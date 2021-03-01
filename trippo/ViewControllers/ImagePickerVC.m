//
//  ImagePickerVC.m
//  travelme
//
//  Created by andrew glew on 10/06/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

/*
 created date:      10/06/2018
 last modified:     11/06/2018
 remarks:           TODO - send array of images back to the calling viewcontroller.
 */

#import "ImagePickerVC.h"

@interface ImagePickerVC ()

@end

@implementation ImagePickerVC
CGFloat ImagePickerFooterFilterHeightConstant;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ImageCollectionView.delegate = self;
    self.imageitems = [[NSMutableArray alloc] init];
    if (!self.wikiimages) {
        self.LabelPoiName.text = [NSString stringWithFormat:@"Photos nearby %@",self.PointOfInterest.name];
    } else {
        self.LabelPoiName.text = [NSString stringWithFormat:@"Web Photos of %@",self.PointOfInterest.name];
    }
  
    ImagePickerFooterFilterHeightConstant = self.FooterWithTextConstraint.constant;
    
    self.ViewLoading.layer.cornerRadius=8.0f;
    self.ViewLoading.layer.masksToBounds=YES;
    self.ViewLoading.layer.borderWidth = 1.0f;
    self.ViewLoading.layer.borderColor=[[UIColor colorNamed:@"TrippoColor"]CGColor];

    
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    queueThread = [[NSThread alloc] initWithTarget:self
                                                   selector:@selector( LoadImageData )
                                                     object:nil ];
    
    [queueThread start ];
}

/*
 created date:      10/06/2018
 last modified:     23/02/2021
 remarks:  This runs inside its own thread - one of the most complex methods in the application.
 */
-(void) LoadImageData {


    if (!self.wikiimages) {
        CLLocationCoordinate2D PoiCoord = CLLocationCoordinate2DMake([self.PointOfInterest.lat doubleValue], [self.PointOfInterest.lon doubleValue]);
        CLLocationCoordinate2D Coord;
        
        CLLocation *PoiLocation = [[CLLocation alloc] initWithLatitude:PoiCoord.latitude longitude:PoiCoord.longitude];
        int MaxNumberOfPhotos = 200;
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
            
            double distance = [location distanceFromLocation:PoiLocation];
            
            if (distance < [self.distance doubleValue]) {

                if (PhotoCounter < MaxNumberOfPhotos) {
                    NSLog(@"COORDINATES: %f , %f",Coord.latitude, Coord.longitude);
                    NSLog(@"DATE: %@", item.creationDate);
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
                            [self.imageitems addObject:img];
                            dispatch_async(dispatch_get_main_queue(), ^(){
                                 [self.ImageCollectionView reloadData];
                            });
                            
                        }
                    }];
                    PhotoCounter++;
                }
                
                if([[NSThread currentThread] isCancelled])
                    break;
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self.LabelPhotoCounter setText:[NSString stringWithFormat:@"%lu photos found", (unsigned long)self.imageitems.count]];
                });
            }
            
        }
        NSLog(@"number of results:=%lu", (unsigned long)self.imageitems.count);
        dispatch_async(dispatch_get_main_queue(), ^(){
            self.ButtonStopSearching.hidden = true;
            
            [self.ActivityLoading stopAnimating];
            [self.ImageCollectionView reloadData];
        });
    } else {
            /*
             Obtain Wiki data based on name.
             https://en.wikipedia.org/api/rest_v1/page/media-list/Göteborg
             */
            NSArray *parms = [self.PointOfInterest.wikititle componentsSeparatedByString:@"~"];
            NSString *url = [NSString stringWithFormat:@"https://%@.wikipedia.org/api/rest_v1/page/media-list/%@",[parms objectAtIndex:0] , [parms objectAtIndex:1]];
            
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [self fetchFromWikiApiMediaByTitle:url withDictionary:^(NSDictionary *data) {

                NSDictionary *items = [data objectForKey:@"items"];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self.LabelPhotoCounter setText:[NSString stringWithFormat:@"Checking %lu Web Assets", (unsigned long)items.count]];
                });
                __block int AssetCounter = 0;
                
                
                // only load thumbnails here!!
                
                /* we can process all later, but am only interested in the closest wiki entry */
                for (NSDictionary *item in items) {
                    int MaxNumberOfPhotos = 200;

                    NSDictionary *DescriptionItem = [item objectForKey:@"caption"];
                    
                    /* no more than 200 photos! */
                    if (self.imageitems.count < MaxNumberOfPhotos) {
                        NSArray *SourceSet = [item objectForKey:@"srcset"];
                        
                        NSDictionary *SourceItem = [SourceSet objectAtIndex:0];
                        
                        NSString *AssetUrl = [NSString stringWithFormat:@"https:%@",[SourceItem valueForKey:@"src"]];
                        
                        [self downloadImageFrom:[NSURL URLWithString: AssetUrl] completion:^(UIImage *image) {

                            AssetCounter ++;

                            if (image!=nil) {
                                ImageNSO *imageitem = [[ImageNSO alloc] init];
                                imageitem.originalsource = AssetUrl;
                                
                                if (image.size.height > image.size.width) {
                                        CGRect aRect = CGRectMake(0,(image.size.height / 2) - (image.size.width / 2), image.size.width, image.size.width);
                                        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], aRect);
                                        image = [UIImage imageWithCGImage:imageRef];
                                        CGImageRelease(imageRef);
                                } else if (image.size.height < image.size.width) {
                                        CGRect aRect = CGRectMake((image.size.width / 2) - (image.size.height / 2), 0, image.size.height, image.size.height);
                                        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], aRect);
                                        image = [UIImage imageWithCGImage:imageRef];
                                        CGImageRelease(imageRef);
                                }
                                imageitem.Image = [ToolBoxNSO imageWithImage:image scaledToSize:self.ImageSize];
                                if (DescriptionItem.count>0) {
                                    imageitem.Description = [DescriptionItem objectForKey:@"text"];
                                }
                                imageitem.selected = false;
                                [self.imageitems addObject:imageitem];
                                // keep the collection view updated with the new image
                                [self.ImageCollectionView reloadData];
                                    
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^(){
                                [self.LabelPhotoCounter setText:[NSString stringWithFormat:@"%lu photos found inside %lu Web Assets", (unsigned long)self.imageitems.count,(unsigned long)items.count]];
                                 if (AssetCounter==items.count) {
                                     self.ButtonStopSearching.hidden = true;
                                     
                                     [self.ActivityLoading stopAnimating];
                                 }
                             });

                        }];
                    }
                    if([[NSThread currentThread] isCancelled])
                        break;
            }
        }];
    }
}

