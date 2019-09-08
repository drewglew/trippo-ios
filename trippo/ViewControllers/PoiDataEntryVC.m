//
//  PoiDataEntryVC.m
//  travelme
//
//  Created by andrew glew on 28/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PoiDataEntryVC.h"
#define CLCOORDINATE_EPSILON 0.005f
#define CLCOORDINATES_EQUAL2( coord1, coord2 ) (fabs(coord1.latitude - coord2.latitude) < CLCOORDINATE_EPSILON && fabs(coord1.longitude - coord2.longitude) < CLCOORDINATE_EPSILON)

@interface PoiDataEntryVC () <PoiDataEntryDelegate>

@end

@implementation PoiDataEntryVC
@synthesize delegate;
CLLocationCoordinate2D ModifiedCoordinate;
bool CenterSelectedType;

/*
 created date:      28/04/2018
 last modified:     26/08/2019
 remarks: Need to optimize the call to settings so it ends up as part of the appdelegate or something
 */
- (void)viewDidLoad {
    CenterSelectedType = true;
    [super viewDidLoad];
    
    RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
    if (settings.count==0) {
        self.Settings = [[SettingsRLM alloc] init];
        self.Settings.userkey = @"UNKNOWN-KEY";
        self.Settings.username = @"Jane Doe";
        self.Settings.useremail = @"jane,doe@unknown.com";
    } else {
        self.Settings = settings[0];
    }

    self.PoiImageDictionary = [[NSMutableDictionary alloc] init];
    
    if (self.PointOfInterest.IncludeWeather == nil || [self.PointOfInterest.IncludeWeather intValue] == 0) {
        [self.SwitchWeather setOn:false];
    } else {
        [self.SwitchWeather setOn:true];
    }

    if (self.newitem && !self.fromnearby) {
        if (![self.PointOfInterest.name isEqualToString:@""]) {
            self.TextFieldTitle.text = self.PointOfInterest.name;
            self.TextViewNotes.text = self.PointOfInterest.privatenotes;
        } else {
            self.TextViewNotes.text = self.PointOfInterest.privatenotes;
        }
    } else if (self.fromnearby) {
        self.TextFieldTitle.text = self.PointOfInterest.name;
        self.TextViewNotes.text = self.PointOfInterest.privatenotes;
        
        if (self.haswikimainimage) {
            
            ImageCollectionRLM *imgobject = [[ImageCollectionRLM alloc] init];
            imgobject.key = [[NSUUID UUID] UUIDString];
            imgobject.KeyImage = 1;
            imgobject.info = self.WikiMainImageDescription;
            
            [self.realm beginWriteTransaction];
            [self.PointOfInterest.images addObject:imgobject];
            [self.realm commitWriteTransaction];
            
            CGSize size = CGSizeMake(self.TextViewNotes.frame.size.width * 2, self.TextViewNotes.frame.size.width * 2);
        
            [self.PoiImageDictionary setObject:[ToolBoxNSO imageWithImage:self.WikiMainImage scaledToSize:size] forKey:imgobject.key];
            [self.ImagePicture setImage:[self.PoiImageDictionary objectForKey:imgobject.key]];
            [self.ImageViewKey setImage:[self.PoiImageDictionary objectForKey:imgobject.key]];
            self.LabelPhotoInfo.text = imgobject.info;
        }
        
    } else {
        if (self.readonlyitem) {
            self.TextFieldTitle.enabled = false;
            [self.TextViewNotes setEditable:false];
            self.CollectionViewPoiImages.scrollEnabled = true;
        }
        
        [self LoadImageDataCollection];
        
        /* Text fields and Segment */
        self.TextViewNotes.text = self.PointOfInterest.privatenotes;
        self.TextFieldTitle.text = self.PointOfInterest.name;
    }
    
    self.ImagePicture.frame = CGRectMake(0, 0, self.ScrollViewImage.frame.size.width, self.ScrollViewImage.frame.size.height);
    
    self.ScrollViewImage.delegate = self;
    
    
    [self LoadCategoryData];

    [self LoadMapData];

    UILongPressGestureRecognizer* mapLongPressAddAnnotation = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(AddAnnotationToMap:)];
    
    [mapLongPressAddAnnotation setMinimumPressDuration:0.5];
    [self.MapView addGestureRecognizer:mapLongPressAddAnnotation];
    
    self.CollectionViewPoiImages.dataSource = self;
    self.CollectionViewPoiImages.delegate = self;
    
    
    self.CollectionViewTypes.dataSource = self;
    self.CollectionViewTypes.delegate = self;
    // Do any additional setup after loading the view.

    /*
    self.TextFieldTitle.layer.cornerRadius=8.0f;
    self.TextFieldTitle.layer.masksToBounds=YES;
    self.TextFieldTitle.layer.borderColor=[[UIColor clearColor]CGColor];
    self.TextFieldTitle.layer.borderWidth= 1.0f;
     */
    
    // Map Distance Picker frame
    self.ViewDistancePicker.layer.cornerRadius=8.0f;
    self.ViewDistancePicker.layer.masksToBounds=YES;
    self.ViewDistancePicker.layer.borderColor=[[UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0]CGColor];
    self.ViewDistancePicker.layer.borderWidth= 2.5f;
    
    
    self.TextViewNotes.layer.cornerRadius=8.0f;
    self.TextViewNotes.layer.masksToBounds=YES;
    
    // heigtht of option blurred view is 60; view is 4 less; to make a circle we need half the remainder.
    self.ViewSelectedKey.layer.cornerRadius=28;
    self.ViewSelectedKey.layer.masksToBounds=YES;
    
    self.ViewTrash.layer.cornerRadius=28;
    self.ViewTrash.layer.masksToBounds=YES;
    
    [self addDoneToolBarToKeyboard:self.TextViewNotes];
    
    [self addDoneToolBarForTextFieldToKeyboard: self.TextFieldTitle];
    
    self.TextFieldTitle.delegate = self;
    self.TextViewNotes.delegate = self;
    
    
    if (self.checkInternet) {
        if ([self.PointOfInterest.countrycode isEqualToString:@""] || self.PointOfInterest.countrycode==nil) {
            self.ButtonGeo.hidden = false;
        }
        // TODO we need to check if Poi has missing data and that the internet is available...
        
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.PointOfInterest.categoryid unsignedLongValue] inSection:0];
    [self.CollectionViewTypes scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    
    
    /* load the average count of ratings given to this point of interest inside actual activities */
    RLMResults<ActivityRLM*> *activities = [ActivityRLM objectsWhere:@"poikey==%@ and state==1",self.PointOfInterest.key];
    
    int totalelements = 0;
    int occurances = 0;
    float total = 0.0f;
    float average = 0.0f;
   
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [cal setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents * comp = [cal components:( NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    [comp setYear:1900];
    [comp setMonth:1];
    [comp setDay:1];
    [comp setMinute:0];
    [comp setHour:0];
    [comp setSecond:0];
    NSDate *LastVisitiedDt = [cal dateFromComponents:comp];
    
    for (ActivityRLM *activity in activities) {
        occurances ++;
        if (activity.rating != [NSNumber numberWithFloat:0]) {
            totalelements ++;
            total += [activity.rating floatValue];
        }
        if([activity.startdt compare: LastVisitiedDt] == NSOrderedDescending ) {
            LastVisitiedDt = activity.startdt;
        }
    }
    
    if (total>0.0f) {
        average = total / totalelements;
        self.LabelOccurances.text = [NSString stringWithFormat:@"Visited %d times\n%@",occurances, [self FormatPrettyDate:LastVisitiedDt]];
    } else {
        average = 0.0f;
        if (occurances > 0) {
             self.LabelOccurances.text = [NSString stringWithFormat:@"Visited %d times\n%@",occurances, [self FormatPrettyDate:LastVisitiedDt]];
        } else {
            self.LabelOccurances.text = @"Not found in any activities";
        }
    }
    
    self.ViewStarRatings.maximumValue = 5;
    self.ViewStarRatings.minimumValue = 0;
    self.ViewStarRatings.value = average;
    self.ViewStarRatings.allowsHalfStars = YES;
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"dd MMM, YYYY HH:mm"];
    
    self.LabelInfoName.text = self.PointOfInterest.name;
    self.LabelInfoSharedBy.text = self.PointOfInterest.sharedby;
    NSLog(@"device shared by:%@",self.PointOfInterest.devicesharedby);
    self.LabelInfoSharedDevice.text = self.PointOfInterest.devicesharedby;
    self.labelInfoAuthorName.text = self.PointOfInterest.authorname;
    self.LabelInfoSharedDt.text = [dateFormatter  stringFromDate:self.PointOfInterest.importeddt];
    self.LabelInfoCreatedDt.text = [dateFormatter  stringFromDate:self.PointOfInterest.createddt];
    self.LabelInfoLastModified.text = [dateFormatter  stringFromDate:self.PointOfInterest.modifieddt];
    [self registerForKeyboardNotifications];
    self.SegmentDetailOption.selectedSegmentTintColor = [UIColor colorNamed:@"TrippoColor"];
    
}


/*
 created date:      28/04/2018
 last modified:     28/03/2019
 remarks: TODO - split load existing data into 2 - map data and images.
 */
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIImage *ImageWiki;
    if (![self.PointOfInterest.wikititle isEqualToString:@""]) {
        ImageWiki = [UIImage imageNamed:@"WikiFilled"];
    } else {
        ImageWiki = [UIImage imageNamed:@"Wiki"];
    }
    self.ButtonWiki.imageView.image = [ImageWiki imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    
    self.PoiScrollView.contentSize = CGSizeMake(self.PoiScrollView.frame.size.width, self.PoiScrollViewContent.frame.size.height);
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.PoiScrollView.contentInset = contentInsets;
    self.PoiScrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height + 50.0;
    if (!CGRectContainsPoint(aRect, self.ActiveTextField.frame.origin) && self.ActiveTextView == nil ) {
        NSLog(@"contentsize=%f,%f",self.PoiScrollView.contentSize.height, self.PoiScrollView.contentSize.width);
        
         //CGRect aRectTextField = CGRectMake(self.ActiveTextField.frame.origin.x, self.ActiveTextField.frame.origin.y, self.ActiveTextField.frame.size.width, self.ActiveTextField.frame.size.height - aRect.size.height);
        
        [self.PoiScrollView scrollRectToVisible:self.ActiveTextField.frame animated:YES];
        
    } else if (!CGRectContainsPoint(aRect, self.ActiveTextView.frame.origin) && self.ActiveTextField == nil ) {
        
         [self.PoiScrollView scrollRectToVisible:self.ActiveTextView.frame animated:YES];
        
    }
    
    self.SegmentDetailOption.selectedSegmentTintColor = [UIColor colorWithRed:0.0f/255.0f green:102.0f/255.0f blue:51.0f/255.0f alpha:1.0];

}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.PoiScrollView.contentInset = contentInsets;
    self.PoiScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.ActiveTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.ActiveTextField = nil;
}
/*
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //self.TextFieldTitle.backgroundColor = [UIColor whiteColor];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //self.TextFieldTitle.backgroundColor = [UIColor clearColor];
    return YES;
}
*/
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.ActiveTextView = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.ActiveTextView = nil;
}

