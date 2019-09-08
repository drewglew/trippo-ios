//
//  WeatherVCViewController.m
//  trippo
//
//  Created by andrew glew on 23/06/2019.
//  Copyright © 2019 andrew glew. All rights reserved.
//

#import "WeatherVCViewController.h"

@interface WeatherVCViewController ()

@end

@implementation WeatherVCViewController

/*
 created date:      23/06/2019
 last modified:     24/06/2019
 remarks:
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    RLMArray *weathercollection;
    
    // Do any additional setup after loading the view.
    if (self.ActivityItem.state == [NSNumber numberWithInteger:0]) {
        weathercollection = self.ActivityItem.poi.weather;
    } else {
        if (self.ActivityItem.state == [NSNumber numberWithInteger:1]) {
            if (self.ActivityItem.weather.count > 0) {
                weathercollection = self.ActivityItem.weather;
            } else {
                // this should handle activities that are in progress.
                weathercollection = self.ActivityItem.poi.weather;
            }
        }
    }
    self.timeintervals = [[NSSet setWithArray:[weathercollection valueForKey:@"timedefition"]] allObjects];
    self.weathersections = [[NSMutableArray alloc] initWithCapacity:self.timeintervals.count];
    RLMResults <WeatherRLM*> *rows;
    for (NSString *item in self.timeintervals) {
       
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timedefition = %@", item];
        rows = [weathercollection objectsWithPredicate:predicate];
        [self.weathersections addObject:rows];
    }
    self.TableViewWeatherListing.rowHeight = 150;
    self.TableViewWeatherListing.delegate = self;
    [self.TableViewWeatherListing reloadData];
}

/*
 created date:      23/06/2019
 last modified:     23/06/2019
 remarks:
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.weathersections.count;
}

/*
 created date:      23/06/2019
 last modified:     23/06/2019
 remarks:
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%@",self.timeintervals[section]];
}


/*
 created date:      23/06/2019
 last modified:     23/06/2019
 remarks:
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *temp = self.weathersections[section];
    return temp.count;
}



/*
 created date:      23/06/2019
 last modified:     24/06/2019
 remarks:
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WeatherCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeatherCellId"];
    WeatherRLM *item = [[self.weathersections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    BOOL doHighlight = false;
    
    BOOL today;
    if (self.ActivityItem.weather.count>0) {
        // we have history data..
        today = true;
        
    } else {
        today = [[NSCalendar currentCalendar] isDateInToday:self.ActivityItem.startdt];
    }

    [cell.ImageIcon setImage:[UIImage systemImageNamed:item.systemicon]];
    
    NSLog(@"%@",item.icon);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if ([item.timedefition isEqualToString:@"currently"]) {
        cell.LabelTime.text = @"now";
        cell.LabelTemp.text = [NSString stringWithFormat:@"%@ °C", item.temperature];
        
        doHighlight = true;
        
    } else if ([item.timedefition isEqualToString:@"hourly"]) {
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour) fromDate:[NSDate dateWithTimeIntervalSince1970: [item.time doubleValue]]];
        NSInteger activityhour = [components hour];
        
        NSString *weekname = @"";
        
        // change of date
        if (activityhour == 0) {
            NSDate *weekday = [NSDate dateWithTimeIntervalSince1970: [item.time doubleValue]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            weekname = [NSString stringWithFormat:@"%@, ",[dateFormatter stringFromDate:weekday]];
        }
        cell.LabelTemp.text = [NSString stringWithFormat:@"%@ °C", item.temperature];
        cell.LabelTime.text = [NSString stringWithFormat:@"%@%ld:00",weekname, (long)activityhour];
        
        
        if (today) {
            
            unsigned unitFlags =  NSCalendarUnitDay | NSCalendarUnitHour;
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:unitFlags fromDate:self.ActivityItem.startdt];
            NSInteger activitystarthour = [components hour];
            NSInteger activitystartday = [components day];
            
            components = [calendar components:unitFlags fromDate:self.ActivityItem.enddt];
            NSInteger activityendhour = [components hour];
            NSInteger activityendday = [components day];
            
            components = [calendar components:unitFlags fromDate:[NSDate dateWithTimeIntervalSince1970: [item.time doubleValue]]];
            NSInteger weatherhour = [components hour];
            NSInteger weatherday = [components day];
            
            // 24 hours covered..
            if (activitystarthour == weatherhour && activitystartday == weatherday) {
               doHighlight = true;
            } else if ((weatherhour >= activitystarthour  && activitystartday == weatherday && weatherhour <= activityendhour && activityendday == weatherday) || (weatherhour >= activitystarthour  && activityendday > weatherday && self.ActivityItem.weather.count>0)) {
                doHighlight = true;
            } else {
                doHighlight = false;
            }
        }
        
        
    } else if ([item.timedefition isEqualToString:@"daily"]) {
        
        NSDate *weekday = [NSDate dateWithTimeIntervalSince1970: [item.time doubleValue]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE"];
        NSLog(@"%@", item);
        
        cell.LabelTemp.text = item.temperature;
        cell.LabelTime.text = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:weekday]];
        
        
        NSDate *today = [NSDate date];
        NSDate *eightDaysAhead = [today dateByAddingTimeInterval:8*24*60*60];
        
        if ([self.ActivityItem.startdt compare:today] == NSOrderedDescending &&  [self.ActivityItem.startdt compare:eightDaysAhead] == NSOrderedAscending) {
        
            if ([[NSCalendar currentCalendar] isDate:self.ActivityItem.startdt inSameDayAsDate:[NSDate dateWithTimeIntervalSince1970: [item.time doubleValue]]]) {
                doHighlight = true;
            } else {
                doHighlight = false;
            }
            
            // TODO Apply multiple days for as long as activity runs.
        
        } else {
            doHighlight = false;
        }
    }

    if (doHighlight) {
        [cell.contentView setBackgroundColor:[UIColor labelColor]];
        [cell.LabelTemp setTextColor:[UIColor systemBackgroundColor]];
        [cell.LabelSummary setTextColor:[UIColor systemBackgroundColor]];
        [cell.LabelTime setTextColor:[UIColor secondarySystemBackgroundColor]];
        
    } else {
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        [cell.LabelTemp setTextColor:[UIColor labelColor]];
        [cell.LabelSummary setTextColor:[UIColor labelColor]];
        [cell.LabelTime setTextColor:[UIColor secondaryLabelColor]];
    }
    
    cell.LabelSummary.text = [NSString stringWithFormat:@"%@", item.summary];
    return cell;
}



/*
created date:      23/06/2019
last modified:     23/06/2019
remarks:
*/
- (IBAction)ButtonClosePressed:(id)sender {
     [self dismissViewControllerAnimated:YES completion:Nil];
}

@end
