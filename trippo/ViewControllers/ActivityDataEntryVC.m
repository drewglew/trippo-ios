//
//  ActivityDataEntryVC.m
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ActivityDataEntryVC.h"

@interface ActivityDataEntryVC ()
@property RLMNotificationToken *notification;
@end

int BlurredMainViewPresentedHeight;
int BlurredImageViewPresentedHeight=60;
int DocumentListingViewPresentedHeight = 250;
@implementation ActivityDataEntryVC
@synthesize ImageViewPoi;
@synthesize delegate;

/*
 created date:      01/05/2018
 last modified:     16/08/2019
 remarks:
 */
- (void)viewDidLoad {
    
    /* new block */
    self.timezones = [NSTimeZone knownTimeZoneNames];
       
    self.StartDtTimeZonePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.StartDtTimeZonePicker.delegate = self;
    self.StartDtTimeZonePicker.dataSource = self;
   
    self.EndDtTimeZonePicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.EndDtTimeZonePicker.delegate = self;
    self.EndDtTimeZonePicker.dataSource = self;
    
    self.TextFieldStartDt.delegate = self;
    self.TextFieldEndDt.delegate = self;
    /* end of new block */
    
    
    [super viewDidLoad];    
    if (self.Activity.state == [NSNumber  numberWithInteger:0]) {
        self.ImagePicture.image = [UIImage imageNamed:@"Planning"];
        self.ImageViewKeyActivity.image = [UIImage imageNamed:@"Planning"];
        self.MainImageTrailingConstraint.constant = [UIScreen mainScreen].bounds.size.width;;
    } else {
        self.ImagePicture.image = [UIImage imageNamed:@"Activity"];
        self.ImageViewKeyActivity.image = [UIImage imageNamed:@"Activity"];
    }
    
    // clean up wiki
    //self.WikiViewHeightConstraint.constant = 0.0f;
    self.ActivityImageDictionary = [[NSMutableDictionary alloc] init];
    
    self.TableViewAttachments.delegate = self;
    
    self.TextFieldName.layer.cornerRadius=8.0f;
    self.TextFieldName.layer.masksToBounds=YES;
    self.TextFieldName.layer.borderColor=[[UIColor clearColor] CGColor];
    self.TextFieldName.layer.borderWidth= 1.0f;

    self.TextViewNotes.layer.cornerRadius=8.0f;
    self.TextViewNotes.layer.masksToBounds=YES;

    self.ViewSelectedKey.layer.cornerRadius=28;
    self.ViewSelectedKey.layer.masksToBounds=YES;
    
    self.ViewTrash.layer.cornerRadius=28;
    self.ViewTrash.layer.masksToBounds=YES;
    
    
    NSDate *now = [NSDate date];
    
    NSDate *defaultStartDt = now;
    NSDate *defaultEndDt = now;
    
    
    if (self.deleteitem) {
        UIImage *btnImage = [UIImage imageNamed:@"TrashCan"];
        [self.ButtonAction setImage:btnImage forState:UIControlStateNormal];
        [self.ButtonAction setTitle:@"" forState:UIControlStateNormal];
        
        [self LoadActivityData];
        [self LoadDocuments];
        
        self.CollectionViewActivityImages.scrollEnabled = true;
    } else if (!self.newitem && !self.transformed) {

        [self LoadActivityData];
        [self LoadDocuments];
        
        self.CollectionViewActivityImages.scrollEnabled = true;

        if (self.Activity.state == [NSNumber numberWithInteger:0]) {
            // validate if we have an related actual item.
            NSString* ActualCompondKey = [self.Activity.compondkey stringByReplacingOccurrencesOfString:@"~0" withString:@"~1"];
            
            ActivityRLM *activity = [ActivityRLM objectForPrimaryKey:ActualCompondKey];
            
            if (activity != nil) {
                self.ButtonArriving.enabled = false;
                self.ButtonLeaving.enabled = false;
                self.LabelGeoWarningNotice.text = @"It is no longer possible to modify the notification settings on this planned item because it is also an actual activity.";
                self.GeoWarningLabelHeightConstraint.constant = 75.0f;
                [self.ButtonArriving setBackgroundColor:[UIColor colorWithRed:179.0f/255.0f green:25.0f/255.0f blue:49.0f/255.0f alpha:1.0]];
                [self.ButtonLeaving setBackgroundColor:[UIColor colorWithRed:179.0f/255.0f green:25.0f/255.0f blue:49.0f/255.0f alpha:1.0]];
            }
            
            self.ViewUpdateActualWeatherHeightConstraint.constant = 0.0f;
            [self.ViewUpdateActualWeather setHidden:TRUE];
        }
        
        BOOL datesAreEqual = [[NSCalendar currentCalendar] isDate:self.Activity.startdt
                                                      equalToDate:self.Activity.enddt toUnitGranularity:NSCalendarUnitMinute];
        
        if (datesAreEqual && self.Activity.state==[NSNumber numberWithInteger:1]) {
            
            // we set the colour in the main method that covers its normal set.
            self.ButtonArriving.enabled = false;
            self.LabelGeoWarningNotice.text = @"It is impractical to set arrival notifications on actual activity that is already checked in.";
            self.GeoWarningLabelHeightConstraint.constant = 75.0f;
            [self.ButtonArriving setBackgroundColor:[UIColor colorWithRed:179.0f/255.0f green:25.0f/255.0f blue:49.0f/255.0f alpha:1.0]];

            self.ViewCheckInOut.layer.cornerRadius = 100;
            self.ViewCheckInOut.clipsToBounds = YES;
            self.ViewCheckInOut.transform = CGAffineTransformMakeRotation(-.34906585);
            self.ViewCheckInOut.hidden = false;
            // systemPink colour
            self.ViewCheckInOut.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0];
            self.LabelCheckInOut.text = @"Check\nOut";
            [self.LabelCheckInOut setTextColor:[UIColor whiteColor]];
            
            self.ViewUpdateActualWeatherHeightConstraint.constant = 0.0f;
            [self.ViewUpdateActualWeather setHidden:TRUE];
           
        } else if (self.Activity.state == [NSNumber numberWithInteger:1]) {
            // we set the colour in the main method that covers its normal set.
            self.ButtonArriving.enabled = false;
            self.ButtonLeaving.enabled = false;
            self.LabelGeoWarningNotice.text = @"It is no longer possible to set notifications on this item because it is completed.";
            self.GeoWarningLabelHeightConstraint.constant = 75.0f;
            [self.ButtonArriving setBackgroundColor:[UIColor colorWithRed:179.0f/255.0f green:25.0f/255.0f blue:49.0f/255.0f alpha:1.0]];
            [self.ButtonLeaving setBackgroundColor:[UIColor colorWithRed:179.0f/255.0f green:25.0f/255.0f blue:49.0f/255.0f alpha:1.0]];
            
            // activity is done!
            if (self.Activity.weather.count > 0) {
                [self.ButtonUpdateActualWeather setEnabled:FALSE];
            } else if (self.Activity.poi.IncludeWeather == 0) {
                self.ViewUpdateActualWeatherHeightConstraint.constant = 0.0f;
                [self.ViewUpdateActualWeather setHidden:TRUE];
            }
        }
        self.toggleNotifyArrivingFlag = [self.Activity.geonotification intValue];
        self.toggleNotifyLeavingFlag = [self.Activity.geonotifycheckout intValue];

    } else if (self.transformed) {
        self.ViewCheckInOut.layer.cornerRadius = 100;
        self.ViewCheckInOut.clipsToBounds = YES;
        self.ViewCheckInOut.transform = CGAffineTransformMakeRotation(-.34906585);
        self.ViewCheckInOut.hidden = false;
        self.LabelCheckInOut.text = @"Check\nIn";
        [self.ButtonAction setTitle:@"Update" forState:UIControlStateNormal];
        [self LoadActivityData];
        [self LoadDocuments];
        self.CollectionViewActivityImages.scrollEnabled = true;
        self.toggleNotifyArrivingFlag = 0;
        self.toggleNotifyLeavingFlag = 0;
        defaultStartDt = self.Activity.startdt;
        defaultEndDt = self.Activity.enddt;
        
        // we set the colour in the main method that covers its normal set.
        self.ButtonArriving.enabled = false;
        self.LabelGeoWarningNotice.text = @"It is impractical to set arrival notifications on actual activity when creating them from a planned activity.";
        self.GeoWarningLabelHeightConstraint.constant = 75.0f;
        [self.ButtonArriving setBackgroundColor:[UIColor colorWithRed:179.0f/255.0f green:25.0f/255.0f blue:49.0f/255.0f alpha:1.0]];
        //[self.view layoutIfNeeded];

        self.Activity.startdt = now;
        self.Activity.enddt = now;
        
        self.ViewUpdateActualWeatherHeightConstraint.constant = 0.0f;
        [self.ViewUpdateActualWeather setHidden:TRUE];
        [self.ButtonPayment setEnabled:false];
        
    } else if (self.newitem) {

        self.StartDtTimeZoneNameTextField.text = self.Trip.defaulttimezonename;
        self.EndDtTimeZoneNameTextField.text = self.Trip.defaulttimezonename;
        
        /* here needed */
        
        self.TextFieldName.text = self.Poi.name;
        
        if (self.Activity.startdt==nil) {
            if (self.Activity.state==[NSNumber numberWithInteger:0]) {
                /*
                 handle adjustment of activity start end dates depending on now for new items.
                 if now is later than start date and earlier than end date set the start datetime value to now
                 otherwise the start and end dates will be same as trip date ranges.
                 */
                NSDate *now = [NSDate date];
                if ([now compare:self.Trip.startdt] == NSOrderedDescending && [now compare:self.Trip.enddt] == NSOrderedAscending) {
                    self.Activity.startdt = now;
                    self.Activity.enddt = self.Trip.enddt;
                } else {
                    self.Activity.startdt = self.Trip.startdt;
                    self.Activity.enddt = self.Trip.enddt;
                }
            } else {
                self.Activity.startdt = now;
                self.Activity.enddt = now;
            }
        }
        
        [self LoadDocuments];
        
        self.toggleNotifyArrivingFlag = 0;
        self.toggleNotifyLeavingFlag = 0;
        
        if (self.Activity.state == [NSNumber numberWithInteger:1]) {
            // we set the colour in the main method that covers its normal set.
            self.ButtonArriving.enabled = false;
            self.ButtonLeaving.enabled = false;
            self.LabelGeoWarningNotice.text = @"It is impractical to set notifications on actual activity when creating them.  Once updated, it is possible to create a leaving notification if item is 'Checked-In'.";
            self.GeoWarningLabelHeightConstraint.constant = 75.0f;
            [self.ButtonArriving setBackgroundColor:[UIColor colorWithRed:179.0f/255.0f green:25.0f/255.0f blue:49.0f/255.0f alpha:1.0]];
            [self.ButtonLeaving setBackgroundColor:[UIColor colorWithRed:179.0f/255.0f green:25.0f/255.0f blue:49.0f/255.0f alpha:1.0]];
            //[self.view layoutIfNeeded];
        }
        
        self.ViewUpdateActualWeatherHeightConstraint.constant = 0.0f;
        [self.ViewUpdateActualWeather setHidden:TRUE];
        
        [self.SwitchTweet setOn:false];
        [self.ButtonPayment setEnabled:false];
        
        [self LoadPoiData];
        
    }
    self.startDt = self.Activity.startdt;
    self.endDt = self.Activity.enddt;
    
    NSTimeZone *timeZoneStartDp = [NSTimeZone timeZoneWithName:self.StartDtTimeZoneNameTextField.text];
    NSTimeZone *timeZoneEndDp = [NSTimeZone timeZoneWithName:self.EndDtTimeZoneNameTextField.text];
    
    
    [self addDoneToolBarToKeyboard:self.TextViewNotes];
    [self addDoneToolBarForTextFieldToKeyboard:self.TextFieldName];
    [self addDoneToolBarForTextFieldToKeyboard:self.TextFieldReference];
    
    self.TextFieldName.delegate = self;
    self.TextViewNotes.delegate = self;
    self.TextFieldReference.delegate = self;
    self.TableViewAttachments.delegate = self;
    
    //self.ViewStateIndicator.layer.cornerRadius = (self.ViewStateIndicator.bounds.size.width / 2);
    //self.ViewStateIndicator.clipsToBounds = YES;
    
    //self.ViewSettingsStateIndicator.layer.cornerRadius = (self.ViewStateIndicator.bounds.size.width / 2);
    //self.ViewSettingsStateIndicator.clipsToBounds = YES;
    
    if (self.Activity.state==[NSNumber numberWithInteger:1]) {
        //self.ImageViewIdeaWidthConstraint.constant = 0;
        BlurredMainViewPresentedHeight = 420;
        self.ViewEffectBlurDetailHeightConstraint.constant = BlurredMainViewPresentedHeight;
        self.ViewStarRating.hidden = false;
        
        self.ViewStarRating.maximumValue = 5;
        self.ViewStarRating.minimumValue = 0;
        self.ViewStarRating.value = [self.Activity.rating floatValue];
        self.ViewStarRating.allowsHalfStars = YES;
        self.ViewStarRating.accurateHalfStars = YES;

        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightBold];
        self.ImageViewStateIndicator.image = [UIImage systemImageNamed:@"a.circle.fill" withConfiguration:config];
        self.ImageViewSettingsStateIndicator.image = [UIImage systemImageNamed:@"a.circle.fill" withConfiguration:config];
          
    } else {
        BlurredMainViewPresentedHeight = 150;
        
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightBold];
        self.ImageViewStateIndicator.image = [UIImage systemImageNamed:@"i.circle" withConfiguration:config];
        self.ImageViewSettingsStateIndicator.image = [UIImage systemImageNamed:@"i.circle" withConfiguration:config];
    }

    self.CollectionViewActivityImages.dataSource = self;
    self.CollectionViewActivityImages.delegate = self;
    
    self.ImagePicture.frame = CGRectMake(0, 0, self.ScrollViewImage.frame.size.width, self.ScrollViewImage.frame.size.height);
    self.ScrollViewImage.delegate = self;

    
    /* here to do work! */
    
    /* initialize the datePicker for start dt */
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [self.datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [self.datePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    /* add toolbar control for 'Done' option */
    UIToolbar *toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolBar setTintColor:[UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(HidePickers)];
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];
    
    /* extend features on the input view of the text field for start dt */
    self.TextFieldStartDt.inputView = self.datePicker;
    self.TextFieldStartDt.text = [NSString stringWithFormat:@"%@", [self FormatPrettyDate :self.startDt :timeZoneStartDp :@" "]];
    [self.TextFieldStartDt setInputAccessoryView:toolBar];
    
    /* extend features on the input view of the text field for end dt */
    self.TextFieldEndDt.inputView = self.datePicker;
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"EEE, dd MMM yyyy"];
    NSDateFormatter *timeformatter = [[NSDateFormatter alloc] init];
    [timeformatter setDateFormat:@"HH:mm"];
    
    // firstly test the start and end dates.  Remember the start and end are the same if activity is checked in.
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:self.startDt toDate:self.endDt options:0];
    
    if ((components.day!=0 || components.hour!=0 || components.minute!=0) || self.Activity.state==[NSNumber numberWithInteger:0]) {
        self.TextFieldEndDt.text = [NSString stringWithFormat:@"%@", [self FormatPrettyDate :self.endDt :timeZoneEndDp :@" "]];
    } else {
        // now using same exponent, we can write out the time that has passed since user checked into activity.
        NSString *PrettyDateDifference = [ToolBoxNSO PrettyDateDifference :self.startDt :[NSDate date] :@" ago"];
        if (![PrettyDateDifference isEqualToString:@""]) {
            self.TextFieldEndDt.text = PrettyDateDifference;
        }
    }

    if ([self.ButtonArriving isEnabled]) {
        if (self.toggleNotifyArrivingFlag == 1) {
            [self.ButtonArriving setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:102.0f/255.0f blue:51.0f/255.0f alpha:1.0]];
        } else {
            [self.ButtonArriving setBackgroundColor:[UIColor lightGrayColor]];
        }
    }
    if ([self.ButtonLeaving isEnabled]) {
        if (self.toggleNotifyLeavingFlag == 1) {
            [self.ButtonLeaving setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:102.0f/255.0f blue:51.0f/255.0f alpha:1.0]];
        } else {
            [self.ButtonLeaving setBackgroundColor:[UIColor lightGrayColor]];
        }
    }
    if (![self.ButtonUpdateActualWeather isEnabled]) {
        [self.ButtonUpdateActualWeather setBackgroundColor:[UIColor colorWithRed:179.0f/255.0f green:25.0f/255.0f blue:49.0f/255.0f alpha:1.0]];
    }
    
    [self.TextFieldEndDt setInputAccessoryView:toolBar];
    
    self.StartDtTimeZoneNameTextField.inputView = self.StartDtTimeZonePicker;
    [self.StartDtTimeZoneNameTextField setInputAccessoryView:toolBar];
    
    self.EndDtTimeZoneNameTextField.inputView = self.EndDtTimeZonePicker;
    [self.EndDtTimeZoneNameTextField setInputAccessoryView:toolBar];

    self.TableViewAttachments.rowHeight = 60.0f;
    //self.WebViewPreview.scrollView.delegate = self;
    __weak typeof(self) weakSelf = self;
    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf LoadDocuments];
       // [weakSelf.TableViewAttachments reloadData];
    }];
    
    self.ActivityScrollView.delegate = self;
    self.SegmentPresenter.selectedSegmentTintColor = [UIColor colorNamed:@"TrippoColor"];

    NSInteger anIndex=[self.timezones indexOfObject:self.StartDtTimeZoneNameTextField.text];
    [self.StartDtTimeZonePicker selectRow:anIndex inComponent:0 animated:YES];
    
    anIndex=[self.timezones indexOfObject:self.EndDtTimeZoneNameTextField.text];
    [self.EndDtTimeZonePicker selectRow:anIndex inComponent:0 animated:YES];
    
    [self registerForKeyboardNotifications];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    
    self.ActivityScrollView.contentSize = CGSizeMake(self.ActivityScrollView.frame.size.width, self.ActivityScrollViewContent.frame.size.height);
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
    self.ActivityScrollView.contentInset = contentInsets;
    self.ActivityScrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height + 50.0;
    if (!CGRectContainsPoint(aRect, self.ActiveTextField.frame.origin) && self.ActiveTextView == nil ) {
        
        NSLog(@"contentsize=%f,%f",self.ActivityScrollView.contentSize.height, self.ActivityScrollView.contentSize.width);
        
        //CGRect aRectTextField = CGRectMake(self.ActiveTextField.frame.origin.x, self.ActiveTextField.frame.origin.y, self.ActiveTextField.frame.size.width, self.ActiveTextField.frame.size.height - aRect.size.height);
        
        [self.ActivityScrollView scrollRectToVisible:self.ActiveTextField.frame animated:YES];
    } else if (!CGRectContainsPoint(aRect, self.ActiveTextView.frame.origin)  && self.ActiveTextField == nil) {
        NSLog(@"contentsize=%f,%f",self.ActivityScrollView.contentSize.height, self.ActivityScrollView.contentSize.width);
        
        //CGRect aRectTextView = CGRectMake(self.ActiveTextView.frame.origin.x, self.ActiveTextView.frame.origin.y, self.ActiveTextView.frame.size.width, self.view.frame.size.height - self.ActiveTextView.frame.origin.y + 50);
        
        [self.ActivityScrollView scrollRectToVisible:self.ActiveTextView.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.ActivityScrollView.contentInset = contentInsets;
    self.ActivityScrollView.scrollIndicatorInsets = contentInsets;
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





-(void)addDoneToolBarToKeyboard:(UITextView *)textView
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


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleKeyboardWillShow:)
     name:UIKeyboardWillShowNotification object:nil];
    
}




