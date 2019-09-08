//
//  ProjectListCell.h
//  travelme
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectNSO.h"
#import "TripRLM.h"
#import "TTTAttributedLabel.h"

@interface ProjectListCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *LabelProjectName;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewProject;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (assign) bool isNewAccessor;
@property (strong, nonatomic) ProjectNSO *project;
@property (strong, nonatomic) TripRLM *trip;
@property (weak, nonatomic) IBOutlet UIView *VisualEffectsViewBlur;
@property (weak, nonatomic) IBOutlet UILabel *LabelDateRange;
@property (weak, nonatomic) IBOutlet UILabel *LabelNbrOfActivities;
@property (weak, nonatomic) IBOutlet UILabel *LabelNbrOfActivities2;
@property (weak, nonatomic) IBOutlet UILabel *LabelNbrOfActivities3;
@property (weak, nonatomic) IBOutlet UIView *RotatingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ActivityIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *ViewMain;

@end
