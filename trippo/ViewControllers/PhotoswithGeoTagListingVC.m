//
//  PhotoswithGeoTagListingVC.m
//  trippo
//
//  Created by andrew glew on 01/12/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PhotoswithGeoTagListingVC.h"

@interface PhotoswithGeoTagListingVC ()

@end

@implementation PhotoswithGeoTagListingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ImageItems = [[NSMutableArray alloc] init];
    self.ImageSize = CGSizeMake(100 , 100);
    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    queueThread = [[NSThread alloc] initWithTarget:self
                                          selector:@selector( LoadPhotoData )
                                            object:nil ];
    
    [queueThread start ];
}

/*
 created date:      01/12/2018
 last modified:     01/12/2018
 remarks:
 */
-(void) LoadPhotoData {

    
    int MaxNumberOfPhotos = 500;
    int PhotoCounter = 0;

    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode   = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = YES;
    options.networkAccessAllowed = YES;
    
    for (PHAsset *item in result) {
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:item.location.coordinate.latitude longitude:item.location.coordinate.longitude];
        
        
        if (PhotoCounter < MaxNumberOfPhotos) {
            NSLog(@"COORDINATES: %f , %f",location.coordinate.latitude , location.coordinate.longitude);
            NSLog(@"DATE: %@", item.creationDate);
            NSLog(@"DESCRIPTION: %@", item.description);
            NSLog(@"STUFF: %@", item.location.description);
            
            if (item.location!=nil) {
                //__block UIImage *img;
                
               
                    PHImageManager *manager = [PHImageManager defaultManager];
                    //PHImageContentModeDefault
                    [manager requestImageForAsset:item targetSize:self.ImageSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^void(UIImage *image, NSDictionary *info) {
                        if(image){
                            ImageNSO *img = [[ImageNSO alloc] init];
                            img.creationdate = item.creationDate;
                            NSDateFormatter *dtformatter = [[NSDateFormatter alloc] init];
                            [dtformatter setDateFormat:@"EEE MMM dd YYYY, HH:mm"];
                            img.Description = [NSString stringWithFormat:@"Own photo taken %@",[dtformatter stringFromDate:item.creationDate]];
                            img.Image = image;
                            img.selected = false;
                            [self.ImageItems addObject:img];
                            dispatch_async(dispatch_get_main_queue(), ^(){
                                //    [self.ImageCollectionView reloadData];
                            });
                        }
                    }];
                
                PhotoCounter++;
                }
                     
            
        }
        
        if([[NSThread currentThread] isCancelled])
            break;
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            //[self.LabelPhotoCounter setText:[NSString stringWithFormat:@"%lu photos found", (unsigned long)self.imageitems.count]];
        });
        
        
    }
    NSLog(@"number of results:=%lu", (unsigned long)self.ImageItems.count);
    /*dispatch_async(dispatch_get_main_queue(), ^(){
        self.ButtonStopSearching.hidden = true;
        
        self.ActivityLoading.hidden = true;
        [self.ImageCollectionView reloadData];
    });*/
}



- (IBAction)BackPressed:(id)sender {
   [self dismissViewControllerAnimated:YES completion:Nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
