//
//  ScheduleCell.h
//  travelme
//
//  Created by andrew glew on 05/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduleNSO.h"
#import "ScheduleBackgroundView.h"

@interface ScheduleCell : UITableViewCell

@property (strong, nonatomic) ScheduleNSO *schedule;
@property (weak, nonatomic) IBOutlet ScheduleBackgroundView *ViewHierarcyDetail;
@property (strong, nonatomic) UIButton *TransportButton;

@end
