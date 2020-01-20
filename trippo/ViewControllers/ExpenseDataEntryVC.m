//
//  ExpenseDataEntryVC.m
//  trippo
//
//  Created by andrew glew on 07/04/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import "ExpenseDataEntryVC.h"

@interface ExpenseDataEntryVC ()

@end

@implementation ExpenseDataEntryVC

/*
 created date:      07/04/2019
 last modified:     19/01/2020
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    double amount = 0;
    self.LabelTitle.text = self.TitleText;
    self.ViewExpensePopup.layer.cornerRadius=8.0f;
    self.ViewExpensePopup.layer.masksToBounds=YES;
    self.ViewExpensePopup.layer.borderWidth = 1.0f;
    self.ViewExpensePopup.layer.borderColor = [[UIColor colorNamed:@"TrippoColor"]CGColor];
    
    self.HomeCurrencyCode = [AppDelegateDef HomeCurrencyCode];
    
    NSDate *PresetDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    self.DuplicateCurrenciesExchangeRate = [[ExchangeRateRLM alloc] init];
    self.DuplicateCurrenciesExchangeRate.compondkey = [NSString stringWithFormat:@"00-00-00~%@%@", self.HomeCurrencyCode, self.HomeCurrencyCode];
    self.DuplicateCurrenciesExchangeRate.currencycode = self.HomeCurrencyCode;
    self.DuplicateCurrenciesExchangeRate.homecurrencycode = self.HomeCurrencyCode;
    self.DuplicateCurrenciesExchangeRate.rate = [NSNumber numberWithInt:10000];
    
    if (self.newitem) {
        NSLog(@"empty expense");
        self.ExpenseItem = [[PaymentRLM alloc] init];
        
        if (self.ActivityItem != nil) {
            self.ExpenseItem.status = self.ActivityItem.state;
            NSLog(@"Activity state=%@",self.ActivityItem.state);
            if (self.ExpenseItem.status==[NSNumber numberWithLong:0]) {
                self.SegmentExpenseType.selectedSegmentIndex = 0;
            } else {
                self.SegmentExpenseType.selectedSegmentIndex = 2;
            }
            self.ExpenseItem.amt_est = 0;
            self.ExpenseItem.amt_act = 0;
            
        }
        
        
    } else {

        NSLog(@"exisiting expense");
        //self.LabelTitle.text = [NSString stringWithFormat:@"%@",self.ActivityItem.name];
        self.TextFieldExpenseDescription.text = self.ExpenseItem.desc;
        self.TextFieldCurrency.text = self.ExpenseItem.localcurrencycode;
        self.SegmentExpenseType.selectedSegmentIndex = [self.ExpenseItem.status longValue];
       
        
        if (self.SegmentExpenseType.selectedSegmentIndex == 0) {
            amount = [self.ExpenseItem.amt_est doubleValue];
            amount = amount / 100.0;
            self.TextFieldExpenseAmount.text = [NSString stringWithFormat:@"%.2f",amount];
            
            PresetDate = [dateFormatter dateFromString:self.ExpenseItem.date_est];
            self.ActiveExchangeRate = self.ExpenseItem.rate_est;
            
        } else {
            amount = [self.ExpenseItem.amt_act doubleValue];
            amount = amount / 100.0;
            self.TextFieldExpenseAmount.text = [NSString stringWithFormat:@"%.2f",amount];
            PresetDate = [dateFormatter dateFromString:self.ExpenseItem.date_act];
            self.ActiveExchangeRate = self.ExpenseItem.rate_act;
        }
    }
    
    self.currencies = [[NSMutableArray alloc] init];
    
    NSInteger row = 0;

    /* get local currency detail for currency picker control */
    NSString *currencysymbol = @"";
    NSString *code = @"";
    NSString *localeIdent;
    NSLocale *PoiLocale;
    NSLocale *HomeLocale = [NSLocale currentLocale];
    
    if (self.ActivityItem.poikey != nil) {
        NSDictionary *components = [NSDictionary dictionaryWithObject:self.ActivityItem.poi.countrycode forKey:NSLocaleCountryCode];
        localeIdent = [NSLocale localeIdentifierFromComponents:components];
        PoiLocale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdent];
        
        currencysymbol = @"";
        code = [PoiLocale objectForKey: NSLocaleCurrencyCode];
        if (![code isEqualToString:[HomeLocale displayNameForKey:NSLocaleCurrencySymbol value:[PoiLocale objectForKey: NSLocaleCurrencyCode]]]) {
            currencysymbol = [NSString stringWithFormat:@"(%@)", [PoiLocale displayNameForKey:NSLocaleCurrencySymbol value:code]];
        }
        NSLog(@"No POI so we cannot add a local currency to the list.");
        [self.currencies addObject:[NSString stringWithFormat:@"%@ - %@ %@", code, @"Local currency", currencysymbol]];
        self.SelectedCurrencyCode = code;
    } else {
        self.SelectedCurrencyCode = self.HomeCurrencyCode;
    }
    
    
     /* next obtain home currency detail for currency picker control */
    currencysymbol = @"";
    code = [AppDelegateDef HomeCurrencyCode];
    
    if (![code isEqualToString:[HomeLocale displayNameForKey:NSLocaleCurrencySymbol value:[HomeLocale objectForKey: NSLocaleCurrencyCode]]]) {
        currencysymbol = [NSString stringWithFormat:@"(%@)", [HomeLocale displayNameForKey:NSLocaleCurrencySymbol value:code]];
    }
    [self.currencies addObject:[NSString stringWithFormat:@"%@ - %@ %@", code, @"Home currency", currencysymbol]];
    self.HomeCurrencyCode = code;
    
    /* locate all valid currencies */
    for (NSString *code in [NSLocale commonISOCurrencyCodes]) {
        
        if ([[HomeLocale displayNameForKey:NSLocaleCurrencyCode value:code] rangeOfString:@"("].location == NSNotFound) {
            NSString *currencysymbol = @"";
            /* only display symbol if it exists */
            if (![code isEqualToString:[HomeLocale displayNameForKey:NSLocaleCurrencySymbol value:code]]) {
                currencysymbol = [NSString stringWithFormat:@"(%@)", [HomeLocale displayNameForKey:NSLocaleCurrencySymbol value:code]];
            }
            [self.currencies addObject:[NSString stringWithFormat:@"%@ - %@ %@", code, [HomeLocale displayNameForKey:NSLocaleCurrencyCode value:code], currencysymbol]];
            row ++;
        }
    }

    if (!self.newitem) {
        [self DisplayHomeAmount :self.ActiveExchangeRate :[NSNumber numberWithDouble:amount]];
    }
    
    // Do any additional setup after loading the view.
    /* initialize the datePicker for end dt */
    self.datePickerRate = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [self.datePickerRate setDatePickerMode:UIDatePickerModeDate];
    self.datePickerRate.maximumDate = [NSDate date];
    
    [self.datePickerRate setDate:PresetDate];
    
    [self.datePickerRate addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];

    self.currencyPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    
    self.currencyPicker.delegate = self;
    self.currencyPicker.dataSource = self;

    /* add toolbar control for 'Done' option */
    UIToolbar *toolBar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolBar.barStyle = UIBarStyleDefault;
    [toolBar setTintColor:[UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
    
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(HideDatePicker)];
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];
    
    /* extend features on the input view of the text field for end dt */
    self.TextFieldRateDate.inputView = self.datePickerRate;
    self.TextFieldRateDate.text = [NSString stringWithFormat:@"%@", [ToolBoxNSO FormatPrettySimpleDate :self.datePickerRate.date]];
    [self.TextFieldRateDate setInputAccessoryView:toolBar];
    
    self.TextFieldCurrency.inputView = self.currencyPicker;
    self.TextFieldCurrency.text = [NSString stringWithFormat:@"%@",[self.currencies objectAtIndex:[self.currencyPicker selectedRowInComponent:0]]];
    [self.TextFieldCurrency setInputAccessoryView:toolBar];
    [self.TextFieldExpenseAmount setInputAccessoryView:toolBar];
    [self.TextFieldExpenseDescription setInputAccessoryView:toolBar];

    if ([self.SelectedCurrencyCode isEqualToString:self.HomeCurrencyCode]) {
        self.LabelExrate.text = @"Home = Selected";
        self.TextFieldRateDate.enabled = false;
        self.ButtonRequestLatest.enabled = false;
        self.ButtonUseLastFoundrate.enabled = false;
        self.ActiveExchangeRate = self.DuplicateCurrenciesExchangeRate;
    } else {
        [self SetControls];
    }   
    self.SegmentExpenseType.selectedSegmentTintColor = [UIColor colorNamed:@"TrippoColor"];
    [self.SegmentExpenseType setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor systemBackgroundColor], NSFontAttributeName: [UIFont systemFontOfSize:13]} forState:UIControlStateSelected];
    
    
    RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
    
    AssistantRLM *assist = [[settings[0].AssistantCollection objectsWhere:@"ViewControllerName=%@",@"ExpenseDataEntryVC"] firstObject];

    if ([assist.State integerValue] == 1) {
    
        UIView* helperView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 400)];
        helperView.backgroundColor = [UIColor labelColor];
        
        helperView.layer.cornerRadius=8.0f;
        helperView.layer.masksToBounds=YES;
        
        UILabel* title = [[UILabel alloc] init];
        title.frame = CGRectMake(10, 18, helperView.bounds.size.width - 20, 24);
        title.textColor =  [UIColor secondarySystemBackgroundColor];
        title.font = [UIFont systemFontOfSize:22 weight:UIFontWeightThin];
        title.text = @"Expenses";
        title.textAlignment = NSTextAlignmentCenter;
        [helperView addSubview:title];
        
        UIImageView *logo = [[UIImageView alloc] init];
        logo.frame = CGRectMake(10, helperView.bounds.size.height - 50, 80, 40);
        logo.image = [UIImage imageNamed:@"Trippo"];
        [helperView addSubview:logo];
        
        UILabel* helpText = [[UILabel alloc] init];
        helpText.frame = CGRectMake(10, 50, helperView.bounds.size.width - 20, 300);
        helpText.textColor =  [UIColor secondarySystemBackgroundColor];
        helpText.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        helpText.numberOfLines = 0;
        helpText.adjustsFontSizeToFitWidth = YES;
        helpText.minimumScaleFactor = 0.5;

        helpText.text = @"This view allows you to add/view Planned costs, Advanced costs or Actual.  (Advanced cost simply adds both Planned and Actual) You can by default use your home currency that is set to your devices default setting or you may choose another currency - for example the country you are traveling to.\n\nWhen the currency is different to your own - request an exchange rate to get the latest, you can also revert to a previous dates currency too.  Once called upon, you are able to reuse that rate for all other expenses.\n\nIt is helpful to give a breif payment explanation, so the payment can be easily located. i.e. 'Entrance Ticket' or '2 nights stay'\n\nThe expenses can be reopened and edited on both activity and overall trip payments.";
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

