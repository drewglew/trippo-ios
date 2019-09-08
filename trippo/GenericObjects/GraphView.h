//
//  GraphView.h
//  travelme
//
//  Created by andrew glew on 17/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CirclePart.h"

@interface GraphView : UIView

@property (nonatomic) CGPoint centrePoint;
@property (nonatomic) CGFloat radius;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, strong) NSArray *circleParts;

-(id)initWithFrame:(CGRect)frame CentrePoint:(CGPoint)centrePoint radius:(CGFloat)radius lineWidth:(CGFloat)lineWidth circleParts:(NSArray*)circleParts;

@end
