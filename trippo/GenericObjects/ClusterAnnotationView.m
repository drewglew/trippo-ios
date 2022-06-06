//
//  ClusterAnnotationView.m
//  trippo
//
//  Created by andrew glew on 23/03/2021.
//  Copyright © 2021 andrew glew. All rights reserved.
//

#import "ClusterAnnotationView.h"

@implementation ClusterAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
        self.displayPriority = MKFeatureDisplayPriorityDefaultHigh;
        self.collisionMode = MKAnnotationViewCollisionModeCircle;
    }

    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    super.annotation = annotation;
    [self updateImage:annotation];
}

- (void)updateImage:(MKClusterAnnotation *)cluster {
    if (!cluster) {
        self.image = nil;
        return;
    }

    CGRect rect = CGRectMake(0, 0, 40, 40);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:rect.size];
    self.image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {

        [[UIColor colorNamed:@"TrippoColor"] setFill];

        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
        path.lineWidth = 0.0;
        [path fill];
        [path stroke];

        NSString *text = [NSString stringWithFormat:@"%ld", (long) cluster.memberAnnotations.count];
        NSDictionary<NSAttributedStringKey, id> *attributes = @{
            NSFontAttributeName: [UIFont preferredFontForTextStyle: UIFontTextStyleBody],
            NSForegroundColorAttributeName: [UIColor labelColor]
                                                                };
        CGSize size = [text sizeWithAttributes:attributes];
        CGRect textRect = CGRectMake(rect.origin.x + (rect.size.width  - size.width)  / 2,
                                     rect.origin.y + (rect.size.height - size.height) / 2,
                                     size.width,
                                     size.height);
        [text drawInRect:textRect withAttributes:attributes];
    }];
}

@end
