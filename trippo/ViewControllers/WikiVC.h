//
//  WikiVC.h
//  travelme
//
//  Created by andrew glew on 13/06/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "PoiNSO.h"
#import "AppDelegate.h"
#import "CountryNSO.h"
#import "Reachability.h"
#import "PoiRLM.h"

@protocol WikiGeneratorDelegate <NSObject>
- (void)updatePoiFromWikiActvity :(PoiRLM*)PointOfInterest;
@end

@interface WikiVC : UIViewController <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property PoiRLM *PointOfInterest;
@property (nonatomic, weak) id <WikiGeneratorDelegate> delegate;
@property (nonatomic) NSNumber *gsradius;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentLanguageOption;
@property (weak, nonatomic) IBOutlet UIButton *ButtonBack;
@property (weak, nonatomic) IBOutlet UIButton *ButtonSearchByLocation;
@property (weak, nonatomic) IBOutlet UIButton *ButtonSearchByName;
@property (weak, nonatomic) IBOutlet UILabel *LabelInfo;
@property (weak, nonatomic) IBOutlet UILabel *LabelWaitingStatus;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ActivityIndicator;
@property (weak, nonatomic) IBOutlet UIView *ViewLoading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FooterWithSegmentConstraint;

@end
