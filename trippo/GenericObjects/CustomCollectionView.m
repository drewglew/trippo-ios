//
//  CustomCollectionView.m
//  trippo
//
//  Created by andrew glew on 31/03/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import "CustomCollectionView.h"
@interface CustomCollectionView ()
@property (nonatomic, copy) void (^reloadDataCompletionBlock)(void);
@end

@implementation CustomCollectionView
- (void)reloadDataWithCompletion:(void (^)(void))completionBlock
{
    self.reloadDataCompletionBlock = completionBlock;
    [super reloadData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.reloadDataCompletionBlock) {
        self.reloadDataCompletionBlock();
        self.reloadDataCompletionBlock = nil;
    }
}
@end
