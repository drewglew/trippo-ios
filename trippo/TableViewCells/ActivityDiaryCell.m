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
    
    

    [self.DatePickerStart addTarget:self action:@selector(datePickerStartValueChanged:) forControlEvents:UIControlEventValueChanged]; // method to respond to changes in the picker value

    [self.DatePickerStart addTarget:self action:@selector(datePickerStartDismissed:) forControlEvents:UIControlEventEditingDidEnd]; // method to respond to changes in the picker value
    
    
    [self.DatePickerEnd addTarget:self action:@selector(datePickerEndValueChanged:) forControlEvents:UIControlEventValueChanged]; // method to respond to changes in the picker value
    [self.DatePickerEnd addTarget:self action:@selector(datePickerEndDismissed:) forControlEvents:UIControlEventEditingDidEnd]; // method to respond to changes in the picker value
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if(selected)
    {
        self.CellBorder.layer.cornerRadius = 5.0f;
        self.CellBorder.layer.borderWidth  = 1.0f;
        self.CellBorder.layer.masksToBounds = YES;
        self.CellBorder.layer.borderColor  = [UIColor labelColor].CGColor;
    }
    else
    {
        self.CellBorder.layer.borderWidth  = 0.0f;
    }
}



/*
created date:       27/08/2019
last modified:      12/03/2021
remarks:            Improved date logic.  called when user accepts change to single
 
*/
- (BOOL)areDates:(NSDate *)itemStartDt :(NSDate *)itemEndDt inRangeFirstDate:(NSDate *)activityFirstDate lastDate:(NSDate *)activityLastDate {
    
    if (([itemStartDt compare:activityFirstDate] == NSOrderedDescending) && ([itemEndDt compare:activityLastDate] == NSOrderedDescending) && ([itemStartDt compare:activityLastDate] == NSOrderedAscending)) {
        return false;
    } else if (([itemStartDt compare:activityFirstDate] == NSOrderedAscending) && ([itemEndDt compare:activityLastDate] == NSOrderedAscending) && ([itemEndDt compare:activityFirstDate] == NSOrderedDescending)) {
        return false;
    } else {
        return true;
    }
}

/*
 created date:      22/02/2019
 last modified:     27/08/2019
 remarks:           Must stay on active line - due to validations.  TODO - resolve that!
                    Max/Min simply done, not taking into account things outside of Trip.
 */
-(void)datePickerStartDismissed:(id)sender{
    self.DatePickerEnd.minimumDate = self.DatePickerStart.date;
    self.startDt =  self.DatePickerStart.date;
    [self dismissPicker];
}


-(void)datePickerEndDismissed:(id)sender{
    self.DatePickerStart.maximumDate = self.DatePickerEnd.date;
    self.endDt =  self.DatePickerEnd.date;
    [self dismissPicker];
}

/*
 created date:      11/03/2021
 last modified:     12/03/2021
 remarks:
 */
-(void)dismissPicker {

    RLMResults <ActivityRLM*> *activities = [ActivityRLM objectsWhere:@"tripkey=%@ and state=%@",self.activity.tripkey, self.activity.state];
    
    if (activities.count==0) {
        
        [self.activity.realm beginWriteTransaction];
        self.activity.startdt = self.startDt;
        self.activity.enddt = self.endDt;
        [self.activity.realm commitWriteTransaction];
        [self endEditing:YES];
        
    } else {
        
        NSString *dateInfoMessage = [[NSString alloc] init];
        
        bool ErrorInCurrentItem = false;
        for (ActivityRLM* activity in activities) {
            
            /* we do not want to waste comparing activity against itself */
            if (![self.activity.key isEqualToString:activity.key]) {
                
                bool areDatesInsideRange = [self areDates:self.startDt :self.endDt inRangeFirstDate:activity.startdt lastDate:activity.enddt];
                
                if (!areDatesInsideRange) {
                    ErrorInCurrentItem = true;
                    NSString *prettystartdt = [self FormatPrettyDate :activity.startdt :[NSTimeZone timeZoneWithName:self.activity.startdttimezonename] :@"\n"];
                    NSString *prettyenddt = [self FormatPrettyDate :activity.enddt :[NSTimeZone timeZoneWithName:self.activity.enddttimezonename] :@"\n"];
                    dateInfoMessage = [NSString stringWithFormat:@"Dates need to be within bounds of %@ and %@.", prettystartdt, prettyenddt];
                    break;
                }
            }
        }
        if (ErrorInCurrentItem) {
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Error in selected dates"
                                         message:dateInfoMessage
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            
            [alert.view setTintColor:[UIColor labelColor]];
            
            UIAlertAction* okButton = [UIAlertAction
                                       actionWithTitle:@"Ok"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                            self.startDt = self.activity.startdt;
                                            self.endDt = self.activity.enddt;
                
                                            self.DatePickerStart.date = self.startDt;
                                            self.DatePickerEnd.date = self.endDt;
                                       }];
            
            [alert addAction:okButton];

            //self.startDt = self.activity.startdt;
            //self.endDt = self.activity.enddt;

            
            
            [self.topViewController presentViewController:alert animated:YES completion:^{}];

        } else  {
            [self.activity.realm beginWriteTransaction];
            
            self.activity.startdt = self.startDt;
            self.activity.enddt = self.endDt;

            [self.activity.realm commitWriteTransaction];
            [self endEditing:YES];
        }
        self.DatePickerStart.date = self.startDt;
        self.DatePickerEnd.date = self.endDt;
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
 created date:      27/02/2021
 last modified:     27/02/2021
 remarks:
 */
- (void)datePickerStartValueChanged:(id)sender{
    self.startDt = datePicker.date;
}

/*
 created date:      27/02/2021
 last modified:     27/02/2021
 remarks:
 */
- (void)datePickerEndValueChanged:(id)sender{

    self.endDt = datePicker.date;
}


@end
