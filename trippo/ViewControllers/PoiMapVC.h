//
//  PoiMapVC.h
//  trippo
//
//  Created by andrew glew on 23/03/2021.
//  Copyright © 2021 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CustomAnnotationView.h"
#import "ClusterAnnotationView.h"
#import "AnnotationMK.h"
#import "PoiRLM.h"
#import "AppDelegate.h"
#import "NearbyListingVC.h"
#import "PoiDataEntryVC.h"


@protocol PoiMapDelegate <NSObject>
@end


NS_ASSUME_NONNULL_BEGIN

@interface PoiMapVC : UIViewController <MKMapViewDelegate, NearbyListingDelegate, PoiDataEntryDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *MapView;
@property RLMResults<PoiRLM *> *poifilteredcollection;
@property RLMRealm *realm;
@property (strong, nonatomic)  CLLocationManager *locationManager;
@property (nonatomic, weak) id <PoiMapDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
