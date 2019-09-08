//
//  WikiVC.m
//  travelme
//
//  Created by andrew glew on 13/06/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "WikiVC.h"

@interface WikiVC ()

@end

@implementation WikiVC
CGFloat WikiFooterFilterHeightConstant;
/*
 created date:      13/06/2018
 last modified:     04/02/2019
 remarks:           Need to make sure we create folder
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.scrollView.delegate = self;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *dataPath = [documentDirectory stringByAppendingPathComponent:@"/WikiDocs/"];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];

    NSString *wikiDataFilePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/WikiDocs/%@.pdf",self.PointOfInterest.key]];
    
    if (![fileManager fileExistsAtPath:wikiDataFilePath]){
        /* generate a PDF of WikiPage */
        if ([self checkInternet]) {
            NSString *TitleText = [self.PointOfInterest.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            [self MakeWikiFile :TitleText :wikiDataFilePath :[AppDelegateDef.CountryDictionary objectForKey:AppDelegateDef.HomeCountryCode]];
        } else {
            NSLog(@"Device is not connected to the Internet");
        }
    } else {
        /* present the WikiPage that is saved already */
        NSString *HomeLanguage = [[AppDelegateDef.CountryDictionary objectForKey:AppDelegateDef.HomeCountryCode] lowercaseString];
        NSString *LocalLanguage = [[AppDelegateDef.CountryDictionary objectForKey:self.PointOfInterest.countrycode] lowercaseString];
        NSString *PageLanguage =  [self.PointOfInterest.wikititle substringWithRange:NSMakeRange(0, 2)];
        
        if ([PageLanguage isEqualToString:HomeLanguage]) {
            [self.SegmentLanguageOption setSelectedSegmentIndex:0];
        } else if ([PageLanguage isEqualToString:LocalLanguage]) {
            // segment index = 1
            [self.SegmentLanguageOption setSelectedSegmentIndex:1];
        } else {
            [self.SegmentLanguageOption setSelectedSegmentIndex:2];
            // segment index = 2
        }

        NSURL *targetURL = [NSURL fileURLWithPath:wikiDataFilePath];
        NSData *data = [NSData dataWithContentsOfURL:targetURL];
        [self.webView loadData:data MIMEType:@"application/pdf" characterEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
    }
    WikiFooterFilterHeightConstant = self.FooterWithSegmentConstraint.constant;
    self.webView.hidden=false;
    // Do any additional setup after loading the view.
    self.ViewLoading.layer.cornerRadius=8.0f;
    self.ViewLoading.layer.masksToBounds=YES;
    self.ViewLoading.layer.borderWidth = 1.0f;
    self.ViewLoading.layer.borderColor=[[UIColor colorNamed:@"TrippoColor"]CGColor];

    
}

/*
 created date:      13/06/2018
 last modified:     12/10/2018
 remarks:  search by name first?  if nothing found then by closest location?
 */
-(bool)SearchWikiDocByLocation :(NSString *)wikiPathName :(NSString *)language {
    bool RetValue = false;
    
    /*
     Obtain Wiki records based on coordinates & local language.  (radius is in meters, we should use same range as type used to search photos)
     https://en.wikipedia.org/w/api.php?action=query&list=geosearch&gsradius=1000&gscoord=52.5208626606277|13.4094035625458&format=json
    
     Or search by name with redirect.
     https://en.wikipedia.org/w/api.php?action=query&titles=Göteborg&redirects&format=jsonfm&formatversion=2
     */

    NSString *url = [NSString stringWithFormat:@"https://%@.wikipedia.org/w/api.php?action=query&list=geosearch&gsprop=type|name|dim|country|region|globe&gsradius=%@&gscoord=%@|%@&format=json&redirects",language, self.gsradius, self.PointOfInterest.lat, self.PointOfInterest.lon];
    
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self fetchFromWikiApiByLocation:url withDictionary:^(NSDictionary *data) {

            NSDictionary *query = [data objectForKey:@"query"];
            NSDictionary *geosearch =  [query objectForKey:@"geosearch"];
            
            NSLog(@"%@",geosearch);
            
            NSString *titleText = @"";
            
            /* we can process all later, but am only interested in the closest wiki entry */
            for (NSDictionary *item in geosearch) {

                titleText = [[item valueForKey:@"title"] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    self.PointOfInterest.wikititle =  [NSString stringWithFormat:@"%@~%@",language,titleText];
                    
                    [self.delegate updatePoiFromWikiActvity :self.PointOfInterest];
                    [self MakeWikiFile :titleText :wikiPathName :language];
                });
                    
                /*
                 https://en.wikipedia.org/api/rest_v1/page/pdf/Berlin_Alexanderplatz_station
                 */
                break;
                
            }
    }];

    return RetValue;
}

