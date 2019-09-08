//
//  ToolBoxNSO.m
//  travelme
//
//  Created by andrew glew on 02/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "ToolBoxNSO.h"

@implementation ToolBoxNSO

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

+ (UIImage*)resizeImage:(UIImage*)image toFitInSize:(CGSize)toSize
{
    UIImage *result = image;
    CGSize sourceSize = image.size;
    CGSize targetSize = toSize;
    
    BOOL needsRedraw = NO;
    
    // Check if width of source image is greater than width of target image
    // Calculate the percentage of change in width required and update it in toSize accordingly.
    
    if (sourceSize.width > toSize.width) {
        
        CGFloat ratioChange = (sourceSize.width - toSize.width) * 100 / sourceSize.width;
        
        toSize.height = sourceSize.height - (sourceSize.height * ratioChange / 100);
        
        needsRedraw = YES;
    }
    
    // Now we need to make sure that if we chnage the height of image in same proportion
    // Calculate the percentage of change in width required and update it in target size variable.
    // Also we need to again change the height of the target image in the same proportion which we
    /// have calculated for the change.
    
    if (toSize.height < targetSize.height) {
        
        CGFloat ratioChange = (targetSize.height - toSize.height) * 100 / targetSize.height;
        
        toSize.height = targetSize.height;
        toSize.width = toSize.width + (toSize.width * ratioChange / 100);
        
        needsRedraw = YES;
    }
    
    // To redraw the image
    
    if (needsRedraw) {
        UIGraphicsBeginImageContext(toSize);
        [image drawInRect:CGRectMake(0.0, 0.0, toSize.width, toSize.height)];
        result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Return the result
    
    return result;
}


/*
 created date:      21/10/2018
 last modified:     21/10/2018
 remarks:           Present the pretty date formats of start and end.  If activity is checked out give the user detail of how long instead of duplicated date.
 */
+(NSString*)PrettyDateDifference :(NSDate*)Start :(NSDate*)End :(NSString*) PostFixText {
    
    NSString *PrettyDate = @"";
    
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"EEE, dd MMM yyyy"];
    NSDateFormatter *timeformatter = [[NSDateFormatter alloc] init];
    [timeformatter setDateFormat:@"HH:mm"];

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:Start toDate:End options:0];
    
    NSInteger days = components.day;
    NSInteger hours = components.hour;
    NSInteger minutes = components.minute;
    
    // format text for plural/singular in EN only.
    NSString *DaysText = @"days";
    NSString *HoursText = @"hours";
    NSString *MinutesText = @"minutes";
    if (days==1) {
        DaysText = @"day";
    }
    if (hours==1) {
        HoursText = @"hour";
    }
    if (minutes==1) {
        MinutesText = @"minute";
    }
    
    if (days==0) {
        if (hours==0) {
            if (minutes==0) {
                // do nothing
            } else {
                PrettyDate = [NSString stringWithFormat:@"%ld %@%@", (long)minutes, MinutesText, PostFixText];
            }
            
        } else {
            if (minutes==0) {
                PrettyDate = [NSString stringWithFormat:@"%ld %@%@", (long)hours, HoursText, PostFixText];
            } else {
                PrettyDate = [NSString stringWithFormat:@"%ld %@ and %ld %@%@", (long)hours, HoursText, (long)minutes, MinutesText, PostFixText];
            }
        }
    } else {
        if (hours==0) {
            if (minutes==0) {
                PrettyDate = [NSString stringWithFormat:@"%ld %@%@", (long)days, DaysText, PostFixText];
            } else {
                PrettyDate = [NSString stringWithFormat:@"%ld %@ and %ld %@%@", (long)days, DaysText, (long)minutes, MinutesText, PostFixText];
            }
            
        } else {
            if (minutes==0) {
                PrettyDate = [NSString stringWithFormat:@"%ld %@ and %ld %@%@", (long)days, DaysText, (long)hours, HoursText, PostFixText];
            } else {
                PrettyDate = [NSString stringWithFormat:@"%ld %@, %ld %@ and %ld %@%@", (long)days, DaysText, (long)hours, HoursText, (long)minutes, MinutesText, PostFixText ];
            }
        }
    }
    return PrettyDate;
}

/*
 created date:      22/10/2018
 last modified:     11/08/2019
 remarks:
 */