-(void)doneButtonClickedDismissKeyboard
{
    [self.TextViewNotes resignFirstResponder];
    [self.TextFieldName resignFirstResponder];
    [self.TextFieldReference resignFirstResponder];
}



/*
created date:       15/08/2019
last modified:      16/08/2019
remarks:            Add wiki document into collection if possible.
*/
-(void)LoadDocuments {
   
    self.DocumentCollection = [[NSMutableArray alloc] init];
    for (AttachmentRLM *attachmentobject in self.Activity.attachments) {
       [self.DocumentCollection addObject:attachmentobject];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];

    NSString *wikiDataFilePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/WikiDocs/%@.pdf",self.Poi.key]];
    
    if ([fileManager fileExistsAtPath:wikiDataFilePath]){
        AttachmentRLM *wikidocument = [[AttachmentRLM alloc] init];
        wikidocument.key = @"WIKIPEDIA";
        wikidocument.filename = [NSString stringWithFormat:@"/WikiDocs/%@.pdf",self.Poi.key];
        wikidocument.notes = @"Wikipedia Document";
        wikidocument.isselected = [NSNumber numberWithInt:1];
        [self.DocumentCollection addObject:wikidocument];
    }
    [self.TableViewAttachments reloadData];

}



/*
 created date:      15/08/2019
 last modified:     15/08/2019
 remarks:
 */
