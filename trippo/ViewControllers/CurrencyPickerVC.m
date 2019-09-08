//
//  CurrencyPickerVC.m
//  travelme
//
//  Created by andrew glew on 08/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "CurrencyPickerVC.h"

@interface CurrencyPickerVC ()

@end

@implementation CurrencyPickerVC

/*
 created date:      08/08/2018
 last modified:     19/09/2018
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.currencies = [[NSMutableArray alloc] init];
    
    // Do any additional setup after loading the view.
    NSInteger row = 0;
    NSInteger selectedRow = 0;
    NSLocale *locale = [NSLocale currentLocale];
    for (NSString *code in [NSLocale commonISOCurrencyCodes]) {

        if ([[locale displayNameForKey:NSLocaleCurrencyCode value:code] rangeOfString:@"("].location == NSNotFound) {
            NSString *currencysymbol = @"";
            /* only display symbol if it exists */
            if (![code isEqualToString:[locale displayNameForKey:NSLocaleCurrencySymbol value:code]]) {
                currencysymbol = [NSString stringWithFormat:@"(%@)", [locale displayNameForKey:NSLocaleCurrencySymbol value:code]];
            }
            [self.currencies addObject:[NSString stringWithFormat:@"%@ - %@ %@", code, [locale displayNameForKey:NSLocaleCurrencyCode value:code], currencysymbol]];
            if ([code isEqualToString:self.SelectedCurrencyCode]) {
                selectedRow = row;
            }
            row ++;
        }
    }
    
    self.PickerCurrencies.delegate = self;
    self.PickerCurrencies.dataSource = self;
    
    [self.PickerCurrencies setValue:[UIColor colorWithRed:100.0f/255.0f green:245.0f/255.0f blue:1.0f/255.0f alpha:1.0] forKey:@"textColor"];
    
    [self.PickerCurrencies selectRow:selectedRow inComponent:0 animated:YES];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.currencies.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.currencies objectAtIndex:row];//Or, your suitable title; like Choice-a, etc.
}




/*
 created date:      08/08/2018
 last modified:     08/08/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}
/*
 created date:      08/08/2018
 last modified:     08/08/2018
 remarks:
 */
- (IBAction)CurrencySelected:(id)sender {
    NSString *selectedCurrencyDetail = [self.currencies objectAtIndex:[self.PickerCurrencies selectedRowInComponent:0]];
    [self.delegate didPickCurrency :[selectedCurrencyDetail substringToIndex:3]];
    [self dismissViewControllerAnimated:YES completion:Nil];
}
/*
 created date:      08/08/2018
 last modified:     08/08/2018
 remarks:
 */
- (void)didPickCurrency :(NSString*)CurrencyCode {
    
}




@end
