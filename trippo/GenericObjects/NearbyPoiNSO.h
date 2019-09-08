//
//  NearbyPoiNSO.h
//  travelme
//
//  Created by andrew glew on 16/07/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PoiNSO.h"

@interface NearbyPoiNSO : PoiNSO
@property (nonatomic) NSString *title;
@property (nonatomic) NSNumber *dist;
@property (nonatomic) UIImage *Image;
@property (nonatomic) NSString *PageId;
@property (nonatomic) NSString *type;


@end
