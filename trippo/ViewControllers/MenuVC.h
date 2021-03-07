//
//  MenuVC.h
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PoiSearchVC.h"
#import "ProjectListVC.h"
#import "ProjectDataEntryVC.h"
#import "ActivityListVC.h"
#import "PoiNSO.h"
#import "LocatorVC.h"
#import "PoiDataEntryVC.h"
#import "NearbyListingVC.h"
#import "SettingsRLM.h"
#import "SettingsVC.h"
#import "AssistantRLM.h"
#import "Reachability.h"
#import <CloudKit/CloudKit.h>

#include <stdlib.h>

@protocol MenuDelegate <NSObject>
@end

@interface MenuVC : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, ProjectListDelegate, ProjectDataEntryDelegate, ActivityListDelegate, LocatorDelegate, PoiDataEntryDelegate, NearbyListingDelegate, SettingsDelegate, MKMapViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *ButtonProject;
@property (weak, nonatomic) IBOutlet UIButton *ButtonPoi;
@property (weak, nonatomic) IBOutlet UIButton *ButtonInfo;
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionViewPreviewPanel;
@property (strong, nonatomic) RLMResults *alltripitems;
@property (strong, nonatomic) NSMutableArray *selectedtripitems;
@property (weak, nonatomic) IBOutlet UIButton *ButtonSettings;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewFeaturedPoi;
//@property (weak, nonatomic) IBOutlet UILabel *LabelFeaturedPoi;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *LabelFeaturedPoiHeader;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *LabelFeaturedSharedPoi;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *LabelFeaturedSharedPoiHeader;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *LabelFeaturedPoi;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewSharedFeaturedPoi;



@property (nonatomic, weak) id <MenuDelegate> delegate;
@property (strong, nonatomic) RLMRealm *realm;
@property (assign) bool SetReload;
@property (strong, nonatomic) PoiRLM *FeaturedPoi;
@property (strong, nonatomic) PoiRLM *FeaturedSharedPoi;
@property (strong, nonatomic) SettingsRLM *Settings;
@property (strong, nonatomic) NSMutableDictionary *TripImageDictionary;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ActivityView;
@property(nonatomic,strong) UIAlertAction *okAction;

@property (weak, nonatomic) IBOutlet UIImageView *ImageViewPoi;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewTrip;
@property (weak, nonatomic) IBOutlet MKMapView *FeaturedPoiMap;
@property (weak, nonatomic) IBOutlet UIView *ViewRegisterWarning;
@property (weak, nonatomic) IBOutlet UIView *MainSurface;
@property (weak, nonatomic) IBOutlet UIButton *ButtonFeaturedPoi;
@property (weak, nonatomic) IBOutlet UIButton *ButtonSharedFeaturedPoi;

@property (weak, nonatomic) IBOutlet UIButton *ButtonAllTrips;
@property (strong, nonatomic) IBOutlet UIView *AssistantView;
@property (weak, nonatomic) IBOutlet UIButton *ButtonSharedPoiCloudDownload;




@end
