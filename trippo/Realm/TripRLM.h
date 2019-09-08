//
//  TripRLM.h
//  trippo
//
//  Created by andrew glew on 25/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "ActivityRLM.h"

@interface TripRLM : RLMObject
@property  NSString *key;
@property  NSString *name;
@property  NSString *privatenotes;
@property  NSDate *startdt;
@property  NSDate *enddt;
@property  NSDate *createddt;
@property  NSDate *modifieddt;
@property  NSDate *routeplannedcalculateddt;
@property  NSNumber<RLMInt> *routeplannedtotaltravelminutes;
@property  NSNumber<RLMDouble> *routeplannedtotaltraveldistance;
@property  NSDate *routeactualcalculateddt;
@property  NSNumber<RLMInt> *routeactualtotaltravelminutes;
@property  NSNumber<RLMDouble> *routeactualtotaltraveldistance;
@property  NSNumber<RLMInt> *itemgrouping;
@property  NSString *startdttimezonename;
@property  NSString *enddttimezonename;
@property  NSString *defaulttimezonename;

@property RLMArray<ImageCollectionRLM *><ImageCollectionRLM> *images;
//@property RLMArray<ExpenseRLM *><ExpenseRLM> *expenses;
@end