/*
 created date:      19/01/2020
 last modified:     19/01/2020
 remarks:
 */
-(void)helperViewButtonPressed :(id)sender {
    RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
    AssistantRLM *assist = [[settings[0].AssistantCollection objectsWhere:@"ViewControllerName=%@",@"ExpenseDataEntryVC"] firstObject];
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
 created date:      07/04/2019
 last modified:     05/10/2019
 remarks:           Used to enable controls depending on the data in exchange rates.
 */
-(void)SetControls {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [dateFormatter stringFromDate:[NSDate date]];

    RLMResults <ExchangeRateRLM*> *allRates = [ExchangeRateRLM objectsWhere:@"currencycode=%@ AND homecurrencycode=%@", self.SelectedCurrencyCode, self.HomeCurrencyCode];

    if (allRates.count>0) {
        ExchangeRateRLM *LatestRate = [[allRates sortedResultsUsingKeyPath:@"date" ascending:NO] firstObject];
        NSLog(@"RATE=%@",LatestRate.rate);
        
        double rate = [LatestRate.rate doubleValue];
        rate = rate/10000.0;
        
        self.LabelExrate.text = [NSString stringWithFormat:@"%@ from %@: %.4f",LatestRate.currencycode, LatestRate.date, rate];
        
        self.ActiveExchangeRate = LatestRate;

        self.ButtonUseLastFoundrate.enabled = true;

        if (self.newitem) {
            self.ExpenseItem.rate_est = LatestRate;
            self.ExpenseItem.rate_act = LatestRate;
        }
        
        if ([today isEqualToString:LatestRate.date]) {
            self.TextFieldRateDate.enabled = false;
            self.ButtonRequestLatest.enabled = false;
            
        } else {
            if ([self checkInternet]) {
                self.TextFieldRateDate.enabled = true;
                self.ButtonRequestLatest.enabled = true;
            }
        }
    } else {
        
        if (!self.newitem || self.ActivityItem.key != nil) {
            self.LabelExrate.text = @"Unknown";
            self.ButtonUseLastFoundrate.enabled = false;
            if ([self checkInternet]) {
                self.ButtonRequestLatest.enabled = true;
                self.TextFieldRateDate.enabled = true;
            }
        } else {
            if (self.ActivityItem.key==nil) {
                 if ([self.SelectedCurrencyCode isEqualToString:self.HomeCurrencyCode]) {
                     self.LabelExrate.text = @"Home = Selected";
                     self.TextFieldRateDate.enabled = false;
                     self.ButtonRequestLatest.enabled = false;
                     self.ButtonUseLastFoundrate.enabled = false;
                     self.ActiveExchangeRate = self.DuplicateCurrenciesExchangeRate;
                 }
            }
        }
    }
}

/*
 created date:      07/04/2019
 last modified:     08/04/2019
 remarks:
 */
- (void)HideDatePicker
{
    [self.TextFieldRateDate resignFirstResponder];
    [self.TextFieldCurrency resignFirstResponder];
    [self.TextFieldExpenseAmount resignFirstResponder];
    [self.TextFieldExpenseDescription resignFirstResponder];
    
}


/*
 created date:      07/04/2019
 last modified:     08/04/2019
 remarks:
 */
- (void)onDatePickerValueChanged:(UIDatePicker *)datePicker
{
    self.TextFieldRateDate.text = [ToolBoxNSO FormatPrettySimpleDate:datePicker.date];
}


/*
 created date:      07/04/2019
 last modified:     07/04/2019
 remarks:
 */
- (void)onCurrencyPickerValueChanged:(UIPickerView *)pickerView
{
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.currencies.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.currencies objectAtIndex:row];
}

