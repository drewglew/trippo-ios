//
//  CurrencyPickerVC.h
//  travelme
//
//  Created by andrew glew on 08/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CurrencyPickerDelegate <NSObject>
- (void)didPickCurrency :(NSString*)CurrencyCode;
@end
@interface CurrencyPickerVC : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *PickerCurrencies;
@property (strong, nonatomic) NSMutableArray *currencies;
@property (nonatomic) NSString *SelectedCurrencyCode;
@property (nonatomic, weak) id <CurrencyPickerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *ButtonCancel;
@property (weak, nonatomic) IBOutlet UIButton *ButtonSelect;



@end
