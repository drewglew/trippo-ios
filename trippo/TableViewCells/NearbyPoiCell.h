//
//  NearbyPoiCell.h
//  travelme
//
//  Created by andrew glew on 16/07/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NearbyPoiCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *LabelTitle;
@property (weak, nonatomic) IBOutlet UILabel *LabelDist;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewThumbPhoto;
@property (weak, nonatomic) IBOutlet UILabel *LabelType;

@end
