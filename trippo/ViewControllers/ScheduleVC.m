//
//  ScheduleCV.m
//  travelme
//
//  Created by andrew glew on 05/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ScheduleVC.h"

@interface ScheduleVC ()

@end

NSIndexPath *activeCellIndexPath;

@implementation ScheduleVC

/*
 created date:      28/04/2018
 last modified:     05/10/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.TableViewScheduleItems.delegate = self;
    self.TableViewScheduleItems.rowHeight = 200;
    self.level = 0;
    
    if (self.ActivityState == [NSNumber numberWithLong:0]) {
        self.labelHeader.text = [NSString stringWithFormat:@"%@ - Itinerary", self.Trip.name];
    } else {
        self.labelHeader.text = [NSString stringWithFormat:@"%@ - Journey", self.Trip.name];;
    }
    [self LoadScheduleData];
    // Do any additional setup after loading the view.
}

/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

/*
 created date:      28/04/2018
 last modified:     22/10/2018
 remarks:
 */
-(void) LoadScheduleData {
    //self.scheduleitems = [AppDelegateDef.Db GetActivitySchedule:self.Project.key :self.ActivityState];
    /* used to dynamically set the width of the hiararcy view */
    
    self.scheduleitems = [[NSMutableArray alloc] init];
    self.ActivityImageDictionary = [[NSMutableDictionary alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
    ImageCollectionRLM *imgobject;
    RLMResults *filteredResults;

    RLMResults <ActivityRLM*> *ActivitiesInTrip = [ActivityRLM objectsWhere:@"tripkey = %@ and state=%@", self.Trip.key, self.ActivityState];

    int SortOrder = 0;
    for (ActivityRLM *activityobj in ActivitiesInTrip) {
        
        NSLog(@"name:%@",activityobj.poi.name);
        
        ScheduleNSO *itemBegin = [[ScheduleNSO alloc] init];
        itemBegin.compondkey = activityobj.compondkey;
        itemBegin.dt = activityobj.startdt;
        itemBegin.name = activityobj.name;
        itemBegin.poi = [PoiRLM objectForPrimaryKey:activityobj.poikey];
        itemBegin.type = @"begin";
        itemBegin.enddatesameasstart = false;
        itemBegin.transportid = [NSNumber numberWithInt:0]; // car
        itemBegin.sortorder = [NSNumber numberWithInt:SortOrder];
        itemBegin.Coordinates = CLLocationCoordinate2DMake([itemBegin.poi.lat doubleValue], [itemBegin.poi.lon doubleValue]);
        itemBegin.categoryid = itemBegin.poi.categoryid;
        itemBegin.activityitem = activityobj;
        
        // try to get image reference.
        [self.scheduleitems addObject:itemBegin];
        ScheduleNSO *itemEnd = [[ScheduleNSO alloc] init];
        itemEnd.compondkey = activityobj.compondkey;
        itemEnd.dt = activityobj.enddt;
        itemEnd.name = activityobj.name;
        itemEnd.poi = itemBegin.poi;
        itemEnd.type = @"end";
        itemEnd.activityitem = activityobj;
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:activityobj.startdt toDate:activityobj.enddt options:0];
        if (components.day==0 && components.hour==0 && components.minute==0) {
            itemEnd.enddatesameasstart = true;
        } else {
            itemEnd.enddatesameasstart = false;
        }
        itemBegin.transportid = [NSNumber numberWithInt:0]; // car
        itemEnd.sortorder = [NSNumber numberWithInt:SortOrder];
        itemEnd.Coordinates = CLLocationCoordinate2DMake([itemEnd.poi.lat doubleValue], [itemEnd.poi.lon doubleValue]);
        itemEnd.categoryid = itemEnd.poi.categoryid;
        // try to get image reference.
        [self.scheduleitems addObject:itemEnd];

        SortOrder ++;
        /* Image handling */
        imgobject = [[ImageCollectionRLM alloc] init];
        filteredResults = [activityobj.images objectsWithPredicate:predicate];
        if (filteredResults.count>0) {
            imgobject = [filteredResults firstObject];
        } else {
            PoiRLM *poiobject = [PoiRLM objectForPrimaryKey:activityobj.poikey];
            filteredResults = [poiobject.images objectsWithPredicate:predicate];
            if (filteredResults.count==0) {
                imgobject = [poiobject.images firstObject];
            } else {
                imgobject = [filteredResults firstObject];
            }
        }
        
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imgobject.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        if (pngData==nil) {
            [self.ActivityImageDictionary setObject:[UIImage imageNamed:@"Activity"] forKey:activityobj.compondkey];
        } else {
            [self.ActivityImageDictionary setObject:[UIImage imageWithData:pngData] forKey:activityobj.compondkey];
        }
    }
    
    [self RedrawHierarcy];
    
    self.LabelItemCounter.text = [NSString stringWithFormat:@"%lu Items",(unsigned long)self.scheduleitems.count];
    [self.TableViewScheduleItems reloadData];
}

/*
 created date:      21/10/2018
 last modified:     21/10/2018
 remarks:
 */
-(void) RedrawHierarcy {
    /* now sort the scheduleitems */
    NSSortDescriptor *sortDescriptorDate = [[NSSortDescriptor alloc] initWithKey:@"dt" ascending:YES];
    NSSortDescriptor *sortDescriptorOrder = [[NSSortDescriptor alloc] initWithKey:@"sortorder" ascending:YES];

    [self.scheduleitems sortUsingDescriptors:@[sortDescriptorDate,sortDescriptorOrder]];
    self.MaxNbrOfHierarcyLevels=0;
    int index = 0;
    ScheduleNSO *LastSchedule = [[ScheduleNSO alloc] init];
    for (ScheduleNSO *schedule in self.scheduleitems) {
        
        if([schedule.type isEqualToString:@"begin"]) {
            index ++;
            schedule.hierarcyindex = index;
        } else {
            schedule.hierarcyindex = index;
            index --;
        }
        LastSchedule = schedule;
    }

    /* loop through to get the key images we need as well as the maximum amount of levels in hierarcy */
    for (ScheduleNSO *schedule in self.scheduleitems) {
        if(schedule.hierarcyindex > self.MaxNbrOfHierarcyLevels) {
            self.MaxNbrOfHierarcyLevels = schedule.hierarcyindex;
        }
    }
}






- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}


