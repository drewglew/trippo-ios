//
//  JENNodeView.h
//
//  Created by Jennifer Nordwall on 3/14/14.
//  Copyright (c) 2014 Jennifer Nordwall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityRLM.h"
#import "JENSubtreeView.h"
#import "JENOptionsView.h"
#import "TravelPlanDetailVC.h"
#import "TravelPlanVC.h"
#import "PoiSearchVC.h"

@interface JENDefaultNodeView : UIView <TravelPlanDetailDelegate, PoiSearchDelegate>
@property (nonatomic, strong) NSString *nodeName;
@property (nonatomic, getter=isImmediate) BOOL insertNode;
@property (nonatomic, strong) ActivityRLM *activity;
@property (nonatomic, strong) UIImage *activityImage;
@property (nonatomic, strong) UIView *activityView;
@property (nonatomic, strong) JENOptionsView *activityOptionView;
@property (nonatomic, strong) NSDate *startDt;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *activityImageView;
@property (nonatomic, strong) UIButton* openOptionsButton;
//@property (nonatomic, strong) UIButton* transportButton;
@property (nonatomic, strong) UIImageView* transportImageView;
@property (nonatomic, strong) UIImageView* transportTravelBackIndicator;
@property (nonatomic, assign) double nodeSize;
@property (nonatomic, strong) NSNumber *transportType;
@property (nonatomic, strong) NSNumber *travelBack;
-(id)initWithParm:(double)NodeSize :(bool)isSelected;

@end