/*
 created date:      14/07/2018
 last modified:     14/07/2018
 remarks:
 */
- (void)downloadImageFrom:(NSURL *)path completion:(void (^)(UIImage *image))completionBlock {
    dispatch_queue_t queue = dispatch_queue_create("Image Download", 0);
    dispatch_async(queue, ^{
        NSData *data = [[NSData alloc] initWithContentsOfURL:path];
        dispatch_async(dispatch_get_main_queue(), ^{

            if(data) {
                completionBlock([[UIImage alloc] initWithData:data]);
            } else {
                completionBlock(nil);
            }
        });
    });
}


/*
 created date:      14/07/2018
 last modified:     14/07/2018
 remarks:
 */
-(void)fetchFromWikiApiMediaByTitle:(NSString *)url withDictionary:(void (^)(NSDictionary* data))dictionary{
    
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:data
                                                                                              options:0
                                                                                                error:NULL];
                                      dictionary(dicData);
                                  }];
    [task resume];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 created date:      10/06/2018
 last modified:     10/06/2018
 remarks:
 */
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageitems.count;
}

/*
 created date:      10/06/2018
 last modified:     10/06/2018
 remarks:
 */
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"ImageItemCell" forIndexPath:indexPath];
    ImageNSO *img = [self.imageitems objectAtIndex:indexPath.row];
    cell.ViewSelectedBorder.hidden = !img.selected;
    cell.ImageSelected.hidden = !img.selected;
    [cell.Image setImage:img.Image];
    return cell;
}


/*
 created date:      10/06/2018
 last modified:     01/09/2018
 remarks:
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageNSO *img = [self.imageitems objectAtIndex:indexPath.row];
    img.selected = !img.selected;
    
    [self.LabelPhotoCounter setText:[NSString stringWithFormat:@"%@", img.Description]];
    
    [self.ImageCollectionView reloadData];
}

/*
 created date:      10/06/2018
 last modified:     10/06/2018
 remarks: manages the dynamic width of the cells.
 */
-(CGSize)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout* )collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    CGFloat collectionWidth = self.ImageCollectionView.frame.size.width;
    float cellWidth = collectionWidth/4.0f;
    CGSize size = CGSizeMake(cellWidth,cellWidth);
    
    return size;
}


