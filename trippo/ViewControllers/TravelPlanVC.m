//
//  TravelPlanVC.m
//  trippo
//
//  Created by andrew glew on 19/07/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import "TravelPlanVC.h"
#import "JENNode.h"
#import "JENTreeView.h"
#import "JENDefaultNodeView.h"
#import "JENCustomDecorationView.h"

@interface TravelPlanVC ()
@property RLMNotificationToken *notification;
@property int ItemCounter;
@property bool HideMapAnnotations;

@end


@implementation TravelPlanVC
BOOL _mapNeedsPadding;
/*
 created date:      19/07/2019
 last modified:     19/01/2020
 remarks:           Constructs the root node and calls the method in same class to load tree.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
    self.StepperScale.value = [settings[0].NodeScale doubleValue];
    
    self.HideMapAnnotations = false;
    JENNode *root = [[JENNode alloc] init];
    root.nodeName = @"Trip";
    root.activityImage = self.TripImage;
    self.treeview.rootNode                  = root;
    self.treeview.dataSource                = self;
    self.LabelTripTitle.text = self.Trip.name;

    if (self.ActivityState == [NSNumber numberWithInteger:1]) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightBold];
        self.ImageViewStateIndicator.image = [UIImage systemImageNamed:@"figure.walk" withConfiguration:config];
    } else {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightBold];
        self.ImageViewStateIndicator.image = [UIImage systemImageNamed:@"lightbulb" withConfiguration:config];
    }

    __weak typeof(self) weakSelf = self;
    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf.ButtonCalculate setHidden:false];
        
        [weakSelf LoadTreeFromActivityData];
        weakSelf.itinerarycollection = [[NSMutableArray alloc] init];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDt" ascending:YES];
        NSArray *sortedChildren = [weakSelf.treeview.rootNode.children sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
        [weakSelf obtainJourney :sortedChildren :nil :weakSelf.treeview.rootNode];
        
        if (weakSelf.itin.count > 0) {
            weakSelf.itinerarycollection = [weakSelf.itin mutableCopy];
            [weakSelf.itin removeAllObjects];
        }
        
        [weakSelf.ItineraryTableView reloadData];

    }];
    [self LoadTreeFromActivityData];
    
    self.itinerarycollection = [[NSMutableArray alloc] init];
    self.singlepointdistancecollection = [[NSMutableArray alloc] init];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDt" ascending:YES];
    NSArray *sortedChildren = [self.treeview.rootNode.children sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    [self obtainJourney :sortedChildren :nil :self.treeview.rootNode];
    
    [self.ItineraryTableView reloadData];
    
    UILabel *lbl= [[UILabel alloc] initWithFrame:CGRectMake(-10, 0, self.ButtonJourneySideButton.frame.size.width,self.ButtonJourneySideButton.frame.size.height)];
    lbl.transform = CGAffineTransformMakeRotation(M_PI / 2);
    lbl.text = @"journey";
    lbl.textColor =[UIColor labelColor];
    lbl.backgroundColor =[UIColor clearColor];
    [self.ButtonJourneySideButton addSubview:lbl];
    
    lbl= [[UILabel alloc] initWithFrame:CGRectMake(-10, 0, self.ButtonMapSideButton.frame.size.width,self.ButtonMapSideButton.frame.size.height)];
    lbl.transform = CGAffineTransformMakeRotation(M_PI / 2);
    lbl.text = @"map";
    lbl.textColor = [UIColor colorNamed:@"TrippoColor"];
    lbl.backgroundColor =[UIColor clearColor];
    [self.ButtonMapSideButton addSubview:lbl];
    
    self.JourneySidePanelFullWidthConstraint.constant = self.view.bounds.size.width;
    self.MapSidePanelFullWidthConstraint.constant = self.view.bounds.size.width;
    
    self.JourneySidePanelViewTrailingConstraint.constant = 0 - self.JourneySidePanelFullWidthConstraint.constant + self.ButtonTabWidthConstraint.constant;
    
    self.MapSidePanelViewTrailingConstraint.constant = 0 - self.MapSidePanelFullWidthConstraint.constant + self.ButtonMapTabWidthConstraint.constant;
    
    
    self.ButtonJourneySideButton.layer.cornerRadius = 5; // this value vary as per your desire
    self.ButtonJourneySideButton.clipsToBounds = YES;
    
    self.ButtonMapSideButton.layer.cornerRadius = 5; // this value vary as per your desire
    self.ButtonMapSideButton.clipsToBounds = YES;
    
    
    self.ItineraryTableView.delegate = self;
    self.ItineraryTableView.rowHeight = 100;
    
    self.DistanceFromPointTableView.delegate = self;
    self.DistanceFromPointTableView.rowHeight = 75;
    self.MapView.delegate = self;
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if(_mapNeedsPadding){
        _mapNeedsPadding = NO;
        [self.MapView setVisibleMapRect:self.MapView.visibleMapRect edgePadding:UIEdgeInsetsMake(100, 20, 10, 10) animated:YES];
    }
}

/*
 created date:      20/07/2019
 last modified:     20/07/2019
 remarks:           Original from GitHub https://github.com/chikuba/JENTreeView.
 */
