//
//  JENTreeViewModelNode.h
//
//  Created by Jennifer Nordwall on 3/8/14.
//  Copyright (c) 2014 Jennifer Nordwall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActivityRLM.h"

@protocol JENTreeViewModelNode <NSObject>

@required

@property (nonatomic, strong) NSSet *children;
@property (nonatomic, strong) NSString *nodeName;
@property (nonatomic, getter=isImmediate) BOOL insertNode;
@property (nonatomic, strong) ActivityRLM *activity;
@property (nonatomic, strong) NSDate *startDt;
@property (nonatomic, strong) UIImage *activityImage;
@property (nonatomic, assign) double nodeSize;
@property (nonatomic, strong) NSNumber *transportType;
@property (nonatomic, strong) NSNumber *travelBack;
@end
