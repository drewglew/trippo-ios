//
//  AppDelegate.m
//  travelme
//
//  Created by andrew glew on 27/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "AppDelegate.h"
#import <Realm/Realm.h>
#import "MenuVC.h"
//#import "LoginVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize databasename;
@synthesize twitterSecretKey;
@synthesize twitterConsumerKey;

/*
 created date:      27/04/2018
 last modified:     16/06/2019
 remarks:
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLocale *theLocale = [NSLocale currentLocale];
    self.HomeCurrencyCode = [theLocale objectForKey:NSLocaleCurrencyCode];
    self.HomeCountryCode = [theLocale objectForKey:NSLocaleCountryCode];
    self.MeasurementSystem = [theLocale objectForKey:NSLocaleMeasurementSystem];
    self.MetricSystem = [theLocale objectForKey:NSLocaleUsesMetricSystem];
    self.poiitems = [[NSMutableArray alloc] init];
    /* countries / language dictionary */
    
    self.CountryDictionary = [[NSMutableDictionary alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"country" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    for (NSDictionary *country in dict) {
        NSString *CountryCode = [country objectForKey:@"alpha2Code"];
        NSArray *Languages = [country objectForKey:@"languages"];
        NSString *LanguageCode = @"";
        if (Languages.count>0) {
            for (NSDictionary *language in Languages) {
                LanguageCode = [language objectForKey:@"iso639_1"];
                //NSLog(@"%@-%@",LanguageCode,CountryCode);
                break;
            }
            if (CountryCode != nil && LanguageCode != nil) {
                [self.CountryDictionary setObject:LanguageCode forKey:CountryCode];
            }
        }
    }
    
    self.UserNotificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    
    self.UserNotificationCenter.delegate = self;
    
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;

    UNNotificationAction *checkinAction = [UNNotificationAction actionWithIdentifier:@"CheckIn" title:@"Check In" options:UNNotificationActionOptionNone];
    
    UNNotificationAction *checkoutAction = [UNNotificationAction actionWithIdentifier:@"CheckOut" title:@"Check Out" options:UNNotificationActionOptionNone];
    
    UNNotificationAction *deleteAction = [UNNotificationAction actionWithIdentifier:@"Dismiss"
                                                                              title:@"Dismiss" options:UNNotificationActionOptionDestructive];
    
    UNNotificationAction *IgnoreAction = [UNNotificationAction actionWithIdentifier:@"Ignore"
                                                                              title:@"Ignore - we'll resend" options:UNNotificationActionOptionNone ];
    
    
    
    
    UNNotificationCategory *checkinCategory = [UNNotificationCategory categoryWithIdentifier:@"CheckInCategory"
                                                                              actions:@[checkinAction,IgnoreAction,deleteAction] intentIdentifiers:@[]
                                                                              options:UNNotificationCategoryOptionNone];
    
    UNNotificationCategory *checkoutCategory = [UNNotificationCategory categoryWithIdentifier:@"CheckOutCategory"
                                                                                     actions:@[checkoutAction,IgnoreAction, deleteAction] intentIdentifiers:@[]
                                                                                     options:UNNotificationCategoryOptionNone];
    
    NSSet *categories = [NSSet setWithObjects:checkinCategory, checkoutCategory, nil];
    
    [self.UserNotificationCenter setNotificationCategories:categories];
    
    
    
    [self.UserNotificationCenter requestAuthorizationWithOptions:options
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (!granted) {
                                  NSLog(@"Something went wrong");
                              }
                          }];

    /*
     Migration block - to use if we change the model..
    */
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = 23;
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) { };
    [RLMRealmConfiguration setDefaultConfiguration:config];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    NSLog(@"%f,%f",UIScreen.mainScreen.bounds.size.height,UIScreen.mainScreen.bounds.size.width);
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MenuVC *menu = [storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    
    //self.window.backgroundColor = [UIColor whiteColor];
    
    self.PoiBackgroundImageDictionary = [[NSMutableDictionary alloc] init];
    
    menu.realm = realm;
    
    self.window.rootViewController = menu;
    
    
    self.window.hidden = false;
    [self.window makeKeyAndVisible];
    
    return YES;
}

