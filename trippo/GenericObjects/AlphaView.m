//
//  AlphaView.m
//  travelme
//
//  Created by andrew glew on 05/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "AlphaView.h"

@implementation AlphaView


/*You have to override the top view's drawRect method. So, for example, you might create a HoleyView class that derives from UIView (you can do that by adding a new file to your project, selecting Objective-C subclass, and setting "Subclass of" to UIView). In HoleyView, drawRect would look something like this:*/

- (void)drawRect:(CGRect)rect {
    // Start by filling the area with the blue color
    [[UIColor blueColor] setFill];
    UIRectFill( rect );
    
    // Assume that there's an ivar somewhere called holeRect of type CGRect
    // We could just fill holeRect, but it's more efficient to only fill the
    // area we're being asked to draw.
    CGRect holeRectIntersection = CGRectIntersection( rect, rect );
    
    [[UIColor clearColor] setFill];
    UIRectFill( holeRectIntersection );
}

@end
