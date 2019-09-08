//
//  CirclePart.m
//  travelme
//
//  Created by andrew glew on 17/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "CirclePart.h"

@implementation CirclePart

-(id)initWithStartDegree:(CGFloat)startDegree endDegree:(CGFloat)endDegree partColor:(UIColor*)partColor
{
    self = [super init];
    if (self) {
        self.startDegree = startDegree;
        self.endDegree = endDegree;
        self.partColor = partColor;
    }
    return self;
}

@end
