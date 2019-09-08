//
//  WeatherCell.h
//  trippo
//
//  Created by andrew glew on 23/06/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WeatherCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *LabelTime;
@property (weak, nonatomic) IBOutlet UILabel *LabelSummary;
@property (weak, nonatomic) IBOutlet UIImageView *ImageIcon;
@property (weak, nonatomic) IBOutlet UILabel *LabelTemp;
@property (assign) bool isSelected;
@end

NS_ASSUME_NONNULL_END
