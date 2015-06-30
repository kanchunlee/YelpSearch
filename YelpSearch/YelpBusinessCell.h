//
//  YelpBusinessCell.h
//  YelpSearch
//
//  Created by Kent Lee on 2015/6/23.
//  Copyright (c) 2015年 Kent Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YelpBusinessCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImage;
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end