/*
-(void) InitRealm :(NSURL*) url {
    self.PoiBackgroundImageDictionary = [[NSMutableDictionary alloc] init];
    
    [RLMSyncManager sharedManager].errorHandler = ^(NSError *error, RLMSyncSession *session) {
        NSLog(@"A global error has occurred! %@", error);
    };
    
    NSDictionary<NSString *, RLMSyncUser *> *allUsers = [RLMSyncUser allUsers];
    
    if (allUsers.count==1) {
        
        NSURL *syncURL = [NSURL URLWithString:@"realms://incredible-wooden-hat.de1a.cloud.realm.io/~/trippo"];
        RLMRealmConfiguration.defaultConfiguration = [RLMSyncUser.currentUser configurationWithURL:syncURL fullSynchronization:YES];
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MenuVC *menu = [storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
        
        menu.realm = realm;
        self.window.rootViewController = menu;
        [self.window makeKeyAndVisible];
    }
    else {
        
        self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginVC *login = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        self.window.rootViewController = login;
        [self.window makeKeyAndVisible];
    }
    
}
*/

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

/*
 created date:      29/04/2018
 last modified:     16/03/2019
 remarks:
 */
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    
    if (url) {
        NSURLSession *session = [NSURLSession sharedSession];
        
        [[session dataTaskWithURL:url
                completionHandler:^(NSData *data,
                                    NSURLResponse *response,
                                    NSError *error) {
                    
                    if(!error) {
                
                        NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
                        
                        NSString *ext = [[url lastPathComponent] pathExtension];
                        if ([[ext uppercaseString] isEqualToString:@"PDF"]) {
                            
                            [self ProcessPdfFile :data :url];
                            
                        } else {
                            documentsURL = [documentsURL URLByAppendingPathComponent:@"ImportedPoi.trippo"];
                            [data writeToURL:documentsURL atomically:YES];
                            [self ProcessImportFile];
                        }
                
                    } else {
                        NSLog(@"%@",error.userInfo);
                    }
                }] resume];
    }
    return YES;
}



- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


/*
 created date:      24/02/2019
 last modified:     08/09/2019
 remarks:           A means of importing PDF's into the App.  Feature will be made available within the App to preview and manage these.
 */
-(bool) ProcessPdfFile:(NSData*) PdfData :(NSURL*) url{
    


    NSString *PdfOriginalFileName = [url.absoluteString lastPathComponent];



    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Importing PDF Document"
                                                                   message:@"Please amend the file name, so you can identify it when attaching to a Point of Interest or an Activity."
                                                            preferredStyle:UIAlertControllerStyleAlert];

    
    
    
    [alertController.view setTintColor:[UIColor labelColor]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
         [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
             // optionally configure the text field
             textField.text = PdfOriginalFileName;
             textField.keyboardType = UIKeyboardTypeAlphabet;
         }];
    });
   

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         UITextField *textField = [alertController.textFields firstObject];

                                                        NSURL *pdfDocumentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];


                                                        pdfDocumentsURL = [pdfDocumentsURL URLByAppendingPathComponent:@"/PdfImportedDocs/"];

                                                         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                                         NSString *pdfDirectory = [paths objectAtIndex:0];
                                                         NSString *dataPath = [pdfDirectory stringByAppendingPathComponent:@"/PdfImportedDocs"];
                                                         [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
                                                         
                                                        

                                                        RLMRealm *realm = [RLMRealm defaultRealm];

                                                        AttachmentRLM *a = [[AttachmentRLM alloc] init];
                                                        a.key = [[NSUUID UUID] UUIDString];
                                                        a.importeddate = [NSDate date];

                                                        a.filename = [NSString stringWithFormat:@"/PdfImportedDocs/%@.pdf",a.key];

                                                        a.notes = textField.text;

                                                        [realm beginWriteTransaction];
                                                        [realm addObject:a];
                                                        [realm commitWriteTransaction];

                                                        pdfDocumentsURL = [pdfDocumentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/%@.pdf",a.key]];

                                                        [PdfData writeToURL:pdfDocumentsURL atomically:YES];
                                                         
                                                     }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
            [alertController addAction:ok];
    });
    
    UIViewController *viewController = [self currentTopViewController];


    NSLayoutConstraint *constraint = [NSLayoutConstraint
                                      constraintWithItem:alertController.view
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationLessThanOrEqual
                                      toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                      multiplier:1
                                      constant:viewController.view.frame.size.height*2.0f];

    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alertController.view addConstraint:constraint];
        [viewController presentViewController:alertController animated:YES completion:^{}];
    });
    return true;

}