/*
 created date:      05/02/2019
 last modified:     05/02/2019
 remarks:
 */
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if (velocity.y > 0 && self.FooterWithTextConstraint.constant == ImagePickerFooterFilterHeightConstant){
        NSLog(@"scrolling down");
        
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.FooterWithTextConstraint.constant = 0.0f;
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    if (velocity.y < 0  && self.FooterWithTextConstraint.constant == 0.0f){
        NSLog(@"scrolling up");
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             self.FooterWithTextConstraint.constant = ImagePickerFooterFilterHeightConstant;
                             [self.view layoutIfNeeded];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}


- (void)didAddImages :(NSMutableArray*)ImageCollection {
    
}

/*
 created date:      11/06/2018
 last modified:     08/09/2019
 remarks:           it gets the original image, but doesn't dismiss the view instantly.
                    BUG FOR EACH ADDITIONAL PHOTO ADDED DUPLICATES * AMT
 */
- (IBAction)AddSelectionPressed:(id)sender {

    [queueThread cancel];
    queueThread = nil;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"selected = %@", @YES];
    NSMutableArray *imageCollection = [NSMutableArray arrayWithArray:[self.imageitems filteredArrayUsingPredicate:pred]];

    
    if (self.wikiimages && [self.SwitchHighQuality isOn]) {
        
        // This will be a view suspending all user activity until task is completed.
        [self.ActivityLoading startAnimating];
        self.VisualEffectViewWaiting.hidden = false;
        
        NSArray *AllowedTypes = [[NSArray alloc] initWithObjects:@"png",@"gif",@"jpg",@"jpeg",@"bmp",nil];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@ AND SELF != nil", AllowedTypes];

        for (ImageNSO *item in imageCollection) {
        
            bool typefound = [predicate evaluateWithObject:[[item.originalsource pathExtension] lowercaseString]];
            if (!typefound) {
                if (item == [self.imageitems lastObject]) {
                    self.VisualEffectViewWaiting.hidden = true;
                    [self.ActivityLoading stopAnimating];
                }
                continue;
            }
            NSURL *url = [NSURL URLWithString: item.originalsource];
            [self downloadImageFrom:url completion:^(UIImage *image) {
                
                   
                if (image!=nil) {
                    UIImage *squareimage = image;

                    if (image.size.height > image.size.width) {
                        CGRect aRect = CGRectMake(0,(image.size.height / 2) - (image.size.width / 2), image.size.width, image.size.width);
                        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], aRect);
                        squareimage = [UIImage imageWithCGImage:imageRef];
                        CGImageRelease(imageRef);
                    } else if (image.size.height < image.size.width) {
                        CGRect aRect = CGRectMake((image.size.width / 2) - (image.size.height / 2), 0, image.size.height, image.size.height);
                        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], aRect);
                        squareimage = [UIImage imageWithCGImage:imageRef];
                        CGImageRelease(imageRef);
                    }
                    
                    /* It is possible from wikipedia the image is huge */
                    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
                    if (squareimage.size.width > screenSize.width * 2.0f) {
                        CGSize newSize = CGSizeMake(screenSize.width * 2.0f, screenSize.width * 2.0f);
                        squareimage = [ToolBoxNSO imageWithImage:squareimage scaledToSize:newSize];
                    }
                    
                    item.Image = squareimage;
                    if (item == [imageCollection lastObject]) {
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            self.VisualEffectViewWaiting.hidden = true;
                            [self.ActivityLoading stopAnimating];
                            [self.delegate didAddImages :imageCollection];
                            [self dismissViewControllerAnimated:YES completion:Nil];
                        });
                    }
                }
            }];
        }
    } else {
        [self.delegate didAddImages :imageCollection];
        [self dismissViewControllerAnimated:YES completion:Nil];
    }
    
}

- (IBAction)StopSearchingPressed:(id)sender {
    [queueThread cancel];
    queueThread = nil;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"Image!=NULL"];
    self.imageitems = [NSMutableArray arrayWithArray:[self.imageitems filteredArrayUsingPredicate:pred]];
    self.ButtonStopSearching.hidden = true;

    [self.ActivityLoading startAnimating];
    [self.ImageCollectionView reloadData];
    
}

/*
 created date:      10/06/2018
 last modified:     11/06/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [queueThread cancel];
    queueThread = nil;
    
    [self dismissViewControllerAnimated:YES completion:Nil];
    
}
/*
 created date:      02/02/2019
 last modified:     02/02/2019
 remarks:
 */
- (IBAction)SwitchQualityChanged:(id)sender {
    
    
    
}
@end
