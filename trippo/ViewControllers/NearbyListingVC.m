//
//  NearbyListingVC.m
//  travelme
//
//  Created by andrew glew on 16/07/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "NearbyListingVC.h"

@interface NearbyListingVC ()

@end

@implementation NearbyListingVC
CGFloat lastNearbyListingFooterFilterHeightConstant;
bool runOnce = true;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (![ToolBoxNSO HasTopNotch]) {
        self.HeaderHeightConstraint.constant = 70.0f;
    }
    lastNearbyListingFooterFilterHeightConstant = self.FooterWithSegmentConstraint.constant;
    //UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 50)];

    //self.TableViewNearbyPoi.tableHeaderView = headerView;
    
    if ([self checkInternet]) {
        if (self.PointOfInterest==nil) {
            NSLog(@"Get Location");
            [self startUserLocationSearch];
        } else {
            
            self.LabelNearby.text = [NSString stringWithFormat:@"Nearby %@",self.PointOfInterest.name];
            
            [self LoadNearbyPoiItemsData];
        }
    }
    else
        NSLog(@"Device is not connected to the Internet");
    
    self.TableViewNearbyPoi.delegate = self;
    self.TableViewNearbyPoi.rowHeight = 100;
    
    self.ViewLoading.layer.cornerRadius=8.0f;
    self.ViewLoading.layer.masksToBounds=YES;
    self.ViewLoading.layer.borderWidth = 1.0f;
    self.ViewLoading.layer.borderColor=[[UIColor colorNamed:@"TrippoColor"]CGColor];
    self.SegmentFilterType.selectedSegmentTintColor = [UIColor colorNamed:@"TrippoColor"];
    [self.SegmentFilterType setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor systemBackgroundColor], NSFontAttributeName: [UIFont systemFontOfSize:13]} forState:UIControlStateSelected];
    self.SegmentImageEnabler.selectedSegmentTintColor = [UIColor colorNamed:@"TrippoColor"];
    [self.SegmentImageEnabler setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor systemBackgroundColor], NSFontAttributeName: [UIFont systemFontOfSize:13]} forState:UIControlStateSelected];
    self.SegmentWikiLanguageOption.selectedSegmentTintColor = [UIColor colorNamed:@"TrippoColor"];
    [self.SegmentWikiLanguageOption setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor systemBackgroundColor], NSFontAttributeName: [UIFont systemFontOfSize:13]} forState:UIControlStateSelected];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.TableViewNearbyPoi.allowsSelection = YES;
}

/*
 created date:      17/07/2018
 last modified:     17/07/2018
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
 created date:      17/07/2018
 last modified:     17/07/2018
 remarks:
 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    [self.locationManager stopUpdatingLocation];
    
    self.PointOfInterest = [[PoiRLM alloc] init];

    self.PointOfInterest.lat = [NSNumber numberWithDouble: self.locationManager.location.coordinate.latitude];
    self.PointOfInterest.lon = [NSNumber numberWithDouble: self.locationManager.location.coordinate.longitude];
    
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];

    [geoCoder reverseGeocodeLocation: [[CLLocation alloc] initWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
  
        if (error) {
            NSLog(@"%@", [NSString stringWithFormat:@"%@", error.localizedDescription]);
        } else {
            if ([placemarks count]>0) {
                CLPlacemark *placemark = [placemarks firstObject];
                self.PointOfInterest.countrycode = placemark.ISOcountryCode;
            }
            
            [self LoadNearbyPoiItemsData];
            
        }
    }];

}


/*
 created date:      16/07/2018
 last modified:     11/09/2019
 remarks:  calls the wiki API and gets Array of results
 */