/*
 created date:      08/09/2018
 last modified:     08/09/2019
 remarks:           Have plugged in Poi.
 */
-(bool) ProcessImportFile {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath =  [documentsDirectory stringByAppendingPathComponent:@"ImportedPoi.trippo"];
    bool ImportedFile = false;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
    
        NSData *dataJSON = [NSData dataWithContentsOfFile:filePath];
        NSDictionary *PoiData = [NSJSONSerialization JSONObjectWithData:dataJSON options:kNilOptions error:nil];
        
        NSDictionary *ImageData = [PoiData objectForKey:@"ImageObject"];
        
        PoiRLM *poi = [[PoiRLM alloc] init];
        poi.key = [PoiData objectForKey:@"key"];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init]; [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        poi.modifieddt = [dateFormat dateFromString:[PoiData objectForKey:@"modifieddt"]];
        
        RLMResults <PoiRLM*> *found = [PoiRLM objectsWhere:@"key=%@",poi.key];
        
        bool modifyflag = false;
        bool insertflag = false;
        bool imagefound = false;
        
        
        if (found.count>0) {
           if([found[0].modifieddt compare: poi.modifieddt] == NSOrderedAscending ) {
               /* import is newer than item already in data - we must update existing */
               modifyflag = true;
               [realm beginWriteTransaction];
               found[0].name = [PoiData objectForKey:@"name"];
               found[0].categoryid = [PoiData objectForKey:@"categoryid"];
               found[0].country = [PoiData objectForKey:@"country"];
               found[0].administrativearea = [PoiData objectForKey:@"administrativearea"];
               found[0].subadministrativearea = [PoiData objectForKey:@"subadministrativearea"];
               found[0].fullthoroughfare = [PoiData objectForKey:@"fullthoroughfare"];
               found[0].privatenotes = [PoiData objectForKey:@"privatenotes"];
               found[0].locality = [PoiData objectForKey:@"locality"];
               found[0].sublocality = [PoiData objectForKey:@"sublocality"];
               found[0].postcode = [PoiData objectForKey:@"postcode"];
               found[0].wikititle = [PoiData objectForKey:@"wikititle"];
               found[0].searchstring = [PoiData objectForKey:@"searchstring"];
               found[0].lat = [PoiData objectForKey:@"lat"];
               found[0].lon = [PoiData objectForKey:@"lon"];
               found[0].createddt = [dateFormat dateFromString:[PoiData objectForKey:@"createddt"]];
               found[0].modifieddt = [dateFormat dateFromString:[PoiData objectForKey:@"modifieddt"]];
               found[0].authorname = [PoiData objectForKey:@"authorname"];
               found[0].authorkey = [PoiData objectForKey:@"authorkey"];
               found[0].sharedby = [PoiData objectForKey:@"sharedby"];
               found[0].devicesharedby = [PoiData objectForKey:@"devicesharedby"];
               found[0].exporteddt = [dateFormat dateFromString:[PoiData objectForKey:@"shareddt"]];
               
               for (ImageCollectionRLM *image in found[0].images) {
                   if (image.KeyImage && ![image.ImageFileReference isEqualToString:[ImageData objectForKey:@"FileReference"]]) {
                       image.KeyImage = 0;
                   }
               }
               bool ImageFound = false;
               for (ImageCollectionRLM *image in found[0].images) {
                   if ([image.ImageFileReference isEqualToString:[ImageData objectForKey:@"FileReference"]]) {
                       image.KeyImage = 1;
                       ImageFound = true;
                   }
               }
               [realm commitWriteTransaction];
           }
        } else {
            insertflag = true;

            [realm beginWriteTransaction];
            poi.name = [PoiData objectForKey:@"name"];
            poi.categoryid = [PoiData objectForKey:@"categoryid"];
            poi.country = [PoiData objectForKey:@"country"];
            poi.countrycode = [PoiData objectForKey:@"countrycode"];
            poi.administrativearea = [PoiData objectForKey:@"administrativearea"];
            poi.subadministrativearea = [PoiData objectForKey:@"subadministrativearea"];
            poi.fullthoroughfare = [PoiData objectForKey:@"fullthoroughfare"];
            poi.privatenotes = [PoiData objectForKey:@"privatenotes"];
            poi.locality = [PoiData objectForKey:@"locality"];
            poi.sublocality = [PoiData objectForKey:@"sublocality"];
            poi.postcode = [PoiData objectForKey:@"postcode"];
            poi.wikititle = [PoiData objectForKey:@"wikititle"];
            poi.searchstring = [PoiData objectForKey:@"searchstring"];
            poi.lat = [PoiData objectForKey:@"lat"];
            poi.lon = [PoiData objectForKey:@"lon"];
            poi.createddt = [dateFormat dateFromString:[PoiData objectForKey:@"createddt"]];
            poi.authorname = [PoiData objectForKey:@"authorname"];
            poi.authorkey = [PoiData objectForKey:@"authorkey"];
            poi.sharedby = [PoiData objectForKey:@"sharedby"];
            poi.exporteddt = [dateFormat dateFromString:[PoiData objectForKey:@"shareddt"]];
            poi.devicesharedby = [PoiData objectForKey:@"devicesharedby"];
            [realm addObject:poi];
            
            [realm commitWriteTransaction];
            
            
        }
        
        NSData *nsdataFromBase64String  = [[NSData alloc] initWithBase64EncodedString:[ImageData objectForKey:@"Image"] options:0];
        
        ImageCollectionRLM *img = [[ImageCollectionRLM alloc] init];
        
        if (insertflag || modifyflag) {

            NSString *imagefiledirectory = [ImageData objectForKey:@"Directory"];
            img.ImageFileReference = [ImageData objectForKey:@"ImageFileReference"];
            img.key = [ImageData objectForKey:@"Key"];
            img.KeyImage = true;
            
            if (!imagefound && ![img.key isEqualToString:@"N/A"]) {
                
                NSString *NewPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",imagefiledirectory]];
                
                [[NSFileManager defaultManager] createDirectoryAtPath:NewPath withIntermediateDirectories:YES attributes:nil error:nil];
                
                NSString *dataFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",img.ImageFileReference]];
                
                [nsdataFromBase64String writeToFile:dataFilePath atomically:YES];
                
                NSError *error;
                if (![nsdataFromBase64String writeToFile:dataFilePath options:NSDataWritingFileProtectionNone error:&error]) {
                    // Error occurred. Details are in the error object.
                    NSLog(@"%@",error);
                }
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                
                [realm beginWriteTransaction];
                if (insertflag) {
                    [poi.images addObject:img];
                } else if (modifyflag) {
                    [found[0].images addObject:img];
                }
                [realm commitWriteTransaction];
                
                CGSize imagesize = CGSizeMake(100 , 100);
                
                if (insertflag) {
                    [self.PoiBackgroundImageDictionary setObject:[ToolBoxNSO imageWithImage:[UIImage imageWithData:nsdataFromBase64String] convertToSize:imagesize] forKey:poi.key];
                } else if (modifyflag) {
                    [self.PoiBackgroundImageDictionary setObject:[ToolBoxNSO imageWithImage:[UIImage imageWithData:nsdataFromBase64String] convertToSize:imagesize] forKey:found[0].key];
                }
                
            }

        }

        // now show the alert
        UIAlertController *alertController;
        [alertController.view setTintColor:[UIColor labelColor]];

        if (insertflag) {
            alertController = [UIAlertController alertControllerWithTitle:@"Imported!" message:[NSString stringWithFormat:@"\n\nThe Point of Interest '%@' has been added to your device!",poi.name] preferredStyle:UIAlertControllerStyleAlert];
        } else if (modifyflag) {
            alertController = [UIAlertController alertControllerWithTitle:@"Imported!" message:[NSString stringWithFormat:@"\n\nThe Point of Interest'%@' has been updated!",found[0].name] preferredStyle:UIAlertControllerStyleAlert];
        } else {
             alertController = [UIAlertController alertControllerWithTitle:@"Warning!" message:[NSString stringWithFormat:@"\n\nThe Point of Interest '%@' has not been modified!",found[0].name] preferredStyle:UIAlertControllerStyleAlert];
        }
        if (![img.key isEqualToString:@"N/A"]) {
            /* try and add image into view. */
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
            img.image = [UIImage imageWithData:nsdataFromBase64String];
            [alertController.view addSubview:img];
            ImportedFile = true;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            UIViewController *viewController = [self currentTopViewController];
            
            NSLayoutConstraint *constraint = [NSLayoutConstraint
                                              constraintWithItem:alertController.view
                                              attribute:NSLayoutAttributeHeight
                                              relatedBy:NSLayoutRelationLessThanOrEqual
                                              toItem:nil
                                              attribute:NSLayoutAttributeNotAnAttribute
                                              multiplier:1
                                              constant:viewController.view.frame.size.height*2.0f];
            
            [alertController.view addConstraint:constraint];
            [viewController presentViewController:alertController animated:YES completion:^{}];
                
        });
    
    }
    return ImportedFile;
}

- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

/*
- (UIViewController *)topViewController{
  return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}
*/
/*
- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
  if (rootViewController.presentedViewController == nil) {
    return rootViewController;
  }

  if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
    UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
    return [self currentTopViewController:lastViewController];
  }

  UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
  return [self currentTopViewController:presentedViewController];
}
*/

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    //Called when a notification is delivered to the foreground.
    NSLog(@"willPresentNotification > Userinfo %@",notification.request.content.userInfo);
    completionHandler(UNNotificationPresentationOptionAlert);
}


/*
 created date:      24/03/2019
 last modified:     24/04/2019
 remarks:           Have plugged in Poi.
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    
    //Called to let your app know which action was selected by the user for a given notification.
    
    NSString *DefaultOverrideItdentifier = @"";
    
    NSLog(@"didReceiveNotificationResponse > Userinfo %@",response.notification.request.content.userInfo);
    
    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier ]) {
        /* this is where the code flows if user taps on notification and app is in background / phone on standby */
        /* opens App */
        /* lets force the option again.. */
    
        if ([response.notification.request.identifier containsString:@"CHECKIN~"]) {
            DefaultOverrideItdentifier = @"CheckIn";
            
        } else if ([response.notification.request.identifier containsString:@"CHECKOUT~"]) {
            DefaultOverrideItdentifier = @"CheckOut";
        }
    }
    
    if ([response.actionIdentifier isEqualToString:@"CheckIn"] || [DefaultOverrideItdentifier isEqualToString:@"CheckIn"]) {
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        NSString *Key  = [response.notification.request.identifier stringByReplacingOccurrencesOfString:@"CHECKIN~" withString:@""];
        NSString *PlannedCompondKey = [NSString stringWithFormat:@"%@~0",Key];
        ActivityRLM *plannedactivity = [ActivityRLM objectForPrimaryKey: PlannedCompondKey];
        
        NSString *ActualCompondKey = [NSString stringWithFormat:@"%@~1",Key];
        ActivityRLM *actualactivity = [ActivityRLM objectForPrimaryKey: ActualCompondKey];
        
        if (plannedactivity != nil && actualactivity == nil) {

            ActivityRLM *actualactivity = [[ActivityRLM alloc] init];
            actualactivity.key = plannedactivity.key;
            actualactivity.state = [NSNumber numberWithInt:1];
            actualactivity.compondkey = ActualCompondKey;
            actualactivity.name = plannedactivity.name;
            actualactivity.tripkey = plannedactivity.tripkey;
            actualactivity.poikey = plannedactivity.poikey;
            actualactivity.poi = plannedactivity.poi;
            actualactivity.createddt = [NSDate date];
            actualactivity.modifieddt = [NSDate date];
            actualactivity.startdt = response.notification.date;
            actualactivity.enddt = response.notification.date;
            actualactivity.privatenotes = [NSString stringWithFormat:@"Actual activity auto-generated from notification centre"];
            actualactivity.IncludeInTweet = plannedactivity.IncludeInTweet;
            actualactivity.geonotification = 0;
            actualactivity.geonotifycheckout = plannedactivity.geonotifycheckout;
            actualactivity.geonotifycheckindt = plannedactivity.geonotifycheckindt;
            actualactivity.geonotifycheckoutdt = plannedactivity.geonotifycheckoutdt;
            [realm beginWriteTransaction];
            [realm addObject:actualactivity];
            
            
            [realm commitWriteTransaction];
            
        } else if (actualactivity != nil) {
            // the actual activity has been either created by the check out notification or manually by the user in the App
            [realm beginWriteTransaction];
            actualactivity.modifieddt = [NSDate date];
            actualactivity.startdt = response.notification.date;
            actualactivity.privatenotes = [NSString stringWithFormat:@"%@\nActual activity updated from checkin notification", actualactivity.privatenotes];
            actualactivity.geonotification = 0;
            [realm commitWriteTransaction];
        } else {
            NSLog(@"Error, Cannot locate the item from notification!");
        }

        /* remove pending notification */
        NSString *identifier = response.notification.request.identifier;
        
        NSArray *activityNotification = [NSArray arrayWithObjects:identifier, nil];
        [self.UserNotificationCenter removePendingNotificationRequestsWithIdentifiers:activityNotification];
        [self.UserNotificationCenter removeDeliveredNotificationsWithIdentifiers:activityNotification];

        
    } else if ([response.actionIdentifier isEqualToString:@"CheckOut"] || [DefaultOverrideItdentifier isEqualToString:@"CheckOut"]) {

        RLMRealm *realm = [RLMRealm defaultRealm];
        
        NSString *Key  = [response.notification.request.identifier stringByReplacingOccurrencesOfString:@"CHECKOUT~" withString:@""];
        NSString *PlannedCompondKey = [NSString stringWithFormat:@"%@~0",Key];
        ActivityRLM *plannedactivity = [ActivityRLM objectForPrimaryKey: PlannedCompondKey];
        
        NSString *ActualCompondKey = [NSString stringWithFormat:@"%@~1",Key];
        ActivityRLM *actualactivity = [ActivityRLM objectForPrimaryKey: ActualCompondKey];
        
        if (plannedactivity != nil && actualactivity == nil) {
         
            ActivityRLM *actualactivity = [[ActivityRLM alloc] init];
            actualactivity.key = plannedactivity.key;
            actualactivity.state = [NSNumber numberWithInt:1];
            actualactivity.compondkey = ActualCompondKey;
            actualactivity.name = plannedactivity.name;
            actualactivity.tripkey = plannedactivity.tripkey;
            actualactivity.poikey = plannedactivity.poikey;
            actualactivity.poi = plannedactivity.poi;
            actualactivity.createddt = [NSDate date];
            actualactivity.modifieddt = [NSDate date];
            actualactivity.startdt = response.notification.date;
            actualactivity.enddt = response.notification.date;
            actualactivity.privatenotes = [NSString stringWithFormat:@"Actual activity auto-generated from notification centre"];
            actualactivity.IncludeInTweet = plannedactivity.IncludeInTweet;
            actualactivity.geonotification = 0;
            actualactivity.geonotifycheckout = 0;
            actualactivity.geonotifycheckindt = plannedactivity.geonotifycheckindt;
            actualactivity.geonotifycheckoutdt = plannedactivity.geonotifycheckoutdt;

            [realm beginWriteTransaction];
            [realm addObject:actualactivity];
            [realm commitWriteTransaction];
            
         } else if (actualactivity != nil) {
         
            [realm beginWriteTransaction];
            actualactivity.modifieddt = [NSDate date];
            actualactivity.enddt = response.notification.date;
            actualactivity.privatenotes = [NSString stringWithFormat:@"%@\nActual activity updated from checkout notification", actualactivity.privatenotes];
            actualactivity.geonotification = 0;
            actualactivity.geonotifycheckout = 0;
             
            [realm commitWriteTransaction];
            /* remove pending notification */
         } else {
             NSLog(@"Error, Cannot locate the item from notification on check out!");
         }
        
        /* remove pending notification */
        NSString *identifier = response.notification.request.identifier;
        NSArray *activityNotification = [NSArray arrayWithObjects:identifier, nil];
        [self.UserNotificationCenter removePendingNotificationRequestsWithIdentifiers:activityNotification];
        [self.UserNotificationCenter removeDeliveredNotificationsWithIdentifiers:activityNotification];
    
    } else if ([response.actionIdentifier isEqualToString:@"Ignore"]) {
        NSLog(@"Skip the thing!  Userinfo %@",response.notification.request.content.userInfo);
        
    } else if ([response.actionIdentifier isEqualToString:@"Dismiss"]) {
        NSLog(@"Remove the thing!  Userinfo %@",response.notification.request.content.userInfo);
        NSString *identifier = response.notification.request.identifier;
        NSArray *activityNotification = [NSArray arrayWithObjects:identifier, nil];
        [self.UserNotificationCenter removePendingNotificationRequestsWithIdentifiers:activityNotification];
        [self.UserNotificationCenter removeDeliveredNotificationsWithIdentifiers:activityNotification];
    }
}


@end
