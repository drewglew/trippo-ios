//
//  MultiplierConstraint.h
//  trippo-app
//
//  Created by andrew glew on 04/03/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSLayoutConstraint (Multiplier)
-(instancetype)updateMultiplier:(CGFloat)multiplier;
@end

NS_ASSUME_NONNULL_END
