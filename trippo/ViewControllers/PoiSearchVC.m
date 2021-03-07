//
//  ActivityDataEntryVC.m
//  travelme
//
//  Created by andrew glew on 30/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PoiSearchVC.h"

@interface PoiSearchVC ()
@property RLMNotificationToken *notification;
@end

@implementation PoiSearchVC
CGFloat lastPoiSearchFooterFilterHeightConstant;

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/*
 created date:      30/04/2018
 last modified:     11/01/2020
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.SearchBarPoi.delegate = self;
    self.TableViewSearchPoiItems.delegate = self;
    self.TableViewSearchPoiItems.rowHeight = 100;
    
    lastPoiSearchFooterFilterHeightConstant = self.FilterOptionHeightConstraint.constant;
    
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.FilterOptionHeightConstraint.constant)];
    self.TableViewSearchPoiItems.tableFooterView = footerView;
    
    self.SegmentCountries.selectedSegmentIndex=1;
    if (self.TripItem == nil) {
        // we are arriving directly from the menu
        //[self.SegmentPoiFilterList setTitle:@"Unused" forSegmentAtIndex:0];
        self.SegmentCountries.selectedSegmentIndex=1;
        self.SegmentCountries.enabled = false;
        
    } else {
        // project is available
        self.SegmentCountries.selectedSegmentIndex=0;

        NSArray *keypaths  = [[NSArray alloc] initWithObjects:@"poikey", nil];
        RLMResults <ActivityRLM*> *activities = [[ActivityRLM objectsWhere:@"tripkey = %@",self.TripItem.key] distinctResultsUsingKeyPaths:keypaths];

        if (activities.count>0) {
            self.countries = [[NSMutableArray alloc] init];
            for (ActivityRLM *activityobj in activities) {
                PoiRLM *poi = [PoiRLM objectForPrimaryKey:activityobj.poikey];
                bool found=false;
                for (NSString *country in self.countries) {
                    if ([country isEqualToString:poi.countrycode]) {
                        found=true;
                        break;
                    }
                }
                if (!found) {
                    [self.countries addObject:poi.countrycode];
                }
            }
        } else {
            self.SegmentCountries.selectedSegmentIndex=1;
            self.SegmentPoiFilterList.selectedSegmentIndex=1;
        }
    }
    
    /* user selected specific option from startup view */
    __weak typeof(self) weakSelf = self;
    
    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf RefreshPoiFilteredData:true];
        [weakSelf.TableViewSearchPoiItems reloadData];
    }];

    self.TypeItems = @[@"Cat-Accomodation",
                       @"Cat-Airport",
                       @"Cat-Astronaut",
                       @"Cat-Bakery",
                       @"Cat-Beer",
                       @"Cat-Bike",
                       @"Cat-Bridge",
                       @"Cat-CarHire",
                       @"Cat-CarPark",
                       @"Cat-Casino",
                       @"Cat-Cave",
                       @"Cat-Church",
                       @"Cat-Cinema",
                       @"Cat-City",
                       @"Cat-CityPark",
                       @"Cat-Climbing",
                       @"Cat-Club",
                       @"Cat-Sea",
                       @"Cat-Concert",
                       @"Cat-FoodWine",
                       @"Cat-Football",
                       @"Cat-Forest",
                       @"Cat-Golf",
                       @"Cat-Historic",
                       @"Cat-House",
                       @"Cat-Lake",
                       @"Cat-Lighthouse",
                       @"Cat-Metropolis",
                       @"Cat-Misc",
                       @"Cat-Monument",
                       @"Cat-Museum",
                       @"Cat-NationalPark",
                       @"Cat-Nature",
                       @"Cat-Office",
                       @"Cat-PetrolStation",
                       @"Cat-Photography",
                       @"Cat-Restaurant",
                       @"Cat-River",
                       @"Cat-Rugby",
                       @"Cat-Safari",
                       @"Cat-Scenary",
                       @"Cat-School",
                       @"Cat-Ship",
                       @"Cat-Shopping",
                       @"Cat-Ski",
                       @"Cat-Sports",
                       @"Cat-Swimming",
                       @"Cat-Tennis",
                       @"Cat-Theatre",
                       @"Cat-ThemePark",
                       @"Cat-Tower",
                       @"Cat-Train",
                       @"Cat-Trek",
                       @"Cat-Venue",
                       @"Cat-Village",
                       @"Cat-Vineyard",
                       @"Cat-Windmill",
                       @"Cat-Zoo"
                       ];
    
    
    
    [self LoadPoiBackgroundImageData];
    
    [self RefreshPoiFilteredData :true];

    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.CollectionViewTypes addGestureRecognizer:lpgr];
    
    self.SegmentPoiFilterList.selectedSegmentTintColor = [UIColor colorNamed:@"TrippoColor"];
    [self.SegmentPoiFilterList setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor systemBackgroundColor], NSFontAttributeName: [UIFont systemFontOfSize:13]} forState:UIControlStateSelected];
    
    self.SegmentCountries.selectedSegmentTintColor = [UIColor colorNamed:@"TrippoColor"];
    [self.SegmentCountries setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor systemBackgroundColor], NSFontAttributeName: [UIFont systemFontOfSize:13]} forState:UIControlStateSelected];
    
    self.SearchBarPoi.searchBarStyle = UISearchBarStyleMinimal;
    self.SearchBarPoi.searchTextField.backgroundColor = [UIColor tertiarySystemBackgroundColor];
    self.SearchBarPoi.searchTextField.textColor = [UIColor colorNamed:@"TrippoColor"];
    
    [self addDoneToolBarForTextFieldToKeyboard:self.SearchBarPoi.searchTextField];
    
    /* new block 20200111 */
    RLMResults <SettingsRLM*> *settings = [SettingsRLM allObjects];
    
    
    
}

