//
//  FHTodoCollection.h
//  FHExpandTableViewDemo
//
//  Created by 胡翔 on 2017/3/23.
//  Copyright © 2017年 胡翔. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHTodoItem.h"

@interface FHTodoCollection : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSArray <FHTodoItem *> *completed;

@property (nonatomic, strong) NSArray <FHTodoItem *> *unCompleted;

@end
