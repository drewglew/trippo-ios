//
//  DocumentsVC.m
//  trippo-app
//
//  Created by andrew glew on 25/02/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import "DocumentsVC.h"

@interface DocumentsVC ()
@property RLMNotificationToken *notification;
@end

@implementation DocumentsVC
CGFloat DocumentFooterFilterHeightConstant;

/*
 created date:      25/02/2019
 last modified:     26/02/2019
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.TableViewDocuments.delegate = self;
    self.TableViewDocuments.rowHeight = 75.0f;
  
    [self loadAttachmentListing];

    self.TableViewDocuments.tableHeaderView = self.ViewHeader;
    [self addDoneToolBarToKeyboard:self.TextFieldURL];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.TableViewDocuments.frame.size.width, 98)];
    self.TableViewDocuments.tableFooterView = footerView;
    
    DocumentFooterFilterHeightConstant = self.FooterHeightConstraint.constant;
    __weak typeof(self) weakSelf = self;
    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf loadAttachmentListing];
        [weakSelf.TableViewDocuments reloadData];
    }];
    
}


-(void)loadAttachmentListing {
    self.DocumentCollection = [AttachmentRLM allObjects];
}


/*
 created date:      25/02/2019
 last modified:     25/02/2019
 remarks:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*
 created date:      25/02/2019
 last modified:     25/02/2019
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.DocumentCollection.count;
}


/*
 created date:      25/02/2019
 last modified:     27/02/2019
 remarks:           table view with sections.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AttachmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttachmentCellId"];
    AttachmentRLM *document = [self.DocumentCollection objectAtIndex:indexPath.row];
    cell.LabelNotes.text = document.notes;
    cell.LabelUploadedDt.text = [NSString stringWithFormat:@"%@", [ToolBoxNSO FormatPrettyDate:document.importeddate]];
    cell.document = document;
       return cell;
}

/*
 created date:      26/02/2019
 last modified:     26/02/2019
 remarks:           table view with sections.
 */

- (void)tableView:(UITableView *)tableView willDisplayCell:(AttachmentCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    AttachmentRLM *document = [self.DocumentCollection objectAtIndex:indexPath.row];
    RLMResults <AttachmentRLM*> *items = [self.Activity.attachments objectsWhere:@"key=%@",document.key];
    
    // NSLog(@"Key - %@",self.Activity.attachments[0].key);
    NSLog(@"document = %@",document);
    NSLog(@"activity attachments  = %@",self.Activity);
    
    if (items.count==0) {
        [cell setSelected: false];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    } else {
        
        [cell setSelected: true];
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    AttachmentRLM *document = [self.DocumentCollection objectAtIndex:indexPath.row];
    
    NSLog(@"%@",document);
    
    [self.realm transactionWithBlock:^{
        document.isselected = [NSNumber numberWithInt:1];
    }];
    
    
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath  {
    AttachmentRLM *document = [self.DocumentCollection objectAtIndex:indexPath.row];
    
    NSLog(@"%@",document);
    
    [self.realm transactionWithBlock:^{
        document.isselected = [NSNumber numberWithInt:0];
    }];
    
    
}

/*
 created date:      26/02/2019
 last modified:     26/02/2019
 remarks:
 */
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if (velocity.y > 0 && self.FooterHeightConstraint.constant == DocumentFooterFilterHeightConstant){
        NSLog(@"scrolling down");
        
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.FooterHeightConstraint.constant = 0.0f;
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    if (velocity.y < 0  && self.FooterHeightConstraint.constant == 0.0f){
        NSLog(@"scrolling up");
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             self.FooterHeightConstraint.constant = DocumentFooterFilterHeightConstant;
                             [self.view layoutIfNeeded];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}


/*
 created date:      27/02/2019
 last modified:     27/02/2019
 remarks:           User can only delete unused Poi items
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL edit = YES;
    return edit;
}

/*
created date:      14/09/2019
last modified:     14/09/2019
remarks:
*/
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    UIContextualAction *deleteAction = [[UIContextualAction alloc] init];
    
    deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        [self tableView:tableView deleteDocument:indexPath];
        self.TableViewDocuments.editing = NO;
    }];
    
    deleteAction.backgroundColor = [UIColor systemRedColor];
    deleteAction.image = [UIImage systemImageNamed:@"trash"];

    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    config.performsFirstActionWithFullSwipe = NO;
    return config;
}

/*
 created date:      27/02/2019
 last modified:     27/02/2019
 remarks:           Might not be totally necessary, but seperated out from editActionsForRowAtIndexPath method above.
 */
- (void)tableView:(UITableView *)tableView deleteDocument:(NSIndexPath *)indexPath  {
    
    AttachmentRLM *item = [self.DocumentCollection objectAtIndex:indexPath.row];
    
    RLMResults *usedactivities = [ActivityRLM objectsWhere:@"ANY attachments.key = %@",item.key];
    
    if (usedactivities.count == 0) {
        [self.realm transactionWithBlock:^{
            [self.realm deleteObject:item];
        }];
    }
    
    NSLog(@"delete called!");
}


/*
 created date:      26/02/2019
 last modified:     26/02/2019
 remarks:
 */
-(void)addDoneToolBarToKeyboard:(UITextField *)textField
{
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleDefault;
    //doneToolbar.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0];
    [doneToolbar setTintColor:[UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClickedDismissKeyboard)],
                         nil];
    [doneToolbar sizeToFit];
    textField.inputAccessoryView = doneToolbar;
}

