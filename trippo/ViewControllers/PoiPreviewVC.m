//
//  PoiPreviewVCViewController.m
//  trippo
//
//  Created by andrew glew on 20/03/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import "PoiPreviewVC.h"

@interface PoiPreviewVC ()

@end

@implementation PoiPreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.TextViewNotes.text = self.PointOfInterest.privatenotes;
    self.LabelPoi.text = self.PointOfInterest.name;
    self.ImageViewPoi.image = self.headerImage;

    NSString *Address = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@", self.PointOfInterest.fullthoroughfare, self.PointOfInterest.sublocality, self.PointOfInterest.locality, self.PointOfInterest.administrativearea,   self.PointOfInterest.postcode,self.PointOfInterest.country];
    
    Address  = [Address stringByReplacingOccurrencesOfString:@", (null)" withString:@""];
    Address  = [Address stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    Address  = [Address stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@"\n"];
    Address  = [Address stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
    
    Address = [Address stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    self.LabelAddress.text = Address;
    
    self.ViewPoiPopup.layer.cornerRadius=8.0f;
    self.ViewPoiPopup.layer.masksToBounds=YES;
    self.ViewPoiPopup.layer.borderWidth = 1.0f;
    self.ViewPoiPopup.layer.borderColor=[[UIColor colorNamed:@"TrippoColor"]CGColor];
    
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
/*
 created date:      20/03/2019
 last modified:     20/03/2019
 remarks:
 */
- (IBAction)ButtonClosePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}


@end
