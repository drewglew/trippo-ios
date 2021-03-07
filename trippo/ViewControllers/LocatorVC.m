//
//  LocatorVC.m
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "LocatorVC.h"

@interface LocatorVC () <LocatorDelegate, PoiDataEntryDelegate>
@end

@implementation LocatorVC

MKLocalSearch *localSearch;
MKLocalSearchResponse *results;

@synthesize MapView = _MapView;
@synthesize delegate;
@synthesize PointOfInterest;



/*
 created date:      27/04/2018
 last modified:     14/01/2020
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.SearchBar.delegate = self;
    self.TableViewSearchResult.delegate = self;
    [self startUserLocationSearch];
     UILongPressGestureRecognizer* mapLongPressAddAnnotation = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(AddAnnotationToMap:)];
    
    [mapLongPressAddAnnotation setMinimumPressDuration:0.5];
    [self.MapView addGestureRecognizer:mapLongPressAddAnnotation];    // Do any additional setup after loading the view.
    self.MapView.delegate = self;

    NSArray *excludedPois = [[NSArray alloc] initWithObjects:  MKPointOfInterestCategoryPolice, MKPointOfInterestCategoryPostOffice, MKPointOfInterestCategoryLaundry, MKPointOfInterestCategoryPharmacy, MKPointOfInterestCategoryFireStation, MKPointOfInterestCategoryEVCharger, MKPointOfInterestCategoryBank, MKPointOfInterestCategoryATM, nil];
       
    MKPointOfInterestFilter *filter = [[MKPointOfInterestFilter alloc] initExcludingCategories:excludedPois];
    
    self.MapView.pointOfInterestFilter = filter;
    
    
    
    self.firstactivityinproject = false;
    
    if (self.fromproject) {
        [self zoomToPoiBounds];
    }

    self.PointOfInterest = [[PoiRLM alloc] init];
    self.PointOfInterest.name = @"";
    self.Coordinates = kCLLocationCoordinate2DInvalid;
    self.PointOfInterest.key = [[NSUUID UUID] UUIDString];
    
    self.TableViewSearchResult.rowHeight = 70;
    
    self.SearchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.SearchBar.searchTextField.backgroundColor = [UIColor tertiarySystemBackgroundColor];
    self.SearchBar.searchTextField.textColor = [UIColor colorNamed:@"TrippoColor"];

    self.TableViewSearchResult.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.SegmentMapType.selectedSegmentTintColor = [UIColor colorNamed:@"TrippoColor"];
    [self.SegmentMapType setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor systemBackgroundColor], NSFontAttributeName: [UIFont systemFontOfSize:13]} forState:UIControlStateSelected];
    /* new block 20200111 */
    RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
    
    AssistantRLM *assist = [[settings[0].AssistantCollection objectsWhere:@"ViewControllerName=%@",@"LocatorVC"] firstObject];

    if ([assist.State integerValue] == 1) {
    
        UIView* helperView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 400)];
        helperView.backgroundColor = [UIColor labelColor];
        
        helperView.layer.cornerRadius=8.0f;
        helperView.layer.masksToBounds=YES;
        
        UILabel* title = [[UILabel alloc] init];
        title.frame = CGRectMake(10, 18, helperView.bounds.size.width - 20, 24);
        title.textColor =  [UIColor secondarySystemBackgroundColor];
        title.font = [UIFont systemFontOfSize:22 weight:UIFontWeightThin];
        title.text = @"Locate a Point of Interest";
        title.textAlignment = NSTextAlignmentCenter;
        [helperView addSubview:title];
        
        UIImageView *logo = [[UIImageView alloc] init];
        logo.frame = CGRectMake(10, helperView.bounds.size.height - 50, 80, 40);
        logo.image = [UIImage imageNamed:@"Trippo"];
        [helperView addSubview:logo];
        
        UILabel* helpText = [[UILabel alloc] init];
        helpText.frame = CGRectMake(10, 50, helperView.bounds.size.width - 20, 300);
        helpText.textColor =  [UIColor secondarySystemBackgroundColor];
        helpText.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        helpText.numberOfLines = 0;
        helpText.adjustsFontSizeToFitWidth = YES;
        helpText.minimumScaleFactor = 0.5;

        helpText.text = @"Whenever a new Point Of Interest needs to be created firstly you must set the location of the new item.  The map has 4 different layers to chose from.  If you are working within a Trip already with activities instead of directly from the Point Of Interest listing the default zoom level and focus on the map will be within range of the active trip.  Using the search-bar the system locates places within the current view at  greater detail level than locations off the map.\n\nTo pinpoint a location that might not be available searching by name you can long depress to specifically set position. Once the location has been set you may proceed onto the Point Of Interest detail view.\n\nIn case of no internet connectivity you can still create a Point Of Interest, but it requires a correct location setup once back online.";
        helpText.textAlignment = NSTextAlignmentLeft;
        [helperView addSubview:helpText];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(helperView.bounds.size.width - 40.0, 3.5, 35.0, 35.0); // x,y,width,height
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightRegular];
        [button setImage:[UIImage systemImageNamed:@"xmark.circle" withConfiguration:config] forState:UIControlStateNormal];
        [button setTintColor: [UIColor secondarySystemBackgroundColor]];
        [button addTarget:self action:@selector(helperViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [helperView addSubview:button];
        
        [self.view addSubview:helperView];
    }
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

}

