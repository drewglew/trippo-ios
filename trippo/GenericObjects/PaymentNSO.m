//
//  PaymentNSO.m
//  travelme
//
//  Created by andrew glew on 09/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PaymentNSO.h"

@implementation PaymentNSO
@synthesize description;
@synthesize homecurrencycode;
@synthesize localcurrencycode;
@synthesize activityname;
@synthesize amt_est;
@synthesize amt_act;
@synthesize dt_est;
@synthesize dt_act;
@synthesize date_est;
@synthesize date_act;
@synthesize key;
@synthesize rate_est;
@synthesize rate_act;
@synthesize status;

/*
 created date:      29/04/2018
 last modified:     15/05/2018
 remarks: transform NSString to NSDate.
 */
-(NSDate *)GetDtFromString :(NSString *) dt {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *returnValue = [[NSDate alloc] init];
    returnValue = [dateFormatter dateFromString:dt];
    return returnValue;
}



@end
