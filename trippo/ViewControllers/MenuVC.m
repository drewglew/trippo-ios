//
//  MenuVC.m
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "MenuVC.h"

@interface MenuVC () <PoiSearchDelegate, ProjectListDelegate>
@property RLMNotificationToken *notification;
@end

@implementation MenuVC
int Adjustment;
bool FirstLoad;

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

/*
 created date:      27/04/2018
 last modified:     19/02/2019
 remarks:           Simple delete action that initially can be triggered by user on a button.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.FeaturedPoiMap.delegate = self;
    self.ImageViewFeaturedPoi.layer.borderWidth = 1;
    self.ImageViewFeaturedPoi.layer.borderColor = [UIColor whiteColor].CGColor;
    
    FirstLoad = true;
    self.TripImageDictionary = [[NSMutableDictionary alloc] init];
    self.selectedtripitems = [[NSMutableArray alloc] init];
    [self LocateTripContent];
    
    [self.CollectionViewPreviewPanel reloadData];
    
    
    self.LabelFeaturedPoi.text = @"In focus...";

    __weak typeof(self) weakSelf = self;

    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf LocateTripContent];
        [weakSelf.CollectionViewPreviewPanel reloadData];
    }];
}

/*
 created date:      18/08/2018
 last modified:     13/09/2019
 remarks:
 */
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.ActivityView stopAnimating];
    [self LoadFeaturedPoi];
    
    self.alltripitems = [TripRLM allObjects];

    FirstLoad = false;
    
    RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
    NSLog(@"%@", settings);
    
    if (settings.count==0) {
        
       //self.CollectionViewPreviewPanel.enabled = false;
        self.ButtonFeaturedPoi.enabled = false;
        self.ButtonAllTrips.enabled = false;
        self.ButtonProject.enabled = false;
        self.ButtonPoi.enabled = false;
        
        self.ViewRegisterWarning.hidden = false;
        CABasicAnimation *animation =
        [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.05];
        [animation setRepeatCount:5];
        [animation setAutoreverses:YES];
        [animation setFromValue:[NSValue valueWithCGPoint:
                                 CGPointMake([self.ViewRegisterWarning center].x - 20.0f, [self.ViewRegisterWarning center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                               CGPointMake([self.ViewRegisterWarning center].x + 20.0f, [self.ViewRegisterWarning center].y)]];
        [[self.ViewRegisterWarning layer] addAnimation:animation forKey:@"position"];
        self.Settings = nil;
    } else {
        self.Settings = settings[0];
        
       // self.CollectionViewPreviewPanel.enabled = true;
        self.ButtonFeaturedPoi.enabled = true;
        self.ButtonAllTrips.enabled = true;
        self.ButtonProject.enabled = true;
        self.ButtonPoi.enabled = true;
        
        self.ViewRegisterWarning.hidden = true;
    }
    
}







/*
 created date:      15/08/2018
 last modified:     23/04/2019
 remarks:
 */
-(void)LocateTripContent {
    // 1=past/last; 2=now; 3=new (optional); 4=future/next; 5=new (optional)
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    
    self.alltripitems = [TripRLM allObjects];
  
    self.selectedtripitems = [[NSMutableArray alloc] init];

    NSDate* currentDate = [NSDate date];

    /* last trip 0/1 */
    TripRLM* lasttrip = [[TripRLM alloc] init];

    RLMSortDescriptor *sort = [RLMSortDescriptor sortDescriptorWithKeyPath:@"enddt" ascending:YES];
    [self.alltripitems sortedResultsUsingDescriptors:[NSArray arrayWithObject:sort]];

    NSDate* tripdt = nil;
    for (TripRLM* trip in self.alltripitems) {
        RLMResults <ActivityRLM*> *allActivities = [ActivityRLM objectsWhere:@"tripkey=%@", trip.key];
        NSDate *LastestDate = [allActivities maxOfProperty:@"enddt"];
        // past item
        //NSLog(@"trip enddt=%@",LastestDate);
        if([currentDate compare: LastestDate] == NSOrderedDescending ) {
            if (tripdt == nil) {
                tripdt = LastestDate;
                lasttrip.itemgrouping = [NSNumber numberWithInt:1];
                lasttrip.key = trip.key;
                lasttrip.name = trip.name;
                lasttrip.startdt = trip.startdt;
                lasttrip.enddt = trip.enddt;
            } else if ([tripdt compare: LastestDate] == NSOrderedAscending) {
                lasttrip.key = trip.key;
                lasttrip.name = trip.name;
                lasttrip.startdt = trip.startdt;
                lasttrip.enddt = trip.enddt;
                lasttrip.itemgrouping = [NSNumber numberWithInt:1];
                tripdt = trip.enddt;
            }
        }
    }
    
    if (lasttrip.itemgrouping==[NSNumber numberWithInt:1]) {
        TripRLM *trip = [TripRLM objectForPrimaryKey:lasttrip.key];
        [self RetrieveImageItem :trip :imagesDirectory];
        [self.selectedtripitems addObject:lasttrip];
    }

    /* active trip 0/1:M */
    bool found_active = false;
    for (TripRLM* trip in self.alltripitems) {
        RLMResults <ActivityRLM*> *allActivities = [ActivityRLM objectsWhere:@"tripkey=%@", trip.key];
        NSDate *EarliestDate = [allActivities maxOfProperty:@"startdt"];
        NSDate *LatestDate = [allActivities maxOfProperty:@"enddt"];

        if ([currentDate compare: EarliestDate] == NSOrderedDescending && [currentDate compare: LatestDate] == NSOrderedAscending) {
            
            TripRLM* tripobject = [[TripRLM alloc] init];
            tripobject.key = trip.key;
            tripobject.name = trip.name;
            tripobject.startdt = trip.startdt;
            tripobject.enddt = trip.enddt;
            tripobject.itemgrouping = [NSNumber numberWithInt:2];
            
            [self.selectedtripitems addObject:tripobject];
            found_active = true;
            [self RetrieveImageItem :trip :imagesDirectory];
        }

    }
   
    /* optional new if no active trip found */
    if (!found_active) {
        TripRLM* emptytrip = [[TripRLM alloc] init];
        emptytrip.key = [[NSUUID UUID] UUIDString];
        emptytrip.itemgrouping = [NSNumber numberWithInt:3];
        emptytrip.name = @"";
        [self.selectedtripitems addObject:emptytrip];
        [self.TripImageDictionary setObject:[UIImage imageNamed:@"Project"] forKey:emptytrip.key];
    }
    
    sort = [RLMSortDescriptor sortDescriptorWithKeyPath:@"startdt" ascending:NO];
    [self.alltripitems sortedResultsUsingDescriptors:[NSArray arrayWithObject:sort]];

    /* next trip 0/1 */
    tripdt = nil;
    TripRLM* nexttrip = [[TripRLM alloc] init];

    for (TripRLM* trip in self.alltripitems) {
        // nexttrip item
        RLMResults <ActivityRLM*> *allActivities = [ActivityRLM objectsWhere:@"tripkey=%@", trip.key];
        NSDate *EarliestDate = [allActivities maxOfProperty:@"startdt"];

        if([currentDate compare: EarliestDate] == NSOrderedAscending ) {
            if (tripdt==nil) {
                tripdt = EarliestDate;
                nexttrip = [[TripRLM alloc] initWithValue:trip];
                nexttrip.itemgrouping = [NSNumber numberWithInt:4];
                nexttrip.key = trip.key;
                nexttrip.name = trip.name;
            } else if ([tripdt compare: EarliestDate] == NSOrderedDescending) {
                nexttrip = [[TripRLM alloc] initWithValue:trip];
                nexttrip.itemgrouping = [NSNumber numberWithInt:4];
                tripdt = trip.startdt;
                nexttrip.key = trip.key;
                nexttrip.name = trip.name;
            }
        }
    }

    if (nexttrip.itemgrouping == [NSNumber numberWithInt:4]) {
        TripRLM *trip = [TripRLM objectForPrimaryKey:nexttrip.key];
        [self RetrieveImageItem :trip :imagesDirectory];
        [self.selectedtripitems addObject:nexttrip];
    }
    
     /* optional new if active trip found */
    if (found_active) {
        TripRLM* emptytrip = [[TripRLM alloc] init];
        emptytrip.key = [[NSUUID UUID] UUIDString];
        emptytrip.itemgrouping = [NSNumber numberWithInt:5];;
        emptytrip.name = @"";
        [self.TripImageDictionary setObject:[UIImage imageNamed:@"Project"] forKey:emptytrip.key];
        [self.selectedtripitems addObject:emptytrip];
    }
    
}

/*
 created date:      02/09/2018
 last modified:     02/09/2018
 remarks:
 */
-(void) RetrieveImageItem :(TripRLM*) trip :(NSString*) imagesDirectory {
    if (trip.images.count==1) {
        ImageCollectionRLM *imgobject = [trip.images firstObject];
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imgobject.ImageFileReference]];
        NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
        if (pngData==nil) {
            [self.TripImageDictionary setObject:[UIImage imageNamed:@"Project"] forKey:trip.key];
        } else {
            [self.TripImageDictionary setObject:[UIImage imageWithData:pngData] forKey:trip.key];
        }
    } else {
        [self.TripImageDictionary setObject:[UIImage imageNamed:@"Project"] forKey:trip.key];
    }
}