-(void)layoutTreeview:(UISwitch*)sender {
    self.treeview.alignChildren        =  0;
    self.treeview.invertedLayout    =  0;
    [self.treeview layoutGraph];
}

/*
 created date:      20/07/2019
 last modified:     20/07/2019
 remarks:           Original from GitHub https://github.com/chikuba/JENTreeView.
 */
-(void)reloadTreeView:(UISwitch*)sender {
    self.treeview.showSubviews        = true;
    self.treeview.showSubviewFrames    = true;
    [self.treeview reloadData];
}

/*
 created date:      20/07/2019
 last modified:     25/08/2019
 remarks:           Original from GitHub https://github.com/chikuba/JENTreeView.  Constructs node with its data.
 */
-(UIView*)treeView:(JENTreeView*)treeView
nodeViewForModelNode:(id<JENTreeViewModelNode>)modelNode {
    
    bool isSelected = false;
    if ([self.NodeSelectedActivityKey isEqualToString:modelNode.activity.key]) {
        isSelected = true;
    }
    
    JENDefaultNodeView* view = [[JENDefaultNodeView alloc] initWithParm:self.StepperScale.value :isSelected];

    view.nodeName               = modelNode.nodeName;
    view.activity               = modelNode.activity;
    view.activityImage          = modelNode.activityImage;
    view.startDt                = modelNode.startDt;
    view.nodeSize               = modelNode.nodeSize;
    view.transportType          = modelNode.transportType;
    view.travelBack             = modelNode.travelBack;
    return view;
}


/*
 created date:      20/07/2019
 last modified:     20/07/2019
 remarks:           Copied from GitHub https://github.com/chikuba/JENTreeView
 */
-(UIView<JENDecorationView>*)treeView:(JENTreeView*)treeView
           decorationViewForModelNode:(id<JENTreeViewModelNode>)modelNode {
    
    JENCustomDecorationView *decorationView = [[JENCustomDecorationView alloc] init];
    
    decorationView.ortogonalConnection  =  1;
    decorationView.showView             = false;
    decorationView.showViewFrame        = false;
    
    return decorationView;
}

/*
 created date:      21/07/2019
 last modified:     21/07/2019
 remarks:           Resets the tree effectively losing any changes user manually made.
 */
- (IBAction)ResetPressed:(id)sender {
    [self LoadTreeFromActivityData];
}


/*
 created date:      20/07/2019
 last modified:     21/07/2019
 remarks:           Regenerates the tree from realm db.  Called on startup and reset button press.
 */
- (void)LoadTreeFromActivityData {

    self.excludedlisting  = [[NSMutableArray alloc] init];
    
    NSDate *MinDate = self.Trip.startdt;
    NSDate *MaxDate = self.Trip.enddt;
    
    /* build a controller set that can check off items already loaded */
    for (ActivityRLM *activityobj in self.activitycollection) {
         NodeNSO *item = [[NodeNSO alloc] init];
         item.Activity = activityobj;
         item.isUsed = false;
         if([activityobj.startdt compare: MinDate] == NSOrderedAscending ) {
             MinDate = activityobj.startdt;
         }
         if([activityobj.enddt compare: MaxDate] == NSOrderedDescending ) {
            MaxDate = activityobj.enddt;
         }
    }

    RLMResults<ActivityRLM*> *activities = [ActivityRLM objectsWhere:@"startdt BETWEEN {%@, %@} and enddt BETWEEN {%@, %@} and state=%@ and tripkey=%@", MinDate, MaxDate, MinDate, MaxDate, self.ActivityState, self.Trip.key];
    
    RLMSortDescriptor *sort = [RLMSortDescriptor sortDescriptorWithKeyPath:@"startdt" ascending:YES];
    activities = [activities sortedResultsUsingDescriptors:[NSArray arrayWithObject:sort]];

    self.treeview.rootNode.children = [NSSet setWithArray:[self getChildren :MinDate :MaxDate :activities]];
    self.treeview.dataSource                = self;
    self.treeview.alignChildren             =  0;
    self.treeview.invertedLayout            =  0;
    self.treeview.showSubviews              = false;
    self.treeview.showSubviewFrames         = false;
    
    [self.treeview reloadData];

}


/*
 created date:      20/07/2019
 last modified:     21/07/2019
 remarks:           Recursive function that creates nodes and identifies children.
 */