/*
 created date:      01/03/2021
 last modified:     01/03/2021
 remarks:
 */
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.frommenu){
        [self.delegate didDismissPresentingViewController];
    }
}


/*
 created date:      11/08/2018
 last modified:     11/08/2018
 remarks:
 */
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.CollectionViewTypes];
    
    NSIndexPath *indexPath = [self.CollectionViewTypes indexPathForItemAtPoint:p];
    if (indexPath != nil){
        
        TypeNSO *type = [self.PoiTypes objectAtIndex:indexPath.row];
        
        NSNumber *categoryid = type.categoryid;
        
        for (TypeNSO *type in self.PoiTypes) {
            if (type.categoryid == categoryid) {
                type.selected = true;
            } else {
                type.selected = false;
            }
        }
        
        [self RefreshPoiFilteredData:false];
     
    }
}

/*
created date:      14/09/2019
last modified:     14/09/2019
remarks:
*/
-(void)addDoneToolBarForTextFieldToKeyboard:(UITextField *)textField
{
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleDefault;
    [doneToolbar setTintColor:[UIColor colorWithRed:255.0f/255.0f green:91.0f/255.0f blue:73.0f/255.0f alpha:1.0]];
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClickedDismissKeyboard)],
                         nil];
    [doneToolbar sizeToFit];
    textField.inputAccessoryView = doneToolbar;
}

/*
created date:      14/09/2019
last modified:     14/09/2019
remarks:
*/
-(void)doneButtonClickedDismissKeyboard
{
    [self.SearchBarPoi.searchTextField resignFirstResponder];
}

/*
 created date:      11/06/2018
 last modified:     10/08/2018
 remarks:
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

}

/*
 created date:      03/05/2018
 last modified:     23/06/2019
 remarks:           called twice???  Improved Poi Type processing
 */