- (void)HidePickers
{
    [self.TextFieldStartDt resignFirstResponder];
    [self.TextFieldEndDt resignFirstResponder];
    [self.StartDtTimeZoneNameTextField resignFirstResponder];
    [self.EndDtTimeZoneNameTextField resignFirstResponder];
}


/*
 created date:      01/05/2018
 last modified:     15/08/2019
 remarks:           create a thumbnail image if it doesn't exist.
 */
-(void) LoadActivityData {
    /* set text data */
    self.TextFieldName.text = self.Activity.name;
    self.LabelActivityName.text = self.Activity.name;
    self.TextViewNotes.text = self.Activity.privatenotes;
    self.TextFieldReference.text = self.Activity.reference;

    if (self.Activity.startdttimezonename == nil) {
        self.StartDtTimeZoneNameTextField.text = self.Trip.defaulttimezonename;
        self.EndDtTimeZoneNameTextField.text = self.Trip.defaulttimezonename;
    } else {
        self.StartDtTimeZoneNameTextField.text = self.Activity.startdttimezonename;
        self.EndDtTimeZoneNameTextField.text = self.Activity.enddttimezonename;
    }
    if ([self.Activity.IncludeInTweet intValue] == 0) {
        [self.SwitchTweet setOn:false];
    } else {
        [self.SwitchTweet setOn:true];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileDirectory = [paths objectAtIndex:0];
    long ImageIndex = 0;
    for (ImageCollectionRLM *imgobject in self.Activity.images) {
        UIImage *image = [[UIImage alloc] init];
        NSString *dataFilePath = [fileDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imgobject.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        if (pngData==nil) {
            
            if (self.Activity.state == [NSNumber numberWithInteger:0]) {
                image = [UIImage imageNamed:@"Planning"];
            } else {
                image = [UIImage imageNamed:@"Activity"];
            }
        
        } else {
            image = [UIImage imageWithData:pngData];
        }
        if (imgobject.KeyImage) {
            self.SelectedImageKey = imgobject.key;
            self.SelectedImageReference = imgobject.ImageFileReference;
            self.SelectedImageIndex = [NSNumber numberWithLong:ImageIndex];
            self.ViewSelectedKey.hidden = false;
            [self.ImagePicture setImage:image];
            [self.ImageViewKeyActivity setImage:image];
        }
        
        [self.ActivityImageDictionary setObject:image forKey:imgobject.key];
        
        ImageIndex ++;
    }
    [self LoadPoiData];
}

/*
 created date:      01/05/2018
 last modified:     09/09/2018
 remarks: Focus on Point of Interest Data
 */
-(void) LoadPoiData {

    /* set map */
    self.PoiMapView.delegate = self;
    self.NotificationMapView.delegate = self;

    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
    anno.title = self.Poi.name;
    anno.subtitle = [NSString stringWithFormat:@"%@", self.Poi.administrativearea];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.Poi.lat doubleValue], [self.Poi.lon doubleValue]);
    
    anno.coordinate = coord;

    NSNumber *radius = self.Poi.radius;
    
    [self.PoiMapView setCenterCoordinate:coord animated:NO];
    
    self.PoiMapView.zoomEnabled = false;
    self.PoiMapView.scrollEnabled = false;
    self.PoiMapView.userInteractionEnabled = false;
    
    [self.NotificationMapView setCenterCoordinate:coord animated:YES];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, [radius doubleValue] * 2.2, [radius doubleValue] * 2.2);
    MKCoordinateRegion adjustedRegion = [self.PoiMapView regionThatFits:viewRegion];
    [self.PoiMapView setRegion:adjustedRegion animated:YES];
    [self.PoiMapView addAnnotation:anno];
    [self.PoiMapView selectAnnotation:anno animated:YES];
    
    viewRegion = MKCoordinateRegionMakeWithDistance(coord, [radius doubleValue] * 5, [radius doubleValue] * 5);
    adjustedRegion = [self.NotificationMapView regionThatFits:viewRegion];
    [self.NotificationMapView setRegion:adjustedRegion animated:YES];
    [self.NotificationMapView addAnnotation:anno];
    [self.NotificationMapView selectAnnotation:anno animated:YES];
    
    /* load images from file - TODO make sure we locate them all */
    if (self.PoiImage==nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *imagesDirectory = [paths objectAtIndex:0];
        
        if (self.Poi.images.count>0) {
            
            ImageCollectionRLM *imgobject = [[self.Poi.images objectsWhere:@"KeyImage==1"] firstObject];
            
            NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imgobject.ImageFileReference]];
            
            NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
            
            if (pngData!=nil) {
                self.ImageViewPoi.image = [UIImage imageWithData:pngData];
            } else {
                self.ImageViewPoi.image = [UIImage imageNamed:@"Poi"];
            }
        } else {
            self.ImageViewPoi.image = [UIImage imageNamed:@"Poi"];
        }
    } else {
        self.ImageViewPoi.image = self.PoiImage;
    }
    
    MKCircle *myCircle = [MKCircle circleWithCenterCoordinate:coord radius:[radius doubleValue]];
    [self.PoiMapView addOverlay:myCircle];
    
    [self.NotificationMapView addOverlay:myCircle];
    
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
        aRenderer.fillColor = [UIColor colorWithRed:49.0f/255.0f green:163.0f/255.0f blue:0.0f/255.0f alpha:0.25];
        return aRenderer;
    }
    else
    {
        return nil;
    }
}

/*
created date:      14/07/2018
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
created date:      27/08/2019
last modified:     27/08/2019
remarks:
*/
- (BOOL)isDate:(NSDate *)date inRangeFirstDate:(NSDate *)firstDate lastDate:(NSDate *)lastDate {
    
    return !([date compare:firstDate] == NSOrderedAscending) && !([date compare:lastDate] == NSOrderedDescending);
}


/*
 created date:      01/05/2018
 last modified:     29/07/2019
 remarks:  TODO [self.delegate didUpdateActivityImage]; add to update
 */
