//
//  ScheduleNSO.m
//  travelme
//
//  Created by andrew glew on 05/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ScheduleNSO.h"

@implementation ScheduleNSO
 
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

@end