/*
 created date:      07/04/2019
 last modified:     05/10/2019
 remarks:
 */
- (void)pickerView:(UIPickerView *)thePickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
     self.TextFieldCurrency.text = [self.currencies objectAtIndex:row];
     self.SelectedCurrencyCode = [self.TextFieldCurrency.text substringToIndex:3];
    
    if ([self.SelectedCurrencyCode isEqualToString:self.HomeCurrencyCode]) {
        self.LabelExrate.text = @"Home = Selected";
        self.TextFieldRateDate.enabled = false;
        self.ButtonRequestLatest.enabled = false;
        self.ButtonUseLastFoundrate.enabled = false;
        
    } else {
        [self SetControls];
    }
    [self UpdateAmounts];
}

- (IBAction)AmountEditingEnded:(id)sender {
    [self UpdateAmounts];
}

/*
 created date:      07/04/2019
 last modified:     05/10/2019
 remarks:
 */
-(void)UpdateAmounts {
    double amount = [self.TextFieldExpenseAmount.text doubleValue];

    if (amount != 0) {
        amount = (round(amount*100)) / 100.0;
        self.TextFieldExpenseAmount.text = [NSString stringWithFormat:@"%.2f",amount];
    } else {
        self.LabelHomeAmount.text = [NSString stringWithFormat:@"%.2f %@", 0.0, self.HomeCurrencyCode];
    }
    
    if ([self.SelectedCurrencyCode isEqualToString:self.HomeCurrencyCode]) {
        [self DisplayHomeAmount :nil :[NSNumber numberWithDouble:amount]];
    } else {
        [self DisplayHomeAmount :self.ActiveExchangeRate :[NSNumber numberWithDouble:amount]];
    }
    
}


