//
//  InfoVC.h
//  travelme
//
//  Created by andrew glew on 13/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoVC : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *LabelVersion;
@property (weak, nonatomic) IBOutlet UILabel *LabelMainTitle;
@property (weak, nonatomic) IBOutlet UILabel *LabelCreditsTitle;
@property (weak, nonatomic) IBOutlet UIButton *ButtonBack;
@property (weak, nonatomic) IBOutlet UITextView *TextViewContent;

@end
