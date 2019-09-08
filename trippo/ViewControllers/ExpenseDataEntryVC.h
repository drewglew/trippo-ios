//
//  ExpenseDataEntryVC.h
//  trippo
//
//  Created by andrew glew on 07/04/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextFieldDatePicker.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "ExchangeRateRLM.h"
#import "PaymentRLM.h"
#import "ActivityRLM.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ExpenseDetailDelegate <NSObject>
@end

@interface ExpenseDataEntryVC : UIViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *ViewExpensePopup;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldExpenseDescription;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldExpenseAmount;
@property (weak, nonatomic) IBOutlet TextFieldDatePicker *TextFieldCurrency;
@property (weak, nonatomic) IBOutlet UIButton *ButtonRequestLatest;
@property (weak, nonatomic) IBOutlet UIButton *ButtonUpdate;
@property (weak, nonatomic) IBOutlet TextFieldDatePicker *TextFieldRateDate;
@property (nonatomic, strong)IBOutlet UIDatePicker *datePickerRate;
@property (nonatomic, strong)IBOutlet UIPickerView *currencyPicker;
@property (weak, nonatomic) IBOutlet UIButton *ButtonUseLastFoundrate;
@property (weak, nonatomic) IBOutlet UISegmentedControl *SegmentExpenseType;
@property (weak, nonatomic) IBOutlet UILabel *LabelHomeAmount;
@property (nonatomic) NSString *HomeCurrencyCode;
@property (nonatomic) NSString *SelectedCurrencyCode;
@property (nonatomic) NSString *TitleText;
@property ActivityRLM *ActivityItem;
@property PaymentRLM *ExpenseItem;
@property ExchangeRateRLM *ActiveExchangeRate;
@property ExchangeRateRLM *DuplicateCurrenciesExchangeRate;


@property RLMRealm *realm;
@property (assign) bool newitem;
@property (strong, nonatomic) NSMutableArray *currencies;
@property (weak, nonatomic) IBOutlet UILabel *LabelExrate;
@property (weak, nonatomic) IBOutlet UILabel *LabelTitle;
@property (nonatomic, weak) id <ExpenseDetailDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