-(void)doneButtonClickedDismissKeyboard
{
    [self.TextViewNotes resignFirstResponder];
    [self.TextFieldTitle resignFirstResponder];

}







/*
 created date:      11/06/2018
 last modified:     28/03/2019
 remarks:
 */
-(void) LoadCategoryData {
  
    self.TypeItems = @[@"Cat-Accomodation",
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
                       @"Cat-Windmill",
                       @"Cat-Zoo"
                       ];
    
    self.TypeLabelItems  = @[
                             @"Accomodation",
                             @"Airport",
                             @"Astronaut",
                             @"Bakery",
                             @"Beer",
                             @"Bicycle",
                             @"Bridge",
                             @"Car Hire",
                             @"Car Park",
                             @"Casino",
                             @"Cave",
                             @"Church",
                             @"Cinema",
                             @"City",
                             @"CityPark",
                             @"Climbing",
                             @"Club",
                             @"Coast",
                             @"Concert",
                             @"Food and Wine",
                             @"Football",
                             @"Forest",
                             @"Golf",
                             @"Historic",
                             @"Home",
                             @"Lake",
                             @"Lighthouse",
                             @"Metropolis",
                             @"Miscellaneous",
                             @"Monument/Statue",
                             @"Museum",
                             @"National Park",
                             @"Nature",
                             @"Office",
                             @"Petrol Station",
                             @"Photography",
                             @"Restaurant",
                             @"River",
                             @"Rugby",
                             @"Safari",
                             @"Scenary",
                             @"School",
                             @"Ship",
                             @"Shopping",
                             @"Skiing",
                             @"Sports/Exercise",
                             @"Swimming",
                             @"Tennis",
                             @"Theatre",
                             @"Theme Park",
                             @"Tower",
                             @"Train",
                             @"Trekking",
                             @"Venue",
                             @"Village",
                             @"Windmill",
                             @"Zoo"
                             ];
    
    self.TypeDistanceItems  = @[
                                @40,// @“Accomodation", = 0
                                @500, // @"Airport", = 1
                                @20000, // @"Astronaut", = 2
                                @40, // @"Bakery”, = 3
                                @50, // @"Beer", = 4
                                @50, // @“Bicycle”, = 5
                                @150, // @"Bridge", = 6
                                @100, // @"Car Hire", = 7
                                @100, // @“Car Park", = 8
                                @200, // @"Casino", = 9
                                @250, // @"Cave", = 10
                                @250, // @"Church", = 11
                                @250, // @"Cinema", = 12
                                @2000, // @"City", = 13
                                @5000, // @"CityPark", = 14
                                @1000, // @"Climbing", = 15
                                @250, // @"Club", = 16
                                @5000, // @"Coast”, = 17
                                @300, // @"Concert", = 18
                                @50, // @"Food and Wine", = 19
                                @1000, // @"Football", = 20
                                @5000, // @"Forest", = 21
                                @5000, // @"Golf", = 22
                                @500, // @"Historic", = 23
                                @20, // @"Home”, = 24
                                @500, // @"Lake", = 25
                                @200, // @"Lighthouse", = 26
                                @10000, // @"Metropolis", = 27
                                @10000, // @"Miscellaneous”, = 28
                                @1000, // @"Monument/Statue“, = 29
                                @1000, // @"Museum", = 30
                                @10000, // @"National Park", = 31
                                @10000, // @"Nature", = 32
                                @250, // @"Office", = 33
                                @100, // @"Petrol Station", = 34
                                @10000, // @"Photography", = 35
                                @150, // @"Restaurant", = 36
                                @1500, // @"River", = 37
                                @1000, // @"Rugby", = 38
                                @10000, // @"Safari", = 39
                                @5000, // @"Scenery", = 40
                                @150, // @"School", = 41
                                @1000, // @"Ship", = 42
                                @250, // @"Shopping", = 43
                                @5000, // @"Skiing”, = 44
                                @250, // @"Sports/Exercise“, = 45
                                @250, // @"Swimming", = 46
                                @250, // @"Tennis", = 47
                                @150, // @"Theatre", = 48
                                @500, // @"Theme Park", = 49
                                @1000, // @"Tower", = 50
                                @150, // @"Train", = 51
                                @10000, // @"Trekking”, = 52
                                @250, // @"Venue", = 53
                                @1000, // @"Village", = 54
                                @1000, // @"Windmill", = 55
                                @1000 // @"Zoo", = 56
                             ];

    self.LabelPoi.text = [self GetPoiLabelWithType:self.PointOfInterest.categoryid];
    
    
    
    
    self.DistancePickerItems = @[@"10",@"20",@"30",@"40",@"50",@"60",@"70",@"80",@"90",@"100",@"125",@"150",@"175",@"200",@"225",@"250",@"275",@"300",@"325",@"350",@"375",@"400",@"425",@"450",@"475",@"500",@"600",@"700",@"800",@"900",@"1000",@"1250",@"1500",@"1750",@"2000",@"2500",@"3000",@"3500",@"4000",@"4500",@"5000",@"6000",@"7000",@"8000",@"9000",@"10000",@"20000"];
    
    self.PickerDistance.delegate = self;
    self.PickerDistance.dataSource = self;
    
    if (self.newitem || self.PointOfInterest.radius == nil) {
        
        if (self.newitem) {
            self.PointOfInterest.categoryid = [NSNumber numberWithLong:0];
        }
        NSString *distanceFromTypeSelected = [NSString stringWithFormat:@"%@",[self.TypeDistanceItems objectAtIndex:[self.PointOfInterest.categoryid longValue]]];
        [self.PickerDistance selectRow:[self.DistancePickerItems indexOfObject: distanceFromTypeSelected] inComponent:0 animated:YES];
        
    } else {
        NSString *distanceFromTypeSelected = [NSString stringWithFormat:@"%@",self.PointOfInterest.radius];
        [self.PickerDistance selectRow:[self.DistancePickerItems indexOfObject: distanceFromTypeSelected] inComponent:0 animated:YES];
    }
}

/*
 created date:      28/03/2019
 last modified:     28/03/2019
 remarks:
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

/*
 created date:      28/03/2019
 last modified:     28/03/2019
 remarks:
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.DistancePickerItems.count;
}

/*
 created date:      28/03/2019
 last modified:     28/03/2019
 remarks:
 */
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *pickerLabel = (UILabel *)view;
    // Reuse the label if possible, otherwise create and configure a new one
    if ((pickerLabel == nil) || ([pickerLabel class] != [UILabel class])) { //newlabel
        CGRect frame = CGRectMake(0.0, 0.0, 270, 32.0);
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        pickerLabel.textAlignment =NSTextAlignmentCenter;
        pickerLabel.backgroundColor = [UIColor clearColor];
        pickerLabel.font = [UIFont fontWithName:@"AmericanTypewriter" size:12];
    }
    pickerLabel.textColor = [UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0];
    pickerLabel.text = [self.DistancePickerItems objectAtIndex:row];
    return pickerLabel;
}