-(NSMutableArray*) getChildren :(NSDate*)StartDt :(NSDate*)EndDt :(RLMResults*) activities {
    NSMutableArray *children = [[NSMutableArray alloc] init];
    
    /* possibly could reuse existing */
    RLMResults<ActivityRLM*> *dataset = [activities objectsWhere:@"startdt BETWEEN {%@, %@} and enddt BETWEEN {%@, %@} and state=%@ and tripkey=%@", StartDt, EndDt, StartDt, EndDt, self.ActivityState, self.Trip.key];
    
    RLMSortDescriptor *sort = [RLMSortDescriptor sortDescriptorWithKeyPath:@"startdt" ascending:YES];
    activities = [activities sortedResultsUsingDescriptors:[NSArray arrayWithObject:sort]];

    for (ActivityRLM *item in dataset) {
        bool IgnoreActivity = false;
        
        for (ActivityRLM *excludeditem in self.excludedlisting) {
            if ([item.key isEqualToString:excludeditem.key]) {
                IgnoreActivity = true;
            }
        }
        if (!IgnoreActivity) {
            /* excluded list includes all items already processed */
            [self.excludedlisting addObject:item];
            
            JENNode *leaf = [[JENNode alloc] init];
            leaf.nodeName = item.name;
            leaf.startDt = item.startdt;
            leaf.activity = item;
            leaf.insertNode = false;
            leaf.nodeSize = self.StepperScale.value;
            
            if (item.traveltransportid == nil) {
                leaf.transportType = 0;
            } else {
                leaf.transportType = item.traveltransportid;
            }
            leaf.travelBack = item.travelbackflag;
            
            if ([self.ActivityImageDictionary objectForKey:item.compondkey] == nil) {
                NSLog(@"empty image...");
                [self getActivityImage :item];
            }
            leaf.activityImage = [self.ActivityImageDictionary objectForKey:item.compondkey];
            
            leaf.children = [NSSet setWithArray:[self getChildren:item.startdt :item.enddt :dataset]];
            [children addObject:leaf];
        }
    }
    return children;
}


/*
 created date:      22/07/2019
 last modified:     22/07/2019
 remarks:           Load single Activity image for Trip - TODO optimize this.
 use thumbnail image if it exists, else - create it (the activity data entry point will
 also need to do some management - when it deletes an activity or a key image delete its thumbnail
 */
-(void)getActivityImage :(ActivityRLM*) activity {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imagesDirectory = [paths objectAtIndex:0];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
    RLMResults *filteredResults;
    ImageCollectionRLM *imgobject = [[ImageCollectionRLM alloc] init];
    
    CGSize CellSize = CGSizeMake(200,200);
    
    filteredResults = [activity.images objectsWithPredicate:predicate];
    if (filteredResults.count>0) {
        imgobject = [filteredResults firstObject];
    } else {
        PoiRLM *poiobject = [PoiRLM objectForPrimaryKey:activity.poikey];
        filteredResults = [poiobject.images objectsWithPredicate:predicate];
        if (filteredResults.count==0) {
            imgobject = [poiobject.images firstObject];
        } else {
            imgobject = [filteredResults firstObject];
        }
    }
    
    NSString *dataFilePath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imgobject.ImageFileReference]];
    NSData *pngData = [NSData dataWithContentsOfFile:dataFilePath];
    if (pngData==nil) {
        if (activity.state == [NSNumber numberWithInteger:0]) {
            @autoreleasepool {
                UIImage *image = [ToolBoxNSO resizeImage:[UIImage imageNamed:@"Planning"] toFitInSize:CellSize];
                [self.ActivityImageDictionary setObject:image forKey:activity.compondkey];
                image = nil;
            }
        } else {
            @autoreleasepool {
                UIImage *image = [ToolBoxNSO resizeImage:[UIImage imageNamed:@"Activity"] toFitInSize:CellSize];
                [self.ActivityImageDictionary setObject:image  forKey:activity.compondkey];
                image = nil;
            }
        }
    } else {
        @autoreleasepool {
            UIImage *image = [ToolBoxNSO resizeImage:[UIImage imageWithData:pngData]  toFitInSize:CellSize];
            [self.ActivityImageDictionary setObject:image forKey:activity.compondkey];
            image = nil;
        }
        
    }
}


/*
 created date:      21/07/2019
 last modified:     13/08/2019
 remarks:           Resize the nodes on stepper pressed and save to settings.  Need to be careful of updates.
 */
- (IBAction)StepperPressed:(id)sender {

    RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
    SettingsRLM *settingitem = [settings firstObject];
    [self.realm transactionWithBlock:^{
        settingitem.NodeScale = [NSNumber numberWithDouble:self.StepperScale.value];
    }];
    [self.treeview reloadData];
}

/*
 created date:      23/07/2019
 last modified:     23/07/2019
 remarks:           Animations.
 */
- (IBAction)JourneySideButtonPressed:(id)sender {
    CGFloat ViewWidth =  (self.JorneySidePanelView.frame.size.width - self.ButtonTabWidthConstraint.constant) * -1;
    if (self.JourneySidePanelViewTrailingConstraint.constant == ViewWidth ) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             self.JourneySidePanelViewTrailingConstraint.constant -= ViewWidth;
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished)
         {

         }];
    } else {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             self.JourneySidePanelViewTrailingConstraint.constant += ViewWidth;
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished)
         {
  
         }];
    }
}

/*
 created date:      27/07/2019
 last modified:     05/03/2021
 remarks:           Animations.
 */
