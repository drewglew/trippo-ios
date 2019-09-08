//
//  SearchResultListCell.h
//  travelme
//
//  Created by andrew glew on 28/04/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *LabelSearchItem;
@property (weak, nonatomic) IBOutlet UILabel *LabelSearchCountryItem;
@property (strong, nonatomic) NSString *subTitle;

@end
