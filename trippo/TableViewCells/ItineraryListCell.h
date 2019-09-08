//
//  ItineraryListCell.h
//  trippo
//
//  Created by andrew glew on 25/07/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ItineraryListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *LabelRoute;
@property (weak, nonatomic) IBOutlet UIImageView *TransportImageView;
@property (weak, nonatomic) IBOutlet UILabel *LabelDistance;
@property (weak, nonatomic) IBOutlet UILabel *LabelAccumDistance;
@property (weak, nonatomic) IBOutlet UILabel *LabelExpectedTravelTime;
@property (weak, nonatomic) IBOutlet UILabel *LabelAccumExpectedTravelTime;
@property (weak, nonatomic) IBOutlet UIButton *TransportButton;

@property (nonatomic, copy) void(^transportButtonTapHandler)(void);
@end

NS_ASSUME_NONNULL_END
