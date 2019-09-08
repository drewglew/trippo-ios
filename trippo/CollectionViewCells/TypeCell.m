//
//  TypeCell.m
//  travelme
//
//  Created by andrew glew on 11/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "TypeCell.h"

@implementation TypeCell


- (void)layoutSubviews {
    [super layoutSubviews];
    self.ViewCircleBackground.layer.cornerRadius = self.frame.size.width / 2.0;
    self.ViewCircleBackground.layer.masksToBounds = YES;
    
}



@end
