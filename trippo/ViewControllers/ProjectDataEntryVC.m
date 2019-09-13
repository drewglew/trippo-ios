//
//  ProjectDataEntry.m
//  travelme
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ProjectDataEntryVC.h"

@interface ProjectDataEntryVC ()

@end

@implementation ProjectDataEntryVC
@synthesize delegate;
BOOL loadedActualWeatherData = false;
BOOL loadedPlannedWeatherData = false;

/*
 created date:      29/04/2018
 last modified:     15/08/2019
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    self.timezones = [NSTimeZone knownTimeZoneNames];
    
    self.StartDtTimeZonePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.StartDtTimeZonePicker.delegate = self;
    self.StartDtTimeZonePicker.dataSource = self;

    self.EndDtTimeZonePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.EndDtTimeZonePicker.delegate = self;
    self.EndDtTimeZonePicker.dataSource = self;

    self.DefaultDtTimeZonePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.DefaultDtTimeZonePicker.delegate = self;
    self.DefaultDtTimeZonePicker.dataSource = self;
    
    self.TextFieldStartDt.delegate = self;
   
    self.TextFieldEndDt.delegate = self;

    self.loadedActualWeatherData = false;
    self.loadedPlannedWeatherData = false;
    // Do any additional setup after loading the view.
    if (!self.newitem) {
        [self.ButtonAction setTitle:@"Update" forState:UIControlStateNormal];
        [self LoadExistingData];
        self.updatedimage = false;
 
    }

    [self addDoneToolBarToKeyboard:self.TextViewNotes];
    self.TextViewNotes.delegate = self;
    
    [self addDoneToolBarForTextFieldToKeyboard: self.TextFieldName];
    self.TextFieldName.delegate = self;
    self.MapView.delegate = self;
    
    self.TextViewNotes.layer.cornerRadius=8.0f;
    self.TextViewNotes.layer.masksToBounds=YES;
    
    self.ViewSummary.layer.cornerRadius=8.0f;
    self.ViewSummary.layer.masksToBounds=YES;
    
    NSDate *startOfToday = [[NSDate alloc] init];
    
    NSTimeZone *defaultTimeZone = [NSTimeZone defaultTimeZone];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    /* if a new trip, set both start & end dates to today at 00:00  */
    if (self.newitem) {
        
        [cal setTimeZone:defaultTimeZone];
        startOfToday = [cal startOfDayForDate:[NSDate date]];
        self.StartDtTimeZoneNameTextField.text = [NSString stringWithFormat:@"%@",[defaultTimeZone name]];
        self.EndDtTimeZoneNameTextField.text = [NSString stringWithFormat:@"%@",[defaultTimeZone name]];
        self.DefaultTimeZoneNameTextField.text = [NSString stringWithFormat:@"%@",[defaultTimeZone name]];
        self.startDt = startOfToday;
        self.endDt = startOfToday;
    } else {
        self.startDt = self.Trip.startdt;
        self.endDt = self.Trip.enddt;
    }
    
    
    /* initialize the datePicker for start dt */
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [self.datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    
    if (self.newitem) {
        self.Trip.startdt = startOfToday;
        self.Trip.enddt = startOfToday;
    }
    [self.datePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];

    /* add toolbar control for 'Done' option */
    UIToolbar *toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
   // [toolBar setTintColor:[UIColor grayColor]];
    
    [toolBar setTintColor:[UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
    
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(HidePickers)];
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];

    /* extend features on the input view of the text field for start dt */
    self.TextFieldStartDt.inputView = self.datePicker;
    self.TextFieldStartDt.text = [NSString stringWithFormat:@"%@", [self FormatPrettyDate :self.startDt :[NSTimeZone timeZoneWithName:self.StartDtTimeZoneNameTextField.text] :@" "]];
    [self.TextFieldStartDt setInputAccessoryView:toolBar];

    /* extend features on the input view of the text field for end dt */
    self.TextFieldEndDt.inputView = self.datePicker;
    self.TextFieldEndDt.text = [NSString stringWithFormat:@"%@", [self FormatPrettyDate :self.endDt :[NSTimeZone timeZoneWithName:self.EndDtTimeZoneNameTextField.text] :@" "]];
    [self.TextFieldEndDt setInputAccessoryView:toolBar];

    /* add toolbar control for 'Done' option */
    
    self.StartDtTimeZoneNameTextField.inputView = self.StartDtTimeZonePicker;
    [self.StartDtTimeZoneNameTextField setInputAccessoryView:toolBar];
    
    self.EndDtTimeZoneNameTextField.inputView = self.EndDtTimeZonePicker;
    [self.EndDtTimeZoneNameTextField setInputAccessoryView:toolBar];
    
    self.DefaultTimeZoneNameTextField.inputView = self.DefaultDtTimeZonePicker;
    [self.DefaultTimeZoneNameTextField setInputAccessoryView:toolBar];

    
    NSInteger anIndex=[self.timezones indexOfObject:self.StartDtTimeZoneNameTextField.text];
    [self.StartDtTimeZonePicker selectRow:anIndex inComponent:0 animated:YES];
    
    anIndex=[self.timezones indexOfObject:self.EndDtTimeZoneNameTextField.text];
     [self.EndDtTimeZonePicker selectRow:anIndex inComponent:0 animated:YES];
    
    anIndex=[self.timezones indexOfObject:self.DefaultTimeZoneNameTextField.text];
    [self.DefaultDtTimeZonePicker selectRow:anIndex inComponent:0 animated:YES];
    
    
    [self registerForKeyboardNotifications];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.timezones.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    
    return [self.timezones objectAtIndex:row];
    
    //[[self.timezones objectAtIndex:row] name];
}

/*
 created date:      07/04/2019
 last modified:     15/08/2019
 remarks:
 */
