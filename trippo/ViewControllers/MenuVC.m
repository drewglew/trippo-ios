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
 last modified:     11/01/2020
 remarks:           Simple delete action that initially can be triggered by user on a button.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    //self.FeaturedPoiMap.delegate = self;
    //self.ImageViewFeaturedPoi.layer.borderWidth = 1;
    //self.ImageViewFeaturedPoi.layer.borderColor = [UIColor whiteColor].CGColor;
    
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

-(void)PresentAssistantView {
    /* new block 20200111 */
    if (self.AssistantView == nil || [self.AssistantView isHidden]) {
        self.AssistantView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 400)];
        
        self.AssistantView.backgroundColor = [UIColor labelColor];
                
        self.AssistantView.layer.cornerRadius=8.0f;
        self.AssistantView.layer.masksToBounds=YES;

        UILabel* title = [[UILabel alloc] init];
        title.frame = CGRectMake(10, 18,  self.AssistantView.bounds.size.width - 20, 24);
        title.textColor =  [UIColor secondarySystemBackgroundColor];
        title.font = [UIFont systemFontOfSize:22 weight:UIFontWeightThin];
        title.text = @"Introduction";
        title.textAlignment = NSTextAlignmentCenter;
        [self.AssistantView addSubview:title];
        
        UIImageView *logo = [[UIImageView alloc] init];
        logo.frame = CGRectMake(10, self.AssistantView.bounds.size.height - 50, 80, 40);
        logo.image = [UIImage imageNamed:@"Trippo"];
        [self.AssistantView  addSubview:logo];
        
        UILabel* helpText = [[UILabel alloc] init];
        helpText.frame = CGRectMake(10, 50,  self.AssistantView.bounds.size.width - 20, 300);
        helpText.textColor =  [UIColor secondarySystemBackgroundColor];
        helpText.adjustsFontSizeToFitWidth = YES;
        helpText.minimumScaleFactor = 0.5;
        helpText.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        helpText.numberOfLines = 0;
        helpText.text = @"Ciao, नमस्कार, Hallo, 你好, Hola, Здравствуйте, Welcome, Hej, Bonjour - I am your friendly travel assistant! I will appear the first time you experience each new view.  Inside Settings you can choose to see me again, if you missed details the first time round!\n\nBefore you can add content - you must goto 'Settings' to enter some basic details. Once this is added, returning to this menu you will be able to begin adding your own content such as your own Points of Interest as well as creating Trips.\n\nWhen trips exist - past, present or up and coming - they can be browsed here by swiping the circular trip items left or right.\n\nAll data is stored on your phone, no supporting backups are available in this first version.  As this is sensitive data it is important you know & trust where your data is.";
         
        helpText.textAlignment = NSTextAlignmentLeft;
        [self.AssistantView  addSubview:helpText];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(self.AssistantView.bounds.size.width - 40.0, 3.5, 35.0, 35.0); // x,y,width,height
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightRegular];
        [button setImage:[UIImage systemImageNamed:@"xmark.circle" withConfiguration:config] forState:UIControlStateNormal];
        [button setTintColor: [UIColor secondarySystemBackgroundColor]];
        [button addTarget:self action:@selector(helperViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.AssistantView addSubview:button];
        [self.view addSubview:self.AssistantView];
    }
}


/*
 created date:      18/08/2018
 last modified:     12/01/2020
 remarks:
 */
-(void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    self.ButtonFeaturedPoi.enabled = true;
    
    [self.ActivityView stopAnimating];
    [self LoadFeaturedPoi];
    
    self.alltripitems = [TripRLM allObjects];

    FirstLoad = false;
    
    RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
    
    if (settings.count==0) {
        
        [self PresentAssistantView];
        
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
        
        AssistantRLM *assist = [[self.Settings.AssistantCollection objectsWhere:@"ViewControllerName=%@",@"MenuVC"] firstObject];

        if ([assist.State integerValue] == 1) {
            [self PresentAssistantView];
        }

        
        self.ButtonAllTrips.enabled = true;
        self.ButtonProject.enabled = true;
        self.ButtonPoi.enabled = true;
        self.ViewRegisterWarning.hidden = true;
    }
    
}


/*
 created date:      11/01/2020
 last modified:     12/01/2020
 remarks:
 */
-(void)helperViewButtonPressed :(id)sender {
    [self.AssistantView setHidden:TRUE];
    AssistantRLM *assist = [[self.Settings.AssistantCollection objectsWhere:@"ViewControllerName=%@",@"MenuVC"] firstObject];
    NSLog(@"%@",assist);
    if ([assist.State integerValue] == 1) {
        [self.realm beginWriteTransaction];
        assist.State = [NSNumber numberWithInteger:0];
        [self.realm commitWriteTransaction];
    }
    [self.ActivityView setHidden:TRUE];
}

