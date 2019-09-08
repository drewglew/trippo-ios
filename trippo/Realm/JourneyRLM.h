//
//  JourneyRLM.h
//  trippo
//
//  Created by andrew glew on 17/08/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import "RLMObject.h"
#import "ActivityRLM.h"

NS_ASSUME_NONNULL_BEGIN

@interface JourneyRLM : RLMObject
@property  NSString *Route;
@property  NSNumber<RLMInt> *TransportId;
@property  NSNumber<RLMDouble> *Distance;
@property  NSNumber<RLMDouble> *ExpectedTravelTime;
@property  NSNumber<RLMInt> *SequenceNo;
@property  NSNumber<RLMDouble> *AccumExpectedTravelTime;
@property  NSNumber<RLMDouble> *AccumDistance;
@property  ActivityRLM *from;
@property  ActivityRLM *to;
@end

RLM_ARRAY_TYPE(JourneyRLM)

NS_ASSUME_NONNULL_END