/*
 created date:      05/05/2018
 last modified:     05/05/2018
 remarks:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*
 created date:      05/05/2018
 last modified:     05/05/2018
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.scheduleitems.count;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.TableViewScheduleItems.frame.size.width, 62)];
    return headerView;
}



/*
 created date:      05/05/2018
 last modified:     04/10/2018
 remarks:
 */
- (ScheduleCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    float Spacer = 75;
    float LeftMargin = 10;
    float RightMargin = 10;
    float ImageWidthHeight = 100;
    int LineStyle = 0;
    
    static NSString *CellIdentifier = @"ScheduleCellId";
    ScheduleCell *cell = [self.TableViewScheduleItems dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ScheduleCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    cell.schedule = [self.scheduleitems objectAtIndex:indexPath.row];
    
    //linestyle 0 = start
    //linestyle 1 = through
    //linestyle 2 = end
    //linestyle 3 = none

    if (indexPath.row == 0) {
        LineStyle = 0;
    } else if (self.scheduleitems.count <= indexPath.row + 1) {
        LineStyle = 2;
    } else {
        ScheduleNSO *nextSchedule = [self.scheduleitems objectAtIndex:indexPath.row + 1];
        ScheduleNSO *prevSchedule = [self.scheduleitems objectAtIndex:indexPath.row - 1];
        if (prevSchedule.hierarcyindex < cell.schedule.hierarcyindex && nextSchedule.hierarcyindex < cell.schedule.hierarcyindex ) {
            
            LineStyle = 3;
        } else if (nextSchedule.hierarcyindex < cell.schedule.hierarcyindex) {
            
            LineStyle = 2;
        } else if (prevSchedule.hierarcyindex < cell.schedule.hierarcyindex) {
            
            LineStyle = 0;
        } else {
            
            LineStyle = 1;
        }
    }

    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.ViewHierarcyDetail attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.view.bounds.size.width]];

    //cell.LabelActivity.text = cell.schedule.name;
    //cell.LabelSpanDateTime.text = [NSString stringWithFormat:@"%@", [self FormatPrettyDates :cell.schedule.dt]];
    

    // we have number of columns..
    if ((LeftMargin + (Spacer * self.MaxNbrOfHierarcyLevels) + ImageWidthHeight + RightMargin) > cell.contentView.bounds.size.width) {
        Spacer = (cell.contentView.bounds.size.width - (LeftMargin + RightMargin + (ImageWidthHeight/2))) / (self.MaxNbrOfHierarcyLevels);
    }

    [cell.ViewHierarcyDetail addColumns :cell.schedule.hierarcyindex :LineStyle :Spacer];

    NSArray *viewsToRemove = [cell.ViewHierarcyDetail subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }

    /* TRANSPORT BUTTON
     little white button above main badge - not on the first item indexpath.row 0 */
    if (indexPath.row!=0) {
        cell.TransportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        // set the frame and title you want
        // find the Y pos of where the button will be within cell view
        CGFloat PositionTransportButtonY = 10;
        CGFloat TransportButtonWH = 40;
        [cell.TransportButton setFrame:CGRectMake(LeftMargin + (Spacer * (cell.schedule.hierarcyindex - 1)), PositionTransportButtonY, TransportButtonWH, TransportButtonWH)];
        
        if (cell.schedule.transportid == [NSNumber numberWithInt:1]) {
            [cell.TransportButton setImage:[UIImage imageNamed:@"transport-walk"] forState:UIControlStateNormal];
        } else  if (cell.schedule.transportid == [NSNumber numberWithInt:2]) {
            [cell.TransportButton setImage:[UIImage imageNamed:@"transport-public"] forState:UIControlStateNormal];
        } else {
             [cell.TransportButton setImage:[UIImage imageNamed:@"transport-car"] forState:UIControlStateNormal];
        }
        cell.TransportButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [cell.TransportButton setBackgroundColor:[UIColor colorWithRed:218.0f/255.0f green:212.0f/255.0f blue:239.0f/255.0f alpha:1.0]];
        [cell.TransportButton addTarget:self
                          action:@selector(TransportButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        cell.TransportButton.layer.cornerRadius = (TransportButtonWH / 2);
        cell.TransportButton.clipsToBounds = YES;
        [cell.ViewHierarcyDetail addSubview:cell.TransportButton];
    }
    
    /* SCHEDULE BADGE BUTTON
     Picture on node and main button  */
    UIButton *ScheduleBadge = [UIButton buttonWithType:UIButtonTypeCustom];
    // set the frame and title you want
    // find the Y pos of where the button will be within cell view
    CGFloat PositionButtonY = (cell.contentView.bounds.size.height / 2) - (ImageWidthHeight / 2);
    [ScheduleBadge setFrame:CGRectMake(LeftMargin + (Spacer * (cell.schedule.hierarcyindex - 1)), PositionButtonY, ImageWidthHeight, ImageWidthHeight)];
    
    [ScheduleBadge setTitle:@"button" forState:UIControlStateNormal];
    // set action/target you want
    [ScheduleBadge setImage:[self.ActivityImageDictionary objectForKey:cell.schedule.compondkey] forState:UIControlStateNormal];
    
    [ScheduleBadge addTarget:self
          action:@selector(ScheduleBadgePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    ScheduleBadge.layer.cornerRadius = (ImageWidthHeight / 2);
    ScheduleBadge.clipsToBounds = YES;

    [cell.ViewHierarcyDetail addSubview:ScheduleBadge];

    /* Node Label
     name  */
    CGFloat LabelViewWidth = 100;
    CGFloat LabelViewHeight = 50;
    CGFloat PositionLabelViewY = cell.contentView.bounds.size.height - LabelViewHeight;
    
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(LeftMargin + (Spacer * (cell.schedule.hierarcyindex - 1)), PositionLabelViewY, LabelViewWidth, LabelViewHeight)];

    CGFloat LabelNameWidth = 100;
    CGFloat LabelNameHeight = 40;
    CGFloat LabelNameLeftMargin = 0;
    CGFloat LabelNameTopMargin = 5;
    
    UILabel *labelName = [[UILabel alloc]initWithFrame:CGRectMake(LabelNameLeftMargin, LabelNameTopMargin, LabelNameWidth, LabelNameHeight)];
    
    labelName.text = cell.schedule.name;
    [labelName setNumberOfLines:2];
    [labelName setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [labelName setTextAlignment:NSTextAlignmentCenter];
    [labelName setTextColor:[UIColor whiteColor]];
    [labelName setBackgroundColor:[UIColor colorWithRed:173.0f/255.0f green:52.0f/255.0f blue:62.0f/255.0f alpha:1.0]];
    labelName.layer.borderWidth = 1.0f;
    labelName.layer.borderColor = [UIColor colorWithRed:173.0f/255.0f green:52.0f/255.0f blue:62.0f/255.0f alpha:1.0].CGColor;
    
    labelName.layer.cornerRadius = 5;
    labelName.layer.masksToBounds = true;
    
    [view addSubview:labelName];
    
    [cell.ViewHierarcyDetail addSubview:view];

    [cell.ViewHierarcyDetail setNeedsDisplay];
    return cell;
}


- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.TableViewScheduleItems.frame.size.width, 70)];
    return footerView;
}


