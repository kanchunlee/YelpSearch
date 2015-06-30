//
//  YelpFilterController.m
//  YelpSearch
//
//  Created by Kent Lee on 2015/6/24.
//  Copyright (c) 2015年 Kent Lee. All rights reserved.
//

#import "YelpFilterController.h"

static NSArray *yelpFilters;
static int sortSection = 0;
static int radiusSection = 1;
static int dealsSection = 2;
static int categorySection = 3;

@interface YelpFilterController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation YelpFilterController

@synthesize filterSetting;

+ (void)initialize {
    yelpFilters = @[
                    @[@"Sort", @[@"Best Match", @"Distance", @"Highest Rated"]],
                    @[@"Radius", @[@"Search By Distance (km)"]],
                    @[@"Deals", @[@"Has Deals"]],
                    @[@"Categories", @[@"Expand"]]
                    ];
    yelpRadiusFilters = @[@"1.0", @"5.0", @"10.0"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"TableViewCell"];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"TableViewHeaderView"];
    if (self.selectedCategories == nil) {
        self.selectedCategories = [[NSMutableArray alloc] init];
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return yelpFilters.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionFilters = yelpFilters[section][1];
    NSInteger count = sectionFilters.count;
    if (section == radiusSection && [self.filterSetting[@"radiusExpand"] boolValue]) {
        count += yelpRadiusFilters.count;
    }
    if (section == categorySection) {
        count = self.filterCategories.count;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TableViewCell" forIndexPath:indexPath];
    NSArray *sectionFilters = yelpFilters[indexPath.section][1];
    if (indexPath.section == radiusSection && [self.filterSetting[@"radiusExpand"] boolValue] && indexPath.row > 0) {
        cell.textLabel.text = yelpRadiusFilters[indexPath.row-1];
    }
    else if (indexPath.section == categorySection) {
        cell.textLabel.text = self.filterCategories[indexPath.row];
    }
    else {
        cell.textLabel.text = sectionFilters[indexPath.row];
    }
    if (indexPath.section == sortSection) {
        // sort filter
        if ([self.filterSetting[@"sortMethod"] integerValue] == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else if (indexPath.section == radiusSection) {
        // radius filter
        if (indexPath.row == 0) {
            if (cell.accessoryView == nil) {
                UISwitch *radiusSwitch = [[UISwitch alloc] init];
                radiusSwitch.on = [self.filterSetting[@"radiusExpand"] boolValue];
                [radiusSwitch addTarget:self action:@selector(onRadiusExpandChanged) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
                [cell.accessoryView addSubview:radiusSwitch];
            }
            else {
                UISwitch *radiusSwitch = (UISwitch *)cell.accessoryView.subviews[0];
                radiusSwitch.on = [self.filterSetting[@"radiusExpand"] boolValue];
            }
        }
        else {
            if ([self.filterSetting[@"radiusSetting"] integerValue] == indexPath.row) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            if (cell.accessoryView) {
                cell.accessoryView = nil;
            }
        }
    }
    else if (indexPath.section == dealsSection) {
        // deals filter
        if (cell.accessoryView == nil) {
            UISwitch *dealsSwitch = [[UISwitch alloc] init];
            dealsSwitch.on = [self.filterSetting[@"hasDeal"] boolValue];
            [dealsSwitch addTarget:self action:@selector(onHasDealsChanged) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
            [cell.accessoryView addSubview:dealsSwitch];
        }
        else {
            UISwitch *dealsSwitch = (UISwitch *)cell.accessoryView.subviews[0];
            dealsSwitch.on = [self.filterSetting[@"hasDeal"] boolValue];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (indexPath.section == categorySection) {
        if ([self.selectedCategories containsObject:self.filterCategories[indexPath.row]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (cell.accessoryView != nil) {
            cell.accessoryView = nil;
        }
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TableViewHeaderView"];
    NSArray *sectionDetails = yelpFilters[section];
    header.textLabel.text = sectionDetails[0];
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == sortSection && [self.filterSetting[@"sortMethod"] integerValue] != indexPath.row) {
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:[self.filterSetting[@"sortMethod"] integerValue] inSection:0];
        [self.filterSetting setObject:[NSNumber numberWithInt:(int)indexPath.row] forKey:@"sortMethod"];
        [self.tableView reloadRowsAtIndexPaths:@[oldIndexPath, indexPath] withRowAnimation:UITableViewRowAnimationNone];
        //NSLog(@"%ld", (long)[self.filterSetting[@"sortMethod"] integerValue]);
    }
    else if (indexPath.section == radiusSection && indexPath.row == 0) {
        [self onRadiusExpandChanged];
    }
    else if (indexPath.section == radiusSection && indexPath.row > 0 && [self.filterSetting[@"radiusSetting"] integerValue] != indexPath.row) {
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:[self.filterSetting[@"radiusSetting"] integerValue] inSection:1];
        [self.filterSetting setObject:[NSNumber numberWithInt:(int)indexPath.row] forKey:@"radiusSetting"];
        [self.tableView reloadRowsAtIndexPaths:@[oldIndexPath, indexPath] withRowAnimation:UITableViewRowAnimationNone];
        //NSLog(@"%ld", (long)[self.filterSetting[@"radiusSetting"] integerValue]);
    }
    else if (indexPath.section == dealsSection && indexPath.row == 0) {
        [self onHasDealsChanged];
    }
    else if (indexPath.section == categorySection) {
        // do something
        if ([self.selectedCategories containsObject:self.filterCategories[indexPath.row]]) {
            [self.selectedCategories removeObject:self.filterCategories[indexPath.row]];
        }
        else {
            [self.selectedCategories addObject:self.filterCategories[indexPath.row]];
        }
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)onRadiusExpandChanged {
    if ([self.filterSetting[@"radiusExpand"] boolValue]) {
        [self.filterSetting setValue:@NO forKey:@"radiusExpand"];
    }
    else {
        [self.filterSetting setValue:@YES forKey:@"radiusExpand"];
    }
    [self.tableView reloadData];
}

- (void)onHasDealsChanged {
    if ([self.filterSetting[@"hasDeal"] boolValue]) {
        [self.filterSetting setValue:@NO forKey:@"hasDeal"];
    }
    else {
        [self.filterSetting setValue:@YES forKey:@"hasDeal"];
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:dealsSection];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)onCancelButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSearchButton:(UIBarButtonItem *)sender {
    [self.delegate filterController:self updateFilterParams:self.filterSetting selectedCategories:self.selectedCategories];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