/*
 created date:      28/03/2019
 last modified:     28/03/2019
 remarks:
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *radius = [f numberFromString:[self.DistancePickerItems objectAtIndex: row]];
    
    CLLocationDistance RadiusAmt = [radius doubleValue];
    ModifiedCoordinate = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
    
    [self.MapView removeOverlay:self.CircleRange];
    self.CircleRange = [MKCircle circleWithCenterCoordinate:ModifiedCoordinate radius:RadiusAmt];
    [self.MapView addOverlay:self.CircleRange];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(ModifiedCoordinate, [radius doubleValue] * 2.1, [radius doubleValue] * 2.1);
    MKCoordinateRegion adjustedRegion = [self.MapView regionThatFits:viewRegion];
    [self.MapView setRegion:adjustedRegion animated:YES];
}

/*
created date:      27/08/2019
last modified:     27/08/2019
remarks:
*/
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
    
    MKMarkerAnnotationView *pinView = (MKMarkerAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    
    if (!pinView) {
        pinView = [[MKMarkerAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"];
    } else {
        pinView.annotation = annotation;
    }
    pinView.markerTintColor = [UIColor colorNamed:@"TrippoColor"];
    return pinView;
}

/*
 created date:      11/06/2018
 last modified:     28/03/2019
 remarks:
 */
-(void) LoadMapData {
    /* set map */
    self.MapView.delegate = self;

    //self.MapView.pointOfInterestFilter = [MKPointOfInterestFilter filterIncludingAllCategories];
    
    
    
    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
    anno.title = self.PointOfInterest.name;
    anno.subtitle = [NSString stringWithFormat:@"%@", self.PointOfInterest.administrativearea];

    ModifiedCoordinate = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
    
    anno.coordinate = ModifiedCoordinate;

    //NSNumber *radius = [self.TypeDistanceItems objectAtIndex:[self.PointOfInterest.categoryid longValue]];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *radius = [f numberFromString:[self.DistancePickerItems objectAtIndex: [self.PickerDistance selectedRowInComponent:0]]];

    [self.MapView setCenterCoordinate:ModifiedCoordinate animated:YES];
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(ModifiedCoordinate, [radius doubleValue] * 2.1, [radius doubleValue] * 2.1);
    MKCoordinateRegion adjustedRegion = [self.MapView regionThatFits:viewRegion];
    [self.MapView setRegion:adjustedRegion animated:YES];
    [self.MapView addAnnotation:anno];
    [self.MapView selectAnnotation:anno animated:YES];

}


/*
 created date:      16/03/2019
 last modified:     28/03/2019
 remarks: User gestures a long tap, the annotation is placed where the figure is.
 */
-(void)AddAnnotationToMap:(UILongPressGestureRecognizer *)gesture
{

    UIGestureRecognizer *recognizer = (UIGestureRecognizer*) gesture;
    if(UIGestureRecognizerStateBegan == gesture.state)
    {
        CGPoint tapPoint = [recognizer locationInView:self.MapView];
        CLLocationCoordinate2D location = [self.MapView convertPoint:tapPoint toCoordinateFromView:self.MapView];
        
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        
        [geoCoder reverseGeocodeLocation: [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"%@", [NSString stringWithFormat:@"%@", error.localizedDescription]);
            } else {

                AnnotationMK *anno = [[AnnotationMK alloc] init];
                
                if ([placemarks count]>0) {
                    CLPlacemark *placemark = [placemarks firstObject];
                    anno.coordinate = placemark.location.coordinate;
                    anno.title = placemark.name;
                    
                    NSString *AdminArea = placemark.subAdministrativeArea;
                    if ([AdminArea isEqualToString:@""] || AdminArea == NULL) {
                        AdminArea = placemark.administrativeArea;
                    }
                    
                    anno.subtitle = [NSString stringWithFormat:@"%@, %@", AdminArea, placemark.ISOcountryCode ];
                    
                    anno.Country = placemark.country;
                    anno.SubLocality = placemark.subLocality;
                    anno.Locality = placemark.locality;
                    anno.PostCode = placemark.postalCode;
                    anno.CountryCode = placemark.ISOcountryCode;
                    anno.FullThoroughFare = [NSString stringWithFormat:@"%@, %@", placemark.thoroughfare, placemark.subThoroughfare];
                    
                    [self.MapView addAnnotation:anno];
                    [self.MapView selectAnnotation:anno animated:true];
                } else {
                    anno.title = @"Unknown Place";
                }
                [self.MapView removeAnnotations:self.MapView.annotations];
                self.ButtonMapUpdate.hidden = false;
                self.ButtonMapRevert.hidden = false;
                
                //NSNumber *radius = [self.TypeDistanceItems objectAtIndex:[self.PointOfInterest.categoryid longValue]];
                
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                NSNumber *radius = [f numberFromString:[self.DistancePickerItems objectAtIndex: [self.PickerDistance selectedRowInComponent:0]]];
                
                
                
                [self.MapView setCenterCoordinate:anno.coordinate animated:YES];
                MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(anno.coordinate, [radius doubleValue] * 2.1, [radius doubleValue] * 2.1);
                MKCoordinateRegion adjustedRegion = [self.MapView regionThatFits:viewRegion];
                [self.MapView setRegion:adjustedRegion animated:YES];

                for (id<MKOverlay> overlay in self.MapView.overlays)
                {
                    [self.MapView removeOverlay:overlay];
                }
                
                CLLocationDistance RadiusAmt = [radius doubleValue];
                self.CircleRange = [MKCircle circleWithCenterCoordinate:anno.coordinate radius:RadiusAmt];
                
                ModifiedCoordinate = anno.coordinate;
                
                [self.MapView addOverlay:self.CircleRange];
                
                [self.MapView addAnnotation:anno];
                [self.MapView selectAnnotation:anno animated:true];
            }
        }];
    }
}

/*
 created date:      16/03/2019
 last modified:     28/03/2019
 remarks:
 */
- (IBAction)RevertMapButtonPressed:(id)sender {
    
    [self.MapView removeAnnotations:self.MapView.annotations];
    for (id<MKOverlay> overlay in self.MapView.overlays)
    {
        [self.MapView removeOverlay:overlay];
    }
    [self LoadMapData];
    
    //NSNumber *radius = [self.TypeDistanceItems objectAtIndex:[self.PointOfInterest.categoryid longValue]];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *radius = [f numberFromString:[self.DistancePickerItems objectAtIndex: [self.PickerDistance selectedRowInComponent:0]]];
    
    
    CLLocationDistance RadiusAmt = [radius doubleValue];
    ModifiedCoordinate = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
    
    self.CircleRange = [MKCircle circleWithCenterCoordinate:ModifiedCoordinate radius:RadiusAmt];
    [self.MapView addOverlay:self.CircleRange];
    
    self.ButtonMapRevert.hidden = true;
    self.ButtonMapUpdate.hidden = true;
}



/*
 created date:      16/03/2019
 last modified:     16/03/2019
 remarks:           Need to save the location modification. Do we need to update the main array?
 */
- (IBAction)UpdateMapButtonPressed:(id)sender {
    
    [self.PointOfInterest.realm beginWriteTransaction];
    
    self.PointOfInterest.lon = [NSNumber numberWithDouble:ModifiedCoordinate.longitude];
    self.PointOfInterest.lat = [NSNumber numberWithDouble:ModifiedCoordinate.latitude ];
    
    [self.PointOfInterest.realm commitWriteTransaction];
    self.ButtonMapRevert.hidden = true;
    self.ButtonMapUpdate.hidden = true;
}


/*
 created date:      14/07/2018
 last modified:     28/03/2019
 remarks: this method handles the map circle that is placed as overlay onto map
 */
- (MKOverlayRenderer *) mapView:(MKMapView *)mapView rendererForOverlay:(id)overlay {
    if([overlay isKindOfClass:[MKCircle class]])
    {
        MKCircleRenderer* aRenderer = [[MKCircleRenderer
                                        alloc]initWithCircle:(MKCircle *)overlay];
        
        
        
        aRenderer.strokeColor = [UIColor colorNamed:@"TrippoColor"];
        aRenderer.lineWidth = 2;
        
        //TrippoColorAlpha
        aRenderer.fillColor =  [UIColor colorWithRed:49.0f/255.0f green:163.0f/255.0f blue:0.0f/255.0f alpha:0.25];
                               // colorWithAlphaComponent:0.25]
        return aRenderer;
    }
    else
    {
        return nil;
    }
}

/*
 created date:      28/04/2018
 last modified:     31/08/2018
 remarks:
 */
-(void) LoadImageDataCollection {

    /* load images from file - TODO make sure we locate them all */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    
    for (ImageCollectionRLM *imageitem in self.PointOfInterest.images) {
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imageitem.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        
        UIImage *image;
        if (pngData!=nil) {
            image = [UIImage imageWithData:pngData];
        } else {
            image = [UIImage systemImageNamed:@"command"];
        }
        if (imageitem.KeyImage) {
            self.SelectedImageKey = imageitem.key;
            self.ViewSelectedKey.hidden = false;
            [self.ImagePicture setImage:image];
            [self.ImageViewKey setImage:image];
        }
        [self.PoiImageDictionary setObject:image forKey:imageitem.key];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 created date:      28/04/2018
 last modified:     12/08/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.CollectionViewPoiImages) {
        return self.PointOfInterest.images.count + 1;
    } else {
        return self.TypeItems.count;
    }
}



/*
 created date:      28/04/2018
 last modified:     03/03/2019
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (collectionView == self.CollectionViewPoiImages) {
    
        PoiImageCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"PoiImageId" forIndexPath:indexPath];
        NSInteger NumberOfItems = self.PointOfInterest.images.count + 1;
        if (indexPath.row == NumberOfItems -1) {
       
            UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightThin];
                                 
            cell.ImagePoi.image = [UIImage systemImageNamed:@"plus.circle" withConfiguration:config];
            [cell.ImagePoi setTintColor: [UIColor colorNamed:@"TrippoColor"]];
       
        } else {
            ImageCollectionRLM *imgreference = [self.PointOfInterest.images objectAtIndex:indexPath.row];
            cell.ImagePoi.image = [self.PoiImageDictionary objectForKey:imgreference.key];
        }
        return cell;
        
    } else {
        
        TypeCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"TypeCellId" forIndexPath:indexPath];
        cell.TypeImageView.image = [UIImage imageNamed:[self.TypeItems objectAtIndex:indexPath.row]];
        if ([self.PointOfInterest.categoryid unsignedLongValue] == indexPath.row) {
            cell.ImageViewChecked.hidden = false;
        } else {
            cell.ImageViewChecked.hidden = true;
        }
       
        return cell;
    }
}


/*
 created date:      28/04/2018
 last modified:     28/03/2019
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    /* add the insert method if found to be last cell */
    
    if (collectionView == self.CollectionViewPoiImages) {
        NSInteger NumberOfItems = self.PointOfInterest.images.count + 1;
        
        if (indexPath.row == NumberOfItems - 1) {
            /* insert item */
            //self.PoiImage = [[PoiImageNSO alloc] init];
            self.imagestate = 1;
            [self InsertPoiImage];
        } else {
            
            if (!self.newitem) {
                ImageCollectionRLM *imgobject = [self.PointOfInterest.images objectAtIndex:indexPath.row];
                self.SelectedImageKey = imgobject.key;
                self.SelectedImageIndex = [NSNumber numberWithLong:indexPath.row];
                if (imgobject.KeyImage==0) {
                    self.ViewSelectedKey.hidden = true;
                } else {
                    self.ViewSelectedKey.hidden = false;
                }
                [self.ImagePicture setImage:[self.PoiImageDictionary objectForKey:imgobject.key]];
                self.LabelPhotoInfo.text = imgobject.info;
                if (imgobject.ImageFlaggedDeleted==0) {
                    self.ViewTrash.hidden = true;
                } else {
                     self.ViewTrash.hidden = false;
                }

            }
            else {
                ImageCollectionRLM *imgobject = [self.PointOfInterest.images objectAtIndex:indexPath.row];
                [self.ImagePicture setImage:[self.PoiImageDictionary objectForKey:imgobject.key]];
                self.LabelPhotoInfo.text = imgobject.info;
            }
        }
    } else {
        if (!self.readonlyitem) {
            [self.realm beginWriteTransaction];
            self.PointOfInterest.categoryid = [NSNumber numberWithLong:indexPath.row];
            
            NSString *distanceFromTypeSelected = [NSString stringWithFormat:@"%@",[self.TypeDistanceItems objectAtIndex:indexPath.row]];
            [self.PickerDistance selectRow:[self.DistancePickerItems indexOfObject: distanceFromTypeSelected] inComponent:0 animated:YES];
            
            [self.realm commitWriteTransaction];
            self.LabelPoi.text = [NSString stringWithFormat:@"Point Of Interest - %@",[self.TypeLabelItems objectAtIndex:[self.PointOfInterest.categoryid longValue]]];
            [collectionView reloadData];
        }
    }
}

