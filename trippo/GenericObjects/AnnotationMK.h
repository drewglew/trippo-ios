//
//  AnnotationMK.h
//  travelme
//
//  Created by andrew glew on 07/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface AnnotationMK : MKPointAnnotation {
    NSString *AdministrativeArea;
    NSString *SubAdministrativeArea;
    NSString *Country;
    NSString *CountryCode;
    NSString *Locality;
    NSString *SubLocality;
    NSString *PostCode;
    NSString *Type;
    NSString *PoiKey;
    NSString *Website;
    NSNumber *categoryid;
    UIImage *image;
}
@property (nonatomic) NSString *AdministrativeArea;
@property (nonatomic) NSString *SubAdministrativeArea;
@property (nonatomic) NSString *Country;
@property (nonatomic) NSString *CountryCode;
@property (nonatomic) NSString *Locality;
@property (nonatomic) NSString *SubLocality;
@property (nonatomic) NSString *FullThoroughFare;
@property (nonatomic) NSString *PostCode;
@property (nonatomic) NSString *Type;
@property (nonatomic) NSString *PoiKey;
@property (nonatomic) NSString *ActivityCompondKey;
@property (nonatomic) NSString *Website;
@property (nonatomic) NSNumber *categoryid;
@property (nonatomic) UIImage *image;
@end