- (void)pickerView:(UIPickerView *)thePickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
     
    
    if (thePickerView == self.StartDtTimeZonePicker) {
        self.StartDtTimeZoneNameTextField.text = [self.timezones objectAtIndex: row];
        self.TextFieldStartDt.text = [NSString stringWithFormat:@"%@", [self FormatPrettyDate :self.startDt :[NSTimeZone timeZoneWithName:self.StartDtTimeZoneNameTextField.text] :@" "]];
        
    } else if (thePickerView == self.EndDtTimeZonePicker) {
        self.EndDtTimeZoneNameTextField.text = [self.timezones objectAtIndex: row];
        self.TextFieldEndDt.text = [NSString stringWithFormat:@"%@", [self FormatPrettyDate :self.endDt :[NSTimeZone timeZoneWithName:self.EndDtTimeZoneNameTextField.text] :@" "]];
        
    } else {
        self.DefaultTimeZoneNameTextField.text = [self.timezones objectAtIndex: row];
    }
    
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
    
   
    self.SegmentAnnotations.selectedSegmentTintColor = [UIColor colorNamed:@"TrippoColor"];
    [self.SegmentAnnotations setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor systemBackgroundColor], NSFontAttributeName: [UIFont systemFontOfSize:13]} forState:UIControlStateSelected];
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.TripScrollView.contentSize = CGSizeMake(self.TripScrollView.frame.size.width, self.TripScrollViewContent.frame.size.height);
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
    self.TripScrollView.contentInset = contentInsets;
    self.TripScrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height + 50.0;
    if (!CGRectContainsPoint(aRect, self.ActiveTextField.frame.origin) && self.ActiveTextView == nil ) {
        NSLog(@"contentsize=%f,%f",self.TripScrollView.contentSize.height, self.TripScrollView.contentSize.width);
        
        //CGRect aRectTextField = CGRectMake(self.ActiveTextField.frame.origin.x, self.ActiveTextField.frame.origin.y, self.ActiveTextField.frame.size.width, self.ActiveTextField.frame.size.height - aRect.size.height);
        
        [self.TripScrollView scrollRectToVisible:self.ActiveTextField.frame animated:YES];
    } else if (!CGRectContainsPoint(aRect, self.ActiveTextView.frame.origin) && self.ActiveTextField == nil ) {
        NSLog(@"contentsize=%f,%f",self.TripScrollView.contentSize.height, self.TripScrollView.contentSize.width);
        
        // height of keyboard + height of textview

        //CGRect aRectTextView = CGRectMake(self.ActiveTextView.frame.origin.x, self.ActiveTextView.frame.origin.y, self.ActiveTextView.frame.size.width, self.view.frame.size.height - self.ActiveTextView.frame.origin.y + 50);
        [self.TripScrollView scrollRectToVisible:self.ActiveTextView.frame animated:YES];
        
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.TripScrollView.contentInset = contentInsets;
    self.TripScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.ActiveTextField = textField;
    
    if (textField == self.TextFieldStartDt) {
        self.datePicker.timeZone = [NSTimeZone timeZoneWithName:self.StartDtTimeZoneNameTextField.text];
        self.datePicker.date = self.startDt;
    } else if (textField == self.TextFieldEndDt) {
        self.datePicker.timeZone = [NSTimeZone timeZoneWithName:self.EndDtTimeZoneNameTextField.text];
        self.datePicker.date = self.endDt;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.ActiveTextField = nil;
}

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
    [self.TextFieldName resignFirstResponder];
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

/*
 created date:      14/06/2019
 last modified:     14/06/2019
 */
- (bool)checkInternet
{
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] == NotReachable)
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
created date:      14/06/2019
last modified:     25/08/2019
remarks:
*/
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
    
     MKMarkerAnnotationView *pinView = (MKMarkerAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    
    AnnotationMK *myAnnotation = (AnnotationMK*) annotation;
    
    if (!pinView) {
        pinView = [[MKMarkerAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"];
        pinView.canShowCallout = YES;
    } else {
        pinView.annotation = annotation;
    }
    
    if ([myAnnotation.Type isEqualToString:@"marker-actual"]) {
        pinView.markerTintColor = [UIColor colorNamed:@"TrippoColor"];
    } else if ([myAnnotation.Type isEqualToString:@"marker-planned"]) {
        pinView.markerTintColor = [UIColor systemIndigoColor];
        
    } else {
        UIImageView *Weather = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,30,30)];
        
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:30.0f];
        Weather.image = [UIImage systemImageNamed:myAnnotation.Type withConfiguration:config];
        
        pinView.rightCalloutAccessoryView = Weather;
        [pinView.rightCalloutAccessoryView setTintColor:[UIColor colorNamed:@"TrippoColor"]];
        
    }
    
    return pinView;
}


/*
 created date:      08/05/2018
 last modified:     08/05/2018
 remarks:
 */
- (void) zoomToAnnotationsBounds:(NSArray *)annotations {
    
    CLLocationDegrees minLatitude = DBL_MAX;
    CLLocationDegrees maxLatitude = -DBL_MAX;
    CLLocationDegrees minLongitude = DBL_MAX;
    CLLocationDegrees maxLongitude = -DBL_MAX;
    
    for (AnnotationMK *annotation in annotations) {
        double annotationLat = annotation.coordinate.latitude;
        double annotationLong = annotation.coordinate.longitude;
        minLatitude = fmin(annotationLat, minLatitude);
        maxLatitude = fmax(annotationLat, maxLatitude);
        minLongitude = fmin(annotationLong, minLongitude);
        maxLongitude = fmax(annotationLong, maxLongitude);
    }
    
    // See function below
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
    
    // If your markers were 40 in height and 20 in width, this would zoom the map to fit them perfectly. Note that there is a bug in mkmapview's set region which means it will snap the map to the nearest whole zoom level, so you will rarely get a perfect fit. But this will ensure a minimum padding.
    UIEdgeInsets mapPadding = UIEdgeInsetsMake(40.0, 40.0, 40.0, 40.0);
    CLLocationCoordinate2D relativeFromCoord = [self.MapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.MapView];
    
    // Calculate the additional lat/long required at the current zoom level to add the padding
    CLLocationCoordinate2D topCoord = [self.MapView convertPoint:CGPointMake(0, mapPadding.top) toCoordinateFromView:self.MapView];
    CLLocationCoordinate2D rightCoord = [self.MapView convertPoint:CGPointMake(0, mapPadding.right) toCoordinateFromView:self.MapView];
    CLLocationCoordinate2D bottomCoord = [self.MapView convertPoint:CGPointMake(0, mapPadding.bottom) toCoordinateFromView:self.MapView];
    CLLocationCoordinate2D leftCoord = [self.MapView convertPoint:CGPointMake(0, mapPadding.left) toCoordinateFromView:self.MapView];
    
    double latitudeSpanToBeAddedToTop = relativeFromCoord.latitude - topCoord.latitude;
    double longitudeSpanToBeAddedToRight = relativeFromCoord.latitude - rightCoord.latitude;
    double latitudeSpanToBeAddedToBottom = relativeFromCoord.latitude - bottomCoord.latitude;
    double longitudeSpanToBeAddedToLeft = relativeFromCoord.latitude - leftCoord.latitude;
    
    maxLatitude = maxLatitude + latitudeSpanToBeAddedToTop;
    minLatitude = minLatitude - latitudeSpanToBeAddedToBottom;
    
    maxLongitude = maxLongitude + longitudeSpanToBeAddedToRight;
    minLongitude = minLongitude - longitudeSpanToBeAddedToLeft;
    
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
}

