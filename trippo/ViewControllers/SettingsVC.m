//
//  SettingsVC.m
//  travelme
//
//  Created by andrew glew on 23/08/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "SettingsVC.h"
#import <TwitterKit/TWTRLogInButton.h>
@interface SettingsVC ()

@end

@implementation SettingsVC

/*
 created date:      23/08/2018
 last modified:     16/03/2019
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.TextFieldNickName.delegate = self;

    
    if (self.Settings!=nil) {
        self.TextFieldNickName.text = self.Settings.username;
    }
    
    self.ViewUserName.layer.cornerRadius = 5;
    self.ViewUserName.layer.masksToBounds = true;

    
    //self.TextFieldNickName.layer.borderWidth = 1.0f;
    //self.TextFieldNickName.layer.borderColor = [UIColor colorNamed:@"TrippoColor"].CGColor;

    
    TWTRLogInButton *logInButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {

            NSLog(@"Logged in as %@",[session userName]);
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
    
    [self.ViewTwitterLogIn addSubview:logInButton];
    
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
- (IBAction)UpdateSharedAlbumButtonPressed:(id)sender {
    
    __block PHFetchResult *photosAsset;
    __block PHAssetCollection *collection;
    __block PHObjectPlaceholder *placeholder;
    
    // Find the album
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"title = %@", @"YOUR_ALBUM_TITLE"];
    collection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum
                                                          subtype:PHAssetCollectionSubtypeAny
                                                          options:fetchOptions].firstObject;
    // Create the album
    if (!collection)
    {
        
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *createAlbum = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"YOUR_ALBUM_TITLE"];
            placeholder = [createAlbum placeholderForCreatedAssetCollection];
        } completionHandler:^(BOOL success, NSError *error) {
            if (success)
            {
                PHFetchResult *collectionFetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[placeholder.localIdentifier]
                                                                                                            options:nil];
                collection = collectionFetchResult.firstObject;
            }
        }];
    }
    
    
    UIImage *testImage = [UIImage systemImageNamed:@"command"];
    
    // Save to the album
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:testImage];
        placeholder = [assetRequest placeholderForCreatedAsset];
        photosAsset = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection
                                                                                                                      assets:photosAsset];
        [albumChangeRequest addAssets:@[placeholder]];
    } completionHandler:^(BOOL success, NSError *error) {
        if (success)
        {
           
            
           
           // photo.assetURL = [NSString stringWithFormat:@"assets-library://asset/asset.PNG?id=%@&ext=JPG", UUID];
            //[self savePhoto];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }];
    
    
}


- (IBAction)BackButtonPressed:(id)sender {
     [self dismissViewControllerAnimated:YES completion:Nil];
    
}

- (IBAction)LogoutButton:(id)sender {
    
    NSDictionary<NSString *, RLMSyncUser *> *allUsers = [RLMSyncUser allUsers];

    if (allUsers.count==1) {
        RLMSyncUser *user = [RLMSyncUser currentUser];
        [user logOut];
    }
    
    
    
}

-(BOOL) textFieldShouldReturn: (UITextField *) textField {
    [textField resignFirstResponder];
    return YES;
}


/*
 created date:      19/02/2019
 last modified:     19/02/2019
 remarks:
 */
- (IBAction)ActionButtonPressed:(id)sender {
    
    if ([self.TextFieldNickName.text isEqualToString:@""]) {
    
    } else {
        if (self.Settings == nil) {
            self.Settings = [[SettingsRLM alloc] init];
            self.Settings.userkey = [[NSUUID UUID] UUIDString];
            self.Settings.username = self.TextFieldNickName.text;
            self.Settings.TripCellColumns = [NSNumber numberWithInt:3];
            self.Settings.ActivityCellColumns = [NSNumber numberWithInt:3];
            self.Settings.NodeScale = [NSNumber numberWithInt:60];
            
            [self.realm beginWriteTransaction];
            [self.realm addObject:self.Settings];
            [self.realm commitWriteTransaction];
            
        } else {
            [self.Settings.realm beginWriteTransaction];
            self.Settings.username = self.TextFieldNickName.text;
            if (self.Settings.TripCellColumns == nil) {
                self.Settings.TripCellColumns = [NSNumber numberWithInt:3];
                self.Settings.ActivityCellColumns = [NSNumber numberWithInt:3];
                self.Settings.NodeScale = [NSNumber numberWithInt:60];
            }
            [self.Settings.realm commitWriteTransaction];
        }
        [self dismissViewControllerAnimated:YES completion:Nil];
    }
    
}


/*
 created date:      26/03/2019
 last modified:     26/03/2019
 remarks:
 */
- (IBAction)DismissAllPendingNotificationsPressed:(id)sender {
    
    [AppDelegateDef.UserNotificationCenter removeAllPendingNotificationRequests];
    
    /*
    [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> *requests){
        NSLog(@"requests: %@", requests);
        for (UNNotificationRequest *object in requests) {
            NSString *identifier = object.identifier;
            NSArray *activityNotification = [NSArray arrayWithObjects:identifier, nil];
                                             
            [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:activityNotification];
        }
        NSLog(@"Completed! removed ");
        
        // TODO add message box here.
        
    }];
    */
}


@end
