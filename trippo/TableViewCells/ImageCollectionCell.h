//
//  ImageCollectionCell.h
//  travelme
//
//  Created by andrew glew on 10/06/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *Image;
@property (weak, nonatomic) IBOutlet UIView *ViewSelectedBorder;
@property (weak, nonatomic) IBOutlet UIImageView *ImageSelected;

@end
