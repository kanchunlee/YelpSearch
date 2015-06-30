//
//  YelpBusinessCell.m
//  YelpSearch
//
//  Created by Kent Lee on 2015/6/23.
//  Copyright (c) 2015年 Kent Lee. All rights reserved.
//

#import "YelpBusinessCell.h"

@implementation YelpBusinessCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.mainImage.image = nil;
    self.ratingImage.image = nil;
    self.distanceLabel.text = @"0.0 km";
}

@end
