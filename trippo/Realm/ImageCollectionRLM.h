//
//  ImageCollectionRLM.h
//  trippo
//
//  Created by andrew glew on 25/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "RLMObject.h"
#import <UIKit/UIKit.h>

@interface ImageCollectionRLM : RLMObject
@property NSString *ImageFileReference;
@property NSString *key;
@property NSString *info;
@property (assign) bool KeyImage;
@property (assign) bool NewImage;
@property (assign) bool UpdateImage;
@property (assign) bool ImageFlaggedDeleted;
@end

RLM_ARRAY_TYPE(ImageCollectionRLM)
