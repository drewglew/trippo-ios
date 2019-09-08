//
//  TravelPlanVC.h
//  trippo
//
//  Created by andrew glew on 19/07/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "TripRLM.h"
#import "ToolBoxNSO.h"
#import "JENTreeView.h"
#import "NodeNSO.h"
#import "JourneyItemNSO.h"
#import "ItineraryListCell.h"
#import "DistanceFromPointCell.h"
#import <MapKit/MapKit.h>
#import "SettingsRLM.h"
#import "ItineraryRLM.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TravelPlanDelegate <NSObject>
@end

@interface TravelPlanVC : UIViewController <JENTreeViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate>
@property (nonatomic, weak) id <TravelPlanDelegate> delegate;
@property RLMRealm *realm;
@property TripRLM *Trip;

@property (strong, nonatomic) NSMutableArray *activitycollection;
@property (strong, nonatomic) NSMutableArray *excludedlisting;
@property (strong, nonatomic) NSMutableArray *itinerarycollection;
@property (strong, nonatomic) NSMutableArray *itin;

@property (strong, nonatomic) NSMutableDictionary *ActivityImageDictionary;
@property (weak, nonatomic) IBOutlet JENTreeView *treeview;
@property (nonatomic) UIImage *TripImage;
@property (nonatomic) NSNumber *ActivityState;
@property ItineraryRLM *Itinerary;


@property (weak, nonatomic) IBOutlet UIStepper *StepperScale;
@property (weak, nonatomic) IBOutlet UIView *ViewStateIndicator;
@property (weak, nonatomic) IBOutlet UILabel *LabelStateIndicator;

@property (weak, nonatomic) IBOutlet UILabel *LabelTripTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *JourneySidePanelViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIView *JorneySidePanelView;
@property (weak, nonatomic) IBOutlet UIButton *ButtonJourneySideButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ButtonTabWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *JourneySidePanelFullWidthConstraint;

@property (weak, nonatomic) IBOutlet UIView *MapSidePanelView;
@property (weak, nonatomic) IBOutlet UIButton *ButtonMapSideButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *MapSidePanelViewTrailingConstraint;
@property (nonatomic) NSString *NodeSelectedActivityKey;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *MapSidePanelFullWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ButtonMapTabWidthConstraint;
@property (weak, nonatomic) IBOutlet MKMapView *MapView;
@property (weak, nonatomic) IBOutlet UILabel *LabelMapTotalDistance;
@property (weak, nonatomic) IBOutlet UILabel *LabeMapTotalExpectedTime;

@property (weak, nonatomic) IBOutlet UITableView *ItineraryTableView;
@property (assign) double AccumDistance;
@property (assign) double SequenceCounter;
@property (weak, nonatomic) IBOutlet UIButton *ButtonUpdateTripStats;
@property (weak, nonatomic) IBOutlet UIButton *ButtonCalculate;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *JourneyActivityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewStateIndicator;

@property (weak, nonatomic) IBOutlet UIView *DistanceFromPointFullView;

@property (weak, nonatomic) IBOutlet UITableView *DistanceFromPointTableView;
@property (strong, nonatomic) NSMutableArray *singlepointdistancecollection;

-(void) singlePointDistances :(NSString*) OriginPoiKey :(ActivityRLM*) OriginActivity;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *DistanceFromPointActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *LabelDistanceFromPoint;
@property (weak, nonatomic) IBOutlet UIButton *DistanceFromPointCloseButton;

@end

NS_ASSUME_NONNULL_END
