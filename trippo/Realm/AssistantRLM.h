//
//  AssistantRLM.h
//  trippo
//
//  Created by andrew glew on 12/01/2020.
//  Copyright © 2020 andrew glew. All rights reserved.
//

#import <Realm/Realm.h>
#import "RLMObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface AssistantRLM : RLMObject
@property NSString *ViewControllerName;
@property NSNumber<RLMInt> *State;
@end

RLM_ARRAY_TYPE(AssistantRLM)

NS_ASSUME_NONNULL_END
