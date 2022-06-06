//
//  WikiMapVC.m
//  trippo
//
//  Created by andrew glew on 31/07/2021.
//  Copyright © 2021 andrew glew. All rights reserved.
//

#import "NearbyMapVC.h"

@implementation NearbyMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // if nearby me or nearby poi?
    self.LabelNearby.text = self.viewTitle;
    
    if (self.isnearbyme) {
        [self startUserLocationSearch];
    } else {
        MKUserLocation *anno = [[MKUserLocation alloc] init];
        anno.coordinate = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
        
        anno.title = self.PointOfInterest.name;
        [self.MapView addAnnotation:anno];
        [self zoomToPoiBounds];
    }
    
    
    [self loadAnnotations];
    
    [self configureMapView];
    self.MapView.delegate = self;

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
    [self zoomToPoiBounds];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
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
    
    for (NearbyPoiNSO *poi in self.nearbyitems) {
        
        NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
        [fmt setPositiveFormat:@"0.##"];

        NSMeasurementFormatter *formatter = [[NSMeasurementFormatter alloc] init];
        formatter.locale = [NSLocale currentLocale];
        
        NSMeasurement *distance = [[NSMeasurement alloc] initWithDoubleValue:[poi.dist doubleValue] unit:NSUnitLength.meters];

            
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(poi.Coordinates.latitude, poi.Coordinates.longitude) title:poi.title subtitle:[NSString stringWithFormat:@"%@",[formatter stringFromMeasurement:distance]]];
       
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
    
    if (self.nearbyitems.count>0) {

        for (NearbyPoiNSO *poi in self.nearbyitems) {
            NSNumber *latitude = [NSNumber numberWithDouble:poi.Coordinates.latitude];
            NSNumber *longitude = [NSNumber numberWithDouble:poi.Coordinates.longitude];
            minLatitude = fmin([latitude doubleValue], minLatitude);
            maxLatitude = fmax([latitude doubleValue], maxLatitude);
            minLongitude = fmin([longitude doubleValue], minLongitude);
            maxLongitude = fmax([longitude doubleValue], maxLongitude);
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
    
    CustomAnnotationView *pinView = (CustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"nearbypin"];
/*
    if ([pinView isKindOfClass:[MKClusterAnnotation class]]) {
        return nil;
    }
*/
    if ([pinView isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
    
        UIImageSymbolConfiguration *configButtons = [UIImageSymbolConfiguration configurationWithPointSize:25.0f weight:UIImageSymbolWeightThin];
        
        
        if (!pinView) {
            pinView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"nearbypin"];
        } else {
            pinView.annotation = annotation;
        }

        pinView.canShowCallout = YES;
        UIImageView *poiImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title = %@", annotation.title];
        NearbyPoiNSO *n = [[self.nearbyitems filteredArrayUsingPredicate: predicate] firstObject];

        if (n.Image != nil) {
            [poiImage setImage:[ToolBoxNSO imageWithImage:n.Image scaledToSize:poiImage.bounds.size]];
            pinView.detailCalloutAccessoryView = poiImage;
        }
        
               
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [rightButton setImage:[UIImage systemImageNamed:@"plus" withConfiguration:configButtons] forState:UIControlStateNormal];
        pinView.rightCalloutAccessoryView = rightButton;
        
        pinView.tintColor = [UIColor colorNamed:@"TrippoColor"];
        pinView.markerTintColor = [UIColor colorNamed:@"TrippoColor"];
        return pinView;
    } else {
        return nil;
    }
}

/*
 created date:      19/07/2018
 last modified:     19/07/2018
 remarks:
 */
- (bool)checkInternet
{
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        return false;
    }
    else
    {
        //connection available
        return true;
    }
    
}


/*
 created date:      31/01/2019
 last modified:     31/01/2019
 remarks:
 */
- (void)downloadImageFrom:(NSURL *)path completion:(void (^)(UIImage *image))completionBlock {
    dispatch_queue_t queue = dispatch_queue_create("Image Download", 0);
    dispatch_async(queue, ^{
        NSData *data = [[NSData alloc] initWithContentsOfURL:path];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(data) {
                completionBlock([[UIImage alloc] initWithData:data]);
            } else {
                completionBlock(nil);
            }
        });
    });
}


/*
 created date:      13/06/2018
 last modified:     17/07/2018
 remarks:
 */
-(void)fetchFromWikiApi:(NSString *)url withDictionary:(void (^)(NSDictionary* data))dictionary{
    
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:data
                                                                                              options:0
                                                                                                error:NULL];
                                      dictionary(dicData);
                                  }];
    [task resume];
}