/*
 created date:      16/03/2019
 last modified:     16/03/2019
 remarks:           Scrolls to selected catagory item - only once.
 */

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (CenterSelectedType) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[self.PointOfInterest.categoryid longValue] inSection:0];
        [self.CollectionViewTypes scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        CenterSelectedType = false;
    }
}

/*
 created date:      10/06/2018
 last modified:     10/06/2018
 remarks:
 */
-(PHFetchResult*) getAssetsFromLibraryWithStartDate:(NSDate *)startDate andEndDate:(NSDate*) endDate
{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"creationDate > %@ AND creationDate < %@",startDate ,endDate];
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    return allPhotos;
}

/*
 created date:      28/04/2018
 last modified:     15/06/2019
 remarks:
 */
-(void)InsertPoiImage {
    
    
    NSString *titleMessage = @"How would you like to add a photo to your Point Of Interest?";
    NSString *alertMessage = @"";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleMessage
                                                                   message:alertMessage
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert.view setTintColor:[UIColor labelColor]];
    
    NSString *cameraOption = @"Take a photo with the camera";
    NSString *photorollOption = @"Choose a photo from camera roll";
    NSString *photoCloseToPoiOption = @"Choose own photos nearby";
    NSString *photoFromWikiOption = @"Choose photos from web";
    NSString *lastphotoOption = @"Select last photo taken";
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:cameraOption
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                                   
                                                                   
                                                                   UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Device has no camera" preferredStyle:UIAlertControllerStyleAlert];
                                                                   
                                                                   
                                                                   [alert.view setTintColor:[UIColor labelColor]];
                                                               
                                                                   UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                                                                   
                                                                   [alert addAction:defaultAction];
                                                                   [self presentViewController:alert animated:YES completion:nil];
                                                                   
                                                                   
                                                               }else
                                                               {
                                                                   
                                                                   UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                                   picker.delegate = self;
                                                                   picker.allowsEditing = YES;
                                                                   picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                   picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                                                                   
                                                                   [self presentViewController:picker animated:YES completion:NULL];
                                                                   
                                                               }
                                                               
                                                               
                                                               NSLog(@"you want a photo");
                                                               
                                                           }];
    
    
    
    UIAlertAction *photorollAction = [UIAlertAction actionWithTitle:photorollOption
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  
                                                                  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                                                  picker.delegate = self;
                                                                  picker.allowsEditing = YES;
                                                                  picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                                  [self presentViewController:picker animated:YES completion:nil];
                                                                  
                                                                  NSLog(@"you want to select a photo");
                                                                  
                                                              }];
    
    
    
    
    
    UIAlertAction *photosCloseToPoiAction = [UIAlertAction actionWithTitle:photoCloseToPoiOption
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  
                                                                  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                  ImagePickerVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ImagePickerViewController"];
                                                                  controller.delegate = self;
                                                                  
                                                                  PoiRLM *copiedpoi = [[PoiRLM alloc] init];
                                                                  copiedpoi.key = self.PointOfInterest.key;
                                                                  copiedpoi.lon = self.PointOfInterest.lon;
                                                                  copiedpoi.lat = self.PointOfInterest.lat;
                                                                  copiedpoi.name = self.PointOfInterest.name;
                                                                  
                                                                  controller.PointOfInterest = copiedpoi;
                                                                  
                                                                  controller.distance = [self.TypeDistanceItems objectAtIndex:[self.PointOfInterest.categoryid longValue]];
                                                                  
                                                                  controller.wikiimages = false;
                                                                  
                                                                  controller.ImageSize = CGSizeMake(self.TextViewNotes.frame.size.width * 2, self.TextViewNotes.frame.size.width * 2);
                                                                  [controller setModalPresentationStyle:UIModalPresentationFullScreen];
                                                                  [self presentViewController:controller animated:YES completion:nil];
                                                                  
                                                              }];
    

    UIAlertAction *photoWikiAction = [UIAlertAction actionWithTitle:photoFromWikiOption
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  
                                                                  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                  ImagePickerVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ImagePickerViewController"];
                                                                  controller.delegate = self;
                                                                  
                                                                  PoiRLM *copiedpoi = [[PoiRLM alloc] init];
                                                                  copiedpoi.key = self.PointOfInterest.key;
                                                                  copiedpoi.lon = self.PointOfInterest.lon;
                                                                  copiedpoi.lat = self.PointOfInterest.lat;
                                                                  copiedpoi.name = self.PointOfInterest.name;
                                                                  copiedpoi.wikititle = self.PointOfInterest.wikititle;
                                                                  controller.PointOfInterest = copiedpoi;
                                                                  
                                                                  controller.distance = [self.TypeDistanceItems objectAtIndex:[self.PointOfInterest.categoryid longValue]];
                                                                  
                                                                  controller.wikiimages = true;
                                                                  
                                                                  controller.ImageSize = CGSizeMake(self.TextViewNotes.frame.size.width * 2, self.TextViewNotes.frame.size.width * 2);
                                                                  [controller setModalPresentationStyle:UIModalPresentationFullScreen];
                                                                  [self presentViewController:controller animated:YES completion:nil];
                                                              }];
    

    UIAlertAction *lastphotoAction = [UIAlertAction actionWithTitle:lastphotoOption
                                    style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
                                    if (status == PHAuthorizationStatusNotDetermined) {
                                        // Access has not been determined.
                                        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                                        }];
                                    }
                                                                  
                                    if (status == PHAuthorizationStatusAuthorized)
                                    {
                                        PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
                                        options.version = PHImageRequestOptionsVersionCurrent;
                                        options.deliveryMode =  PHImageRequestOptionsDeliveryModeHighQualityFormat;
                                        options.resizeMode = PHImageRequestOptionsResizeModeExact;
                                        options.synchronous = NO;
                                        options.networkAccessAllowed =  TRUE;
                                                                      
                                        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
                                        fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
                                        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
                                        PHAsset *lastAsset = [fetchResult lastObject];
                                        CGSize size = CGSizeMake(self.TextViewNotes.frame.size.width * 2, self.TextViewNotes.frame.size.width * 2);
                                        
                                        [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                            targetSize:size
                                            contentMode:PHImageContentModeAspectFill
                                            options:options
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                                                                  
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                                     
                                                    CGSize size = CGSizeMake(self.TextViewNotes.frame.size.width * 2, self.TextViewNotes.frame.size.width * 2);

                                                    if (self.imagestate==1) {
                                                        
                                                        ImageCollectionRLM *imgobject = [[ImageCollectionRLM alloc] init];
                                                        imgobject.key = [[NSUUID UUID] UUIDString];
                                                        
                                                         UIImage *image = [ToolBoxNSO imageWithImage:result scaledToSize:size];
                                                        
                                                        if (self.PointOfInterest.images.count==0) {
                                                            imgobject.KeyImage = 1;
                                                        } else {
                                                            imgobject.KeyImage = 0;
                                                        }
                                                        
                                                        [self.realm beginWriteTransaction];
                                                        [self.PointOfInterest.images addObject:imgobject];
                                                        [self.realm commitWriteTransaction];
                                                        
                                                        [self.PoiImageDictionary setObject:image forKey:imgobject.key];
                                                        
                                                    } else if (self.imagestate==2) {
                                                        
                                                        /* need to save the new image into file location on update */
                                                        
                                                        ImageCollectionRLM *imgobject = [self.PointOfInterest.images objectAtIndex:[self.SelectedImageIndex longValue]];
                                                        
                                                        UIImage *image = [ToolBoxNSO imageWithImage:result scaledToSize:size];
                                                        [self.PoiImageDictionary setObject:image forKey:imgobject.key];
                                                        [self.realm beginWriteTransaction];
                                                        imgobject.UpdateImage = true;
                                                        [self.realm commitWriteTransaction];
                                                    }
                                                    [self.CollectionViewPoiImages reloadData];
                                                });
                                            }];
                                        }
                                    }];
    
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                               NSLog(@"You pressed cancel");
                                                           }];
    
    
    
    [alert addAction:cameraAction];
    [alert addAction:photorollAction];
    [alert addAction:photosCloseToPoiAction];
    if (![self.PointOfInterest.wikititle isEqualToString:@""]) {
        [alert addAction:photoWikiAction];
    }
    [alert addAction:lastphotoAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/*
 created date:      28/04/2018
 last modified:     26/09/2018
 remarks:
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    /* obtain the image from the camera */
   
    // OCR scan
    if (self.imagestate==3) {

        UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
        TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:originalImage];
        cropViewController.delegate = self;
        [picker dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:cropViewController animated:YES completion:nil];
        }];
        
    } else {
        /* normal image from camera */
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        CGSize size;
        if (self.newitem) {
            size = CGSizeMake(self.TextViewNotes.frame.size.width * 2, self.TextViewNotes.frame.size.width *2);
        } else {
            size = CGSizeMake(self.ImagePicture.frame.size.width * 2, self.ImagePicture.frame.size.width *2);
        }
        chosenImage = [ToolBoxNSO imageWithImage:chosenImage scaledToSize:size];
        if (self.imagestate==1) {
            ImageCollectionRLM *imgobject = [[ImageCollectionRLM alloc] init];
            imgobject.key = [[NSUUID UUID] UUIDString];
            
            if (self.PointOfInterest.images.count==0) {
                imgobject.KeyImage = 1;
            } else {
                imgobject.KeyImage = 0;
            }
            
            [self.realm beginWriteTransaction];
            [self.PointOfInterest.images addObject:imgobject];
            [self.realm commitWriteTransaction];
            
            [self.PoiImageDictionary setObject:chosenImage forKey:imgobject.key];
            
        } else if (self.imagestate == 2) {
            ImageCollectionRLM *imgobject = [self.PointOfInterest.images objectAtIndex:[self.SelectedImageIndex longValue]];
            
            [self.realm beginWriteTransaction];
            imgobject.UpdateImage = true;
            [self.realm commitWriteTransaction];
            
            [self.PoiImageDictionary setObject:chosenImage forKey:imgobject.key];
        }
        [self.CollectionViewPoiImages reloadData];
        [picker dismissViewControllerAnimated:YES completion:NULL];
        
    }
    self.imagestate = 0;

}