-(void)RefreshPoiFilteredData :(BOOL) UpdateTypes {
    
    self.poifilteredcollection = [PoiRLM allObjects];
    
    if (self.SegmentPoiFilterList.selectedSegmentIndex != 1 && self.SegmentPoiFilterList.selectedSegmentIndex != 3) {
        /* get distinct poi items from activities */
        NSArray *keypaths  = [[NSArray alloc] initWithObjects:@"poikey", nil];
        
        RLMResults<ActivityRLM*> *used = [[ActivityRLM allObjects] distinctResultsUsingKeyPaths:keypaths];
        
        NSMutableArray *poiitems = [[NSMutableArray alloc] init];
        
        for (ActivityRLM *usedPois in used) {
            if (usedPois.name != nil) {
                
                [poiitems addObject:usedPois.poikey];
            }
        }

        NSSet *typeset = [[NSSet alloc] initWithArray:poiitems];
        
        if (self.SegmentPoiFilterList.selectedSegmentIndex == 0) {
           // NSLog(@"unused");

            self.poifilteredcollection = [self.poifilteredcollection objectsWithPredicate:[NSPredicate predicateWithFormat:@"NOT (key IN %@)",typeset]];
            
        } else if (self.SegmentPoiFilterList.selectedSegmentIndex == 2) {
            //NSLog(@"used");

            self.poifilteredcollection = [self.poifilteredcollection objectsWithPredicate:[NSPredicate predicateWithFormat:@"key IN %@",typeset]];
            
        }
    } else if (self.SegmentPoiFilterList.selectedSegmentIndex == 3) {
        //NSLog(@"visited");
        
        NSArray *keypaths  = [[NSArray alloc] initWithObjects:@"poikey", nil];
        
        RLMResults<ActivityRLM*> *used = [[ActivityRLM objectsWhere:@"state = 1"]  distinctResultsUsingKeyPaths:keypaths];
        
        NSMutableArray *poiitems = [[NSMutableArray alloc] init];
        
        for (ActivityRLM *usedPois in used) {
            [poiitems addObject:usedPois.poikey];
        }
        NSSet *typeset = [[NSSet alloc] initWithArray:poiitems];
        
        self.poifilteredcollection = [self.poifilteredcollection objectsWithPredicate:[NSPredicate predicateWithFormat:@"key IN %@",typeset]];
        
        
    }

    if (self.TripItem != nil && self.SegmentCountries.selectedSegmentIndex == 0) {
        NSSet *projectcountries = [NSSet setWithArray:self.countries];
        self.poifilteredcollection = [self.poifilteredcollection objectsWithPredicate:[NSPredicate predicateWithFormat:@"countrycode IN %@",projectcountries]];
    }
    
    // here we must apply in case isSearching is false and text is not ""... when we return from Poi Data Entry
    if (self.isSearching || (![self.SearchBarPoi.text isEqualToString:@""] && self.isSearching == false)) {
        self.poifilteredcollection = [self.poifilteredcollection objectsWithPredicate:[NSPredicate predicateWithFormat:@"searchstring CONTAINS %@",self.SearchBarPoi.text]];
    }
    
    
    if (UpdateTypes) {

        NSCountedSet* countedSet = [[NSCountedSet alloc] init];
        
        for (PoiRLM* poi in self.poifilteredcollection) {
           // NSLog(@"%@ : %@",poi.name, poi.categoryid );
            [countedSet addObject:poi.categoryid];
        }
        
        if (self.PoiTypes.count>0) {
            // need to process each selected to check counter if there are still Poi selected.
            // when adding new items, we need to check if the user has own mixed selection of types.
            bool isselected = false;
            bool isunselected = false;
            /* reset all existing type items in array */
            for (TypeNSO* type in self.PoiTypes) {
                type.occurances = [NSNumber numberWithInteger:0];
                if (type.selected) {
                    isselected = true;
                }
                if (!type.selected) {
                    isunselected = true;
                }
            }
            
            /* load up array with any new type items while if we cannot find type in existing list we create new item */
            for (id item in countedSet)
            {
                bool found = false;

                for (TypeNSO* type in self.PoiTypes) {
                    if (type.categoryid == item) {
                        type.occurances = [NSNumber numberWithInteger:[countedSet countForObject:type.categoryid]];
                        found = true;
                        
                        break;
                    }
                }
                
                if (!found) {
                    TypeNSO *type = [[TypeNSO alloc] init];
                    type.occurances = [NSNumber numberWithInteger:[countedSet countForObject:item]];
                    type.categoryid = item;
                    u_long number = [item unsignedLongValue];
                    type.imagename = [self.TypeItems objectAtIndex: number];
                    if (isselected && isunselected) {
                        type.selected = false;
                    } else {
                        type.selected = true;
                    }
                    [self.PoiTypes addObject:type];
                }
                
                
            }
            
            /* we remove any items that are not occuring in this selection */
            NSInteger count = [self.PoiTypes count];
            for (NSInteger index = (count - 1); index >= 0; index--) {
                TypeNSO *type = self.PoiTypes[index];
                if (type.occurances == [NSNumber numberWithInteger:0]) {
                    [self.PoiTypes removeObjectAtIndex:index];
                }
            }
            
            /* finally sort the list in the common order used */
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryid"
                                                         ascending:YES];
            [self.PoiTypes sortUsingDescriptors:@[sortDescriptor]];
            

        } else {
        
            self.PoiTypes = [[NSMutableArray alloc] init];
            
            for (id item in countedSet)
            {
                TypeNSO *type = [[TypeNSO alloc] init];
                type.occurances = [NSNumber numberWithInteger:[countedSet countForObject:item]];
                type.categoryid = item;
                u_long number = [item unsignedLongValue];
                type.imagename = [self.TypeItems objectAtIndex: number];
                type.selected = true;
                [self.PoiTypes addObject:type];
            }
            
            /* sort the list in the common order used */
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"categoryid"
                                                         ascending:YES];
            [self.PoiTypes sortUsingDescriptors:@[sortDescriptor]];
            
        }
    
    }
    // here we filter on existing types ..
    bool TypesExcluded = false;
    NSMutableArray *types = [[NSMutableArray alloc] init];
    for (TypeNSO *type in self.PoiTypes) {
        if (type.selected) {
            [types addObject:type.categoryid];
        } else {
            TypesExcluded = true;
        }
    }
    
    if (TypesExcluded) {
        NSSet *typeset = [[NSSet alloc] initWithArray:types];
    
        self.poifilteredcollection = [self.poifilteredcollection objectsWithPredicate:[NSPredicate predicateWithFormat:@"categoryid IN %@",typeset]];
    }

    self.poifilteredcollection = [self.poifilteredcollection sortedResultsUsingDescriptors:@[
                                                       [RLMSortDescriptor sortDescriptorWithKeyPath:@"name" ascending:YES],
                                                       ]];
    
    
    
    
    
    [self.LabelCounter setText:[NSString stringWithFormat:@"%lu Items", (unsigned long)self.poifilteredcollection.count]];
    
    [self.TableViewSearchPoiItems reloadData];
    
    [self.CollectionViewTypes reloadData];
    
}




