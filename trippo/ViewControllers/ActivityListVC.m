//
//  ActivityListVC.m
//  travelmegetActivityImage
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ActivityListVC.h"
@import UserNotifications;

@interface ActivityListVC ()
@property RLMNotificationToken *notification;
@property NSIndexPath *LongGesturedPressedSelectedIndexPath;
@end

@implementation ActivityListVC
CGFloat ActivityListFooterFilterHeightConstant;
CGFloat NumberOfCellsInRow = 2.0f;
CGFloat Scale = 4.14f;

@synthesize delegate;

/*
 created date:      30/04/2018
 last modified:     24/02/2021
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    self.ActivityImageDictionary = [[NSMutableDictionary alloc] init];
    self.CollectionViewActivities.delegate = self;
    self.TableViewDiary.delegate = self;
    self.editmode = false;
    
    /* table header */
   // if (![ToolBoxNSO HasTopNotch]) {
   //     self.HeaderViewHeightConstraint.constant = 70.0f;
   // }
 
    // Do any additional setup after loading the view.
    if (self.Trip.itemgrouping==[NSNumber numberWithInt:1]) {
        self.SegmentState.selectedSegmentIndex = 1;
        self.LabelProject.text =  [NSString stringWithFormat:@"%@ - Activities in Last Trip", self.Trip.name];
    } else if (self.Trip.itemgrouping==[NSNumber numberWithInt:4]) {
        self.LabelProject.text =  [NSString stringWithFormat:@"Next Trip in %@", self.Trip.name];
    } else if (self.Trip.itemgrouping==[NSNumber numberWithInt:2]) {
        self.SegmentState.selectedSegmentIndex = 1;
        self.LabelProject.text =  [NSString stringWithFormat:@"Active Trip in %@", self.Trip.name];
    } else {
         self.LabelProject.text =  [NSString stringWithFormat:@"Activities for %@", self.Trip.name];
    }
    
   
   self.TypeItems = @[
                           @"Cat-Accomodation",
                           @"Cat-Airport",
                           @"Cat-Astronaut",
                           @"Cat-Bakery",
                           @"Cat-Beer",
                           @"Cat-Bike",
                           @"Cat-Bridge",
                           @"Cat-CarHire",
                           @"Cat-CarPark",
                           @"Cat-Casino",
                           @"Cat-Cave",
                           @"Cat-Church",
                           @"Cat-Cinema",
                           @"Cat-City",
                           @"Cat-CityPark",
                           @"Cat-Climbing",
                           @"Cat-Club",
                           @"Cat-Sea",
                           @"Cat-Concert",
                           @"Cat-FoodWine",
                           @"Cat-Football",
                           @"Cat-Forest",
                           @"Cat-Golf",
                           @"Cat-Historic",
                           @"Cat-House",
                           @"Cat-Lake",
                           @"Cat-Lighthouse",
                           @"Cat-Metropolis",
                           @"Cat-Misc",
                           @"Cat-Monument",
                           @"Cat-Museum",
                           @"Cat-NationalPark",
                           @"Cat-Nature",
                           @"Cat-Office",
                           @"Cat-PetrolStation",
                           @"Cat-Photography",
                           @"Cat-Restaurant",
                           @"Cat-River",
                           @"Cat-Rugby",
                           @"Cat-Safari",
                           @"Cat-Scenary",
                           @"Cat-School",
                           @"Cat-Ship",
                           @"Cat-Shopping",
                           @"Cat-Ski",
                           @"Cat-Sports",
                           @"Cat-Swimming",
                           @"Cat-Tennis",
                           @"Cat-Theatre",
                           @"Cat-ThemePark",
                           @"Cat-Tower",
                           @"Cat-Train",
                           @"Cat-Trek",
                           @"Cat-Venue",
                           @"Cat-Village",
                           @"Cat-Vineyard",
                           @"Cat-Windmill",
                           @"Cat-Zoo"
                           ];
    
    [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];
    [self LoadActivityImageData];
    
    __weak typeof(self) weakSelf = self;
    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf LoadActivityData :[NSNumber numberWithInteger:weakSelf.SegmentState.selectedSegmentIndex]];
        if (weakSelf.CollectionViewActivities.hidden) {
            [weakSelf.TableViewDiary reloadData];
        } else {
            [weakSelf.CollectionViewActivities reloadData];
        }
        
    }];

    ActivityListFooterFilterHeightConstant = self.FooterWithSegmentConstraint.constant;

    
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [self.CollectionViewActivities addGestureRecognizer:longPressRecognizer];
    
    
    UIPinchGestureRecognizer *pinch =[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinch:)];
    [self.CollectionViewActivities addGestureRecognizer:pinch];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    self.TableViewDiary.sectionFooterHeight = 50;
    
    self.tweetview = false;
    
    if (self.SegmentState.selectedSegmentIndex == 1) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightBold];

        self.ImageViewStateIndicator.image = [UIImage systemImageNamed:@"figure.walk" withConfiguration:config];
    } else {
        
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightBold];

        self.ImageViewStateIndicator.image = [UIImage systemImageNamed:@"lightbulb" withConfiguration:config];
    }
    
   
    
    self.SegmentState.selectedSegmentTintColor = [UIColor colorNamed:@"TrippoColor"];
    [self.SegmentState setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor systemBackgroundColor], NSFontAttributeName: [UIFont systemFontOfSize:13]} forState:UIControlStateSelected];
    
    RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
    NumberOfCellsInRow = [settings[0].ActivityCellColumns floatValue];
    
    /* handle different devices */
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat cellWidth = width / NumberOfCellsInRow;
    Scale = cellWidth / 50;
    
    self.ViewLoading.layer.cornerRadius=8.0f;
    self.ViewLoading.layer.masksToBounds=YES;
    self.ViewLoading.layer.borderWidth = 1.0f;
    self.ViewLoading.layer.borderColor=[[UIColor colorNamed:@"TrippoColor"]CGColor];
    
}

- (void)didDismissPresentingViewController {
}


- (void)keyboardWillShow:(NSNotification*)aNotification
{
    self.TableViewDiary.allowsSelection = NO;
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.TableViewDiary.allowsSelection = YES;
}

-(NSDate *)dateWithOutTime:(NSDate *)datDate
{
    if( datDate == nil ) {
        datDate = [NSDate date];
    }
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:self.Trip.defaulttimezonename];
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    currentCalendar.timeZone = tz;
    
    NSDateComponents* comps = [currentCalendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear  fromDate:datDate];
    return [currentCalendar dateFromComponents:comps];
}




/*
 created date:      20/06/2019
 last modified:     21/06/2019
 remarks:
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:
(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:
(NSIndexPath *)indexPath
{
    return CGSizeMake(50*Scale, 50*Scale);
}

/*
 created date:      20/06/2019
 last modified:     24/08/2019
 remarks:           Works on iPhone XR - will it work on an smaller iPhone 7?
 */