- (IBAction)ActionButtonPressed:(id)sender {
    
    if (self.TextFieldName.text == nil) {
        return;
    }
   
    /*
    if user does not enter any dates, the dates stored match the project dates entered.
    If user modifies the dates and start date is earlier than project start date or end date is later than end date -
    modify the project date & any other PLANNED dates that were equal to it previously.
    
    Additionally validate all planned dates in following way when they are manually modified.
    Take example 1.
     Planned activity A: start 10/1/19 10:00 end 15/1/19 10:30
     *Planned activity B: start 14/1/19 16:00 end 16/1/19 21:00
    
    The start date of activity B cannot be after activity A starts and end date cannot be after 15/1/19 10:30 when activity A ends.
    Either activity B end date must be equal/less than end date of activity A
     Planned activity A: start 10/1/19 10:00 end 15/1/19 10:30
     *Planned activity B: start 14/1/19 16:00 end 15/1/19 10:30
    or activity B must start before or after activity A begins.
     Planned activity A: start 10/1/19 10:00 end 15/1/19 10:30
     *Planned activity B: start 10/1/19 09:00 end 16/1/19 10:30
    
    
    Now example 2:
    
    Extend example 1 with adding activity C.
     Planned activity A: start 10/1/19 10:00 end 15/1/19 10:30
     Planned activity B: start 14/1/19 16:00 end 15/1/19 09:30
     *Planned activity C: start 5/1/19 09:00 end 14/1/19 08:00
    
    Either activity C start date must be after both activity A + B’s start date
     Planned activity A: start 10/1/19 10:00 end 15/1/19 10:30
     Planned activity B: start 14/1/19 16:00 end 15/1/19 09:30
     *Planned activity C: start 14/1/19 17:00 end 14/1/19 08:00
    
    Or activity C end date must be after activity A+B’s end date
     Planned activity A: start 10/1/19 10:00 end 15/1/19 10:30
     Planned activity B: start 14/1/19 16:00 end 15/1/19 09:30
     *Planned activity C: start 5/1/19 09:00 end 16/1/19 08:00
    */
    
    
        NSDate *startdt = self.startDt;
        NSDate *enddt = self.endDt;

        /* validate against the Trip */
        bool AdjustTripStartDt = false;
        bool AdjustTripEndDt = false;

       
    
    
        NSComparisonResult resulttripstartdt = [startdt compare:self.Trip.startdt];
        NSComparisonResult resulttripenddt = [enddt compare:self.Trip.enddt];

        if (resulttripstartdt == NSOrderedAscending) {
            AdjustTripStartDt = true;
        }
        if (resulttripenddt == NSOrderedDescending) {
            AdjustTripEndDt = true;
        }
    
        RLMResults <ActivityRLM*> *activities = [ActivityRLM objectsWhere:@"tripkey=%@ and state=%@",self.Trip.key, self.Activity.state];

        if (activities.count==0) {
            [self UpdateActivityRealmData];
        } else {
            
            NSString *AlertMessage = [[NSString alloc] init];

            bool ErrorInCurrentItem = false;
            for (ActivityRLM* activity in activities) {
                
                /* we do not want to waste comparing activity against itself */
                if (![self.Activity.key isEqualToString:activity.key]) {
 
                    /* new block from 2019-08-27 start */

                    bool isStartDtInsideRange = [self isDate:self.startDt  inRangeFirstDate:activity.startdt lastDate:activity.enddt];
                    
                    bool isEndDtInsideRange = [self isDate:self.endDt  inRangeFirstDate:activity.startdt lastDate:activity.enddt];
                    
                    if ((isStartDtInsideRange && isEndDtInsideRange) || (!isStartDtInsideRange && !isEndDtInsideRange)) {
                        NSLog(@"Activity has dates that are allowed!");
                    } else {
                        
                        ErrorInCurrentItem = true;
                        NSString *prettystartdt = [self FormatPrettyDate :activity.startdt :[NSTimeZone timeZoneWithName:self.StartDtTimeZoneNameTextField.text] :@"\n"];
                        
                        NSString *prettyenddt = [self FormatPrettyDate :activity.enddt :[NSTimeZone timeZoneWithName:self.EndDtTimeZoneNameTextField.text] :@"\n"];
                        
                        
                        
                        AlertMessage = [NSString stringWithFormat:@"The start and end dates of current activity must be contained within the activity %@ with date range %@ and %@ or outside of these bounds. Please modify and correct before updating.", prettystartdt, prettyenddt, activity.name];
                        break;
                        
                    }
                    /* new block from 2019-08-27 end */
                }
            }
            if (ErrorInCurrentItem) {
                
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Error in date range"
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
                
            } else  {
                /* only perform this batch update if no errors have occurred beforehand & we are working on planned activities */
            
                for (ActivityRLM* activity in activities) {
                    /* we do not want to waste comparing activity against itself */
                    if (![self.Activity.key isEqualToString:activity.key]) {
                        NSDate *activitystartdt = activity.startdt;
                        NSDate *activityenddt = activity.enddt;
                        /* organize planned draft items to match expected modification to Trip  */
                        if (AdjustTripStartDt || AdjustTripEndDt) {
                            NSComparisonResult resultoriginalstartdt = [self.Trip.startdt compare:activitystartdt];
                            NSComparisonResult resultoriginalenddt = [self.Trip.enddt compare:activityenddt];
                            if (resultoriginalstartdt == NSOrderedSame && resultoriginalenddt == NSOrderedSame) {
                                [activity.realm beginWriteTransaction];
                                activity.startdt = startdt;
                                activity.enddt = enddt;
                                [activity.realm commitWriteTransaction];
                            }
                        }
                    }
                }
                /* new block to update also the Trip information to reflect changes made over the activity */
                if (AdjustTripStartDt || AdjustTripEndDt) {
            
                    if (AdjustTripStartDt) {
                        [self.Trip.realm beginWriteTransaction];
                        self.Trip.startdt = startdt;
                        [self.Trip.realm commitWriteTransaction];
                    }
                    if (AdjustTripEndDt) {
                        [self.Trip.realm beginWriteTransaction];
                        self.Trip.enddt = enddt;
                        [self.Trip.realm commitWriteTransaction];
                    }
                    
                }

                [self UpdateActivityRealmData];
            }
        }
    
}

/*
 created date:      21/02/2019
 last modified:     20/06/2019
 remarks:           
 */
- (void)UpdateActivityRealmData
{
    if (self.newitem || self.transformed) {
        /* working */
        self.Activity.name = self.TextFieldName.text;
        self.Activity.privatenotes = self.TextViewNotes.text;
        self.Activity.reference = self.TextFieldReference.text;
        self.Activity.rating = [NSNumber numberWithFloat: self.ViewStarRating.value];
        self.Activity.modifieddt = [NSDate date];
        self.Activity.createddt = [NSDate date];
        self.Activity.startdttimezonename = self.StartDtTimeZoneNameTextField.text;
        self.Activity.enddttimezonename = self.EndDtTimeZoneNameTextField.text;
        self.Activity.defaulttimezonename = self.Trip.defaulttimezonename;
        self.Activity.poi = self.Poi;
        self.Activity.poikey = self.Poi.key;
        self.Activity.tripkey = self.Trip.key;
        self.Activity.startdt = self.startDt;
        self.Activity.enddt = self.endDt;

        if ([self.SwitchTweet isOn]) {
            self.Activity.IncludeInTweet = [NSNumber numberWithInt:1];
        } else {
            self.Activity.IncludeInTweet = [NSNumber numberWithInt:0];
        }

        if (self.newitem) self.Activity.key = [[NSUUID UUID] UUIDString];
        self.Activity.compondkey = [NSString stringWithFormat:@"%@~%@",self.Activity.key,self.Activity.state];
        
        if (self.toggleNotifyArrivingFlag == 1) {
            // we have only just switched this on.
            [self InitGeoNotification:@"CheckInCategory" :true :[NSString stringWithFormat: @"Arrived at location you planned to be at %@", [self FormatPrettyDate :self.Activity.startdt :[NSTimeZone timeZoneWithName:self.StartDtTimeZoneNameTextField.text] :@"\n"]]];
            self.Activity.geonotification = [NSNumber numberWithInt:1];
            self.Activity.geonotifycheckindt = [NSDate date];
        } else {
            self.Activity.geonotification = [NSNumber numberWithInt:0];
        }
        
        if (self.toggleNotifyLeavingFlag == 1) {
            // we have only just switched this on.
            [self InitGeoNotification:@"CheckOutCategory" :false :[NSString stringWithFormat: @"Departed location you planned to leave at %@", [self FormatPrettyDate :self.Activity.enddt :[NSTimeZone timeZoneWithName:self.EndDtTimeZoneNameTextField.text] :@"\n"]]];
            self.Activity.geonotifycheckout = [NSNumber numberWithInt:1];
            self.Activity.geonotifycheckoutdt = [NSDate date];
        } else {
            self.Activity.geonotifycheckout = [NSNumber numberWithInt:0];
        }
        
        if (self.Activity.images.count > 0) {

            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *imagesDirectory = [paths objectAtIndex:0];
            
            NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/Trips/%@/Activities/%@",self.Activity.tripkey, self.Activity.compondkey]];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
            
            int counter = 1;
            for (ImageCollectionRLM *activityimgobject in self.Activity.images) {
                NSData *imageData =  UIImagePNGRepresentation([self.ActivityImageDictionary objectForKey:activityimgobject.key]);
                NSString *filename = [NSString stringWithFormat:@"%@.png", [[NSUUID UUID] UUIDString]];
                NSString *filepathname = [dataPath stringByAppendingPathComponent:filename];
                [imageData writeToFile:filepathname atomically:YES];
                //activityimgobject.NewImage = true;
                activityimgobject.ImageFileReference = [NSString stringWithFormat:@"/Images/Trips/%@/Activities/%@/%@",self.Activity.tripkey, self.Activity.compondkey,filename];
                //activityimgobject.State = self.Activity.state;
                counter++;
            }
        }
        
        [self.realm beginWriteTransaction];
        [self.realm addObject:self.Activity];
        [self.realm commitWriteTransaction];
        [self dismissModalStack];

    } else {
        [self.Activity.realm beginWriteTransaction];
        self.Activity.name = self.TextFieldName.text;
        self.Activity.privatenotes = self.TextViewNotes.text;
        self.Activity.reference = self.TextFieldReference.text;
        self.Activity.rating = [NSNumber numberWithFloat: self.ViewStarRating.value];
        self.Activity.modifieddt = [NSDate date];
        self.Activity.startdt = self.startDt;
        self.Activity.enddt = self.endDt;
        self.Activity.startdttimezonename = self.StartDtTimeZoneNameTextField.text;
        self.Activity.enddttimezonename = self.EndDtTimeZoneNameTextField.text;
        self.Activity.defaulttimezonename = self.Trip.defaulttimezonename;
        if ([self.SwitchTweet isOn]) {
            self.Activity.IncludeInTweet = [NSNumber numberWithInt:1];
        } else {
            self.Activity.IncludeInTweet = [NSNumber numberWithInt:0];
        }

        
        if (self.toggleNotifyArrivingFlag == 1 && (self.Activity.geonotification == [NSNumber numberWithLong:0] || self.Activity.geonotification == nil)) {
            // we have only just switched this on.
            [self InitGeoNotification:@"CheckInCategory" :true :[NSString stringWithFormat: @"Arrived at location you originally planned to be at %@", [self FormatPrettyDate :self.Activity.startdt :[NSTimeZone timeZoneWithName:self.StartDtTimeZoneNameTextField.text] :@"\n"]]];
            self.Activity.geonotification = [NSNumber numberWithInt:1];
            self.Activity.geonotifycheckindt = [NSDate date];
        } else if (self.toggleNotifyArrivingFlag == 0 && self.Activity.geonotification == [NSNumber numberWithLong:1]) {
            // run through removal
            [self setGeoNotifyOff :true];
            self.Activity.geonotification = [NSNumber numberWithInt:0];
        }
        
        if (self.toggleNotifyLeavingFlag == 1 && (self.Activity.geonotifycheckout == [NSNumber numberWithLong:0] || self.Activity.geonotifycheckout == nil)) {
            // we have only just switched this on.
            [self InitGeoNotification:@"CheckOutCategory" :false :[NSString stringWithFormat: @"Departed location you originally planned to leave at %@", [self FormatPrettyDate :self.Activity.enddt:[NSTimeZone timeZoneWithName:self.EndDtTimeZoneNameTextField.text] :@"\n"]]];
            self.Activity.geonotifycheckout = [NSNumber numberWithInt:1];
            self.Activity.geonotifycheckoutdt = [NSDate date];
        } else if (self.toggleNotifyLeavingFlag == 0 && self.Activity.geonotifycheckout == [NSNumber numberWithLong:1]) {
            // run through removal
             [self setGeoNotifyOff :false];
            self.Activity.geonotifycheckout = [NSNumber numberWithInt:0];
        }
        
        
        if (self.Activity.images.count>0) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *imagesDirectory = [paths objectAtIndex:0];
            
            NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/Trips/%@/Activities/%@",self.Trip.key, self.Activity.compondkey]];
            
            
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
            
            NSInteger count = [self.Activity.images count];
            
            for (NSInteger index = (count - 1); index >= 0; index--) {
                ImageCollectionRLM *imgobject = self.Activity.images[index];
                
                if (imgobject.ImageFlaggedDeleted) {
                    /* else we are good to delete it */
                    NSString *filepathname = [imagesDirectory stringByAppendingPathComponent:imgobject.ImageFileReference];
                    NSError *error = nil;
                    BOOL success = [fm removeItemAtPath:filepathname error:&error];
                    if (!success || error) {
                        NSLog(@"something failed in deleting unwanted data");
                    }
                    
                    [self.Activity.images removeObjectAtIndex:index];
                    
                } else if ([imgobject.ImageFileReference isEqualToString:@""] || imgobject.ImageFileReference==nil) {
                    /* here we add the attachment to file system and dB */
                    imgobject.NewImage = true;
                    NSData *imageData =  UIImagePNGRepresentation([self.ActivityImageDictionary objectForKey:imgobject.key]);
                    NSString *filename = [NSString stringWithFormat:@"%@.png", imgobject.key];
                    NSString *filepathname = [dataPath stringByAppendingPathComponent:filename];
                    [imageData writeToFile:filepathname atomically:YES];
                    
                    imgobject.ImageFileReference = [NSString stringWithFormat:@"Images/Trips/%@/Activities/%@/%@",self.Trip.key, self.Activity.compondkey,filename];
                    NSLog(@"new image");
                    [delegate didUpdateActivityImages:true];
                    
                } else if (imgobject.UpdateImage) {
                    /* we might swap it out as user has replaced the original file */
                    NSData *imageData =  UIImagePNGRepresentation([self.ActivityImageDictionary objectForKey:imgobject.key]);
                    NSString *filepathname = [imagesDirectory stringByAppendingPathComponent:imgobject.ImageFileReference];
                    [imageData writeToFile:filepathname atomically:YES];
                    NSLog(@"updated image");
                    [delegate didUpdateActivityImages:true];
                }
            }
        }
        [self.Activity.realm commitWriteTransaction];
        [self dismissModalStack];
    }
}


