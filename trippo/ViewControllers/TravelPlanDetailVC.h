//
//  TravelPlanDetailVC.h
//  trippo
//
//  Created by andrew glew on 21/07/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "TripRLM.h"
#import "TextFieldDatePicker.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TravelPlanDetailDelegate <NSObject>
@end

@interface TravelPlanDetailVC : UIViewController
@property (nonatomic, weak) id <TravelPlanDetailDelegate> delegate;
@property ActivityRLM *Activity;
@property RLMRealm *realm;
@property (weak, nonatomic) IBOutlet UIView *ViewPopup;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewActivity;
@property (weak, nonatomic) IBOutlet UILabel *LabelActvityName;
@property (nonatomic) UIImage *ActivityImage;
@property (weak, nonatomic) IBOutlet TextFieldDatePicker *TextFieldDateFrom;
@property (weak, nonatomic) IBOutlet TextFieldDatePicker *TextFieldDateTo;
@property (nonatomic) NSNumber *TravelTypeId;




@end

NS_ASSUME_NONNULL_END