/*
 created date:      06/05/2018
 last modified:     06/05/2018
 remarks:
 */
-(NSString*)FormatPrettyDates :(NSDate*)ActivityDt {
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"dd MMM yyyy HH:mm"];
    [dateformatter setTimeZone:[NSTimeZone localTimeZone]];
    return [NSString stringWithFormat:@"%@",[dateformatter stringFromDate:ActivityDt]];
}

/*
 created date:      08/05/2018
 last modified:     08/05/2018
 remarks:           segue controls.
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowProjectDirections"]){
        // todo
        DirectionsVC *controller = (DirectionsVC *)segue.destinationViewController;
        controller.delegate = self;
        NSMutableArray *Route = [[NSMutableArray alloc] init];
        for (ScheduleNSO *schedule in self.scheduleitems) {
            PoiRLM *item = [[PoiRLM alloc] init];
            item.lat = schedule.poi.lat;
            item.lon = schedule.poi.lon;
            item.transportid = schedule.transportid;
            item.name = schedule.poi.name;
            item.administrativearea = schedule.poi.administrativearea;
            [Route addObject:item];
        }
        controller.ActivityState = self.ActivityState;
        controller.Route = Route;
        controller.FromScheduler = true;
        controller.realm = self.realm;
        controller.Trip = self.Trip;
        controller.scheduleitems = self.scheduleitems;
    }
}

/*
 created date:      04/10/2018
 last modified:     05/10/2018
 remarks:
 */
