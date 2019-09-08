//
//  DirectionsVC.m
//  travelme
//
//  Created by andrew glew on 06/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "DirectionsVC.h"

@interface DirectionsVC ()

@end

@implementation DirectionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.MapView.delegate = self;
    // Do any additional setup after loading the view.
}

/*
 created date:      06/05/2018
 last modified:     08/05/2018
 remarks:
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /* if coming from activity window we need to find our current position
     which in turn once found will goto processMultiRouting method. */

    if (!self.FromScheduler) {
        self.ButtonOpenMap.hidden = false;
        self.ButtonOpenMap.layer.cornerRadius = 25;
        self.ButtonOpenMap.clipsToBounds = YES;
        self.ButtonOpenMap.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        self.ButtonOpenGMap.hidden = false;
        self.ButtonOpenGMap.layer.cornerRadius = 25;
        self.ButtonOpenGMap.clipsToBounds = YES;
        self.ButtonOpenGMap.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        self.ButtonUpdateCalc.hidden = true;
    } else {
        self.ButtonOpenMap.hidden = true;
        self.ButtonOpenGMap.hidden = true;
        self.ButtonUpdateCalc.hidden = false;
    }
    
    if (self.Route.count ==1) {
        [self startUserLocationSearch];
    } else {
        [self processMultiRouting];
    }
    
}

/*
 created date:      08/05/2018
 last modified:     04/02/2019
 remarks:
 */
-(void)processMultiRouting {
    
    bool firstItem = true;
    
    MKMapItem *mapItemPrevious;
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    self.Distance = 0;
    self.TravelTime = 0;
    
    for (PoiRLM *route in self.Route) {

        AnnotationMK *annotation = [[AnnotationMK alloc] init];

        annotation.coordinate = CLLocationCoordinate2DMake([route.lat doubleValue], [route.lon doubleValue]);
        annotation.title = route.name;
        annotation.subtitle = route.administrativearea;
        [self.MapView addAnnotation:annotation];
        
        MKPlacemark *placemark  = [[MKPlacemark alloc] initWithCoordinate:annotation.coordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];

        if (firstItem) {
            firstItem = false;
        } else  {
            request.source = mapItemPrevious;
            request.destination = mapItem;
            request.requestsAlternateRoutes = NO;
            //request.transportType
            
            if (route.transportid==nil) {
               request.transportType = MKDirectionsTransportTypeAny;
            } else if (route.transportid==[NSNumber numberWithInt:1]) {
                request.transportType = MKDirectionsTransportTypeWalking;
            } else  if (route.transportid==[NSNumber numberWithInt:2]) {
                request.transportType = MKDirectionsTransportTypeTransit;
            } else {
                request.transportType = MKDirectionsTransportTypeAutomobile;
            }

            MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
        
            [directions calculateDirectionsWithCompletionHandler:
             ^(MKDirectionsResponse *response, NSError *error) {
                 if (error) {
                     NSLog(@"ERROR");
                     NSLog(@"%@",[error localizedDescription]);
                 } else {
                     [self showRoute:response];
                 }
             }];
        }
        mapItemPrevious = [[MKMapItem alloc] initWithPlacemark:placemark];
    }
    [self zoomToAnnotationsBounds :self.MapView.annotations];
}

/*
 created date:      06/05/2018
 last modified:     06/05/2018
 remarks:
 */
-(void)startUserLocationSearch{
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}
/*
 created date:      06/05/2018
 last modified:     09/10/2018
 remarks:
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    [self.locationManager stopUpdatingLocation];
    PoiRLM *mylocation = [[PoiRLM alloc] init];
    
    mylocation.name = @"My Current Location";
    mylocation.lat = [NSNumber numberWithDouble: self.locationManager.location.coordinate.latitude];
    mylocation.lon = [NSNumber numberWithDouble:self.locationManager.location.coordinate.longitude];
    mylocation.administrativearea = @"";
    [self.Route insertObject:mylocation atIndex:0];
    
    [self processMultiRouting];
}
/*
 created date:      06/05/2018
 last modified:     04/02/2019
 remarks:
 */
