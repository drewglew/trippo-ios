//
//  PaymentNSO.h
//  travelme
//
//  Created by andrew glew on 09/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentNSO : NSObject

/* PAYMENT table
 sql_statement = "CREATE TABLE payment (projectkey TEXT, activitykey TEXT, key TEXT PRIMARY KEY, state INTEGER, amount INTEGER, currencycode TEXT, paymentdt TEXT, FOREIGN KEY(projectkey) REFERENCES project(key), FOREIGN KEY(activitykey) REFERENCES activity(key))";
 */

@property (nonatomic) NSString *key;
@property (nonatomic) NSString *description;
@property (nonatomic) NSString *activityname;
@property (nonatomic) NSNumber *amt_est;
@property (nonatomic) NSNumber *amt_act;
@property (nonatomic) NSString *homecurrencycode;
@property (nonatomic) NSString *localcurrencycode;
@property (nonatomic) NSDate   *dt_est;
@property (nonatomic) NSDate   *dt_act;
@property (nonatomic) NSString *date_est;
@property (nonatomic) NSString *date_act;
@property (nonatomic) NSNumber *rate_est;
@property (nonatomic) NSNumber *rate_act;
@property (nonatomic) NSNumber *status;


-(NSDate *)GetDtFromString :(NSString *) dt;

@end
