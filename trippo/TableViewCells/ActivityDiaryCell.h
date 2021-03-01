//
//  ActivityDiaryCell.h
//  trippo-app
//
//  Created by andrew glew on 20/02/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextFieldDatePicker.h"
#import "ActivityRLM.h"
#import "ToolboxNSO.h"
NS_ASSUME_NONNULL_BEGIN

@interface ActivityDiaryCell : UITableViewCell 
@property (weak, nonatomic) IBOutlet UIButton *ButtonDelete;
@property (weak, nonatomic) IBOutlet TextFieldDatePicker *TextFieldStartDt;
@property (weak, nonatomic) IBOutlet TextFieldDatePicker *TextFieldEndDt;

@property (weak, nonatomic) IBOutlet UILabel *LabelName;
@property (strong, nonatomic) ActivityRLM *activity;
@property (strong, nonatomic) UIDatePicker * datePicker;
@property (nonatomic) NSDate *startDt;
@property (nonatomic) NSDate *endDt;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewTypeOfPoi;
@property (weak, nonatomic) IBOutlet UIView *ViewPoiType;
@property (weak, nonatomic) IBOutlet UIView *ViewExpenseFlag;

@property (weak, nonatomic) IBOutlet UIDatePicker *DatePickerStart;
@property (weak, nonatomic) IBOutlet UIDatePicker *DatePickerEnd;

@property (nonatomic) NSString *defaultTimeZone;
@property (strong, nonatomic) UIToolbar * datePickerToolbar;
@property (strong, nonatomic) NSIndexPath *indexPathForCell;
@property (weak, nonatomic) IBOutlet UIView *CellBorder;
@property (weak, nonatomic) IBOutlet UIView *DurationView;
@property (weak, nonatomic) IBOutlet UILabel *LabelDuration;
@property (weak, nonatomic)  UITextField *ActiveDtTextField;

@end

NS_ASSUME_NONNULL_END