/*
 created date:      15/08/2018
 last modified:     10/01/2020
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

    NSPredicate *predicateExpired = [NSPredicate predicateWithFormat:@"enddt < %@", currentDate];
    RLMResults <TripRLM*> *expiredTrips = [self.alltripitems objectsWithPredicate:predicateExpired];
    
    RLMSortDescriptor *sort = [RLMSortDescriptor sortDescriptorWithKeyPath:@"enddt" ascending:YES];
    expiredTrips = [expiredTrips sortedResultsUsingDescriptors:[NSArray arrayWithObject:sort]];

    if (expiredTrips.count >0) {
        TripRLM* trip = [expiredTrips lastObject];
   
        lasttrip.itemgrouping = [NSNumber numberWithInt:1];
        lasttrip.key = trip.key;
        lasttrip.name = trip.name;
        lasttrip.defaulttimezonename = trip.defaulttimezonename;
        lasttrip.startdt = trip.startdt;
        lasttrip.enddt = trip.enddt;
    }
   
    if (lasttrip.itemgrouping==[NSNumber numberWithInt:1]) {
        TripRLM *trip = [TripRLM objectForPrimaryKey:lasttrip.key];
        [self RetrieveImageItem :trip :imagesDirectory];
        [self.selectedtripitems addObject:lasttrip];
    }

    NSPredicate *predicateActive = [NSPredicate predicateWithFormat:@"startdt <= %@ AND enddt >= %@", currentDate,currentDate];
    RLMResults <TripRLM*> *activeTrips = [self.alltripitems objectsWithPredicate:predicateActive];

    /* active trip 0/1:M */
    bool found_active = false;
    for (TripRLM* trip in activeTrips) {
        TripRLM* tripobject = [[TripRLM alloc] init];
        tripobject.key = trip.key;
        tripobject.name = trip.name;
        tripobject.defaulttimezonename = trip.defaulttimezonename;
        tripobject.startdt = trip.startdt;
        tripobject.enddt = trip.enddt;
        tripobject.itemgrouping = [NSNumber numberWithInt:2];
        [self.selectedtripitems addObject:tripobject];
        found_active = true;
        [self RetrieveImageItem :trip :imagesDirectory];
    }

    /* optional new if no active trip found */
    if (!found_active) {
        TripRLM* emptytrip = [[TripRLM alloc] init];
        emptytrip.key = [[NSUUID UUID] UUIDString];
        emptytrip.itemgrouping = [NSNumber numberWithInt:3];
        emptytrip.name = @"";
        [self.selectedtripitems addObject:emptytrip];
        [self.TripImageDictionary setObject:[UIImage systemImageNamed:@"latch.2.case"] forKey:emptytrip.key];
    }
    
    sort = [RLMSortDescriptor sortDescriptorWithKeyPath:@"startdt" ascending:NO];
    [self.alltripitems sortedResultsUsingDescriptors:[NSArray arrayWithObject:sort]];

    /* next trip 0/1 */
    NSPredicate *predicateFuture = [NSPredicate predicateWithFormat:@"startdt > %@", currentDate];
    RLMResults <TripRLM*> *futureTrips = [self.alltripitems objectsWithPredicate:predicateFuture];
       
    sort = [RLMSortDescriptor sortDescriptorWithKeyPath:@"startdt" ascending:YES];
    futureTrips = [futureTrips sortedResultsUsingDescriptors:[NSArray arrayWithObject:sort]];

    TripRLM* nexttrip = [[TripRLM alloc] init];
    
    if (futureTrips.count >0) {
        TripRLM* trip = [futureTrips firstObject];
        nexttrip.key = trip.key;
        nexttrip.name = trip.name;
        nexttrip.defaulttimezonename = trip.defaulttimezonename;
        nexttrip.startdt = trip.startdt;
        nexttrip.enddt = trip.enddt;
        nexttrip.itemgrouping = [NSNumber numberWithInt:4];
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
        [self.TripImageDictionary setObject:[UIImage systemImageNamed:@"latch.2.case"] forKey:emptytrip.key];
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
            [self.TripImageDictionary setObject:[UIImage systemImageNamed:@"latch.2.case"] forKey:trip.key];
        } else {
            [self.TripImageDictionary setObject:[UIImage imageWithData:pngData] forKey:trip.key];
        }
    } else {
        [self.TripImageDictionary setObject:[UIImage systemImageNamed:@"latch.2.case"] forKey:trip.key];
    }
}



/*
 created date:      18/08/2018
 last modified:     14/01/2020
 remarks:
 */
