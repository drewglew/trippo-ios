//
//  SettingsRLM.h
//  trippo-lite
//
//  Created by andrew glew on 19/02/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import "RLMObject.h"
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingsRLM : RLMObject
@property NSString *userkey;
@property NSString *username;
@property NSString *useremail;
@property NSNumber<RLMInt> *TripCellColumns; // 1 to 5 default 3 ProjectListVC
@property NSNumber<RLMInt> *ActivityCellColumns; // 1 to 5 default 3 ActivityListVC
@property NSNumber<RLMInt> *NodeScale;  //20 to 200 default 60 / TravelPlanVC
@end

/* more to add */

NS_ASSUME_NONNULL_END
