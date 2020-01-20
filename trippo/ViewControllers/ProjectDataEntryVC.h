//
//  ProjectDataEntry.h
//  travelme
//
//  Created by andrew glew on 29/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "ProjectNSO.h"
#import "AppDelegate.h"
#import "ToolBoxNSO.h"
#import <Realm/Realm.h>
#import "TripRLM.h"
#import "ActivityRLM.h"
#import "ImageCollectionRLM.h"
#import "TextFieldDatePicker.h"
#import <MapKit/MapKit.h>
#import "AnnotationMK.h"
#import "Reachability.h"
#import "WeatherRLM.h"
#import "PaymentListingVC.h"
#import "SettingsRLM.h"


@protocol ProjectDataEntryDelegate <NSObject>
@end

@interface ProjectDataEntryVC : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate,UITextFieldDelegate, MKMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, PaymentListingDelegate>

@property (strong, nonatomic) ProjectNSO *Project;
@property TripRLM *Trip;
@property (weak, nonatomic) IBOutlet UIView *ViewProjectImage;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewProject;
@property (weak, nonatomic) IBOutlet UITextView *TextViewNotes;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldName;
@property (weak, nonatomic)  UITextField *ActiveTextField;
@property (weak, nonatomic) UITextView *ActiveTextView;
@property (assign) bool newitem;
@property (assign) bool loadedActualWeatherData;
@property (assign) bool loadedPlannedWeatherData;
@property (assign) bool updatedimage;
@property RLMRealm *realm;
@property (weak, nonatomic) IBOutlet UIButton *ButtonAction;
@property (weak, nonatomic) IBOutlet UIButton *ButtonEditImage;
@property (weak, nonatomic) IBOutlet UILabel *LabelInfo;
@property (weak, nonatomic) IBOutlet UIButton *ButtonBack;
@property (weak, nonatomic) IBOutlet UIButton *ButtonUploadImage;
@property (weak, nonatomic) IBOutlet UILabel *LabelFlags;
@property (weak, nonatomic) IBOutlet UILabel *LabelEstCalcTitle;
@property (weak, nonatomic) IBOutlet UILabel *LabelActCalcTitle;
@property (weak, nonatomic) IBOutlet UILabel *LabelEstCalcDist;
@property (weak, nonatomic) IBOutlet UILabel *LabelActCalcDist;
@property (weak, nonatomic) IBOutlet UILabel *LabelEstCalcTravelTime;
@property (weak, nonatomic) IBOutlet UILabel *LabelActCalcTravelTime;
@property (nonatomic, strong)IBOutlet UIDatePicker *datePicker;
@property (nonatomic) NSDate *startDt;
@property (nonatomic) NSDate *endDt;
//@property (nonatomic, strong)IBOutlet UIDatePicker *datePickerEnd;
@property (weak, nonatomic) IBOutlet TextFieldDatePicker *TextFieldStartDt;
@property (weak, nonatomic) IBOutlet TextFieldDatePicker *TextFieldEndDt;
@property (weak, nonatomic) IBOutlet UIView *ViewSummary;
@property (weak, nonatomic) IBOutlet MKMapView *MapView;
@property NSMutableArray *AnnotationCollection;
@property NSMutableArray *WeatherActualAnnotationCollection;
@property NSMutableArray *WeatherPlannedAnnotationCollection;
@property NSArray *timezones;
@property (nonatomic, strong)IBOutlet UIPickerView *StartDtTimeZonePicker;
@property (nonatomic, strong)IBOutlet UIPickerView *EndDtTimeZonePicker;
@property (nonatomic, strong)IBOutlet UIPickerView *DefaultDtTimeZonePicker;
@property (nonatomic, weak) id <ProjectDataEntryDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentAnnotations;
@property (weak, nonatomic) IBOutlet UILabel *LabelWeatherLastUpdatedAt;
@property (weak, nonatomic) IBOutlet UIScrollView *TripScrollView;
@property (weak, nonatomic) IBOutlet UIView *TripScrollViewContent;
@property (weak, nonatomic) IBOutlet UITextField *StartDtTimeZoneNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *EndDtTimeZoneNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *DefaultTimeZoneNameTextField;



@end
