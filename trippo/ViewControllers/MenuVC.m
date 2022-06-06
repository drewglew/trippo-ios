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

typedef enum  {
    PreviousItem=1,
    CurrentItem=2,
    CheckOutItem=3,
    NewItem=4,
    NextItem=5,
    AnotherNewItem=6,
    PoiListing=7,
    TripsListing=8,
    NearbyMeOption=9,
    SettingsOption=10
} MenuOptions;

// 1=past/last; 2=now; 3=new (optional); 4=future/next; 5=new (optional)

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

/*
 created date:      01/03/2021
 last modified:     07/03/2021
 remarks:
 */
-(void)didDismissPresentingViewController {
    [self LoadPoiDetail :[NSNumber numberWithInt:1]];
}



/*
 created date:      18/08/2018
 last modified:     03/03/2021
 remarks:
 */
-(void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];

    [self.ButtonFeaturedPoi setEnabled:true];
    [self.ButtonSharedFeaturedPoi setEnabled:true];
    
    [self.ActivityView stopAnimating];
    [self LoadPoiDetail :[NSNumber numberWithInt:1]];
    [self LoadPoiDetail :[NSNumber numberWithInt:2]];
    
    
    self.alltripitems = [TripRLM allObjects];
    FirstLoad = false;
    RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
    
    if (settings.count==0) {
        
        UIAlertController *alertSettings = [UIAlertController alertControllerWithTitle:@"Before we begin!"
                                                                            message:@"Points of interest items may be shared, so before you start creating your own please provide the name you would like referenced as the author."
                                                                     preferredStyle:UIAlertControllerStyleAlert];

        
        
        self.okAction = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
            
        
       
       
        UITextField *TextFieldAuthor = alertSettings.textFields[0];
            
        if (![TextFieldAuthor.text isEqualToString:@""]) {
            
            
            self.Settings = [[SettingsRLM alloc] init];
            self.Settings.userkey = [[NSUUID UUID] UUIDString];
            self.Settings.username = TextFieldAuthor.text;
            self.Settings.TripCellColumns = [NSNumber numberWithInt:3];
            self.Settings.ActivityCellColumns = [NSNumber numberWithInt:3];
            self.Settings.NodeScale = [NSNumber numberWithInt:60];
            [self.realm beginWriteTransaction];
            [self.realm addObject:self.Settings];
            [self.realm commitWriteTransaction];
        }
    
        }];
        self.okAction.enabled = NO;
        
        [alertSettings addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.delegate = self;
            [textField setKeyboardType:UIKeyboardTypeAlphabet];
            [textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
        }];

        [alertSettings addAction:self.okAction];
        [self presentViewController:alertSettings animated:YES completion:nil];
        
        
        
    } else {
        self.Settings = settings[0];
        
        self.ButtonAllTrips.enabled = true;
        self.ButtonProject.enabled = true;
        self.ButtonPoi.enabled = true;
        self.ViewRegisterWarning.hidden = true;
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    NSString *finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self.okAction setEnabled:(finalString.length >= 2)];
    return YES;
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
   
        lasttrip.itemgrouping = [NSNumber numberWithInt:PreviousItem];
        lasttrip.key = trip.key;
        lasttrip.name = trip.name;
        lasttrip.defaulttimezonename = trip.defaulttimezonename;
        lasttrip.startdt = trip.startdt;
        lasttrip.enddt = trip.enddt;
        lasttrip.images = trip.images;
    }
   
    
    
    if (lasttrip.itemgrouping==[NSNumber numberWithInt:PreviousItem]) {
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
        tripobject.itemgrouping = [NSNumber numberWithInt:CurrentItem];
        tripobject.images = trip.images;
        [self.selectedtripitems addObject:tripobject];
        found_active = true;
        [self RetrieveImageItem :trip :imagesDirectory];
    }

    
    /* todo - locate any activity that is the latest? */
    
    RLMResults<ActivityRLM*> *activities = [ActivityRLM objectsWhere:@"startdt=enddt and state=1"];
    
    if (activities.count>0) {
        sort = [RLMSortDescriptor sortDescriptorWithKeyPath:@"startdt" ascending:NO];
        
        ActivityRLM *a = [[activities sortedResultsUsingDescriptors:[NSArray arrayWithObject:sort]] firstObject];
        TripRLM* checkout = [[TripRLM alloc] init];
        checkout.key = a.key;
        checkout.name = a.name;
        checkout.defaulttimezonename = a.defaulttimezonename;
        checkout.startdt = a.startdt;
        checkout.enddt = a.enddt;
        [self.TripImageDictionary setObject:[UIImage systemImageNamed:@"arrow.left.to.line"] forKey:a.key];
        checkout.itemgrouping = [NSNumber numberWithInt:CheckOutItem];
        [self.selectedtripitems addObject:checkout];
        
    }
    
    
    /* optional new if no active trip found */
    if (!found_active) {
        TripRLM* emptytrip = [[TripRLM alloc] init];
        emptytrip.key = [[NSUUID UUID] UUIDString];
        emptytrip.itemgrouping = [NSNumber numberWithInt:NewItem];
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
        nexttrip.images = trip.images;
        nexttrip.itemgrouping = [NSNumber numberWithInt:NextItem];
    }
    
    if (nexttrip.itemgrouping == [NSNumber numberWithInt:NextItem]) {
        TripRLM *trip = [TripRLM objectForPrimaryKey:nexttrip.key];
        [self RetrieveImageItem :trip :imagesDirectory];
        [self.selectedtripitems addObject:nexttrip];
    }
    
     /* optional new if active trip found */
    if (found_active) {
        TripRLM* emptytrip = [[TripRLM alloc] init];
        emptytrip.key = [[NSUUID UUID] UUIDString];
        emptytrip.itemgrouping = [NSNumber numberWithInt:AnotherNewItem];
        emptytrip.name = @"";
        [self.TripImageDictionary setObject:[UIImage systemImageNamed:@"latch.2.case"] forKey:emptytrip.key];
        [self.selectedtripitems addObject:emptytrip];
    }
    
    
    // now Poi
    TripRLM* pois = [[TripRLM alloc] init];
    pois.key = [[NSUUID UUID] UUIDString];
    pois.itemgrouping = [NSNumber numberWithInt:PoiListing];
    pois.name = @"";
    [self.TripImageDictionary setObject:[UIImage systemImageNamed:@"command"] forKey:pois.key];
    [self.selectedtripitems addObject:pois];
    
    // now Trips
    TripRLM* trips = [[TripRLM alloc] init];
    trips.key = [[NSUUID UUID] UUIDString];
    trips.itemgrouping = [NSNumber numberWithInt:TripsListing];
    trips.name = @"";
    [self.TripImageDictionary setObject:[UIImage systemImageNamed:@"latch.2.case.fill"] forKey:trips.key];
    [self.selectedtripitems addObject:trips];
    
    // now Nearby
    TripRLM* nearby = [[TripRLM alloc] init];
    nearby.key = [[NSUUID UUID] UUIDString];
    nearby.itemgrouping = [NSNumber numberWithInt:NearbyMeOption];
    nearby.name = @"";
    [self.TripImageDictionary setObject:[UIImage systemImageNamed:@"target"] forKey:nearby.key];
    [self.selectedtripitems addObject:nearby];
    
    // now Settings
    TripRLM* settings = [[TripRLM alloc] init];
    settings.key = [[NSUUID UUID] UUIDString];
    settings.itemgrouping = [NSNumber numberWithInt:SettingsOption];
    settings.name = @"";
    [self.TripImageDictionary setObject:[UIImage systemImageNamed:@"gearshape.2"] forKey:settings.key];
    [self.selectedtripitems addObject:settings];
    
    
    
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
 last modified:     07/03/2021
 remarks:
 */