/*
 created date:      26/09/2018
 last modified:     26/09/2018
 remarks:           TODO - is it worth presenting the black and white image?
 */
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
    tesseract.delegate = self;
    //tesseract.charWhitelist = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'-?@$%&().,:;";

    tesseract.image = [ToolBoxNSO convertImageToGrayScale :image];
    tesseract.maximumRecognitionTime = 20.0;
    [tesseract recognize];

    if (!self.TextViewNotes.selectedTextRange.empty) {
        // use selected position to obtain location where to add the text
        [self.TextViewNotes replaceRange:self.TextViewNotes.selectedTextRange withText:[tesseract recognizedText]];
    } else {
        // append to the end of the detail.
        self.TextViewNotes.text = [NSString stringWithFormat:@"%@\n%@", self.TextViewNotes.text, [tesseract recognizedText]];
    }
    NSLog(@"%@", [tesseract recognizedText]);
    
    [cropViewController dismissViewControllerAnimated:YES completion:NULL];
}

/*
 created date:      21/05/2018
 last modified:     15/03/2019
 remarks: manages the dynamic width of the cells.
 */
-(CGSize)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout* )collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CGSize size;
    if (collectionView == self.CollectionViewPoiImages) {
        size = CGSizeMake(100,100);
    } else {
        return CGSizeMake(self.view.frame.size.height/8,self.view.frame.size.height/8 );
    }
    return size;
}




/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

/*
 created date:      28/04/2018
 last modified:     29/04/2018
 remarks:
 */
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //[self.TextViewNotes endEditing:YES];
    [self.TextFieldTitle endEditing:YES];
}
*/
    
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/*
 created date:      28/04/2018
 last modified:     22/06/2019
 remarks:           
 */