-(void) LoadNearbyPoiItemsData {
    
    if (runOnce || self.PointOfInterest!=nil) {
        runOnce = false;
 
        self.nearbyitems = [[NSMutableArray alloc] init];
        self.ViewLoading.hidden = false;
        [self.LoadingActivityIndictor startAnimating];
        
        NSString *PreferredLanguage;
        if (self.SegmentWikiLanguageOption.selectedSegmentIndex == 0) {
            PreferredLanguage = [AppDelegateDef.CountryDictionary objectForKey:AppDelegateDef.HomeCountryCode];
        } else if (self.SegmentWikiLanguageOption.selectedSegmentIndex == 1) {
            PreferredLanguage = [AppDelegateDef.CountryDictionary objectForKey:self.PointOfInterest.countrycode];
        } else {
            PreferredLanguage = @"en";
        }
      
        /*
         Obtain Wiki records based on coordinates & local language.  (radius is in meters, we should use same range as type used to search photos)
         https://en.wikipedia.org/w/api.php?action=query&list=geosearch&gsradius=1000&gscoord=52.5208626606277|13.4094035625458&format=json
         
         Or search by name with redirect.
         https://en.wikipedia.org/w/api.php?action=query&titles=Göteborg&redirects&format=jsonfm&formatversion=2
         */
        
        NSString *url = [NSString stringWithFormat:@"https://%@.wikipedia.org/w/api.php?action=query&list=geosearch&gsprop=type|name|dim|country|region|globe&gsradius=10000&gscoord=%@|%@&format=json&redirects&gslimit=120",PreferredLanguage ,self.PointOfInterest.lat, self.PointOfInterest.lon];
        
        bool GetImages = false;
        
        if ([self.SegmentImageEnabler selectedSegmentIndex] == 1) {
            GetImages = true;
        }
        
        bool FilterItems = false;
        
        if ([self.SegmentFilterType selectedSegmentIndex] == 0) {
            FilterItems = true;
        }
        
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [self fetchFromWikiApi:url withDictionary:^(NSDictionary *data) {
            
            NSDictionary *query = [data objectForKey:@"query"];
            NSDictionary *geosearch =  [query objectForKey:@"geosearch"];
            
            NSArray *AllowedTypes = [[NSArray alloc] initWithObjects:@"landmark",@"building",@"isle",@"city",@"railwaystation",@"edu",@"river",@"airport",@"mountain",@"forest"@"waterbody",@"glacier",@"pass",nil];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@ AND SELF != nil", AllowedTypes];
              
              
            /* we can process all later, but am only interested in the closest wiki entry */
            for (NSDictionary *item in geosearch) {
                /*
                 let us try and get the images if the switch user has set allows us!
                 */
                bool typefound = true;
                
                if (FilterItems) {
                    typefound = [predicate evaluateWithObject:[item valueForKey:@"type"]];
                }
                
                if (typefound) {
                    NearbyPoiNSO *poi = [[NearbyPoiNSO alloc] init];
                    
                    poi.wikititle = [NSString stringWithFormat:@"%@~%@",PreferredLanguage,[[item valueForKey:@"title"] stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
                    poi.title = [item valueForKey:@"title"];
                    poi.dist = [item valueForKey:@"dist"];
                    
                    if ([item objectForKey:@"type"] != [NSNull null]) {
                        poi.type = [item valueForKey:@"type"];
                    }
                    poi.Coordinates = CLLocationCoordinate2DMake([[item valueForKey:@"lat"] doubleValue], [[item valueForKey:@"lon"] doubleValue]);
                    poi.PageId = [item valueForKey:@"pageid"];
//boo
                    [self.nearbyitems addObject:poi];
                }
            }
            
            if (GetImages && self.nearbyitems.count > 0) {
                [self uploadWikiThumbImage :PreferredLanguage];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    self.LabelTotalItems.text = [NSString stringWithFormat:@"%lu items", (unsigned long)self.nearbyitems.count];
                    [self.TableViewNearbyPoi reloadData];
                    [self.TableViewNearbyPoi setNeedsDisplay];
                    //[self.TableViewNearbyPoi setNeedsLayout];
                    self.ViewLoading.hidden = true;
                    [self.LoadingActivityIndictor stopAnimating];
                });
            }
        }];
    }
}



/*
 created date:      01/02/2019
 last modified:     01/02/2019
 remarks:
 */
