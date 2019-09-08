//
//  ActivityListCell.h
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityNSO.h"
#import "ActivityRLM.h"
#import "TTTAttributedLabel.h"


@interface ActivityListCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewActivity;
@property (strong, nonatomic) ActivityRLM *activity;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *LabelName;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *VisualViewBlur;
@property (weak, nonatomic) IBOutlet UIView *ViewMain;

@property (weak, nonatomic) IBOutlet UIButton *ButtonDelete;
@property (weak, nonatomic) IBOutlet UIImageView *ImageBlurBackground;
@property (weak, nonatomic) IBOutlet UIImageView *ImageBlurBackgroundBottomHalf;

@property (weak, nonatomic) IBOutlet UIView *ViewOverlay;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *VisualViewBlurBehindImage;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewBookmark;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewTypeOfPoi;
@property (weak, nonatomic) IBOutlet UIView *ViewActiveItem;
@property (weak, nonatomic) IBOutlet UIView *ViewActiveBadge;
@property (weak, nonatomic) IBOutlet UIView *ViewPoiType;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *ViewDateInfo;
@property (weak, nonatomic) IBOutlet UILabel *LabelStartTimePlusWeekDay;
@property (weak, nonatomic) IBOutlet UILabel *LabelEndTimePlusWeekDay;
@property (weak, nonatomic) IBOutlet UILabel *LabelStartDate;
@property (weak, nonatomic) IBOutlet UILabel *LabelEndDate;
@property (weak, nonatomic) IBOutlet UILabel *LabelDuration;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ImageConstraint;
@property (weak, nonatomic) IBOutlet UIView *ViewWeather;
@property (weak, nonatomic) IBOutlet UIImageView *ImageWeatherIcon;
@property (weak, nonatomic) IBOutlet UILabel *LabelWeatherTemp;
@property (weak, nonatomic) IBOutlet UIView *ViewWeatherDogEarBackground;
@property (weak, nonatomic) IBOutlet UIButton *ButtonShowWeather;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BadgeHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *LabelActive;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *BadgeLabelHeightConstraint;


@end
