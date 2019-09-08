//
//  ItineraryRLM.h
//  trippo
//
//  Created by andrew glew on 17/08/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//
#import <Realm/Realm.h>
#import "RLMObject.h"
#import "JourneyRLM.h"

NS_ASSUME_NONNULL_BEGIN

@interface ItineraryRLM : RLMObject
@property NSString *tripkey;
@property NSNumber<RLMInt> *state;
@property NSString *compondkey;

@property RLMArray<JourneyRLM *><JourneyRLM> *itinerary;
@end


NS_ASSUME_NONNULL_END
