//
//  AttachNSO.h
//  trippo
//
//  Created by andrew glew on 25/07/2021.
//  Copyright © 2021 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AttachNSO : NSObject

@property (nonatomic) NSString *key;
@property (nonatomic) NSString *filename;
@property (nonatomic) NSString *notes;
@property (nonatomic) NSDate *importeddate;
@property (nonatomic) NSNumber *isselected;

@end

NS_ASSUME_NONNULL_END
