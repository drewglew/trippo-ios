//
//  JENNode.h
//  Example
//
//  Created by Jennifer Nordwall on 3/23/14.
//  Copyright (c) 2014 Jennifer Nordwall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JENTreeViewModelNode.h"
#import "ActivityRLM.h"

@interface JENNode : NSObject<JENTreeViewModelNode>

@property (nonatomic, strong) NSSet *children;
@property (nonatomic, strong) NSString *nodeName;
@property (nonatomic, getter=isImmediate) BOOL insertNode;
@property (nonatomic, strong) ActivityRLM *activity;
@property (nonatomic, strong) NSDate *startDt;
@property (nonatomic, assign) double nodeSize;
@property (nonatomic, strong) NSNumber *transportType;
@property (nonatomic, strong) NSNumber *travelBack;
@property (nonatomic, strong) UIImage *activityImage;

@end
