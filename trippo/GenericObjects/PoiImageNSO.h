//
//  PoiImageNSO.h
//  travelme
//
//  Created by andrew glew on 28/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PoiImageNSO : NSObject

@property (nonatomic) UIImage *Image;
@property (nonatomic) NSString *ImageFileReference;
@property (assign) int KeyImage;
@property (assign) bool NewImage;
@property (assign) bool UpdateImage;
@property (assign) int ImageFlaggedDeleted;
@end