- (IBAction)ActionButtonPressed:(id)sender {

    if (self.newitem) {
        
        /* manage the images if any exist */
        if (self.PointOfInterest.images.count>0) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *imagesDirectory = [paths objectAtIndex:0];

            NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/%@",self.PointOfInterest.key]];
        
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];

            for (ImageCollectionRLM *imgobject in self.PointOfInterest.images) {
                NSData *imageData =  UIImagePNGRepresentation([self.PoiImageDictionary objectForKey:imgobject.key]);
                NSString *filename = [NSString stringWithFormat:@"%@.png", imgobject.key];
                NSString *filepathname = [dataPath stringByAppendingPathComponent:filename];
                [imageData writeToFile:filepathname atomically:YES];
                imgobject.NewImage = true;
                imgobject.ImageFileReference = [NSString stringWithFormat:@"Images/%@/%@",self.PointOfInterest.key,filename];
                
            }
        }
        self.PointOfInterest.authorname = self.Settings.username;
        self.PointOfInterest.authorkey = self.Settings.userkey;
        self.PointOfInterest.name = self.TextFieldTitle.text;
        self.PointOfInterest.privatenotes = self.TextViewNotes.text;
        self.PointOfInterest.modifieddt = [NSDate date];
        self.PointOfInterest.createddt = [NSDate date];
        
        if ([self.SwitchWeather isOn]) {
            self.PointOfInterest.IncludeWeather = [NSNumber numberWithInt:1];
        } else {
            self.PointOfInterest.IncludeWeather = [NSNumber numberWithInt:0];
        }

        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        self.PointOfInterest.radius = [f numberFromString:[self.DistancePickerItems objectAtIndex: [self.PickerDistance selectedRowInComponent:0]]];

        self.PointOfInterest.searchstring =  [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@",self.PointOfInterest.name,self.PointOfInterest.administrativearea,self.PointOfInterest.subadministrativearea,self.PointOfInterest.postcode,self.PointOfInterest.locality,self.PointOfInterest.sublocality,self.PointOfInterest.country];
        
        [self.realm beginWriteTransaction];
        [self.realm addObject:self.PointOfInterest];
        [self.realm commitWriteTransaction];

        if (!self.fromproject) {
            // standard funationality required for POI module
            if (self.fromnearby) {
                [self.delegate didUpdatePoi:@"created" :self.PointOfInterest];
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.delegate didCreatePoiFromProject :self.PointOfInterest];
                [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }
        } else {
            // special functionality needed here for Trip items.  We must present the Activity data entry view
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ActivityDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityDataEntryViewController"];
            controller.delegate = self;
            controller.realm = self.realm;
            controller.Activity = self.ActivityItem;
            controller.Trip = self.TripItem;

            controller.Poi = self.PointOfInterest;
            controller.newitem = true;
            controller.transformed = false;
            controller.deleteitem = false;
            // important property this.  when finally updating the activity, we will use this to go back to the activity-list view
            controller.fromproject = true;
            
            /* manage the Poi Key image */
            NSURL *url = [self applicationDocumentsDirectory];
            NSData *pngData;
            if (self.PointOfInterest.images.count>0) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
                RLMResults *filteredArray = [self.PointOfInterest.images objectsWithPredicate:predicate];
                ImageCollectionRLM *imgobject;
                if (filteredArray.count==0) {
                    imgobject = [self.PointOfInterest.images firstObject];
                } else {
                    imgobject = [filteredArray firstObject];
                }
                NSURL *imagefile = [url URLByAppendingPathComponent:imgobject.ImageFileReference];
                NSError *err;
                pngData = [NSData dataWithContentsOfURL:imagefile options:NSDataReadingMappedIfSafe error:&err];
                UIImage *image;
                if (pngData!=nil) {
                    image =[UIImage imageWithData:pngData];
                }
                else {
                    image = [UIImage systemImageNamed:@"command"];
                }
                
                // save the thumb image to file
                CGSize imagesize = CGSizeMake(100 , 100); // set the width and height
                UIImage *thumbImage = [ToolBoxNSO imageWithImage:image convertToSize:imagesize];
                NSData *imageData =  UIImagePNGRepresentation(thumbImage);
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *imagesDirectory = [paths objectAtIndex:0];
                NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/%@",self.PointOfInterest.key]];
                NSString *thumbImagefilename = @"thumbnail.png";
                NSString *filepathname = [dataPath stringByAppendingPathComponent:thumbImagefilename];
                [imageData writeToFile:filepathname atomically:YES];
                
                [AppDelegateDef.PoiBackgroundImageDictionary setObject:thumbImage forKey:self.PointOfInterest.key];
            }
            
            [controller setModalPresentationStyle:UIModalPresentationFullScreen];
            [self presentViewController:controller animated:YES completion:nil];
        }
    
    } else {
        [self.realm beginWriteTransaction];
        self.PointOfInterest.name = self.TextFieldTitle.text;
        self.PointOfInterest.privatenotes = self.TextViewNotes.text;
        self.PointOfInterest.modifieddt = [NSDate date];
        self.PointOfInterest.searchstring =  [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%@|%@",self.PointOfInterest.name,self.PointOfInterest.administrativearea,self.PointOfInterest.subadministrativearea,self.PointOfInterest.postcode,self.PointOfInterest.locality,self.PointOfInterest.sublocality,self.PointOfInterest.country];
        
        
        if ([self.SwitchWeather isOn]) {
            self.PointOfInterest.IncludeWeather = [NSNumber numberWithInt:1];
        } else {
            self.PointOfInterest.IncludeWeather = [NSNumber numberWithInt:0];
        }
        
        if ([self.PointOfInterest.privatenotes isEqualToString:@""]) {
            
            NSString *Address = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@", self.PointOfInterest.fullthoroughfare, self.PointOfInterest.sublocality, self.PointOfInterest.locality, self.PointOfInterest.administrativearea,   self.PointOfInterest.postcode,self.PointOfInterest.country];
            
            Address  = [Address stringByReplacingOccurrencesOfString:@", (null)" withString:@""];
            Address  = [Address stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
            Address  = [Address stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@"\n"];
            Address  = [Address stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
            Address = [Address stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
            self.PointOfInterest.privatenotes = Address;
        
        }
    
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        self.PointOfInterest.radius = [f numberFromString:[self.DistancePickerItems objectAtIndex: [self.PickerDistance selectedRowInComponent:0]]];
        
        if (self.PointOfInterest.images.count > 0) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *imagesDirectory = [paths objectAtIndex:0];
        
            NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/%@",self.PointOfInterest.key]];
        
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];

            NSInteger count = [self.PointOfInterest.images count];
            //bool NoKeyPhoto = true;
            /* loop through in reverse as it is easier to handle deletions in array */
            for (NSInteger index = (count - 1); index >= 0; index--) {
                ImageCollectionRLM *imgobject = self.PointOfInterest.images[index];
                if (imgobject.ImageFlaggedDeleted) {
                    /* else we are good to delete it */
                    NSString *filepathname = [imagesDirectory stringByAppendingPathComponent:imgobject.ImageFileReference];
                    NSError *error = nil;
                    BOOL success = [fm removeItemAtPath:filepathname error:&error];
                    if (!success || error) {
                        NSLog(@"something failed in deleting unwanted data");
                    }
                    [self.PointOfInterest.images removeObjectAtIndex:index];
                } else if ([imgobject.ImageFileReference isEqualToString:@""] || imgobject.ImageFileReference==nil) {
                    /* here we add the attachment to file system and dB */
                    imgobject.NewImage = true;
                    NSData *imageData =  UIImagePNGRepresentation([self.PoiImageDictionary objectForKey:imgobject.key]);
                    NSString *filename = [NSString stringWithFormat:@"%@.png", imgobject.key];
                    NSString *filepathname = [dataPath stringByAppendingPathComponent:filename];
                    [imageData writeToFile:filepathname atomically:YES];
                    imgobject.ImageFileReference = [NSString stringWithFormat:@"Images/%@/%@",self.PointOfInterest.key,filename];
                    NSLog(@"new image");
                } else if (imgobject.UpdateImage) {
                    /* we might swap it out as user has replaced the original file */
                    NSData *imageData =  UIImagePNGRepresentation([self.PoiImageDictionary objectForKey:imgobject.key]);
                    NSString *filepathname = [imagesDirectory stringByAppendingPathComponent:imgobject.ImageFileReference];
                    [imageData writeToFile:filepathname atomically:YES];
                    imgobject.UpdateImage = false;
                    NSLog(@"updated image");
                }
                
            }
        }
        [self.realm commitWriteTransaction];
        [self.delegate didUpdatePoi:@"modified" :self.PointOfInterest];
        [self dismissViewControllerAnimated:YES completion:Nil];
    }
}

/*
 created date:      28/04/2018
 last modified:     21/05/2018
 remarks:
 */
- (IBAction)UpdatePoiItemPressed:(id)sender {

}

/*
 created date:      28/04/2018
 last modified:     19/02/2019
 remarks:
 */
-(IBAction)SegmentOptionChanged:(id)sender {
    
    UISegmentedControl *segment = sender;
    if (segment.selectedSegmentIndex==0) {
        self.ViewMain.hidden = false;
        self.ViewNotes.hidden = true;
        self.ViewMap.hidden = true;
        self.ViewPhotos.hidden =true;
        self.ViewInfo.hidden = true;
        self.ButtonScan.hidden = false;
        self.ButtonRoute.hidden = true;
        self.SwitchViewPhotoOptions.hidden=true;
        
        self.ButtonWiki.hidden=false;
        self.ButtonSharePoi.hidden=true;
        self.LabelImageOptions.hidden=true;
        if (self.checkInternet) {
            if ([self.PointOfInterest.countrycode isEqualToString:@""] || self.PointOfInterest.countrycode==nil) {
                self.ButtonGeo.hidden = false;
            }
        }
        
     } else if (segment.selectedSegmentIndex==1) {
         self.ViewMain.hidden = true;
         self.ViewNotes.hidden = true;
         self.ViewMap.hidden = false;
         self.ViewPhotos.hidden =true;
         self.ViewInfo.hidden = true;
         self.LabelImageOptions.hidden=true;
         self.SwitchViewPhotoOptions.hidden=true;
         self.ButtonGeo.hidden = true;
         self.ButtonScan.hidden = true;
         self.ButtonRoute.hidden = false;
         self.ButtonWiki.hidden=true;
         self.ButtonSharePoi.hidden=true;
         
        for (id<MKOverlay> overlay in self.MapView.overlays)
        {
            [self.MapView removeOverlay:overlay];
        }
        
        //CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
        
         NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
         f.numberStyle = NSNumberFormatterDecimalStyle;
         NSNumber *radius = [f numberFromString:[self.DistancePickerItems objectAtIndex: [self.PickerDistance selectedRowInComponent:0]]];

         
         
        //NSNumber *radius = [self.TypeDistanceItems objectAtIndex:[self.PointOfInterest.categoryid longValue]];
        
         
         
        [self.MapView setCenterCoordinate:ModifiedCoordinate animated:YES];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(ModifiedCoordinate, [radius doubleValue] * 2.1, [radius doubleValue] * 2.1);
        MKCoordinateRegion adjustedRegion = [self.MapView regionThatFits:viewRegion];
        [self.MapView setRegion:adjustedRegion animated:YES];

        CLLocationDistance RadiusAmt = [radius doubleValue];
        
        self.CircleRange = [MKCircle circleWithCenterCoordinate:ModifiedCoordinate radius:RadiusAmt];
        
        [self.MapView addOverlay:self.CircleRange];
        
        
    } else if (segment.selectedSegmentIndex==2) {
        self.ViewMain.hidden = true;
        self.ViewNotes.hidden = true;
        self.ViewMap.hidden = true;
        self.ViewPhotos.hidden =false;
        self.ViewInfo.hidden = true;
        self.ButtonGeo.hidden = true;
        self.ButtonScan.hidden = true;
        self.ButtonRoute.hidden = true;
        self.ButtonWiki.hidden=true;
        self.ButtonSharePoi.hidden=true;
        
        if (self.PointOfInterest.images.count > 0 && !self.readonlyitem) {
            self.ViewBlurHeightConstraint.constant = 0;
            self.ViewBlurImageOptionPanel.hidden=false;
            self.SwitchViewPhotoOptions.hidden=false;
            self.LabelImageOptions.hidden = false;
        }
    } else {
        /* view info */
        
        self.ViewMain.hidden = true;
        self.ViewNotes.hidden = true;
        self.ViewInfo.hidden = false;
        self.ButtonScan.hidden = true;
        self.ViewMap.hidden = true;
        self.ViewPhotos.hidden =true;
        self.SwitchViewPhotoOptions.hidden=true;
        self.LabelImageOptions.hidden = true;
        self.ButtonGeo.hidden = true;
        self.ButtonRoute.hidden = true;
        self.ButtonWiki.hidden=true;
        self.ButtonSharePoi.hidden=false;
    }
}


-(NSString *)GetPoiLabelWithType :(NSNumber*) PoiType {
    NSString *LabelText;
    
    LabelText = [NSString stringWithFormat:@"Point Of Interest - %@",[self.TypeLabelItems objectAtIndex:[PoiType integerValue]]];
    return LabelText;
}



/*
 created date:      21/05/2018
 last modified:     30/08/2018
 remarks:
 */
- (IBAction)ButtonImageDeletePressed:(id)sender {
    bool DeletedFlagEnabled = false;
    if (self.PointOfInterest.images.count==0) {
        self.ViewBlurImageOptionPanel.hidden = true;
    } else {
        for (ImageCollectionRLM *imgobject in self.PointOfInterest.images) {
           
            if ([imgobject.key isEqualToString:self.SelectedImageKey]) {
                 [self.realm beginWriteTransaction];
                if (imgobject.ImageFlaggedDeleted==0) {
                    //if (item.KeyImage==0) {
                        self.ViewTrash.hidden = false;
                        imgobject.ImageFlaggedDeleted = 1;
                        DeletedFlagEnabled = true;
                        imgobject.UpdateImage = true;
                    //}
                }
                else {
                    self.ViewTrash.hidden = true;
                    imgobject.ImageFlaggedDeleted = 0;
                }
                [self.realm commitWriteTransaction];
            }
            
        }
    }

    
    
}

/*
 created date:      21/05/2018
 last modified:     09/08/2018
 remarks:
 */
- (IBAction)ButtonImageKeyPressed:(id)sender {

    bool KeyImageEnabled = false;
    if (self.PointOfInterest.images.count==0) {
        self.ViewBlurImageOptionPanel.hidden = true;
    } else if (self.PointOfInterest.images.count==1) {
        
    } else {
        [self.realm beginWriteTransaction];
        for (ImageCollectionRLM *imgobject in self.PointOfInterest.images) {
            
            if ([imgobject.key isEqualToString:self.SelectedImageKey]) {
                if (imgobject.KeyImage==0) {
                    self.ViewSelectedKey.hidden = false;
                    imgobject.KeyImage = 1;
                    KeyImageEnabled = true;
                    imgobject.UpdateImage = true;
                    [self.ImageViewKey setImage:self.ImagePicture.image];
                } else {
                    self.ViewSelectedKey.hidden = true;
                    imgobject.KeyImage = 0;
                    imgobject.UpdateImage = true;
                }
            } else {
                if (imgobject.KeyImage == 1) {
                    imgobject.KeyImage = 0;
                    imgobject.UpdateImage = true;
                }
            }
            
        }
        [self.realm commitWriteTransaction];
    }
}

/*
 created date:      11/06/2018
 last modified:     01/09/2018
 remarks:
 */
- (void)didAddImages :(NSMutableArray*)ImageCollection {
    bool AddedImage = false;
    for (ImageNSO *img in ImageCollection) {
    
        ImageCollectionRLM *imgobject = [[ImageCollectionRLM alloc] init];
        imgobject.key = [[NSUUID UUID] UUIDString];
        [self.PoiImageDictionary setObject:img.Image forKey:imgobject.key];
        
        if (self.PointOfInterest.images.count==0) {
            imgobject.KeyImage = 1;
        } else {
            imgobject.KeyImage = 0;
        }
        imgobject.info = img.Description;
        [self.realm beginWriteTransaction];
        [self.PointOfInterest.images addObject:imgobject];
        [self.realm commitWriteTransaction];
        
        AddedImage = true;
    }
    if (AddedImage) {
        [self.CollectionViewPoiImages reloadData];
    }

}

/*
 created date:      13/06/2018
 last modified:     28/03/2019
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if([segue.identifier isEqualToString:@"WikiGenerator"]){
        WikiVC *controller = (WikiVC *)segue.destinationViewController;
        controller.delegate = self;
        
        PoiRLM *poi = [[PoiRLM alloc] init];
        poi.name = self.PointOfInterest.name;
        poi.lat = self.PointOfInterest.lat;
        poi.lon = self.PointOfInterest.lon;
        poi.wikititle = self.PointOfInterest.wikititle;
        poi.countrycode = self.PointOfInterest.countrycode;
        poi.key = self.PointOfInterest.key;
        
        controller.PointOfInterest = poi;
        controller.PointOfInterest.name = self.TextFieldTitle.text;
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        controller.gsradius = [f numberFromString:[self.DistancePickerItems objectAtIndex: [self.PickerDistance selectedRowInComponent:0]]];
        
        //controller.gsradius = [self.TypeDistanceItems objectAtIndex:[self.PointOfInterest.categoryid longValue]];
    } 
}


/*
 created date:      26/09/2018
 last modified:     28/03/2019
 remarks:
 */
- (IBAction)ButtonWikiPressed:(id)sender {

    if (self.SegmentDetailOption.selectedSegmentIndex!=1) {
       
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        WikiVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"WikiViewId"];
        controller.delegate = self;
        
        PoiRLM *poi = [[PoiRLM alloc] init];
        poi.name = self.PointOfInterest.name;
        poi.lat = self.PointOfInterest.lat;
        poi.lon = self.PointOfInterest.lon;
        poi.wikititle = self.PointOfInterest.wikititle;
        poi.key = self.PointOfInterest.key;
        poi.countrycode = self.PointOfInterest.countrycode;
        
        controller.PointOfInterest = poi;
        controller.PointOfInterest.name = self.TextFieldTitle.text;
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        controller.gsradius = [f numberFromString:[self.DistancePickerItems objectAtIndex: [self.PickerDistance selectedRowInComponent:0]]];
        
        
        //controller.gsradius = [self.TypeDistanceItems objectAtIndex:[self.PointOfInterest.categoryid longValue]];
        
        [self presentViewController:controller animated:YES completion:nil];
        
    } else {
        if (![self.PointOfInterest.wikititle isEqualToString:@""]) {
            // add text to notes from wiki page.
  
            NSArray *parms = [self.PointOfInterest.wikititle componentsSeparatedByString:@"~"];
            
            NSString *url = [NSString stringWithFormat:@"https://%@.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=%@",[parms objectAtIndex:0],[parms objectAtIndex:1]];
            
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            /* get data */
            [self fetchFromWikiApi:url withDictionary:^(NSDictionary *data) {
                
                NSDictionary *query = [data objectForKey:@"query"];
                NSDictionary *pages =  [query objectForKey:@"pages"];
                NSArray *keys = [pages allKeys];
                NSDictionary *item =  [pages objectForKey:[keys firstObject]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (!self.TextViewNotes.selectedTextRange.empty) {
                    
                        // use selected position to obtain location where to add the text
                        [self.TextViewNotes replaceRange:self.TextViewNotes.selectedTextRange withText:[item objectForKey:@"extract"]];
                        
                    } else {
                        // we append to the end of the contents.
                        NSString *content = self.TextViewNotes.text;
                        if ([content isEqualToString:@""]) {
                            content = [item objectForKey:@"extract"];
                        } else {
                            content = [NSString stringWithFormat:@"%@\n\n%@", content, [item objectForKey:@"extract"]];
                        }
                        self.TextViewNotes.text = content;
                    }
                });
            }];
            
        }
        
    }
}