-(void)showRoute:(MKDirectionsResponse *)response
{

    
    for (MKRoute *route in response.routes)
    {
        route.polyline.subtitle = [NSString stringWithFormat:@"%lu",(unsigned long)route.transportType];
        NSLog(@"transport=%lu",route.transportType);
        [self.MapView
         addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
        
        self.Distance += route.distance;
        self.TravelTime += (route.expectedTravelTime);
    }
    
    self.LabelJourneyDetail.text = [NSString stringWithFormat:@"Journey = %@ hrs",[self stringFromTimeInterval:[NSNumber numberWithLong:self.TravelTime]]];
    
    self.LabelDistance.text = [NSString stringWithFormat:@"Distance = %@", [self formattedDistanceForMeters :self.Distance]];
    
}


- (NSString *)stringFromTimeInterval:(NSNumber*)interval {
    long ti = [interval longValue];
    long seconds = ti % 60;
    long minutes = (ti / 60) % 60;
    long hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

/*
 created date:      08/10/2018
 last modified:     08/10/2018
 remarks:
 */
-(NSString *)formattedDistanceForMeters:(double)distance
{
    NSLengthFormatter *lengthFormatter = [NSLengthFormatter new];
    [lengthFormatter.numberFormatter setMaximumFractionDigits:1];
    
    if ([[AppDelegateDef MeasurementSystem] isEqualToString:@"U.K."] || ![AppDelegateDef MetricSystem]) {
        return [lengthFormatter stringFromValue:distance / 1609.34 unit:NSLengthFormatterUnitMile];
        
    } else {
        return [lengthFormatter stringFromValue:distance / 1000 unit:NSLengthFormatterUnitKilometer];
    }
}

/*
 created date:      08/05/2018
 last modified:     08/05/2018
 remarks:
 */
- (void) zoomToAnnotationsBounds:(NSArray *)annotations {
    
    CLLocationDegrees minLatitude = DBL_MAX;
    CLLocationDegrees maxLatitude = -DBL_MAX;
    CLLocationDegrees minLongitude = DBL_MAX;
    CLLocationDegrees maxLongitude = -DBL_MAX;
    
    for (AnnotationMK *annotation in annotations) {
        double annotationLat = annotation.coordinate.latitude;
        double annotationLong = annotation.coordinate.longitude;
        minLatitude = fmin(annotationLat, minLatitude);
        maxLatitude = fmax(annotationLat, maxLatitude);
        minLongitude = fmin(annotationLong, minLongitude);
        maxLongitude = fmax(annotationLong, maxLongitude);
    }
    
    // See function below
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
    
    // If your markers were 40 in height and 20 in width, this would zoom the map to fit them perfectly. Note that there is a bug in mkmapview's set region which means it will snap the map to the nearest whole zoom level, so you will rarely get a perfect fit. But this will ensure a minimum padding.
    UIEdgeInsets mapPadding = UIEdgeInsetsMake(40.0, 40.0, 40.0, 40.0);
    CLLocationCoordinate2D relativeFromCoord = [self.MapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.MapView];
    
    // Calculate the additional lat/long required at the current zoom level to add the padding
    CLLocationCoordinate2D topCoord = [self.MapView convertPoint:CGPointMake(0, mapPadding.top) toCoordinateFromView:self.MapView];
    CLLocationCoordinate2D rightCoord = [self.MapView convertPoint:CGPointMake(0, mapPadding.right) toCoordinateFromView:self.MapView];
    CLLocationCoordinate2D bottomCoord = [self.MapView convertPoint:CGPointMake(0, mapPadding.bottom) toCoordinateFromView:self.MapView];
    CLLocationCoordinate2D leftCoord = [self.MapView convertPoint:CGPointMake(0, mapPadding.left) toCoordinateFromView:self.MapView];
    
    double latitudeSpanToBeAddedToTop = relativeFromCoord.latitude - topCoord.latitude;
    double longitudeSpanToBeAddedToRight = relativeFromCoord.latitude - rightCoord.latitude;
    double latitudeSpanToBeAddedToBottom = relativeFromCoord.latitude - bottomCoord.latitude;
    double longitudeSpanToBeAddedToLeft = relativeFromCoord.latitude - leftCoord.latitude;
    
    maxLatitude = maxLatitude + latitudeSpanToBeAddedToTop;
    minLatitude = minLatitude - latitudeSpanToBeAddedToBottom;
    
    maxLongitude = maxLongitude + longitudeSpanToBeAddedToRight;
    minLongitude = minLongitude - longitudeSpanToBeAddedToLeft;
    
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
}

-(void) setMapRegionForMinLat:(double)minLatitude minLong:(double)minLongitude maxLat:(double)maxLatitude maxLong:(double)maxLongitude {
    
    MKCoordinateRegion region;
    region.center.latitude = (minLatitude + maxLatitude) / 2;
    region.center.longitude = (minLongitude + maxLongitude) / 2;
    region.span.latitudeDelta = (maxLatitude - minLatitude);
    region.span.longitudeDelta = (maxLongitude - minLongitude);
    
    // MKMapView BUG: this snaps to the nearest whole zoom level, which is wrong- it doesn't respect the exact region you asked for. See http://stackoverflow.com/questions/1383296/why-mkmapview-region-is-different-than-requested
    [self.MapView setRegion:region animated:YES];
}


/*
 created date:      06/05/2018
 last modified:     23/10/2018
 remarks:
 */
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        if ([overlay.subtitle isEqualToString:@"1"]) {
            
            [renderer setStrokeColor:[UIColor colorWithRed:23.0f/255.0f green:130.0f/255.0f blue:196.0f/255.0f alpha:1.0]];
        } else if ([overlay.subtitle isEqualToString:@"2"]) {
            
            [renderer setStrokeColor:[UIColor colorWithRed:106.0f/255.0f green:76.0f/255.0f blue:147.0f/255.0f alpha:1.0]];
        } else {
            [renderer setStrokeColor:[UIColor colorWithRed:106.0f/255.0f green:76.0f/255.0f blue:147.0f/255.0f alpha:1.0]];
        }
        [renderer setLineWidth:5.0];
        return renderer;
    }
    return nil;
}

