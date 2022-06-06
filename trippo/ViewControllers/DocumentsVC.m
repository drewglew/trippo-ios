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
    self.TableViewDocuments.allowsMultipleSelection = YES;
  
    [self loadAttachmentListing];

    self.TableViewDocuments.tableHeaderView = self.ViewHeader;
    [self addDoneToolBarToKeyboard:self.TextFieldURL];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.TableViewDocuments.frame.size.width, 98)];
    self.TableViewDocuments.tableFooterView = footerView;
    
    DocumentFooterFilterHeightConstant = self.FooterHeightConstraint.constant;
    __weak typeof(self) weakSelf = self;
    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        //[weakSelf loadAttachmentListing];
        [weakSelf.TableViewDocuments reloadData];
    }];
    
}


/*
 created date:      25/02/2019
 last modified:     25/07/2021
 remarks:
 */
-(void)loadAttachmentListing {
    
    self.DocumentCollection = [AttachmentRLM objectsWhere:@"isactivity=0"];
    self.documentitems = [[NSMutableArray alloc] init];
    for (AttachmentRLM *baseAttach in self.DocumentCollection) {
        
        AttachmentRLM *activityAttach = [[self.Activity.attachments objectsWhere:@"key=%@",baseAttach.key] firstObject];
        
        AttachNSO *a = [[AttachNSO alloc] init];
        a.filename = baseAttach.filename;
        a.importeddate = baseAttach.importeddate;
        a.key = baseAttach.key;
        a.notes = baseAttach.notes;
        a.isselected = [NSNumber numberWithInteger:[activityAttach.isselected integerValue]];
        [self.documentitems addObject:a];
    }
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
    return self.documentitems.count;
}


/*
 created date:      25/02/2019
 last modified:     25/07/2021
 remarks:           table view with sections.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AttachmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttachmentCellId"];
    if (!cell) {
        cell = [[AttachmentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AttachmentCellId"];
    }
    AttachNSO *document = [self.documentitems objectAtIndex:indexPath.row];
    cell.document = document;
    cell.LabelNotes.text = document.notes;
    cell.LabelUploadedDt.text = [NSString stringWithFormat:@"%@", [ToolBoxNSO FormatPrettyDate:document.importeddate]];
    return cell;
}

/*
 created date:      25/02/2019
 last modified:     25/07/2021
 remarks:
 */

- (void)tableView:(UITableView *)tableView willDisplayCell:(AttachmentCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    AttachNSO *document = [self.documentitems objectAtIndex:indexPath.row];    
    if (cell.document.isselected==[NSNumber numberWithInteger:1]) {
        [cell setSelected: true];
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        [cell setSelected: false];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}


/*
 created date:      25/02/2019
 last modified:     25/07/2021
 remarks:
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AttachNSO *document = [self.documentitems objectAtIndex:indexPath.row];
    document.isselected = [NSNumber numberWithInteger:1];
}


/*
 created date:      25/02/2019
 last modified:     25/07/2021
 remarks:
 */
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath  {
    AttachNSO *document = [self.documentitems objectAtIndex:indexPath.row];
    document.isselected = [NSNumber numberWithInteger:0];
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
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonClickedDismissKeyboard)],
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

/*
 created date:      25/02/2019
 last modified:     25/07/2021
 remarks:
 */
- (IBAction)ActionPressed:(id)sender {
    
    
    [self.Activity.realm beginWriteTransaction];
    [self.Activity.attachments removeAllObjects];
    [self.Activity.realm commitWriteTransaction];
    [self.Activity.realm beginWriteTransaction];
    
    for (AttachNSO *a in self.documentitems) {
        if ([a.isselected longValue] == 1) {
            AttachmentRLM *attach = [[AttachmentRLM alloc] init];
            attach.filename = a.filename;
            attach.importeddate = a.importeddate;
            attach.key = a.key;
            attach.isselected = a.isselected;
            attach.isactivity = [NSNumber numberWithInteger:1];
            attach.notes = a.notes;
            [self.Activity.attachments addObject:attach];
        }
    }
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
                                                                                                 a.isactivity = [NSNumber numberWithInteger:0];
                                                                                                 
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

/*
 created date:      21/03/2021
 last modified:     21/03/2021
 remarks:
 */
- (IBAction)PasteButtonPressed:(id)sender {

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSData *data = [pasteboard dataForPasteboardType:(NSString *)kUTTypePDF];
    
    

    if (data!=nil) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Pasting PDF Document"
                                                                                 message:@"Please amend the file name, so you can identify it when attaching to a Point of Interest or an Activity."
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController.view setTintColor:[UIColor labelColor]];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            // optionally configure the text field
            textField.text = @"Pasted PDF Document";
            textField.keyboardType = UIKeyboardTypeAlphabet;
            [textField setClearButtonMode:UITextFieldViewModeAlways];
        }];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
            
            UITextField *textField = [alertController.textFields firstObject];

            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *pdfDirectory = [paths objectAtIndex:0];
            NSString *dataPath = [pdfDirectory stringByAppendingPathComponent:@"PdfImportedDocs"];
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];

            AttachmentRLM *a = [[AttachmentRLM alloc] init];
            a.key = [[NSUUID UUID] UUIDString];
            a.importeddate = [NSDate date];
            a.filename = [NSString stringWithFormat:@"/PdfImportedDocs/%@.pdf",a.key];
            a.notes = textField.text;
            a.isactivity = [NSNumber numberWithInteger:0];

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
        }];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                                   NSLog(@"You pressed cancel");
                                                               }];
        
        
        
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
