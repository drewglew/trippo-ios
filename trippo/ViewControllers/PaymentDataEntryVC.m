//
//  PaymentDataEntryVC.m
//  travelme
//
//  Created by andrew glew on 09/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PaymentDataEntryVC.h"

@interface PaymentDataEntryVC ()

@end

@implementation PaymentDataEntryVC
/*
 created date:      14/05/2018
 last modified:     16/09/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    [self.DatePickerPaymentDt setValue:[UIColor colorWithRed:100.0f/255.0f green:245.0f/255.0f blue:1.0f/255.0f alpha:1.0] forKey:@"textColor"];

    self.DatePickerPaymentDt.maximumDate = [NSDate date];
    
    if (self.newitem) {
        /* get the expected currency code from the country of the point of interest.*/
        if (self.ActivityItem.poikey == nil) {
            // do nothing.
        } else {
            
            PoiRLM *poi = [PoiRLM objectForPrimaryKey:self.ActivityItem.poikey];
            NSDictionary *components = [NSDictionary dictionaryWithObject:poi.countrycode forKey:NSLocaleCountryCode];
            NSString *localeIdent = [NSLocale localeIdentifierFromComponents:components];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdent];
            self.TextFieldCurrency.text = [locale objectForKey: NSLocaleCurrencyCode];
        }
    } else {

        self.TextFieldCurrency.text = self.ExpenseItem.localcurrencycode;
        self.TextFieldDescription.text = self.ExpenseItem.desc;
        NSDate *date;
        
        if (self.ExpenseItem.amt_act !=  [NSNumber numberWithInteger:0]) {
            self.SegmentPaymentType.selectedSegmentIndex=1;
            double amount = [self.ExpenseItem.amt_act doubleValue];
            amount = amount / 100.0;
            self.TextFieldAmt.text = [NSString stringWithFormat:@"%.2f",amount];
            date = [dateFormatter dateFromString:self.ExpenseItem.date_act];
        } else {
            self.SegmentPaymentType.selectedSegmentIndex=0;
            double amount = [self.ExpenseItem.amt_est doubleValue];
            amount = amount / 100.0;
            self.TextFieldAmt.text = [NSString stringWithFormat:@"%.2f",amount];
            date = [dateFormatter dateFromString:self.ExpenseItem.date_est];
        }
        self.DatePickerPaymentDt.date = date;
    }
    if (self.ActivityItem != NULL) {
        self.LabelTitle.text = self.ActivityItem.name;
    }
    self.TextFieldCurrency.delegate = self;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

/*
 created date:      14/05/2018
 last modified:     14/05/2018
 remarks:
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.TextFieldCurrency endEditing:YES];
    [self.TextFieldDescription endEditing:YES];
    [self.TextFieldAmt endEditing:YES];
    
}

/*
 created date:      14/05/2018
 last modified:     19/09/2018
 remarks:   We should only add planned payments to activities that are planned.
            Additionally we should be able to add payments that are not attached to an activity.
            For example: Petrol payment.
            A single photo on each payment should be possible to hold the receipt.
 */
