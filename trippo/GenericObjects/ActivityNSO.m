//
//  ActivityNSO.m
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ActivityNSO.h"

@implementation ActivityNSO
@synthesize key;
@synthesize name;
@synthesize privatenotes;
@synthesize startdt;
@synthesize enddt;
@synthesize currency;
@synthesize costamt;
@synthesize project;
@synthesize poi;
@synthesize activitystate;

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks: transform NSDate to string.
 */
-(NSString *)GetStringFromDt :(NSDate *) dt {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *returnValue = [dateFormatter stringFromDate:dt];
    return returnValue;
}

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks: transform NSString to NSDate.
 */
-(NSDate *)GetDtFromString :(NSString *) dt {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *returnValue = [[NSDate alloc] init];
    returnValue = [dateFormatter dateFromString:dt];
    return returnValue;
}

/*
 created date:      29/04/2018
 last modified:     29/04/2018
 remarks: remove decimals from price amount
 */
-(NSNumber *)TransformNumeric :(int) NumberOfDP :(float) Value {
    NSNumber *returnvalue = [NSNumber numberWithFloat:Value];
    return returnvalue;
}




@end
