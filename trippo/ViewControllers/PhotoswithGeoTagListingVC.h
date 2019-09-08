//
//  PhotoswithGeoTagListingVC.h
//  trippo
//
//  Created by andrew glew on 01/12/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <MapKit/MapKit.h>
#import "ImageNSO.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotoswithGeoTagListingVC : UIViewController {
     NSThread *queueThread;
}
@property (nonatomic, readwrite) CGSize ImageSize;
@property (strong, nonatomic) NSMutableArray *ImageItems;
@end

NS_ASSUME_NONNULL_END