+ (NSString*)FormatPrettyDate :(NSDate*)Dt {
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"EEE, dd MMM yyyy"];
    NSDateFormatter *timeformatter = [[NSDateFormatter alloc] init];
    [timeformatter setDateFormat:@"HH:mm"];
    return [NSString stringWithFormat:@"%@\n%@",[dateformatter stringFromDate:Dt], [timeformatter stringFromDate:Dt]];
}

/*
 created date:      08/04/2019
 last modified:     08/04/2019
 remarks:
 */
+ (NSString*)FormatPrettySimpleDate :(NSDate*)Dt {
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"dd MMM yyyy"];
    return [NSString stringWithFormat:@"%@",[dateformatter stringFromDate:Dt]];
}

/*
 created date:      22/10/2018
 last modified:     24/03/2019
 remarks:           Time formatter
 */
+ (NSString*)FormatPrettyTime :(NSDate*)Dt {
    
    NSDateFormatter *timeformatter = [[NSDateFormatter alloc] init];
    [timeformatter setDateFormat:@"HH:mm"];
    return [NSString stringWithFormat:@"%@", [timeformatter stringFromDate:Dt]];
}

/*
 created date:      19/03/2019
 last modified:     19/03/2019
 remarks:           taken from StackOverflow
 */
+ (UIImage *)convertImageToGrayScale:(UIImage *)image {
    
    
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    
    // Return the new grayscale image
    return newImage;
}

/*
 created date:      01/04/2019
 last modified:     01/04/2019
 remarks:           taken from StackOverflow
 */
+(bool)HasTopNotch {
    bool HasTopNotch = NO;

    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    if (mainWindow.safeAreaInsets.top >= 24.0) {
        HasTopNotch = YES;
    }
    return HasTopNotch;
}


/*
 created date:      15/06/2019
 last modified:     15/06/2019
 remarks:           taken from StackOverflow
 */
+ (BOOL)isSameDay:(NSDate*)date1 otherDay:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

/*
 created date:      15/06/2019
 last modified:     15/06/2019
 remarks:           taken from StackOverflow
 */
+ (BOOL)isSameDt:(NSDate*)date1 otherDay:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

/*
 created date:      17/06/2019
 last modified:     17/06/2019
 remarks:           taken from StackOverflow
 */
+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*
created date:       27/09/2019
last modified:      27/09/2019
remarks:
*/
+ (NSString *) getWeatherSystemImage:(NSString *) DarkSkyIconName {
    NSString *weatherSystemImage = @"";
    
    if ([DarkSkyIconName isEqualToString:@"clear-day"]) {
        weatherSystemImage = @"sun.max";
    } else if ([DarkSkyIconName isEqualToString:@"clear-night"]) {
        weatherSystemImage = @"moon.stars";
    } else if ([DarkSkyIconName isEqualToString:@"rain"]) {
        weatherSystemImage = @"cloud.heavyrain";
    } else if ([DarkSkyIconName isEqualToString:@"snow"]) {
        weatherSystemImage = @"cloud.snow";
    } else if ([DarkSkyIconName isEqualToString:@"sleet"]) {
        weatherSystemImage = @"cloud.sleet";
    } else if ([DarkSkyIconName isEqualToString:@"wind"]) {
        weatherSystemImage = @"wind";
    } else if ([DarkSkyIconName isEqualToString:@"fog"]) {
        weatherSystemImage = @"cloud.fog";
    } else if ([DarkSkyIconName isEqualToString:@"cloudy"]) {
        weatherSystemImage = @"cloud";
    } else if ([DarkSkyIconName isEqualToString:@"partly-cloudy-day"]) {
        weatherSystemImage = @"cloud.sun";
    } else if ([DarkSkyIconName isEqualToString:@"partly-cloudy-night"]) {
        weatherSystemImage = @"cloud.moon";
    } else if ([DarkSkyIconName isEqualToString:@"hail"]) {
        weatherSystemImage = @"cloud.hail";
    } else if ([DarkSkyIconName isEqualToString:@"thunderstorm"]) {
        weatherSystemImage = @"cloud.bolt";
    } else if ([DarkSkyIconName isEqualToString:@"tornado"]) {
        weatherSystemImage = @"tornado";
    } else {
        weatherSystemImage = @"exclamationmark.icloud";
    }

    return weatherSystemImage;
}



@end
