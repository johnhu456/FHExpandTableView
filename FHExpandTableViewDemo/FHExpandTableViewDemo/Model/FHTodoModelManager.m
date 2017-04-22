//
//  FHTodoModelManager.m
//  FHExpandTableViewDemo
//
//  Created by 胡翔 on 2017/4/21.
//  Copyright © 2017年 胡翔. All rights reserved.
//

#import "FHTodoModelManager.h"
#import "FHTodoCollection.h"

@implementation FHTodoModelManager

- (NSArray<FHTodoCollection *> *)getAllTodoCollection {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"FHTodoModel" ofType:@"plist"];
    NSArray *todoCollectionArray = [[NSArray alloc] initWithContentsOfFile:modelPath];
    NSMutableArray *completed = [[NSMutableArray alloc] init];
    NSMutableArray *unCompleted = [[NSMutableArray alloc] init];

    for (NSDictionary *collectionDic in todoCollectionArray) {
        if ([collectionDic valueForKey:@"completed"]) {
            for (NSDictionary *completeTodoDic in [collectionDic valueForKey:@"completed"]) {
                FHTodoItem *todoItem = [[FHTodoItem alloc] init];
                [todoItem setValuesForKeysWithDictionary:completeTodoDic];
                [completed addObject:todoItem];
            }
        }
        if ([collectionDic valueForKey:@"unCompleted"]) {
            for (NSDictionary *unCompleteTodoDic in [collectionDic valueForKey:@"unCompleted"]) {
                FHTodoItem *unCompletedTodoItem = [[FHTodoItem alloc] init];
                [unCompletedTodoItem setValuesForKeysWithDictionary:unCompleteTodoDic];
                [unCompleted addObject:unCompletedTodoItem];
            }
        }
        FHTodoCollection *collection = [[FHTodoCollection alloc] init];
        collection.name = [collectionDic valueForKey:@"name"];
        collection.completed = [completed copy];
        collection.unCompleted = [unCompleted copy];
        [result addObject:collection];
        [completed removeAllObjects];
        [unCompleted removeAllObjects];
    }
    return result;
}

@end
