//
//  NotificationCell.h
//  trippo
//
//  Created by andrew glew on 14/01/2020.
//  Copyright © 2020 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotificationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *LabelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelSubtitle;
@property (weak, nonatomic) IBOutlet UILabel *LabelBody;


@end

NS_ASSUME_NONNULL_END
