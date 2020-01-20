//
//  NotificationNSO.h
//  trippo
//
//  Created by andrew glew on 14/01/2020.
//  Copyright © 2020 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotificationNSO : NSObject
@property (nonatomic) NSString *Identifier;
@property (nonatomic) NSString *Title;
@property (nonatomic) NSString *SubTitle;
@property (nonatomic) NSString *Body;
@end

NS_ASSUME_NONNULL_END