- (void)uploadWikiThumbImage :(NSString*) PreferredLanguage {
    NSLog(@"switch is enabled!");

    __block int AssetCounter = 0;
   
    for (NearbyPoiNSO *item in self.nearbyitems) {
        
        NSString *urlString = [NSString stringWithFormat:@"https://%@.wikipedia.org/w/api.php?action=query&format=json&formatversion=2&prop=pageimages|pageterms&piprop=thumbnail&pithumbsize=600&pageids=%@",PreferredLanguage ,item.PageId];
        
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        [self fetchFromWikiApi:urlString withDictionary:^(NSDictionary *data) {
            
            NSDictionary *query = [data objectForKey:@"query"];
            NSArray *pages = [query objectForKey:@"pages"];
            NSDictionary *dataset = [pages lastObject];
            
            if ([dataset objectForKey:@"thumbnail"]) {
                NSDictionary *thumbnail = [dataset objectForKey:@"thumbnail"];
                NSString *source = [thumbnail objectForKey:@"source"];
                NSURL *url = [NSURL URLWithString: source];
                
                [self downloadImageFrom:url completion:^(UIImage *image) {
                    AssetCounter ++;
                    if (image != nil) {
                        
                        if (image.size.height > image.size.width) {
                            CGRect aRect = CGRectMake(0,(image.size.height / 2) - (image.size.width / 2), image.size.width, image.size.width);
                            CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], aRect);
                            image = [UIImage imageWithCGImage:imageRef];
                            CGImageRelease(imageRef);
                        } else if (image.size.height < image.size.width) {
                            CGRect aRect = CGRectMake((image.size.width / 2) - (image.size.height / 2), 0, image.size.height, image.size.height);
                            CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], aRect);
                            image = [UIImage imageWithCGImage:imageRef];
                            CGImageRelease(imageRef);
                        }
                        
                        item.Image = image;
                    }
                    if (item == [self.nearbyitems lastObject]) {
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            
                                self.LabelTotalItems.text = [NSString stringWithFormat:@"%lu items", (unsigned long)self.nearbyitems.count];
                                [self.TableViewNearbyPoi reloadData];
                                [self.TableViewNearbyPoi setNeedsDisplay];
                                //[self.TableViewNearbyPoi setNeedsLayout];
                                self.ViewLoading.hidden = true;
                                [self.LoadingActivityIndictor stopAnimating];
                            
                        });
                    }
                }];
            } else {
                if (item == [self.nearbyitems lastObject]) {
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        
                        self.LabelTotalItems.text = [NSString stringWithFormat:@"%lu items", (unsigned long)self.nearbyitems.count];
                        [self.TableViewNearbyPoi reloadData];
                        [self.TableViewNearbyPoi setNeedsDisplay];
                        //[self.TableViewNearbyPoi setNeedsLayout];
                        self.ViewLoading.hidden = true;
                        [self.LoadingActivityIndictor stopAnimating];
                        
                    });
                }
            }
        }];
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
 created date:      16/07/2018
 last modified:     16/07/2018
 remarks:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*
 created date:      16/07/2018
 last modified:     16/07/2018
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.nearbyitems.count;
}



