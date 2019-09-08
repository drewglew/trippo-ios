//
//  ActivityDiaryCell.m
//  trippo-app
//
//  Created by andrew glew on 20/02/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import "ActivityDiaryCell.h"



@implementation ActivityDiaryCell

@synthesize TextFieldStartDt, TextFieldEndDt, datePicker, datePickerToolbar;


- (void)awakeFromNib {
    [super awakeFromNib];

    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [self.datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged]; // method to respond to changes in the picker value

    self.datePickerToolbar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
    [self.datePickerToolbar setTintColor:[UIColor orangeColor]];
    UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismissPicker:)];
    UIBarButtonItem *space=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.datePickerToolbar setItems:[NSArray arrayWithObjects:space,doneBtn, nil]];
    
    self.TextFieldStartDt.inputView = self.datePicker;
    self.TextFieldStartDt.inputAccessoryView = self.datePickerToolbar;
    self.TextFieldStartDt.delegate = self;
    
    self.TextFieldEndDt.inputView = self.datePicker;
    self.TextFieldEndDt.inputAccessoryView = self.datePickerToolbar;
    self.TextFieldEndDt.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if(selected)
    {
        self.CellBorder.layer.cornerRadius = 8.0f;
        self.CellBorder.layer.borderWidth  = 1.0f;
        self.CellBorder.layer.masksToBounds = YES;
        self.CellBorder.layer.borderColor  = [UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0].CGColor;
    }
    else
    {
        self.CellBorder.layer.borderWidth  = 0.0f;
    }
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
 created date:      22/02/2019
 last modified:     27/08/2019
 remarks:           Must stay on active line - due to validations.  TODO - resolve that!
                    Max/Min simply done, not taking into account things outside of Trip.
 */
-(void)dismissPicker:(id)sender{

    RLMResults <ActivityRLM*> *activities = [ActivityRLM objectsWhere:@"tripkey=%@ and state=%@",self.activity.tripkey, self.activity.state];
    
    if (activities.count==0) {
        
        [self.activity.realm beginWriteTransaction];
        self.activity.startdt = self.startDt;
        self.activity.enddt = self.endDt;
        [self.activity.realm commitWriteTransaction];
        [self endEditing:YES];
        
    } else {
        
        NSString *AlertMessage = [[NSString alloc] init];
        
        bool ErrorInCurrentItem = false;
        for (ActivityRLM* activity in activities) {
            
            /* we do not want to waste comparing activity against itself */
            if (![self.activity.key isEqualToString:activity.key]) {
                
                bool isStartDtInsideRange = [self isDate:self.startDt  inRangeFirstDate:activity.startdt lastDate:activity.enddt];
                
                bool isEndDtInsideRange = [self isDate:self.endDt  inRangeFirstDate:activity.startdt lastDate:activity.enddt];
                
                if ((isStartDtInsideRange && isEndDtInsideRange) || (!isStartDtInsideRange && !isEndDtInsideRange)) {
                    NSLog(@"Activity has dates that are allowed!");
                } else {
                    ErrorInCurrentItem = true;
                    
                    NSTimeZone *tz = [NSTimeZone timeZoneWithName:self.activity.startdttimezonename];
                    NSString *prettystartdt = [self FormatPrettyDate :activity.startdt :tz :@""];
                    tz = [NSTimeZone timeZoneWithName:self.activity.enddttimezonename];
                    NSString *prettyenddt = [self FormatPrettyDate :activity.enddt :tz :@""];
                    
                    AlertMessage = [NSString stringWithFormat:@"The start and end dates of current activity must be contained within the activity %@ with date range %@ and %@ or outside of these bounds.  No update made this time.", activity.name, prettystartdt, prettyenddt ];
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
                                            self.startDt = self.activity.startdt;
                                            self.endDt = self.activity.enddt;
                                       }];
            
            [alert addAction:okButton];

            
            /* set users date inputs for start and end on this selected item back to orginal */
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"HH:mm"];
            
            self.startDt = self.activity.startdt;
            self.endDt = self.activity.enddt;
           
            df.timeZone = [NSTimeZone timeZoneWithName:self.defaultTimeZone];
            [self.TextFieldStartDt setText:[df stringFromDate:self.startDt]];
            [self.TextFieldEndDt setText:[df stringFromDate:self.endDt]];
            
            [self.topViewController presentViewController:alert animated:YES completion:^{}];

        } else  {
            [self.activity.realm beginWriteTransaction];
            self.activity.startdt = self.startDt;
            self.activity.enddt = self.endDt;

            [self.activity.realm commitWriteTransaction];
            [self endEditing:YES];
        }
    }
}

- (UIViewController *)topViewController{
  return [self topViewController:[UIApplication sharedApplication].delegate.window.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
  if (rootViewController.presentedViewController == nil) {
    return rootViewController;
  }
  
  if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
    UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
    return [self topViewController:lastViewController];
  }
  
  UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
  return [self topViewController:presentedViewController];
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
 created date:      22/02/2019
 last modified:     17/08/2019
 remarks:
 */
- (void)datePickerValueChanged:(id)sender{
    
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"];
   
    if (self.ActiveDtTextField == self.TextFieldStartDt) {
        df.timeZone = [NSTimeZone timeZoneWithName:self.defaultTimeZone];
        self.startDt = datePicker.date;
        [self.TextFieldStartDt setText:[df stringFromDate:self.startDt]];
        
    } else if (self.ActiveDtTextField == self.TextFieldEndDt) {
        df.timeZone = [NSTimeZone timeZoneWithName:self.defaultTimeZone];
        self.endDt = datePicker.date;
        [self.TextFieldEndDt setText:[df stringFromDate:self.endDt]];
        
    }    
}

@end