/*
 created date:      18/08/2018
 last modified:     28/02/2019
 remarks:
 */
-(void) LoadFeaturedPoi {
    
    NSArray *types = [NSArray arrayWithObjects: @2,@3,@7,@8,@9,@10,@12,@13,@15,@16,@17,@18,@19,@20,@21,@23,@24,@25,@26,@28,@30,@31,@33,@35,@36,nil];
    
    NSSet *typeset = [[NSSet alloc] initWithArray:types];
    
    RLMResults *poicollection = [[PoiRLM allObjects] objectsWithPredicate:[NSPredicate predicateWithFormat:@"categoryid IN %@",typeset]];
    
    if (poicollection.count==0) { return; }
    int featuredIndex = arc4random_uniform((int)poicollection.count);
    self.FeaturedPoi = [poicollection objectAtIndex:featuredIndex];
    
    self.LabelFeaturedPoi.text = [NSString stringWithFormat:@"In focus... %@", self.FeaturedPoi.name];
    
    NSURL *url = [self applicationDocumentsDirectory];
    
    NSData *pngData;
    
    if (self.FeaturedPoi.images.count > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
        RLMResults *filteredArray = [self.FeaturedPoi.images objectsWithPredicate:predicate];
        
        ImageCollectionRLM *keyimgobject;
        
        if (filteredArray.count==0) {
            keyimgobject = [self.FeaturedPoi.images firstObject];
        } else {
            keyimgobject = [filteredArray firstObject];
        }
        NSURL *imagefile = [url URLByAppendingPathComponent:keyimgobject.ImageFileReference];
        NSError *err;
        pngData = [NSData dataWithContentsOfURL:imagefile options:NSDataReadingMappedIfSafe error:&err];
        
        if (pngData==nil) {
            self.ImageViewFeaturedPoi.image = [UIImage imageNamed:@"Poi"];
        } else {
            [self.ImageViewFeaturedPoi setImage:[UIImage imageWithData:pngData]];
        }
        
    } else {
        self.ImageViewFeaturedPoi.image = [UIImage imageNamed:@"Poi"];
    }
    
    [self.FeaturedPoiMap removeAnnotations:self.FeaturedPoiMap.annotations];
    
    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
    anno.title = self.FeaturedPoi.name;
    anno.subtitle = [NSString stringWithFormat:@"%@", self.FeaturedPoi.administrativearea];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.FeaturedPoi.lat doubleValue], [self.FeaturedPoi.lon doubleValue]);
    
    anno.coordinate = coord;
    
    //NSNumber *radius = [self.TypeDistanceItems objectAtIndex:[self.Poi.categoryid unsignedLongValue]];
    
    [self.FeaturedPoiMap setCenterCoordinate:coord animated:YES];
    
    //MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, [radius doubleValue] * 2.2, [radius doubleValue] * 2.2);
    
    //MKCoordinateRegion adjustedRegion = [self.PoiMapView regionThatFits:viewRegion];
    //[self.PoiMapView setRegion:adjustedRegion animated:YES];
    [self.FeaturedPoiMap addAnnotation:anno];
    [self.FeaturedPoiMap selectAnnotation:anno animated:YES];
    
    
}