-(void) LoadPoiDetail :(NSNumber *) sharedFlag {
    
    UIFont *font = [UIFont fontWithName:@"AmericanTypewriter" size:20.0f];
    NSDictionary *attributes = @{NSBackgroundColorAttributeName:[UIColor secondarySystemBackgroundColor], NSForegroundColorAttributeName:[UIColor labelColor], NSFontAttributeName:font};
    NSString *headerText;
    NSString *detailText;
    


    NSArray *Types = [NSArray arrayWithObjects: @10,@11,@13,@14,@15,@16,@17,@21,@23,@25,@26,@27,@30,@31,@32,@35,@37,@39,@40,@44,@49,@50,@52,@54,@55,@56,@57,nil];
    
    NSArray *TypeNames = @[@"Accomodation",@"Airport",@"Astronaut",@"Bakery",@"Beer",@"Bicycle",@"Bridge",@"Car Hire",@"Car Park",@"Casino",@"Cave",@"Church",@"Cinema",@"City",@"City Park",@"Climbing Region",@"Club",@"Coastline",@"Concert Venue",@"Food and Wine",@"Football",@"Forest",@"Golf",@"Historic Location",@"Home",@"Lake",@"Lighthouse",@"City",@"Miscellaneous",@"Monument/Statue",@"Museum",@"National Park",@"Nature",@"Office",@"Petrol Station",@"Photography",@"Restaurant",@"River",@"Rugby",@"Safari",@"Scenary",@"School",@"Ship",@"Shopping",@"Skiing",@"Sports/Exercise",@"Swimming",@"Tennis Courts",@"Theatre",@"Theme Park",@"Tower",@"Train",@"Trekking",@"Venue",@"Village",@"Vineyard",@"Windmill",@"Zoo"
        ];
    
    NSSet *typeset = [[NSSet alloc] initWithArray:Types];
    
    RLMResults *poicollection = [[PoiRLM allObjects] objectsWithPredicate:[NSPredicate predicateWithFormat:@"categoryid IN %@ AND poisharedflag = %@",typeset,sharedFlag]];
    
    
    
    if (poicollection.count==0) {
        if ([sharedFlag intValue] == 2) {
            self.FeaturedSharedPoi = nil;
            [self.ButtonSharedFeaturedPoi setEnabled:false];
            headerText = @"Featured Shared POI item...";
            detailText = @"Blurry...\nTry pressing download from cloud";
        } else {
            self.FeaturedPoi = nil;
            [self.ButtonFeaturedPoi setEnabled:false];
            headerText = @"Featured POI item on device...";
            detailText = @"Blurry... Not enough\nPoint of Interest items";
        }
    } else {
        // randomly select POI's from collection.
        int featuredIndex = arc4random_uniform((int)poicollection.count);
        int imageCount = 0;
        
        if ([sharedFlag intValue] == 1) {
            self.FeaturedPoi = [poicollection objectAtIndex:featuredIndex];
            imageCount = (int)self.FeaturedPoi.images.count;
        } else {
            self.FeaturedSharedPoi = [poicollection objectAtIndex:featuredIndex];
            imageCount = (int)self.FeaturedSharedPoi.images.count;
        }
            
        NSURL *url = [self applicationDocumentsDirectory];
        
        NSData *pngData;
        
        if (imageCount > 0) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
            
            RLMResults *filteredArray;
            if ([sharedFlag intValue] == 1) {
                filteredArray = [self.FeaturedPoi.images objectsWithPredicate:predicate];
            } else {
                filteredArray = [self.FeaturedSharedPoi.images objectsWithPredicate:predicate];
            }
            
            ImageCollectionRLM *keyimgobject;
            if (filteredArray.count==0) {
                if ([sharedFlag intValue] == 1) {
                    keyimgobject = [self.FeaturedPoi.images firstObject];
                } else {
                    keyimgobject = [self.FeaturedSharedPoi.images firstObject];
                }
            } else {
                keyimgobject = [filteredArray firstObject];
            }
            
            NSURL *imagefile = [url URLByAppendingPathComponent:keyimgobject.ImageFileReference];
            NSError *err;
            pngData = [NSData dataWithContentsOfURL:imagefile options:NSDataReadingMappedIfSafe error:&err];
            
            if (pngData==nil) {
                if ([sharedFlag intValue] == 1) {
                    self.ImageViewFeaturedPoi.image = [UIImage systemImageNamed:@"command"];
                } else {
                    self.ImageViewSharedFeaturedPoi.image = [UIImage systemImageNamed:@"command"];
                }
            } else {
                if ([sharedFlag intValue] == 1) {
                    [self.ImageViewFeaturedPoi setImage:[UIImage imageWithData:pngData]];
                } else {
                    [self.ImageViewSharedFeaturedPoi setImage:[UIImage imageWithData:pngData]];
                }
            }
            
        } else {
            if ([sharedFlag intValue] == 1) {
                self.ImageViewFeaturedPoi.image = [UIImage systemImageNamed:@"command"];
            } else {
                self.ImageViewSharedFeaturedPoi.image = [UIImage systemImageNamed:@"command"];
            }
        }
        
        if ([sharedFlag intValue] == 2) {
            headerText = [NSString stringWithFormat:@"Shared Featured %@...",[TypeNames objectAtIndex:[self.FeaturedSharedPoi.categoryid longValue]]];
            detailText = self.FeaturedSharedPoi.name;
            [self.ButtonSharedFeaturedPoi setEnabled:true];
        } else {
            headerText = [NSString stringWithFormat:@"My Featured %@...",[TypeNames objectAtIndex:[self.FeaturedPoi.categoryid longValue]]];
            detailText = self.FeaturedPoi.name;
            [self.ButtonFeaturedPoi setEnabled:true];
        }
    }
    
    if ([sharedFlag intValue] == 1) {
        self.LabelFeaturedPoiHeader.attributedText = [[NSAttributedString alloc] initWithString:headerText attributes:attributes];
        self.LabelFeaturedPoiHeader.transform = CGAffineTransformMakeRotation(.1);
        
        self.LabelFeaturedPoi.attributedText = [[NSAttributedString alloc] initWithString:detailText attributes:attributes];
        self.LabelFeaturedPoi.transform = CGAffineTransformMakeRotation(.1);
        
        
    } else {
        self.LabelFeaturedSharedPoiHeader.attributedText = [[NSAttributedString alloc] initWithString:headerText attributes:attributes];
        self.LabelFeaturedSharedPoiHeader.transform = CGAffineTransformMakeRotation(-.1);
        
        self.LabelFeaturedSharedPoi.attributedText = [[NSAttributedString alloc] initWithString:detailText attributes:attributes];
        self.LabelFeaturedSharedPoi.transform = CGAffineTransformMakeRotation(-.1);
        
    }
    
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
 last modified:     07/03/2021
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([segue.identifier isEqualToString:@"ShowFeaturedPoi"]){
        PoiDataEntryVC *controller= (PoiDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.PointOfInterest = self.FeaturedPoi;
        controller.readonlyitem = true;
        controller.realm = self.realm;
    } else if ([segue.identifier isEqualToString:@"ShowFeaturedSharedPoi"]){
        PoiDataEntryVC *controller= (PoiDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.PointOfInterest = self.FeaturedSharedPoi;
        controller.readonlyitem = true;
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
 created date:      14/08/2018
 last modified:     07/03/2021
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    ProjectListCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"projectCellId" forIndexPath:indexPath];
    TripRLM *trip = [self.selectedtripitems objectAtIndex:indexPath.row];
    
    if (trip.itemgrouping!=[NSNumber numberWithInt:CheckOutItem]) {
        cell.ImageViewProject.tintColor = [UIColor systemBackgroundColor];
        cell.ImageViewProject.image = [self.TripImageDictionary objectForKey:trip.key];
        cell.ImageViewProject.transform = CGAffineTransformMakeRotation(0);
        //cell.ImageViewProject.backgroundColor = [UIColor clearColor];
        if (trip.images.count>0) {
            if ([trip.images[0].ImageFileReference isEqualToString:@""]) {
                cell.ImageViewProject.layer.cornerRadius = 0;
                cell.ImageViewProject.layer.borderWidth = 0.0f;
                cell.ImageViewProject.layer.masksToBounds = YES;
            } else {
                cell.ImageViewProject.layer.cornerRadius = cell.ImageViewProject.frame.size.width/2;
                cell.ImageViewProject.layer.borderWidth = 0.0f;
                cell.ImageViewProject.layer.borderColor = [UIColor whiteColor].CGColor;
                cell.ImageViewProject.layer.masksToBounds = YES;
            }
        } else {
            
            cell.ImageViewProject.layer.cornerRadius = 0;
            cell.ImageViewProject.layer.borderWidth = 0.0f;
            cell.ImageViewProject.layer.masksToBounds = YES;
        }
    } else {
        cell.ImageViewProject.image = [self.TripImageDictionary objectForKey:trip.key];
        cell.ImageViewProject.layer.cornerRadius = 0;
        cell.ImageViewProject.layer.borderWidth = 0.0f;
        cell.ImageViewProject.layer.masksToBounds = YES;
        cell.ImageViewProject.tintColor = [UIColor systemRedColor];
        cell.ImageViewProject.transform = CGAffineTransformMakeRotation(-.34906585);
    }
    
    cell.LabelProjectName.text = trip.name;
        
    NSString *reference = @"";
 
    if (trip.itemgrouping==[NSNumber numberWithInt:PreviousItem]) {
        reference = @"Previous";
        cell.LabelDateRange.textColor = [UIColor systemBackgroundColor];
    } else if (trip.itemgrouping==[NSNumber numberWithInt:CurrentItem]) {
        reference = @"Active";
        cell.LabelDateRange.textColor = [UIColor systemBackgroundColor];
    } else if (trip.itemgrouping==[NSNumber numberWithInt:CheckOutItem]) {
        reference = @"Check Out";
        cell.LabelDateRange.textColor = [UIColor systemRedColor];
    } else if (trip.itemgrouping==[NSNumber numberWithInt:NextItem]) {
        reference = @"Next";
        cell.LabelDateRange.textColor = [UIColor systemBackgroundColor];
    } else if (trip.itemgrouping==[NSNumber numberWithInt:PoiListing]) {
        reference = @"POI";
        cell.LabelDateRange.textColor = [UIColor systemBackgroundColor];
    } else if (trip.itemgrouping==[NSNumber numberWithInt:TripsListing]) {
        reference = @"Trips";
        cell.LabelDateRange.textColor = [UIColor systemBackgroundColor];
    } else if (trip.itemgrouping==[NSNumber numberWithInt:NearbyMeOption]) {
        reference = @"Nearby";
        cell.LabelDateRange.textColor = [UIColor systemBackgroundColor];
    } else if (trip.itemgrouping==[NSNumber numberWithInt:SettingsOption]) {
        reference = @"Settings";
        cell.LabelDateRange.textColor = [UIColor systemBackgroundColor];
    } else {
        reference = @"New";
        cell.LabelDateRange.textColor = [UIColor systemBackgroundColor];
    }
    cell.LabelDateRange.text = reference;
   


    return cell;
}


/*
 created date:      15/08/2018
 last modified:     07/03/2021
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.Settings != nil) {
        TripRLM *trip = [self.selectedtripitems objectAtIndex:indexPath.row];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

        
        if (trip.itemgrouping==[NSNumber numberWithInt:NewItem] || trip.itemgrouping==[NSNumber numberWithInt:AnotherNewItem]) {
            ProjectDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ProjectDataEntryViewController"];
            controller.delegate = self;
            controller.Trip = [[TripRLM alloc] init];
            controller.newitem = true;
            controller.realm = self.realm;
            [controller setModalPresentationStyle:UIModalPresentationPageSheet];
            [self presentViewController:controller animated:YES completion:nil];
        
        } else if (trip.itemgrouping==[NSNumber numberWithInt:PoiListing]) {
            // poi
            PoiSearchVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"PoiListingViewController"];
            controller.frommenu = true;
            controller.delegate = self;
            controller.Project = nil;
            controller.Activity = nil;
            controller.realm = self.realm;
            [controller setModalPresentationStyle:UIModalPresentationPageSheet];
            [self presentViewController:controller animated:YES completion:nil];
        
        } else if (trip.itemgrouping==[NSNumber numberWithInt:TripsListing]) {
            // trips
            ProjectListVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ProjectListViewController"];
            controller.delegate = self;
            controller.realm = self.realm;
            [controller setModalPresentationStyle:UIModalPresentationPageSheet];
            [self presentViewController:controller animated:YES completion:nil];
            
        } else if (trip.itemgrouping==[NSNumber numberWithInt:NearbyMeOption]) {
            // nearby
            NearbyListingVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"NearbyListingViewController"];
            controller.frommenu = true;
            controller.delegate = self;
            controller.isnearbyme = true;
            controller.fromproject = false;
            controller.realm = self.realm;
            controller.PointOfInterest = nil;
            [controller setModalPresentationStyle:UIModalPresentationPageSheet];
            [self presentViewController:controller animated:YES completion:nil];
        } else if (trip.itemgrouping==[NSNumber numberWithInt:SettingsOption]) {
            // settings
            SettingsVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
            controller.delegate = self;
            controller.Settings = self.Settings;
            controller.realm = self.realm;
            [controller setModalPresentationStyle:UIModalPresentationPageSheet];
            [self presentViewController:controller animated:YES completion:nil];
        } else if (trip.itemgrouping==[NSNumber numberWithInt:CheckOutItem]) {
            
            /* todo - just present the item for now */
            NSDate *today = [NSDate date];
            
            ActivityRLM *a = [[ActivityRLM objectsWhere:@"key=%@ and state=1",trip.key] firstObject];
            [self.realm beginWriteTransaction];
            a.enddt = today;
            [self.realm commitWriteTransaction];

        } else {
            ActivityListVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityListViewController"];
            controller.delegate = self;
            controller.realm = self.realm;
            controller.Trip = trip;
            controller.TripImage = [self.TripImageDictionary objectForKey:trip.key];
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
        if (p.itemgrouping==[NSNumber numberWithInt:CurrentItem] || p.itemgrouping==[NSNumber numberWithInt:NewItem]) {
            indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        } else if (p.itemgrouping==[NSNumber numberWithInt:NextItem] && indexPath==nil) {
            indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        }
        index++;
    }
    /*if (indexPath!=nil) {
        [self.CollectionViewPreviewPanel scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
     */
    
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
    controller.frommenu = true;
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