/*
 created date:      14/01/2020
 last modified:     14/01/2020
 remarks:
 */
-(void)helperViewButtonPressed :(id)sender {
    RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
    AssistantRLM *assist = [[settings[0].AssistantCollection objectsWhere:@"ViewControllerName=%@",@"LocatorVC"] firstObject];
    //NSLog(@"%@",assist);
    if ([assist.State integerValue] == 1) {
        [self.realm beginWriteTransaction];
        assist.State = [NSNumber numberWithInteger:0];
        [self.realm commitWriteTransaction];
    }
    UIView *parentView = [(UIView *)sender superview];
    [parentView setHidden:TRUE];
    
}


/*
 created date:      11/05/2018
 last modified:     11/05/2018
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
/*
 created date:      06/05/2018
 last modified:     23/06/2019
 remarks:
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    [self.locationManager stopUpdatingLocation];
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    
    if ([self checkInternet]) {

        [geoCoder reverseGeocodeLocation: [[CLLocation alloc] initWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error) {
                
                AnnotationMK *anno = [[AnnotationMK alloc] init];
                if ([placemarks count]>0) {
                    CLPlacemark *placemark = [placemarks firstObject];
                    anno.coordinate = placemark.location.coordinate;
                    anno.title = placemark.name;
                    NSString *AdminArea = placemark.subAdministrativeArea;
                    if ([AdminArea isEqualToString:@""] || AdminArea == NULL) {
                        AdminArea = placemark.administrativeArea;
                    }
                    
                    anno.subtitle = [NSString stringWithFormat:@"%@, %@", AdminArea, placemark.ISOcountryCode ];
                    
                    anno.Country = placemark.country;
                    anno.SubLocality = placemark.subLocality;
                    anno.Locality = placemark.locality;
                    anno.PostCode = placemark.postalCode;
                    anno.CountryCode = placemark.ISOcountryCode;
                    anno.FullThoroughFare = [NSString stringWithFormat:@"%@, %@", placemark.thoroughfare, placemark.subThoroughfare];

                    [self.MapView addAnnotation:anno];
                    // issue when fromproject, but without any activities to refer to, this will not catch.
                    if (!self.fromproject || self.firstactivityinproject) {
                        [self.MapView setCenterCoordinate:anno.coordinate animated:YES];
                        [self.MapView selectAnnotation:anno animated:true];
                    }
                    
                } else {
                    anno.title = @"Unknown Place";
                }
                [self.MapView addAnnotation:anno];
                [self.MapView selectAnnotation:anno animated:true];
            }
        }];
        
    } else {
        
        self.PointOfInterest.lat = [NSNumber numberWithDouble:self.locationManager.location.coordinate.latitude];
        self.PointOfInterest.lon = [NSNumber numberWithDouble:self.locationManager.location.coordinate.longitude];
        self.Coordinates = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
        self.LabelWarningNoInet.hidden = false;
        
        self.LabelWarningNoInet.layer.cornerRadius = 5;
        self.LabelWarningNoInet.layer.masksToBounds = true;
        
        self.ButtonSkip.hidden = false;
        self.ImageViewGlobe.hidden = false;
        self.SearchBar.hidden = true;
        self.MapView.hidden = true;
        self.ButtonClear.hidden = true;
        self.ButtonNext.hidden = true;
    }
        
}

/*
created date:      27/08/2019
last modified:     27/08/2019
remarks:
*/
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
    
    MKMarkerAnnotationView *pinView = (MKMarkerAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    
    if (!pinView) {
        pinView = [[MKMarkerAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"];
    } else {
        pinView.annotation = annotation;
    }
    pinView.markerTintColor = [UIColor colorNamed:@"TrippoColor"];
    return pinView;
}

/*
 created date:      27/04/2018
 last modified:     29/04/2018
 remarks: User gestures a long tap, the annotation is placed where the figure is.
 */
-(void)AddAnnotationToMap:(UILongPressGestureRecognizer *)gesture
{
    UIGestureRecognizer *recognizer = (UIGestureRecognizer*) gesture;
    
    if(UIGestureRecognizerStateBegan == gesture.state)
    {
        CGPoint tapPoint = [recognizer locationInView:self.MapView];
        CLLocationCoordinate2D location = [self.MapView convertPoint:tapPoint toCoordinateFromView:self.MapView];

        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        
        
        /* work here 31/08/2019 */

        
        
        [geoCoder reverseGeocodeLocation: [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error) {
                
                AnnotationMK *anno = [[AnnotationMK alloc] init];

                if ([placemarks count]>0) {
                    
                    
                    
                    CLPlacemark *placemark = [placemarks firstObject];
                    anno.coordinate = placemark.location.coordinate;
                    anno.title = placemark.name;
                    
                   
                    
                     NSString *AdminArea = placemark.subAdministrativeArea;
                    if ([AdminArea isEqualToString:@""] || AdminArea == NULL) {
                        AdminArea = placemark.administrativeArea;
                    }
                    
                    anno.subtitle = [NSString stringWithFormat:@"%@, %@", AdminArea, placemark.ISOcountryCode ];
                    
                    anno.Country = placemark.country;
                    anno.SubLocality = placemark.subLocality;
                    anno.Locality = placemark.locality;
                    anno.PostCode = placemark.postalCode;
                    anno.CountryCode = placemark.ISOcountryCode;
                    anno.FullThoroughFare = [NSString stringWithFormat:@"%@, %@", placemark.thoroughfare, placemark.subThoroughfare];

                    //anno.subtitle = placemark.subLocality;
                    [self.MapView addAnnotation:anno];
                    [self.MapView selectAnnotation:anno animated:true];
                    
                    NSLog(@"%@", anno);

                    
                } else {
                    anno.title = @"Unknown Place";
                }
                 [self.MapView addAnnotation:anno];
                 [self.MapView selectAnnotation:anno animated:true];
            }
        }];
        
    }
    
}

/*
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    self.TableViewSearchResult.hidden=false;
    // Cancel any previous searches.
    [localSearch cancel];
    
    if ([searchBar.text isEqualToString:@""]) {
        results = nil;
        [self.TableViewSearchResult reloadData];
        
        return;
    }
    
    NSArray *excludedPois = [[NSArray alloc] initWithObjects:  MKPointOfInterestCategoryPolice, MKPointOfInterestCategoryPostOffice, MKPointOfInterestCategoryLaundry, MKPointOfInterestCategoryPharmacy, MKPointOfInterestCategoryFireStation, MKPointOfInterestCategoryEVCharger, MKPointOfInterestCategoryBank, MKPointOfInterestCategoryATM, nil];
    
    MKPointOfInterestFilter *filter = [[MKPointOfInterestFilter alloc] initExcludingCategories:excludedPois];
    
    MKLocalSearchCompleter *completer = [[MKLocalSearchCompleter alloc] init];
    
    completer.pointOfInterestFilter = filter;
    completer.queryFragment = searchBar.text;
    
    // Perform a new search.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchBar.text;
    request.region = self.MapView.region;
    
    
    localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){

        if (error != nil) {
            return;
        }
        
        if ([response.mapItems count] == 0) {
            return;
        }
        results = response;
        [self.TableViewSearchResult reloadData];
    }];
}

/*
 created date:      28/04/2018
 last modified:     28/04/2018
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results.mapItems count];
}

/*
 created date:      28/04/2018
 last modified:     28/08/2019
 remarks:
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *IDENTIFIER = @"SearchResultsCell";
    
    SearchResultListCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[SearchResultListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    MKMapItem *item = results.mapItems[indexPath.row];

    NSArray *formattedAddressLines = [[[item valueForKey:@"place"] valueForKey:@"address"] valueForKey:@"formattedAddressLines"];
    
    
    
    NSString *formattedAddress = @"";
    
    for (NSString* address in formattedAddressLines) {
        if ([formattedAddressLines firstObject] != address) {
            formattedAddress = [NSString stringWithFormat:@"%@, %@", formattedAddress, address];
        } else {
             formattedAddress = [NSString stringWithFormat:@"%@", address];
        }
    }

    cell.subTitle = formattedAddress;
    cell.LabelSearchItem.text = item.name;
    cell.LabelSearchCountryItem.text = cell.subTitle;

    return cell;
}

/*
 created date:      28/04/2018
 last modified:     09/05/2018
 remarks:
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self.SearchBar setActive:NO animated:YES];
    static NSString *IDENTIFIER = @"SearchResultsCell";
    
    SearchResultListCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[SearchResultListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    MKMapItem *item = results.mapItems[indexPath.row];
    
    AnnotationMK *anno = [[AnnotationMK alloc] init];
    anno.title = item.name;
    
    NSString *AdminArea = item.placemark.subAdministrativeArea;
    if ([AdminArea isEqualToString:@""] || AdminArea == NULL) {
        AdminArea = item.placemark.administrativeArea;
    }
    
    anno.subtitle = [NSString stringWithFormat:@"%@, %@", AdminArea,item.placemark.countryCode ];
    //fullThoroughfare 
    anno.Country = item.placemark.country;
    anno.SubLocality = item.placemark.subLocality;
    anno.Locality = item.placemark.locality;
    anno.PostCode = item.placemark.postalCode;
    anno.CountryCode = item.placemark.countryCode;
    anno.FullThoroughFare = [NSString stringWithFormat:@"%@, %@",item.placemark.thoroughfare, item.placemark.subThoroughfare];
    anno.coordinate = item.placemark.coordinate;
    
    [self.MapView addAnnotation:anno];
    [self.MapView selectAnnotation:anno animated:YES];
    [self.MapView setCenterCoordinate:item.placemark.location.coordinate animated:YES];
    [self.MapView setUserTrackingMode:MKUserTrackingModeNone];
    self.SearchBar.text  = item.name;
    [self.SearchBar endEditing:YES];
    self.TableViewSearchResult.hidden = true;
}

/*
 created date:      27/04/2018
 last modified:     28/04/2018
 remarks:
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.SearchBar resignFirstResponder];
    self.TableViewSearchResult.hidden=true;
}





/*
 created date:      27/04/2018
 last modified:     19/05/2018
 remarks:
 */
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    id annotation = view.annotation;
    if (![annotation isKindOfClass:[MKUserLocation class]]) {
        AnnotationMK *annotation = (AnnotationMK *)[view annotation];
        self.PointOfInterest.name = annotation.title;
        self.PointOfInterest.administrativearea = annotation.subtitle;
        self.PointOfInterest.lat = [NSNumber numberWithDouble:annotation.coordinate.latitude];
        self.PointOfInterest.lon = [NSNumber numberWithDouble:annotation.coordinate.longitude];
        self.Coordinates = annotation.coordinate;
        self.PointOfInterest.country = annotation.Country;
        self.PointOfInterest.countrycode = annotation.CountryCode;
        self.PointOfInterest.locality = annotation.Locality;
        self.PointOfInterest.sublocality = annotation.SubLocality;
        self.PointOfInterest.fullthoroughfare = annotation.FullThoroughFare;
        self.PointOfInterest.postcode = annotation.PostCode;
        self.PointOfInterest.subadministrativearea = annotation.SubAdministrativeArea;
    } else {
        AnnotationMK *annotation = (AnnotationMK *)[view annotation];
        self.PointOfInterest.name = annotation.title;
        self.PointOfInterest.administrativearea = annotation.subtitle;
        self.PointOfInterest.lat = [NSNumber numberWithDouble:annotation.coordinate.latitude];
        self.PointOfInterest.lon = [NSNumber numberWithDouble:annotation.coordinate.longitude];
        self.Coordinates = annotation.coordinate;
    }
    
}

