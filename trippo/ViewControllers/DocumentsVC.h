//
//  DocumentsVC.h
//  trippo-app
//
//  Created by andrew glew on 25/02/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityRLM.h"
#import "AttachmentCell.h"
#import "ToolBoxNSO.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DocumentsDelegate <NSObject>
@end

@interface DocumentsVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *TableViewDocuments;
@property (weak, nonatomic) IBOutlet UITextField *TextFieldURL;
@property (weak, nonatomic) IBOutlet UIView *ViewHeader;
@property (nonatomic, weak) id <DocumentsDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *documentitems;
@property RLMResults<AttachmentRLM*> *DocumentCollection;
@property ActivityRLM *Activity;
@property RLMRealm *realm;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *FooterHeightConstraint;

@end

NS_ASSUME_NONNULL_END
