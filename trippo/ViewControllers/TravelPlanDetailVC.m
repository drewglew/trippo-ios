//
//  TravelPlanDetailVC.m
//  trippo
//
//  Created by andrew glew on 21/07/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import "TravelPlanDetailVC.h"

@interface TravelPlanDetailVC ()

@end

@implementation TravelPlanDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ViewPopup.layer.cornerRadius=8.0f;
    self.ViewPopup.layer.masksToBounds=YES;
    self.ViewPopup.layer.borderWidth = 1.0f;
    self.ViewPopup.layer.borderColor = [[UIColor colorNamed:@"TrippoColor"]CGColor];
    
    [self.ImageViewActivity setImage:self.ActivityImage];
    self.LabelActvityName.text = self.Activity.name;
    
    self.TextFieldDateFrom.text = [NSString stringWithFormat:@"%@", [ToolBoxNSO FormatPrettyDate :self.Activity.startdt]];
    self.TextFieldDateTo.text = [NSString stringWithFormat:@"%@", [ToolBoxNSO FormatPrettyDate :self.Activity.enddt]];
    
}

/*
 created date:      21/07/2019
 last modified:     21/07/2019
 remarks:           Usual back button
 */
- (IBAction)BackPressed:(id)sender {
    
     [self dismissViewControllerAnimated:YES completion:Nil];
}

@end
