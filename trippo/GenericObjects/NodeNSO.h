//
//  NodeNSO.h
//  trippo
//
//  Created by andrew glew on 20/07/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ActivityRLM.h"

NS_ASSUME_NONNULL_BEGIN

@interface NodeNSO : NSObject
@property ActivityRLM *Activity;
@property (assign) bool isUsed;
@end

NS_ASSUME_NONNULL_END
