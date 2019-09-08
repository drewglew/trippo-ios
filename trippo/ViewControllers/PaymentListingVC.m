//
//  PaymentListingVC.m
//  travelme
//
//  Created by andrew glew on 08/05/2018.
//  Copyright © 2018 andrew glew. All rights reserved.
//

#import "PaymentListingVC.h"

@interface PaymentListingVC ()
@property RLMNotificationToken *notification;
@end

@implementation PaymentListingVC

/*
 created date:      09/05/2018
 last modified:     12/08/2019
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
  
    
    /* going to receive an array of existing payments and what category */
    
    NSString *Title = [NSString stringWithFormat:@"Expenses\n%@", self.ActivityItem.name];
    if (self.TripItem == nil) {
        self.ViewTripAmount.hidden = true;
    } else {
        Title = [NSString stringWithFormat:@"Trip Expenses\n%@", self.TripItem.name];
        self.ViewTripAmount.hidden = false;
    }
    
    self.LabelTitle.text = Title;
    self.ImageView.image = self.headerImage;
    
    self.ImageView.layer.borderColor = [[UIColor whiteColor]CGColor];
    self.ImageView.layer.borderWidth = 2.0f;
    
    
    self.TableViewPayment.rowHeight = 100;
    self.TableViewPayment.sectionFooterHeight = 110;
    // Do any additional setup after loading the view.
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    self.TableViewPayment.tableFooterView = footer;
    
    
    __weak typeof(self) weakSelf = self;
    self.notification = [self.realm addNotificationBlock:^(NSString *note, RLMRealm *realm) {
        [weakSelf LoadPaymentData];
        [weakSelf.TableViewPayment reloadData];
    }];
}

/*
 created date:      09/05/2018
 last modified:     09/05/2018
 remarks:
 */
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self LoadPaymentData];
}


/*
 created date:      09/05/2018
 last modified:     15/09/2018
 remarks:  
 */
-(void) LoadPaymentData {

    if (self.TripItem == nil) {
        self.ExpenseCollection = [PaymentRLM objectsWhere:@"activitykey=%@",self.ActivityItem.key];
    }
    else {
        self.ExpenseCollection = [PaymentRLM objectsWhere:@"tripkey=%@",self.TripItem.key];
    }

    NSLog(@"%@",self.ExpenseCollection);
    
    self.localcurrencyitems = [[NSSet setWithArray:[self.ExpenseCollection valueForKey:@"localcurrencycode"]] allObjects];
    
    
    self.paymentsections = [[NSMutableArray alloc] initWithCapacity:self.localcurrencyitems.count];
    RLMResults <PaymentRLM*> *rows;
    
    for (NSString *item in self.localcurrencyitems) {
        NSLog(@"item=%@", item);
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"localcurrencycode = %@", item];
        rows = [self.ExpenseCollection objectsWithPredicate:predicate];
        
        for (PaymentRLM *test in rows) {
            if (test.localcurrencycode == nil) {
                NSLog(@"localcurrencycode=%@ - why does this happen??", test.localcurrencycode);
                [self.realm transactionWithBlock:^{
                    test.localcurrencycode = test.homecurrencycode;
                }];
            }
        }
        
        [self.paymentsections addObject:rows];
    }
    
    /* work out trip price rate */
    if (self.TripItem != nil) {
        
        /* get total days as fraction */
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitHour
                                                            fromDate:self.TripItem.startdt
                                                              toDate:self.TripItem.enddt
                                                             options:0];
        
        long Days = [components hour]/24;
        long RemainingHours = [components hour]%24;
        double TotalDays = Days + (double)RemainingHours/24.0f;
        
        
        /* if there are no days or even partial days we need to hide the badge */
        if (TotalDays > 0) {
            /* now get home currency actual paid amount */
            double actrate=0, actamt=0;
            for (PaymentRLM *item in self.ExpenseCollection) {
                actrate = [item.rate_act.rate doubleValue] / 10000;
                if ([item.rate_act.rate intValue]==1) {
                    actamt += ([item.amt_act doubleValue] / 100);
                } else {
                    actamt +=  ([item.amt_act doubleValue] / 100) * actrate;
                }
            }
            /* simply calculate trip rate */
            double TripRate = 0;
            if (actamt!=0) {
                TripRate = actamt / TotalDays;
            }
            
            self.LabelTripAmount.text = [NSString stringWithFormat:@"%.2f\n%@",TripRate,[AppDelegateDef HomeCurrencyCode]];
            
            self.ViewTripAmount.layer.cornerRadius = self.ViewTripAmount.bounds.size.width/2;
            self.ViewTripAmount.transform = CGAffineTransformMakeRotation(.17);
        } else {
            self.ViewTripAmount.hidden = true;
        }
    }
    
    [self.TableViewPayment reloadData];
}

