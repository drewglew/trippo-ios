//
//  WeatherRLM.h
//  trippo
//
//  Created by andrew glew on 17/06/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//
#import <Realm/Realm.h>
#import "RLMObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface WeatherRLM : RLMObject
@property NSString *timedefition;
@property NSNumber<RLMInt> *time;
@property NSString *summary;
@property NSString *icon;
@property NSString *systemicon;
@property NSString *temperature;
@property NSNumber<RLMInt> *precipIntensity;
@property NSNumber<RLMInt> *precipProbability;
@property NSNumber<RLMInt> *windSpeed;
@property NSNumber<RLMInt> *windGust;
@property NSNumber<RLMInt> *cloudCover;
@property NSNumber<RLMInt> *visibility;
@end

RLM_COLLECTION_TYPE(WeatherRLM)

NS_ASSUME_NONNULL_END
