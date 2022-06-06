//
//  ToolBoxNSO.h
//  travelme
//
//  Created by andrew glew on 02/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ToolBoxNSO : NSObject
+(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size;
+ (UIImage*)resizeImage:(UIImage*)image toFitInSize:(CGSize)toSize;
+ (NSString*)PrettyDateDifference :(NSDate*)Start :(NSDate*)End :(NSString*) PostFixText;
+ (NSString*)FormatPrettyDate :(NSDate*)Dt;
+ (NSString*)FormatPrettySimpleDate :(NSDate*)Dt;
+ (NSString*)FormatPrettyTime :(NSDate*)Dt;
+ (UIImage *)convertImageToGrayScale:(UIImage *)image ;
+ (bool)HasTopNotch;
+ (BOOL)isSameDt:(NSDate*)date1 otherDay:(NSDate*)date2;
+ (BOOL)isSameDay:(NSDate*)date1 otherDay:(NSDate*)date2;
+ (UIImage *)imageWithColor:(UIColor *)color ;
@end
