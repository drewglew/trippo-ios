//
//  PaymentListingVC.h
//  travelme
//
//  Created by andrew glew on 08/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityNSO.h"
#import "ProjectNSO.h"
#import "PaymentDataEntryVC.h"
#import "ExpenseDataEntryVC.h"
#import "PaymentNSO.h"
#import "AppDelegate.h"
#import "PaymentListCell.h"
#import "PoiImageNSO.h"
#import "PaymentRLM.h"
#import "TripRLM.h"
#import "SettingsRLM.h"
#import "AssistantRLM.h"

@protocol PaymentListingDelegate <NSObject>
@end

@interface PaymentListingVC : UIViewController <PaymentDetailDelegate, ExpenseDetailDelegate>
@property (weak, nonatomic) IBOutlet UITableView *TableViewPayment;
@property (weak, nonatomic) IBOutlet UILabel *LabelTitle;
@property (strong, nonatomic) NSMutableArray *paymentitems;
@property (strong, nonatomic) NSArray *localcurrencyitems;
@property (strong, nonatomic) NSNumber *activitystate;
@property (strong, nonatomic) NSString *headerImageReference;
@property (strong, nonatomic) NSMutableArray *paymentsections;
@property (strong, nonatomic) UIImage *headerImage;

@property ActivityRLM *ActivityItem;
@property TripRLM *TripItem;
@property RLMResults<PaymentRLM*>*ExpenseCollection;
@property RLMRealm *realm;

@property (nonatomic, weak) id <PaymentListingDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *ImageView;
@property (weak, nonatomic) IBOutlet UIButton *ButtonAction;
@property (weak, nonatomic) IBOutlet UILabel *LabelTripPrice;
@property (weak, nonatomic) IBOutlet UILabel *LabelTripAmount;
@property (weak, nonatomic) IBOutlet UIView *ViewTripAmount;

@property (weak, nonatomic) IBOutlet UIButton *ButtonBack;
@property (weak, nonatomic) IBOutlet UIButton *ButtonNew;


@end
