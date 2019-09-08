//
//  GraphView.m
//  travelme
//
//  Created by andrew glew on 17/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView

-(id)initWithFrame:(CGRect)frame CentrePoint:(CGPoint)centrePoint radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth circleParts:(NSArray*)circleParts
{
    self = [super initWithFrame:frame];
    if (self) {
        self.centrePoint = centrePoint;
        self.radius = radius;
        self.lineWidth = lineWidth;
        self.circleParts = circleParts;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    [self drawCircle];
}

- (void)drawCircle {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, _lineWidth);
    
    for(CirclePart *circlePart in _circleParts)
    {
        CGContextMoveToPoint(context, _centrePoint.x, _centrePoint.y);
        
        CGContextAddArc(context, _centrePoint.x , _centrePoint.y, _radius, [self radians:circlePart.startDegree], [self radians:circlePart.endDegree], 0);
        CGContextSetFillColorWithColor(context, circlePart.partColor.CGColor);
        CGContextFillPath(context);
    }
}

-(float) radians:(double) degrees {
    return degrees * M_PI / 180;
}


@end