-(void) LoadFeaturedPoi {
    
    NSArray *types = [NSArray arrayWithObjects: @10,@11,@13,@14,@15,@17,@21,@23,@25,@26,@27,@30,@31,@32,@35,@37,@39,@40,@44,@49,@50,@52,@54,@55,@56,@57,nil];
    
  
    NSSet *typeset = [[NSSet alloc] initWithArray:types];
    
    RLMResults *poicollection = [[PoiRLM allObjects] objectsWithPredicate:[NSPredicate predicateWithFormat:@"categoryid IN %@",typeset]];
    
    if (poicollection.count==0) {
        self.FeaturedPoi = nil;
        self.LabelFeaturedPoi.text = @"Blurry... Not enough Point of Interest items";
        [self.ButtonFeaturedPoi setEnabled:false];
        return;
        
    }
    int featuredIndex = arc4random_uniform((int)poicollection.count);
    self.FeaturedPoi = [poicollection objectAtIndex:featuredIndex];
    
    //self.LabelFeaturedPoi.text = [NSString stringWithFormat:@"In focus... %@", self.FeaturedPoi.name];
    
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
            self.ImageViewFeaturedPoi.image = [UIImage systemImageNamed:@"command"];
        } else {
            [self.ImageViewFeaturedPoi setImage:[UIImage imageWithData:pngData]];
        }
        
    } else {
        self.ImageViewFeaturedPoi.image = [UIImage systemImageNamed:@"command"];
    }
    
    //[self.FeaturedPoiMap removeAnnotations:self.FeaturedPoiMap.annotations];
    
    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
    anno.title = self.FeaturedPoi.name;
    anno.subtitle = [NSString stringWithFormat:@"%@", self.FeaturedPoi.administrativearea];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.FeaturedPoi.lat doubleValue], [self.FeaturedPoi.lon doubleValue]);
    
    anno.coordinate = coord;
    
    //UIFont *font = [UIFont systemFontOfSize:20.0];
    
    UIFont *font = [UIFont fontWithName:@"AmericanTypewriter" size:20.0f];
    
    NSDictionary *attributes = @{NSBackgroundColorAttributeName:[UIColor secondarySystemBackgroundColor], NSForegroundColorAttributeName:[UIColor labelColor], NSFontAttributeName:font};
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"Featured Local POI..." attributes:attributes];
    self.LabelFeaturedPoiHeader.attributedText = string;
    
    //self.LabelFeaturedPoiHeader.transform = CGAffineTransformMakeRotation(.34906585);
    self.LabelFeaturedPoiHeader.transform = CGAffineTransformMakeRotation(.1);
    
    string = [[NSAttributedString alloc] initWithString:self.FeaturedPoi.name attributes:attributes];
    
    self.LabelFeaturedPoi.attributedText = string;
    self.LabelFeaturedPoi.transform = CGAffineTransformMakeRotation(-.1);
    
    string = [[NSAttributedString alloc] initWithString:@"Featured Shared POI..." attributes:attributes];
    
    self.LabelFeaturedSharedPoiHeader.attributedText = string;
    
    self.LabelFeaturedSharedPoiHeader.transform = CGAffineTransformMakeRotation(-.1);
    
    string = [[NSAttributedString alloc] initWithString:@"Rome" attributes:attributes];
    
    self.LabelFeaturedSharedPoi.attributedText = string;
  
    self.LabelFeaturedSharedPoi.transform = CGAffineTransformMakeRotation(.1);
    
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
 last modified:     13/01/2020
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
    } else if([segue.identifier isEqualToString:@"ShowMeNearby"]){
        NearbyListingVC *controller = (NearbyListingVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.fromproject = false;
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

/*
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetHeight(collectionView.frame) - 20, (CGRectGetHeight(collectionView.frame) - 20));
}
*/


/*
 created date:      14/08/2018
 last modified:     06/01/2020
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
    //cell.ImageViewProject.layer.cornerRadius = ((self.MainSurface.bounds.size.height / 2) - 120) / 2;
    
    //cell.ImageViewProject.layer.cornerRadius = cell.ImageViewProject.bounds.size.height / 2;
    //cell.ImageViewProject.layer.masksToBounds = true;
    
    return cell;
}


/*
 created date:      15/08/2018
 last modified:     14/09/2019
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
            [controller setModalPresentationStyle:UIModalPresentationPageSheet];
            [self presentViewController:controller animated:YES completion:nil];
        } else {
            ActivityListVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityListViewController"];
            controller.delegate = self;
            controller.realm = self.realm;
            controller.Trip = trip;
            controller.TripImage = [self.TripImageDictionary objectForKey:trip.key];

            /*
             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
             ActivityListVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityListViewController"];
             controller.delegate = self;
             controller.realm = self.realm;
             controller.TripImage = cell.ImageViewProject.image;
             controller.Trip = [self.tripcollection objectAtIndex:indexPath.row];
            */
            
            [controller setModalPresentationStyle:UIModalPresentationPageSheet];
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
    
    [controller setModalPresentationStyle:UIModalPresentationPageSheet];
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

- (void)didCreatePoiFromProjectPassThru :(PoiRLM*)Object {
    
}



@end
