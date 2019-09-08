//
//  PaymentListCell.h
//  travelme
//
//  Created by andrew glew on 09/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *LabelDescription;
@property (weak, nonatomic) IBOutlet UILabel *LabelHomeAmt;
@property (weak, nonatomic) IBOutlet UILabel *LabelHomeCurrencyCode;
@property (weak, nonatomic) IBOutlet UILabel *LabelLocalAmt;
@property (weak, nonatomic) IBOutlet UILabel *LabelLocalCurrencyCode;
@property (weak, nonatomic) IBOutlet UILabel *LabelHomeAmtEst;
@property (weak, nonatomic) IBOutlet UILabel *LabelLocalAmtEst;
@property (weak, nonatomic) IBOutlet UILabel *LabelHomeCurrencyCodeEst;
@property (weak, nonatomic) IBOutlet UILabel *LabelLocalCurrencyCodeEst;
@property (nonatomic) NSNumber *homeAmount;
@end