/*
 created date:      07/03/2021
 last modified:     07/03/2021
 remarks:           returns either the poi key of item obtained from cloud or empty string.
 */
-(NSString*) ObtainNewPoiKeyWithCompleteBlock:(void(^)(NSString * result))completeBlock {
    if (self.checkInternet) {
        CKDatabase *publicDB = [[CKContainer containerWithIdentifier:@"iCloud.com.drew.trips"] publicCloudDatabase];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"blockedflag = 1"];
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"poi" predicate:predicate];
        
        CKQueryOperation *operation = [[CKQueryOperation alloc] initWithQuery:query];
        operation.resultsLimit = 20;
        NSArray *desiredKeys = [[NSArray alloc] initWithObjects:@"key",nil];
        [operation setDesiredKeys:desiredKeys];
   
        NSMutableArray *cloudPois = [[NSMutableArray alloc] init];
        
        operation.recordFetchedBlock = ^(CKRecord *record) {
            [cloudPois addObject:[record objectForKey: @"key"]];
        };
        operation.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSPredicate *predicateExclusion = [NSPredicate predicateWithFormat:@"key IN %@",cloudPois];
                
                RLMResults <PoiRLM*> *IgnorePoiObjects = [PoiRLM objectsWithPredicate:predicateExclusion];
                
                for (PoiRLM *p in IgnorePoiObjects) {
                    if ([cloudPois containsObject:p.key]) {
                        [cloudPois removeObject:p.key];
                    }
                }
                if (cloudPois.count >0) {
                    if (cloudPois.count == 1) {
                        if (completeBlock) completeBlock([cloudPois firstObject]);
                       
                    } else {
                        int featuredIndex = arc4random_uniform((int)cloudPois.count);
                        if (completeBlock) completeBlock([cloudPois objectAtIndex:featuredIndex]);
                    }
                } else {
                    if (completeBlock) completeBlock(@"no-items");
                }
                
            });
        };
        [publicDB addOperation:operation];
    } else {
        if (completeBlock) completeBlock(@"no-inet");
        //return @"no-inet";
    }
    return nil;
}