- (NSInteger)minutesBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
    NSTimeInterval interval = [secondDate timeIntervalSinceDate:firstDate];
    return (int)interval / 60;
}

/*
 created date:      08/05/2018
 last modified:     16/05/2018
 remarks:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.localcurrencyitems.count;
}



/*
 created date:      08/05/2018
 last modified:     16/05/2018
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *temp = self.paymentsections[section];
    return temp.count;
}

/*
 created date:      19/09/2018
 last modified:     19/09/2018
 remarks:           Added currency symbol to header.
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:self.localcurrencyitems[section]];
    NSString *currencySymbol = [NSString stringWithFormat:@"%@",[locale displayNameForKey:NSLocaleCurrencySymbol value:self.localcurrencyitems[section]]];

    return [NSString stringWithFormat:@" %@ (%@)",self.localcurrencyitems[section],currencySymbol];
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerTitle = [[UILabel alloc] init];
    headerTitle.frame = CGRectMake(0, 0, tableView.frame.size.width , 20);
    headerTitle.backgroundColor = [UIColor labelColor];
    headerTitle.textColor = [UIColor systemBackgroundColor];
    headerTitle.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:17];
    headerTitle.text = [self tableView:tableView titleForHeaderInSection:section];
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:headerTitle];
    return headerView;
}



/*
 created date:      09/06/2018
 last modified:     12/08/2019
 remarks:           table view with sections.
 */
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    NSNumberFormatter *numberHomeFormatter = [[NSNumberFormatter alloc] init];
    [numberHomeFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberHomeFormatter setCurrencyCode:[AppDelegateDef HomeCurrencyCode]];
    
    NSArray *temp = self.paymentsections[section];

    double actrate=0, plannedrate=0;
    double actamt=0, plannedamt=0;
    
    for (PaymentRLM *item in temp) {
        
        actrate = [item.rate_act.rate doubleValue] / 10000;
        if ([item.rate_act.rate intValue]==1) {
            actamt += ([item.amt_act doubleValue] / 100);
        } else {
            actamt +=  ([item.amt_act doubleValue] / 100) * actrate;
        }
        plannedrate = [item.rate_est.rate doubleValue] / 10000;
        if ([item.rate_est.rate intValue]==1) {
            plannedamt += ([item.amt_est doubleValue] / 100);
        } else {
            plannedamt +=  ([item.amt_est doubleValue] / 100) * plannedrate;
        }
    }

    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 64)];
    UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
    [footerView addSubview:backgroundView];
    
    // 3. Add a label
    UILabel* actualSummaryLabel = [[UILabel alloc] init];
    actualSummaryLabel.frame = CGRectMake(10, 5, tableView.frame.size.width - 200, 20);
    actualSummaryLabel.backgroundColor = [UIColor clearColor];
    actualSummaryLabel.textColor = [UIColor secondaryLabelColor];
    actualSummaryLabel.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:17];
    actualSummaryLabel.text = @"Actual Total";
    actualSummaryLabel.textAlignment = NSTextAlignmentLeft;

    // 4. Add the label to the header view
    [footerView addSubview:actualSummaryLabel];

    /*10 trailing
     40 width of currency field
     10 spacer
     100 width of amount
     */

    // 3. Add a label
    UILabel* actualSummaryAmtLabel = [[UILabel alloc] init];
    actualSummaryAmtLabel.frame = CGRectMake(tableView.frame.size.width - 160, 5, 150, 20);
    actualSummaryAmtLabel.backgroundColor = [UIColor clearColor];
    actualSummaryAmtLabel.textColor = [UIColor labelColor];
    actualSummaryAmtLabel.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:17];
    actualSummaryAmtLabel.text = [numberHomeFormatter stringFromNumber:[NSNumber numberWithDouble:actamt]];
    actualSummaryAmtLabel.textAlignment = NSTextAlignmentRight;
    
    [footerView addSubview:actualSummaryAmtLabel];
    
    UILabel* plannedSummaryLabel = [[UILabel alloc] init];
    plannedSummaryLabel.frame = CGRectMake(10, 26, tableView.frame.size.width - 200, 20);
    plannedSummaryLabel.backgroundColor = [UIColor clearColor];
    plannedSummaryLabel.textColor = [UIColor secondaryLabelColor];
    plannedSummaryLabel.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:17];
    plannedSummaryLabel.text = @"Planned Total";
    plannedSummaryLabel.textAlignment = NSTextAlignmentLeft;
    [footerView addSubview:plannedSummaryLabel];
    
    UILabel* plannedSummaryAmtLabel = [[UILabel alloc] init];
    plannedSummaryAmtLabel.frame = CGRectMake(tableView.frame.size.width - 160, 26, 150, 20);
    plannedSummaryAmtLabel.backgroundColor = [UIColor clearColor];
    plannedSummaryAmtLabel.textColor = [UIColor labelColor];
    plannedSummaryAmtLabel.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:17];
    plannedSummaryAmtLabel.text = [numberHomeFormatter stringFromNumber:[NSNumber numberWithDouble:plannedamt]];
    plannedSummaryAmtLabel.textAlignment = NSTextAlignmentRight;
    [footerView addSubview:plannedSummaryAmtLabel];

    return footerView;
}