-(void)onPinch:(UIPinchGestureRecognizer*)gestureRecognizer
{
    static CGFloat scaleStart;
    
    CGFloat collectionWidth = self.CollectionViewActivities.frame.size.width;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        scaleStart = Scale;
        
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        Scale = scaleStart * gestureRecognizer.scale;
        
        if ( Scale*50 < collectionWidth / 6) {
            Scale = (collectionWidth / 6) / 50;
        }
        else
        {
            [self.CollectionViewActivities.collectionViewLayout invalidateLayout];
        }
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        // snap to pretty border distribution
        if ( Scale*50 < collectionWidth / 5) {
            Scale = (collectionWidth / 5) / 50;
            NumberOfCellsInRow = 5.0f;
        } else if (Scale*50 < collectionWidth / 4) {
            Scale = (collectionWidth / 4) / 50;
            NumberOfCellsInRow = 4.0f;
        } else if (Scale*50 < collectionWidth / 3) {
            Scale = (collectionWidth / 3) / 50;
            NumberOfCellsInRow = 3.0f;
        } else if (Scale*50 < collectionWidth / 2) {
            Scale = (collectionWidth / 2) / 50;
            NumberOfCellsInRow = 2.0f;
        } else {
            Scale = collectionWidth / 50;
            NumberOfCellsInRow = 1.0f;
        }
        
        RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
        SettingsRLM *settingitem = [settings firstObject];
        [self.realm transactionWithBlock:^{
            settingitem.ActivityCellColumns = [NSNumber numberWithFloat:NumberOfCellsInRow];
        }];
    
        
        if (self.FooterWithSegmentConstraint.constant == 0.0f){
                  NSLog(@"pinched without footer");
                  [UIView animateWithDuration:0.4f
                                        delay:0.0f
                                      options:UIViewAnimationOptionBeginFromCurrentState
                                   animations:^{
                                       
                                       self.FooterWithSegmentConstraint.constant = ActivityListFooterFilterHeightConstant;
                                       [self.view layoutIfNeeded];
                                       
                                   } completion:^(BOOL finished) {
                                       
                                   }];
              }
        
        [self.CollectionViewActivities.collectionViewLayout invalidateLayout];
        [self.CollectionViewActivities reloadData];
        
    }
    
}


/*
 created date:      27/09/2018
 last modified:     27/09/2018
 remarks:
 */
-(void)onLongPress:(UILongPressGestureRecognizer*)pGesture
{
    if (NumberOfCellsInRow<=3.0f) {
        
        NSInteger NumberOfItems = self.activitycollection.count + 1;

        if (pGesture.state == UIGestureRecognizerStateBegan)
        {
            CGPoint touchPoint = [pGesture locationInView:self.CollectionViewActivities];
            self.LongGesturedPressedSelectedIndexPath = [self.CollectionViewActivities indexPathForItemAtPoint:touchPoint];
            if (self.LongGesturedPressedSelectedIndexPath != nil) {
                if (self.LongGesturedPressedSelectedIndexPath.row == NumberOfItems -1) {
                    return;
                }
                //Handle the long press on row
                ActivityListCell *cell= (ActivityListCell*)[self.CollectionViewActivities cellForItemAtIndexPath:self.LongGesturedPressedSelectedIndexPath ];
                cell.ViewDateInfo.hidden = false;
            }
        }
        if (pGesture.state == UIGestureRecognizerStateEnded)
        {
            if (self.LongGesturedPressedSelectedIndexPath != nil) {
                //Handle the long press on row
                // NSLog(@"%ld row unpressed",(long)self.LongGesturedPressedSelectedIndexPath.row);
                ActivityListCell *cell= (ActivityListCell*)[self.CollectionViewActivities cellForItemAtIndexPath:self.LongGesturedPressedSelectedIndexPath ];
                cell.ViewDateInfo.hidden = true;
                
            }
        }
    }
}

/*
 created date:      30/04/2018
 last modified:     27/08/2019
 remarks:           Tweet option included in selection of cells.
 */
-(void) LoadActivityData:(NSNumber*) State {

    NSDateFormatter *DateIdentityFormatter = [[NSDateFormatter alloc] init];
    [DateIdentityFormatter setDateFormat:@"YYYY-MM-dd"];
    DateIdentityFormatter.timeZone = [NSTimeZone timeZoneWithName:self.Trip.defaulttimezonename];
    
    NSMutableDictionary *dataset = [[NSMutableDictionary alloc] init];
    
    /* obtain the planned activities, both planned and actual activities are interested in this */
    NSString *IdentityStartDate = [[NSString alloc] init];
    NSString *IdentityEndDate = [[NSString alloc] init];

    self.AllActivitiesInTrip = [ActivityRLM objectsWhere:@"tripkey = %@", self.Trip.key];

    NSString *whereClause = @"state==0";
    if (State==[NSNumber numberWithLong:0] || !self.tweetview) {
        
        if (self.tweetview) {
            whereClause = [NSString stringWithFormat:@"%@ and IncludeInTweet==1", whereClause];
        }
        
        RLMResults<ActivityRLM*> *plannedactivities = [self.AllActivitiesInTrip objectsWhere:whereClause];
 
        for (ActivityRLM* planned in plannedactivities) {
            
            RLMResults <PaymentRLM*> *payments = [PaymentRLM objectsWhere:@"activitykey=%@", planned.key];
            
            for (PaymentRLM* payment in payments) {
                if ([payment.amt_est intValue]>0) {
                    planned.hasestpayment = [NSNumber numberWithInt:1];
                } else {
                    planned.hasestpayment = [NSNumber numberWithInt:0];
                }
            }
            
            [dataset setObject:planned forKey:planned.key];
            
        }
        self.IdentityStartDt  = [plannedactivities minOfProperty:@"startdt"];
        self.IdentityEndDt = [plannedactivities maxOfProperty:@"enddt"];
    }
    
    /* next only for actual activities we search for those too and replace using dictionary any of them */
    if (State==[NSNumber numberWithLong:1]) {
        
        whereClause = @"state==1";
        if (self.tweetview) {
            whereClause = [NSString stringWithFormat:@"%@ and IncludeInTweet==1", whereClause];
            [dataset removeAllObjects];
        }

        RLMResults<ActivityRLM*> *actualactivities = [self.AllActivitiesInTrip objectsWhere:whereClause];

        bool found=false;
        for (ActivityRLM* actual in actualactivities) {
            RLMResults <PaymentRLM*> *payments = [PaymentRLM objectsWhere:@"activitykey=%@", actual.key];

            for (PaymentRLM* payment in payments) {
                if ([payment.amt_act intValue]>0) {
                    actual.hasactpayment = [NSNumber numberWithInt:1];
                } else {
                    actual.hasactpayment = [NSNumber numberWithInt:0];
                }
            }
            [dataset setObject:actual forKey:actual.key];
            found = true;
        }
        if (found) {
            self.IdentityStartDt  = [actualactivities minOfProperty:@"startdt"];
            self.IdentityEndDt = [actualactivities maxOfProperty:@"enddt"];
        }
    }
    
    NSArray *temp2 = [[NSArray alloc] initWithArray:[dataset allValues]];
    
    NSSortDescriptor *sortDescriptorState = [[NSSortDescriptor alloc] initWithKey:@"state" ascending:NO];
    NSSortDescriptor *sortDescriptorStartDt = [[NSSortDescriptor alloc] initWithKey:@"startdt"
                                                 ascending:YES];
    
    temp2 = [temp2 sortedArrayUsingDescriptors:@[sortDescriptorState,sortDescriptorStartDt]];
    self.activitycollection = [NSMutableArray arrayWithArray:temp2];

    //ActivityRLM  *Earliest = [[self.activitycollection sortedResultsUsingKeyPath:@"startdt" ascending:TRUE] firstObject];
    
    //ActivityRLM  *Latest = [[self.activitycollection sortedResultsUsingKeyPath:@"enddt" ascending:FALSE] firstObject];
    
    
    if (self.IdentityStartDt == nil ||  [self.IdentityStartDt compare:self.Trip.startdt] == NSOrderedDescending) {
        self.IdentityStartDt = self.Trip.startdt;
    }

    if (self.IdentityEndDt == nil ||  [self.IdentityEndDt compare:self.Trip.enddt] == NSOrderedAscending) {
        self.IdentityEndDt = self.Trip.enddt;
    }

    if (self.tweetview) {
        return;
    }
    /* diary collection - not including Tweet complexity */
    IdentityStartDate = [DateIdentityFormatter stringFromDate:self.IdentityStartDt];
    IdentityEndDate = [DateIdentityFormatter stringFromDate:self.IdentityEndDt];
        
    NSMutableArray *diaryactivties = [[NSMutableArray alloc] init];
    
    for (ActivityRLM *activity in self.activitycollection) {
        ActivityRLM *a = activity;
        a.identitystartdate = [DateIdentityFormatter stringFromDate:activity.startdt];
        a.identityenddate = [DateIdentityFormatter stringFromDate:activity.enddt];
        [diaryactivties addObject:a];
    }
    
    self.sectionheaderdaystitle = [[NSMutableArray alloc] init];
    self.diarycollection = [[NSMutableArray alloc] init];
    
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:self.Trip.defaulttimezonename];
    
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    currentCalendar.timeZone = tz;
    
    NSDateComponents *oneDay = [NSDateComponents new];
    oneDay.day = 1;

    NSDateFormatter *FullDateFormatter = [[NSDateFormatter alloc] init];
    [FullDateFormatter setDateFormat:@"EEEE, dd MMM, YYYY"];
    FullDateFormatter.timeZone = tz;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    dateFormatter.timeZone = tz;
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    timeFormatter.timeZone = tz;
    
    NSDate *StartDt = [dateFormatter dateFromString:IdentityStartDate];
    NSDate *EndDt = [dateFormatter dateFromString:IdentityEndDate];

    int DayIndex = 0;
    while ([StartDt compare:EndDt] == NSOrderedAscending || [StartDt compare:EndDt] == NSOrderedSame) {
        
        IdentityStartDate = [DateIdentityFormatter stringFromDate:StartDt];
        IdentityEndDate = [DateIdentityFormatter stringFromDate:EndDt];
        
        DayIndex ++;
        DiaryDatesNSO *dd = [[DiaryDatesNSO alloc] init];

        dd.daytitle = [NSString stringWithFormat:@"Day %d - %@", DayIndex, [FullDateFormatter stringFromDate:StartDt]];
        
        dd.startdt = [currentCalendar startOfDayForDate:StartDt];
        dd.extendedActivityDetail = [[NSMutableArray alloc] init];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identitystartdate = %@", IdentityStartDate];
        NSArray *itemsinday = [diaryactivties filteredArrayUsingPredicate:predicate];
        
        itemsinday = [itemsinday sortedArrayUsingDescriptors:@[sortDescriptorStartDt]];
        
        [self.diarycollection addObject:itemsinday];
        
        StartDt = [currentCalendar dateByAddingUnit:NSCalendarUnitDay
                                              value:+1
                                             toDate:StartDt
                                            options:0];
        
        StartDt = [currentCalendar startOfDayForDate:StartDt];

        /* subtract 1 minute off the time */
        dd.enddt = [StartDt dateByAddingTimeInterval:-60];
        
        [self.sectionheaderdaystitle addObject:dd];
    }
    
   /* important structure to add sub section on sectionheaderdaystitle collection */
   for (ActivityRLM *activity in diaryactivties) {
       
       if ((State==[NSNumber numberWithLong:1] && activity.state == [NSNumber numberWithInteger:1]) || (State==[NSNumber numberWithLong:0] && activity.state == [NSNumber numberWithInteger:0])) {
           
           NSDateComponents *componentsForBeginDate = [currentCalendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:activity.startdt];
           NSDateComponents *componentsForEndDate = [currentCalendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:activity.enddt];
           
           NSInteger beginday = [componentsForBeginDate day];
           NSInteger endday = [componentsForEndDate day];
           
           if (beginday != endday) {
               bool currentDateFound = false;
               for (DiaryDatesNSO  *dd in self.sectionheaderdaystitle) {
                   if ([currentCalendar isDate:dd.startdt inSameDayAsDate:activity.startdt]) {
                       currentDateFound = true;
                       continue;
                   }
                   if (currentDateFound) {
                       if ([currentCalendar isDate:dd.startdt inSameDayAsDate:activity.enddt]) {
                           [dd.extendedActivityDetail addObject:[NSString stringWithFormat:@"%@ ends at %@",activity.name, [timeFormatter stringFromDate:activity.enddt]]];
                           break;
                       } else {
                           [dd.extendedActivityDetail addObject:[NSString stringWithFormat:@"%@ continues",activity.name]];
                       }
                   }
               }
           }
       }
   }
}