-(void) setMapRegionForMinLat:(double)minLatitude minLong:(double)minLongitude maxLat:(double)maxLatitude maxLong:(double)maxLongitude {
    
    MKCoordinateRegion region;
    region.center.latitude = (minLatitude + maxLatitude) / 2;
    region.center.longitude = (minLongitude + maxLongitude) / 2;
    region.span.latitudeDelta = (maxLatitude - minLatitude);
    region.span.longitudeDelta = (maxLongitude - minLongitude);
    
    // MKMapView BUG: this snaps to the nearest whole zoom level, which is wrong- it doesn't respect the exact region you asked for. See http://stackoverflow.com/questions/1383296/why-mkmapview-region-is-different-than-requested
    [self.MapView setRegion:region animated:NO];
}


/*
 created date:      16/02/2019
 last modified:     16/08/2019
 remarks:
 */
-(NSString*)FormatPrettyDate :(NSDate*)Dt :(NSTimeZone*)TimeZone :(NSString*) delimiter {
    
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"EEE, dd MMM yyyy"];
    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:TimeZone.secondsFromGMT];
    
    NSDateFormatter *dft = [NSDateFormatter new];
    [dft setDateFormat:@"HH:mm"];
    dft.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:TimeZone.secondsFromGMT];
    
    return [NSString stringWithFormat:@"%@ %@",[df stringFromDate:Dt], [dft stringFromDate:Dt]];
}




/*
 created date:      16/02/2019
 last modified:     17/08/2019
 remarks:
 */
- (void)HidePickers
{
    [self.TextFieldStartDt resignFirstResponder];
    [self.TextFieldEndDt resignFirstResponder];
    [self.StartDtTimeZoneNameTextField resignFirstResponder];
    [self.EndDtTimeZoneNameTextField resignFirstResponder];
    
    if ([self.DefaultTimeZoneNameTextField isFirstResponder]) {
        [self.DefaultTimeZoneNameTextField resignFirstResponder];
        if (![self.DefaultTimeZoneNameTextField.text isEqualToString:self.StartDtTimeZoneNameTextField.text] || ![self.DefaultTimeZoneNameTextField.text isEqualToString:self.EndDtTimeZoneNameTextField.text]) {
        
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Trip Time Zones"
                                          message:[NSString stringWithFormat:@"Do you want to also set the start & end Time Zones to the default '%@'?", self.DefaultTimeZoneNameTextField.text]
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            
            [alert.view setTintColor:[UIColor labelColor]];
            
            UIAlertAction* yes = [UIAlertAction
                                 actionWithTitle:@"Yes"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                    self.StartDtTimeZoneNameTextField.text =   self.DefaultTimeZoneNameTextField.text;
                
                                    self.EndDtTimeZoneNameTextField.text =   self.DefaultTimeZoneNameTextField.text;
                
                                    NSInteger anIndex=[self.timezones indexOfObject:self.StartDtTimeZoneNameTextField.text];
                                       [self.StartDtTimeZonePicker selectRow:anIndex inComponent:0 animated:YES];
                                       
                                    anIndex=[self.timezones indexOfObject:self.EndDtTimeZoneNameTextField.text];
                                        [self.EndDtTimeZonePicker selectRow:anIndex inComponent:0 animated:YES];
                                    
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                      
                                 }];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"No"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                                                
                                    }];
             
            [alert addAction:yes];
            [alert addAction:cancel];
             
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    
}





/*
 created date:      16/02/2019
 last modified:     15/08/2019
 remarks:
 */
- (void)onDatePickerValueChanged:(UIDatePicker *)datePicker
{
    NSTimeZone *timeZoneStartDp = [NSTimeZone timeZoneWithName:self.StartDtTimeZoneNameTextField.text];
    NSTimeZone *timeZoneEndDp = [NSTimeZone timeZoneWithName:self.EndDtTimeZoneNameTextField.text];
    
    if (self.ActiveTextField == self.TextFieldStartDt) {
    
        self.startDt = datePicker.date;
        self.ActiveTextField.text = [self FormatPrettyDate:datePicker.date :timeZoneStartDp :@" "];
    
    
        NSComparisonResult result = [datePicker.date compare:self.endDt];
    
        switch (result)
        {
            case NSOrderedDescending:
                NSLog(@"%@ is in future from %@", datePicker.date, self.endDt);
                self.endDt = datePicker.date;
                self.TextFieldEndDt.text = [self FormatPrettyDate:datePicker.date :timeZoneEndDp :@" "];
                break;
            case NSOrderedAscending: NSLog(@"%@ is in past from %@", datePicker.date, self.endDt); break;
            case NSOrderedSame: NSLog(@"%@ is the same as %@", datePicker.date, self.endDt); break;
            default: NSLog(@"erorr dates %@, %@", datePicker.date, self.endDt); break;
        }
       
    } else if (self.ActiveTextField == self.TextFieldEndDt) {
        
        self.endDt = datePicker.date;
        self.TextFieldEndDt.text = [self FormatPrettyDate:datePicker.date :timeZoneEndDp :@" "];
        
        NSComparisonResult result = [datePicker.date compare: self.startDt];
        
        switch (result)
        {
            case NSOrderedAscending:
                NSLog(@"%@ is in future from %@", self.datePicker.date, self.startDt);
                self.startDt = datePicker.date;
                self.TextFieldStartDt.text = [self FormatPrettyDate:datePicker.date :timeZoneStartDp :@" "];
                break;
            case NSOrderedDescending:
                NSLog(@"%@ is in past from %@", self.startDt, datePicker.date);
                
                break;
            case NSOrderedSame: NSLog(@"%@ is the same as %@", self.startDt, datePicker.date); break;
            default: NSLog(@"erorr dates %@, %@", self.startDt, datePicker.date); break;
        }
        
    }
    
}







