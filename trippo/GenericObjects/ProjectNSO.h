//
//  ProjectNSO.h
//  travelme
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ProjectNSO : NSObject
@property (nonatomic) NSString *key;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *imagefilereference;
@property (nonatomic) NSString *privatenotes;
// properties below for easy access
@property (nonatomic) UIImage *Image;
@property (assign) int timeinverval;   // 1=past 2=now 3=future
@property (assign) NSNumber *numberofactivities;
@property (assign) NSNumber *numberofactivitiesonlyplanned;
@property (assign) NSNumber *numberofactivitiesonlyactual;
@property (nonatomic) NSDate *startdt;
@property (nonatomic) NSDate *enddt;
@property (nonatomic) NSNumber *cost;
@property (nonatomic) NSString *currency;
@property (strong, nonatomic) NSMutableArray *Links;

-(NSDate *)GetDtFromString :(NSString *) dt;
@end