/*
 created date:      10/03/2021
 last modified:     10/03/2021
 remarks:
 */
-(NSDate *)getMinDate {
    ActivityRLM *Earliest = [[[ActivityRLM objectsWhere:@"tripkey = %@",self.Trip.key] sortedResultsUsingKeyPath:@"startdt" ascending:TRUE] firstObject];
    NSLog(@"EARLIEST - %@",Earliest.startdt);
    return Earliest.startdt;
}

/*
 created date:      10/03/2021
 last modified:     10/03/2021
 remarks:
 */
-(NSDate *)getMaxDate {
    ActivityRLM *Latest = [[[ActivityRLM objectsWhere:@"tripkey = %@",self.Trip.key] sortedResultsUsingKeyPath:@"enddt" ascending:FALSE] firstObject];
    NSLog(@"LATEST - %@",Latest.enddt);
    return Latest.enddt;
}



/*
 created date:      01/09/2018
 last modified:     21/03/2019
 remarks:  Load all Activity images for Trip
 */
-(void)LoadActivityImageData {
    /* for each activity we need to show the image of the poi attached to it */
    /* load images from file - TODO make sure we locate them all */
    
    RLMResults<ActivityRLM*> *activities = [ActivityRLM objectsWhere:@"tripkey==%@",self.Trip.key];
    for (ActivityRLM *activityobj in activities) {
        [self getActivityImage :activityobj];
    }
}

/*
 created date:      21/03/2019
 last modified:     25/06/2019
 remarks:           Load single Activity image for Trip - TODO optimize this.
                    use thumbnail image if it exists, else - create it (the activity data entry point will
                    also need to do some management - when it deletes an activity or a key image delete its thumbnail
 */
-(void)getActivityImage :(ActivityRLM*) activity {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
    RLMResults *filteredResults;
    ImageCollectionRLM *imgobject = [[ImageCollectionRLM alloc] init];

    CGSize CellSize = CGSizeMake(self.CollectionViewActivities.collectionViewLayout.collectionViewContentSize.width * 2, self.CollectionViewActivities.collectionViewLayout.collectionViewContentSize.width * 2);
    
    filteredResults = [activity.images objectsWithPredicate:predicate];
    if (filteredResults.count>0) {
        imgobject = [filteredResults firstObject];
    } else {
        PoiRLM *poiobject = [PoiRLM objectForPrimaryKey:activity.poikey];
        filteredResults = [poiobject.images objectsWithPredicate:predicate];
        if (filteredResults.count==0) {
            imgobject = [poiobject.images firstObject];
        } else {
            imgobject = [filteredResults firstObject];
        }
    }
    
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightThin];

    NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imgobject.ImageFileReference]];
    NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
    if (pngData==nil) {
        if (activity.state == [NSNumber numberWithInteger:0]) {
            @autoreleasepool {
                //UIImage *image = [ToolBoxNSO resizeImage:[UIImage imageNamed:@"Planning"] toFitInSize:CellSize];
                
                [self.ActivityImageDictionary setObject:[UIImage systemImageNamed:@"lightbulb" withConfiguration:config] forKey:activity.compondkey];
                //image = nil;
            }
        } else {
            @autoreleasepool {
                //UIImage *image = [ToolBoxNSO resizeImage:[UIImage imageNamed:@"Activity"] toFitInSize:CellSize];
                [self.ActivityImageDictionary setObject:[UIImage systemImageNamed:@"figure.walk" withConfiguration:config]  forKey:activity.compondkey];
                //image = nil;
            }
        }
    } else {
        @autoreleasepool {
            UIImage *image = [ToolBoxNSO resizeImage:[UIImage imageWithData:pngData]  toFitInSize:CellSize];
            [self.ActivityImageDictionary setObject:image forKey:activity.compondkey];
            image = nil;
        }
        
    }
}
/*
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if ([ToolBoxNSO HasTopNotch]) {
        return CGSizeMake(0, 50);
    }
    else{
        return CGSizeMake(0, 50);
    }
}
*/