- (IBAction)ButtonActionPressed:(id)sender {
    
    if ([self.TextFieldDescription.text isEqualToString:@""]) {
        return;
    }
    
    if (self.newitem) {
        self.ExpenseItem = [[PaymentRLM alloc] init];
        self.ExpenseItem.key = [[NSUUID UUID] UUIDString];
        if (self.ActivityItem.key!=nil) {
            self.ExpenseItem.tripkey = self.ActivityItem.tripkey;
            self.ExpenseItem.activitykey = self.ActivityItem.key;
        } else {
            self.ExpenseItem.tripkey = self.ActivityItem.tripkey;
        }
    } else {
        [self.realm beginWriteTransaction];
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];

    NSDate *today = [NSDate date];
    
    switch ([self.DatePickerPaymentDt.date  compare:today]) {
        case NSOrderedAscending:
            break;
        case NSOrderedDescending:
            self.DatePickerPaymentDt.date = today;
            break;
        case NSOrderedSame:
            break;
    }
    
    self.ExpenseItem.desc = self.TextFieldDescription.text;
    self.ExpenseItem.status = [NSNumber numberWithLong:self.SegmentPaymentType.selectedSegmentIndex];

    /* estimated payment */
    if (self.ExpenseItem.status == [NSNumber numberWithLong:0] ) {

        double amt = [self.TextFieldAmt.text  doubleValue];
        int amt_int = amt*100;
        self.ExpenseItem.amt_est = [NSNumber numberWithInt:amt_int];
        
        self.ExpenseItem.dt_est = self.DatePickerPaymentDt.date;
        self.ExpenseItem.date_est = [dateFormatter stringFromDate:self.ExpenseItem.dt_est];
        
        self.ExpenseItem.dt_act = self.ExpenseItem.dt_est;
        self.ExpenseItem.date_act = self.ExpenseItem.date_est;
        self.ExpenseItem.amt_act = [NSNumber numberWithInt:0];
        
    } else {
        
        double amt = [self.TextFieldAmt.text  doubleValue];
        int amt_int = amt*100;
        self.ExpenseItem.amt_act = [NSNumber numberWithInt:amt_int];
        
        self.ExpenseItem.dt_act = self.DatePickerPaymentDt.date;
        self.ExpenseItem.date_act = [dateFormatter stringFromDate:self.ExpenseItem.dt_act];
        self.ExpenseItem.amt_act = self.ExpenseItem.amt_act;
        
        if (self.newitem && self.ActivityItem.state == [NSNumber numberWithInteger:0]) {
            self.ExpenseItem.dt_est = self.ExpenseItem.dt_act;
            self.ExpenseItem.date_est = self.ExpenseItem.date_act;
            self.ExpenseItem.amt_est = self.ExpenseItem.amt_act;
        } else if (self.newitem) {
            self.ExpenseItem.amt_est = [NSNumber numberWithInt:0];
            self.ExpenseItem.dt_est = self.ExpenseItem.dt_act;
            self.ExpenseItem.date_est = self.ExpenseItem.date_act;
        }
    }

    self.ExpenseItem.localcurrencycode = self.TextFieldCurrency.text;
    self.ExpenseItem.homecurrencycode = [AppDelegateDef HomeCurrencyCode];
    
    NSString *primarykey = [NSString stringWithFormat:@"%@~%@%@",self.ExpenseItem.date_est, self.ExpenseItem.localcurrencycode, self.ExpenseItem.homecurrencycode];
    
    if (![self.ExpenseItem.localcurrencycode isEqualToString:self.ExpenseItem.homecurrencycode]) {
        [self GetExchangeRates];
        //[self finializePayment] --> called from within GetExchangeRates
    } else {
        if (self.ExpenseItem.status==[NSNumber numberWithLong:0]) {
            self.ExpenseItem.rate_est = [[ExchangeRateRLM alloc] init];
            self.ExpenseItem.rate_est.date = self.ExpenseItem.date_est;
            self.ExpenseItem.rate_est.homecurrencycode = self.ExpenseItem.homecurrencycode;
            self.ExpenseItem.rate_est.currencycode = self.ExpenseItem.localcurrencycode;
            self.ExpenseItem.rate_est.compondkey = primarykey;
            self.ExpenseItem.rate_est.rate = [NSNumber numberWithInt:1*10000];
        } else {
            self.ExpenseItem.rate_act = [[ExchangeRateRLM alloc] init];
            self.ExpenseItem.rate_act.date = self.ExpenseItem.date_act;
            self.ExpenseItem.rate_act.homecurrencycode = self.ExpenseItem.homecurrencycode;
            self.ExpenseItem.rate_act.currencycode = self.ExpenseItem.localcurrencycode;
            self.ExpenseItem.rate_act.compondkey = primarykey;
            self.ExpenseItem.rate_act.rate = [NSNumber numberWithInt:1*10000];
        }
        
        
        [self finializePayment];
    }
}