/*
 created date:      26/09/2018
 last modified:     26/09/2018
 remarks:           Copied from Nearby View Controller 
 */
-(void)fetchFromWikiApi:(NSString *)url withDictionary:(void (^)(NSDictionary* data))dictionary{
    
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








/*
 created date:      23/05/2018
 last modified:     19/07/2018
 remarks:
 */
- (IBAction)ButtonImageEditPressed:(id)sender {
    self.imagestate = 2;
    [self InsertPoiImage];
}

- (IBAction)SwitchViewPhotoOptionsChanged:(id)sender {
    [self.view layoutIfNeeded];
    bool showkeyview = self.ViewSelectedKey.hidden;
    bool showdeletedflag = self.ViewTrash.hidden;
    self.ViewSelectedKey.hidden = true;
    self.ViewTrash.hidden = true;
    if (self.ViewBlurHeightConstraint.constant==60) {
        
        [UIView animateWithDuration:0.5 animations:^{
            self.ViewBlurHeightConstraint.constant=0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.ViewSelectedKey.hidden = showkeyview;
            self.ViewTrash.hidden = showdeletedflag;
        }];
        
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.ViewBlurHeightConstraint.constant=60;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.ViewSelectedKey.hidden = showkeyview;
            self.ViewTrash.hidden = showdeletedflag;
        }];
    }
}

/*
 created date:      13/07/2018
 last modified:     31/08/2018
 remarks:
 */
- (void)updatePoiFromWikiActvity :(PoiRLM*)Object {

    [self.realm beginWriteTransaction];
    self.PointOfInterest.wikititle = Object.wikititle;
    [self.realm commitWriteTransaction];
    
}

- (void)didCreatePoiFromProject :(PoiRLM*)Object {
}

- (void)didCreatePoiFromNearby {
}

/* Delegate methods for ScrollView */
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [self.ScrollViewImage viewWithTag:5];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
}

-(void)addDoneToolBarToKeyboard:(UITextView *)textView
{
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleDefault;
    [doneToolbar setTintColor:[UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
    
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClickedDismissKeyboard)],
                         nil];
    [doneToolbar sizeToFit];
    textView.inputAccessoryView = doneToolbar;
}

-(void)addDoneToolBarForTextFieldToKeyboard:(UITextField *)textField
{
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleDefault;
    [doneToolbar setTintColor:[UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClickedDismissKeyboard)],
                         nil];
    [doneToolbar sizeToFit];
    textField.inputAccessoryView = doneToolbar;
}


/*
 created date:      15/07/2018
 last modified:     12/08/2018
 remarks:
 */
- (void)didUpdatePoi :(NSString*)Method :(PoiRLM*)Object {
    
}

/*
 created date:      28/04/2018
 last modified:     06/02/2019
 remarks:           BUG WHEN USER CANCELS AFTER ADDING IMAGE IN NEARBY
 */
- (IBAction)BackPressed:(id)sender {

    if (self.newitem) {
        /* remove any wiki document that might be orphaned afterwards */
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        
        NSString *wikiDataFilePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/WikiDocs/%@.pdf",self.PointOfInterest.key]];
        
        NSError *error = nil;
        [fileManager removeItemAtPath:wikiDataFilePath error:&error];
        
        /* manage the images if any exist */
        /*if (self.PointOfInterest.images.count>0) {
         
            [self.realm transactionWithBlock:^{
               [self.realm deleteObjects:self.PointOfInterest.images];
            }];
        }*/
    
    } else {
        
        if (self.PointOfInterest.images.count > 0) {
            
            NSInteger count = [self.PointOfInterest.images count];
            
            [self.realm beginWriteTransaction];
            for (NSInteger index = (count - 1); index >= 0; index--) {
                ImageCollectionRLM *imgobject = self.PointOfInterest.images[index];
                if (imgobject.ImageFlaggedDeleted) {
                    imgobject.ImageFlaggedDeleted = false;
                    NSLog(@"undone deleted image");
                } else if ([imgobject.ImageFileReference isEqualToString:@""] || imgobject.ImageFileReference==nil) {
                    /* here we add the attachment to file system and dB */
                    [self.realm deleteObject:imgobject];
                    NSLog(@"undone new image");
                } else if (imgobject.UpdateImage) {
                    /* we might swap it out as user has replaced the original file */
                    imgobject.UpdateImage = false;
                    NSLog(@"undone updated image");
                }
            }
            [self.realm commitWriteTransaction];
        }

    }
   
    [self dismissViewControllerAnimated:YES completion:Nil];
}

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
 created date:      10/08/2018
 last modified:     20/10/2018
 remarks: TODO add all items that might have originally been added on insert.
 */
