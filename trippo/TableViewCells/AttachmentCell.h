//
//  AttachmentCell.h
//  trippo-app
//
//  Created by andrew glew on 24/02/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttachmentRLM.h"

NS_ASSUME_NONNULL_BEGIN

@interface AttachmentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *LabelNotes;
@property (weak, nonatomic) IBOutlet UILabel *LabelUploadedDt;
@property (weak, nonatomic) IBOutlet UILabel *LabelInfo;
@property (weak, nonatomic) IBOutlet UIButton *ButtonAddNew;
@property (strong, nonatomic) AttachmentRLM *document;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewChecked;
//@property (assign) bool isAttachmentSelected;
@end

NS_ASSUME_NONNULL_END