/*
created date:       27/07/2021
last modified:      29/07/2021
remarks:
*/
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

    MKPointAnnotation *myAnnotation = (MKPointAnnotation*) view.annotation;

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title = %@", myAnnotation.title];
    NearbyPoiNSO *n = [[self.nearbyitems filteredArrayUsingPredicate: predicate] firstObject];
  
    if (view.rightCalloutAccessoryView == control) {
    
        if ([self checkInternet]) {
                        
            PoiRLM *poi = [[PoiRLM alloc] init];
            poi.key = [[NSUUID UUID] UUIDString];
            poi.lat = [NSNumber numberWithDouble:n.Coordinates.latitude];
            poi.lon = [NSNumber numberWithDouble:n.Coordinates.longitude];
            poi.wikititle = n.wikititle;
            
            CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
            
            //self.ViewLoading.hidden = false;
            //[self.LoadingActivityIndictor startAnimating];
            
            [geoCoder reverseGeocodeLocation: [[CLLocation alloc] initWithLatitude:n.Coordinates.latitude longitude:n.Coordinates.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
                if (error) {
                    NSLog(@"%@", [NSString stringWithFormat:@"%@", error.localizedDescription]);
                } else {
                    if ([placemarks count]>0) {
                        CLPlacemark *placemark = [placemarks firstObject];
                        
                        NSString *AdminArea = placemark.subAdministrativeArea;
                        if ([AdminArea isEqualToString:@""] || AdminArea == NULL) {
                            AdminArea = placemark.administrativeArea;
                        }
                        poi.administrativearea = [NSString stringWithFormat:@"%@, %@", AdminArea,placemark.ISOcountryCode];
                        poi.country = placemark.country;
                        poi.sublocality = placemark.subLocality;
                        poi.locality = placemark.locality;
                        poi.postcode = placemark.postalCode;
                        poi.countrycode = placemark.ISOcountryCode;
                        poi.fullthoroughfare = [NSString stringWithFormat:@"%@, %@", placemark.thoroughfare, placemark.subThoroughfare];
                        
                    }
                    poi.name = n.title;

                    /*
                     Obtain Wiki records based on coordinates & local language.  (radius is in meters, we should use same range as type used to search photos)
                     https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=Chichester
                    */
                    
                    NSArray *parms = [poi.wikititle componentsSeparatedByString:@"~"];

                    NSString *url = [NSString stringWithFormat:@"https://%@.wikipedia.org/w/api.php?action=query&format=json&formatversion=2&prop=description|extracts|pageimages|pageterms&exintro=&explaintext=&piprop=original|thumbnail&titles=%@",[parms objectAtIndex:0],[parms objectAtIndex:1]];
                    
                    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

                    /* get data */
                    [self fetchFromWikiApi:url withDictionary:^(NSDictionary *data) {
                        
                        NSDictionary *query = [data objectForKey:@"query"];
                        NSArray *pages =  [query objectForKey:@"pages"];
                        NSDictionary *item =  [pages firstObject];
                        poi.privatenotes = [item objectForKey:@"extract"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            
                            if (self.hasimages) {
                                
                                NSArray *AllowedTypes = [[NSArray alloc] initWithObjects:@"png",@"gif",@"jpg",@"jpeg",@"bmp",nil];
                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@ AND SELF != nil", AllowedTypes];
                                
                                
                                NSDictionary *original = [item objectForKey:@"original"];
                                NSString *source = [original objectForKey:@"source"];
                                
                                bool typefound = [predicate evaluateWithObject:[[source pathExtension] lowercaseString]];
                                
                                if (!typefound) {
                                    NSLog(@"extension type=%@",[[source pathExtension] lowercaseString]);
                                    NSDictionary *thumbnail = [item objectForKey:@"thumbnail"];
                                    source = [thumbnail objectForKey:@"source"];
                                }
                                
                                NSURL *url = [NSURL URLWithString: source];
                                
                                [self downloadImageFrom:url completion:^(UIImage *image) {
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^(){
                                        // self.ViewLoading.hidden = true;
                                        // [self.LoadingActivityIndictor stopAnimating];
                                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                        PoiDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"PoiDataEntryId"];
                                        
                                        controller.delegate = self;
                                        controller.PointOfInterest = poi;
                                        controller.realm = self.realm;
                                        controller.newitem = true;
                                        controller.readonlyitem = false;
                                        controller.fromproject = false;
                                        controller.TripItem = nil;
                                         
                                        controller.ActivityItem = nil;
                                        controller.fromnearby = true;
                                        if (image!=nil) {
                                            UIImage *squareimage = image;
                                            if (image.size.height > image.size.width) {
                                                CGRect aRect = CGRectMake(0,(image.size.height / 2) - (image.size.width / 2), image.size.width, image.size.width);
                                                CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], aRect);
                                                squareimage = [UIImage imageWithCGImage:imageRef];
                                                CGImageRelease(imageRef);
                                            } else if (image.size.height < image.size.width) {
                                                CGRect aRect = CGRectMake((image.size.width / 2) - (image.size.height / 2), 0, image.size.height, image.size.height);
                                                CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], aRect);
                                                squareimage = [UIImage imageWithCGImage:imageRef];
                                                CGImageRelease(imageRef);
                                            }
                                            
                                            
                                            controller.WikiMainImage = squareimage;
                                            controller.WikiMainImageDescription = [item objectForKey:@"description"];
                                            controller.haswikimainimage = true;
                                        } else {
                                            controller.haswikimainimage = false;
                                        }
                                        
                                        [controller setModalPresentationStyle:UIModalPresentationPageSheet];
                                        [self presentViewController:controller animated:YES completion:nil];
                                    });
                                }];
                                
                            } else {
                                //self.ViewLoading.hidden = true;
                                //[self.LoadingActivityIndictor stopAnimating];
                                
                                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                
                                PoiDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"PoiDataEntryId"];
                                
                                controller.delegate = self;
                                controller.PointOfInterest = poi;
                                controller.realm = self.realm;
                                controller.newitem = true;
                                controller.readonlyitem = false;
                                controller.fromproject = false;
                                controller.TripItem = nil;
                                controller.ActivityItem = nil;
                                controller.fromnearby = true;
                                controller.haswikimainimage = false;
                                
                                [controller setModalPresentationStyle:UIModalPresentationPageSheet];
                                [self presentViewController:controller animated:YES completion:nil];
                            }
                        });
                        
                    }];
           
                }
            }];
        }
    }
}

- (void)didCreatePoiFromProject :(PoiRLM*)Object {
    
}

- (void)didUpdatePoi :(NSString*)Method :(PoiRLM*)Object {
    
    
}


@end