/*
 created date:      16/06/2018
 last modified:     18/07/2018
 remarks:  search by name first?  if nothing found then by closest location?
 */
-(void) MakeWikiFile :(NSString*)Title :(NSString *)wikiPathName :(NSString *)language {
NSString *urlstring = [NSString stringWithFormat:@"https://%@.wikipedia.org/api/rest_v1/page/pdf/%@",language,Title];
NSURL *url = [NSURL URLWithString:[urlstring stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
[self.ActivityIndicator startAnimating];
[self.ViewLoading setHidden:FALSE];
    
NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                      dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          
                                          if ([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]) {
                                              NSLog(@"error");
                                              self.PointOfInterest.wikititle=@"";
                                              
                                              dispatch_async(dispatch_get_main_queue(), ^(void){
                                                  self.LabelInfo.text = @"An error occurred in download PDF Wiki service";
                                                  [self.ActivityIndicator stopAnimating];
                                                  [self.ViewLoading setHidden:TRUE];
                                                   self.webView.hidden = true;
                                              });
                                          } else {

                                              [data writeToFile:wikiPathName options:NSDataWritingAtomic error:&error];
                                              
                                              NSLog(@"TEST");
                                              
                                              dispatch_async(dispatch_get_main_queue(), ^(void){
                                                  
                                                  self.PointOfInterest.wikititle =  [NSString stringWithFormat:@"%@~%@",language,Title];
                                                  
                                                  [self.delegate updatePoiFromWikiActvity :self.PointOfInterest];
                                                  
                                                  [self.webView loadData:data MIMEType:@"application/pdf" characterEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
                                                  
                                                  self.LabelInfo.text = @"Download completed.";
                                                  [self.ActivityIndicator stopAnimating];
                                                  [self.ViewLoading setHidden:TRUE];
                                                  
                                                  self.webView.hidden=false;
                                                  
                                              });
                                             
                                          }
                                      }];

        [downloadTask resume];
}


/*
 created date:      04/02/2019
 last modified:     04/02/2019
 remarks:  Wiki PDF generator not working..
 */
-(void) MakeWikiFileV2 :(NSString*)Title :(NSString *)wikiPathName :(NSString *)language {
    NSString *urlstring = [NSString stringWithFormat:@"https://%@.wikipedia.org/api/rest_v1/page/html/%@",language,Title];
    NSURL *url = [NSURL URLWithString:[urlstring stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
                                              if ([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]) {
                                                  NSLog(@"error");
                                                  self.PointOfInterest.wikititle=@"";
                                                  dispatch_async(dispatch_get_main_queue(), ^(void){
                                                      
                                                      self.PointOfInterest.wikititle =  [NSString stringWithFormat:@"%@~%@",language,Title];
                                                      
                                                      //[self.delegate updatePoiFromWikiActvity :self.PointOfInterest];
                                                      
                                                      [self.webView loadData:data MIMEType:@"application/html" characterEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
                                                      
                                                      self.webView.hidden=false;
                                                      
                                                  });
                                                      
                                                      
                                                      
                                                      
                                                  
                                              } else {
 
                                                  /*
                                                  [data writeToFile:wikiPathName options:NSDataWritingAtomic error:&error];
                                                  */
                                                  dispatch_async(dispatch_get_main_queue(), ^(void){
                                                      
                                                      self.PointOfInterest.wikititle =  [NSString stringWithFormat:@"%@~%@",language,Title];
                                                      
                                                      [self.delegate updatePoiFromWikiActvity :self.PointOfInterest];
                                                      
                                                      [self.webView loadData:data MIMEType:@"application/html" characterEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@""]];
                                                      
                                                      self.webView.hidden=false;
                                                      
                                                  });
                                                  
                                              }
                                          }];
    
    [downloadTask resume];
}




/*
 created date:      13/06/2018
 last modified:     15/06/2018
 remarks:
 */
-(void)fetchFromWikiApiByLocation:(NSString *)url withDictionary:(void (^)(NSDictionary* data))dictionary{
    
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


/*
 created date:      15/06/2018
 last modified:     09/10/2018
 remarks:
 */
- (IBAction)UpdateWikiPagePressed:(id)sender {
    
    if ([self checkInternet]) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        
        NSString *wikiDataFilePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/WikiDocs/%@.pdf",self.PointOfInterest.key]];
        
        NSError *error = nil;
        [fileManager removeItemAtPath:wikiDataFilePath error:&error];
        
        NSString *PreferredLanguage;
        if (self.SegmentLanguageOption.selectedSegmentIndex == 0) {
            PreferredLanguage = [AppDelegateDef.CountryDictionary objectForKey:AppDelegateDef.HomeCountryCode];
        } else if (self.SegmentLanguageOption.selectedSegmentIndex == 1) {
            PreferredLanguage = [AppDelegateDef.CountryDictionary objectForKey:self.PointOfInterest.countrycode];
        } else {
            PreferredLanguage = @"en";
        }
        
        if (![fileManager fileExistsAtPath:wikiDataFilePath]){
            [self SearchWikiDocByLocation :wikiDataFilePath  :PreferredLanguage];
        }
    } else {
        NSLog(@"Device is not connected to the Internet");
    }
    
}

/*
 created date:      16/06/2018
 last modified:     12/10/2018
 remarks:
 */
- (IBAction)UpdateWikiPageByTitlePressed:(id)sender {
    
    if ([self checkInternet]) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        
        NSString *wikiDataFilePath = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/WikiDocs/%@.pdf",self.PointOfInterest.key]];
        
        NSError *error = nil;
        [fileManager removeItemAtPath:wikiDataFilePath error:&error];
        
        NSString *PreferredLanguage;
        if (self.SegmentLanguageOption.selectedSegmentIndex == 0) {
            PreferredLanguage = [AppDelegateDef.CountryDictionary objectForKey:AppDelegateDef.HomeCountryCode];
        } else if (self.SegmentLanguageOption.selectedSegmentIndex == 1) {
            PreferredLanguage = [AppDelegateDef.CountryDictionary objectForKey:self.PointOfInterest.countrycode];
        } else {
            PreferredLanguage = @"en";
        }
        
        NSString *TitleText = [self.PointOfInterest.name stringByReplacingOccurrencesOfString:@" " withString:@"_"];

        self.PointOfInterest.wikititle = [NSString stringWithFormat:@"%@~%@",PreferredLanguage,TitleText];
        
        [self.delegate updatePoiFromWikiActvity :self.PointOfInterest];

        [self MakeWikiFile :TitleText :wikiDataFilePath :PreferredLanguage];
    } else {
        NSLog(@"Device is not connected to the Internet");
    }
    
}

/*
 created date:      06/02/2019
 last modified:     06/02/2019
 remarks:
 */
-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                    withVelocity:(CGPoint)velocity
             targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if (velocity.y > 0 && self.FooterWithSegmentConstraint.constant == WikiFooterFilterHeightConstant){
        NSLog(@"scrolling down");
        
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.FooterWithSegmentConstraint.constant = 0.0f;
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             
                         }];
    }
    if (velocity.y < 0  && self.FooterWithSegmentConstraint.constant == 0.0f){
        NSLog(@"scrolling up");
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             self.FooterWithSegmentConstraint.constant = WikiFooterFilterHeightConstant;
                             [self.view layoutIfNeeded];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}


- (bool)checkInternet
{
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        return false;
    }
    else
    {
        //connection available
        return true;
    }
    
}



/*
 created date:      13/07/2018
 last modified:     13/07/2018
 remarks:
 */
- (void)updatePoiFromWikiActvity :(PoiNSO*)PointOfInterest {
    
}

/*
 created date:      13/06/2018
 last modified:     13/06/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {

    [self dismissViewControllerAnimated:YES completion:Nil];
}

@end