/*
 created date:      27/04/2018
 last modified:     09/05/2018
 remarks:
 */
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    //AnnotationMK *annotation = (AnnotationMK *)[view annotation];
    
    self.PointOfInterest.name = @"";
    self.PointOfInterest.administrativearea = @"";
    self.PointOfInterest.subadministrativearea = @"";
    self.PointOfInterest.locality = @"";
    self.PointOfInterest.sublocality = @"";
    self.PointOfInterest.postcode = @"";
    self.PointOfInterest.country = @"";
    self.PointOfInterest.countrycode = @"";
    self.PointOfInterest.fullthoroughfare = @"";
    self.Coordinates = kCLLocationCoordinate2DInvalid;
    self.PointOfInterest.lat = [NSNumber numberWithDouble:0];
    self.PointOfInterest.lon = [NSNumber numberWithDouble:0];
}

/*
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:
 */
- (IBAction)ClearAnnotationsOnMapPressed:(id)sender {
    [self.MapView removeAnnotations:self.MapView.annotations];
}

/*
 created date:      27/04/2018
 last modified:     28/04/2018
 remarks:           trigger segue controls without map data
 */
- (IBAction)SkipMapDataPressed:(id)sender {

    [self performSegueWithIdentifier:@"ShowPoiWithoutMapData" sender:self];
}

