//
//  ActivityRLM.m
//  trippo
//
//  Created by andrew glew on 25/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ActivityRLM.h"

@implementation ActivityRLM
+ (NSString *)primaryKey {
    return @"compondkey";
}
+ (NSArray *)ignoredProperties {
    return @[@"identitystartdate",@"identityenddate",@"hasestpayment",@"hasactpayment"];
}
@end
