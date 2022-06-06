//
//  ActivityDataEntryVC.h
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ActivityNSO.h"
#import "PoiNSO.h"
#import "PoiListCell.h"
#import "ActivityDataEntryVC.h"
#import "PoiDataEntryVC.h"
#import "ProjectNSO.h"
#import "LocatorVC.h"
#import "NearbyListingVC.h"
#import "TypeNSO.h"
#import "TypeCell.h"
#import "TripRLM.h"
#import "PoiRLM.h"
#import "ActivityRLM.h"
#import "SettingsVC.h"
#import "PoiMapVC.h"


@protocol PoiSearchDelegate <NSObject>
- (void)didUpdateActivityImages :(bool) ForceUpdate;
- (void)didDismissPresentingViewController;
@end

@interface PoiSearchVC : UIViewController <UISearchBarDelegate, UITableViewDelegate, ActivityDataEntryDelegate, LocatorDelegate, PoiDataEntryDelegate, NearbyListingDelegate, PoiMapDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *SearchBarPoi;
@property (weak, nonatomic) IBOutlet UITableView *TableViewSearchPoiItems;
@property (strong, nonatomic) NSMutableArray *poiitems;

@property (strong, nonatomic) NSMutableArray *poifiltereditems;
@property (strong, nonatomic) NSMutableArray *countries;
@property (assign) bool newitem;
@property (assign) bool transformed;
@property (assign) bool isSearching;
@property (assign) bool frommenu;
@property (assign) bool applypoitypefilterfromsettings;
@property (nonatomic, weak) id <PoiSearchDelegate> delegate;

@property (strong, nonatomic) ActivityRLM *Activity;
@property (strong, nonatomic) ProjectNSO *Project;
@property (strong, nonatomic) PoiNSO *PointOfInterest;

@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentPoiFilterList;

@property (weak, nonatomic) IBOutlet UILabel *LabelCounter;
@property (weak, nonatomic) IBOutlet UIButton *ButtonBack;
@property (weak, nonatomic) IBOutlet UIButton *ButtonNew;
@property (weak, nonatomic) IBOutlet UIButton *ButtonFilter;
@property (weak, nonatomic) IBOutlet UIButton *ButtonResetFilter;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentCountries;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FilterOptionHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *ViewFooterButtons;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *VisEffectViewFooter;

@property (strong, nonatomic) NSArray *TypeItems;
@property (strong, nonatomic) NSMutableArray *PoiTypes;
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionViewTypes;

@property RLMRealm *realm;
@property RLMResults<PoiRLM *> *poifilteredcollection;

@property TripRLM *TripItem;
@property SettingsRLM *settings;
@property PoiRLM *PoiItem;
@property ActivityRLM *ActivityItem;
@end