/*
 created date:      27/04/2018
 last modified:     28/04/2018
 remarks:           trigger segue controls with map data if valid
 */
- (IBAction)UseMapDataPressed:(id)sender {
    
    
    
    bool coordinatesAreValid = (CLLocationCoordinate2DIsValid(self.Coordinates));
                                
    if (coordinatesAreValid) {
        [self performSegueWithIdentifier:@"ShowPoiWithMapData" sender:self];

    } else {
        
        NSLog(@"Nothing doing!");
    }
}

/*
 created date:      27/04/2018
 last modified:     27/04/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

/*
 created date:      28/04/2018
 last modified:     10/08/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"ShowPoiWithMapData"]){
        PoiDataEntryVC *controller = (PoiDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.realm = self.realm;
        controller.PointOfInterest = self.PointOfInterest;
        controller.newitem = true;
        controller.PointOfInterest.wikititle = @"";
        controller.readonlyitem = false;
        controller.fromproject = self.fromproject;
        if (self.fromproject) {
            controller.TripItem = self.TripItem;
            controller.ActivityItem = self.ActivityItem;
        }
        controller.fromnearby = false;
    } else if([segue.identifier isEqualToString:@"ShowPoiWithoutMapData"]){
        PoiDataEntryVC *controller = (PoiDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.realm = self.realm;
        controller.PointOfInterest = self.PointOfInterest;
        controller.Coordinates = self.Coordinates;
        controller.PointOfInterest.privatenotes = @"No GeoData has been supplied except coordinates. Please press 'Geo' button when internet connectivity is next available!";
        controller.newitem = true;
        controller.readonlyitem = false;
        controller.fromproject = self.fromproject;
        controller.fromnearby = false;
    }
}

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
 created date:      11/06/2018
 last modified:     12/08/2018
 remarks:
 */