/*
 created date:      29/04/2018
 last modified:     14/08/2019
 remarks:
 */
-(void) LoadExistingData {
    
    self.TextFieldName.text = self.Trip.name;
    self.TextViewNotes.text = self.Trip.privatenotes;

    
    if (self.Trip.startdttimezonename == nil) {
        NSTimeZone *defaultTimeZone = [NSTimeZone defaultTimeZone];
        self.StartDtTimeZoneNameTextField.text = [NSString stringWithFormat:@"%@",[defaultTimeZone name]];
        self.EndDtTimeZoneNameTextField.text = [NSString stringWithFormat:@"%@",[defaultTimeZone name]];
        self.DefaultTimeZoneNameTextField.text = [NSString stringWithFormat:@"%@",[defaultTimeZone name]];
    } else {
        self.StartDtTimeZoneNameTextField.text = self.Trip.startdttimezonename;
        self.EndDtTimeZoneNameTextField.text = self.Trip.enddttimezonename;
        self.DefaultTimeZoneNameTextField.text = self.Trip.defaulttimezonename;
    }
    
    
    NSDateFormatter *dtformatter = [[NSDateFormatter alloc] init];
    [dtformatter setDateFormat:@"EEE, dd MMM yyyy HH:mm"];

    
    NSMeasurementFormatter *formatter = [[NSMeasurementFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    NSNumberFormatter *numberformatter = [[NSNumberFormatter alloc] init];
    [numberformatter setMaximumFractionDigits:1];
    [formatter setNumberFormatter:numberformatter];
 
   
    NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
    dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
    dateComponentsFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
     
    
    if (self.Trip.routeactualcalculateddt==nil) {
        self.LabelActCalcDist.hidden = true;
        self.LabelActCalcTravelTime.hidden = true;
        self.LabelActCalcTitle.hidden = false;
        self.LabelActCalcTitle.text = @"No summary for Actual trip available";
    } else {
        self.LabelActCalcDist.hidden = false;
        self.LabelActCalcTravelTime.hidden = false;
        self.LabelActCalcTitle.hidden = false;
        self.LabelActCalcTitle.text = [NSString stringWithFormat:@"Actual Summary generated on:\n%@",[dtformatter stringFromDate:self.Trip.routeactualcalculateddt]];
        
        NSMeasurement *accumdistance = [[NSMeasurement alloc] initWithDoubleValue:[self.Trip.routeactualtotaltraveldistance doubleValue] unit:NSUnitLength.meters];
        self.LabelActCalcDist.text = [NSString stringWithFormat:@"%@",[formatter stringFromMeasurement:accumdistance]];
        
        self.LabelActCalcTravelTime.text = [dateComponentsFormatter stringFromTimeInterval:[self.Trip.routeactualtotaltravelminutes longValue]];
        
    }
    if (self.Trip.routeplannedcalculateddt==nil) {
        self.LabelEstCalcDist.hidden = true;
        self.LabelEstCalcTravelTime.hidden = true;
        self.LabelEstCalcTitle.hidden = false;
        self.LabelEstCalcTitle.text = @"No summary for Planned trip available";
    } else {
        self.LabelEstCalcDist.hidden = false;
        self.LabelEstCalcTravelTime.hidden = false;
        self.LabelEstCalcTitle.hidden = false;
        self.LabelEstCalcTitle.text = [NSString stringWithFormat:@"Planned Summary generated on:\n%@",[dtformatter stringFromDate:self.Trip.routeplannedcalculateddt]];
       
        NSMeasurement *accumdistance = [[NSMeasurement alloc] initWithDoubleValue:[self.Trip.routeplannedtotaltraveldistance  doubleValue] unit:NSUnitLength.meters];
        self.LabelEstCalcDist.text = [NSString stringWithFormat:@"%@",[formatter stringFromMeasurement:accumdistance]];
        
        self.LabelEstCalcTravelTime.text = [dateComponentsFormatter stringFromTimeInterval:[self.Trip.routeplannedtotaltravelminutes longValue]];
        
    }
   
    /* generate the flags */
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    RLMResults <ActivityRLM*> *activities = [ActivityRLM objectsWhere:@"tripkey = %@",self.Trip.key];
    
    for (ActivityRLM *activity in activities) {
        if (activity.poi != nil && activity.poi.countrycode != nil && ![activity.poi.countrycode isEqualToString:@""]) {
            [dictionary setObject:[self emojiFlagForISOCountryCode:activity.poi.countrycode] forKey:activity.poi.countrycode];
        }
    }
    
    for(id key in dictionary) {
        self.LabelFlags.text = [NSString stringWithFormat:@"%@ %@",self.LabelFlags.text,[dictionary objectForKey:key]];
    }
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    
    ImageCollectionRLM *image = [self.Trip.images firstObject];
    NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",image.ImageFileReference]];
    NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
    if (pngData!=nil) {
        self.ImageViewProject.image = [UIImage imageWithData:pngData];
    } else {
        [self.ImageViewProject setImage:[UIImage imageNamed:@"Project"]];
    }
}
/*
- (NSString *)stringFromTimeInterval:(NSNumber*)interval {
    long ti = [interval longValue];
    long seconds = ti % 60;
    long minutes = (ti / 60) % 60;
    long hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}
*/

/*
 created date:      29/04/2018
 last modified:     14/08/2019
 remarks:
 */
- (IBAction)ProjectActionPressed:(id)sender {
    
    
    
    NSString *prettystartdt = [self FormatPrettyDate :self.startDt :[NSTimeZone timeZoneWithName:self.StartDtTimeZoneNameTextField.text] :@"\n"];
    NSString *prettyenddt = [self FormatPrettyDate :self.endDt:[NSTimeZone timeZoneWithName:self.StartDtTimeZoneNameTextField.text] :@"\n"];

    // first validation round is between the 2 dates on this page.
    NSComparisonResult result = [self.startDt compare:self.endDt];
    
    NSString *AlertMessage = [[NSString alloc] init];
    
    switch (result)
    {
        case NSOrderedDescending:
            AlertMessage = [NSString stringWithFormat:@"The start date %@ cannot be after the end date %@. \nPlease correct.", prettystartdt, prettyenddt];
            break;
        case NSOrderedAscending:
            // all good!!
            break;
        case NSOrderedSame:
            AlertMessage = [NSString stringWithFormat:@"The start date %@ cannot be the same as the end date.\nPlease correct", prettystartdt];
            break;
        default:
            NSLog(@"error dates %@, %@", self.startDt, self.endDt);
            break;
    }
    
    if (![AlertMessage isEqualToString:@""])  {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Error in dates chosen"
                                     message:AlertMessage
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        
        [alert.view setTintColor:[UIColor labelColor]];
        
        UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {

                                    }];
        
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
        int StartDtsAmendedCount = 0;
        int EndDtsAmendedCount = 0;
        int DraftAmendedCount = 0;
        
        /* ERROR */

        RLMResults <ActivityRLM*> *plannedactivities = [ActivityRLM objectsWhere:@"tripkey=%@ and state=0",self.Trip.key];
       
        if (plannedactivities.count==0) {
            [self UpdateTripRealmData];
        } else {
            
            for (ActivityRLM* activity in plannedactivities) {
               
                NSDate *activitystartdt = activity.startdt;
                NSDate *activityenddt = activity.enddt;
                
                NSComparisonResult resultstartdt = [self.Trip.startdt compare:activitystartdt];
                NSComparisonResult resultenddt = [self.Trip.enddt compare:activityenddt];
                
                if (resultstartdt == NSOrderedSame && resultenddt == NSOrderedSame) {
                    DraftAmendedCount ++;
                } else if (resultstartdt == NSOrderedDescending && resultenddt == NSOrderedSame) {
                    StartDtsAmendedCount ++;
                } else if (resultstartdt == NSOrderedSame && resultenddt == NSOrderedAscending) {
                    EndDtsAmendedCount ++;
                }
            }
            
            if (DraftAmendedCount + StartDtsAmendedCount + EndDtsAmendedCount > 0)  {

                UIAlertController * alertInfo = [UIAlertController
                                             alertControllerWithTitle:@"Information"
                                             message:[NSString stringWithFormat:@"This update will adjust %d draft items, %d start dates and %d end dates inside activities. Are you sure you want to make this change?", DraftAmendedCount, StartDtsAmendedCount, EndDtsAmendedCount]
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                
                [alertInfo.view setTintColor:[UIColor labelColor]];
                
                UIAlertAction* yesButton = [UIAlertAction
                                           actionWithTitle:@"Yes"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               
                                               for (ActivityRLM* activity in plannedactivities) {
                                                   
                                                   NSDate *activitystartdt = activity.startdt;
                                                   NSDate *activityenddt = activity.enddt;
                                                   
                                                   NSComparisonResult resultstartdt = [self.Trip.startdt compare:activitystartdt];
                                                   NSComparisonResult resultenddt = [self.Trip.enddt compare:activityenddt];
                                                   
                                                   if (resultstartdt == NSOrderedSame && resultenddt == NSOrderedSame) {
                                                       [activity.realm beginWriteTransaction];
                                                       activity.startdt = self.startDt;
                                                       activity.enddt = self.endDt;
                                                       [activity.realm commitWriteTransaction];
                                                      
                                                   } else if (resultstartdt == NSOrderedDescending  && resultenddt == NSOrderedSame) {
                                                       [activity.realm beginWriteTransaction];
                                                       activity.startdt = self.startDt;
                                                       if ([self.startDt compare:activityenddt] == NSOrderedAscending)
                                                       {
                                                            activity.enddt = self.startDt;
                                                       }
                                                       [activity.realm commitWriteTransaction];
                                                   } else if (resultstartdt == NSOrderedSame && resultenddt == NSOrderedAscending) {
                                                       [activity.realm beginWriteTransaction];
                                                       activity.enddt = self.endDt;
                                                       if ([self.endDt compare:activitystartdt] == NSOrderedDescending)
                                                       {
                                                           activity.startdt = self.endDt;
                                                       }
                                                       [activity.realm commitWriteTransaction];
                                                   }
                                               }
                                               
                                               [self UpdateTripRealmData];
                                           }];
                
                UIAlertAction* noButton = [UIAlertAction
                                           actionWithTitle:@"No"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               
                                           }];
                
                
                [alertInfo addAction:yesButton];
                [alertInfo addAction:noButton];
                
                [self presentViewController:alertInfo animated:YES completion:nil];
            } else {
                
                [self UpdateTripRealmData];
            }
        }
    }
}


