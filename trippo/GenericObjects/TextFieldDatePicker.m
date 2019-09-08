//
//  TextFieldDatePicker.m
//  trippo
//
//  Created by andrew glew on 22/10/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "TextFieldDatePicker.h"

@implementation TextFieldDatePicker

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    return CGRectZero;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    // Do your customization here, eg:
    if (enabled) {
        
        self.textColor = [UIColor colorNamed:@"TrippoColor"];
        //self.backgroundColor = [UIColor colorNamed:@"TrippoColor"];
    } else {
        self.textColor = [UIColor grayColor];
       // self.backgroundColor = [UIColor lightGrayColor];
    }
}

- (BOOL)becomeFirstResponder {
    BOOL outcome = [super becomeFirstResponder];
    if (outcome) {
        self.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0];
        self.textColor = [UIColor whiteColor];
        
    }
    return outcome;
}

- (BOOL)resignFirstResponder {
    BOOL outcome = [super resignFirstResponder];
    if (outcome) {
        self.backgroundColor = [UIColor tertiarySystemBackgroundColor];
        self.textColor = [UIColor colorNamed:@"TrippoColor"];
    }
    return outcome;
}



@end
