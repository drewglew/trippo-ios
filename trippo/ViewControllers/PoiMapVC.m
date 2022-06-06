//
//  PoiMapVC.m
//  trippo
//
//  Created by andrew glew on 23/03/2021.
//  Copyright © 2021 andrew glew. All rights reserved.
//


#import "PoiMapVC.h"

@interface PoiMapVC ()
@property bool foundLocation;
@end

@implementation PoiMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.foundLocation = false;
    [self startUserLocationSearch];
    
    [self loadAnnotations];
    
    [self configureMapView];
    self.MapView.delegate = self;
    
    
    //[self zoomToPoiBounds];
    
    
}

/*
 created date:      28/07/2021
 last modified:     28/07/2021
 remarks:
 */
-(void)startUserLocationSearch{
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    self.foundLocation = true;
    MKUserLocation *anno = [[MKUserLocation alloc] init];
    anno.coordinate = self.locationManager.location.coordinate;
    
    anno.title = @"Current Location";
    [self.MapView addAnnotation:anno];

}


/*
 created date:      23/03/2021
 last modified:     23/03/2021
 remarks:
 */
-(void) configureMapView {
   [self.MapView registerClass:[CustomAnnotationView class] forAnnotationViewWithReuseIdentifier:MKMapViewDefaultAnnotationViewReuseIdentifier];
    [self.MapView registerClass:[ClusterAnnotationView class] forAnnotationViewWithReuseIdentifier:MKMapViewDefaultClusterAnnotationViewReuseIdentifier];
}

/*
 created date:      26/07/2021
 last modified:     26/07/2021
 remarks:
 */
-(void) loadAnnotations {
    
    //[self.MapView removeAnnotations:self.MapView.annotations];
    
    for (PoiRLM *poi in self.poifilteredcollection) {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake([poi.lat doubleValue], [poi.lon doubleValue]) title:poi.name subtitle:poi.key];
       
        [self.MapView addAnnotation:annotation];
    }
}

/*
 created date:      23/06/2019
 last modified:     23/06/2019
 remarks:
 */
- (void) zoomToPoiBounds {
    
    CLLocationDegrees minLatitude = DBL_MAX;
    CLLocationDegrees maxLatitude = -DBL_MAX;
    CLLocationDegrees minLongitude = DBL_MAX;
    CLLocationDegrees maxLongitude = -DBL_MAX;
    
    if (self.poifilteredcollection.count>0) {

        for (PoiRLM *poi in self.poifilteredcollection) {
            double Lat = [poi.lat doubleValue];
            double Lon = [poi.lon doubleValue];
            //NSLog(@"%@", activity.poi.name);
            minLatitude = fmin(Lat, minLatitude);
            maxLatitude = fmax(Lat, maxLatitude);
            minLongitude = fmin(Lon, minLongitude);
            maxLongitude = fmax(Lon, maxLongitude);
        }

        [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
    }
}

/*
 created date:      23/06/2019
 last modified:     23/06/2019
 remarks:
 */
-(void) setMapRegionForMinLat:(double)minLatitude minLong:(double)minLongitude maxLat:(double)maxLatitude maxLong:(double)maxLongitude {
    
    MKCoordinateRegion region;
    region.center.latitude = (minLatitude + maxLatitude) / 2;
    region.center.longitude = (minLongitude + maxLongitude) / 2;
    region.span.latitudeDelta = (maxLatitude - minLatitude);
    region.span.longitudeDelta = (maxLongitude - minLongitude);
    
    // MKMapView BUG: this snaps to the nearest whole zoom level, which is wrong- it doesn't respect the exact region you asked for. See http://stackoverflow.com/questions/1383296/why-mkmapview-region-is-different-than-requested
    [self.MapView setRegion:region animated:NO];
}

/*
created date:       26/07/2021
last modified:      26/07/2021
remarks:
*/

- (ClusterAnnotationView *)mapView:(MKMapView *)mapView viewForClusterAnnotation:(id<MKAnnotation>)annotation {
    
    ClusterAnnotationView * annotationView = (ClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"poiCluster"];
    
    if (!annotationView) {
        annotationView = [[ClusterAnnotationView alloc] initWithAnnotation:annotation
                                                reuseIdentifier:@"poiCluster"];
        
        annotationView.image = [UIImage systemImageNamed:@"circle"];
        annotationView.canShowCallout = NO;
    }
    else {
        annotationView.annotation = annotation;
    }
    annotationView.tintColor = [UIColor colorNamed:@"TrippoColor"];
    return annotationView;
}


/*
created date:       25/07/2021
last modified:      28/07/2021
remarks:
*/
- (CustomAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
    
    CustomAnnotationView *pinView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"poipin"];

    if ([pinView isKindOfClass:[MKClusterAnnotation class]]) {
        return nil;
    }
    if ([pinView isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
    
        if (!pinView) {
            pinView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"poipin"];
        } else {
            pinView.annotation = annotation;
        }
        
        pinView.canShowCallout = YES;
        UIImageView *poiImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [poiImage setImage:[AppDelegateDef.PoiBackgroundImageDictionary objectForKey:annotation.subtitle]];
        pinView.detailCalloutAccessoryView = poiImage;
        
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:30.0f weight:UIImageSymbolWeightThin];
       
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [leftButton setImage:[UIImage systemImageNamed:@"target" withConfiguration:config] forState:UIControlStateNormal];
        pinView.leftCalloutAccessoryView = leftButton;
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [rightButton setImage:[UIImage systemImageNamed:@"command" withConfiguration:config] forState:UIControlStateNormal];
        pinView.rightCalloutAccessoryView = rightButton;
        
        pinView.tintColor = [UIColor colorNamed:@"TrippoColor"];
        pinView.markerTintColor = [UIColor colorNamed:@"TrippoColor"];
        return pinView;
    } else {
        return nil;
    }
    
}

/*
created date:       27/07/2021
last modified:      29/07/2021
remarks:
*/
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

    MKPointAnnotation *myAnnotation = (MKPointAnnotation*) view.annotation;
    NSString *PoiKey = myAnnotation.subtitle;
    PoiRLM *p = [PoiRLM objectForPrimaryKey:PoiKey];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if (view.rightCalloutAccessoryView == control) {
        
        PoiDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"PoiDataEntryId"];
        controller.delegate = self;
        controller.realm = self.realm;
        controller.PointOfInterest = p;
        controller.newitem = false;
        [controller setModalPresentationStyle:UIModalPresentationPageSheet];
        [self presentViewController:controller animated:YES completion:nil];
    } else if (view.leftCalloutAccessoryView == control) {
        
        NearbyListingVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"NearbyListingViewController"];
        controller.frommenu = false;
        controller.delegate = self;
        controller.fromproject = false;
        controller.isnearbyme = false;
        controller.realm = self.realm;
        controller.PointOfInterest = p;
        [controller setModalPresentationStyle:UIModalPresentationPageSheet];
        [self presentViewController:controller animated:YES completion:nil];
    }
    
}

- (void)didCreatePoiFromProject :(PoiRLM*)Object {
    
}
- (void)didUpdatePoi :(NSString*)Method :(PoiRLM*)Object {
    
}

@end
