//
//  CirclePart.h
//  travelme
//
//  Created by andrew glew on 17/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CirclePart : NSObject
@property (nonatomic) CGFloat startDegree;
@property (nonatomic) CGFloat endDegree;
@property (nonatomic) UIColor *partColor;

-(id)initWithStartDegree:(CGFloat)startDegree endDegree:(CGFloat)endDegree partColor:(UIColor*)partColor;

@end