/*
created date:      18/08/2018
last modified:     25/08/2019
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
 last modified:     18/08/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if([segue.identifier isEqualToString:@"ShowPoiList"]){
        PoiSearchVC *controller = (PoiSearchVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.Project = nil;
        controller.Activity = nil;
        controller.realm = self.realm;
    } else if([segue.identifier isEqualToString:@"ShowProjectList"]){
        ProjectListVC *controller = (ProjectListVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.realm = self.realm;
    } else if ([segue.identifier isEqualToString:@"ShowFeaturedPoi"]){
        PoiDataEntryVC *controller= (PoiDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.PointOfInterest = self.FeaturedPoi;
        controller.readonlyitem = true;
        controller.realm = self.realm;
    } else if ([segue.identifier isEqualToString:@"ShowSettings"]){
        SettingsVC *controller= (SettingsVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.Settings = self.Settings;
        controller.realm = self.realm;
    }
}



/*
 created date:      14/08/2018
 last modified:     15/08/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedtripitems.count;
}


/*
 created date:      28/02/2019
 last modified:     28/02/2019
 remarks:
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetHeight(collectionView.frame) - 20, (CGRectGetHeight(collectionView.frame) - 20));
}

/*
 created date:      14/08/2018
 last modified:     03/09/2018
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ProjectListCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"projectCellId" forIndexPath:indexPath];
    TripRLM *trip = [self.selectedtripitems objectAtIndex:indexPath.row];
    cell.ImageViewProject.image = [self.TripImageDictionary objectForKey:trip.key];

    cell.LabelProjectName.text = trip.name;
    
    //cell.LabelProjectName.text = trip.name;
    
    NSString *reference = @"";
    //NSLog(@"itemgrouping=%@",trip.itemgrouping);
    
    if (trip.itemgrouping==[NSNumber numberWithInt:1]) {
        reference = @"Previous";
        
    } else if (trip.itemgrouping==[NSNumber numberWithInt:2]) {
        reference = @"Active";
    } else if (trip.itemgrouping==[NSNumber numberWithInt:4]) {
        reference = @"Next";
    } else {
        reference = @"New";
    }

    cell.LabelDateRange.text = reference;
    
    //TODO
    cell.ImageViewProject.layer.cornerRadius = ((self.MainSurface.bounds.size.height / 2) - 100) / 2;
    
    //cell.ImageViewProject.layer.cornerRadius = cell.ImageViewProject.bounds.size.height / 2;
    cell.ImageViewProject.layer.masksToBounds = true;
    
    return cell;
}


/*
 created date:      15/08/2018
 last modified:     13/08/2019
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.Settings != nil) {
        TripRLM *trip = [self.selectedtripitems objectAtIndex:indexPath.row];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

        if (trip.itemgrouping==[NSNumber numberWithInt:3] || trip.itemgrouping==[NSNumber numberWithInt:5]) {
            ProjectDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ProjectDataEntryViewController"];
            controller.delegate = self;
            controller.Trip = [[TripRLM alloc] init];
            controller.newitem = true;
            controller.realm = self.realm;
            [controller setModalPresentationStyle:UIModalPresentationFullScreen];
            [self presentViewController:controller animated:YES completion:nil];
        } else {
            ActivityListVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityListViewController"];
            controller.delegate = self;
            controller.realm = self.realm;
            
            controller.Trip = trip;
            NSLog(@"startdt = %@",controller.Trip.startdt);
            [controller setModalPresentationStyle:UIModalPresentationFullScreen];
            [self presentViewController:controller animated:YES completion:nil];
        }
    }
}



/*
 created date:      14/08/2018
 last modified:     31/08/2018
 remarks:           Scrolls to selected trip item.
 */
