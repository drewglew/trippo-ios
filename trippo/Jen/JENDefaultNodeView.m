//
//  JENNodeView.m
//
//  Created by Jennifer Nordwall on 3/14/14.
//  Copyright (c) 2014 Jennifer Nordwall. All rights reserved.
//

#import "JENDefaultNodeView.h"

@interface JENDefaultNodeView ()



@end

@implementation JENDefaultNodeView

@synthesize nodeName = _nodeName;
@synthesize activity = _activity;
@synthesize activityImage = _activityImage;
@synthesize insertNode = _insertNode;
@synthesize nodeSize = _nodeSize;
@synthesize transportType = _transportType;


-(id)initWithParm:(double)NodeSize :(bool)isSelected
{
    self = [super init];
    
    if(self) {
        _nodeSize = NodeSize;
        //_transportType = 0;

        self.activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, NodeSize, NodeSize)];
        //[self.activityView setBackgroundColor:[UIColor greenColor]];
        [self addSubview:self.activityView];
        
        self.nameLabel = [[UILabel alloc] init];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        self.nameLabel.text = @"";
        [self.activityView addSubview:self.nameLabel];
        
        self.activityImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,NodeSize,NodeSize)];
        
        self.activityImageView.layer.cornerRadius = (self.activityImageView.bounds.size.width / 2);
        self.activityImageView.clipsToBounds = YES;
       
        [self.activityImageView setImage:self.activityImage];
        
        [self.activityImageView setTintColor:[UIColor systemIndigoColor]];
        [self.activityImageView setBackgroundColor:[UIColor systemBackgroundColor]];
        [self.activityView addSubview:self.activityImageView];

        if (NodeSize >= 40.0f) {
         
            self.openOptionsButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, NodeSize, NodeSize)];
            [self.openOptionsButton addTarget:self action:@selector(OpenOptionButtonPressed ) forControlEvents:UIControlEventTouchUpInside];
            [self.activityView addSubview: self.openOptionsButton];

            self.activityOptionView = [[JENOptionsView alloc] initWithFrame:CGRectMake(0, 0, NodeSize, NodeSize)];
            [self.activityOptionView setBackgroundColor:[UIColor clearColor]];
            
            if (isSelected) {
                NSLog(@"selected %@", self.activity.name);
            } else {
                 NSLog(@"unselected %@", self.activity.name);
            }
            
            [self.activityOptionView setHidden:!isSelected];
            
            [self addSubview:self.activityOptionView];
            
            UIButton *closeOptionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            closeOptionButton.frame = CGRectMake(0, 0, NodeSize, NodeSize);
            [closeOptionButton addTarget:self action:@selector(CloseOptionButtonPressed ) forControlEvents:UIControlEventTouchUpInside];
            [self.activityOptionView addSubview: closeOptionButton];
 
            UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
            moreButton.frame = CGRectMake(0.0, 0.0, NodeSize/3, NodeSize/3);
            [moreButton addTarget:self action:@selector(MoreButtonPressed ) forControlEvents:UIControlEventTouchUpInside];
            UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:NodeSize/3 weight:UIImageSymbolWeightThin scale:UIImageSymbolScaleSmall];
            [moreButton setImage:[[UIImage systemImageNamed:@"ellipsis.circle.fill" withConfiguration:config] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        
            moreButton.tintColor = [UIColor colorWithRed:218.0f/255.0f green:212.0f/255.0f blue:239.0f/255.0f alpha:1.0];
            [self.activityOptionView addSubview: moreButton];

            UIButton *singlePointOptionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            singlePointOptionButton.frame = CGRectMake(NodeSize - (NodeSize/3), NodeSize - (NodeSize/3), NodeSize/3, NodeSize/3);
            [singlePointOptionButton addTarget:self action:@selector(SinglePointOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [singlePointOptionButton setImage:[[UIImage systemImageNamed:@"smallcircle.circle.fill" withConfiguration:config] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        
            singlePointOptionButton.tintColor = [UIColor colorWithRed:218.0f/255.0f green:212.0f/255.0f blue:239.0f/255.0f alpha:1.0];
            [self.activityOptionView addSubview: singlePointOptionButton];

            UIButton *newOptionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            newOptionButton.frame = CGRectMake(0, NodeSize - (NodeSize/3), NodeSize/3, NodeSize/3);
            [newOptionButton addTarget:self action:@selector(NewOptionButtonPressed ) forControlEvents:UIControlEventTouchUpInside];
            
            [newOptionButton setImage:[[UIImage systemImageNamed:@"plus.circle.fill" withConfiguration:config] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        
            newOptionButton.tintColor =  [UIColor colorWithRed:218.0f/255.0f green:212.0f/255.0f blue:239.0f/255.0f alpha:1.0];
            [self.activityOptionView addSubview: newOptionButton];

            UIButton *travelBackOptionButton = [UIButton buttonWithType:UIButtonTypeCustom];
            travelBackOptionButton.frame = CGRectMake(NodeSize - (NodeSize/3), 0, NodeSize/3, NodeSize/3);
            [travelBackOptionButton addTarget:self action:@selector(TravelBackOptionButtonPressed ) forControlEvents:UIControlEventTouchUpInside];
       
            [travelBackOptionButton setImage:[[UIImage systemImageNamed:@"arrow.down.left.circle.fill" withConfiguration:config] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        
            travelBackOptionButton.tintColor =  [UIColor colorWithRed:218.0f/255.0f green:212.0f/255.0f blue:239.0f/255.0f alpha:1.0];
            [self.activityOptionView addSubview: travelBackOptionButton];
                      
            double TravelBackIndicatorSize = 30.0f;
            TravelBackIndicatorSize = NodeSize / 6.0f;

            self.transportTravelBackIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(-TravelBackIndicatorSize/2, (NodeSize/2) - (TravelBackIndicatorSize/2) , TravelBackIndicatorSize, TravelBackIndicatorSize)];
            [self.transportTravelBackIndicator setImage:[UIImage imageNamed:@"TravelBackIndicator"]];
            [self.activityOptionView addSubview: self.transportTravelBackIndicator];
            [self.transportTravelBackIndicator setHidden:false];
 
        }
    }
    return self;
}
    

-(void)setTravelBack:(NSNumber *)travelBack {
_travelBack = travelBack;
    if (travelBack == [NSNumber numberWithLong:0] || travelBack == nil) {
        [self.transportTravelBackIndicator setHidden:true];
    } else {
        [self.transportTravelBackIndicator setHidden:false];
    }
}

// not used..
-(void)setInsertNode:(bool)insertNode {
     if(insertNode != _insertNode) {
         insertNode = _insertNode;
     }
}

-(void)setNodeName:(NSString *)nodeName {
    if(nodeName != _nodeName) {
        _nodeName = nodeName;
        self.nameLabel.text = @"";
        
        if ([nodeName isEqualToString:@"Trip"]) {
            self.openOptionsButton.enabled = false;
        }
        
        double sizeOfNode = _nodeSize;
        if (sizeOfNode == 0.0f) {
            sizeOfNode = 75.0f;
        }
 
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                sizeOfNode,
                                sizeOfNode);

        self.nameLabel.frame = CGRectMake(self.bounds.origin.x + 5,
                                          self.bounds.origin.y + 5,
                                          self.bounds.size.width - 10,
                                          self.bounds.size.height - 10);
    }
}


-(void)setNodeSize:(double)nodeSize {
    if(nodeSize != _nodeSize) {
        _nodeSize = nodeSize;
    }
}

// called 7 times
-(void)setActivityImage:(UIImage *)activityImage {
    if(activityImage != _activityImage) {
        _activityImage = activityImage;
        [_activityImageView setImage:activityImage];
    }
}

// called 7 times??
-(void)setActivity:(ActivityRLM *)activity {
    if(activity != _activity) {
        _activity = activity;
    }
}

- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}
 
         
-(void) CloseOptionButtonPressed {
    NSLog(@"you pressed the close option button");
    TravelPlanVC *currentTopVC = (TravelPlanVC*)[self currentTopViewController];
    currentTopVC.NodeSelectedActivityKey = @"";
    if (self.activityOptionView!=nil) {
        [self.activityOptionView setHidden: true];
    }
}

-(void) MoreButtonPressed {
    NSLog(@"you pressed the more button");
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TravelPlanDetailVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"TravelPlanDetailViewController"];
    controller.delegate = self;
    controller.Activity = self.activity;
    controller.ActivityImage = self.activityImage;
    [controller setModalPresentationStyle:UIModalPresentationOverFullScreen];
    TravelPlanVC *currentTopVC = (TravelPlanVC*)[self currentTopViewController];
    controller.realm = currentTopVC.realm;
    [currentTopVC presentViewController:controller animated:YES completion:nil];
}


-(void) SinglePointOptionButtonPressed: (UIButton*) sender {
    NSLog(@"you pressed the single point option button");
    
    //[sender setEnabled:false];
    TravelPlanVC *currentTopVC = (TravelPlanVC*)[self currentTopViewController];
    [currentTopVC singlePointDistances :self.activity.poikey :self.activity];
    
}

-(void) TravelBackOptionButtonPressed {
    NSLog(@"you pressed the travel back option button");
    
    TravelPlanVC *currentTopVC = (TravelPlanVC*)[self currentTopViewController];
    
    currentTopVC.NodeSelectedActivityKey = self.activity.key;
    
    
    [currentTopVC.realm beginWriteTransaction];
    if (self.travelBack == [NSNumber numberWithLong:1]) {
        self.travelBack = [NSNumber numberWithLong:0];
        self.activity.travelbackflag = [NSNumber numberWithLong:0];
    } else {
        self.travelBack = [NSNumber numberWithLong:1];
        self.activity.travelbackflag = [NSNumber numberWithLong:1];
    }
    NSLog(@"%@", self.activity.travelbackflag);
    
    [currentTopVC.realm commitWriteTransaction];
}
                                                     
-(void) NewOptionButtonPressed {
    NSLog(@"you pressed the new option button");
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PoiSearchVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"PoiListingViewController"];
    controller.delegate = self;
    controller.Activity = [[ActivityRLM alloc] init];

    controller.transformed = false;
    [controller setModalPresentationStyle:UIModalPresentationOverFullScreen];
    TravelPlanVC *currentTopVC = (TravelPlanVC*)[self currentTopViewController];
    controller.realm = currentTopVC.realm;
    [currentTopVC presentViewController:controller animated:YES completion:nil];
    controller.TripItem = currentTopVC.Trip;
    controller.Activity.state = self.activity.state;
    controller.Activity.startdt = self.activity.startdt;
    controller.Activity.enddt = self.activity.enddt;
    controller.newitem = true;
}



-(void) OpenOptionButtonPressed{
    TravelPlanVC *currentTopVC = (TravelPlanVC*)[self currentTopViewController];
    currentTopVC.NodeSelectedActivityKey = self.activity.key;
    /* first find container with access to nodes */
    UIView * myView=(UIView*)self;
    while ((myView= [myView superview])) {
        if([myView isKindOfClass:[JENTreeView class]]) {
            /* call method that then searches subviews that are within class optionviews*/
            [self hideVisibleOptionViews :myView];
        }
    }
    if (self.activityOptionView!=nil) {
        [self.activityOptionView setHidden: false];
    }
}

/* recursive method to check all subviews of container */
- (void)hideVisibleOptionViews:(UIView*)inView
{
    for (UIView *view in inView.subviews)
    {
        if([view isKindOfClass:[JENOptionsView class]])
           [view setHidden: TRUE];
        else
           [self hideVisibleOptionViews:view];
    }
}

- (void)didCreatePoiFromProject:(PoiNSO *)Object {
     NSLog(@"this is a trigger!");
}

- (void)didUpdatePoi:(NSString *)Method :(PoiNSO *)Object {
    
    NSLog(@"this is a trigger!");
    
}

- (void)didUpdateActivityImages :(bool) ForceUpdate {
    
    
    
}


@end
