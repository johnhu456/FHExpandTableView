//
//  FHExpandHeadCell
//  FHExpandTableView
//
//  Created by 胡翔 on 2017/4/21.
//  Copyright © 2017 胡翔. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A Expandable cell, work with FHExpandTableView
 */
@interface FHExpandHeadCell : UITableViewCell

/**
 The cell's title
 */
@property (nonatomic, copy) NSString *title;

/**
 The cell's badge content,default is 0 and hidden. Largest number is 99.
 */
@property (nonatomic, assign) NSUInteger badgeNumber;

/**
 Expand cell with animation
 
 @param expanded Expand cell or not
 @param animated Animate or not
 */
- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated;

@end