- (IBAction)MapSideButtonPressed:(id)sender {
    CGFloat ViewWidth =  (self.MapSidePanelView.frame.size.width - self.ButtonMapTabWidthConstraint.constant) * -1;
    
    NSArray *annotations = [self.MapView annotations];
   
    //[self.MapView showAnnotations:annotations animated:YES];
    //self.MapView.camera.altitude *= 1.4;
    _mapNeedsPadding = YES;
    [self.MapView showAnnotations:annotations animated:YES];
    
    if (self.MapSidePanelViewTrailingConstraint.constant == ViewWidth ) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             self.MapSidePanelViewTrailingConstraint.constant -= ViewWidth;
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished)
         {
             
             if (self.itinerarycollection.count > 0) {
             
                 double accumDistance = 0.0f;
                 double accumExpectedTime = 0;
                 for (JourneyRLM *item in self.itinerarycollection) {
                     
                     NSLog(@"%@ to %@ DISTANCE = %@",item.from.name, item.to.name, item.Distance);
                     
                     if (item.TransportId == [NSNumber numberWithInt:0] || item.TransportId == [NSNumber numberWithInt:0]) {
                         if (item.Distance != nil) {
                             accumDistance += [item.Distance doubleValue];
                             accumExpectedTime += [item.ExpectedTravelTime longValue];
                         }
                     }
                 }

                 NSMeasurementFormatter *formatter = [[NSMeasurementFormatter alloc] init];
                 formatter.locale = [NSLocale currentLocale];
                 NSNumberFormatter *numberformatter = [[NSNumberFormatter alloc] init];
                 [numberformatter setMaximumFractionDigits:1];
                 [formatter setNumberFormatter:numberformatter];
                 NSMeasurement *accumdistance = [[NSMeasurement alloc] initWithDoubleValue:accumDistance unit:NSUnitLength.meters];
                 
                 self.LabelMapTotalDistance.text = [NSString stringWithFormat:@"%@",[formatter stringFromMeasurement:accumdistance]];
                
                 
                 NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
                 dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
                 dateComponentsFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);

                 self.LabeMapTotalExpectedTime.text = [dateComponentsFormatter stringFromTimeInterval:accumExpectedTime];

                 CLLocationDegrees minLatitude = DBL_MAX;
                 CLLocationDegrees maxLatitude = -DBL_MAX;
                 CLLocationDegrees minLongitude = DBL_MAX;
                 CLLocationDegrees maxLongitude = -DBL_MAX;
                 
                 for (AnnotationMK *annotation in self.MapView.annotations) {
                     double annotationLat = annotation.coordinate.latitude;
                     double annotationLong = annotation.coordinate.longitude;
                     minLatitude = fmin(annotationLat, minLatitude);
                     maxLatitude = fmax(annotationLat, maxLatitude);
                     minLongitude = fmin(annotationLong, minLongitude);
                     maxLongitude = fmax(annotationLong, maxLongitude);
                 }
                 
                 
                 // See function below
                //[self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
             }

         }];
    } else {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             self.MapSidePanelViewTrailingConstraint.constant += ViewWidth;
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished)
         {
   
         }];
    }
    
}


/*
created date:       24/08/2019
last modified:      24/08/2019
remarks:
*/
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

    AnnotationMK *myAnnotation = (AnnotationMK*) view.annotation;
    NSString *originPoiKey = myAnnotation.PoiKey;
    ActivityRLM *originActivity = [ActivityRLM objectForPrimaryKey:myAnnotation.ActivityCompondKey];
    
    [self singlePointDistances:originPoiKey :originActivity];
    
}

/*
created date:       25/08/2019
last modified:      25/08/2019
remarks:            Generates list focused on active annotation on map and derives distances for each known
                    activity.  Obtains distance for each one.
*/
-(void) singlePointDistances :(NSString*) OriginPoiKey :(ActivityRLM*) OriginActivity {
          
    self.DistanceFromPointTableView.hidden = true;
    [self.LabelDistanceFromPoint setText:[NSString stringWithFormat:@"Distances from %@", OriginActivity.name]];
    [self.DistanceFromPointActivityIndicator startAnimating];
    self.DistanceFromPointFullView.hidden = false;
    [self.DistanceFromPointCloseButton setEnabled:FALSE];
    self.singlepointdistancecollection = [[NSMutableArray alloc] init];
      
      for (ActivityRLM *destinationActivity in self.activitycollection) {
          if (![destinationActivity.poikey isEqualToString:OriginPoiKey]) {
              JourneyRLM *item = [[JourneyRLM alloc] init];
              item.Route = [NSString stringWithFormat:@"%@",destinationActivity.name];
              item.from = OriginActivity;
              item.to = destinationActivity;
              [self.singlepointdistancecollection addObject:item];
          }
      }
    
     dispatch_group_t serviceGroup = dispatch_group_create();

     for (JourneyRLM *item in self.singlepointdistancecollection) {

         if ([item.Distance doubleValue] == 0.0f) {
             dispatch_group_enter(serviceGroup);
             [self calculateDistance:item :false completionHandler:^{
                 dispatch_group_leave(serviceGroup);
             }];
         }
     }

     dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{

         /* sort the list into ascending order - closest activity first */
         NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"Distance"
                                                         ascending:YES];
            
         NSArray *temp = [self.singlepointdistancecollection sortedArrayUsingDescriptors:@[sortDescriptor]];
         self.singlepointdistancecollection = [NSMutableArray arrayWithArray:temp];

         /* reload table view and display it. */
         [self.DistanceFromPointTableView reloadData];
         [self.DistanceFromPointActivityIndicator stopAnimating];
         [self.DistanceFromPointCloseButton setEnabled:TRUE];
         self.DistanceFromPointTableView.hidden = false;

     });
}