/*
 created date:      30/04/2018
 last modified:     20/08/2019
 remarks:           table view with sections.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PaymentListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentCellId"];

    PaymentRLM *item = [[self.paymentsections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSNumberFormatter *numberLocalFormatter = [[NSNumberFormatter alloc] init];
    [numberLocalFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberLocalFormatter setCurrencyCode:item.localcurrencycode];
    
    NSNumberFormatter *numberHomeFormatter = [[NSNumberFormatter alloc] init];
    [numberHomeFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberHomeFormatter setCurrencyCode:[AppDelegateDef HomeCurrencyCode]];

    if (self.TripItem == nil || item.activityname == nil) {
        cell.LabelDescription.text = item.desc;
    } else {
        cell.LabelDescription.text = [NSString stringWithFormat:@"%@: %@",item.activityname, item.desc];
    }

    /* might need to adjust this with rate */
    
    double localamt = ([item.amt_act doubleValue] / 100);
    cell.LabelLocalAmt.text = [numberLocalFormatter stringFromNumber:[NSNumber numberWithDouble:localamt]];
    
    double localamtest = ([item.amt_est doubleValue] / 100);
    cell.LabelLocalAmtEst.text = [numberLocalFormatter stringFromNumber:[NSNumber numberWithDouble:localamtest]];
   

    if ([item.rate_act.rate intValue]==1) {
        cell.LabelLocalAmt.hidden = true;
        cell.LabelHomeAmt.text = cell.LabelLocalAmt.text;
        //cell.LabelLocalCurrencyCode.text = item.localcurrencycode;
        
    } else {
        cell.LabelHomeAmt.hidden = false;
        double rate = [item.rate_act.rate doubleValue] / 10000;
        double homeamt = ([item.amt_act doubleValue] / 100) * rate;
        cell.LabelHomeAmt.text = [numberHomeFormatter stringFromNumber:[NSNumber numberWithDouble:homeamt]];
    }
    
    if ([item.rate_est.rate intValue]==1) {
        cell.LabelLocalAmtEst.hidden = true;
        cell.LabelHomeAmtEst.text = cell.LabelLocalAmtEst.text;
    } else {
        cell.LabelHomeAmtEst.hidden = false;
        double rate = [item.rate_est.rate doubleValue] / 10000;
        double homeamt = ([item.amt_est doubleValue] / 100) * rate;
        cell.homeAmount = [NSNumber numberWithDouble:homeamt];
        cell.LabelHomeAmtEst.text = [numberHomeFormatter stringFromNumber:[NSNumber numberWithDouble:homeamt]];
    }

    return cell;
}