/*
 created date:      24/02/2019
 last modified:     24/02/2019
 remarks:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*
 created date:      24/02/2019
 last modified:     16/08/2019
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.DocumentCollection.count + 1;
}


/*
 created date:      25/02/2019
 last modified:     16/08/2019
 remarks:           table view with sections.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttachmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttachmentCellId"];
    NSInteger NumberOfItems = self.DocumentCollection.count + 1;
    if (indexPath.row == NumberOfItems -1) {
        cell.LabelInfo.hidden = false;
        cell.LabelNotes.text = @"";
        //[cell.LabelNotes setTextColor:[UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
        cell.LabelUploadedDt.text = @"";
        cell.ButtonAddNew.hidden = false;
        cell.ImageViewChecked.hidden = true;
    } else {
        AttachmentRLM *attachmentobject = [self.DocumentCollection objectAtIndex:indexPath.row];
        cell.LabelInfo.hidden = true;
        cell.LabelNotes.text = attachmentobject.notes;
        //[cell.LabelNotes setTextColor:[UIColor colorWithRed:49.0f/255.0f green:163.0f/255.0f blue:0.0f/255.0f alpha:1.0]];
        if (attachmentobject.importeddate != nil) {
            cell.LabelUploadedDt.text = [NSString stringWithFormat:@"%@", [ToolBoxNSO FormatPrettyDate:attachmentobject.importeddate]];
        } else {
            cell.LabelUploadedDt.text = @"from the Point Of Interest";
        }
        cell.ButtonAddNew.hidden = true;
        cell.ImageViewChecked.hidden = false;
    }
    return cell;
}

/*
 created date:      25/02/2019
 last modified:     25/02/2019
 remarks:           table view with sections.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger NumberOfItems = self.DocumentCollection.count + 1;
    if (indexPath.row == NumberOfItems -1 ) {
        
    } else {
        AttachmentRLM *attachmentobject = [self.DocumentCollection objectAtIndex:indexPath.row];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        
        NSString *PdfDataFilePath = [documentDirectory stringByAppendingPathComponent:attachmentobject.filename];

        NSURL *targetURL = [NSURL fileURLWithPath:PdfDataFilePath];
        NSData *data = [NSData dataWithContentsOfURL:targetURL];

        [self.WebViewPreview loadData:data MIMEType:@"application/pdf" characterEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
        
    }
}

/*
 created date:      25/02/2019
 last modified:     25/02/2019
 remarks:           table view with sections.
 */
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // rows in section 0 should not be selectable
    if ( indexPath.row ==  self.DocumentCollection.count) return nil;
    return indexPath;
}

/*
 created date:      03/05/2018
 last modified:     20/03/2019
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ShowPoiPreview"]){
        PoiPreviewVC *controller = (PoiPreviewVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.PointOfInterest = self.Poi;
        controller.headerImage = self.ImageViewPoi.image;
    } else if ([segue.identifier isEqualToString:@"ShowDocuments"]){
        DocumentsVC *controller = (DocumentsVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.Activity = self.Activity;
        controller.realm = self.realm;
        
    } else if ([segue.identifier isEqualToString:@"ShowPayments"]){
        PaymentListingVC *controller = (PaymentListingVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.ActivityItem = self.Activity;
        controller.activitystate = self.Activity.state;
        if (self.Activity.images.count > 0) {
            controller.headerImage = self.ImageViewKeyActivity.image;
        } else {
            if (self.Poi.images.count > 0) {
                 controller.headerImage = self.PoiImage;
            } else {
                if (self.Activity.state == [NSNumber numberWithInteger:0]) {
                    controller.headerImage = [UIImage imageNamed:@"Planning"];
                } else {
                    controller.headerImage = [UIImage imageNamed:@"Activity"];
                }
            }
        }
        /* here we add something new */
        controller.realm = self.realm;
        controller.TripItem = nil;
    }
}