- (bool)checkInternet
{
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        return false;
    }
    else
    {
        //connection available
        return true;
    }
    
}

/*
 created date:      30/04/2018
 last modified:     10/08/2021
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (self.checkInternet) {
        return self.activitycollection.count + 1;
    } else {
        return self.activitycollection.count;
    }
}

/*
 created date:      30/04/2018
 last modified:     28/02/2021
 remarks:  [NSTimeZone timeZoneWithName:self.StartDtTimeZoneNameTextField.text]   df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:TimeZone.secondsFromGMT];
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    
    ActivityListCell *cell= [collectionView dequeueReusableCellWithReuseIdentifier:@"ActivityCellId" forIndexPath:indexPath];
    
    cell.contentView.hidden = false;
    
    NSDateFormatter *TimePlusDayOfWeekFormatter = [[NSDateFormatter alloc] init];
    [TimePlusDayOfWeekFormatter setDateFormat:@"HH:mm, EEEE"];
    
    NSDateFormatter *DateFormatter = [[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"dd MMM YYYY"];

    NSInteger NumberOfItems = self.activitycollection.count + 1;
    if (indexPath.row == NumberOfItems -1) {
        if (self.tweetview) {
            cell.contentView.hidden = true;
        }
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightThin];

        cell.ImageViewActivity.image = [UIImage systemImageNamed:@"plus" withConfiguration:config];
        [cell.ImageViewActivity setTintColor: [UIColor colorNamed:@"TrippoColor"]];
        [cell.ImageViewActivity setBackgroundColor: [UIColor clearColor]];
        cell.VisualViewBlur.hidden = true;
        cell.ViewOverlay.hidden = true;
        cell.ImageBlurBackground.hidden = true;
        cell.ImageBlurBackgroundBottomHalf.hidden = true;
        cell.ViewActiveBadge.hidden = true;
        cell.ViewActiveItem.backgroundColor = [UIColor clearColor];
    } else {
        //[cell.ImageViewActivity setBackgroundColor: [UIColor colorNamed:@"ActivityBGColor"]];
        [cell.ImageViewActivity setTintColor: [UIColor colorNamed:@"TrippoColor"]];
        if (!self.editmode) {
            cell.ViewOverlay.hidden = false;
        } else {
            cell.ViewOverlay.hidden = true;
        }
        cell.activity = [self.activitycollection objectAtIndex:indexPath.row];
        
        NSTimeZone *tz = [NSTimeZone timeZoneWithName:self.Trip.defaulttimezonename];
        TimePlusDayOfWeekFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:tz.secondsFromGMT];
        DateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:tz.secondsFromGMT];
        
        /* setup startdt popup that shows on longpress */
        if (cell.activity.startdt!=nil) {
            cell.LabelStartTimePlusWeekDay.text = [NSString stringWithFormat:@"%@",[TimePlusDayOfWeekFormatter stringFromDate:cell.activity.startdt]];
            cell.LabelStartDate.text = [NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:cell.activity.startdt]];
        } else {
            cell.LabelStartTimePlusWeekDay.text = @"";
            cell.LabelStartDate.text = @"";
        }

         /* setup enddt & approx duration popup that shows on longpress */
        NSComparisonResult resultSameStartEndDt = [cell.activity.startdt compare:cell.activity.enddt];
        
        tz = [NSTimeZone timeZoneWithName:cell.activity.enddttimezonename];
        TimePlusDayOfWeekFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:tz.secondsFromGMT];
        DateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:tz.secondsFromGMT];
        
        if (cell.activity.enddt!=nil && resultSameStartEndDt != NSOrderedSame ) {
            cell.LabelEndTimePlusWeekDay.text = [NSString stringWithFormat:@"%@",[TimePlusDayOfWeekFormatter stringFromDate:cell.activity.enddt]];
            cell.LabelEndDate.text = [NSString stringWithFormat:@"%@",[DateFormatter stringFromDate:cell.activity.enddt]];
            cell.LabelDuration.text = [ToolBoxNSO PrettyDateDifference :cell.activity.startdt :cell.activity.enddt :@""];
        } else {
            cell.LabelEndTimePlusWeekDay.text = @"";
            cell.LabelEndDate.text = @"";
            cell.LabelDuration.text = @"";
        }

        RLMResults <ActivityRLM*> *activitySet = [self.AllActivitiesInTrip objectsWhere:[NSString stringWithFormat:@"key = '%@'",cell.activity.key]];
        NSNumber *CountOfActivitiesInSet = [NSNumber numberWithLong:activitySet.count];
        
        if (self.SegmentState.selectedSegmentIndex == 1) {
            
            if (CountOfActivitiesInSet == [NSNumber numberWithLong:2] || self.tweetview) {
                cell.ImageViewBookmark.image = nil;
            } else {
                ActivityRLM *single = [activitySet firstObject];
                [cell.ImageViewBookmark setTintColor:[UIColor colorNamed:@"DiaryHeaderBGColor"]];
                if (single.state == [NSNumber numberWithInteger:1]) {
                    
                    //[cell.ImageViewBookmark setImage:[UIImage systemImageNamed:@"bookmark.fill"]];
                    
                    
                    //[cell.ImageViewBookmark setImage:[UIImage imageNamed:@"Bookmark-Yellow"]];
                } else {
                    /* Activity not set as active */
                    //[cell.ImageViewBookmark setImage:[UIImage imageNamed:@"Bookmark-Blue"]];
                    [cell.ImageViewBookmark setTintColor:[UIColor blueColor]];
                }
            }

            if (cell.activity.state == [NSNumber numberWithInteger:0]) {
                if (self.tweetview) {
                    cell.contentView.hidden = true;
                    
                } else {
                    cell.ButtonDelete.hidden = true;
                    cell.VisualViewBlur.hidden = false;
                }
            } else {
                if (self.tweetview) {
                    cell.ButtonDelete.hidden = true;
                } else {
                    cell.ButtonDelete.hidden = false;
                }
                cell.VisualViewBlur.hidden = true;
            }
           
            if ([cell.activity.startdt compare: cell.activity.enddt] == NSOrderedSame && cell.activity.startdt!=nil) {
                // only show badge when activity is Actual.
                if (cell.activity.state == [NSNumber numberWithInteger:1]) {
                    cell.BadgeHeightConstraint.constant = (25*Scale)/2;
                    cell.ViewActiveBadge.layer.cornerRadius = cell.BadgeHeightConstraint.constant/2;
                    cell.ViewActiveBadge.layer.masksToBounds = YES;
                    cell.ViewActiveBadge.transform = CGAffineTransformMakeRotation(.34906585);
                    cell.BadgeLabelHeightConstraint.constant = (cell.BadgeHeightConstraint.constant/2);
                    //cell.LabelActive.bounds.size.height = cell.ViewActiveBadge.layer.cornerRadius;
                    [cell.LabelActive setNeedsDisplay];
                    cell.ViewActiveBadge.hidden = false;
                   // cell.ViewWeather.hidden = true;
                } else  {
                    cell.ViewActiveBadge.hidden = true;
                }
            } else {
                cell.ViewActiveBadge.hidden = true;
            }

 
        } else {

            if (CountOfActivitiesInSet == [NSNumber numberWithLong:2]) {
                cell.ImageViewBookmark.image = nil;
            } else {
                if (self.tweetview) {
                    cell.ImageViewBookmark.image = nil;
                } else {
                    
                    [cell.ImageViewBookmark setImage:[UIImage systemImageNamed:@"bookmark.fill"]];
                    [cell.ImageViewBookmark setTintColor:[UIColor blueColor]];
                }
            }
            
            cell.VisualViewBlur.hidden = true;
            if (self.tweetview) {
                cell.ButtonDelete.hidden = true;
            } else {
                cell.ButtonDelete.hidden = false;
            }
            cell.ViewActiveItem.backgroundColor = [UIColor clearColor];
            cell.ViewActiveBadge.hidden = true;
        }

        //PoiRLM *poiobject = [PoiRLM objectForPrimaryKey:cell.activity.poikey];
        
        //cell.ImageViewTypeOfPoi.image = [UIImage imageNamed:[self.TypeItems objectAtIndex:[poiobject.categoryid integerValue]]];
        // 2019-09-15
        //[cell.ImageViewTypeOfPoi setTintColor:[UIColor colorNamed:@"TrippoColor"]];

        if (!self.editmode || indexPath.row == NumberOfItems -1) {
             cell.ViewOverlay.hidden = false;
        } else {
            cell.ViewOverlay.hidden = true;
        }
       
        
        cell.ImageBlurBackground.hidden = false;
        
        if ([self.ActivityImageDictionary objectForKey:cell.activity.compondkey] == nil) {
            [self getActivityImage :cell.activity];
        }
        
        cell.ImageViewActivity.image = [self.ActivityImageDictionary objectForKey:cell.activity.compondkey];
        
        if (self.tweetview) {
            //cell.ViewPoiType.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0];
        } else {
            cell.ImageBlurBackground.image = [self.ActivityImageDictionary objectForKey:cell.activity.compondkey];
            cell.ImageBlurBackgroundBottomHalf.image = [self.ActivityImageDictionary objectForKey:cell.activity.compondkey];
        }
        
        UIFont *font = [UIFont fontWithName:@"AmericanTypewriter" size:20.0f];

        if (NumberOfCellsInRow >= 3.0f) {
            if (NumberOfCellsInRow > 4.0f) {
                font = [UIFont fontWithName:@"AmericanTypewriter" size:8.0f];
            } else {
                font = [UIFont fontWithName:@"AmericanTypewriter" size:14.0];
            }
            cell.ViewWeather.hidden = true;
            
            if (NumberOfCellsInRow > 3.0f) {
                if (self.editmode == 0) {
                    cell.ButtonDelete.hidden = true;
                    if (NumberOfCellsInRow == 5.0f) {
                        cell.ViewPoiType.hidden = true;
                        
                    } else {
                        cell.ViewPoiType.hidden = false;
                    }
                } else {
                    if (cell.activity.state == [NSNumber numberWithInt:0]) {
                        cell.ButtonDelete.hidden = false;
                    }
                    cell.ViewPoiType.hidden = false;
                }
            } else {
                if (cell.activity.state == [NSNumber numberWithInt:0]) {
                    cell.ButtonDelete.hidden = false;
                }
                cell.ViewPoiType.hidden = false;
            }
        } else {
            if (self.editmode == 0) {
                if (cell.activity.state == [NSNumber numberWithInt:0]) {
                    cell.ButtonDelete.hidden = false;
                }
                cell.ViewPoiType.hidden = false;
            }
        }

        
        if ([cell.activity.startdt compare: cell.activity.enddt] == NSOrderedSame && cell.activity.startdt!=nil) {
           // only show badge when activity is Actual.
           if (cell.activity.state == [NSNumber numberWithInteger:1]) {
               cell.ViewWeather.hidden = true;
           }
        }
        
        
        
        NSDictionary *attributes = @{NSBackgroundColorAttributeName:[UIColor secondarySystemBackgroundColor], NSForegroundColorAttributeName:[UIColor labelColor], NSFontAttributeName:font};
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:cell.activity.name attributes:attributes];
        cell.LabelName.attributedText = string;
        cell.LabelName.transform = CGAffineTransformMakeRotation(.05);
        
        
    }
    return cell;
}



