//
//  FHTodoModelManager.h
//  FHExpandTableViewDemo
//
//  Created by 胡翔 on 2017/4/21.
//  Copyright © 2017年 胡翔. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHTodoCollection.h"

@interface FHTodoModelManager : NSObject

- (NSArray <FHTodoCollection *>*)getAllTodoCollection;

@end
