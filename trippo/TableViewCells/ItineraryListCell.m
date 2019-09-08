//
//  ItineraryListCell.m
//  trippo
//
//  Created by andrew glew on 25/07/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import "ItineraryListCell.h"

@implementation ItineraryListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)transportButtonTapped:(UIButton *)sender
{
    self.transportButtonTapHandler();

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