- (IBAction)GeoButtonPressed:(id)sender {
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    
    self.Coordinates = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
    
    [geoCoder reverseGeocodeLocation: [[CLLocation alloc] initWithLatitude:self.Coordinates.latitude longitude:self.Coordinates.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", [NSString stringWithFormat:@"%@", error.localizedDescription]);
        } else {
            
           // dispatch_sync(dispatch_get_main_queue(), ^(void){
            
                [self.realm beginWriteTransaction];
                
                if ([placemarks count]>0) {
                    CLPlacemark *placemark = [placemarks firstObject];
                    NSString *AdminArea = placemark.subAdministrativeArea;
                    if ([AdminArea isEqualToString:@""] || AdminArea == NULL) {
                        AdminArea = placemark.administrativeArea;
                    }
                    
                    NSLog(@"%@",placemark);
                    
                    self.PointOfInterest.administrativearea = placemark.administrativeArea;
                    self.PointOfInterest.lat = [NSNumber numberWithDouble:self.Coordinates.latitude];
                    self.PointOfInterest.lon = [NSNumber numberWithDouble:self.Coordinates.longitude];
                    self.PointOfInterest.country = placemark.country;
                    self.PointOfInterest.countrycode = placemark.ISOcountryCode;
                    self.PointOfInterest.locality = placemark.locality;
                    self.PointOfInterest.sublocality = placemark.subLocality;
                    self.PointOfInterest.fullthoroughfare = placemark.thoroughfare;
                    self.PointOfInterest.postcode = placemark.postalCode;
                    self.PointOfInterest.subadministrativearea = placemark.subAdministrativeArea;
                    self.ButtonGeo.hidden = true;
                    /* reset note if it contains autotext detail */

                    [self.TextViewNotes setText:[self.TextViewNotes.text stringByReplacingOccurrencesOfString:@"No GeoData has been supplied except coordinates. Please press 'Geo' button when internet connectivity is next available!" withString:@""]];
                    
                } else {
                    self.PointOfInterest.administrativearea = @"Unknown Place";
                }
                [self.realm commitWriteTransaction];
           
           // });
            
        }
    }];
    
    
}
/*
 created date:      08/09/2018
 last modified:     19/02/2019
 remarks:           Turn this into more like structure used in RLM objects.
 */
- (IBAction)SharePressed:(id)sender {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    
    NSData *ImageData = [[NSData alloc] init];
    NSString *ImageString = [[NSString alloc] init];
    
    ImageCollectionRLM *ImageObject = [[ImageCollectionRLM alloc] init];
    
    if (self.PointOfInterest.images.count==0) {
        ImageObject.key = @"N/A";
    } else {
        for (ImageCollectionRLM *imageitem in self.PointOfInterest.images) {
             if (imageitem.KeyImage) {
                 ImageData = UIImagePNGRepresentation([self.PoiImageDictionary objectForKey:imageitem.key]);
                 ImageString = [ImageData base64EncodedStringWithOptions:0];
                 ImageObject.key = imageitem.key;
                 ImageObject.ImageFileReference = imageitem.ImageFileReference;
                 if (imageitem.info.length>0) ImageObject.info=imageitem.info;
                 break;
            }
        }
    }
    
    NSString *ImageFileDirectory = [NSString stringWithFormat:@"Images/%@",self.PointOfInterest.key];

    PoiRLM *poi = [[PoiRLM alloc] initWithValue:self.PointOfInterest];
    if (poi.name.length==0) poi.name=@"";
    if (poi.countrykey.length==0) poi.countrykey=@"";
    if (poi.country.length==0) poi.country=@"";
    if (poi.countrycode.length==0) poi.countrycode=@"";
    if (poi.administrativearea.length==0) poi.administrativearea=@"";
    if (poi.subadministrativearea.length==0) poi.subadministrativearea=@"";
    if (poi.fullthoroughfare.length==0) poi.fullthoroughfare=@"";
    if (poi.privatenotes.length==0) poi.privatenotes=@"";
    if (poi.locality.length==0) poi.locality=@"";
    if (poi.sublocality.length==0) poi.sublocality=@"";
    if (poi.postcode.length==0) poi.postcode=@"";
    if (poi.wikititle.length==0) poi.wikititle=@"";
    if (poi.searchstring.length==0) poi.searchstring=@"";
    poi.devicesharedby = [[UIDevice currentDevice] name];
    poi.sharedby = self.Settings.username;
    if (poi.authorname.length==0) poi.authorname=@"";
    if (poi.authorkey.length==0) poi.authorkey=@"";
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    //[dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
   
    NSString *ModifiedDt = [dateFormatter  stringFromDate:poi.modifieddt];
    NSString *CreatedDt = [dateFormatter  stringFromDate:poi.createddt];
    NSString *SharedDt = [dateFormatter  stringFromDate:[NSDate date]];
    
    NSDictionary* ImageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                              ImageObject.key,
                              @"Key",
                              ImageObject.ImageFileReference,
                              @"ImageFileReference",
                              ImageFileDirectory,
                              @"Directory",
                              ImageObject.info,
                              @"info",
                              ImageString,
                              @"Image",
                              nil];
    
    
    NSDictionary* PoiDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                poi.key,
                                @"key",
                                poi.name,
                                @"name",
                                poi.categoryid,
                                @"categoryid",
                                poi.countrykey,
                                @"countrykey",
                                poi.country,
                                @"country",
                                poi.countrycode,
                                @"countrycode",
                                poi.administrativearea,
                                @"administrativearea",
                                poi.subadministrativearea,
                                @"subadministrativearea",
                                poi.fullthoroughfare,
                                @"fullthoroughfare",
                                poi.privatenotes,
                                @"privatenotes",
                                poi.locality,
                                @"locality",
                                poi.sublocality,
                                @"sublocality",
                                poi.postcode,
                                @"postcode",
                                poi.wikititle,
                                @"wikititle",
                                poi.searchstring,
                                @"searchstring",
                                poi.lat,
                                @"lat",
                                poi.lon,
                                @"lon",
                                CreatedDt,
                                @"createddt",
                                ModifiedDt,
                                @"modifieddt",
                                SharedDt,
                                @"shareddt",
                                poi.sharedby,
                                @"sharedby",
                                poi.devicesharedby,
                                @"devicesharedby",
                                poi.authorkey,
                                @"authorkey",
                                poi.authorname,
                                @"authorname",
                                ImageDictionary,
                                @"ImageObject",
                                nil];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:PoiDictionary
                                                       options:NSJSONWritingPrettyPrinted error:nil];
   
    NSURL *url = [NSURL fileURLWithPath:imagesDirectory];
    url = [url URLByAppendingPathComponent:@"Poi.trippo"];
    
    [jsonData writeToURL:url atomically:NO];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        //Delete file
        NSError *errorBlock;
        if([[NSFileManager defaultManager] removeItemAtURL:url error:&errorBlock] == NO) {
            return;
        }
    }];

    activityViewController.popoverPresentationController.sourceView = self.view;
    [self presentViewController:activityViewController animated:YES completion:nil];
    
}

/*
 created date:      16/02/2019
 last modified:     16/02/2019
 remarks:
 */
-(NSString*)FormatPrettyDate :(NSDate*)Dt {
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"EEE, dd MMM yyyy"];
   // NSDateFormatter *timeformatter = [[NSDateFormatter alloc] init];
   // [timeformatter setDateFormat:@"HH:mm"];
    return [NSString stringWithFormat:@"%@",[dateformatter stringFromDate:Dt]];
}

/*
 created date:      25/09/2018
 last modified:     25/09/2018
 remarks:           OCR obtain image and scan for text
 */
- (IBAction)ScanImagePressed:(id)sender {
    
    self.imagestate=3;
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Device has no camera" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert.view setTintColor:[UIColor labelColor]];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];

    }else
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;

        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

/*
 created date:      17/02/2019
 last modified:     17/02/2019
 remarks:           resizes the textview control to allow for keyboard view.
 */
- (void) handleKeyboardWillShow:(NSNotification *)paramNotification{
    
    NSValue *keyboardRectAsObject =
    [[paramNotification userInfo]
     objectForKey:UIKeyboardFrameEndUserInfoKey];

    CGRect keyboardRect = CGRectZero;
    [keyboardRectAsObject getValue:&keyboardRect];
    self.ContraintBottomNotes.constant = keyboardRect.size.height - 132;
    
    [self.TextViewNotes scrollRangeToVisible:self.TextViewNotes.selectedRange];
    [self.TextViewNotes setNeedsDisplay];
}


- (void)didUpdateActivityImages :(bool) ForceUpdate {
    
}

- (IBAction)ButtonRoutePressed:(id)sender {

    if (self.PointOfInterest == nil) {
        return;
    }
    
    NSString *messageText = [[NSString alloc] init];
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    messageText = [NSString stringWithFormat:@"Choose the map you wish to present and calculate selected route between your current position and %@", self.PointOfInterest.name];
    
    UIAlertController * alertPickMapEngine = [UIAlertController
                                              alertControllerWithTitle:@"Which Map?"
                                              message:messageText
                                              preferredStyle:UIAlertControllerStyleAlert];
    
   
    [alertPickMapEngine.view setTintColor:[UIColor labelColor]];
    
    UIAlertAction* actionApple = [UIAlertAction
                                  actionWithTitle:@"Apple Maps"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      
                                      NSString* directionsURL;
                                      
                                    directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%@,%@",self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude, self.PointOfInterest.lat, self.PointOfInterest.lon];
                                      
                                      if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                                          [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL] options:@{} completionHandler:^(BOOL success) {}];
                                      }
                                      
                                      
                                      
                                  }];
    
    [alertPickMapEngine addAction:actionApple];
    
    UIAlertAction* actionGoogle = [UIAlertAction
                                   actionWithTitle:@"Google Maps"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       
                                       NSString *directionsURL;
                                       
                                  
                                       directionsURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%@,%@",self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude, self.PointOfInterest.lat, self.PointOfInterest.lon];
                                   
                                       if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                                       
                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL] options:@{} completionHandler:^(BOOL success) {}];
                                       
                                       }

                                   }];
    
    [alertPickMapEngine addAction:actionGoogle];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                         }];
    
    [alertPickMapEngine addAction:cancelAction];
    [self presentViewController:alertPickMapEngine animated:YES completion:nil];

}

/*
 created date:      28/07/2019
 last modified:     28/07/2019
 remarks:
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    [self.locationManager stopUpdatingLocation];
    PoiRLM *mylocation = [[PoiRLM alloc] init];
    
    mylocation.name = @"My Current Location";
    mylocation.lat = [NSNumber numberWithDouble: self.locationManager.location.coordinate.latitude];
    mylocation.lon = [NSNumber numberWithDouble:self.locationManager.location.coordinate.longitude];
    mylocation.administrativearea = @"";
    
    self.MyCurrentPosition = mylocation;
}


@end
