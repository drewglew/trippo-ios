//
//  ImageNSO.h
//  travelme
//
//  Created by andrew glew on 10/06/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageNSO : NSObject
@property (nonatomic) UIImage *Image;
@property (nonatomic) NSDate *creationdate;
@property (nonatomic) NSString *Description;
@property (assign) bool selected;
@property (nonatomic) NSString *ImageFileReference;
@property (assign) int KeyImage;
@property (assign) bool NewImage;
@property (assign) bool UpdateImage;
@property (assign) int ImageFlaggedDeleted;
@property (assign) NSNumber *State;
@property (nonatomic) NSString *originalsource;
@property (nonatomic) NSString *thumbnailsource;
@end