/*
 created date:      15/09/2018
 last modified:     15/09/2018
 remarks:           Method finalizes the transaction if its an update and adds the object if it is a new item.  Called directly by
                    GetExchangeRates so flow of thread is covered on callback and also ButtonActionPressed: if exchange rate is already
                    available.
 */
-(void) finializePayment {
    
    if (((self.ExpenseItem.rate_est.rate == nil && self.ExpenseItem.status == [NSNumber numberWithInteger:0]) || (self.ExpenseItem.rate_act.rate == nil && self.ExpenseItem.status == [NSNumber numberWithInteger:1]))  && ![self.ExpenseItem.localcurrencycode isEqualToString:self.ExpenseItem.homecurrencycode]) {
        
        /*
         device not connected to the internet,  should we discard this whole item as we do not have a means to provide a valid
         exchange rate..
         We do not have the rate already.
         It is in home currency
         */
        if (!self.newitem) {
            [self.realm cancelWriteTransaction];
        }
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Cannot add new expense"
                                     message:@"Trippo requires web access to obtain exchange rate in currency you have requested. Please try again later."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                      [self dismissViewControllerAnimated:YES completion:Nil];
                                   }];
        
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        if (self.newitem) {
            [self.realm beginWriteTransaction];
            [self.realm addObject:self.ExpenseItem];
            [self.realm commitWriteTransaction];
        } else {
            [self.realm commitWriteTransaction];
        }
        [self dismissViewControllerAnimated:YES completion:Nil];
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


/*
 created date:      14/05/2018
 last modified:     07/04/2019
 remarks:           A little complex.  This code is processed when we do not have the exchange rate requested.
 */
- (void) GetExchangeRates {
  
        NSString *AccessKey = @"a0cb78570a1e24afda3d";
        NSString *DateValue = self.ExpenseItem.date_act;
        
        if (self.ExpenseItem.status==[NSNumber numberWithLong:0]) {
            DateValue = self.ExpenseItem.date_est;
        }
    
        NSString *primarykey = [NSString stringWithFormat:@"%@~%@%@",DateValue, self.ExpenseItem.localcurrencycode, self.ExpenseItem.homecurrencycode];

        ExchangeRateRLM *exrateexisting = [ExchangeRateRLM objectForPrimaryKey:primarykey];
  
        if (exrateexisting == nil) {
        
            if ([self checkInternet]) {
                NSString *url = [NSString stringWithFormat:@"https://free.currencyconverterapi.com/api/v6/convert?q=%@_%@&compact=ultra&date=%@&apiKey=%@", self.ExpenseItem.localcurrencycode, self.ExpenseItem.homecurrencycode, DateValue, AccessKey];

                [self fetchFromExchangeRateApi:url withDictionary:^(NSDictionary *data) {

                    dispatch_sync(dispatch_get_main_queue(), ^(void){
                        
                        if ([data objectForKey:@"status"]==[NSNumber numberWithLong:400]) {
                            NSLog(@"Cannot locate currency with code %@", self.ExpenseItem.localcurrencycode);
                        } else {
                        
                            NSDictionary *LocalToHome = [data objectForKey:[NSString stringWithFormat:@"%@_%@", self.ExpenseItem.localcurrencycode, self.ExpenseItem.homecurrencycode]];
                            NSNumber *LocalToHomeRate = [LocalToHome valueForKey:DateValue];
                            
                            ExchangeRateRLM *exrate = [[ExchangeRateRLM alloc] init];
                            if (self.newitem) {
                                if (self.ExpenseItem.status==[NSNumber numberWithLong:0]) {
                                    self.ExpenseItem.rate_est = [[ExchangeRateRLM alloc] init];
                                    exrate = self.ExpenseItem.rate_est;
                                } else {
                                    self.ExpenseItem.rate_act = [[ExchangeRateRLM alloc] init];
                                    exrate = self.ExpenseItem.rate_act;
                                }
                            }
                            
                            exrate.compondkey = [NSString stringWithFormat:@"%@~%@%@",DateValue, self.ExpenseItem.localcurrencycode, self.ExpenseItem.homecurrencycode];
                            exrate.currencycode = self.ExpenseItem.localcurrencycode;
                            exrate.homecurrencycode = self.ExpenseItem.homecurrencycode;
                            
                            double adjustedRate = [LocalToHomeRate doubleValue] * 10000;
                            
                            exrate.rate = [NSNumber numberWithInt:(int)adjustedRate];
                            exrate.date = DateValue;
                            
                            if (self.newitem && self.ExpenseItem.status == [NSNumber numberWithLong:1]) {
                                self.ExpenseItem.rate_est = self.ExpenseItem.rate_act;
                            }
                            if (!self.newitem) {
                                if (self.ExpenseItem.status==[NSNumber numberWithLong:0]) {
                                    self.ExpenseItem.rate_est = exrate;
                                } else {
                                    self.ExpenseItem.rate_act = exrate;
                                }
                            }
                            [self finializePayment];
                        }
                });
                    
                }];
            } else {
                NSLog(@"Device is not connected to the Internet");
                ExchangeRateRLM *exrate = [[ExchangeRateRLM alloc] init];
                exrate.rate = [NSNumber numberWithInt:-1];
                [self finializePayment];
                return;
            }
            
        } else {
            if (self.ExpenseItem.status==[NSNumber numberWithLong:0]) {
                self.ExpenseItem.rate_est = exrateexisting;
            } else {
                self.ExpenseItem.rate_act = exrateexisting;
            }

            [self finializePayment];
            return;
        }
}

