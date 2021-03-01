//
//  LoginVC.m
//  trippo
//
//  Created by andrew glew on 24/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC ()

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)LoginPressed:(id)sender {
   
     NSURL *authURL = [NSURL URLWithString:@"https://incredible-wooden-hat.de1a.cloud.realm.io"];
    
    
    if ([self.TextFieldUserName.text isEqualToString:@""] || [self.TextFieldPassword.text isEqualToString:@""]) {
        
    } else {
        /*
        for (RLMSyncUser *user in RLMSyncUser.allUsers) {
            [user logOut];
        }
        */
        RLMSyncCredentials *usernameCredentials = [RLMSyncCredentials credentialsWithUsername:self.TextFieldUserName.text password:self.TextFieldPassword.text register:NO];
        [RLMSyncUser logInWithCredentials:usernameCredentials
                            authServerURL:authURL
                             onCompletion:^(RLMSyncUser *user, NSError *error) {
                                 if (user) {
    
                                     // can now open a synchronized RLMRealm with this user
                                     RLMRealmConfiguration *config = [user configuration];

                                     [RLMRealm asyncOpenWithConfiguration:config
                                                            callbackQueue:dispatch_get_main_queue()
                                                                 callback:^(RLMRealm *realm, NSError *error) {
                                                                     if (realm) {
                                                                         self.LabelInfo.text = @"Success!";
                                                                        
                                                                         NSURL *syncServerURL = [NSURL URLWithString: @"realms://incredible-wooden-hat.de1a.cloud.realm.io/~/trippo"];
                                                                         
                                                                         RLMRealmConfiguration.defaultConfiguration = [user configurationWithURL:syncServerURL fullSynchronization:YES];
                                                                         
                                                                         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                         MenuVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
                                                                         controller.delegate = self;
                                                                         controller.realm = realm;
                                                                         [controller setModalPresentationStyle:UIModalPresentationPageSheet];
                                                                         [self presentViewController:controller animated:YES completion:nil];
                                                                         
                                                                     }
                                                                     
                                                                     
                                                                 }];
                                     
                                 } else if (error) {
                                     self.LabelInfo.text = @"Error authenticating user!";
                                     // handle error
                                 }
                             }];

        NSLog(@"%@", usernameCredentials);
        

        
    }
}


- (IBAction)RegisterPressed:(id)sender {
    NSURL *authURL = [NSURL URLWithString:@"https://incredible-wooden-hat.de1a.cloud.realm.io"];
    
    
    
    if ([self.TextFieldUserName.text isEqualToString:@""] || [self.TextFieldPassword.text isEqualToString:@""]) {
        
    } else {
    
    RLMSyncCredentials *usernameCredentials = [RLMSyncCredentials credentialsWithUsername:self.TextFieldUserName.text
                                                                                 password:self.TextFieldPassword.text
                                                                                 register:YES];
    
    [RLMSyncUser logInWithCredentials:usernameCredentials
                            authServerURL:authURL
                             onCompletion:^(RLMSyncUser *user, NSError *error) {
                                if (user) {
                                     // can now open a synchronized RLMRealm with this user
                                     RLMRealmConfiguration *config = [user configuration];
                                     
                                     [RLMRealm asyncOpenWithConfiguration:config
                                                            callbackQueue:dispatch_get_main_queue()
                                                                 callback:^(RLMRealm *realm, NSError *error) {
                                     if (realm) {
                                         self.LabelInfo.text = @"Success!";
                                         NSURL *syncServerURL = [NSURL URLWithString: @"realms://incredible-wooden-hat.de1a.cloud.realm.io/~/trippo"];
                                         
                                         RLMRealmConfiguration.defaultConfiguration = [user configurationWithURL:syncServerURL fullSynchronization:YES];
                                         
                                         UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                         MenuVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
                                         controller.delegate = self;
                                         controller.realm = realm;
                                         [controller setModalPresentationStyle:UIModalPresentationPageSheet];
                                         [self presentViewController:controller animated:YES completion:nil];
                                         
                                     }
                                }];
                                     
                            } else if (error) {
                                self.LabelInfo.text = @"Error registering user!";
                                // handle error
                            }
                        }];
        
    }

}

/*
 created date:      29/08/2018
 last modified:     29/08/2018
 remarks:
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.TextFieldPassword endEditing:YES];
    [self.TextFieldUserName endEditing:YES];
}

@end