/*
 created date:      30/04/2018
 last modified:     21/02/2019
 remarks:  ImG todo
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger NumberOfItems = self.activitycollection.count + 1;
    
    if (indexPath.row == NumberOfItems -1) {
        [self performSegueWithIdentifier:@"ShowNewActivity" sender:nil];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ActivityDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityDataEntryViewController"];
        controller.delegate = self;
        controller.realm = self.realm;
        
        ActivityRLM *activity = [self.activitycollection objectAtIndex:indexPath.row];
        
        controller.Poi = [PoiRLM objectForPrimaryKey:activity.poikey];
        controller.PoiImage = [self RetrievePoiImageItem :controller.Poi];
        
        controller.Trip = self.Trip;
        long selectedSegmentState = self.SegmentState.selectedSegmentIndex;
        controller.newitem = false;
        if (selectedSegmentState == 1 && activity.state == [NSNumber numberWithInteger:0]) {
            // this is an activity item selected from the actual selection that is in fact an idea item.
            ActivityRLM *new = [[ActivityRLM alloc] init];
            new.key = activity.key;
            new.state = [NSNumber numberWithInt:1];
            new.compondkey = [NSString stringWithFormat:@"%@~1",activity.key];
            new.name = activity.name;
            new.tripkey = activity.tripkey;
            new.poikey = activity.poikey;
            new.createddt = [NSDate date];
            new.modifieddt = [NSDate date];
            new.geonotification = activity.geonotification;
            new.geonotifycheckout = activity.geonotifycheckout;
            new.geonotifycheckindt = activity.geonotifycheckindt;
            new.geonotifycheckoutdt = activity.geonotifycheckoutdt;
            controller.Activity = new;
            controller.transformed = true;
            // how can we determine on destination controller what is a brand new item and a transformed item?  Do we need to?
        } else {
            controller.Activity = [self.activitycollection objectAtIndex:indexPath.row];
            controller.transformed = false;
        }
        controller.deleteitem = false;
        [controller setModalPresentationStyle:UIModalPresentationPageSheet];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

/*
 created date:      20/02/2019
 last modified:     23/02/2019
 remarks:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionheaderdaystitle.count;
}

/*
 created date:      20/02/2019
 last modified:     23/02/2019
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *temp = self.diarycollection[section];
    return temp.count;
}

/*
created date:      17/03/2019
last modified:     02/09/2019
remarks:
*/
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section  {
    
    DiaryDatesNSO *dd = self.sectionheaderdaystitle[section];
    int extendedDetailCount = (int)dd.extendedActivityDetail.count;
    
    if (extendedDetailCount > 10) {
        extendedDetailCount = 10;
    }
    
    return 50 + (25 * extendedDetailCount);
}