/*
 created date:      08/08/2018
 last modified:     08/08/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ShowCurrencies"]){
        CurrencyPickerVC *controller = (CurrencyPickerVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.SelectedCurrencyCode = self.TextFieldCurrency.text;
    }
    
}


- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)AmountEditingEnded:(id)sender {
    
    double amount = [self.TextFieldAmt.text doubleValue];
    amount = (round(amount*100)) / 100.0;
    
    [self.realm beginWriteTransaction];
    if (self.ExpenseItem.status==[NSNumber numberWithLong:0]) {
        self.ExpenseItem.amt_est = [NSNumber numberWithDouble:amount];
    } else {
        self.ExpenseItem.amt_act = [NSNumber numberWithDouble:amount];
        if (self.newitem) {
            self.ExpenseItem.amt_est = self.ExpenseItem.amt_act;
        }
    }
    [self.realm commitWriteTransaction];
    
    self.TextFieldAmt.text = [NSString stringWithFormat:@"%.2f",amount];
}


- (IBAction)SegmentStatusChanged:(id)sender {

}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self performSegueWithIdentifier:@"ShowCurrencies" sender:self.TextFieldCurrency];
    return NO;
}

/*
 created date:      08/08/2018
 last modified:     08/08/2018
 remarks:
 */
- (void)didPickCurrency :(NSString*)CurrencyCode {
    self.TextFieldCurrency.text = CurrencyCode;
    
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

- (IBAction)ButtonHomePressed:(id)sender {
    
    self.TextFieldCurrency.text = [AppDelegateDef HomeCurrencyCode];
    
}

/*
 created date:      08/08/2018
 last modified:     16/09/2018
 remarks:
 */
- (IBAction)ButtonLocalPressed:(id)sender {
    
    if (self.ActivityItem.poikey==nil) {
        // apply counter of poi's attached to trip.
        
        
        
        self.TextFieldCurrency.text = [AppDelegateDef HomeCurrencyCode];
    } else {
        PoiRLM *poi = [PoiRLM objectForPrimaryKey:self.ActivityItem.poikey];
        NSDictionary *components = [NSDictionary dictionaryWithObject:poi.countrycode forKey:NSLocaleCountryCode];
        NSString *localeIdent = [NSLocale localeIdentifierFromComponents:components];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdent];
        self.TextFieldCurrency.text = [locale objectForKey: NSLocaleCurrencyCode];
    }
}

- (IBAction)DatePickerChanged:(id)sender {
    
    
}


@end