/*
 created date:      30/04/2018
 last modified:     27/03/2019
 remarks:
 */
-(void) LoadPoiBackgroundImageData {
    if (AppDelegateDef.PoiBackgroundImageDictionary.count==0) {
        NSURL *url = [self applicationDocumentsDirectory];

        NSData *pngData;
        UIImage *image;
        CGSize imagesize = CGSizeMake(100 , 100);
        
        RLMResults <PoiRLM*> *allPoiObjects = [PoiRLM allObjects];
        
        for (PoiRLM *poi in allPoiObjects) {
            
            if (poi.images.count > 0) {
                NSError *err;

                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *imagesDirectory = [paths objectAtIndex:0];
                NSString *thumbDataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/%@/thumbnail.png",poi.key]];
                
                pngData = [NSData dataWithContentsOfFile:thumbDataPath options:NSDataReadingMappedIfSafe error:&err];
                
                if (pngData==nil) {
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
                    RLMResults *filteredArray = [poi.images objectsWithPredicate:predicate];
                    ImageCollectionRLM *imgobject;
                    if (filteredArray.count==0) {
                        imgobject = [poi.images firstObject];
                    } else {
                        imgobject = [filteredArray firstObject];
                    }
                    NSURL *imagefile = [url URLByAppendingPathComponent:imgobject.ImageFileReference];
                    
                    pngData = [NSData dataWithContentsOfURL:imagefile options:NSDataReadingMappedIfSafe error:&err];
                    if (pngData==nil) {
                        image = [UIImage systemImageNamed:@"command"];
                    } else {
                        image = [UIImage imageWithData:pngData];
                        
                    }
                    image = [ToolBoxNSO imageWithImage:image convertToSize:imagesize];

                } else {
                    image =[UIImage imageWithData:pngData];
                }
                [AppDelegateDef.PoiBackgroundImageDictionary setObject:image forKey:poi.key];
            }
        }
    }
}


