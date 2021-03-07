//
//  TripListVC.m
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ProjectListVC.h"

@interface ProjectListVC ()
@property RLMNotificationToken *notification;
@end



@implementation ProjectListVC
CGFloat ProjectListFooterFilterHeightConstant;
CGFloat TripNumberOfCellsInRow = 2.0f;
CGFloat TripScale = 4.14f;
@synthesize delegate;

/*
 created date:      29/04/2018
 last modified:     11/01/2020
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.CollectionViewProjects.delegate = self;
    
    self.editmode = true;
    
    if (![ToolBoxNSO HasTopNotch]) {
        self.HeaderViewHeightConstraint.constant = 70.0f;
    }
    
    /* user selected specific option from startup view */
    __weak typeof(self) weakSelf = self;
    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf LoadSupportingData];
        [weakSelf.CollectionViewProjects reloadData];
    }];
    [self LoadSupportingData];
    ProjectListFooterFilterHeightConstant = self.FooterWithSegmentConstraint.constant;
    
    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
    [self.CollectionViewProjects addGestureRecognizer:pinch];
    
    self.SegmentFilterProjects.selectedSegmentTintColor = [UIColor colorNamed:@"TrippoColor"];
    [self.SegmentFilterProjects setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor systemBackgroundColor], NSFontAttributeName: [UIFont systemFontOfSize:13]} forState:UIControlStateSelected];
    
    
    RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
    TripNumberOfCellsInRow = [settings[0].TripCellColumns floatValue];
    
    /* handle different devices */
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat cellWidth = width / TripNumberOfCellsInRow;
    TripScale = cellWidth / 50;
    
    /* new block 20200111 */
    
    AssistantRLM *assist = [[settings[0].AssistantCollection objectsWhere:@"ViewControllerName=%@",@"ProjectListVC"] firstObject];

    if ([assist.State integerValue] == 1) {

        UIView* helperView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 350)];
        helperView.backgroundColor = [UIColor labelColor];
        
        helperView.layer.cornerRadius=8.0f;
        helperView.layer.masksToBounds=YES;
        
        UILabel* title = [[UILabel alloc] init];
        title.frame = CGRectMake(10, 18, helperView.bounds.size.width - 20, 24);
        title.textColor =  [UIColor secondarySystemBackgroundColor];
        title.font = [UIFont systemFontOfSize:22 weight:UIFontWeightThin];
        title.text = @"Trips Log";
        title.textAlignment = NSTextAlignmentCenter;
        [helperView addSubview:title];
        
        UIImageView *logo = [[UIImageView alloc] init];
        logo.frame = CGRectMake(10, helperView.bounds.size.height - 50, 80, 40);
        logo.image = [UIImage imageNamed:@"Trippo"];
        [helperView addSubview:logo];
        
        UILabel* helpText = [[UILabel alloc] init];
        helpText.frame = CGRectMake(10, 50, helperView.bounds.size.width - 20, 250);
        helpText.textColor =  [UIColor secondarySystemBackgroundColor];
        helpText.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        helpText.adjustsFontSizeToFitWidth = YES;
        helpText.minimumScaleFactor = 0.5;
        helpText.numberOfLines = 0;
        helpText.text = @"To create a new trip press the (+) symbol.\n\nOnce Trips have been created this is where they will all displayed and where they can be selected. The More button (...) presents the Trip detail where you may set the photo, time zones and dates; selecting a Trip by tapping on the item itself expands the Activity content within.\n\nPinching and zooming the whole Trips Log allows you to increase/decrease the size of the trip items.  Using the options at the bottom you may also hide/show the detail as well as filtering the selection.  If the options disappear just scroll the list up and they will reappear.";
        helpText.textAlignment = NSTextAlignmentLeft;
        [helperView addSubview:helpText];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(helperView.bounds.size.width - 40.0, 3.5, 35.0, 35.0); // x,y,width,height
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightRegular];
        [button setImage:[UIImage systemImageNamed:@"xmark.circle" withConfiguration:config] forState:UIControlStateNormal];
        [button setTintColor: [UIColor secondarySystemBackgroundColor]];
        [button addTarget:self action:@selector(helperViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [helperView addSubview:button];
        
        [self.view addSubview:helperView];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate didDismissPresentingViewController];
}

