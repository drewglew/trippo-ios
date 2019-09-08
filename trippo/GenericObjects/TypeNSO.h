//
//  TypeNSO.h
//  travelme
//
//  Created by andrew glew on 11/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TypeNSO : NSObject
@property (nonatomic) UIImage *Image;
@property (nonatomic) NSString *imagename;
@property (nonatomic) NSNumber *categoryid;
@property (nonatomic) NSNumber *occurances;
@property (assign) bool selected;
@end