/*
created date:      15/05/2018
last modified:     09/04/2019
remarks:
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *IDENTIFIER = @"PaymentCellId";
    
    PaymentListCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[PaymentListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    PaymentRLM *Expense = [[self.paymentsections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];


    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ExpenseDataEntryVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"ExpenseDataEntryId"];
    controller.delegate = self;
    controller.ExpenseItem = Expense;
    NSString *Title = [NSString stringWithFormat:@"Expense on %@", self.ActivityItem.name];
    if (self.TripItem != nil) {
        self.ActivityItem = [[ActivityRLM alloc] init];
        self.ActivityItem.tripkey = self.TripItem.key;
        self.ActivityItem.state = self.activitystate;
        Title = [NSString stringWithFormat:@"Trip Expense for %@", self.TripItem.name];
    }
    controller.TitleText = Title;
    
    controller.ActivityItem = self.ActivityItem;
    controller.newitem = false;
    controller.realm = self.realm;
   // presentedController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:controller animated:YES completion:nil];
    
    
}

/*
 created date:      15/05/2018
 last modified:     16/05/2018
 remarks:
 */
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                          {
                                              
                                              [self tableView:tableView deletePayment:indexPath];
                                              self.TableViewPayment.editing = NO;
                                              
                                          }];
    
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction];
}
/*
 created date:      15/05/2018
 last modified:     15/06/2019
 remarks:           Might not be totally necessary, but seperated out from editActionsForRowAtIndexPath method above.
 */
- (void)tableView:(UITableView *)tableView deletePayment:(NSIndexPath *)indexPath  {
    
    NSLog(@"should be able to delete any records here?");
    PaymentRLM *Expense = [[self.paymentsections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    [self.realm transactionWithBlock:^{
        [self.realm deleteObject:Expense];
    }];
    
    NSLog(@"delete called!");
}

/*
 created date:      03/05/2018
 last modified:     09/08/2018
 remarks:           segue controls .
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"ShowNewPayment"]){
        PaymentDataEntryVC *controller = (PaymentDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        if (self.TripItem != nil) {
            self.ActivityItem = [[ActivityRLM alloc] init];
            self.ActivityItem.tripkey = self.TripItem.key;
            self.ActivityItem.state = self.activitystate;
        }
        controller.realm = self.realm;
        controller.ActivityItem  = self.ActivityItem;
        controller.ExpenseItem = nil;
        controller.newitem = true;
    } else if([segue.identifier isEqualToString:@"ShowNewExpense"]){
        ExpenseDataEntryVC *controller = (ExpenseDataEntryVC *)segue.destinationViewController;
        controller.delegate = self;
        if (self.TripItem != nil) {
            self.ActivityItem = [[ActivityRLM alloc] init];
            self.ActivityItem.tripkey = self.TripItem.key;
            //self.ActivityItem.state = self.activitystate;
        }
        NSString *Title = [NSString stringWithFormat:@"New Expense on %@", self.ActivityItem.name];
        if (self.TripItem != nil) {
            Title = [NSString stringWithFormat:@"New Trip Expense for %@", self.TripItem.name];
        }
        controller.TitleText = Title;
        
        controller.realm = self.realm;
        controller.ActivityItem  = self.ActivityItem;
        controller.newitem = true;
    }
        
}



/*
 created date:      08/05/2018
 last modified:     08/05/2018
 remarks:
 */
- (IBAction)BackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)SegmentPaymentType:(id)sender {
}
@end