/*
 created date:      17/03/2019
 last modified:     27/02/2021
 remarks:
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DiaryDatesNSO *dd = self.sectionheaderdaystitle[section];
    int beginIndex = 0;
    int extendedDetailCount = (int)dd.extendedActivityDetail.count;
    bool isMore = false;
    
    if (extendedDetailCount > 10) {
        extendedDetailCount = 10;
        beginIndex = (int)dd.extendedActivityDetail.count - 9;
        isMore = true;
    }

    float headerHeight = 50 + (25 * extendedDetailCount);
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, headerHeight)];

    UILabel* title = [[UILabel alloc] init];
    title.frame = CGRectMake(10, 10, tableView.frame.size.width - 50, 24);

    headerView.backgroundColor = [UIColor colorNamed:@"TrippoColor"];
    //headerView.backgroundColor = [UIColor tertiarySystemBackgroundColor];
    title.textColor =  [UIColor labelColor];
    
    
    title.font = [UIFont systemFontOfSize:20 weight:UIFontWeightRegular];
    title.text = dd.daytitle;
    title.textAlignment = NSTextAlignmentLeft;

    [headerView addSubview:title];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(tableView.frame.size.width - 40.0, 3.5, 35.0, 35.0); // x,y,width,height
    button.tag = section;
    
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightThin];
    [button setImage:[UIImage systemImageNamed:@"plus" withConfiguration:config] forState:UIControlStateNormal];

    [button setTintColor: [UIColor labelColor]];
    
    [button addTarget:self action:@selector(sectionHeaderButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    float xPos = 40.0f;
    float height = 20.0f;
    float yPos = 45.0f;

    int counterIndex = 0;
    for (NSString *detail in dd.extendedActivityDetail) {
        if (counterIndex >= beginIndex) {
            UILabel* detailLabel = [[UILabel alloc] init];
               detailLabel.frame = CGRectMake(xPos, yPos, tableView.frame.size.width - 60, height);
            detailLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
            [detailLabel setTextColor:[UIColor secondaryLabelColor]];
            detailLabel.text = detail;
            detailLabel.textAlignment = NSTextAlignmentLeft;
            [headerView addSubview:detailLabel];
            yPos += height + 5;
        }
        counterIndex ++;
    }
    if (isMore) {
        UILabel* detailLabel = [[UILabel alloc] init];
           detailLabel.frame = CGRectMake(xPos, yPos, tableView.frame.size.width - 60, height);
        detailLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        [detailLabel setTextColor:[UIColor secondarySystemBackgroundColor]];
        detailLabel.text = [NSString stringWithFormat:@"and %d more", (int)dd.extendedActivityDetail.count - 9];
        detailLabel.textAlignment = NSTextAlignmentLeft;
        [headerView addSubview:detailLabel];
    }
    
    [headerView addSubview:button];
    return headerView;
}

/*
 created date:      23/02/2019
 last modified:     23/02/2019
 remarks:
 */
-(void)sectionHeaderButtonPressed :(id)sender {
    [self performSegueWithIdentifier:@"ShowNewActivityFromDiary" sender:sender];
}





/*
 created date:      20/02/2019
 last modified:     17/08/2019
 remarks:           table view with sections.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ActivityDiaryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityDiaryCellId"];
    
    cell.activity = [[self.diarycollection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
   
    
    if (self.SegmentState.selectedSegmentIndex==1 && cell.activity.state==[NSNumber numberWithInteger:0]) {
        //cell.TextFieldStartDt.enabled = false;
        //cell.TextFieldEndDt.enabled = false;
        
        cell.DatePickerStart.enabled = false;
        cell.DatePickerEnd.enabled = false;
        
       
        [cell.LabelName setTextColor:[UIColor secondaryLabelColor]];
        [cell.LabelDuration setTextColor:[UIColor tertiaryLabelColor]];
        
        cell.ButtonDelete.hidden = true;
    } else if (self.SegmentState.selectedSegmentIndex==1)  {
        //cell.TextFieldStartDt.enabled = true;
        //cell.TextFieldEndDt.enabled = true;
        
        cell.DatePickerStart.enabled = true;
        cell.DatePickerEnd.enabled = true;
        
        [cell.LabelName setTextColor:[UIColor labelColor]];
        if ( [cell.activity.startdt compare:cell.activity.enddt] == NSOrderedSame) {
            cell.LabelDuration.text = @"active!";
        } else {
            cell.LabelDuration.text = [ToolBoxNSO PrettyDateDifference: cell.activity.startdt :cell.activity.enddt :@""];
            [cell.LabelDuration setTextColor:[UIColor secondaryLabelColor]];
        }
        cell.ButtonDelete.hidden = false;
    } else {
        cell.DatePickerStart.enabled = true;
        cell.DatePickerEnd.enabled = true;
        //cell.TextFieldStartDt.enabled = true;
        //cell.TextFieldEndDt.enabled = true;
        [cell.LabelName setTextColor:[UIColor labelColor]];
        cell.ButtonDelete.hidden = false;
        cell.LabelDuration.text = [ToolBoxNSO PrettyDateDifference: cell.activity.startdt :cell.activity.enddt :@""];
        [cell.LabelDuration setTextColor:[UIColor secondaryLabelColor]];
    }

    cell.LabelName.text = cell.activity.name;
    cell.startDt = cell.activity.startdt;
    cell.endDt = cell.activity.enddt;
    cell.defaultTimeZone = self.Trip.defaulttimezonename;
    
    NSTimeZone *tz = [NSTimeZone timeZoneWithName:cell.activity.enddttimezonename];
    cell.DatePickerEnd.timeZone = tz;
    cell.DatePickerEnd.date = cell.activity.enddt;

    tz = [NSTimeZone timeZoneWithName:cell.activity.enddttimezonename];
    cell.DatePickerStart.timeZone = tz;
    cell.DatePickerStart.date = cell.activity.startdt;

    cell.DatePickerStart.maximumDate = cell.DatePickerEnd.date;
    cell.DatePickerEnd.minimumDate = cell.DatePickerStart.date;
    
    PoiRLM *poiobject = [PoiRLM objectForPrimaryKey:cell.activity.poikey];
    
    cell.ImageViewTypeOfPoi.image = [UIImage imageNamed:[self.TypeItems objectAtIndex:[poiobject.categoryid integerValue]]];
    
    if (([cell.activity.hasestpayment intValue] == 1 && self.SegmentState.selectedSegmentIndex == 0) || ([cell.activity.hasactpayment intValue] == 1 && self.SegmentState.selectedSegmentIndex == 1)) {
        cell.ViewExpenseFlag.hidden=false;
    } else {
        cell.ViewExpenseFlag.hidden=true;
    }
    
    cell.indexPathForCell = indexPath;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


/*
 created date:      22/10/2018
 last modified:     17/08/2019
 remarks:           Time formatter - TODO needs to pop back into toolbox
 */
- (NSString*)FormatPrettyTime :(NSDate*)Dt :(NSTimeZone*)tz {
    
    NSDateFormatter *timeformatter = [[NSDateFormatter alloc] init];
    [timeformatter setDateFormat:@"HH:mm"];
    timeformatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:tz.secondsFromGMT];
    return [NSString stringWithFormat:@"%@", [timeformatter stringFromDate:Dt]];
}



/*
 created date:      25/02/2019
 last modified:     25/02/2019
 remarks:
 */
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGPoint buttonPosition = [textField convertPoint:CGPointZero toView:self.TableViewDiary];
    NSIndexPath *indexPath = [self.TableViewDiary indexPathForRowAtPoint:buttonPosition];
    ActivityDiaryCell *cell = [self.TableViewDiary cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
}

/*
created date:      22/02/2019
last modified:     24/02/2019
remarks:           table view with sections.
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ActivityDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityDataEntryViewController"];
    controller.delegate = self;
    controller.realm = self.realm;

    ActivityRLM *activity = [[self.diarycollection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    controller.Poi = [PoiRLM objectForPrimaryKey:activity.poikey];
    controller.PoiImage = [self RetrievePoiImageItem :controller.Poi];
    
    controller.Trip = self.Trip;
    long selectedSegmentState = self.SegmentState.selectedSegmentIndex;
    controller.newitem = false;
    if (selectedSegmentState == 1 && activity.state == [NSNumber numberWithInteger:0]) {
        // this is an activity item selected from the actual selection that is in fact an idea item.
        ActivityRLM *new = [[ActivityRLM alloc] init];
        new.key = activity.key;
        new.state = [NSNumber numberWithInt:1];
        new.compondkey = [NSString stringWithFormat:@"%@~1",activity.key];
        new.name = activity.name;
        new.tripkey = activity.tripkey;
        new.poikey = activity.poikey;
        new.createddt = [NSDate date];
        new.modifieddt = [NSDate date];
        new.startdt = activity.startdt;
        new.enddt = activity.enddt;
        new.geonotification = activity.geonotification;
        new.geonotifycheckout = activity.geonotifycheckout;
        new.geonotifycheckindt = activity.geonotifycheckindt;
        new.geonotifycheckoutdt = activity.geonotifycheckoutdt;
        controller.Activity = new;
        controller.transformed = true;
    } else {
        controller.Activity =  activity;
        controller.transformed = false;
    }
    controller.deleteitem = false;
    [controller setModalPresentationStyle:UIModalPresentationPageSheet];
    [self presentViewController:controller animated:YES completion:nil];
}

/*
 created date:      05/09/2018
 last modified:     29/09/2018
 remarks:  ImG
 */
