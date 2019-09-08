//
//  ScheduleCV.h
//  travelme
//
//  Created by andrew glew on 05/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduleCell.h"
#import "AppDelegate.h"
#import "DirectionsVC.h"
#import "TripRLM.h"
#import "TextFieldDatePicker.h"
#import "ToolBoxNSO.h"

@protocol ScheduleListDelegate <NSObject>
@end

@interface ScheduleVC : UIViewController <UITableViewDelegate, DirectionsDelegate>
@property (weak, nonatomic) IBOutlet UITableView *TableViewScheduleItems;
@property (strong, nonatomic) NSMutableArray *scheduleitems;
@property (strong, nonatomic) NSMutableArray *activityitems;
@property (nonatomic) NSNumber *ActivityState;
@property (nonatomic, weak) id <ScheduleListDelegate> delegate;
@property (strong, nonatomic) ProjectNSO *Project;
@property TripRLM *Trip;
@property RLMRealm *realm;
@property (assign) int level;
@property (assign) int MaxNbrOfHierarcyLevels;
@property (weak, nonatomic) IBOutlet UILabel *labelHeader;
@property (weak, nonatomic) IBOutlet UILabel *LabelItemCounter;
@property (strong, nonatomic) NSMutableDictionary *ActivityImageDictionary;
@property (weak, nonatomic) IBOutlet UIButton *ButtonBack;
@property (weak, nonatomic) IBOutlet UIButton *ButtonReset;
@property (weak, nonatomic) IBOutlet UIButton *ButtonDirections;
// below are used exclusively in the date picker input view
@property (nonatomic, strong)IBOutlet UIDatePicker *datePicker;
@property (nonatomic, strong)IBOutlet UITextField  *TextFieldDt;
@property (nonatomic, strong)IBOutlet UILabel  *LabelDuration;
@end
