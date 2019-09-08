//
//  PoiPreviewVCViewController.h
//  trippo
//
//  Created by andrew glew on 20/03/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PoiRLM.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PoiPreviewDelegate <NSObject>
@end

@interface PoiPreviewVC : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewPoi;
@property (weak, nonatomic) IBOutlet UILabel *LabelPoi;
@property (weak, nonatomic) IBOutlet UITextView *TextViewNotes;
@property (nonatomic, weak) id <PoiPreviewDelegate> delegate;
@property (strong, nonatomic) UIImage *headerImage;
@property PoiRLM *PointOfInterest;
@property (weak, nonatomic) IBOutlet UILabel *LabelAddress;
@property (weak, nonatomic) IBOutlet UIView *ViewPoiPopup;

@end

NS_ASSUME_NONNULL_END