-(UIImage*) RetrievePoiImageItem :(PoiRLM*) poi {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    UIImage *image = [[UIImage alloc] init];
    if (poi.images.count>0) {
        ImageCollectionRLM *imgobject = [[poi.images objectsWhere:@"KeyImage==1"] firstObject];
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imgobject.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        if (pngData==nil) {
            image = [UIImage systemImageNamed:@"command"];
        } else {
            image = [UIImage imageWithData:pngData];
        }
    } else {
        image = [UIImage systemImageNamed:@"command"];
    }
    return image;
}



/*
 created date:      05/02/2019
 last modified:     05/02/2019
 remarks:
 */
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if (velocity.y > 0 && self.FooterWithSegmentConstraint.constant == ActivityListFooterFilterHeightConstant){
        // NSLog(@"scrolling down");
        
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
        // NSLog(@"scrolling up");
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             self.FooterWithSegmentConstraint.constant = ActivityListFooterFilterHeightConstant;
                             [self.view layoutIfNeeded];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}

/*
 created date:      30/04/2018
 last modified:     24/03/2019
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if([segue.identifier isEqualToString:@"ShowNewActivity"]){
        PoiSearchVC *controller = (PoiSearchVC *)segue.destinationViewController;
        controller.frommenu = false;
        controller.delegate = self;
        controller.Activity = [[ActivityRLM alloc] init];
        controller.newitem = true;
        controller.transformed = false;
        controller.Activity.state = [NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex];
        controller.TripItem = self.Trip;
        controller.realm = self.realm;
     
    } else if([segue.identifier isEqualToString:@"ShowNewActivityFromDiary"]){
        UIButton * button=(UIButton*)sender;
        DiaryDatesNSO *dd = self.sectionheaderdaystitle[button.tag];
        PoiSearchVC *controller = (PoiSearchVC *)segue.destinationViewController;
        controller.frommenu = false;
        controller.delegate = self;
        controller.Activity = [[ActivityRLM alloc] init];
        controller.newitem = true;
        controller.transformed = false;
        controller.Activity.state = [NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex];
        controller.Activity.startdt = dd.startdt;
        controller.Activity.enddt = dd.enddt;
        controller.TripItem = self.Trip;
        controller.realm = self.realm;
        
    } else if([segue.identifier isEqualToString:@"ShowTravelPlan"]) {
        TravelPlanVC *controller = (TravelPlanVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.activitycollection = self.activitycollection;
        controller.ActivityImageDictionary = self.ActivityImageDictionary;
        controller.Trip = self.Trip;
        controller.TripImage = self.TripImage;
        controller.ActivityState = [NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex];
        controller.realm = self.realm;
        
    } else if([segue.identifier isEqualToString:@"ShowDeleteActivity"]) {
        [self DeleteActivity :sender];
        
    } else if ([segue.identifier isEqualToString:@"ShowDeleteActivityFromDiaryView"]) {
        [self DeleteActivity :sender];
    
    } else if([segue.identifier isEqualToString:@"ShowProjectPaymentList"]) {
        PaymentListingVC *controller = (PaymentListingVC *)segue.destinationViewController;
        controller.delegate = self;
        /* here we add something new */
        controller.realm = self.realm;
        controller.TripItem = self.Trip;
        // we need the trip image..
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *imagesDirectory = [paths objectAtIndex:0];
        ImageCollectionRLM *image = [self.Trip.images firstObject];
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",image.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        if (pngData!=nil) {
            controller.headerImage = [UIImage imageWithData:pngData];
        } else {
            controller.headerImage = [UIImage systemImageNamed:@"latch.2.case"];
        }
        controller.ActivityItem = nil;
        controller.activitystate = [NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex];
    } 
}


/*
 created date:      24/03/2019
 last modified:     07/04/2019
 remarks:           segue controls .
 */
-(void)DeleteActivity: (id)sender {
    
    ActivityRLM *ActivityToDelete = [[ActivityRLM alloc] init];
    if ([sender isKindOfClass: [UIButton class]]) {
        UIView * cellView=(UIView*)sender;
        while ((cellView= [cellView superview])) {
            if([cellView isKindOfClass:[ActivityListCell class]]  || [cellView isKindOfClass:[ActivityDiaryCell class]]) {
                ActivityListCell *cell = (ActivityListCell*)cellView;
                ActivityToDelete = cell.activity;
            }
        }
    }
    
    if (ActivityToDelete!=nil) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Delete Activity\n%@", ActivityToDelete.name] message:@"Are you sure you want to remove this activity from current trip?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
       
        [alert.view setTintColor:[UIColor labelColor]];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      
                                                                      [self RemoveGeoNotification :true :ActivityToDelete];
                                                                      [self RemoveGeoNotification :false :ActivityToDelete];
                                                                      
                                                                      
                                                                      [self.realm beginWriteTransaction];
                                                                      [self.realm deleteObject:ActivityToDelete];
                                                                      [self.realm commitWriteTransaction];
                                                                      
                                                                      
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
 created date:      29/03/2019
 last modified:     29/03/2019
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



- (IBAction)ActivityStateChanged:(id)sender {
    [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];

    if (self.SegmentState.selectedSegmentIndex == 1) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightBold];

        self.ImageViewStateIndicator.image = [UIImage systemImageNamed:@"figure.walk" withConfiguration:config];
    } else {

        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightBold];

        self.ImageViewStateIndicator.image = [UIImage systemImageNamed:@"lightbulb" withConfiguration:config];
    }

    if (self.TableViewDiary.hidden == true) {
        [self.CollectionViewActivities reloadData];
    } else {
        [self.TableViewDiary reloadData];
    }
}

- (IBAction)SwitchEditModeChanged:(id)sender {
    self.editmode = !self.editmode;
    [self.CollectionViewActivities performBatchUpdates:^{ } completion:^(BOOL finished) { [self.CollectionViewActivities reloadData];}];
    

}

/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

/*
 created date:      08/09/2018
 last modified:     16/02/2019
 remarks:
 */
- (void)didUpdateActivityImages :(bool)ForceUpdate {
    [self LoadActivityImageData];
}

- (IBAction)ShowDatePressed:(id)sender {
    // NSLog(@"TOUCHED");
}

- (IBAction)RemoveDatePressedUp:(id)sender {
    // NSLog(@"UNTOUCHED");
}

/*
 created date:      20/02/2019
 last modified:     12/01/2020
 remarks:
 */
- (IBAction)SwapMainViewPressed:(id)sender {
        
    for (UIView *i in self.view.subviews){
        if (i.tag==100 || i.tag==101) {
            [i removeFromSuperview];
        }
    }
    
    if (self.TableViewDiary.hidden == true) {
        
        /* Present Diary view */

        
        self.ButtonShare.hidden = true;
        self.TableViewDiary.hidden = false;
        [self.TableViewDiary reloadData];
        self.CollectionViewActivities.hidden = true;
       
        [self.ButtonSwapMainView setImage:[UIImage systemImageNamed:@"squareshape.split.2x2"] forState:UIControlStateNormal];
        [self.ButtonSwapMainView setTitle:@"Grid" forState:UIControlStateNormal];

    } else {
        
        /* Present Grid view */
              
        self.ButtonShare.hidden = false;
        self.TableViewDiary.hidden = true;
        [self.CollectionViewActivities reloadData];
        self.CollectionViewActivities.hidden = false;
        [self.ButtonSwapMainView setImage:[UIImage systemImageNamed:@"list.bullet.rectangle"] forState:UIControlStateNormal];
        [self.ButtonSwapMainView setTitle:@"Detail" forState:UIControlStateNormal];
    }
}

