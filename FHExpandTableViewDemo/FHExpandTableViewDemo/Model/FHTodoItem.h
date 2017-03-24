//
//  FHTodoItem.h
//  FHExpandTableViewDemo
//
//  Created by 胡翔 on 2017/3/23.
//  Copyright © 2017年 胡翔. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHTodoItem : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSDate *date;

@property (nonatomic, assign, getter=isCompleted) BOOL completed;
@end
