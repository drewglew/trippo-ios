//
//  ImagePickerVC.h
//  travelme
//
//  Created by andrew glew on 10/06/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Photos/Photos.h>
#import "PoiNSO.h"
#import "ImageCollectionCell.h"
#import "ImageNSO.h"
#import "ToolBoxNSO.h"
#import "PoiRLM.h"
#import "OptionButton.h"

@protocol ImagePickerDelegate <NSObject>
- (void)didAddImages :(NSMutableArray*)ImageCollection;
@end

@interface ImagePickerVC : UIViewController<UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {
    NSThread *queueThread;
}

@property (weak, nonatomic) IBOutlet UICollectionView *ImageCollectionView;
@property (strong, nonatomic) NSMutableArray *imageitems;
@property (nonatomic, readwrite) CGSize ImageSize;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ActivityLoading;
@property (nonatomic, retain) IBOutlet UILabel *LabelPhotoCounter;
@property (weak, nonatomic) IBOutlet ImageCollectionCell *CellContent;

@property (weak, nonatomic) IBOutlet UILabel *LabelPoiName;
@property (strong, nonatomic) NSMutableDictionary *PoiImageDictionary;
@property (nonatomic) NSNumber *distance;
@property (assign) bool wikiimages;
@property (strong, nonatomic) PoiRLM *PointOfInterest;
@property (nonatomic, weak) id <ImagePickerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *ButtonCancel;
@property (weak, nonatomic) IBOutlet UIButton *ButtonSelect;
@property (weak, nonatomic) IBOutlet OptionButton *ButtonStopSearching;
@property (weak, nonatomic) IBOutlet UISwitch *SwitchHighQuality;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *VisualEffectViewWaiting;
@property (weak, nonatomic) IBOutlet UILabel *LabelWaitingMessage;
@property (weak, nonatomic) IBOutlet UIView *ViewLoading;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FooterWithTextConstraint;


@end
