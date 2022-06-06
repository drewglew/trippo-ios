//
//  LocatorVC.h
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PoiDataEntryVC.h"
#import "PoiNSO.h"
#import "PoiImageNSO.h"
#import "SearchResultListCell.h"
#import "AnnotationMK.h"
#import "ProjectNSO.h"
#import "Reachability.h"

#import "PoiRLM.h"

@protocol LocatorDelegate <NSObject>
- (void)didCreatePoiFromProjectPassThru :(PoiRLM*)Object;
- (void)didUpdatePoi :(NSString*)Method :(PoiRLM*)Object;
@end

@interface LocatorVC : UIViewController <UISearchBarDelegate, UITableViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate> {
    MKMapView *MapView;
}
@property (weak, nonatomic) IBOutlet MKMapView *MapView;
@property (weak, nonatomic) IBOutlet UISearchBar *SearchBar;
@property (strong, nonatomic) PoiRLM *PointOfInterest;
@property (strong, nonatomic) PoiRLM *TempPoi;
@property (strong, nonatomic) TripRLM *TripItem;
@property (strong, nonatomic) ActivityRLM *ActivityItem;
@property RLMRealm *realm;
@property (nonatomic, readwrite) CLLocationCoordinate2D Coordinates;
@property (assign) bool fromproject;
@property (assign) bool firstactivityinproject;
@property (nonatomic, weak) id <LocatorDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *TableViewSearchResult;
@property (strong, nonatomic)  CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIButton *ButtonBack;
@property (weak, nonatomic) IBOutlet UIButton *ButtonClear;
@property (weak, nonatomic) IBOutlet UIButton *ButtonNext;
@property (weak, nonatomic) IBOutlet UIButton *ButtonSkip;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewGlobe;

@property (weak, nonatomic) IBOutlet UILabel *LabelWarningNoInet;

@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentMapType;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentLongPressMode;



@end