/*
 created date:      16/07/2018
 last modified:     08/09/2019
 remarks:           table view with sections.  TODO - REFRESH OF IMAGES STILL NOT IDEAL.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NearbyPoiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NearbyCellId"];
    NearbyPoiNSO *item = [self.nearbyitems objectAtIndex:indexPath.row];
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.##"];

    NSMeasurementFormatter *formatter = [[NSMeasurementFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    
    
    
    NSMeasurement *distance = [[NSMeasurement alloc] initWithDoubleValue:[item.dist doubleValue] unit:NSUnitLength.meters];

    cell.LabelDist.text = [NSString stringWithFormat:@"%@",[formatter stringFromMeasurement:distance]];
    
    cell.LabelTitle.text = item.title;
    cell.LabelType.text = item.type;
    
    if (item.Image == nil) {
        [cell.ImageViewThumbPhoto setImage:[UIImage systemImageNamed:@"target"]];
        [cell.ImageViewThumbPhoto setTintColor:[UIColor systemBackgroundColor]];
    } else {
        [cell.ImageViewThumbPhoto setImage:[ToolBoxNSO imageWithImage:item.Image scaledToSize:cell.ImageViewThumbPhoto.frame.size]];
    }
    return cell;
}



/*
 created date:      16/07/2018
 last modified:     20/03/2019
 remarks:
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if ([self checkInternet]) {
        
        tableView.allowsSelection = NO;
        
        static NSString *IDENTIFIER = @"NearbyCellId";
        
        NearbyPoiCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
        if (cell == nil) {
            cell = [[NearbyPoiCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
        }
        
        NearbyPoiNSO *Nearby = [self.nearbyitems objectAtIndex:indexPath.row];
        
        self.PointOfInterest = [[PoiRLM alloc] init];
        self.PointOfInterest.key = [[NSUUID UUID] UUIDString];
        self.PointOfInterest.lat = [NSNumber numberWithDouble:Nearby.Coordinates.latitude];
        self.PointOfInterest.lon = [NSNumber numberWithDouble:Nearby.Coordinates.longitude];
        self.PointOfInterest.wikititle = Nearby.wikititle;
        
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        
        self.ViewLoading.hidden = false;
        [self.LoadingActivityIndictor startAnimating];
        
        [geoCoder reverseGeocodeLocation: [[CLLocation alloc] initWithLatitude:Nearby.Coordinates.latitude longitude:Nearby.Coordinates.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"%@", [NSString stringWithFormat:@"%@", error.localizedDescription]);
            } else {
                if ([placemarks count]>0) {
                    CLPlacemark *placemark = [placemarks firstObject];
                    
                    NSString *AdminArea = placemark.subAdministrativeArea;
                    if ([AdminArea isEqualToString:@""] || AdminArea == NULL) {
                        AdminArea = placemark.administrativeArea;
                    }
                    self.PointOfInterest.administrativearea = [NSString stringWithFormat:@"%@, %@", AdminArea,placemark.ISOcountryCode];
                    self.PointOfInterest.country = placemark.country;
                    self.PointOfInterest.sublocality = placemark.subLocality;
                    self.PointOfInterest.locality = placemark.locality;
                    self.PointOfInterest.postcode = placemark.postalCode;
                    self.PointOfInterest.countrycode = placemark.ISOcountryCode;
                    self.PointOfInterest.fullthoroughfare = [NSString stringWithFormat:@"%@, %@", placemark.thoroughfare, placemark.subThoroughfare];
                    
                }
                self.PointOfInterest.name = Nearby.title;

                /*
                 Obtain Wiki records based on coordinates & local language.  (radius is in meters, we should use same range as type used to search photos)
                 https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=Chichester
                */
                
                NSArray *parms = [self.PointOfInterest.wikititle componentsSeparatedByString:@"~"];

                NSString *url = [NSString stringWithFormat:@"https://%@.wikipedia.org/w/api.php?action=query&format=json&formatversion=2&prop=description|extracts|pageimages|pageterms&exintro=&explaintext=&piprop=original|thumbnail&titles=%@",[parms objectAtIndex:0],[parms objectAtIndex:1]];
                
                url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

                /* get data */
                [self fetchFromWikiApi:url withDictionary:^(NSDictionary *data) {
                    
                    NSDictionary *query = [data objectForKey:@"query"];
                    NSArray *pages =  [query objectForKey:@"pages"];
                    NSDictionary *item =  [pages firstObject];
                    self.PointOfInterest.privatenotes = [item objectForKey:@"extract"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        
                        if ([self.SegmentImageEnabler selectedSegmentIndex] == 1) {
                            
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
                                    self.ViewLoading.hidden = true;
                                    [self.LoadingActivityIndictor stopAnimating];
                                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                    PoiDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"PoiDataEntryId"];
                                    
                                    controller.delegate = self;
                                    controller.PointOfInterest = self.PointOfInterest;
                                    controller.realm = self.realm;
                                    controller.newitem = true;
                                    controller.readonlyitem = false;
                                    controller.fromproject = self.fromproject;
                                    controller.TripItem = self.TripItem;
                                     
                                    controller.ActivityItem = self.ActivityItem;
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
                            self.ViewLoading.hidden = true;
                            [self.LoadingActivityIndictor stopAnimating];
                            
                            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                            
                            PoiDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"PoiDataEntryId"];
                            
                            controller.delegate = self;
                            controller.PointOfInterest = self.PointOfInterest;
                            controller.realm = self.realm;
                            controller.newitem = true;
                            controller.readonlyitem = false;
                            controller.fromproject = self.fromproject;
                            controller.TripItem = self.TripItem;
                            controller.ActivityItem = self.ActivityItem;
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

/*
 created date:      05/02/2019
 last modified:     23/03/2019
 remarks:
 */
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if (velocity.y > 0 && self.FooterWithSegmentConstraint.constant == lastNearbyListingFooterFilterHeightConstant){
        NSLog(@"scrolling down");
        
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.FooterWithSegmentConstraint.constant = 0.0f;
                             
                             UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0)];
                             self.TableViewNearbyPoi.tableFooterView = footerView;
                             
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    if (velocity.y < 0  && self.FooterWithSegmentConstraint.constant == 0.0f){
        NSLog(@"scrolling up");
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             self.FooterWithSegmentConstraint.constant = lastNearbyListingFooterFilterHeightConstant;

                             UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.FooterWithSegmentConstraint.constant)];
                             self.TableViewNearbyPoi.tableFooterView = footerView;
                             
                             [self.view layoutIfNeeded];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 created date:      16/07/2018
 last modified:     12/08/2018
 remarks:
 */
