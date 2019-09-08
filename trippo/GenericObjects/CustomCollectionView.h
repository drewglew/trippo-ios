//
//  CustomCollectionView.h
//  trippo
//
//  Created by andrew glew on 31/03/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomCollectionView : UICollectionView
- (void)reloadDataWithCompletion:(void (^)(void))completionBlock;

@end

NS_ASSUME_NONNULL_END