- (IBAction)ResetPressed:(id)sender {
    [self LoadScheduleData];
}

/*
 created date:      06/10/2018
 last modified:     06/10/2018
 remarks:           when badge is pressed present a view
 */
-(void)TransportButtonPressed:(id)sender {
    NSLog(@"Transport Pressed!");

    if ([sender isKindOfClass: [UIButton class]]) {
        UIView * cellView=(UIView*)sender;
        while ((cellView= [cellView superview])) {
            if([cellView isKindOfClass:[ScheduleCell class]]) {
                ScheduleCell *cell = (ScheduleCell*)cellView;
                //NSString *key = cell.schedule.compondkey;
                NSIndexPath *indexPath = [self.TableViewScheduleItems indexPathForCell:cell];
                ScheduleNSO *item = [self.scheduleitems objectAtIndex:(int)indexPath.row];
                
                
                if (item.transportid == [NSNumber numberWithInt:1]) {
                    item.transportid = [NSNumber numberWithInt:2];
                    [cell.TransportButton setImage:[UIImage imageNamed:@"transport-public"] forState:UIControlStateNormal];
                } else  if (item.transportid == [NSNumber numberWithInt:2]) {
                    item.transportid = [NSNumber numberWithInt:0];
                    [cell.TransportButton setImage:[UIImage imageNamed:@"transport-car"] forState:UIControlStateNormal];
                } else {
                    item.transportid = [NSNumber numberWithInt:1];
                    [cell.TransportButton setImage:[UIImage imageNamed:@"transport-walk"] forState:UIControlStateNormal];
                }
                
            }
        }
    }
    
}