- (void)didUpdatePoi :(NSString*)Method :(PoiRLM*)Object {
    self.UpdatedPoi = true;
}

- (void)didCreatePoiFromProject:(PoiRLM *)Object {

}



/*
 created date:      17/07/2018
 last modified:     17/07/2018
 remarks:
 */
- (IBAction)SegmentLanguageChanged:(id)sender {
    
    if ([self checkInternet]) {
        [self LoadNearbyPoiItemsData];
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
 created date:      05/02/2019
 last modified:     05/02/2019
 remarks:
 */
- (IBAction)SegmentImageEnablerChanged:(id)sender {
    
    if ([self.SegmentImageEnabler selectedSegmentIndex] == 1) {
        
        NSString *PreferredLanguage;
        if (self.SegmentWikiLanguageOption.selectedSegmentIndex == 0) {
            PreferredLanguage = [AppDelegateDef.CountryDictionary objectForKey:AppDelegateDef.HomeCountryCode];
        } else if (self.SegmentWikiLanguageOption.selectedSegmentIndex == 1) {
            PreferredLanguage = [AppDelegateDef.CountryDictionary objectForKey:self.PointOfInterest.countrycode];
        } else {
            PreferredLanguage = @"en";
        }

        self.ViewLoading.hidden = false;
        [self.LoadingActivityIndictor startAnimating];
        [self uploadWikiThumbImage :PreferredLanguage];
        
    }
}

/*
 created date:      05/02/2019
 last modified:     05/02/2019
 remarks:
 */
- (IBAction)SegmentFilterTypeChanged:(id)sender {
    [self LoadNearbyPoiItemsData];
}

/*
 created date:      23/03/2019
 last modified:     23/03/2019
 remarks:
 */
- (IBAction)ButtonPaneResizePressed:(id)sender {
    
    [self.view layoutIfNeeded];
    if (self.FooterWithSegmentConstraint.constant==98) {
        [UIView animateWithDuration:0.25f animations:^{
            self.FooterWithSegmentConstraint.constant=350;
            [self.ButtonPaneResize setImage:[UIImage systemImageNamed:@"arrow.down.forward.and.arrow.up.backward"] forState:UIControlStateNormal];
            [self.ButtonPaneResize setTitle:@"Hide" forState:UIControlStateNormal];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.FooterWithSegmentConstraint.constant)];
            self.TableViewNearbyPoi.tableFooterView = footerView;
            [self.TableViewNearbyPoi reloadData];
        }];
        
    } else {
        [UIView animateWithDuration:0.25f animations:^{
            self.FooterWithSegmentConstraint.constant=98;
            [self.ButtonPaneResize setImage:[UIImage systemImageNamed:@"arrow.up.backward.and.arrow.down.forward"] forState:UIControlStateNormal];
            [self.ButtonPaneResize setTitle:@"Expand" forState:UIControlStateNormal];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.FooterWithSegmentConstraint.constant)];
            self.TableViewNearbyPoi.tableFooterView = footerView;
            [self.TableViewNearbyPoi reloadData];
        }];
        
    }
    lastNearbyListingFooterFilterHeightConstant = self.FooterWithSegmentConstraint.constant;

}






@end