/*
 created date:      07/04/2019
 last modified:     08/04/2019
 remarks:           Writes home amount summary and depending on content allows the update button to be active
 */
-(void)DisplayHomeAmount: (ExchangeRateRLM *) exrate :(NSNumber*) amt {

    double homeamt = 0.0;
    
    NSLog(@"%@ = %@",self.SelectedCurrencyCode,self.HomeCurrencyCode );
    
    
    if (exrate != nil) {
        double rate = [exrate.rate doubleValue] / 10000;
        homeamt = [amt doubleValue] * rate;
    } else if ([self.SelectedCurrencyCode isEqualToString:self.HomeCurrencyCode]) {
        homeamt = [amt doubleValue];
    }
    self.LabelHomeAmount.text = [NSString stringWithFormat:@"%.2f %@", homeamt, self.HomeCurrencyCode];
    if (homeamt > 0.0 && ![self.TextFieldExpenseDescription.text isEqualToString:@""]) {
        self.ButtonUpdate.enabled = true;
    } else {
        self.ButtonUpdate.enabled = false;
    }
}


/*
 created date:      14/05/2018
 last modified:     15/05/2018
 remarks:           This procedure handles the call to the web service and returns a dictionary back to GetExchangeRates method.
 */
-(void)fetchFromExchangeRateApi:(NSString *)url withDictionary:(void (^)(NSDictionary* data))dictionary{
    
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
 created date:      14/05/2018
 last modified:     07/04/2019
 remarks:           A little complex copied almost completely from original source.
                    This code is processed when user requests update of exchange rate we do not have latest of.
 */
- (void) GetExchangeRates {
    
    NSString *AccessKey = @"a0cb78570a1e24afda3d";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *selecteddate = [dateFormatter stringFromDate:self.datePickerRate.date];
    
    NSString *primarykey = [NSString stringWithFormat:@"%@~%@%@",selecteddate, self.ExpenseItem.localcurrencycode, self.ExpenseItem.homecurrencycode];
    
    ExchangeRateRLM *exrateexisting = [ExchangeRateRLM objectForPrimaryKey:primarykey];
    
    if (exrateexisting == nil) {
        if ([self checkInternet]) {
            NSString *url = [NSString stringWithFormat:@"https://free.currconv.com/api/v7/convert?q=%@_%@&compact=ultra&date=%@&apiKey=%@", self.SelectedCurrencyCode, self.HomeCurrencyCode, selecteddate, AccessKey];
            
            [self fetchFromExchangeRateApi:url withDictionary:^(NSDictionary *data) {
                
                dispatch_sync(dispatch_get_main_queue(), ^(void){
                    
                    if ([data objectForKey:@"status"]==[NSNumber numberWithLong:400]) {
                        self.LabelExrate.text = [data valueForKey:@"error"];
                        NSLog(@"Cannot locate currency with code %@", self.SelectedCurrencyCode);
                    } else {
                        
                        NSDictionary *LocalToHome = [data objectForKey:[NSString stringWithFormat:@"%@_%@", self.SelectedCurrencyCode, self.HomeCurrencyCode]];
                        NSNumber *LocalToHomeRate = [LocalToHome valueForKey:selecteddate];
                        
                        ExchangeRateRLM *exrate = [[ExchangeRateRLM alloc] init];
                        if (self.newitem) {
                            if (self.ExpenseItem.status==[NSNumber numberWithLong:0] || self.ExpenseItem.status==[NSNumber numberWithLong:1]) {
                                self.ExpenseItem.rate_est = [[ExchangeRateRLM alloc] init];
                                exrate = self.ExpenseItem.rate_est;
                            }
                            if (self.ExpenseItem.status==[NSNumber numberWithLong:2] || self.ExpenseItem.status==[NSNumber numberWithLong:1]) {
                                self.ExpenseItem.rate_act = [[ExchangeRateRLM alloc] init];
                                exrate = self.ExpenseItem.rate_act;
                            }
                        }
                        
                        exrate.compondkey = [NSString stringWithFormat:@"%@~%@%@",selecteddate, self.SelectedCurrencyCode, self.HomeCurrencyCode];
                        exrate.currencycode = self.SelectedCurrencyCode;
                        exrate.homecurrencycode = self.HomeCurrencyCode;
                        
                        double adjustedRate = [LocalToHomeRate doubleValue] * 10000;
                        
                        exrate.rate = [NSNumber numberWithInt:(int)adjustedRate];
                        exrate.date = selecteddate;
                        
                        [self.realm beginWriteTransaction];
                        [self.realm addObject:exrate];
                        [self.realm commitWriteTransaction];
                        
                        self.ActiveExchangeRate = exrate;
                        
                        // HERE WE UPDATE THE LABEL
                        self.LabelExrate.text = [NSString stringWithFormat:@"%@ from %@: %.4f",exrate.currencycode, exrate.date, [LocalToHomeRate doubleValue]];

                        [self UpdateAmounts];
                        
                    }
                });
                
            }];
        } else {
            NSLog(@"Device is not connected to the Internet");
            ExchangeRateRLM *exrate = [[ExchangeRateRLM alloc] init];
            exrate.rate = [NSNumber numberWithInt:-1];
            [self UpdateAmounts];
            return;
        }
        
    } else {
        self.ActiveExchangeRate = exrateexisting;
        [self UpdateAmounts];
        return;
    }
}

/*
 created date:      07/04/2019
 last modified:     07/04/2019
 remarks:
 */
- (IBAction)BackButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}


