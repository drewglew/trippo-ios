//
//  PaymentRLM.h
//  trippo
//
//  Created by andrew glew on 15/09/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "RLMObject.h"
#import <Realm/Realm.h>
#import "ExchangeRateRLM.h"
#import "ImageCollectionRLM.h"

@interface PaymentRLM : RLMObject
@property NSString *key;
@property NSString *desc;
@property NSString *activitykey;
@property NSString *activityname;
@property NSString *tripkey;
@property NSNumber<RLMInt> *amt_est;
@property NSNumber<RLMInt> *amt_act;
@property NSString *homecurrencycode;
@property NSString *localcurrencycode;
@property NSString *date_est;
@property NSString *date_act;
@property NSDate *dt_est;
@property NSDate *dt_act;
@property ExchangeRateRLM *rate_est;
@property ExchangeRateRLM *rate_act;
@property NSNumber<RLMInt> *status;
@property RLMArray<ImageCollectionRLM *><ImageCollectionRLM> *images;
@end

RLM_ARRAY_TYPE(PaymentRLM)