/*
 created date:      11/01/2020
 last modified:     12/01/2020
 remarks:
 */
-(void)helperViewButtonPressed :(id)sender {
    RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
    AssistantRLM *assist = [[settings[0].AssistantCollection objectsWhere:@"ViewControllerName=%@",@"ProjectListVC"] firstObject];
    NSLog(@"%@",assist);
    if ([assist.State integerValue] == 1) {
        [self.realm beginWriteTransaction];
        assist.State = [NSNumber numberWithInteger:0];
        [self.realm commitWriteTransaction];
    }
    UIView *parentView = [(UIView *)sender superview];
    [parentView setHidden:TRUE];
    
}

/*
 created date:      29/04/2018
 last modified:     06/01/2020
 remarks:
 */
-(void) LoadSupportingData {

    self.tripcollection = [TripRLM allObjects];
    
    RLMSortDescriptor *sort = [RLMSortDescriptor sortDescriptorWithKeyPath:@"startdt" ascending:NO];
    self.tripcollection = [self.tripcollection sortedResultsUsingDescriptors:[NSArray arrayWithObject:sort]];

    
    self.TripImageDictionary = [[NSMutableDictionary alloc] init];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
  
    for (TripRLM *trip in self.tripcollection) {
        ImageCollectionRLM *image = [trip.images firstObject];
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",image.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        if (pngData!=nil) {
            [self.TripImageDictionary setObject:[UIImage imageWithData:pngData] forKey:trip.key];
        } else {
            UIImage *dummy = [[UIImage alloc] init];
            [self.TripImageDictionary setObject:dummy forKey:trip.key];
        }
    }
}

/*
 created date:      21/06/2019
 last modified:     21/06/2019
 remarks:
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:
(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:
(NSIndexPath *)indexPath
{
    return CGSizeMake(50*TripScale, 50*TripScale);
}

/*
 created date:      21/06/2019
 last modified:     24/08/2019
 remarks:           Works on iPhone XR - will it work on an smaller iPhone 7?
 */
-(void)onPinch:(UIPinchGestureRecognizer*)gestureRecognizer
{
    static CGFloat scaleStart;
    CGFloat collectionWidth = self.CollectionViewProjects.frame.size.width;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        scaleStart = TripScale;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        TripScale = scaleStart * gestureRecognizer.scale;
        
        if ( TripScale*50 < collectionWidth / 6) {
            TripScale = (collectionWidth / 6) / 50;
        }
        else
        {
            [self.CollectionViewProjects.collectionViewLayout invalidateLayout];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        // snap to pretty border distribution
        if ( TripScale*50 < collectionWidth / 5) {
            TripScale = (collectionWidth / 5) / 50;
            TripNumberOfCellsInRow = 5.0f;
        } else if (TripScale*50 < collectionWidth / 4) {
            TripScale = (collectionWidth / 4) / 50;
            TripNumberOfCellsInRow = 4.0f;
        } else if (TripScale*50 < collectionWidth / 3) {
            TripScale = (collectionWidth / 3) / 50;
            TripNumberOfCellsInRow = 3.0f;
        } else if (TripScale*50 < collectionWidth / 2) {
            TripScale = (collectionWidth / 2) / 50;
            TripNumberOfCellsInRow = 2.0f;
        } else {
            TripScale = collectionWidth / 50;
            TripNumberOfCellsInRow = 1.0f;
        }
        
        RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
        SettingsRLM *settingitem = [settings firstObject];
        [self.realm transactionWithBlock:^{
            settingitem.TripCellColumns = [NSNumber numberWithFloat:TripNumberOfCellsInRow];
        }];
        
        [self.CollectionViewProjects.collectionViewLayout invalidateLayout];
        [self.CollectionViewProjects reloadData];
        
        if (self.FooterWithSegmentConstraint.constant == 0.0f){
            NSLog(@"pinched without footer");
            [UIView animateWithDuration:0.4f
                                  delay:0.0f
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 
                                 self.FooterWithSegmentConstraint.constant = ProjectListFooterFilterHeightConstant;
                                 [self.view layoutIfNeeded];
                                 
                             } completion:^(BOOL finished) {
                                 
                             }];
        }
        
        
    }
    
}