-(void) setMapRegionForMinLat:(double)minLatitude minLong:(double)minLongitude maxLat:(double)maxLatitude maxLong:(double)maxLongitude {
    
    MKCoordinateRegion region;
    region.center.latitude = (minLatitude + maxLatitude) / 2;
    region.center.longitude = (minLongitude + maxLongitude) / 2;
    region.span.latitudeDelta = (maxLatitude - minLatitude);
    region.span.longitudeDelta = (maxLongitude - minLongitude);
    
    // MKMapView BUG: this snaps to the nearest whole zoom level, which is wrong- it doesn't respect the exact region you asked for. See http://stackoverflow.com/questions/1383296/why-mkmapview-region-is-different-than-requested
    if (!(region.center.latitude == 0 && region.center.longitude == 0)) {
        [self.MapView setRegion:region animated:NO];
    }
}


/*
created date:       27/07/2019
last modified:      25/08/2019
remarks:
*/
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
    
    MKMarkerAnnotationView *pinView = (MKMarkerAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];

    if (!pinView) {
        pinView = [[MKMarkerAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"];
        
        pinView.canShowCallout = YES;
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton setImage:[UIImage systemImageNamed:@"target"] forState:UIControlStateNormal];

        pinView.rightCalloutAccessoryView = rightButton;
    } else {
        pinView.annotation = annotation;
    }

    pinView.tintColor = [UIColor colorNamed:@"TrippoColor"];
    pinView.markerTintColor = [UIColor colorNamed:@"TrippoColor"];
    return pinView;
}


/*
 created date:      24/07/2019
 last modified:     25/07/2019
 remarks:
 */
- (ActivityRLM*) obtainJourney :(NSArray *) children :(ActivityRLM *) lastActivity :(JENNode *) parentNode  {
    ActivityRLM *lastItem = lastActivity;
    
    self.SequenceCounter = 0;
    
    for (JENNode *node in children) {
        if (lastItem != nil) {
            if (lastItem.travelbackflag == [NSNumber numberWithLong:0] && node.activity.travelbackflag == [NSNumber numberWithLong:1] && ![lastItem.key isEqualToString:parentNode.activity.key]) {
                [self insertItinerary :lastItem :node.activity];
                
                lastItem = node.activity;
            } else if (node.activity.travelbackflag == [NSNumber numberWithLong:1] && ![lastItem.key isEqualToString:parentNode.activity.key]) {
                [self insertItinerary :lastItem :parentNode.activity];
                [self insertItinerary :parentNode.activity :node.activity];

                lastItem = node.activity;
            } else if (lastItem.travelbackflag == [NSNumber numberWithLong:1] && node.activity.travelbackflag == [NSNumber numberWithLong:0] && ![lastItem.key isEqualToString:parentNode.activity.key]) {
                [self insertItinerary :lastItem :parentNode.activity];
                [self insertItinerary :parentNode.activity :node.activity];

                lastItem = node.activity;
            }  else {
                [self insertItinerary :lastItem :node.activity];
                
                lastItem = node.activity;
            }
           
        }
        if (node.children.count > 0) {
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"startDt" ascending:YES];
            NSArray *sortedChildren = [node.children sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
            lastItem =  [self obtainJourney :sortedChildren :node.activity :node];
            if (node.activity.travelbackflag == [NSNumber numberWithLong:1]) {
                [self insertItinerary :lastItem :node.activity];
                [self insertItinerary :node.activity :parentNode.activity];

                lastItem = parentNode.activity;
            } else {
                [self insertItinerary :lastItem :node.activity];
                
                lastItem = node.activity;
            }
            
        } else {
            lastItem = node.activity;
        }
        
    }
    return lastItem;
}

/*
created date:      23/07/2019
last modified:     25/08/2019
remarks:           Calculate the journey while passing the tree.
*/
-(void) insertItinerary :(ActivityRLM*) activityFrom :(ActivityRLM*) activityTo {
    
    NSLog(@"%@ <-> %@", activityFrom.name, activityTo.name);
    
    self.SequenceCounter ++;
    
    if (activityFrom!=nil && activityTo!=nil) {
        JourneyRLM *item = [[JourneyRLM alloc] init];
        item.SequenceNo = [NSNumber numberWithInt:self.SequenceCounter];
        item.Route = [NSString stringWithFormat:@"%@ to %@",activityFrom.name, activityTo.name];
        if (activityTo.traveltransportid==nil) {
            item.TransportId = [NSNumber numberWithInt:0];
        } else {
            item.TransportId = activityTo.traveltransportid;
        }
        item.from = activityFrom;
        item.to = activityTo;
        [self.itinerarycollection addObject:item];
    }
}
   

