//
//  FHExpandCompleteCell.h
//  FHExpandTableView
//
//  Created by 胡翔 on 2017/4/22.
//  Copyright © 2017年 胡翔. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHExpandCompleteCell : UITableViewCell

@property (nonatomic, copy) NSString *title;

/**
 AccessoryView display "-" for expand setted to YES, "+" for NO.
 */
@property (nonatomic, assign) BOOL expand;

@end
