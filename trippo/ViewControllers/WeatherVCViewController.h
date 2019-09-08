//
//  WeatherVCViewController.h
//  trippo
//
//  Created by andrew glew on 23/06/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "WeatherCell.h"
#import "WeatherRLM.h"
#import "PoiRLM.h"
#import "ActivityRLM.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WeatherDelegate <NSObject>
@end

@interface WeatherVCViewController : UIViewController <UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *ButtonClose;
@property (nonatomic, weak) id <WeatherDelegate> delegate;
@property ActivityRLM *ActivityItem;
@property (strong, nonatomic) NSMutableArray *weathersections;
@property (strong, nonatomic) NSArray *timeintervals;
@property RLMRealm *realm;
@property (weak, nonatomic) IBOutlet UITableView *TableViewWeatherListing;

@end

NS_ASSUME_NONNULL_END