/*
 created date:      15/07/2018
 last modified:     15/07/2018
 remarks:   Scale image to size passed in
 */

-(UIImage *)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // here is the scaled image which has been changed to the size specified
    UIGraphicsEndImageContext();
    return newImage;
}

/*
 created date:      13/09/2018
 last modified:     13/09/2018
 remarks:   Crop image with size passed in
 */
- (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.poifilteredcollection.count;
}

/*
 created date:      07/10/2018
 last modified:     07/10/2018
 remarks:
 */
- (NSString *)emojiFlagForISOCountryCode:(NSString *)countryCode {
    NSAssert(countryCode.length == 2, @"Expecting ISO country code");
    
    int base = 127462 -65;
    
    wchar_t bytes[2] = {
        base +[countryCode characterAtIndex:0],
        base +[countryCode characterAtIndex:1]
    };
    
    return [[NSString alloc] initWithBytes:bytes
                                    length:countryCode.length *sizeof(wchar_t)
                                  encoding:NSUTF32LittleEndianStringEncoding];
}


/*
 created date:      30/04/2018
 last modified:     18/11/2018
 remarks:
 */
- (PoiListCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    PoiListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchPoiCellId"];

    
    if (cell == nil) {
        cell = [[PoiListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SearchPoiCellId"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }

    PoiRLM *poi = [self.poifilteredcollection objectAtIndex:indexPath.row];
    
    cell.poi = poi;    
    cell.Name.text = poi.name;
    
    cell.AdministrativeArea.text = poi.administrativearea;
    if (poi.countrycode != nil && ![poi.countrycode isEqualToString:@""]) {
        cell.LabelFlag.text = [self emojiFlagForISOCountryCode:poi.countrycode];
    }
    
    cell.ImageCategory.image = [UIImage imageNamed:[self.TypeItems objectAtIndex:[cell.poi.categoryid integerValue]]];

    if (poi.images.count==0) {
        [cell.PoiKeyImage setImage:[UIImage systemImageNamed:@"command"]];
    } else {
        [cell.PoiKeyImage setImage:[AppDelegateDef.PoiBackgroundImageDictionary objectForKey:poi.key]];
    }
    return cell;
}


/*
 created date:      03/05/2018
 last modified:     03/05/2018
 remarks:
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *IDENTIFIER = @"SearchPoiCellId";
    
    PoiListCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[PoiListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }

    PoiRLM *Poi = [self.self.poifilteredcollection objectAtIndex:indexPath.row];
    
    if (self.Activity==nil) {
        /* open Poi view */
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PoiDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"PoiDataEntryId"];
        controller.delegate = self;
        controller.realm = self.realm;
        controller.PointOfInterest = Poi;
        controller.newitem = false;
        [controller setModalPresentationStyle:UIModalPresentationPageSheet];
        [self presentViewController:controller animated:YES completion:nil];
       
    } else {
        /* we select project and go onto it's activities! */
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ActivityDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ActivityDataEntryViewController"];
        controller.delegate = self;
        controller.Activity = self.Activity;
        controller.realm = self.realm;
        controller.Poi = Poi;
        NSLog(@"startdt = %@",self.TripItem.startdt);
        controller.Trip = self.TripItem;
        //controller.Activity.poi = Poi;
        controller.deleteitem = false;
        controller.transformed = self.transformed;
        controller.newitem = true;
        [controller setModalPresentationStyle:UIModalPresentationPageSheet];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

/*
 created date:      10/09/2018
 last modified:     10/09/2018
 remarks:           User can only delete unused Poi items
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL edit = NO;
    if(self.SegmentPoiFilterList.selectedSegmentIndex == 0) {
        edit = YES;
    }
    return edit;
}

/*
created date:      14/09/2019
last modified:     14/09/2019
remarks:
*/
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    UIContextualAction *deleteAction = [[UIContextualAction alloc] init];
    
    deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Delete" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        [self tableView:tableView deletePoi:indexPath];
        self.TableViewSearchPoiItems.editing = NO;
    }];
    
    deleteAction.backgroundColor = [UIColor systemRedColor];
    deleteAction.image = [UIImage systemImageNamed:@"trash"];

    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    config.performsFirstActionWithFullSwipe = NO;
    return config;
}