/*
 created date:      07/04/2019
 last modified:     07/04/2019
 remarks:
 */
- (IBAction)RequestExchangeRatePressed:(id)sender {
    [self GetExchangeRates];
}



/*
 created date:      07/04/2019
 last modified:     07/04/2019
 remarks:
 */
- (IBAction)UseLastFoundPressed:(id)sender {
    
    RLMResults <ExchangeRateRLM*> *allRates = [ExchangeRateRLM objectsWhere:@"currencycode=%@ AND homecurrencycode=%@", self.SelectedCurrencyCode, self.HomeCurrencyCode];
    
    if (allRates.count>0) {
        ExchangeRateRLM *LatestRate = [[allRates sortedResultsUsingKeyPath:@"date" ascending:NO] firstObject];
        self.ActiveExchangeRate = LatestRate;
        
        double rate = [LatestRate.rate doubleValue];
        rate = rate/10000.0;
        
        self.LabelExrate.text = [NSString stringWithFormat:@"%@ from %@: %.4f",LatestRate.currencycode, LatestRate.date, rate];

        [self UpdateAmounts];
    }
}

/*
 created date:      08/04/2019
 last modified:     09/04/2019
 remarks:           Split the handling of updating the exchange rate and the actual expense record.
 */
- (IBAction)ActionPressed:(id)sender {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    if (self.newitem) {
        // unmanaged Realm object
        self.ExpenseItem.key = [[NSUUID UUID] UUIDString];
        if (self.ActivityItem.key!=nil) {
            self.ExpenseItem.tripkey = self.ActivityItem.tripkey;
            self.ExpenseItem.activitykey = self.ActivityItem.key;
            self.ExpenseItem.activityname = self.ActivityItem.name;
        } else {
            self.ExpenseItem.tripkey = self.ActivityItem.tripkey;
        }
    } else {
        // managed Realm object
        [self.realm beginWriteTransaction];
    }
    
    self.ExpenseItem.homecurrencycode = self.HomeCurrencyCode;
    self.ExpenseItem.localcurrencycode = self.SelectedCurrencyCode;
    self.ExpenseItem.desc = self.TextFieldExpenseDescription.text;
    
    if (self.SegmentExpenseType.selectedSegmentIndex == 0 || self.SegmentExpenseType.selectedSegmentIndex == 2) {
        if ([self.SelectedCurrencyCode isEqualToString:self.HomeCurrencyCode]) {
            self.ExpenseItem.rate_est = self.DuplicateCurrenciesExchangeRate;
        } else {
            self.ExpenseItem.rate_est = self.ActiveExchangeRate;
        }
    }
    
    if (self.SegmentExpenseType.selectedSegmentIndex == 1 || self.SegmentExpenseType.selectedSegmentIndex == 2) {
        if ([self.SelectedCurrencyCode isEqualToString:self.HomeCurrencyCode]) {
            self.ExpenseItem.rate_act = self.DuplicateCurrenciesExchangeRate;
        } else {
            self.ExpenseItem.rate_act = self.ActiveExchangeRate;
        }
    }
    
    self.ExpenseItem.status = [NSNumber numberWithLong:self.SegmentExpenseType.selectedSegmentIndex];

    /* estimated payment and advanced that includes actual */
    if (self.ExpenseItem.status == [NSNumber numberWithLong:0] || self.ExpenseItem.status == [NSNumber numberWithLong:1] ) {
        
        double amt = [self.TextFieldExpenseAmount.text doubleValue];
        int amt_int = amt*100;
        self.ExpenseItem.amt_est = [NSNumber numberWithInt:amt_int];
        
        self.ExpenseItem.dt_est = self.datePickerRate.date;
        self.ExpenseItem.date_est = [dateFormatter stringFromDate:self.ExpenseItem.dt_est];
        
        self.ExpenseItem.dt_act = self.ExpenseItem.dt_est;
        self.ExpenseItem.date_act = self.ExpenseItem.date_est;
        self.ExpenseItem.amt_act = [NSNumber numberWithInt:0];
        
    }
    // handle new state that updates both estimated and actual amounts at the same time.
    if (self.ExpenseItem.status == [NSNumber numberWithLong:2] || self.ExpenseItem.status == [NSNumber numberWithLong:1] ) {
        
        double amt = [self.TextFieldExpenseAmount.text doubleValue];
        int amt_int = amt*100;
        self.ExpenseItem.amt_act = [NSNumber numberWithInt:amt_int];
        
        self.ExpenseItem.dt_act = self.datePickerRate.date;
        self.ExpenseItem.date_act = [dateFormatter stringFromDate:self.ExpenseItem.dt_act];
        self.ExpenseItem.amt_act = self.ExpenseItem.amt_act;
        
    }
    
    if (self.newitem) {
        [self.realm transactionWithBlock:^{
            [self.realm addObject:self.ExpenseItem];
        }];
    } else {
        [self.realm commitWriteTransaction];
    }
    [self dismissViewControllerAnimated:YES completion:Nil];
}


@end