/*
 created date:      23/07/2019
 last modified:     24/08/2019
 remarks:           Calculate the journey while passing the tree.
 */
- (IBAction)ButtonCalculateJourneyPressed:(id)sender {
    
    [self.JourneyActivityIndicator  setHidden:FALSE];
    [self.JourneyActivityIndicator  startAnimating];
    
    
    
    dispatch_group_t serviceGroup = dispatch_group_create();

    for (JourneyRLM *item in self.itinerarycollection) {
 
        //if ([item.Distance doubleValue] == 0.0f) {
            dispatch_group_enter(serviceGroup);
            
            [self calculateDistance:item :true completionHandler:^{
                dispatch_group_leave(serviceGroup);
            }];
            
        //}
    }

    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        
        [self.JourneyActivityIndicator  stopAnimating];
        [self.JourneyActivityIndicator  setHidden:TRUE];
        [self.ItineraryTableView reloadData];
        [self.ButtonCalculate setHidden:true];
        [self.ButtonUpdateTripStats setHidden:false];
        
    });
}


/*
created date:      23/07/2019
last modified:     05/03/2021
remarks:           Used by both the main itinerary listing that loads the map as well as the single point
                   distance called from the annotation 'Info' button inside the map.
*/
-(void) calculateDistance :(JourneyRLM *) item :(bool)UseMap  completionHandler:(void (^)(void))completionHandler {
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark *pmFrom  = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([item.from.poi.lat doubleValue], [item.from.poi.lon doubleValue]) addressDictionary:nil];
    MKMapItem *from = [[MKMapItem alloc] initWithPlacemark:pmFrom];

    MKPlacemark *pmTo  = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake([item.to.poi.lat doubleValue], [item.to.poi.lon doubleValue]) addressDictionary:nil];
    MKMapItem *to = [[MKMapItem alloc] initWithPlacemark:pmTo];
    
    request.source = from;
    request.destination = to;
    request.requestsAlternateRoutes = NO;

    if (item.TransportId==[NSNumber numberWithLong:1]) {
        request.transportType = MKDirectionsTransportTypeWalking;
    } else if (item.TransportId==[NSNumber numberWithLong:2] || item.TransportId==[NSNumber numberWithLong:3] || item.TransportId==[NSNumber numberWithLong:5]) {
        request.transportType = MKDirectionsTransportTypeTransit;
    } else if (item.TransportId==[NSNumber numberWithLong:0]) {
        request.transportType = MKDirectionsTransportTypeAutomobile;
    } else {
        request.transportType = MKDirectionsTransportTypeAny;
    }
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             NSLog(@"%@",[error localizedDescription]);
         } else {
             double Distance = 0.0f;
             long TravelTime = 0;
            
             for (MKRoute *route in response.routes)
             {
                 
                 Distance += route.distance;
                 TravelTime += (route.expectedTravelTime);
                 
                 route.polyline.subtitle = [NSString stringWithFormat:@"%lu",(unsigned long)route.transportType];

                 if (UseMap) {
                     [self.MapView
                  addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
                 }
             }

             dispatch_async(dispatch_get_main_queue(), ^(void){
                 
                 if (UseMap) {
                     CLLocationCoordinate2D Coord = CLLocationCoordinate2DMake([item.to.poi.lat doubleValue], [item.to.poi.lon doubleValue]);
                     
                     AnnotationMK *annotation = [[AnnotationMK alloc] init];
                     annotation.coordinate = Coord;
                     annotation.title = [NSString stringWithFormat:@"%@", item.to.name];
                     annotation.subtitle = [NSString stringWithFormat:@"<- %@",item.from.name];
                     annotation.Type = @"mappin";
                     annotation.PoiKey = item.to.poikey;
                     annotation.ActivityCompondKey = item.to.compondkey;
                     
                     [self.MapView addAnnotation:annotation];
                 }
                 item.Distance = [NSNumber numberWithDouble:Distance];
                 item.ExpectedTravelTime = [NSNumber numberWithLong:TravelTime];
             });
             dispatch_group_leave(group);
             
         }
     }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completionHandler) {
            completionHandler();
        }
    });
 
}