/*
 created date:      30/04/2018
 last modified:     21/10/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    if (self.newitem) {
        /* manage the images if any exist */
        if (self.Activity.images.count>0) {
            /* delete all */
            [self.realm transactionWithBlock:^{
                [self.realm deleteObjects:self.Activity.images];
            }];
        }
    } else {
        if (self.Activity.images.count > 0) {
            NSInteger count = [self.Activity.images count];
            [self.realm beginWriteTransaction];
            for (NSInteger index = (count - 1); index >= 0; index--) {
                ImageCollectionRLM *imgobject = self.Activity.images[index];
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
    [self dismissModalStack];
}

/*
 created date:      19/03/2019
 last modified:     22/07/2019
 remarks:
 */
-(void)dismissModalStack {
    UIViewController *vc = self.presentingViewController;
    NSString *strClass = NSStringFromClass([vc class]);
    while (![strClass isEqualToString:@"ActivityListVC"] && ![strClass isEqualToString:@"TravelPlanVC"]) {
        vc = vc.presentingViewController;
        strClass = NSStringFromClass([vc class]);
    }
    [vc dismissViewControllerAnimated:YES completion:NULL];
}

/*
 created date:      04/05/2018
 last modified:     09/09/2018
 remarks:
 */
- (void)didPickDateSelection :(NSDate*)Start :(NSDate*)End {
    
    [self.realm beginWriteTransaction];
    self.Activity.startdt = Start;
    self.Activity.enddt = End;
    [self.realm commitWriteTransaction];
}


/*
 created date:      15/08/2019
 last modified:     15/08/2019
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
 created date:      13/05/2018
 last modified:     20/03/2019
 remarks:
 */
- (IBAction)CheckInOutPressed:(id)sender {
    
    NSDate *today = [NSDate date];
    
    if (self.newitem || self.transformed) {
        
        self.Activity.startdt = today;
        self.Activity.enddt = today;
        
        self.Activity.poi = self.Poi;
        
        if (self.newitem) self.Activity.key = [[NSUUID UUID] UUIDString];
        [self.realm beginWriteTransaction];
        [self.realm addObject:self.Activity];
        [self.realm commitWriteTransaction];

        [self.delegate didUpdateActivityImages :true];
        // double dismissing so we flow back to the activity window bypassing the search..
        [self dismissModalStack];

    } else {
        [self.realm beginWriteTransaction];
        self.Activity.enddt = today;
        [self.realm commitWriteTransaction];
        [self.delegate didUpdateActivityImages :true];
        //[self dismissViewControllerAnimated:YES completion:Nil];
        [self dismissModalStack];
    }
}




/*
 created date:      13/05/2018
 last modified:     26/03/2019
 remarks:
 */
- (IBAction)SegmentPresenterChanged:(id)sender {
    
    if ([self.SegmentPresenter selectedSegmentIndex] == 0) {
        self.ViewMain.hidden = false;
        self.ViewNotes.hidden = true;
        self.ViewPhotos.hidden = true;
        self.ViewDocuments.hidden = true;
        self.ViewSettings.hidden = true;
        self.ButtonScan.hidden = false;
        self.ButtonUploadImage.hidden = true;
        self.ButtonPayment.hidden = false;
        self.ButtonDirections.hidden = false;
        self.SwitchViewPhotoOptions.hidden = true;
        
        
    } else if ([self.SegmentPresenter selectedSegmentIndex] == 1) {
        self.ViewMain.hidden = true;
        self.ViewNotes.hidden = true;
        self.ViewPhotos.hidden = false;
        self.ViewDocuments.hidden = true;
        self.ViewSettings.hidden = true;
        self.ButtonScan.hidden = true;
        self.ButtonUploadImage.hidden = false;
        self.ButtonPayment.hidden = true;
        self.ButtonDirections.hidden = true;
        self.SwitchViewPhotoOptions.hidden = false;
        
    } else if ([self.SegmentPresenter selectedSegmentIndex] == 2) {
        
        
        // only do this once.
        if (self.DocumentCollection.count > 0 && [self.WebViewPreview isHidden]) {
            AttachmentRLM *attachmentobject = [self.DocumentCollection objectAtIndex:0];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];
            
            NSString *PdfDataFilePath = [documentDirectory stringByAppendingPathComponent:attachmentobject.filename];
            
            NSURL *targetURL = [NSURL fileURLWithPath:PdfDataFilePath];
            NSData *data = [NSData dataWithContentsOfURL:targetURL];
            
            [self.WebViewPreview loadData:data MIMEType:@"application/pdf" characterEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
        }
        [self.WebViewPreview setHidden:FALSE];
        self.ViewMain.hidden = true;
        self.ViewNotes.hidden = true;
        self.ViewDocuments.hidden = false;
        self.ViewSettings.hidden = true;
        self.ViewPhotos.hidden = true;
        self.ButtonScan.hidden = true;
        self.ButtonUploadImage.hidden = true;
        self.ButtonPayment.hidden = true;
        self.ButtonDirections.hidden = true;
        self.SwitchViewPhotoOptions.hidden = true;
        
        
    } else if ([self.SegmentPresenter selectedSegmentIndex] == 3) {
        self.ViewMain.hidden = true;
        self.ViewNotes.hidden = true;
        self.ViewDocuments.hidden = true;
        self.ViewSettings.hidden = false;
        self.ViewPhotos.hidden = true;
        self.ButtonScan.hidden = true;
        self.ButtonUploadImage.hidden = false;
        self.ButtonPayment.hidden = true;
        self.ButtonDirections.hidden = true;
        self.SwitchViewPhotoOptions.hidden = true;
    }
    
}



/*
 created date:      19/08/2018
 last modified:     30/03/2019
 remarks:
 */
-(void)InsertActivityImage {
    
    //CHANGE
    NSString *titleMessage = @"How would you like to add a photo to your Activity?";
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
                                                                         copiedpoi.key = self.Poi.key;
                                                                         copiedpoi.lon = self.Poi.lon;
                                                                         copiedpoi.lat = self.Poi.lat;
                                                                         copiedpoi.name = self.Poi.name;
                                                                         
                                                                         controller.PointOfInterest = copiedpoi;
                                                                         
                                                                         controller.distance = self.Poi.radius;
                                                                         
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
                                                                  copiedpoi.key = self.Poi.key;
                                                                  copiedpoi.lon = self.Poi.lon;
                                                                  copiedpoi.lat = self.Poi.lat;
                                                                  copiedpoi.name = self.Poi.name;
                                                                  copiedpoi.wikititle = self.Poi.wikititle;
                                                                  controller.PointOfInterest = copiedpoi;
                                                                  
                                                                  controller.distance = self.Poi.radius;
                                                                  
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
                                      CGSize size = CGSizeMake(self.ScrollViewImage.frame.size.width * 2, self.ScrollViewImage.frame.size.width * 2);
                                      
                                      [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                                                                 targetSize:size
                                                                                contentMode:PHImageContentModeAspectFill
                                                                                    options:options
                                                                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                                  
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  
                                                  CGSize size = CGSizeMake(self.ScrollViewImage.frame.size.width * 2, self.ScrollViewImage.frame.size.width * 2);
                                                  
                                                  if (self.imagestate==1) {
                                                      
                                                      ImageCollectionRLM *imgobject = [[ImageCollectionRLM alloc] init];
                                                      imgobject.key = [[NSUUID UUID] UUIDString];
                                                      
                                                      UIImage *image = [ToolBoxNSO imageWithImage:result scaledToSize:size];
                                                      
                                                      if (self.Activity.images.count==0) {
                                                          imgobject.KeyImage = 1;
                                                      } else {
                                                          imgobject.KeyImage = 0;
                                                      }
                                                      
                                                      [self.realm beginWriteTransaction];
                                                      [self.Activity.images addObject:imgobject];
                                                      [self.realm commitWriteTransaction];
                                                      
                                                      [self.ActivityImageDictionary setObject:image forKey:imgobject.key];
                                                      
                                                  } else if (self.imagestate==2) {
                                                      
                                                      ImageCollectionRLM *imgobject = [self.Activity.images objectAtIndex:[self.SelectedImageIndex longValue]];
                                                      
                                                      UIImage *image = [ToolBoxNSO imageWithImage:result scaledToSize:size];
                                                      
                                                      [self.ActivityImageDictionary setObject:image forKey:imgobject.key];

                                                      [self.realm beginWriteTransaction];
                                                      imgobject.UpdateImage = true;
                                                      [self.realm commitWriteTransaction];
                                                  }
                                                  [self.CollectionViewActivityImages reloadData];
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
    if (![self.Poi.wikititle isEqualToString:@""]) {
        [alert addAction:photoWikiAction];
    }
    [alert addAction:lastphotoAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/* Delegate methods for ScrollView */
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [self.ScrollViewImage viewWithTag:5];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
}

/*
 created date:      19/08/2018
 last modified:     21/10/2018
 remarks:
 */

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // OCR scan
    if (self.imagestate==3) {
        
        UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
        TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:originalImage];
        cropViewController.delegate = self;
        [picker dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:cropViewController animated:YES completion:nil];
        }];
        
    } else {
    
        /* obtain the image from the camera */
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
            
            
            if (self.Activity.images.count==0) {
                imgobject.KeyImage = 1;
            } else {
                imgobject.KeyImage = 0;
            }
            
            [self.realm beginWriteTransaction];
            [self.Activity.images addObject:imgobject];
            [self.realm commitWriteTransaction];
            
            [self.ActivityImageDictionary setObject:chosenImage forKey:imgobject.key];
            
            
        } else if (self.imagestate == 2) {
            ImageCollectionRLM *imgobject = [self.Activity.images objectAtIndex:[self.SelectedImageIndex longValue]];
            
            [self.realm beginWriteTransaction];
            imgobject.UpdateImage = true;
            [self.realm commitWriteTransaction];
            
            [self.ActivityImageDictionary setObject:chosenImage forKey:imgobject.key];
            
        }
        [self.delegate didUpdateActivityImages :true];
        [self.CollectionViewActivityImages reloadData];
        [picker dismissViewControllerAnimated:YES completion:NULL];
        
    }
    self.imagestate = 0;
}


/*
 created date:      29/09/2018
 last modified:     29/09/2018
 remarks:           TODO - is it worth presenting the black and white image?
 */
- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
    tesseract.delegate = self;
    
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
 created date:      19/08/2018
 last modified:     01/08/2018
 remarks:
 */
- (void)didAddImages :(NSMutableArray*)ImageCollection {
    
    
    
    bool AddedImage = false;
    for (ImageNSO *img in ImageCollection) {
        
        ImageCollectionRLM *imgobject = [[ImageCollectionRLM alloc] init];
        imgobject.key = [[NSUUID UUID] UUIDString];
        [self.ActivityImageDictionary setObject:img.Image forKey:imgobject.key];
        
        if (self.Activity.images.count==0) {
            imgobject.KeyImage = 1;
        } else {
            imgobject.KeyImage = 0;
        }
        imgobject.info = img.Description;
        [self.realm beginWriteTransaction];
        [self.Activity.images addObject:imgobject];
        [self.realm commitWriteTransaction];
        
        AddedImage = true;
    }
    if (AddedImage) {
        [self.CollectionViewActivityImages reloadData];
        [self.delegate didUpdateActivityImages :true];
    }
}