/*
 created date:      06/03/2021
 last modified:     07/03/2021
 remarks:
 */
-(void) DownloadFeaturedSharedPoi {
    
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightThin];

    
    [self ObtainNewPoiKeyWithCompleteBlock:^(NSString *result) {
        if (![result isEqualToString:@"no-items"] && ![result isEqualToString:@"no-inet"]) {
            
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
            
            spinner.frame = CGRectMake(round((self.ImageViewSharedFeaturedPoi.frame.size.width) / 2), round((self.ImageViewSharedFeaturedPoi.frame.size.height) / 2), 25, 25);
            
            CKDatabase *publicDB = [[CKContainer containerWithIdentifier:@"iCloud.com.drew.trips"] publicCloudDatabase];
            //NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key = %@",result];
            
            CKQuery *query = [[CKQuery alloc] initWithRecordType:@"poi" predicate:predicate];
               
            [self.view addSubview:spinner];
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner startAnimating];
            });

            CKQueryOperation *operation = [[CKQueryOperation alloc] initWithQuery:query];
            operation.resultsLimit = 1;
            operation.recordFetchedBlock = ^(CKRecord *record) {
                NSLog(@"RECORD RETURNED %@", record.recordID);
                
                RLMResults <PoiRLM*> *PoiResults = [PoiRLM objectsWhere:@"key=%@", [record objectForKey: @"key"]];
                
                if (PoiResults.count == 0) {
                    PoiRLM *p = [self GetRecord :record];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // now add to points of interest!
                        [self.realm  transactionWithBlock:^{
                            [self.realm addObject:p];
                        }];
                        
                    });
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    // TODO - set to the new item just loaded.
                    
                    [self.ButtonSharedPoiCloudDownload setImage:[UIImage systemImageNamed:@"checkmark.icloud" withConfiguration:config] forState:UIControlStateNormal];
                    [self LoadPoiDetail :[NSNumber numberWithInt:2]];
                });
            };
            operation.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [spinner stopAnimating];
                });
            };
            
            [publicDB addOperation:operation];
     
        } else {
            if ([result isEqualToString:@"no-items"]) {
                [self.ButtonSharedPoiCloudDownload setImage:[UIImage systemImageNamed:@"exclamationmark.icloud" withConfiguration:config] forState:UIControlStateNormal];
            } else if ([result isEqualToString:@"no-inet"]) {
                [self.ButtonSharedPoiCloudDownload setImage:[UIImage systemImageNamed:@"icloud.slash" withConfiguration:config] forState:UIControlStateNormal];
            } else {
                [self.ButtonSharedPoiCloudDownload setImage:[UIImage systemImageNamed:@"icloud.and.arrow.up" withConfiguration:config] forState:UIControlStateNormal];
            }
            [self LoadPoiDetail :[NSNumber numberWithInt:2]];
        }
    }];
}