/*
 created date:      21/02/2019
 last modified:     14/08/2019
 remarks:
 */
- (void)UpdateTripRealmData
{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    
    if (self.newitem) {
        
        // new item
        
        self.Trip.key = [[NSUUID UUID] UUIDString];
        if (self.updatedimage) {
            
            NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/Trips/%@",self.Trip.key]];
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
            NSData *imageData =  UIImagePNGRepresentation(self.ImageViewProject.image);
            
            NSString *filepathname = [dataPath stringByAppendingPathComponent:@"image.png"];
            [imageData writeToFile:filepathname atomically:YES];
            
            ImageCollectionRLM *image = [[ImageCollectionRLM alloc] init];
            image.ImageFileReference = [NSString stringWithFormat:@"Images/Trips/%@/image.png",self.Trip.key];
            [self.Trip.images addObject:image];
            
        } else {
            // just set the single placeholder for the trip
            ImageCollectionRLM *image = [[ImageCollectionRLM alloc] init];
            image.ImageFileReference = @"";
            [self.Trip.images addObject:image];
        }
        
        self.Trip.name = self.TextFieldName.text;
        self.Trip.privatenotes = self.TextViewNotes.text;
        self.Trip.modifieddt = [NSDate date];
        self.Trip.createddt = [NSDate date];
        self.Trip.startdt = self.startDt;
        self.Trip.enddt = self.endDt;
        
        self.Trip.startdttimezonename = self.StartDtTimeZoneNameTextField.text;
        self.Trip.enddttimezonename = self.EndDtTimeZoneNameTextField.text;
        self.Trip.defaulttimezonename = self.DefaultTimeZoneNameTextField.text;
        
        [self.realm beginWriteTransaction];
        NSLog(@"addObject startdate=%@",self.Trip.startdt);
        [self.realm addObject:self.Trip];
        [self.realm commitWriteTransaction];
    }
    else
    {
        // potential update
        if ([self.Trip.privatenotes isEqualToString:self.TextViewNotes.text] && [self.Trip.name isEqualToString:self.TextFieldName.text] && !self.updatedimage && self.Trip.startdt == self.startDt && self.Trip.enddt == self.endDt && [self.Trip.defaulttimezonename isEqualToString: self.DefaultTimeZoneNameTextField.text] && [self.Trip.startdttimezonename isEqualToString: self.StartDtTimeZoneNameTextField.text] && [self.Trip.enddttimezonename isEqualToString: self.EndDtTimeZoneNameTextField.text] ) {
            // nothing to do
        } else {
            [self.Trip.realm beginWriteTransaction];
            if (self.updatedimage) {
                NSData *imageData =  UIImagePNGRepresentation(self.ImageViewProject.image);
                NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/Trips/%@",self.Trip.key]];
                [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
                
                NSString *filepathname = [dataPath stringByAppendingPathComponent:@"image.png"];
                [imageData writeToFile:filepathname atomically:YES];
                ImageCollectionRLM *image = [self.Trip.images firstObject];
                image.ImageFileReference = [NSString stringWithFormat:@"Images/Trips/%@/image.png",self.Trip.key];
            }
            
            self.Trip.privatenotes = self.TextViewNotes.text;
            self.Trip.name = self.TextFieldName.text;
            self.Trip.modifieddt = [NSDate date];
            self.Trip.startdt = self.startDt;
            self.Trip.enddt = self.endDt;
            self.Trip.startdttimezonename = self.StartDtTimeZoneNameTextField.text;
            self.Trip.enddttimezonename = self.EndDtTimeZoneNameTextField.text;
            self.Trip.defaulttimezonename = self.DefaultTimeZoneNameTextField.text;
            [self.Trip.realm commitWriteTransaction];
            
        }
    }
    [self dismissViewControllerAnimated:YES completion:Nil];

}

/*
 created date:      29/04/2018
 last modified:     30/03/2019
 remarks:
 */
- (IBAction)EditImagePressed:(id)sender {
    
    NSString *titleMessage = @"How would you like to add a photo to your Project?";
    NSString *alertMessage = @"";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleMessage
                                                                   message:alertMessage
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    [alert.view setTintColor:[UIColor labelColor]];
    
    NSString *cameraOption = @"Take a photo with the camera";
    NSString *photorollOption = @"Choose a photo from camera roll";
    NSString *lastphotoOption = @"Select last photo taken";
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:cameraOption
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                                   
                                                                   
                                                                   UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Device has no camera" preferredStyle:UIAlertControllerStyleAlert];
                                                                   
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

                                        [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                                                               targetSize:self.ImageViewProject.frame.size
                                                                              contentMode:PHImageContentModeAspectFill
                                                                                  options:options
                                                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                                
                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    self.Project.Image = result;
                                                                                    self.ImageViewProject.image = result;
                                                                                    self.updatedimage = true;
                                                                                });
                                                                            }];                                    
                                    }
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
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                               NSLog(@"You pressed cancel");
                                                           }];
    
    
    
    [alert addAction:cameraAction];
    [alert addAction:photorollAction];
    [alert addAction:lastphotoAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/*
 created date:      29/04/2018
 last modified:     30/03/2019
 remarks:
 */

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    /* obtain the image from the camera */
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    chosenImage = [ToolBoxNSO imageWithImage:chosenImage scaledToSize:self.ImageViewProject.frame.size];
    self.Project.Image = chosenImage;
    self.ImageViewProject.image = chosenImage;
    self.updatedimage = true;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

/*
 created date:      28/04/2018
 last modified:     17/02/2019
 remarks:
 */
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.TextViewNotes endEditing:YES];
    [self.TextFieldName endEditing:YES];
    [self.TextFieldEndDt endEditing:YES];
    [self.TextFieldStartDt endEditing:YES];
}
*/
 


