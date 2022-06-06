//
//  ActivityRLM.h
//  trippo
//
//  Created by andrew glew on 25/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Realm/Realm.h>
#import "ImageCollectionRLM.h"
#import "AttachmentRLM.h"
#import "ExpenseRLM.h"
#import "PoiRLM.h"
#import "WeatherRLM.h"

@interface ActivityRLM : RLMObject
@property NSString *key;
@property NSString *parentkey;
@property NSNumber<RLMInt> *state;
@property NSString *compondkey;  // 12345-67890~0
@property NSString *name;
@property NSString *privatenotes;
@property NSString *reference;
@property NSString *tripkey;
@property NSString *poikey;
@property PoiRLM *poi;
@property NSDate *createddt;
@property NSDate *modifieddt;
@property NSNumber<RLMFloat> *rating;
@property NSNumber<RLMInt> *geonotification;
@property NSNumber<RLMInt> *geonotifycheckout;
@property NSNumber<RLMInt> *IncludeInTweet;
@property NSNumber<RLMInt> *IncludeWeather;
@property NSNumber<RLMInt> *travelbackflag;
@property NSNumber<RLMInt> *traveltransportid;
@property NSDate *startdt;
@property NSDate *enddt;
@property NSDate *geonotifycheckindt;
@property NSDate *geonotifycheckoutdt;
@property NSString *identitystartdate;
@property NSString *identityenddate;
@property  NSString *startdttimezonename;
@property  NSString *enddttimezonename;
@property  NSString *defaulttimezonename;
@property NSNumber<RLMInt> *hasestpayment;
@property NSNumber<RLMInt> *hasactpayment;

@property RLMArray<ImageCollectionRLM *><ImageCollectionRLM> *images;
@property RLMArray<AttachmentRLM *><AttachmentRLM> *attachments;
@property RLMArray<WeatherRLM *><WeatherRLM> *weather;
@end

RLM_COLLECTION_TYPE(ActivityRLM)
