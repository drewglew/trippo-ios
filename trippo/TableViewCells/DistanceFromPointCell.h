//
//  DistanceFromPointCell.h
//  trippo
//
//  Created by andrew glew on 24/08/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DistanceFromPointCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *LabelDistance;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *LabelExpectedTravelTime;


@end

NS_ASSUME_NONNULL_END
