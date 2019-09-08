//
//  TypeCell.h
//  travelme
//
//  Created by andrew glew on 11/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TypeCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *TypeImageView;
@property (weak, nonatomic) IBOutlet UIView *ViewBadge;
@property (weak, nonatomic) IBOutlet UILabel *LabelOccurances;
@property (weak, nonatomic) IBOutlet UIView *ViewCircleBackground;
@property (assign) bool isSelected;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewChecked;



@end