/*
 created date:      06/05/2018
 last modified:     06/05/2018
 remarks:           not used
 */
-(void)zoomToPolyLine: (MKMapView*)map polyline: (MKPolyline*)polyline animated: (BOOL)animated
{
    [map setVisibleMapRect:[polyline boundingMapRect] edgePadding:UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0) animated:animated];
}
/*
 created date:      06/05/2018
 last modified:     06/05/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
    
}

/*
 created date:      16/06/2018
 last modified:     09/10/2018
 remarks:           Used
 */
- (IBAction)OpenMapsPressed:(id)sender {
    
    NSString* directionsURL;
    PoiNSO *poi = [self.Route lastObject];
    if (self.Route.count==1) {
        directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%@,%@",self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude, poi.lat, poi.lon];
    } else {
        PoiNSO *originpoi = [self.Route firstObject];
        directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%@,%@&daddr=%@,%@",originpoi.lat, originpoi.lon, poi.lat, poi.lon];
    }
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL] options:@{} completionHandler:^(BOOL success) {}];
    }
}

/*
 created date:      09/10/2018
 last modified:     09/10/2018
 remarks:           Open Google Map App (if it exists)
 */
- (IBAction)OpenGoogleMapsPressed:(id)sender {
    
    NSString *directionsURL;
    PoiNSO *poi = [self.Route lastObject];
    if (self.Route.count==1) {
        directionsURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%@,%@",self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude, poi.lat, poi.lon];
    } else {
        PoiNSO *originpoi = [self.Route firstObject];
        directionsURL = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%@,%@&daddr=%@,%@",originpoi.lat, originpoi.lon, poi.lat, poi.lon];
    }
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: directionsURL] options:@{} completionHandler:^(BOOL success) {}];
        } else {
            // Fallback on earlier versions
            
        }
    }
    
}


/*
 created date:      07/10/2018
 last modified:     07/10/2018
 remarks:           Update the trip summary
 */
- (IBAction)UpdateCalcPressed:(id)sender {

    [self.realm beginWriteTransaction];
 
    if (self.ActivityState == [NSNumber numberWithInteger:0]) {
        self.Trip.routeplannedcalculateddt = [NSDate date];
        self.Trip.routeplannedtotaltravelminutes = [NSNumber numberWithLong:self.TravelTime];
        self.Trip.routeplannedtotaltraveldistance = [NSNumber numberWithDouble:self.Distance];
    } else {
        self.Trip.routeactualcalculateddt = [NSDate date];
        self.Trip.routeactualtotaltravelminutes = [NSNumber numberWithLong:self.TravelTime];
        self.Trip.routeactualtotaltraveldistance = [NSNumber numberWithDouble:self.Distance];
    }
    [self.realm commitWriteTransaction];
    
}




@end
