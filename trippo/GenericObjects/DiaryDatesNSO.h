//
//  DiaryDatesNSO.h
//  trippo-app
//
//  Created by andrew glew on 23/02/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DiaryDatesNSO : NSObject
@property (nonatomic) NSString *daytitle;
@property (nonatomic) NSDate *startdt;
@property (nonatomic) NSDate *enddt;
@property (strong, nonatomic) NSMutableArray *extendedActivityDetail;
@end

NS_ASSUME_NONNULL_END