-(void) getTotalsForTrip {
    
    double accumDistance = 0.0f;
    double accumPetrolDistance = 0.0f;
    
    double accumExpectedTime = 0;
    
    self.itin = [self.itinerarycollection mutableCopy];
    for (JourneyRLM *item in self.itinerarycollection) {
        if (item.TransportId != [NSNumber numberWithLong:4] && item.TransportId != [NSNumber numberWithLong:6]) {
            if (item.Distance != nil) {
                if (item.TransportId == [NSNumber numberWithLong:0]) {
                    accumPetrolDistance += [item.Distance doubleValue];
                    item.AccumPetrolDistance = [NSNumber numberWithDouble:accumPetrolDistance];
                }
                accumDistance += [item.Distance doubleValue];
                accumExpectedTime += [item.ExpectedTravelTime longValue];
                item.AccumDistance = [NSNumber numberWithDouble:accumDistance];
                item.AccumExpectedTravelTime = [NSNumber numberWithDouble:accumExpectedTime];
            }
        }
    }
    
    [self.realm beginWriteTransaction];
    
    if (self.ActivityState == [NSNumber numberWithInteger:0]) {
        self.Trip.routeplannedcalculateddt = [NSDate date];
        self.Trip.routeplannedtotaltravelminutes = [NSNumber numberWithLong:accumExpectedTime];
        self.Trip.routeplannedtotaltraveldistance = [NSNumber numberWithDouble:accumDistance];
    } else {
        self.Trip.routeactualcalculateddt = [NSDate date];
        self.Trip.routeactualtotaltravelminutes = [NSNumber numberWithLong:accumExpectedTime];
        self.Trip.routeactualtotaltraveldistance = [NSNumber numberWithDouble:accumDistance];
    }
    [self.realm commitWriteTransaction];

}