/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}




/*
 created date:      09/09/2018
 last modified:     09/09/2018
 remarks:
 */
- (IBAction)UploadImagePressed:(id)sender {
    NSData *dataImage = UIImagePNGRepresentation(self.ImageViewProject.image);
    NSString *stringImage = [dataImage base64EncodedStringWithOptions:0];
    
    NSString *ImageFileReference = [NSString stringWithFormat:@"Images/Trips/%@/image.png",self.Trip.key];
    
    NSString *ImageFileDirectory = [NSString stringWithFormat:@"Images/Trips/%@",self.Trip.key];
    
    NSDictionary* dataJSON = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Trip",
                              @"type",
                              ImageFileReference,
                              @"filereference",
                              ImageFileDirectory,
                              @"directory",
                              stringImage,
                              @"image",
                              nil];
    
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataJSON
                                                       options:NSJSONWritingPrettyPrinted error:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:imagesDirectory];
    url = [url URLByAppendingPathComponent:@"Trip.trippo"];
    
    [jsonData writeToURL:url atomically:NO];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        //Delete file
        NSError *errorBlock;
        if([[NSFileManager defaultManager] removeItemAtURL:url error:&errorBlock] == NO) {
            //NSLog(@"error deleting file %@",error);
            return;
        }
    }];
    
    
    activityViewController.popoverPresentationController.sourceView = self.view;
    [self presentViewController:activityViewController animated:YES completion:nil];
    
}

/*
 created date:      07/10/2018
 last modified:     07/10/2018
 remarks:           Obtain flag of country where Poi is located.
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
 created date:      08/10/2018
 last modified:     08/10/2018
 remarks:
 */