/*
 created date:      02/05/2018
 last modified:     10/09/2018
 remarks:           Might not be totally necessary, but seperated out from editActionsForRowAtIndexPath method above.
 */
- (void)tableView:(UITableView *)tableView deletePoi:(NSIndexPath *)indexPath  {

    PoiRLM *item = [self.poifilteredcollection objectAtIndex:indexPath.row];
    [self.realm transactionWithBlock:^{
        [self.realm deleteObject:item];
    }];

    NSLog(@"delete called!");
}

/*
 created date:      05/02/2019
 last modified:     23/03/2019
 remarks:           Provide a bit of space if needed.
 */
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if (velocity.y > 0 && self.FilterOptionHeightConstraint.constant == lastPoiSearchFooterFilterHeightConstant){
        NSLog(@"scrolling down");
        
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.FilterOptionHeightConstraint.constant = 0.0f;
                             
                             UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0)];
                             self.TableViewSearchPoiItems.tableFooterView = footerView;
                             
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    if (velocity.y < 0  && self.FilterOptionHeightConstraint.constant == 0.0f){
        NSLog(@"scrolling up");
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             self.FilterOptionHeightConstraint.constant = lastPoiSearchFooterFilterHeightConstant;
                             
                             UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.FilterOptionHeightConstraint.constant)];
                             self.TableViewSearchPoiItems.tableFooterView = footerView;
                             
                             [self.view layoutIfNeeded];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}




-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.SearchBarPoi resignFirstResponder];
}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.isSearching = YES;
}

/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (void)searchBarTextDidEndEditing:(UISearchBar *)theSearchBar {
    NSLog(@"searchBarTextDidEndEditing");
    self.isSearching = NO;
}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:           TODO merge the search with the filter.  how best to do?
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"Text change - %d",self.isSearching);
    
    if ([searchText length] ==0) {
        self.isSearching = NO;
    } else {
        self.isSearching = YES;
    }
    [self RefreshPoiFilteredData :true];
}



