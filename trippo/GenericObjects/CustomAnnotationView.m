//
//  CustomAnnotationView.m
//  trippo
//
//  Created by andrew glew on 23/03/2021.
//  Copyright © 2021 andrew glew. All rights reserved.
//

#import "CustomAnnotationView.h"

static NSString *identifier = @"com.domain.clusteringIdentifier";

@implementation CustomAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
        self.clusteringIdentifier = identifier;
        self.collisionMode = MKAnnotationViewCollisionModeCircle;
    }

    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    self.clusteringIdentifier = identifier;
}

@end
