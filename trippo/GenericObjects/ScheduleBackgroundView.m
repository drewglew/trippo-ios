//
//  ScheduleBackgroundView.m
//  travelme
//
//  Created by andrew glew on 17/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ScheduleBackgroundView.h"

@implementation ScheduleBackgroundView

/*
 created date:      19/05/2018
 last modified:     04/10/2018
 remarks:
 */
-(void)addColumns:(int)amount :(int)linestyle :(float)spacer{
    LastLineStyle = linestyle;
    columns = [[NSMutableArray alloc] init];
    float border = 10;
    float imagemidsize = 50;
    for (int i = 0; i < amount; i++)
    {
        float position = (spacer * i ) + imagemidsize + border;

        [columns addObject:[NSNumber numberWithFloat:position]];
    }
}
/*
 created date:      19/05/2018
 last modified:     19/05/2018
 remarks:
 */
-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:44.0f/255.0f green:127.0f/255.0f blue:89.0f/255.0f alpha:1.0] CGColor]);

    CGContextSetLineWidth(ctx, 4.0);
    
    for (int i = 0; i < [columns count]; i++) {
        CGFloat f = [((NSNumber*) [columns objectAtIndex:i]) floatValue];
        //last line
        if (i == columns.count - 1) {
            CGFloat midHeight = self.bounds.size.height / 2;
            if (LastLineStyle==0) {
                CGContextMoveToPoint(ctx, f, midHeight);
                CGContextAddLineToPoint(ctx, f, self.bounds.size.height);
            } else if (LastLineStyle==2) {
                CGContextMoveToPoint(ctx, f, 0);
                CGContextAddLineToPoint(ctx, f, midHeight);
            } else if (LastLineStyle==3) {
                // no line
            } else {
                CGContextMoveToPoint(ctx, f, 0);
                CGContextAddLineToPoint(ctx, f, self.bounds.size.height);
            }
        } else {
            CGContextMoveToPoint(ctx, f, 0);
            CGContextAddLineToPoint(ctx, f, self.bounds.size.height);
        }
    }
    CGContextStrokePath(ctx);
    [super drawRect:rect];
}


@end
