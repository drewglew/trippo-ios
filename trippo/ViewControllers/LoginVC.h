//
//  LoginVC.h
//  trippo
//
//  Created by andrew glew on 24/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "TripRLM.h"
#import "MenuVC.h"

@interface LoginVC : UIViewController <MenuDelegate> 
@property (weak, nonatomic) IBOutlet UITextField *TextFieldUserName;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldPassword;
@property (weak, nonatomic) IBOutlet UISwitch *SwitchRememberAccount;
@property (weak, nonatomic) IBOutlet UIButton *ButtonLogin;
@property (weak, nonatomic) IBOutlet UILabel *LabelInfo;
@property (weak, nonatomic) IBOutlet UIButton *ButtonRegisterNew;

@end
