//
//  ExchangeRateRLM.h
//  trippo
//
//  Created by andrew glew on 03/09/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "RLMObject.h"
#import <Realm/Realm.h>

@interface ExchangeRateRLM : RLMObject

@property NSString *currencycode;
@property NSString *homecurrencycode;
@property NSNumber<RLMInt> *rate;
@property NSString *date;
@property NSString *compondkey; // yyyymmdd~GBPUSD

@end
