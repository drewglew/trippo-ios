//
//  CountryRLM.h
//  trippo
//
//  Created by andrew glew on 30/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "RLMObject.h"
#import <Realm/Realm.h>

@interface CountryRLM : RLMObject
@property (nonatomic) NSString *code;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *currency;
@property (nonatomic) NSString *language;
@property (nonatomic) NSString *capital;
@property (nonatomic) NSNumber<RLMDouble> *lon;
@property (nonatomic) NSNumber<RLMDouble> *lat;
@end

RLM_ARRAY_TYPE(CountryRLM)