/*
 created date:      30/04/2018
 last modified:     03/05/2018
 remarks:
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self RefreshPoiFilteredData :true];
}



/*
 created date:      30/04/2018
 last modified:     20/03/2019
 remarks:           segue controls.  We need to work here next - get selection Project==null
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ShowPoiLocator"]){
        LocatorVC *controller = (LocatorVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.realm = self.realm;
        if (self.TripItem == nil) {
            controller.fromproject = false;
        }
        else {
            controller.fromproject = true;
            controller.TripItem = self.TripItem;
            controller.ActivityItem = self.Activity;
        }
    } else if([segue.identifier isEqualToString:@"ShowNearby"]){
        NearbyListingVC *controller = (NearbyListingVC *)segue.destinationViewController;
        controller.delegate = self;
        controller.frommenu = false;
        if (self.TripItem == nil) {
            controller.fromproject = false;
        }
        else {
            controller.TripItem = self.TripItem;
            controller.ActivityItem = self.Activity;
            controller.fromproject = true;
        }
        
        if ([sender isKindOfClass: [UIButton class]]) {
            UIView * cellView=(UIView*)sender;
            while ((cellView= [cellView superview])) {
                if([cellView isKindOfClass:[PoiListCell class]]) {
                    PoiListCell *cell = (PoiListCell*)cellView;
                    NSIndexPath *indexPath = [self.TableViewSearchPoiItems indexPathForCell:cell];
                    controller.PointOfInterest = [self.poifilteredcollection objectAtIndex:indexPath.row];
                    controller.realm = self.realm;
                }
            }
        }
    } else if([segue.identifier isEqualToString:@"ShowNearbyMe"])
    {
        NearbyListingVC *controller = (NearbyListingVC *)segue.destinationViewController;
        controller.frommenu = false;
        controller.delegate = self;
        controller.realm = self.realm;
        controller.PointOfInterest = nil;
        if (self.TripItem == nil) {
            controller.fromproject = false;
        }
        else {
            controller.fromproject = true;
            controller.ActivityItem = self.Activity;
            controller.fromproject = true;
        }
    }
    
}


/*
 created date:      30/04/2018
 last modified:     30/04/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

/*
 created date:      14/05/2018
 last modified:     14/05/2018
 remarks:
 */
- (IBAction)SegmentPoiFilterChanged:(id)sender {
    //[self LoadPoiData];
    [self RefreshPoiFilteredData :true];
}

/*
 created date:      11/08/2018
 last modified:     11/08/2018
 remarks:
 */
- (IBAction)SegmentPoiCountriesFilterChanged:(id)sender {
    
    [self RefreshPoiFilteredData :true];
    
}




/*
 created date:      11/08/2018
 last modified:     11/08/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.PoiTypes.count;
}

/*
 created date:      11/08/2018
 last modified:     11/08/2018
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TypeCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"TypeCellId" forIndexPath:indexPath];
    TypeNSO *item = [self.PoiTypes objectAtIndex:indexPath.row];
    [cell.TypeImageView setImage:[UIImage imageNamed:item.imagename]];
    cell.LabelOccurances.text = [NSString stringWithFormat:@"%@", item.occurances];
    cell.selected = item.selected;
    cell.ImageViewChecked.hidden = !item.selected;
    return cell;
}


/*
 created date:      11/08/2018
 last modified:     11/08/2018
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    /* add the insert method if found to be last cell */
    TypeNSO *item = [self.PoiTypes objectAtIndex:indexPath.row];
    item.selected = !item.selected;
    [self RefreshPoiFilteredData :false];
}



/*
 created date:      11/08/2018
 last modified:     12/08/2018
 remarks:           Only sets all category filters to selected
 */
- (IBAction)FilterResetPressed:(id)sender {
    
    for (TypeNSO *type in self.PoiTypes) {
        type.selected = true;
    }
    self.SearchBarPoi.text = @"";
    self.isSearching = false;
    
    [self RefreshPoiFilteredData:true];
    
}

/*
 created date:      11/08/2018
 last modified:     31/01/2019
 remarks:
 */