/*
created date:      25/07/2019
last modified:     25/08/2019
remarks:
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.ItineraryTableView) {
        return [self.itinerarycollection count];
    } else {
        return [self.singlepointdistancecollection count];
    }
    
}

/*
 created date:      25/07/2019
 last modified:     24/08/2019
 remarks:
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (tableView == self.ItineraryTableView) {
        static NSString *IDENTIFIER = @"ItineraryCellId";
        
        ItineraryListCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
        if (cell == nil) {
            cell = [[ItineraryListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
        }

        JourneyRLM *journey = [self.itinerarycollection objectAtIndex:indexPath.row];
        cell.LabelRoute.text = journey.Route;
        
        
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:50 weight:UIImageSymbolWeightThin];
        
        [cell.TransportButton setContentMode:UIViewContentModeScaleAspectFit];
        
        
        if (journey.TransportId  == [NSNumber numberWithLong:1]) {
            [cell.TransportButton setImage:[UIImage systemImageNamed:@"figure.walk" withConfiguration:config] forState:UIControlStateNormal];
        } else if (journey.TransportId  == [NSNumber numberWithLong:2]) {
            [cell.TransportButton setImage:[UIImage systemImageNamed:@"bus.doubledecker.fill" withConfiguration:config] forState:UIControlStateNormal];
        } else if (journey.TransportId  == [NSNumber numberWithLong:3]) {
            [cell.TransportButton setImage:[UIImage systemImageNamed:@"tram" withConfiguration:config] forState:UIControlStateNormal];
        } else if (journey.TransportId  == [NSNumber numberWithLong:4]) {
            [cell.TransportButton setImage:[UIImage systemImageNamed:@"airplane" withConfiguration:config] forState:UIControlStateNormal];
        } else if (journey.TransportId  == [NSNumber numberWithLong:5]) {
            [cell.TransportButton setImage:[UIImage systemImageNamed:@"helm" withConfiguration:config] forState:UIControlStateNormal];
            //[cell.TransportButton setImage:[UIImage systemImageNamed:@"s.circle" withConfiguration:config] forState:UIControlStateNormal];
        } else if (journey.TransportId  == [NSNumber numberWithLong:6]) {
            [cell.TransportButton setImage:[UIImage systemImageNamed:@"bicycle" withConfiguration:config] forState:UIControlStateNormal];
        } else {
            [cell.TransportButton setImage:[UIImage systemImageNamed:@"car" withConfiguration:config] forState:UIControlStateNormal];
        }
        
        
        NSArray *subArray = [self.itinerarycollection subarrayWithRange:NSMakeRange(0, indexPath.row + 1)];
        
        double accum = 0.0f;
        double accumExpectedTime = 0;
        for (JourneyRLM *item in subArray) {
            if (item.TransportId != [NSNumber numberWithLong:4] && item.TransportId != [NSNumber numberWithLong:6]) {
                accum += [item.Distance doubleValue];
                accumExpectedTime += [item.ExpectedTravelTime longValue];
            }
        }
        
        NSMeasurementFormatter *formatter = [[NSMeasurementFormatter alloc] init];
        formatter.locale = [NSLocale currentLocale];
        NSNumberFormatter *numberformatter = [[NSNumberFormatter alloc] init];
        [numberformatter setMaximumFractionDigits:1];
        [formatter setNumberFormatter:numberformatter];

        NSMeasurement *distance = [[NSMeasurement alloc] initWithDoubleValue:[journey.Distance doubleValue] unit:NSUnitLength.meters];

        NSMeasurement *accumdistance = [[NSMeasurement alloc] initWithDoubleValue:accum unit:NSUnitLength.meters];
        
        cell.LabelDistance.text = [NSString stringWithFormat:@"%@",[formatter stringFromMeasurement:distance]];

        cell.LabelAccumDistance.text = [NSString stringWithFormat:@"%@",[formatter stringFromMeasurement:accumdistance]];
        
        NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
        dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        dateComponentsFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
        
        cell.LabelExpectedTravelTime.text = [dateComponentsFormatter stringFromTimeInterval:[journey.ExpectedTravelTime doubleValue]];
        cell.LabelAccumExpectedTravelTime.text = [dateComponentsFormatter stringFromTimeInterval:accumExpectedTime];
        
        __weak typeof(cell) weakCell = cell;
        
        cell.transportButtonTapHandler = ^{
            /*here*/
            
            NSLog(@"%@",journey);
            
            if ([journey.TransportId longValue] < 6)  {
                journey.TransportId = [NSNumber numberWithLong:[journey.TransportId longValue] + 1];
            } else {
                journey.TransportId = [NSNumber numberWithLong:0];
            }
            
            [weakCell.TransportButton setContentMode:UIViewContentModeScaleAspectFit];
            
            UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:50 weight:UIImageSymbolWeightThin];
            
            if (journey.TransportId  == [NSNumber numberWithLong:1]) {
                [weakCell.TransportButton setImage:[UIImage systemImageNamed:@"figure.walk" withConfiguration:config] forState:UIControlStateNormal];
            } else if (journey.TransportId  == [NSNumber numberWithLong:2]) {
                [weakCell.TransportButton setImage:[UIImage systemImageNamed:@"bus.doubledecker.fill" withConfiguration:config] forState:UIControlStateNormal];
            } else if (journey.TransportId  == [NSNumber numberWithLong:3]) {
                [weakCell.TransportButton setImage:[UIImage systemImageNamed:@"tram" withConfiguration:config] forState:UIControlStateNormal];
            } else if (journey.TransportId  == [NSNumber numberWithLong:4]) {
                [weakCell.TransportButton setImage:[UIImage systemImageNamed:@"airplane" withConfiguration:config] forState:UIControlStateNormal];
            } else if (journey.TransportId  == [NSNumber numberWithLong:5]) {
                [weakCell.TransportButton setImage:[UIImage systemImageNamed:@"helm"
                withConfiguration:config] forState:UIControlStateNormal];
            } else if (journey.TransportId  == [NSNumber numberWithLong:6]) {
                [weakCell.TransportButton setImage:[UIImage systemImageNamed:@"bicycle" withConfiguration:config] forState:UIControlStateNormal];
            } else {
                [weakCell.TransportButton setImage:[UIImage systemImageNamed:@"car" withConfiguration:config] forState:UIControlStateNormal];
            }
            
            self.ButtonCalculate.hidden = false;
            
            NSLog(@"Comment Button Tapped");
        };
        return cell;
        
    } else {
        
        /* load just the distance and title */
        static NSString *IDENTIFIER = @"DistanceFromPointCellId";
        
        DistanceFromPointCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
        if (cell == nil) {
            cell = [[DistanceFromPointCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
        }

        JourneyRLM *journey = [self.singlepointdistancecollection objectAtIndex:indexPath.row];
        cell.labelTitle.text = journey.Route;
        
        NSMeasurementFormatter *formatter = [[NSMeasurementFormatter alloc] init];
        formatter.locale = [NSLocale currentLocale];
        NSNumberFormatter *numberformatter = [[NSNumberFormatter alloc] init];
        [numberformatter setMaximumFractionDigits:1];
        [formatter setNumberFormatter:numberformatter];
        
        NSMeasurement *distance = [[NSMeasurement alloc] initWithDoubleValue:[journey.Distance doubleValue] unit:NSUnitLength.meters];
        
        cell.LabelDistance.text = [NSString stringWithFormat:@"%@",[formatter stringFromMeasurement:distance]];
        
        
        NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
        dateComponentsFormatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
        dateComponentsFormatter.allowedUnits = (NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
        
        cell.LabelExpectedTravelTime.text = [dateComponentsFormatter stringFromTimeInterval:[journey.ExpectedTravelTime doubleValue]];
        
        return cell;
        
    }
    
   
}

/*
 created date:      25/07/2019
 last modified:     25/07/2019
 remarks:
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
        [renderer setLineWidth:2.5];
        return renderer;
    }
    return nil;
}

- (IBAction)ShowMapAnnotationsPressed:(id)sender {
    NSArray *annotations = [self.MapView annotations];
    //NSLog(@"%@",annotations);
    self.HideMapAnnotations = !self.HideMapAnnotations;
    AnnotationMK *annotation = nil;
    for (int i=0; i<[annotations count]; i++) {
        annotation = (AnnotationMK*)[annotations objectAtIndex:i];
        if (![annotation isKindOfClass:[MKUserLocation class]]) {
            [[self.MapView viewForAnnotation:annotation] setHidden: self.HideMapAnnotations];
        }
    }
}

- (IBAction)UpdateTripStatsPressed:(id)sender {
    [self getTotalsForTrip];
    [self.ButtonUpdateTripStats setHidden:TRUE];
}


/*
created date:      24/08/2019
last modified:     24/08/2019
remarks:           Usual back button
*/
- (IBAction)DistanceFromPointCloseButtonPressed:(id)sender {
    self.DistanceFromPointFullView.hidden = true;
}






@end