/*
 created date:      12/01/2020
 last modified:     12/01/2020
 remarks:
 */
-(void)helperViewButtonPressed :(id)sender {
    
    UIView *parentView = [(UIView *)sender superview];
    
    //if ([parentView.tag
    NSString *viewName = @"ActivityListVC-Grid";
    if (parentView.tag == 100) {
        viewName = @"ActivityListVC-Diary";
    }
    
    RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
         AssistantRLM *assist = [[settings[0].AssistantCollection objectsWhere:@"ViewControllerName=%@",viewName] firstObject];
         
    NSLog(@"%@",assist);
    if ([assist.State integerValue] == 1) {
        [self.realm beginWriteTransaction];
        assist.State = [NSNumber numberWithInteger:0];
        [self.realm commitWriteTransaction];
    }
    
    [parentView setHidden:TRUE];
}



/*
 created date:      30/03/2019
 last modified:     31/03/2019
 remarks:
 */
- (UIImage *)imageWithCollectionView {
    UIImage* image = nil;
    UIGraphicsBeginImageContextWithOptions(self.CollectionViewActivities.contentSize, NO, 0.0);
    {
        CGPoint savedContentOffset = self.CollectionViewActivities.contentOffset;
        CGRect savedFrame = self.CollectionViewActivities.frame;
        
        self.CollectionViewActivities.contentOffset = CGPointZero;
        self.CollectionViewActivities.frame = CGRectMake(0, 0, self.CollectionViewActivities.contentSize.width, self.CollectionViewActivities.contentSize.height);
        
        [self.CollectionViewActivities.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        self.CollectionViewActivities.contentOffset = savedContentOffset;
        self.CollectionViewActivities.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    return image;
}


/*
 created date:      15/03/2019
 last modified:     06/03/2021
 remarks:           Added completion block as image rendered too soon after reload data.
                    CustomCollectionView is custom subclass of UICollectionView.
                    https://stackoverflow.com/questions/16071503/how-to-tell-when-uitableview-has-completed-reloaddata
 */
- (IBAction)shareButtonPressed:(id)sender {
    /* tweet break selected */
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Share highlights of Trip\n%@", self.Trip.name] message:@"Send an ePostcard or Share on active Social Media feed with pre-selected activities."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert.view setTintColor:[UIColor labelColor]];
    
    UIAlertAction* tweetAction = [UIAlertAction actionWithTitle:@"Social Media" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              
                                                                    dispatch_async(dispatch_get_main_queue(), ^{

                                                                        self.tweetview = true;
                                                                        [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];
                                                                        [self.CollectionViewActivities reloadDataWithCompletion:^{

                                                                        [self.CollectionViewActivities layoutIfNeeded];

                                                                        UIImage *image;
                                                                        image = [self imageWithCollectionView];

                                                                        TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:image];
                                                                        cropViewController.delegate = self;

                                                                        [cropViewController setTitle:@"Social Media - Set Picture size"];

                                                                        [self presentViewController:cropViewController animated:YES completion:nil];

                                                                    }];
                                                              });
                                                          }];
    
    UIAlertAction* emailAction = [UIAlertAction actionWithTitle:@"ePostcard" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               
                                                                if ([MFMailComposeViewController canSendMail])
                                                                {
                                                                    dispatch_async(dispatch_get_main_queue(), ^{

                                                                        self.tweetview = true;
                                                                        [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];
                                                                        [self.CollectionViewActivities reloadDataWithCompletion:^{

                                                                            [self.CollectionViewActivities layoutIfNeeded];
                                                                            UIImage *image;
                                                                            image = [self imageWithCollectionView];

                                                                            TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:image];
                                                                            cropViewController.delegate = self;
                                                                            [cropViewController setTitle:@"ePostcard - Set Picture size"];
                                                                            [self presentViewController:cropViewController animated:YES completion:nil];
                                                                        }];
                                                                    });
                                                                }
                                                                else
                                                                {
                                                                    NSLog(@"This device cannot send email");
                                                                }
 
                                                           }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             // do nothing..
                                                             
                                                         }];
    
    [alert addAction:tweetAction];
    [alert addAction:emailAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
 
}


/*
created date:       22/08/2019
last modified:      22/08/2019
remarks:            Response from mail Composer.  Handles with a reload of collectionview
*/
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
 
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tweetview = false;
        [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];
        [self.CollectionViewActivities reloadData];
    });
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


/*
created date:      11/09/2019
last modified:     06/03/2021
remarks:           User dismisses action to send ePostcard or Tweet.
*/
- (void)cropViewController:(TOCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled  {
   
    if (@available(iOS 14, *)) {
        [cropViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        cropViewController.transitioningDelegate = nil;
        
    }
    
    [cropViewController dismissViewControllerAnimated:YES completion:NULL];

    dispatch_async(dispatch_get_main_queue(), ^{
        self.tweetview = false;
        [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];
        [self.CollectionViewActivities reloadData];
    });
}



/*
 created date:      22/08/2019
 last modified:     06/03/2021
 remarks:           User manually resizes image of collectionview made by system.  This method handles
                    what should do depending on title passed in.  (email or tweet)
 */
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{

    bool isTweet = false;
    if ([cropViewController.titleLabel.text isEqualToString:@"Social Media - Set Picture size"]) {
        isTweet = true;
    }
    
    if (@available(iOS 14, *)) {
        [cropViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        cropViewController.transitioningDelegate = nil;
        
    }
    
    [cropViewController dismissViewControllerAnimated:YES completion:NULL];

    
    if (isTweet) {
        
        NSString *TripType = @"highlights";
               
        self.tweetview = false;
        [self LoadActivityData :[NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex]];
        [self.CollectionViewActivities reloadData];
    
        if (self.SegmentState.selectedSegmentIndex == 0) {
            TripType = @"itinerary";
        }
        
        NSString *postText = [NSString stringWithFormat:@"%@ trip %@, generated with @Trips_App ",self.Trip.name, TripType];
        UIImage *postImage = image;
        NSArray *postItems = @[postText, postImage];
        
        UIActivityViewController *activityPostVC = [[UIActivityViewController alloc]initWithActivityItems:postItems applicationActivities:nil];

        NSArray *excludedItems = @[UIActivityTypePostToWeibo,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll, UIActivityTypeMail, UIActivityTypeMessage];

        [activityPostVC setExcludedActivityTypes:excludedItems];

        [self presentViewController:activityPostVC animated:YES completion:nil];
    
    } else {
    
    
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
                 
        mail.mailComposeDelegate = self;
          
        [mail setSubject:[NSString stringWithFormat:@"ePostcard %@", self.Trip.name]];
        
        [mail setMessageBody:@"Wish you were here! <br/><br/>(Generated using Trips App for iOS)" isHTML:YES];
                                                    
        
        NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
        NSString *attachmentName = @"trips-collage.jpg";
        [mail addAttachmentData:imageData mimeType:@"image/jpeg" fileName:attachmentName];
                                                                       
        [self presentViewController:mail animated:YES completion:NULL];
        
    }
}

/*
 created date:      14/06/2019
 last modified:     14/06/2019
 remarks:           This procedure handles the call to the web service and returns a dictionary back to GetExchangeRates method.
 */
-(void)fetchFromDarkSkyApi:(NSString *)url withDictionary:(void (^)(NSDictionary* data))dictionary{
    
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:data
                                                                                              options:0
                                                                                                error:NULL];
                                      dictionary(dicData);
                                  }];
    [task resume];
}




@end