- (void)didCreatePoiFromProject :(PoiRLM*)Object {
    [self.delegate didCreatePoiFromProjectPassThru:Object];
    [self.delegate didUpdatePoi :@"created" :Object];
    [self dismissViewControllerAnimated:YES completion:Nil];
}
/*
 created date:      1/06/2018
 last modified:     11/06/2018
 remarks: Leave empty
 */
- (void)didCreatePoiFromProjectPassThru :(PoiRLM*)Object {
    
}

/*
 created date:      15/07/2018
 last modified:     12/08/2018
 remarks:
 */
- (void)didUpdatePoi :(NSString*)Method :(PoiRLM*)Object {
    [self.delegate didUpdatePoi:Method :Object];
}

/*
 created date:      03/02/2019
 last modified:     03/02/2019
 remarks:
 */
- (IBAction)SegmentMapTypeChanged:(id)sender {
    
    switch ([self.SegmentMapType selectedSegmentIndex])
    {
        case 0:
            self.MapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.MapView.mapType = MKMapTypeSatellite ;
            break;
        case 2:
            self.MapView.mapType = MKMapTypeHybrid;
            
            break;
        case 3:
            self.MapView.mapType = MKMapTypeMutedStandard;
            break;
        default:
            break;
            
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

    NSArray *keypaths  = [[NSArray alloc] initWithObjects:@"poikey", nil];
    RLMResults <ActivityRLM*> *activities = [[ActivityRLM objectsWhere:@"tripkey = %@",self.TripItem.key] distinctResultsUsingKeyPaths:keypaths];
    
    if (activities.count>0) {

       
        
        for (ActivityRLM *activity in activities) {
            double Lat = [activity.poi.lat doubleValue];
            double Lon = [activity.poi.lon doubleValue];
            //NSLog(@"%@", activity.poi.name);
            minLatitude = fmin(Lat, minLatitude);
            maxLatitude = fmax(Lat, maxLatitude);
            minLongitude = fmin(Lon, minLongitude);
            maxLongitude = fmax(Lon, maxLongitude);
        }

        [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
    } else {
        self.firstactivityinproject = true;
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


@end
