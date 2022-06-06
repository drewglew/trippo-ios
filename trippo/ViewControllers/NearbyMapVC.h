//
//  WikiMapVC.h
//  trippo
//
//  Created by andrew glew on 31/07/2021.
//  Copyright © 2021 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CustomAnnotationView.h"
#import "ClusterAnnotationView.h"
#import "AnnotationMK.h"
#import "NearbyPoiNSO.h"
#import "AppDelegate.h"
#import "PoiRLM.h"
#import "PoiDataEntryVC.h"
#import "Reachability.h"


@protocol NearbyMapDelegate <NSObject>
@end

NS_ASSUME_NONNULL_BEGIN

@interface NearbyMapVC : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, PoiDataEntryDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *MapView;
@property RLMRealm *realm;
@property (strong, nonatomic)  CLLocationManager *locationManager;
@property (nonatomic, weak) id <NearbyMapDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *nearbyitems;
@property (assign) bool isnearbyme;
@property (assign) bool hasimages;
@property (nonatomic) NSString *viewTitle;
@property (strong, nonatomic) PoiRLM *PointOfInterest;
@property (weak, nonatomic) IBOutlet UILabel *LabelNearby;
@end

NS_ASSUME_NONNULL_END
