//
//  AttachmentCell.m
//  trippo-app
//
//  Created by andrew glew on 24/02/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import "AttachmentCell.h"

@implementation AttachmentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.ImageViewChecked.hidden = !selected;
    
    // Configure the view for the selected state
}

@end
