//
//  SettingsVC.h
//  travelme
//
//  Created by andrew glew on 23/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <Realm/Realm.h>
#import "SettingsRLM.h"
#import "AssistantRLM.h"
#import "AppDelegate.h"
#import "NotificationCell.h"
#import "NotificationNSO.h"

@protocol SettingsDelegate <NSObject>
@end

@interface SettingsVC : UIViewController <UITextFieldDelegate, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *ButtonUpdateSharedAlbum;
@property (weak, nonatomic) IBOutlet UIButton *ButtonBack;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldNickName;
@property (nonatomic, weak) id <SettingsDelegate> delegate;
@property (strong, nonatomic) SettingsRLM *Settings;
@property (strong, nonatomic) RLMRealm *realm;
@property (weak, nonatomic) IBOutlet UIView *ViewUserName;
@property (weak, nonatomic) IBOutlet UITableView *TableViewOpenNotifications;
@property (strong, nonatomic) NSMutableArray *notifications;
@property (weak, nonatomic) IBOutlet UIView *ViewTwitterLogIn;
@property (weak, nonatomic) IBOutlet UIButton *ButtonDismissAllPendingNotifications;

@end