-(NSString *)formattedDistanceForMeters:(double)distance
{
    NSLengthFormatter *lengthFormatter = [NSLengthFormatter new];
    [lengthFormatter.numberFormatter setMaximumFractionDigits:2];
    
    if ([[AppDelegateDef MeasurementSystem] isEqualToString:@"U.K."] || ![AppDelegateDef MetricSystem]) {
        return [lengthFormatter stringFromValue:distance / 1609.34 unit:NSLengthFormatterUnitMile];
        
    } else {
        return [lengthFormatter stringFromValue:distance / 1000 unit:NSLengthFormatterUnitKilometer];
    }
}



/*
 created date:      12/06/2019
 last modified:     27/08/2019
 remarks:           Loads weather data from API and distributes across the annotations on the map.
 */
-(void) constructWeatherMapPointData :(bool)IsActual {

    [self.MapView removeAnnotations:self.MapView.annotations];

    NSArray *keypaths  = [[NSArray alloc] initWithObjects:@"poikey", nil];

    RLMResults<ActivityRLM *> *ActivitiesByState;

    if (IsActual) {
        ActivitiesByState = [[ActivityRLM objectsWhere:@"tripkey = %@ and state = 1",self.Trip.key] distinctResultsUsingKeyPaths:keypaths];
        
    } else {
        ActivitiesByState = [[ActivityRLM objectsWhere:@"tripkey = %@ and state = 0",self.Trip.key] distinctResultsUsingKeyPaths:keypaths];
    }

    __block NSDate *updatedTime;
    __block int PoiCounter = 0;
    for (ActivityRLM *activity in ActivitiesByState) {

        if ([activity.poi.IncludeWeather intValue] == 1) {
            
            /* we only want to update the forecast if it is older than 1 hour */
            RLMResults <WeatherRLM*> *weatherresult = [activity.poi.weather objectsWhere:@"timedefition='currently'"];
            NSNumber *maxtime = [weatherresult maxOfProperty:@"time"];
            
            updatedTime = [NSDate dateWithTimeIntervalSince1970: [maxtime doubleValue]];
            
            NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
            NSNumber *now = [NSNumber numberWithDouble: timestamp];
            
            if ([self checkInternet]) {
            
                //NSLog(@"number of seconds past=%0.2f", [now doubleValue] - [maxtime doubleValue]);
                
                if (([maxtime doubleValue] + 3600 < [now doubleValue]) || maxtime == nil) {
                    
                    /* clean up previous data */
                    if (maxtime != nil) {
                        [self.realm transactionWithBlock:^{
                            [self.realm deleteObjects:activity.poi.weather];
                        }];
                    }
                    
                    NSString *url = [NSString stringWithFormat:@"https://api.darksky.net/forecast/d339db567160bdd560169ea4eef3ee5a/%@,%@?exclude=minutely,flags,alerts&units=uk2", activity.poi.lat, activity.poi.lon];
                    
                    [self fetchFromDarkSkyApi:url withDictionary:^(NSDictionary *data) {
                        
                        dispatch_sync(dispatch_get_main_queue(), ^(void){
                            
                            WeatherRLM *weather = [[WeatherRLM alloc] init];
                            NSDictionary *JSONdata = [data objectForKey:@"currently"];
                            weather.icon = [NSString stringWithFormat:@"weather-%@",[JSONdata valueForKey:@"icon"]];
                            weather.systemicon = [ToolBoxNSO getWeatherSystemImage:[JSONdata valueForKey:@"icon"]];
                            weather.summary = [JSONdata valueForKey:@"summary"];
                            double myDouble = [[JSONdata valueForKey:@"temperature"] doubleValue];
                            NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
                            [fmt setPositiveFormat:@"0.#"];
                            weather.temperature = [NSString stringWithFormat:@"%@",[fmt stringFromNumber:[NSNumber numberWithFloat:myDouble]]];
                            weather.timedefition = @"currently";
                            weather.time = [JSONdata valueForKey:@"time"];
                            updatedTime = [NSDate dateWithTimeIntervalSince1970: [weather.time doubleValue]];
                            
                            /* Annotation for map  - begin */
                            
                            CLLocationCoordinate2D Coord = CLLocationCoordinate2DMake([activity.poi.lat doubleValue], [activity.poi.lon doubleValue]);

                            AnnotationMK *annotation = [[AnnotationMK alloc] init];
                            annotation.coordinate = Coord;
                            annotation.title = [NSString stringWithFormat:@"%@", activity.name];
                            annotation.subtitle = [NSString stringWithFormat:@"%@ °C (%@)",weather.temperature, weather.summary];
                            annotation.Type = weather.systemicon;

                            [self.MapView addAnnotation:annotation];
                            /* Annotation for map  - end */

                            
                            [self.realm transactionWithBlock:^{
                                [activity.poi.weather addObject:weather];
                            }];
                            
                            NSDictionary *JSONHourlyData = [data objectForKey:@"hourly"];
                            NSArray *dataHourly = [JSONHourlyData valueForKey:@"data"];
                            
                            for (NSMutableDictionary *item in dataHourly) {
                                WeatherRLM *weather = [[WeatherRLM alloc] init];
                                weather.icon = [NSString stringWithFormat:@"weather-%@",[item valueForKey:@"icon"]];
                                weather.systemicon = [ToolBoxNSO getWeatherSystemImage:[item valueForKey:@"icon"]];
                                weather.summary = [item valueForKey:@"summary"];
                                double myDouble = [[item valueForKey:@"temperature"] doubleValue];
                                NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
                                [fmt setPositiveFormat:@"0.#"];
                                weather.temperature = [NSString stringWithFormat:@"%@",[fmt stringFromNumber:[NSNumber numberWithFloat:myDouble]]];
                                weather.timedefition = @"hourly";
                                weather.time = [item valueForKey:@"time"];
                                
                                [self.realm transactionWithBlock:^{
                                    [activity.poi.weather addObject:weather];
                                }];
                            }
                            NSDictionary *JSONDailyData = [data objectForKey:@"daily"];
                            NSArray *dataDaily = [JSONDailyData valueForKey:@"data"];
                            
                            for (NSMutableDictionary *item in dataDaily) {
                                WeatherRLM *weather = [[WeatherRLM alloc] init];
                                weather.icon = [NSString stringWithFormat:@"weather-%@",[item valueForKey:@"icon"]];
                                weather.systemicon = [ToolBoxNSO getWeatherSystemImage:[item valueForKey:@"icon"]];
                                weather.summary = [item valueForKey:@"summary"];
                                double tempLow = [[item valueForKey:@"temperatureLow"] doubleValue];
                                double tempHigh = [[item valueForKey:@"temperatureHigh"] doubleValue];
                                NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
                                [fmt setPositiveFormat:@"0.#"];
                                weather.temperature = [NSString stringWithFormat:@"Lowest %@ °C, Highest %@ °C",[fmt stringFromNumber:[NSNumber numberWithFloat:tempLow]], [fmt stringFromNumber:[NSNumber numberWithFloat:tempHigh]]];
                                weather.timedefition = @"daily";
                                weather.time = [item valueForKey:@"time"];
                                
                                [self.realm transactionWithBlock:^{
                                    [activity.poi.weather addObject:weather];
                                }];
                            }
                            PoiCounter ++;
                        });
                    }];
                } else {
                    
                    /* we have weather that is already available without calling the API */
                    CLLocationCoordinate2D Coord = CLLocationCoordinate2DMake([activity.poi.lat doubleValue], [activity.poi.lon doubleValue]);
                    
                    WeatherRLM *weather = [weatherresult firstObject];
                    
                    AnnotationMK *annotation = [[AnnotationMK alloc] init];
                    annotation.coordinate = Coord;
                    annotation.title = [NSString stringWithFormat:@"%@", activity.name];
                    annotation.subtitle = [NSString stringWithFormat:@"%@ °C (%@)",weather.temperature, weather.summary];
                    annotation.Type = weather.systemicon;
                    
                    [self.MapView addAnnotation:annotation];
                    PoiCounter ++;
                }
            } else {
                /* without internet: */
                CLLocationCoordinate2D Coord = CLLocationCoordinate2DMake([activity.poi.lat doubleValue], [activity.poi.lon doubleValue]);
                
                AnnotationMK *annotation = [[AnnotationMK alloc] init];
                annotation.coordinate = Coord;
                annotation.title = activity.name;

                if (weatherresult.count > 0) {
                    WeatherRLM *weather = [weatherresult firstObject];

                    if (([maxtime doubleValue] + 3600 < [now doubleValue]) || maxtime == nil) {
                        annotation.subtitle = [NSString stringWithFormat:@"Offline %@ °C (%@)",weather.temperature, weather.summary];
                    } else {
                        annotation.subtitle = [NSString stringWithFormat:@"%@ °C (%@)",weather.temperature, weather.summary];
                    }
                    annotation.Type = weather.systemicon;
                } else {
                    annotation.PoiKey = activity.poi.key;
                    if (IsActual) {
                        annotation.subtitle = @"Actual";
                        annotation.Type = @"marker-actual";
                    } else {
                        annotation.subtitle = @"Planned";
                        annotation.Type = @"marker-planned";
                    }
                }
                [self.MapView addAnnotation:annotation];
                PoiCounter ++;
            }
        } else {
            /* an item without weather option */
            AnnotationMK *annotation = [[AnnotationMK alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake([activity.poi.lat doubleValue], [activity.poi.lon doubleValue]);
            annotation.title = activity.name;
            annotation.PoiKey = activity.poi.key;
            if (IsActual) {
                annotation.subtitle = @"Actual";
                annotation.Type = @"marker-actual";
            } else {
                annotation.subtitle = @"Planned";
                annotation.Type = @"marker-planned";
            }
            
            [self.MapView addAnnotation:annotation];
            PoiCounter ++;
        }
        if (PoiCounter == ActivitiesByState.count) {
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
            self.LabelWeatherLastUpdatedAt.text = [NSString stringWithFormat:@"Weather data from DarkSky last updated at\n %@",[dateFormatter stringFromDate:updatedTime]];
            [self zoomToAnnotationsBounds :self.MapView.annotations];
        }
    }
}




/*
 created date:      15/06/2019
 last modified:     23/06/2019
 remarks:
 */
- (IBAction)SegmentAnnotationsChanged:(id)sender {
    
    [self.MapView removeAnnotations:self.MapView.annotations];
    
    if (self.SegmentAnnotations.selectedSegmentIndex == 0) {
        [self constructWeatherMapPointData :false];
    } else if (self.SegmentAnnotations.selectedSegmentIndex == 1) {
        [self constructWeatherMapPointData :true];
    }
}


- (IBAction)StartDateTimeZoneEditingDidBegin:(id)sender {

}

- (IBAction)EndDateTimeZoneEditingDidBegin:(id)sender {

}

- (IBAction)DefaultDateTimeZoneEditingDidBegin:(id)sender {

}

/*
 created date:      14/09/2019
 last modified:     14/09/2019
 remarks:
 */
- (void)onStartDtTimeZonePickerValueChanged:(UIPickerView *)Picker
{
    self.StartDtTimeZoneNameTextField.text = [self.timezones objectAtIndex: [Picker selectedRowInComponent:0]] ;
}

/*
 created date:      14/09/2019
 last modified:     14/09/2019
 remarks:
 */
- (void)onEndDtTimeZonePickerValueChanged:(UIPickerView *)Picker
{
    self.EndDtTimeZoneNameTextField.text = [self.timezones objectAtIndex: [Picker selectedRowInComponent:0]] ;
}

/*
 created date:      14/09/2019
 last modified:     14/09/2019
 remarks:
 */
- (void)onDefaultDtTimeZonePickerValueChanged:(UIPickerView *)Picker
{
    self.DefaultTimeZoneNameTextField.text = [self.timezones objectAtIndex: [Picker selectedRowInComponent:0]] ;
}

/*
 created date:      21/08/2019
 last modified:     21/08/2019
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ShowTripPaymentList"]){
        PaymentListingVC *controller = (PaymentListingVC *)segue.destinationViewController;
        controller.delegate = self;

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
            controller.headerImage = [UIImage imageNamed:@"Project"];
        }
        controller.ActivityItem = nil;
        // controller.activitystate = [NSNumber numberWithInteger:self.SegmentState.selectedSegmentIndex];
    }
        
}


@end
