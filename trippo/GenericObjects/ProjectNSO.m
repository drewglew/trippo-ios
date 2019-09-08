//
//  ProjectNSO.m
//  travelme
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ProjectNSO.h"

@implementation ProjectNSO
/*
 created date:      27/05/2018
 last modified:     27/05/2018
 remarks: transform NSString to NSDate.
 */
-(NSDate *)GetDtFromString :(NSString *) dt {
    NSDate *returnValue = [[NSDate alloc] init];
    if (dt!=nil || ![dt isEqualToString:@""]) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        returnValue = [dateFormatter dateFromString:dt];
    }
    return returnValue;
}
@end
