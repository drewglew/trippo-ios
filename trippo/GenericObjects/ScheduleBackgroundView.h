//
//  ScheduleBackgroundView.h
//  travelme
//
//  Created by andrew glew on 17/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleBackgroundView : UIView {
    NSMutableArray *columns;
    int LastLineStyle;
}

- (void)addColumns:(int)amount :(int)linestyle :(float)spacer;


@end
