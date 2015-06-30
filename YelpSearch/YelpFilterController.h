//
//  YelpFilterController.h
//  YelpSearch
//
//  Created by Kent Lee on 2015/6/24.
//  Copyright (c) 2015年 Kent Lee. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIKit.h>

static NSArray *yelpRadiusFilters;

@class YelpFilterController;

@protocol YelpFilterControllerDelegate <NSObject>

- (void)filterController:(YelpFilterController *)filterController updateFilterParams:(NSDictionary *)filterParams selectedCategories:(NSArray *)categories;

@end

@interface YelpFilterController : UIViewController

@property (weak, nonatomic) id<YelpFilterControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableDictionary *filterSetting;
@property (strong, nonatomic) NSMutableArray *filterCategories;
@property (strong, nonatomic) NSMutableArray *selectedCategories;

@end