/*
 created date:      29/04/2018
 last modified:     29/08/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tripcollection.count + 1;;
}

/*
 created date:      29/04/2018
 last modified:     06/01/2020
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ProjectListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"projectCellId" forIndexPath:indexPath];
    
    NSInteger NumberOfItems = self.tripcollection.count + 1;
   
    if (indexPath.row == NumberOfItems -1) {
            
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightRegular];
           
        cell.ImageViewProject.image = [UIImage systemImageNamed:@"plus" withConfiguration:config];
        [cell.ImageViewProject setTintColor: [UIColor colorNamed:@"TrippoColor"]];
        
        cell.isNewAccessor = true;
        cell.VisualEffectsViewBlur.hidden = true;
        
    } else {
        cell.trip = [self.tripcollection objectAtIndex:indexPath.row];
        
        UIImage *image = [self.TripImageDictionary objectForKey:cell.trip.key];
        
        if (CGSizeEqualToSize(image.size, CGSizeZero)) {
            cell.ImageViewProject.image = [UIImage systemImageNamed:@"latch.2.case"];
            
            [cell.ImageViewProject setTintColor: [UIColor systemBackgroundColor]];
            [cell.ImageViewProject setBackgroundColor:[UIColor colorNamed:@"TrippoColor"]];
             
            
        } else {
            cell.ImageViewProject.image = image;
        }

        if (cell.trip.startdt != nil) {
            NSDateFormatter *dtformatter = [[NSDateFormatter alloc] init];
            [dtformatter setDateFormat:@"EEE, dd MMM HH:mm"];
        } 
        
        cell.isNewAccessor = false;
        if (self.editmode) {
            cell.editButton.hidden=false;
            cell.deleteButton.hidden=false;
            cell.VisualEffectsViewBlur.hidden = false;
        } else {
            cell.editButton.hidden=true;
            cell.deleteButton.hidden=true;
            cell.VisualEffectsViewBlur.hidden = true;
        }

        UIFont *font = [UIFont fontWithName:@"AmericanTypewriter" size:20.0f];
        if (TripNumberOfCellsInRow >= 3.0f) {
            if (TripNumberOfCellsInRow > 4.0f) {
                font = [UIFont fontWithName:@"AmericanTypewriter" size:8.0f];
            } else {
                font = [UIFont fontWithName:@"AmericanTypewriter" size:14.0];
            }
            if (TripNumberOfCellsInRow > 3.0f) {
                cell.deleteButton.hidden = true;
            }
        } else {
            cell.deleteButton.hidden = false;
        }
        
        NSDictionary *attributes = @{NSBackgroundColorAttributeName:[UIColor secondarySystemBackgroundColor], NSForegroundColorAttributeName:[UIColor labelColor], NSFontAttributeName:font};
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:cell.trip.name attributes:attributes];
        cell.LabelProjectName.attributedText = string;
        
        cell.LabelProjectName.transform = CGAffineTransformMakeRotation(-.05);
        
    }
    return cell;
}


/*
 created date:      29/04/2018
 last modified:     30/03/2019
 remarks:           presents the trip data entry view in various forms as well as loading from API any weather data.
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger NumberOfItems = self.tripcollection.count + 1;
    
    if (indexPath.row == NumberOfItems -1) {
        /* insert new project item */
        [self performSegueWithIdentifier:@"ShowNewProject" sender:nil];
    } else {
        ProjectListCell *cell = (ProjectListCell *)[self.CollectionViewProjects cellForItemAtIndexPath:indexPath];

        [cell.ActivityIndicatorView startAnimating];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
        /* we select project and go onto it's activities! */
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ActivityListVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityListViewController"];
        controller.delegate = self;
        controller.realm = self.realm;
        controller.TripImage = cell.ImageViewProject.image;
        controller.Trip = [self.tripcollection objectAtIndex:indexPath.row];
       
        [controller setModalPresentationStyle:UIModalPresentationPageSheet];
        [self presentViewController:controller animated:YES completion:nil];
        [cell.ActivityIndicatorView stopAnimating];
    }
}


