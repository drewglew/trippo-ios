//
//  PoiDataEntryVC.h
//  travelme
//
//  Created by andrew glew on 28/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Photos/Photos.h>
#import "AppDelegate.h"
#import "ToolBoxNSO.h"
#import "PoiImageCell.h"
#import "PoiImageNSO.h"
#import "PoiNSO.h"
#import "ActivityRLM.h"
#import "ImagePickerVC.h"
#import "ImageNSO.h"
#import "WikiVC.h"
#import "Reachability.h"
#import "TypeNSO.h"
#import "TypeCell.h"
#import "HCSStarRatingView.h"
#import "PoiRLM.h"
#import "TripRLM.h"
#import "SettingsRLM.h"
#import "TOCropViewController.h"
#import "AnnotationMK.h"
#import "ActivityDataEntryVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CloudKit/CloudKit.h>


@protocol PoiDataEntryDelegate <NSObject>
- (void)didCreatePoiFromProject :(PoiRLM*)Object;
- (void)didUpdatePoi :(NSString*)Method :(PoiRLM*)Object;
@end


@interface PoiDataEntryVC : UIViewController<UICollectionViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MKMapViewDelegate, ImagePickerDelegate, WikiGeneratorDelegate, UIScrollViewDelegate, UITextViewDelegate,UITextFieldDelegate, CLLocationManagerDelegate, TOCropViewControllerDelegate, ActivityDataEntryDelegate>

@property (nonatomic, readwrite) CLLocationCoordinate2D Coordinates;
@property (nonatomic) NSString *Title;
@property (nonatomic) NSString *WikiMainImageDescription;
@property (nonatomic) NSNumber *SelectedImageIndex;
@property (nonatomic) NSString *SelectedImageKey;
@property (assign) bool newitem;
@property (assign) bool imagesupdated;
@property (assign) bool readonlyitem;
@property (assign) bool fromproject;
@property (assign) bool fromnearby;
@property (assign) bool haswikimainimage;
@property (assign) int imagestate;

@property (weak, nonatomic) IBOutlet UICollectionView *CollectionViewPoiImages;
@property (strong, nonatomic) NSMutableDictionary *PoiImageDictionary;
@property (strong, nonatomic) PoiRLM *PointOfInterest;
@property PoiRLM *MyCurrentPosition;
@property (strong, nonatomic) TripRLM *TripItem;
@property (strong, nonatomic) ActivityRLM *ActivityItem;
@property RLMRealm *realm;
@property (strong, nonatomic) NSArray *TypeItems;

@property (strong, nonatomic) NSMutableArray *CategoryItems;
@property (strong, nonatomic) NSArray *TypeLabelItems;
@property (strong, nonatomic) NSArray *TypeDistanceItems;
@property (strong, nonatomic) NSArray *DistancePickerItems;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldTitle;
@property (weak, nonatomic) IBOutlet UITextView *TextViewNotes;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldWebsite;

@property (weak, nonatomic)  UITextField *ActiveTextField;
@property (weak, nonatomic) UITextView *ActiveTextView;

// only used on preview controller
@property (weak, nonatomic) IBOutlet MKMapView *MapView;
@property (strong, nonatomic) MKCircle *CircleRange;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentDetailOption;
@property (weak, nonatomic) IBOutlet UIImageView *ImagePicture;
@property (weak, nonatomic) IBOutlet UILabel *LabelPrivateNotes;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewKey;
@property (weak, nonatomic) IBOutlet UILabel *LabelPoi;
@property (nonatomic, weak) id <PoiDataEntryDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIPickerView *PickerType;
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionViewTypes;
@property (weak, nonatomic) IBOutlet UIView *ViewMain;
@property (weak, nonatomic) IBOutlet UIView *ViewNotes;
@property (weak, nonatomic) IBOutlet UIView *ViewMap;
@property (weak, nonatomic) IBOutlet UIView *ViewPhotos;
@property (weak, nonatomic) IBOutlet UIView *ViewInfo;

@property (weak, nonatomic) IBOutlet UIView *ViewTrash;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *ViewBlurImageOptionPanel;
@property (weak, nonatomic) IBOutlet UIButton *ButtonKey;
@property (weak, nonatomic) IBOutlet UIView *ViewSelectedKey;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ViewBlurHeightConstraint;
@property (weak, nonatomic) IBOutlet UISwitch *SwitchViewPhotoOptions;
@property (weak, nonatomic) IBOutlet UIButton *ButtonWiki;
@property (weak, nonatomic) IBOutlet UIButton *ButtonUpdate;
@property (weak, nonatomic) IBOutlet UIButton *ButtonCancel;
@property (weak, nonatomic) IBOutlet UIButton *ButtonGeo;

@property CGPoint translation;
@property (weak, nonatomic) IBOutlet UIScrollView *ScrollViewImage;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ViewStarRatings;
@property (weak, nonatomic) IBOutlet UILabel *LabelOccurances;
@property (weak, nonatomic) IBOutlet UILabel *LabelPhotoInfo;
@property (weak, nonatomic) IBOutlet UIButton *ButtonSharePoi;
@property (weak, nonatomic) IBOutlet UIButton *ButtonScan;
@property (strong, nonatomic) IBOutlet UIImage *WikiMainImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ContraintBottomNotes;
@property (weak, nonatomic) IBOutlet UILabel *LabelInfoName;
@property (weak, nonatomic) IBOutlet UILabel *LabelInfoCreatedDt;
@property (weak, nonatomic) IBOutlet UILabel *LabelInfoLastModified;
@property (weak, nonatomic) IBOutlet UILabel *labelInfoAuthorName;
@property (weak, nonatomic) IBOutlet UILabel *LabelInfoSharedBy;
@property (weak, nonatomic) IBOutlet UILabel *LabelInfoSharedDt;
@property (weak, nonatomic) IBOutlet UILabel *LabelInfoSharedDevice;
@property (strong, nonatomic) SettingsRLM *Settings;
@property (weak, nonatomic) IBOutlet UIButton *ButtonMapUpdate;
@property (weak, nonatomic) IBOutlet UIButton *ButtonMapRevert;
@property (weak, nonatomic) IBOutlet UIPickerView *PickerDistance;
@property (weak, nonatomic) IBOutlet UIView *ViewDistancePicker;
@property (weak, nonatomic) IBOutlet UISwitch *SwitchWeather;
@property (weak, nonatomic) IBOutlet UIButton *ButtonRoute;
@property (strong, nonatomic)  CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIScrollView *PoiScrollView;
@property (weak, nonatomic) IBOutlet UIView *PoiScrollViewContent;
@property (weak, nonatomic) IBOutlet UILabel *LabelImageOptions;
@property (strong, nonatomic) UISelectionFeedbackGenerator *feedback;
@property (weak, nonatomic) IBOutlet UIButton *ButtonDeleteImage;
@property (weak, nonatomic) IBOutlet UIButton *ButtonEditPhotoInfo;

@end