/*
 created date:      26/02/2019
 last modified:     26/02/2019
 remarks:
 */
-(void)doneButtonClickedDismissKeyboard
{
    [self.TextFieldURL resignFirstResponder];
}


/*
 created date:      25/02/2019
 last modified:     27/02/2019
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}


- (IBAction)ActionPressed:(id)sender {
    
    //NSArray *selectedIndexPathArray = [self.TableViewDocuments indexPathsForSelectedRows];
    
    
    
    
    [self.Activity.realm beginWriteTransaction];
    
    [self.Activity.attachments removeAllObjects];
    [self.Activity.realm commitWriteTransaction];
    
    [self.Activity.realm beginWriteTransaction];
    
    //NSArray *selectedIndexPathArray = [self.TableViewDocuments indexPathsForSelectedRows];
    
    for (AttachmentRLM *a in self.DocumentCollection) {
        
        NSLog(@"Attachment: %@",a);
        
        if ([a.isselected intValue] == 1) {
            [self.Activity.attachments addObject:a];
        }
    }
    /*for (NSIndexPath *indexPath in selectedIndexPathArray) {
        AttachmentRLM *item = [self.DocumentCollection objectAtIndex:indexPath.row];
        
        [self.Activity.attachments addObject:item];
        
        NSLog(@"Activity Attachments: %@",self.Activity.attachments );
        NSLog(@"%@", item.notes);
    }*/
    
    //NSLog(@"number of attachments in Activity:%lu",(unsigned long)self.Activity.attachments.count);
    
    /*
    for (int section = 0; section < [self.TableViewDocuments numberOfSections]; section++) {
        for (int row = 0; row < [self.TableViewDocuments numberOfRowsInSection:section]; row++) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            AttachmentCell* cell = [self.TableViewDocuments cellForRowAtIndexPath:cellPath];
            
            
            if (cell.isSelected) {
                 [self.Activity.attachments addObject:cell.document];
            } else {
                NSLog(@"%@",cell.document.notes);
            }
        }
    }
     */
    [self.Activity.realm commitWriteTransaction];
    
    [self dismissViewControllerAnimated:YES completion:Nil];
}


/*
 created date:      25/02/2019
 last modified:     26/02/2019
 remarks:
 */
- (IBAction)UploadPdfPressed:(id)sender {
    
    NSString *urlstring = self.TextFieldURL.text;
    NSURL *url = [NSURL URLWithString:[urlstring stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    NSString *PdfOriginalFileName = [url.absoluteString lastPathComponent];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Importing PDF Document"
                                                                             message:@"Please amend the file name, so you can identify it when attaching to a Point of Interest or an Activity."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    
    [alertController.view setTintColor:[UIColor labelColor]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // optionally configure the text field
        textField.text = PdfOriginalFileName;
        textField.keyboardType = UIKeyboardTypeAlphabet;
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action) {
                                                   UITextField *textField = [alertController.textFields firstObject];
                                                   
                                                   __block NSString *PdfFileName = textField.text;
                                                   
                                                   NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                                                                         dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                                             
                                                                                             if ([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]) {
                                                                                                 NSLog(@"error");
                                                                                                 dispatch_async(dispatch_get_main_queue(), ^(void){
                                                                                                     self.TextFieldURL.text=@"Error!";
                                                                                                     //[self.ActivityIndicator stopAnimating];
                                                                                                     //[self.ViewLoading setHidden:TRUE];
                                                                                                     //self.webView.hidden = true;
                                                                                                 });
                                                                                                 
                                                                                             } else {
       
                                                                                                 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                                                                                 NSString *pdfDirectory = [paths objectAtIndex:0];
                                                                                                 NSString *dataPath = [pdfDirectory stringByAppendingPathComponent:@"PdfImportedDocs"];
                                                                                                 [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
                                                                                                 
                                                                                                 AttachmentRLM *a = [[AttachmentRLM alloc] init];
                                                                                                 a.key = [[NSUUID UUID] UUIDString];
                                                                                                 a.importeddate = [NSDate date];
                                                                                                 a.filename = [NSString stringWithFormat:@"/PdfImportedDocs/%@.pdf",a.key];
                                                                                                 a.notes = PdfFileName;
                                                                                                 
                                                                                                 pdfDirectory = [pdfDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"PdfImportedDocs/%@.pdf", a.key]];
                                                                                                 
                                                                                                 
                                                                                                 NSError *error;
                                                                                                 bool success = [data writeToFile: pdfDirectory  options:NSDataWritingAtomic error:&error];
                                                                                                 if (!success) {
                                                                                                     NSLog(@"writeToFile failed with error %@", error);
                                                                                                    dispatch_async(dispatch_get_main_queue(), ^(void){
                                                                                                         self.TextFieldURL.text=@"Error saving file!";
                                                                                                     });
                                                                                                 } else {
                                                                                                     dispatch_async(dispatch_get_main_queue(), ^(void){
                                                                                                         [self.realm beginWriteTransaction];
                                                                                                         [self.realm addObject:a];
                                                                                                         [self.realm commitWriteTransaction];
                                                                                                         
                                                                                                     });
                                                                                                 }
                                                                                                 
                                                                                             }
                                                                                         }];
                                                   
                                                   [downloadTask resume];
                                                   
                                                   
                                               }];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    //[self.ActivityIndicator startAnimating];
    //[self.ViewLoading setHidden:FALSE];
}

/*
 created date:      25/02/2019
 last modified:     25/02/2019
 remarks:
 */
- (IBAction)SegmentFilter:(id)sender {
}



@end
