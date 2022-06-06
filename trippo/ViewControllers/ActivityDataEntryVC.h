//
//  ActivityDataEntryVC.h
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "ActivityNSO.h"
#import "PoiListCell.h"
#import "PoiImageNSO.h"
#import "ImagePickerVC.h"
#import "DirectionsVC.h"
#import "PaymentListingVC.h"
#import "HCSStarRatingView.h"
#import "ImageNSO.h"
#import "ActivityImageCell.h"
#import "TOCropViewController.h"
#import "TextFieldDatePicker.h"
#import "OptionButton.h"
#import "AttachmentCell.h"
#import "AttachmentRLM.h"
#import "SettingsVC.h"
#import "AssistantRLM.h"
#import "DocumentsVC.h"
#import "PoiPreviewVC.h"
#import <WebKit/WebKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@protocol ActivityDataEntryDelegate <NSObject>
- (void)didUpdateActivityImages :(bool) ForceUpdate;
@end

@interface ActivityDataEntryVC : UIViewController <UISearchBarDelegate, UITableViewDelegate, MKMapViewDelegate, DirectionsDelegate, PaymentListingDelegate, DocumentsDelegate, UITextViewDelegate,UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImagePickerDelegate, UIScrollViewDelegate, TOCropViewControllerDelegate, PoiPreviewDelegate, UIScrollViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic) UIImage *PoiImage;
@property (assign) bool newitem;
@property (assign) bool transformed;
@property (assign) bool deleteitem;
@property (assign) bool fromproject;
@property (assign) int imagestate;
@property (nonatomic) NSString *SelectedImageReference;
@property (nonatomic) NSString *SelectedImageKey;
@property (nonatomic) NSNumber *SelectedImageIndex;
@property (nonatomic, weak) id <ActivityDataEntryDelegate> delegate;
@property ActivityRLM *Activity;
@property PoiRLM *Poi;
@property PoiRLM *MyCurrentPosition;
@property TripRLM *Trip;
@property RLMRealm *realm;
@property (strong, nonatomic) NSMutableDictionary *ActivityImageDictionary;

@property (strong, nonatomic) NSMutableArray *DocumentCollection;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewPoi;
@property (weak, nonatomic) IBOutlet MKMapView *PoiMapView;
@property (weak, nonatomic) IBOutlet MKMapView *NotificationMapView;

@property (weak, nonatomic) IBOutlet UIView *ViewStateIndicator;
@property (weak, nonatomic) IBOutlet UILabel *LabelStateIndicator;
@property (weak, nonatomic) IBOutlet UIView *ViewSettingsStateIndicator;
@property (weak, nonatomic) IBOutlet UILabel *LabelSettingsStateIndicator;
@property (weak, nonatomic) IBOutlet UILabel *LabelActivityName;

@property (weak, nonatomic)  UITextField *ActiveTextField;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldName;
@property (weak, nonatomic) IBOutlet UITextView *TextViewNotes;
@property (weak, nonatomic) UITextView *ActiveTextView;
@property (weak, nonatomic) IBOutlet UIButton *ButtonAction;
@property (weak, nonatomic) IBOutlet UILabel *LabelStartDT;
@property (weak, nonatomic) IBOutlet UILabel *LabelEndDT;
@property (weak, nonatomic) IBOutlet UIView *ViewCheckInOut;
@property (weak, nonatomic) IBOutlet UIButton *ButtonCheckInOut;

@property (weak, nonatomic) IBOutlet UIDatePicker *DatePickerStartDt;
@property (weak, nonatomic) IBOutlet UIDatePicker *DatePickerEndDt;

@property (weak, nonatomic) IBOutlet UIButton *ButtonDirections;
@property (weak, nonatomic) IBOutlet UIButton *ButtonPayment;
@property (weak, nonatomic) IBOutlet UIButton *ButtonWebsite;


@property (weak, nonatomic) IBOutlet UIButton *ButtonCancel;
@property (weak, nonatomic) IBOutlet UIButton *ButtonScan;

@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentPresenter;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewActivityClass;
@property (weak, nonatomic) IBOutlet UIView *ViewMain;
@property (weak, nonatomic) IBOutlet UIView *ViewNotes;
@property (weak, nonatomic) IBOutlet UIView *ViewPhotos;
@property (weak, nonatomic) IBOutlet UIView *ViewDocuments;
@property (weak, nonatomic) IBOutlet UITableView *TableViewAttachments;
@property (weak, nonatomic) IBOutlet WKWebView *WebViewPreview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ImageViewIdeaWidthConstraint;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *ViewStarRating;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ViewEffectBlurDetailHeightConstraint;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *ViewBlurImageOptionPanel;
@property (weak, nonatomic) IBOutlet UICollectionView *CollectionViewActivityImages;
@property (weak, nonatomic) IBOutlet UISwitch *SwitchViewPhotoOptions;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ViewBlurHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *ViewTrash;
@property (weak, nonatomic) IBOutlet UIView *ViewSelectedKey;
@property (weak, nonatomic) IBOutlet UIImageView *ImagePicture;
@property (weak, nonatomic) IBOutlet UIScrollView *ScrollViewImage;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewKeyActivity;
@property (weak, nonatomic) IBOutlet UIButton *ButtonUploadImage;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldReference;
@property (nonatomic, strong)IBOutlet TextFieldDatePicker  *TextFieldStartDt;
@property (nonatomic, strong)IBOutlet TextFieldDatePicker  *TextFieldEndDt;
@property (nonatomic, strong)IBOutlet UILabel  *LabelDuration;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *ViewBackground;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ConstraintBottomNotes;
@property (weak, nonatomic) IBOutlet UIButton *ButtonExpandCollapseList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ViewDocumentListHeightConstraint;
@property (weak, nonatomic) IBOutlet UISwitch *SwitchTweet;
@property (weak, nonatomic) IBOutlet UIView *ViewSettings;
@property (assign) int toggleNotifyArrivingFlag;
@property (assign) int toggleNotifyLeavingFlag;
@property (weak, nonatomic) IBOutlet UIButton *ButtonArriving;
@property (weak, nonatomic) IBOutlet UIButton *ButtonLeaving;
@property (weak, nonatomic) IBOutlet UILabel *LabelGeoWarningNotice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *GeoWarningLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *MainImageTrailingConstraint;
@property (weak, nonatomic) IBOutlet UIButton *ButtonKey;
@property (weak, nonatomic) IBOutlet UIButton *ButtonDelete;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *WikiViewHeightConstraint;
@property (strong, nonatomic)  CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIScrollView *ActivityScrollView;
@property (weak, nonatomic) IBOutlet UIView *ActivityScrollViewContent;

@property (weak, nonatomic) IBOutlet UITextField *StartDtTimeZoneNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *EndDtTimeZoneNameTextField;
@property (nonatomic, strong)IBOutlet UIPickerView *StartDtTimeZonePicker;
@property (nonatomic, strong)IBOutlet UIPickerView *EndDtTimeZonePicker;
@property (nonatomic, strong)IBOutlet UIDatePicker *datePicker;
@property (nonatomic) NSDate *startDt;
@property (nonatomic) NSDate *endDt;
@property NSArray *timezones;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewStateIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewSettingsStateIndicator;
@property (weak, nonatomic) IBOutlet UILabel *labelPhotoInfo;
@property (weak, nonatomic) IBOutlet UIButton *ButtonEditPhotoInfo;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewDateRangeStatus;

@property (weak, nonatomic) IBOutlet UILabel *labelDateRangeStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelConflictedActivity;

@end