/*
 created date:      19/08/2018
 last modified:     19/08/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.Activity.images.count + 1;
    
}

/*
 created date:      19/04/2018
 last modified:     03/03/2019
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ActivityImageCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"ActivityImageId" forIndexPath:indexPath];
    NSInteger NumberOfItems = self.Activity.images.count + 1;
    if (indexPath.row == NumberOfItems -1) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightThin];
              
        cell.ImageActivity.image = [UIImage systemImageNamed:@"plus.circle" withConfiguration:config];
        [cell.ImageActivity setTintColor: [UIColor colorNamed:@"TrippoColor"]];

    } else {
        ImageCollectionRLM *imgobject = [self.Activity.images objectAtIndex:indexPath.row];
        cell.ImageActivity.image = [self.ActivityImageDictionary objectForKey: imgobject.key];
    }
    return cell;
}


/*
 created date:      28/04/2018
 last modified:     01/09/2018
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    /* add the insert method if found to be last cell */

    NSInteger NumberOfItems = self.Activity.images.count + 1;
        
    if (indexPath.row == NumberOfItems - 1) {
        self.imagestate = 1;
        [self InsertActivityImage];
    } else {
        if (!self.newitem) {
            ImageCollectionRLM *imgobject = [self.Activity.images objectAtIndex:indexPath.row];
            self.SelectedImageKey = imgobject.key;
            self.SelectedImageReference = imgobject.ImageFileReference;
            self.SelectedImageIndex = [NSNumber numberWithLong:indexPath.row];
            if (imgobject.KeyImage==0) {
                self.ViewSelectedKey.hidden = true;
            } else {
                self.ViewSelectedKey.hidden = false;
            }
            [self.ImagePicture setImage: [self.ActivityImageDictionary objectForKey: imgobject.key]];
            
            if (imgobject.ImageFlaggedDeleted==0) {
                self.ViewTrash.hidden = true;
            } else {
                self.ViewTrash.hidden = false;
            }
            
        }
        else {
            ImageCollectionRLM *imgobject = [self.Activity.images objectAtIndex:indexPath.row];
            [self.ImagePicture setImage: [self.ActivityImageDictionary objectForKey: imgobject.key]];
        }
    }
}

- (void)didCreatePoiFromProject :(NSString*)Key {
}



// It is important for you to hide the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.TextFieldName.backgroundColor = [UIColor clearColor];
    [textField resignFirstResponder];
    return YES;
}

/*
 created date:      15/07/2018
 last modified:     12/08/2018
 remarks:
 */
- (void)didUpdatePoi :(NSString*)Method :(PoiNSO*)Object {

}


/*
 created date:      19/08/2018
 last modified:     19/08/2018
 remarks:
 */

- (IBAction)SwitchViewPhotoOptionsChanged:(id)sender {
    [self.view layoutIfNeeded];
    
    if (self.ViewPhotos.hidden == false) {
        bool showkeyview = self.ViewSelectedKey.hidden;
        bool showdeletedflag = self.ViewTrash.hidden;
        self.ViewSelectedKey.hidden = true;
        self.ViewTrash.hidden = true;
        if (self.ViewBlurHeightConstraint.constant==BlurredImageViewPresentedHeight) {
            
            [UIView animateWithDuration:0.5 animations:^{
                self.ViewBlurHeightConstraint.constant=0;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.ViewSelectedKey.hidden = showkeyview;
                self.ViewTrash.hidden = showdeletedflag;
            }];
            
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                self.ViewBlurHeightConstraint.constant=BlurredImageViewPresentedHeight;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.ViewSelectedKey.hidden = showkeyview;
                self.ViewTrash.hidden = showdeletedflag;
            }];
        }
    } else if (self.ViewMain.hidden == false) {

        if (self.ViewEffectBlurDetailHeightConstraint.constant==BlurredMainViewPresentedHeight) {
            [UIView animateWithDuration:0.5 animations:^{
                self.ViewEffectBlurDetailHeightConstraint.constant=0;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                
            }];
            
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                self.ViewEffectBlurDetailHeightConstraint.constant=BlurredMainViewPresentedHeight;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
            }];
        }
    }
}

/*
 created date:      19/08/2018
 last modified:     19/08/2018
 remarks:
 */
- (IBAction)DeleteImageButtonPressed:(id)sender {
    bool DeletedFlagEnabled = false;
    if (self.Activity.images.count==0) {
        self.ViewBlurImageOptionPanel.hidden = true;
    } else {
        for (ImageNSO *item in self.Activity.images) {
            
            if ([item.ImageFileReference isEqualToString:self.SelectedImageReference]) {
                [self.realm beginWriteTransaction];
                if (item.ImageFlaggedDeleted==0) {
                    
                    self.ViewTrash.hidden = false;
                    item.ImageFlaggedDeleted = 1;
                    DeletedFlagEnabled = true;
                    item.UpdateImage = true;
                    
                }
                else {
                    self.ViewTrash.hidden = true;
                    item.ImageFlaggedDeleted = 0;
                }
                [self.realm commitWriteTransaction];
            }
        }
    }
}

/*
 created date:      19/08/2018
 last modified:     19/08/2018
 remarks:
 */
- (IBAction)KeyImageButtonPressed:(id)sender {
    bool KeyImageEnabled = false;
    if (self.Activity.images.count==0) {
        self.ViewBlurImageOptionPanel.hidden = true;
    } else if (self.Activity.images.count==1) {
        
    } else {
        [self.realm beginWriteTransaction];
        for (ImageNSO *item in self.Activity.images) {
            if ([item.ImageFileReference isEqualToString:self.SelectedImageReference]) {
                if (item.KeyImage==0) {
                    self.ViewSelectedKey.hidden = false;
                    item.KeyImage = 1;
                    KeyImageEnabled = true;
                    item.UpdateImage = true;
                } else {
                    self.ViewSelectedKey.hidden = true;
                    item.KeyImage = 0;
                    item.UpdateImage = true;
                }
            } else {
                if (item.KeyImage == 1) {
                    item.KeyImage = 0;
                    item.UpdateImage = true;
                }
            }
        }
        [self.realm commitWriteTransaction];
    }
    [self.delegate didUpdateActivityImages :true];
    
}

/*
 created date:      19/08/2018
 last modified:     19/08/2018
 remarks:
 */
- (IBAction)EditButtonPressed:(id)sender {
    self.imagestate = 2;
    [self InsertActivityImage];
}

/*
 created date:      08/09/2018
 last modified:     14/09/2018
 remarks:
 */
- (IBAction)UploadImagePressed:(id)sender {
    

    NSData *dataImage = UIImagePNGRepresentation(self.ImagePicture.image);
    NSString *stringImage = [dataImage base64EncodedStringWithOptions:0];

    NSString *ImageFileReference = [NSString stringWithFormat:@"Images/Trips/%@/Activities/%@/%@.png",self.Activity.tripkey, self.Activity.compondkey, self.SelectedImageKey];

    NSString *ImageFileDirectory = [NSString stringWithFormat:@"Images/Trips/%@/Activities/%@",self.Activity.tripkey, self.Activity.compondkey];
    
    NSDictionary* dataJSON = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Activity",
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
    url = [url URLByAppendingPathComponent:@"Activity.trippo"];
    
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
 created date:      09/09/2018
 last modified:     09/09/2018
 remarks:  TODO, make sure it is optimal and not called multiple times!
 */
- (void)didUpdateActivityImages :(bool)ForceUpdate {
    
}

/*
 created date:      29/09/2018
 last modified:     29/09/2018
 remarks:           OCR obtain image and scan for text
 */
- (IBAction)ScanButtonPressed:(id)sender {
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
 created date:      09/10/2018
 last modified:     23/10/2018
 remarks:           Give user option of origins..
 */
- (IBAction)ShowDirectionsPressed:(id)sender {

    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    
    RLMResults <ActivityRLM*> *ActivitiesInTrip = [ActivityRLM objectsWhere:@"tripkey = %@ and state=%@", self.Trip.key, self.Activity.state];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startdt < %@", self.Activity.startdt];
    
    RLMResults *filteredActivities = [ActivitiesInTrip objectsWithPredicate:predicate];

    filteredActivities = [filteredActivities sortedResultsUsingDescriptors:@[
                                                                             [RLMSortDescriptor sortDescriptorWithKeyPath:@"startdt" ascending:NO]]];

    
    int MaxList = 8;
    if (filteredActivities.count < MaxList) {
        MaxList = (int)filteredActivities.count;
    }

    UIAlertController * alertPickOrigin = [UIAlertController
                                           alertControllerWithTitle:@"Origin"
                                           message:[NSString stringWithFormat:@"Choose the location you wish to travel from to get to %@", self.Activity.name]
                                           preferredStyle:UIAlertControllerStyleAlert];
    
    [alertPickOrigin.view setTintColor:[UIColor labelColor]];
    
    UIAlertAction* action = [UIAlertAction
                             actionWithTitle:@"My current position"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 
                                 [self MapEngineSelection :nil :self.Poi];
                                 
                             }];
    
    [alertPickOrigin addAction:action];

    for (NSInteger index = 0; index < MaxList; index++) {

        ActivityRLM *item = [filteredActivities objectAtIndex:index];
        PoiRLM *poiitem = item.poi;

        if (poiitem == nil) {
            poiitem = [PoiRLM objectForPrimaryKey:item.poikey];
        }
        
        UIAlertAction* action = [UIAlertAction
                                 actionWithTitle:item.name
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     [self MapEngineSelection :poiitem :self.Poi];
                                 }];
        
        [alertPickOrigin addAction:action];
    }
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                         }];
    
    [alertPickOrigin addAction:cancelAction];
    [self presentViewController:alertPickOrigin animated:YES completion:nil];

}


