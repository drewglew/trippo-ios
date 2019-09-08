//
//  CountryNSO.h
//  travelme
//
//  Created by andrew glew on 07/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountryNSO : NSObject

@property (nonatomic) NSString *code;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *currency;
@property (nonatomic) NSString *language;
@property (nonatomic) NSString *capital;
@property (nonatomic) NSNumber *lon;
@property (nonatomic) NSNumber *lat;

@end