- (IBAction)FilterPressed:(id)sender {
    
    [self.view layoutIfNeeded];
    if (self.FilterOptionHeightConstraint.constant==98) {
        [UIView animateWithDuration:0.25f animations:^{
            self.FilterOptionHeightConstraint.constant=350;
            self.ButtonResetFilter.hidden = false;

            [self.ButtonFilter setImage:[UIImage systemImageNamed:@"arrow.down.forward.and.arrow.up.backward"] forState:UIControlStateNormal];
            [self.ButtonFilter setTitle:@"Hide" forState:UIControlStateNormal];
        
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.FilterOptionHeightConstraint.constant)];
            self.TableViewSearchPoiItems.tableFooterView = footerView;
            [self.TableViewSearchPoiItems reloadData];
        }];
        
    } else {
        [UIView animateWithDuration:0.25f animations:^{
            self.FilterOptionHeightConstraint.constant=98;
            self.ButtonResetFilter.hidden = true;

            [self.ButtonFilter setImage:[UIImage systemImageNamed:@"arrow.up.backward.and.arrow.down.forward"] forState:UIControlStateNormal];
            [self.ButtonFilter setTitle:@"Expand" forState:UIControlStateNormal];
            
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.FilterOptionHeightConstraint.constant)];
            self.TableViewSearchPoiItems.tableFooterView = footerView;
            [self.TableViewSearchPoiItems reloadData];
        }];
        
    }
    lastPoiSearchFooterFilterHeightConstant = self.FilterOptionHeightConstraint.constant;
}

/*
 created date:      12/08/2018
 last modified:     27/03/2019
 remarks:
 */
- (void)didUpdatePoi :(NSString*)Method :(PoiRLM*)Object {
    
    NSURL *url = [self applicationDocumentsDirectory];
    
    NSData *pngData;
    //[self RefreshPoiFilteredData:true];
    if (Object.images.count>0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"KeyImage == %@", [NSNumber numberWithInt:1]];
        RLMResults *filteredArray = [Object.images objectsWithPredicate:predicate];
        ImageCollectionRLM *imgobject;
        if (filteredArray.count==0) {
            imgobject = [Object.images firstObject];
        } else {
            imgobject = [filteredArray firstObject];
        }
        NSURL *imagefile = [url URLByAppendingPathComponent:imgobject.ImageFileReference];
        NSError *err;
        pngData = [NSData dataWithContentsOfURL:imagefile options:NSDataReadingMappedIfSafe error:&err];
        UIImage *image;
        if (pngData!=nil) {
            image =[UIImage imageWithData:pngData];
        }
        else {
            image = [UIImage systemImageNamed:@"command"];
        }
       
        CGSize imagesize = CGSizeMake(100 , 100); // set the width and height
        UIImage *thumbImage = [ToolBoxNSO imageWithImage:image convertToSize:imagesize];
        NSData *imageData =  UIImagePNGRepresentation(thumbImage);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *imagesDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [imagesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/Images/%@/thumbnail.png",Object.key]];
        [imageData writeToFile:dataPath atomically:YES];
        
        
        [AppDelegateDef.PoiBackgroundImageDictionary setObject:thumbImage forKey:Object.key];
        
    }
}

- (void)didDismissPresentingViewController {
}


/*
 created date:      11/06/2018
 last modified:     12/08/2018
 remarks:  Called when new Poi item has been created.
 */
- (void)didCreatePoiFromProjectPassThru :(PoiNSO*)Object {
    [self.SegmentCountries setSelectedSegmentIndex:1];
    [self.SegmentPoiFilterList setSelectedSegmentIndex:0];
    [self.SearchBarPoi setText:Object.name];
    [self searchBar:_SearchBarPoi textDidChange:Object.name];
}


- (void)didCreatePoiFromProject:(NSString *)Key {
    
}

- (void)didUpdateActivityImages :(bool) ForceUpdate {
    
}





@end