-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    NSIndexPath *indexPath;
    int index = 0;
    for (TripRLM *p in self.selectedtripitems) {
        if (p.itemgrouping==[NSNumber numberWithInt:2] || p.itemgrouping==[NSNumber numberWithInt:3]) {
            indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        } else if (p.itemgrouping==[NSNumber numberWithInt:4] && indexPath==nil) {
            indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        }
        index++;
    }
    if (indexPath!=nil) {
        [self.CollectionViewPreviewPanel scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
    
}

- (IBAction)ButtonFeaturedPoiPressed:(id)sender {
    
    
}

/*
 created date:      18/08/2018
 last modified:     18/08/2018
 remarks:           Opens up the POI search list view.  Activity view needs NSRunLoop command to get time to present it.
 */
- (IBAction)ButtonShowPoiListPressed:(id)sender {

    
    //self.FeaturedViewTrailingConstraint.constant = self.FeaturedViewTrailingConstraint.constant - Adjustment;
    
    [self.ActivityView startAnimating];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    PoiSearchVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"PoiListingViewController"];
    controller.delegate = self;
    controller.Project = nil;
    controller.Activity = nil;
    controller.realm = self.realm;
    
    [controller setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:controller animated:YES completion:nil];
    
    [self.ActivityView stopAnimating];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didCreatePoiFromProject:(PoiNSO *)Object {
    
}

- (void)didUpdatePoi:(NSString *)Method :(PoiNSO *)Object {
    
}

/*
 created date:      09/09/2018
 last modified:     09/09/2018
 remarks:
 */
- (void)didUpdateActivityImages :(bool) ForceUpdate {

}

/* optimize - if returning from projects/trips we need to update, not after every update */

- (IBAction)SwitchImageEnabler:(id)sender {
}
@end
