//
//  InfoVC.m
//  travelme
//
//  Created by andrew glew on 13/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "InfoVC.h"

@interface InfoVC ()

@end

@implementation InfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.LabelVersion.text = [NSString stringWithFormat: @"%@ build %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
    
    UIColor *color = [UIColor secondaryLabelColor];
    UIColor *secondaryColor = [UIColor secondaryLabelColor];

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.TextViewContent.text];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];

    [paragraphStyle setLineSpacing:5];
    [attrString beginEditing];

    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, self.TextViewContent.text.length)];

    [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.TextViewContent.text.length)];


     [attrString addAttribute:NSForegroundColorAttributeName value:secondaryColor range:NSMakeRange(0, self.TextViewContent.text.length)];

    NSRange range = [self.TextViewContent.text rangeOfString:@"Credits"];
    
    if(range.location != NSNotFound)
    {
         [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:24 weight: UIFontWeightHeavy] range:NSMakeRange(range.location, 7)];
         [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(range.location, 7)];
    }
    [attrString endEditing];

    self.TextViewContent.attributedText = attrString;
    self.TextViewContent.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorNamed:@"TrippoColor"]};
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
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

@end