/*
 created date:      04/10/2018
 last modified:     22/10/2018
 remarks:           when badge is pressed present a view
 */
-(void)ScheduleBadgePressed:(id)sender {
    // handle the action
    NSLog(@"Pressed!");
    
    if ([sender isKindOfClass: [UIButton class]]) {
        UIView * cellView=(UIView*)sender;
        while ((cellView= [cellView superview])) {
            if([cellView isKindOfClass:[ScheduleCell class]]) {
                ScheduleCell *cell = (ScheduleCell*)cellView;
                
                bool PresentAlertController = false;
                
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:[NSString stringWithFormat:@"%@",cell.schedule.name]
                                             message:@"Choose one of the following options on the item pressed"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                if (@available(iOS 13.0, *)) {
                     [alert.view setTintColor:[UIColor labelColor]];
                } else {
                    // Fallback on earlier versions
                }
                
                NSString *key = cell.schedule.compondkey;
                activeCellIndexPath = [self.TableViewScheduleItems indexPathForCell:cell];
                // Remove end node
                if ([cell.schedule.type isEqualToString:@"end"] || [cell.schedule.type isEqualToString:@"middle"]) {
                
                    bool OkToDelete = false;
                
                    ScheduleNSO *item = [self.scheduleitems objectAtIndex:(int)activeCellIndexPath.row - 1];
                    if ([key isEqualToString:item.compondkey]) {
                        OkToDelete = true;
                    }
                    
                    if (OkToDelete) {
                        UIAlertAction* DeleteButton = [UIAlertAction
                                            actionWithTitle:@"Keep only first node?"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                
                                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(NOT compondkey MATCHES %@) OR (compondkey MATCHES %@ AND type == %@)",cell.schedule.compondkey,cell.schedule.compondkey,@"begin"];
                                                [self.scheduleitems filterUsingPredicate:predicate];
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                    
                                                    [self.TableViewScheduleItems reloadData];
                                                    self.LabelItemCounter.text = [NSString stringWithFormat:@"%lu Items",(unsigned long)self.scheduleitems.count];
                                                });
                                                
                                            }];
                        [alert addAction:DeleteButton];
                        PresentAlertController = true;
                    }
                }
                
                // Delete whole activity
                int currentHirarcyIndex = cell.schedule.hierarcyindex;
                
                
                if ([cell.schedule.type isEqualToString:@"begin"]) {
                    
                    bool noChild = true;
                    if (self.scheduleitems.count > activeCellIndexPath.row + 1) {
                        ScheduleNSO *childitem = [self.scheduleitems objectAtIndex:(int)activeCellIndexPath.row + 1];
                        if (childitem.hierarcyindex > currentHirarcyIndex) {
                            noChild = false;
                        }
                    }
                    if (noChild) {
                        UIAlertAction* DeleteSet = [UIAlertAction
                                                        actionWithTitle:@"Delete nodes?"
                                                        style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            
                                                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (compondkey MATCHES %@)",cell.schedule.compondkey];
                                                            [self.scheduleitems filterUsingPredicate:predicate];
                                                            
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [self.TableViewScheduleItems reloadData];
                                                                self.LabelItemCounter.text = [NSString stringWithFormat:@"%lu Items",(unsigned long)self.scheduleitems.count];
                                                            });
                                                            
                                                        }];
                        [alert addAction:DeleteSet];
                        PresentAlertController = true;
                    }
                }

                // Set back
                if (currentHirarcyIndex>1 && [cell.schedule.type isEqualToString:@"end"]) {
                    
                    int hiaracyIndex = cell.schedule.hierarcyindex;
                    //NSIndexPath *indexPath = [self.TableViewScheduleItems indexPathForCell:cell];
                    
                    // might not be strong enough..
                    
                    ScheduleNSO *parentObject = [[ScheduleNSO alloc] init];
                    for (int i = (int)activeCellIndexPath.row; i >= 0; i--) {
                        ScheduleNSO *item = [self.scheduleitems objectAtIndex:i];
                        if (item.hierarcyindex < hiaracyIndex) {
                            parentObject = item;
                            break;
                        } else if (item.hierarcyindex > hiaracyIndex) {
                            parentObject = nil;
                            break;
                        }
                    }
                    
                    bool midJourneyFromParent = false;
                    if (self.scheduleitems.count > activeCellIndexPath.row + 1) {
                        ScheduleNSO *followingitem = [self.scheduleitems objectAtIndex:(int)activeCellIndexPath.row + 1];
                        if (followingitem.hierarcyindex == currentHirarcyIndex) {
                            midJourneyFromParent = true;
                        }
                    }

                    if (parentObject!=nil && midJourneyFromParent) {
                        UIAlertAction* SetBackButton = [UIAlertAction
                                           actionWithTitle:@"Travel back"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               //Handle no, thanks button

                                               ScheduleNSO *item = [[ScheduleNSO alloc] init];
                                               item.compondkey = parentObject.compondkey;
                                               item.hierarcyindex = parentObject.hierarcyindex;
                                               item.dt = parentObject.dt;
                                               item.name = parentObject.name;
                                               item.type = @"middle";
                                               item.poi = parentObject.poi;
                                               item.sortorder = parentObject.sortorder;
                                               item.Coordinates = parentObject.Coordinates;
                                               item.categoryid = parentObject.poi.categoryid;
                                               [self.scheduleitems replaceObjectAtIndex:activeCellIndexPath.row withObject:item];
                                               
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   NSArray *indexPaths = self.TableViewScheduleItems.indexPathsForVisibleRows;
                                                   [self.TableViewScheduleItems reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                                                  self.LabelItemCounter.text = [NSString stringWithFormat:@"%lu Items",(unsigned long)self.scheduleitems.count];
                                               });
                                               
                                               
                                           }];
                        [alert addAction:SetBackButton];
                        PresentAlertController = true;
                    }
                }
                
               // NEW - only shown if there is a match between start and end dt's as well as on Actual and it is the 'end' node!
               if ([cell.schedule.type isEqualToString:@"end"] && cell.schedule.enddatesameasstart && self.ActivityState == [NSNumber numberWithLong:1]) {
                   
                   NSLog(@"we can offer the user to change the date and time here!");
                   
                   UIAlertAction* SetEndDateButton = [UIAlertAction
                                                   actionWithTitle:@"Manually set end date"
                                                   style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       //Handle no, thanks button
                                                       
                                                       NSLog(@"Set end date somehow");
                                                      
                                                       //Initialise date picker
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
                                                           [self.datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
                                                           [self.datePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
                                                           
                                                           [self.datePicker setMinimumDate:cell.schedule.activityitem.startdt];
                                                           [self.datePicker setDate:cell.schedule.dt];
                                                           /* locate the maximum end date this node can logically have */
                                                           if (cell.schedule.hierarcyindex>0) {
                                                               ScheduleNSO *parentObject = [[ScheduleNSO alloc] init];
                                                               
                                                               for (int i = (int)activeCellIndexPath.row; i >= 0; i--) {
                                                                   ScheduleNSO *item = [self.scheduleitems objectAtIndex:i];
                                                                   if (item.hierarcyindex < cell.schedule.hierarcyindex) {
                                                                       
                                                                       parentObject = item;
                                                                       
                                                                       for (int x = (int)activeCellIndexPath.row; x <= self.scheduleitems.count; x++) {
                                                                           ScheduleNSO *item = [self.scheduleitems objectAtIndex:x];
                                                                       
                                                                           if ([item.compondkey isEqualToString:parentObject.compondkey] && !item.enddatesameasstart) {
                                                                               
                                                                             [self.datePicker setMaximumDate:item.dt];
                                                                               break;
                                                                           }
                                                                       }
                                                                       break;
                                                                   }
                                                               }
                                                           }
                                                           
                                                          
                                                           
                                                           CGRect ViewRect = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
                                                           CGRect CancelButtonRect = CGRectMake(10.0, 50.0, 50.0, 50.0);
                                                           CGRect DurationLabelRect = CGRectMake(70.0, 50.0, self.view.bounds.size.width - 140, 13.0);
                                                           CGRect NameLabelRect = CGRectMake(70.0, 50.0, self.view.bounds.size.width - 140, 30.0);
                                                           CGRect AcceptButtonRect = CGRectMake(self.view.bounds.size.width - 60.0, 50.0, 50.0, 50.0);
                                                           CGRect StartDtLabelRect = CGRectMake(10.0, 135.0, self.view.bounds.size.width - 20, 40.0);
                                                           CGRect BadgeImageViewRect = CGRectMake((self.view.bounds.size.width / 2) - 50, 200.0, 100, 100);
                                                           CGRect TextFieldRect = CGRectMake(10.0, 325.0, self.view.bounds.size.width - 20, 40.0);
                                                       
                                                           UIImageView *BadgeImageView = [[UIImageView alloc] initWithFrame:BadgeImageViewRect];
                                                           
                                                           [BadgeImageView setImage:[self.ActivityImageDictionary objectForKey:cell.schedule.compondkey]];
                                                           
                                                           BadgeImageView.layer.cornerRadius = 50;
                                                           BadgeImageView.clipsToBounds = YES;
                                                           
                                                           UIButton *CancelButton = [[UIButton alloc] initWithFrame:CancelButtonRect];
                                                           
                                                           CancelButton.backgroundColor = [UIColor colorWithRed:100.0f/255.0f green:245.0f/255.0f blue:1.0f/255.0f alpha:1.0];
                                                           
                                                           [CancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                                                           
                                                           [CancelButton setImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
                                                           
                                                           
                                                           CancelButton.layer.cornerRadius = 25;
                                                           CancelButton.clipsToBounds = YES;
                                                           CancelButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
                                                           
                                                           UIButton *AcceptButton = [[UIButton alloc] initWithFrame:AcceptButtonRect];
                                                           AcceptButton.backgroundColor = [UIColor colorWithRed:100.0f/255.0f green:245.0f/255.0f blue:1.0f/255.0f alpha:1.0];
                                                           [AcceptButton setTitle:@"OK" forState:UIControlStateNormal];
                                                           [AcceptButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                                                           [AcceptButton addTarget:self action:@selector(acceptButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                                                           
                                                           AcceptButton.layer.cornerRadius = 25;
                                                           AcceptButton.clipsToBounds = YES;
                                                           
                                                           self.TextFieldDt = [[TextFieldDatePicker alloc] initWithFrame:TextFieldRect];
                                                        
                                                          
                                                           self.TextFieldDt.text = [NSString stringWithFormat:@"%@", [self FormatPrettyDates :cell.schedule.dt]];
                                                           
                                                           [[self.TextFieldDt layer] setBorderColor:[[UIColor colorWithRed:100.0f/255.0f green:245.0f/255.0f blue:1.0f/255.0f alpha:1.0] CGColor]];
                                                           [[self.TextFieldDt layer] setBorderWidth:2.3];
                                                           [[self.TextFieldDt layer] setCornerRadius:15];
                                                           [self.TextFieldDt setClipsToBounds: YES];
                                                           
                                                           self.TextFieldDt.inputView = self.datePicker;
                                                           [self.TextFieldDt setTextAlignment:NSTextAlignmentCenter];
                                                           [self.TextFieldDt setTextColor:[UIColor colorWithRed:100.0f/255.0f green:245.0f/255.0f blue:1.0f/255.0f alpha:1.0]];
                                                        
                                                           self.LabelDuration = [[UILabel alloc] initWithFrame:DurationLabelRect];
                                                           self.LabelDuration.text = @"No Duration";
                                                           [self.LabelDuration setFont:[UIFont systemFontOfSize:12.0]];
                                                           [self.LabelDuration setTextColor:[UIColor colorWithRed:100.0f/255.0f green:245.0f/255.0f blue:1.0f/255.0f alpha:1.0]];
                                                           [self.LabelDuration setTextAlignment:NSTextAlignmentCenter];
                                                           
                                                           /* Label Name - temporarily used to present the name  */
                                                           UILabel *LabelName = [[UILabel alloc] initWithFrame:NameLabelRect];
                                                           LabelName.text = cell.schedule.activityitem.name;
                                                           [LabelName setFont:[UIFont systemFontOfSize:16.0]];
                                                           [LabelName setTextColor:[UIColor colorWithRed:100.0f/255.0f green:245.0f/255.0f blue:1.0f/255.0f alpha:1.0]];
                                                           [LabelName setTextAlignment:NSTextAlignmentCenter];
                                                           
                                                           UILabel *StartDtLabel = [[UILabel alloc] initWithFrame:StartDtLabelRect];
                                                           
                                                           [StartDtLabel setTextColor:[UIColor colorWithRed:100.0f/255.0f green:245.0f/255.0f blue:1.0f/255.0f alpha:1.0]];
                                                           StartDtLabel.text = [NSString stringWithFormat:@"%@", [self FormatPrettyDates :cell.schedule.activityitem.startdt]];
                                                           [StartDtLabel setTextAlignment:NSTextAlignmentCenter];
                                                           
                                                           UIView* view = [[UIView alloc] initWithFrame:ViewRect];
                                                           view.backgroundColor = [UIColor colorWithRed:11.0f/255.0f green:110.0f/255.0f blue:79.0f/255.0f alpha:1.0];
                                                           
                                                           [view addSubview:self.TextFieldDt];
                                                           [view addSubview:BadgeImageView];
                                                               [view addSubview:StartDtLabel];
                                                           [view addSubview:CancelButton];
                                                           [view addSubview:AcceptButton];
                                                           [view addSubview:self.LabelDuration];
                                                           [view addSubview:LabelName];
                                                           
                                                           [self addDoneToolBarToDatePicker:self.TextFieldDt];
                                                           
                                                           [self.view addSubview:view];
                                                        });
                                                       
                                                   }];
                   [alert addAction:SetEndDateButton];
                   PresentAlertController = true;
               }
 
                //Add  buttons to alert controller
                if (PresentAlertController) {
                    
                    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    [alert addAction:cancelAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        }
    }
}

/*
 created date:      21/10/2018
 last modified:     21/10/2018
 remarks:
 */
- (void)onDatePickerValueChanged:(UIDatePicker *)datePicker
{
    
    self.TextFieldDt.text = [self FormatPrettyDates:datePicker.date];
    
    ScheduleNSO *item = [self.scheduleitems objectAtIndex:activeCellIndexPath.row];
    self.LabelDuration.text = [ToolBoxNSO PrettyDateDifference:item.activityitem.startdt :self.datePicker.date :@""];
    
}

/*
 created date:      21/10/2018
 last modified:     21/10/2018
 remarks:
 */
- (void)cancelButtonPressed:(UIButton *)sender {
    NSLog(@"Button cancelled Pressed!");
    [[self.view.subviews objectAtIndex:(self.view.subviews.count - 1)]removeFromSuperview];
}

/*
 created date:      21/10/2018
 last modified:     21/10/2018
 remarks:
 */
- (void)acceptButtonPressed:(UIButton *)sender {

    ScheduleNSO *item = [self.scheduleitems objectAtIndex:activeCellIndexPath.row];
    item.dt = self.datePicker.date;
    item.enddatesameasstart = false;
    NSLog(@"Button accept Pressed!");
    [[self.view.subviews objectAtIndex:(self.view.subviews.count - 1)]removeFromSuperview];

    [self RedrawHierarcy];
    
    NSArray *indexPaths = self.TableViewScheduleItems.indexPathsForVisibleRows;
    [self.TableViewScheduleItems reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    self.LabelItemCounter.text = [NSString stringWithFormat:@"%lu Items",(unsigned long)self.scheduleitems.count];
}




-(void)addDoneToolBarToDatePicker:(UITextField *)textField
{
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleDefault;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClickedDismissDatePicker)],
                         nil];
    [doneToolbar sizeToFit];
    textField.inputAccessoryView = doneToolbar;
}

-(void)doneButtonClickedDismissDatePicker
{
    [self.TextFieldDt resignFirstResponder];
}


@end
