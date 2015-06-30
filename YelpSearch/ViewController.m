//
//  ViewController.m
//  YelpSearch
//
//  Created by Kent Lee on 2015/6/23.
//  Copyright (c) 2015年 Kent Lee. All rights reserved.
//

#import "ViewController.h"
#import "YelpClient.h"
#import "YelpBusinessCell.h"
#import "YelpFilterController.h"
#import <UIImageView+AFNetworking.h>
#import <CoreLocation/CLLocation.h>

NSString * const kYelpConsumerKey = @"";
NSString * const kYelpConsumerSecret = @"";
NSString * const kYelpToken = @"";
NSString * const kYelpTokenSecret = @"";

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, YelpFilterControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) YelpClient *client;
@property (strong, nonatomic) NSMutableArray *yelpRecords;
@property (strong, nonatomic) NSMutableDictionary *yelpFilters;
@property (strong, nonatomic) NSMutableArray *yelpCategories;
@property (strong, nonatomic) NSArray *yelpSelectedCategories;
@property (strong, nonatomic) UISearchBar *searchBar;
@property NSInteger totalBusiness;
@property NSInteger offsetBusiness;
@property CLLocationCoordinate2D yelpRegion;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 120.0f;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    self.searchBar.text = @"Thai";
    self.searchBar.delegate = self;
    self.searchBar.barStyle = UIBarStyleBlackOpaque;
    self.navigationItem.titleView = self.searchBar;    
    
    self.offsetBusiness = 0;
    self.yelpRecords = [[NSMutableArray alloc] init];
    self.yelpCategories = [[NSMutableArray alloc] init];
    self.yelpRegion = CLLocationCoordinate2DMake(37.7879862, -122.4076558);
    self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
    [self doYelpSearch];
    
    self.yelpFilters = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                       @"sortMethod": @0,
                                                                       @"radiusExpand": @NO,
                                                                       @"radiusSetting": @1,
                                                                       @"hasDeal": @NO
                                                                       }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *nav = segue.destinationViewController;
    YelpFilterController *filterController = (YelpFilterController *)nav.topViewController;
    filterController.delegate = self;
    filterController.filterSetting = [self.yelpFilters mutableCopy];
    filterController.filterCategories = [self.yelpCategories mutableCopy];
    if (self.yelpSelectedCategories != nil) {
        filterController.selectedCategories = [self.yelpSelectedCategories mutableCopy];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YelpBusinessCell *cell = (YelpBusinessCell *)[self.tableView dequeueReusableCellWithIdentifier:@"YelpBusinessCell" forIndexPath:indexPath];
    NSDictionary *info = self.yelpRecords[indexPath.row];
    NSArray *address = [info valueForKeyPath:@"location.display_address"];
    NSMutableArray *categories = [[NSMutableArray alloc] init];
    for (NSArray *category in info[@"categories"]) {
        [categories addObject:category[0]];
    }
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%ld. %@", indexPath.row + 1, info[@"name"]];
    cell.reviewLabel.text = [NSString stringWithFormat:@"%ld Reviews", (long)[info[@"review_count"] integerValue]];
    if (address.count >= 2) {
        cell.addressLabel.text = [NSString stringWithFormat:@"%@, %@", address[0], address[1]];
    }
    else {
        cell.addressLabel.text = @"No address info";
    }
    cell.categoryLabel.text = [categories componentsJoinedByString:@", "];
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake([[info valueForKeyPath:@"location.coordinate.latitude"] doubleValue], [[info valueForKeyPath:@"location.coordinate.longitude"] doubleValue]);
    CLLocation *currentLoc = [[CLLocation alloc] initWithCoordinate: self.yelpRegion altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil];
    CLLocation *cellLoc = [[CLLocation alloc] initWithCoordinate: position altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:nil];
    CLLocationDistance kilometers = [cellLoc distanceFromLocation:currentLoc] / 1000;

    cell.distanceLabel.text = [NSString stringWithFormat:@"%.2f km", kilometers];
    [cell.mainImage setImageWithURL:[NSURL URLWithString:info[@"image_url"]]];
    [cell.ratingImage setImageWithURL:[NSURL URLWithString:info[@"rating_img_url_small"]]];
    
    if (indexPath.row == self.yelpRecords.count - 8 && self.yelpRecords.count < self.totalBusiness) {
        [self doYelpSearch];
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.yelpRecords.count;
}

- (void)filterController:(YelpFilterController *)filterController updateFilterParams:(NSDictionary *)filterParams selectedCategories:(NSArray *)categories {
    self.yelpFilters = [filterParams mutableCopy];
    self.yelpSelectedCategories = categories;
    [self.yelpRecords removeAllObjects];
    [self.tableView reloadData];
    self.totalBusiness = 0;
    self.offsetBusiness = 0;
    [self doYelpSearch];
    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES];
}

- (void)doYelpSearch {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"sort"] = [NSString stringWithFormat:@"%ld", (long)[self.yelpFilters[@"sortMethod"] integerValue]];
    param[@"term"] = self.searchBar.text;
    param[@"ll"] = @"37.7879862,-122.4076558";
    param[@"offset"] = [NSString stringWithFormat:@"%ld", (long)self.offsetBusiness];
    if ([self.yelpFilters[@"radiusExpand"] boolValue]) {
        switch ([self.yelpFilters[@"radiusSetting"] integerValue]) {
            case 1:
                param[@"radius_filter"] = @"1000.0";
                break;
            case 2:
                param[@"radius_filter"] = @"5000.0";
                break;
            case 3:
                param[@"radius_filter"] = @"10000.0";
                break;
        }
    }
    if ([self.yelpFilters[@"hasDeal"] boolValue]) {
        param[@"deals_filter"] = @"true";
    }
    if (self.yelpSelectedCategories != nil && self.yelpSelectedCategories.count > 0) {
        param[@"category_filter"] = [self.yelpSelectedCategories componentsJoinedByString:@","];
    }
    NSLog(@"%@", param);
    [self.client searchWithTerm:param success:^(AFHTTPRequestOperation *operation, id response) {
        //NSLog(@"response: %@", response);
        [self.yelpRecords addObjectsFromArray:response[@"businesses"]];
        self.totalBusiness = [response[@"total"] integerValue];
        self.offsetBusiness += [(NSArray *)(response[@"businesses"]) count];
        [self.tableView reloadData];
        for (NSDictionary *info in response[@"businesses"]) {
            for (NSArray *category in info[@"categories"]) {
                if (![self.yelpCategories containsObject:category[1]]) {
                    [self.yelpCategories addObject:category[1]];
                }
            }
        }
        NSLog(@"%ld", (long)self.totalBusiness);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.yelpSelectedCategories = nil;
    [self.yelpCategories removeAllObjects];
    [self.yelpRecords removeAllObjects];
    [self.tableView reloadData];
    self.totalBusiness = 0;
    self.offsetBusiness = 0;
    [self doYelpSearch];
    [self.tableView setContentOffset:CGPointMake(0, -self.tableView.contentInset.top) animated:YES];
}

@end
