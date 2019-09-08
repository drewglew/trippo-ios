//
//  ScheduleNSO.h
//  travelme
//
//  Created by andrew glew on 05/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "ProjectNSO.h"
#import "TripRLM.h"
#import "PoiRLM.h"


@interface ScheduleNSO : NSObject
@property (nonatomic) NSString *compondkey;
@property (nonatomic) NSString *name;
@property (nonatomic) NSDate *dt;
@property (nonatomic) NSString *type;
@property (assign) int hierarcyindex;
@property (nonatomic) NSNumber *categoryid;
@property (nonatomic) NSNumber *transportid;
@property (nonatomic) NSNumber *sortorder;
@property (assign) bool enddatesameasstart;
@property ActivityRLM *activityitem;
@property (nonatomic, readwrite) CLLocationCoordinate2D Coordinates;
@property (strong, nonatomic) TripRLM *trip;
@property PoiRLM *poi;
-(NSDate *)GetDtFromString :(NSString *) dt;
@end