/*
 created date:      05/02/2019
 last modified:     05/02/2019
 remarks:
 */
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset{
        
    if (velocity.y > 0 && self.FooterWithSegmentConstraint.constant == ProjectListFooterFilterHeightConstant){
        NSLog(@"scrolling down");
        
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.FooterWithSegmentConstraint.constant = 0.0f;
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    if (velocity.y < 0  && self.FooterWithSegmentConstraint.constant == 0.0f){
        NSLog(@"scrolling up");
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             self.FooterWithSegmentConstraint.constant = ProjectListFooterFilterHeightConstant;
                             [self.view layoutIfNeeded];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}







/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:            .
 */
- (IBAction)EditModePressed:(id)sender {
    self.editmode = !self.editmode;
    [self.CollectionViewProjects reloadData];
    
}

- (IBAction)SwitchEditModePressed:(id)sender {
    self.editmode = !self.editmode;
    [self.CollectionViewProjects reloadData];
}


/*
 created date:      28/04/2018
 last modified:     29/04/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"ShowUpdateProject"]){
        ProjectDataEntryVC *controller = (ProjectDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.realm = self.realm;
        if ([sender isKindOfClass: [UIButton class]]) {
            UIView * cellView=(UIView*)sender;
            while ((cellView = [cellView superview])) {
                if([cellView isKindOfClass:[ProjectListCell class]]) {
                    ProjectListCell *cell = (ProjectListCell*)cellView;
                    NSIndexPath *indexPath = [self.CollectionViewProjects indexPathForCell:cell];
                    controller.Trip = [self.tripcollection objectAtIndex:indexPath.row];
                }
            }
         }
        controller.newitem = false;

    } else if([segue.identifier isEqualToString:@"ShowDeleteProject"]){
        [self DeleteTrip:sender];
        
    } else if([segue.identifier isEqualToString:@"ShowNewProject"]){
        ProjectDataEntryVC *controller = (ProjectDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.realm = self.realm;
        controller.Trip = [[TripRLM alloc] init];
        controller.Project = [[ProjectNSO alloc] init];
        controller.newitem = true;
    }
}
/*
 created date:      24/06/2018
 last modified:     24/06/2018
 remarks:
 */
- (IBAction)SegmentFilteredChanged:(id)sender {
    //NSLog(@"%@",[NSNumber numberWithInteger:self.SegmentFilterProjects.selectedSegmentIndex]);
    [self FilterProjectCollectionView];
}

/*
 created date:      24/06/2018
 last modified:     06/01/2020
 remarks:
 */
-(void)FilterProjectCollectionView {

    NSDate* currentDate = [NSDate date];
    self.tripcollection = [TripRLM allObjects];
    
    if (self.SegmentFilterProjects.selectedSegmentIndex == 0) {
        NSLog(@"All - %d",0);
    } else if (self.SegmentFilterProjects.selectedSegmentIndex == 1) {
        NSLog(@"Past - %d",1);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"enddt < %@", currentDate];
        self.tripcollection = [self.tripcollection objectsWithPredicate:predicate];
    } else if (self.SegmentFilterProjects.selectedSegmentIndex == 2) {
        NSLog(@"Future - %d",2);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startdt > %@", currentDate];
        self.tripcollection = [self.tripcollection objectsWithPredicate:predicate];
    } else {
        NSLog(@"Current");
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startdt <= %@ AND enddt >= %@", currentDate,currentDate];
        self.tripcollection = [self.tripcollection objectsWithPredicate:predicate];
    }
    
    RLMSortDescriptor *sort = [RLMSortDescriptor sortDescriptorWithKeyPath:@"startdt" ascending:NO];
    self.tripcollection = [self.tripcollection sortedResultsUsingDescriptors:[NSArray arrayWithObject:sort]];

    
    [self.CollectionViewProjects reloadData];
}

/*
 created date:      07/10/2018
 last modified:     07/10/2018
 remarks:
 */
- (NSString *)emojiFlagForISOCountryCode:(NSString *)countryCode {
    NSAssert(countryCode.length == 2, @"Expecting ISO country code");
    
    int base = 127462 -65;
    
    wchar_t bytes[2] = {
        base +[countryCode characterAtIndex:0],
        base +[countryCode characterAtIndex:1]
    };
    
    return [[NSString alloc] initWithBytes:bytes
                                    length:countryCode.length *sizeof(wchar_t)
                                  encoding:NSUTF32LittleEndianStringEncoding];
}

/*
 created date:      30/03/2019
 last modified:     30/03/2019
 remarks:
 */
-(void)DeleteTrip: (id)sender {
    
    TripRLM *TripToDelete = [[TripRLM alloc] init];
    if ([sender isKindOfClass: [UIButton class]]) {
        UIView * cellView=(UIView*)sender;
        while ((cellView= [cellView superview])) {
            if([cellView isKindOfClass:[ProjectListCell class]]) {
                ProjectListCell *cell = (ProjectListCell*)cellView;
                TripToDelete = cell.trip;
            }
        }
    }
    
    if (TripToDelete!=nil) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Delete Trip\n%@", TripToDelete.name ] message:@"Are you sure you want to remove complete trip and all activities?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        
        [alert.view setTintColor:[UIColor labelColor]];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      
                                                                      /* locate all activities */
                                                                      RLMResults <ActivityRLM*> *activities = [ActivityRLM objectsWhere:@"tripkey=%@",self.Trip.key];
                                                                      
                                                                      /* remove any notifications attached */
                                                                      for (ActivityRLM* activity in activities) {
                                                                          [self RemoveGeoNotification :true :activity];
                                                                          [self RemoveGeoNotification :false :activity];
                                                                      }
                                                                      
                                                                      /* delete actvities */
                                                                      [self.realm transactionWithBlock:^{
                                                                          [self.realm deleteObjects:activities];
                                                                      }];
                                                                      
                                                                      /* finally delete trip */
                                                                      [self.realm transactionWithBlock:^{
                                                                          [self.realm deleteObject:TripToDelete];
                                                                      }];
                                                                      
                                                                  });
                                                              }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 // do nothing..
                                                                 
                                                             }];
        
        [alert addAction:defaultAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

/*
 created date:      30/03/2019
 last modified:     30/03/2019
 remarks:
 */
-(void) RemoveGeoNotification :(bool) NotifyOnEntry :(ActivityRLM*) activity {
    NSString *identifier;
    
    if (NotifyOnEntry) {
        identifier = [NSString stringWithFormat:@"CHECKIN~%@", activity.compondkey];
    } else {
        identifier = [NSString stringWithFormat:@"CHECKOUT~%@", activity.compondkey];
    }
    
    NSArray *pendingNotification = [NSArray arrayWithObjects:identifier, nil];
    [AppDelegateDef.UserNotificationCenter removePendingNotificationRequestsWithIdentifiers:pendingNotification];
}





@end