/*
 created date:      06/03/2021
 last modified:     07/03/2021
 */
-(PoiRLM*)GetRecord :(CKRecord*) record {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    
    PoiRLM *poi = [[PoiRLM alloc] init];
    poi.key = [record objectForKey: @"key"];
    poi.name = [record objectForKey: @"name"];
    poi.categoryid = [record objectForKey: @"categoryid"];
    poi.authorkey = [record objectForKey: @"authorkey"];
    poi.authorname = [record objectForKey: @"authorname"];
    poi.country = [record objectForKey: @"country"];
    poi.countrycode = [record objectForKey: @"countrycode"];
    poi.createddt = [record objectForKey: @"createddt"];
    poi.devicesharedby = [record objectForKey: @"device"];
    poi.fullthoroughfare = [record objectForKey: @"fullthoroughfare"];
    // [newPoiRecord setObject: @"en" = [record objectForKey: @"languagecode"];
    poi.lat = [record objectForKey: @"lat"];
    poi.lon = [record objectForKey: @"lon"];
    poi.locality = [record objectForKey: @"locality"];
    poi.modifieddt = [record objectForKey: @"modifieddt"];
    poi.privatenotes = [record objectForKey: @"notes"];
    poi.postcode = [record objectForKey: @"postcode"];
    poi.radius = [record objectForKey: @"radius"];
    poi.searchstring = [record objectForKey: @"searchstring"];
    poi.subadministrativearea = [record objectForKey: @"subadministrativearea"];
    poi.sublocality = [record objectForKey: @"sublocality"];
    poi.wikititle = [record objectForKey: @"wikititle"];
    poi.poisharedflag = [NSNumber numberWithInt:2];
    
    ImageCollectionRLM *i = [[ImageCollectionRLM alloc] init];
    
    i.info = [record objectForKey: @"imageinfo"];
    i.key = [record objectForKey: @"imagekey"];
    i.KeyImage = [NSNumber numberWithInt:1];
    
    CKAsset *asset = [record objectForKey:@"image"];
    NSData *imageData = [NSData dataWithContentsOfURL:asset.fileURL];
        
    if (imageData != nil) {
        i.ImageFileReference = [record objectForKey: @"imagefilepathname"];
        /* first we need to create the image folder if it hasn't bee created before*/
        NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/%@",poi.key]];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        /* next we try and copy the image into the same folder we just created */
        NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",i.ImageFileReference]];
        [imageData writeToFile:dataFilePath atomically:YES];
        
        
        CGSize imagesize = CGSizeMake(100 , 100);
        dispatch_async(dispatch_get_main_queue(), ^{
            [AppDelegateDef.PoiBackgroundImageDictionary setObject:[ToolBoxNSO imageWithImage:[UIImage imageWithData:imageData] convertToSize:imagesize] forKey:poi.key];
        });
    }
    [poi.images addObject:i];
    return poi;
}



/*
 created date:      06/03/2021
 last modified:     06/03/2021
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

- (IBAction)ButtonDownloadFromiCloudPressed:(id)sender {
    
    [self DownloadFeaturedSharedPoi];
    
}



@end
