//
//  OptionButton.m
//  trippo
//
//  Created by andrew glew on 22/10/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "OptionButton.h"

@implementation OptionButton

@synthesize buttonColor;



- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self adjustButtonColor];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self adjustButtonColor];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    [self adjustButtonColor];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [self adjustButtonColor];
}



- (void)adjustButtonColor
{
    if (!self.selected && !self.highlighted) {
        UIImage *image = self.imageView.image;
        
        self.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.imageView setTintColor:[self buttonColor]];
    }
}

#pragma mark - Default colors

- (UIColor *)buttonColor
{
    if (!buttonColor) {
        // GREEN >
        buttonColor = [UIColor colorWithRed:44.0f/255.0f green:127.0f/255.0f blue:89.0f/255.0f alpha:1.0];
        // ORANGE >
        // buttonColor = [UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0];
    }
    return buttonColor;
}

- (void)setButtonColor:(UIColor *)newButtonColor
{
    buttonColor = newButtonColor;
    [self adjustButtonColor];
}



@end
