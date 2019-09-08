//
//  JourneyItemNSO.h
//  trippo
//
//  Created by andrew glew on 25/07/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActivityRLM.h"

NS_ASSUME_NONNULL_BEGIN

@interface JourneyItemNSO : NSObject

@property ActivityRLM *Activity;
@property (nonatomic) NSString *Route;
@property (nonatomic) NSNumber *TransportId;
@property (nonatomic) NSNumber *Distance;
@property (nonatomic) NSNumber *AccumDistance;
@property (nonatomic) NSNumber *ExpectedTravelTime;
@property (nonatomic) NSNumber *AccumExpectedTravelTime;
@property (nonatomic) NSNumber *SequenceNo;
@property (nonatomic) ActivityRLM *from;
@property (nonatomic) ActivityRLM *to;
@end

NS_ASSUME_NONNULL_END