-(void) MapEngineSelection :(PoiRLM*) from :(PoiRLM*) to {
    
    NSString *messageText = [[NSString alloc] init];
 
    if (from == nil) {
        messageText = [NSString stringWithFormat:@"Choose the map you wish to present and calculate selected route between your current position and %@", to.name];
    } else {
        messageText = [NSString stringWithFormat:@"Choose the map you wish to present and calculate selected route of %@ to %@", from.name, to.name];
    }
    
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
                                 if (from == nil) {
                                     directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%@,%@",self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude, to.lat, to.lon];
                                 } else {
                                     directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%@,%@&daddr=%@,%@",from.lat, from.lon, to.lat, to.lon];
                                 }
                                 
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
                                      
                                      if (from == nil) {
                                          directionsURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%@,%@",self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude, to.lat, to.lon];
                                      } else {
                                          directionsURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@,%@&daddr=%@,%@",from.lat, from.lon, to.lat, to.lon];
                                      }
                                      
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
 created date:      22/10/2018
 last modified:     22/10/2018
 remarks:
 */
- (void)cancelButtonPressed:(UIButton *)sender {
    NSLog(@"Button cancelled Pressed!");
    [[self.view.subviews objectAtIndex:(self.view.subviews.count - 1)]removeFromSuperview];
}

-(void)doneButtonClickedDismissDatePicker
{
    [self.TextFieldStartDt resignFirstResponder];
    [self.TextFieldEndDt resignFirstResponder];
}

/*
 created date:      17/02/2019
 last modified:     17/02/2019
 remarks:           resizes the textview control to allow for keyboard view.
 */
- (void) handleKeyboardDidShow:(NSNotification *)paramNotification{
    
    
    NSValue *keyboardRectAsObject =
    [[paramNotification userInfo]
     objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = CGRectZero;
    [keyboardRectAsObject getValue:&keyboardRect];
    
    self.ConstraintBottomNotes.constant = keyboardRect.size.height - 132;
    
    [self.TextViewNotes scrollRangeToVisible:self.TextViewNotes.selectedRange];
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
    
    /*
    NSDictionary* info = [paramNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect bkgndRect = self.TextViewNotes.superview.frame;
    bkgndRect.size.height += kbSize.height;
    [self.TextViewNotes.superview setFrame:bkgndRect];
    [self.ActivityScrollView setContentOffset:CGPointMake(0.0, self.TextViewNotes.frame.origin.y-kbSize.height) animated:YES];
    */
//    [self.TextViewNotes scrollRangeToVisible:self.TextViewNotes.selectedRange];
    // [self.TextViewNotes setNeedsDisplay];
}

/*
 created date:      26/02/2019
 last modified:     26/02/2019
 remarks:           resizes the listing of documents
 */
- (IBAction)ButtonExpandDocumentList:(id)sender {
    
    if (self.ViewDocumentListHeightConstraint.constant==DocumentListingViewPresentedHeight) {
        
        [UIView animateWithDuration:0.5 animations:^{
            self.ViewDocumentListHeightConstraint.constant=0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.ButtonExpandCollapseList setImage:[UIImage systemImageNamed:@"doc.circle"] forState:UIControlStateNormal];
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            self.ViewDocumentListHeightConstraint.constant=DocumentListingViewPresentedHeight;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self.ButtonExpandCollapseList setImage:[UIImage systemImageNamed:@"minus.circle"] forState:UIControlStateNormal];
        }];
    }
}

/*
 created date:      25/03/2019
 last modified:     16/06/2019
 remarks:           Create requested checkin/checkout notification.
 */
-(void) InitGeoNotification :(NSString *) CategoryIdentifier :(bool) NotifyOnEntry :(NSString *) Body {
    
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = [NSString stringWithFormat: @"Trippo Activity - %@\nOn Trip %@", self.Activity.name, self.Trip.name];
    if (NotifyOnEntry) {
        content.subtitle = @"Check In";
    } else {
        content.subtitle = @"Check Out";
    }
    content.body = Body;
    content.sound = [UNNotificationSound defaultSound];
    content.categoryIdentifier = CategoryIdentifier;
    
    NSString *identifier;
    
    if (NotifyOnEntry) {
        identifier = [NSString stringWithFormat:@"CHECKIN~%@", self.Activity.key];
    } else {
        identifier = [NSString stringWithFormat:@"CHECKOUT~%@", self.Activity.key];
    }
    
    NSNumber *radius = self.Poi.radius;
    if([radius longValue] > 7500) {
        radius = [NSNumber numberWithBool:7500];
    }

    CLLocationCoordinate2D center = CLLocationCoordinate2DMake([self.Poi.lat doubleValue], [self.Poi.lon doubleValue]);
    CLCircularRegion* region = [[CLCircularRegion alloc] initWithCenter:center
                                                                 radius:[radius longValue] identifier:[NSString stringWithFormat:@"REGION~%@", identifier]];
    
    region.notifyOnEntry = NotifyOnEntry;
    region.notifyOnExit = !NotifyOnEntry;
    
     UNLocationNotificationTrigger *locTrigger = [UNLocationNotificationTrigger triggerWithRegion:region repeats:YES];

     // UNTimeIntervalNotificationTrigger *locTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:60 repeats:YES];
    

    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                          content:content trigger:locTrigger];
    
    
    [AppDelegateDef.UserNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Something went wrong: %@",error);
        }
    }];
}


/*
 created date:      23/03/2019
 last modified:     16/06/2019
 remarks:           TODO!
 */
-(void) RemoveGeoNotification :(bool) NotifyOnEntry {
    NSString *identifier;
    
    if (NotifyOnEntry) {
        identifier = [NSString stringWithFormat:@"CHECKIN~%@", self.Activity.key];
    } else {
        identifier = [NSString stringWithFormat:@"CHECKOUT~%@", self.Activity.key];
    }
    
    NSArray *pendingNotification = [NSArray arrayWithObjects:identifier, nil];
    [AppDelegateDef.UserNotificationCenter removePendingNotificationRequestsWithIdentifiers:pendingNotification];
}



/*
 created date:      10/04/2019
 last modified:     16/06/2019
 remarks:           TODO!
 */
-(void) setGeoNotifyButton :(UIButton*)button :(bool)NotifyOnEntry {

    NSString *ActivityIdentifier;

    if (NotifyOnEntry) {
        ActivityIdentifier = [NSString stringWithFormat:@"CHECKIN~%@", self.Activity.key];
    } else {
        ActivityIdentifier = [NSString stringWithFormat:@"CHECKOUT~%@", self.Activity.key];
    }
    [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> *requests){
        
        NSLog(@"requests: %@", requests);
        for (UNNotificationRequest *object in requests) {
            NSString *identifier = object.identifier;
            
            if ([ActivityIdentifier isEqualToString:identifier]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                        button.hidden = false;
                });
            }
            
        }
    }];
}



/*
 created date:      10/04/2019
 last modified:     16/06/2019
 remarks:
 */
-(void) setGeoNotifyOff :(bool)NotifyOnEntry {
    NSString *identifier;

    if (NotifyOnEntry) {
       identifier = [NSString stringWithFormat:@"CHECKIN~%@", self.Activity.key];
    } else {
       identifier = [NSString stringWithFormat:@"CHECKOUT~%@", self.Activity.key];
    }

    NSArray *pendingNotification = [NSArray arrayWithObjects:identifier, nil];
    [AppDelegateDef.UserNotificationCenter removePendingNotificationRequestsWithIdentifiers:pendingNotification];
}



/*
 created date:      17/06/2019
 last modified:     17/06/2019
 remarks:           TODO!
 */
-(int) setNotifyButtonToggle :(UIButton*) button :(int) ToggleFlag   {
    
    int ModifiedToggleFlag=0;
    
    if (ToggleFlag == 0) {
        [button setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:102.0f/255.0f blue:51.0f/255.0f alpha:1.0]];
        ModifiedToggleFlag = 1;
    } else if(ToggleFlag == 1){
        // set whatever color you want after tap button
        [button setBackgroundColor:[UIColor lightGrayColor]];
    }

    
    return ModifiedToggleFlag;
}

/*
 created date:      17/06/2019
 last modified:     17/06/2019
 remarks:           TODO!
 */
- (IBAction)ButonArrivingPressed:(id)sender {
    self.toggleNotifyArrivingFlag = [self setNotifyButtonToggle:self.ButtonArriving :self.toggleNotifyArrivingFlag];
}

/*
 created date:      17/06/2019
 last modified:     17/06/2019
 remarks:           TODO!
 */
- (IBAction)ButtonLeavingPressed:(id)sender {
    self.toggleNotifyLeavingFlag = [self setNotifyButtonToggle:self.ButtonLeaving :self.toggleNotifyLeavingFlag];
}

/*
 created date:      24/06/2019
 last modified:     27/08/2019
 remarks:           TODO!
 */
- (IBAction)ButtonUpdateWeatherForActualPressed:(id)sender {


    [self.ButtonUpdateActualWeather setEnabled:FALSE];
    [self.ButtonUpdateActualWeather setBackgroundColor:[UIColor colorWithRed:179.0f/255.0f green:25.0f/255.0f blue:49.0f/255.0f alpha:1.0]];
    
    NSTimeInterval timestamp = [self.Activity.startdt timeIntervalSince1970];
    NSNumber *dt = [NSNumber numberWithInt: timestamp];
    
    
    NSString *url = [NSString stringWithFormat:@"https://api.darksky.net/forecast/d339db567160bdd560169ea4eef3ee5a/%@,%@,%@?exclude=minutely,flags,alerts&units=uk2", self.Activity.poi.lat, self.Activity.poi.lon,dt];
    
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
            
            [self.realm transactionWithBlock:^{
                [self.Activity.weather addObject:weather];
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
                    [self.Activity.weather addObject:weather];
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
                    [self.Activity.weather addObject:weather];
                }];
            }
            
        });
    }];
}
    

/*
 created date:      24/06/2019
 last modified:     24/06/2019
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
 created date:      24/06/2019
 last modified:     24/06/2019
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


@end
