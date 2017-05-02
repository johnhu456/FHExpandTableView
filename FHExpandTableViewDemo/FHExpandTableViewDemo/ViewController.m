//
//  ViewController.m
//  FHExpandTableViewDemo
//
//  Created by 胡翔 on 2017/3/23.
//  Copyright © 2017年 胡翔. All rights reserved.
//

#import "ViewController.h"
#import "FHExpandTableView.h"
#import "FHTodoModelManager.h"

#import "FHExpandHeadCell.h"
#import "FHExpandCompleteCell.h"
#import "FHTodoListCell.h"

static NSString *const kCollectionExpandIdentifier = @"kCollectionExpandIdentifier";
static NSString *const kTodoExpandIdentifier = @"kTodoExpandIdentifier";
static NSString *const kCompleteHeadExpandIdentifier = @"kCompleteHeadExpandIdentifier";

static NSString *const kExpandHeadCellReuseIdentifier = @"kExpandHeadCellReuseIdentifier";
static NSString *const kCompleteHeadCellReuseIdentifier = @"kCompleteHeadCellReuseIdentifier";
static NSString *const kTodoListCellReuseIdentifier = @"kTodoListCellReuseIdentifier";

@interface ViewController ()<FHExpandTableViewDelegate>

@property (nonatomic, strong) FHExpandModel *data;
@property (nonatomic, strong) NSArray<FHTodoCollection *> *todoCollections;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My To-do";
    
    FHExpandTableView *tableView = [[FHExpandTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    //Register Cells
    [tableView registerClass:[FHExpandHeadCell class] forCellReuseIdentifier:kExpandHeadCellReuseIdentifier];
    [tableView registerClass:[FHExpandCompleteCell class] forCellReuseIdentifier:kCompleteHeadExpandIdentifier];
    [tableView registerClass:[FHTodoListCell class] forCellReuseIdentifier:kTodoListCellReuseIdentifier];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.expandDelegate = self;

    NSArray *todoCollections = [[[FHTodoModelManager alloc] init] getAllTodoCollection];
    self.todoCollections = todoCollections;
    NSMutableArray *expandArray = [[NSMutableArray alloc] init];
    
    for (FHTodoCollection *collection in todoCollections) {
        FHExpandModel *collectionModel = [FHExpandModel expandModelWithObject:collection identifier:kCollectionExpandIdentifier];
        collectionModel.sameLevelExclusion = YES;
        for (FHTodoItem *unComplete in collection.unCompleted) {
            FHExpandModel *unCompleteModel = [FHExpandModel expandModelWithObject:unComplete identifier:kTodoExpandIdentifier];
            [collectionModel addSubModel:unCompleteModel];
        }
        NSMutableArray *completedTodoExpandModels = [[NSMutableArray alloc] init];
        for (FHTodoItem *complete in collection.completed) {
            FHExpandModel *completeModel = [FHExpandModel expandModelWithObject:complete identifier:kTodoExpandIdentifier];
            [completedTodoExpandModels addObject:completeModel];
        }
        if (completedTodoExpandModels.count) {
            FHExpandModel *completedHeader = [FHExpandModel expandModelWithObject:nil identifier:kCompleteHeadExpandIdentifier];
            completedHeader.subModels = completedTodoExpandModels;
            completedHeader.expand = YES;
            [collectionModel addSubModel:completedHeader];
        }
        [expandArray addObject:collectionModel];
    }
    tableView.expandModels = expandArray;
    [self.view addSubview:tableView];
}


- (UITableViewCell *)FHExpandTableView:(FHExpandTableView *)tableView cellForModel:(FHExpandModel *)model {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"1"];
    
    if ([model.identifier isEqualToString:kCollectionExpandIdentifier]) {
        FHExpandHeadCell *headCell = [tableView dequeueReusableCellWithIdentifier:kExpandHeadCellReuseIdentifier];
        FHTodoCollection *collection = (FHTodoCollection *)model.object;
        headCell.title = collection.name;
        headCell.badgeNumber = collection.unCompleted.count;
        return headCell;
    }
    else if ([model.identifier isEqualToString:kCompleteHeadExpandIdentifier]) {
        FHExpandCompleteCell *completeCell = [tableView dequeueReusableCellWithIdentifier:kCompleteHeadExpandIdentifier];
        FHTodoCollection *collection = (FHTodoCollection *)model.fatherModel.object;
        completeCell.title = [NSString stringWithFormat:@"%lu completed",(unsigned long)collection.completed.count];
        completeCell.expand = model.expand;
        return completeCell;
    }
    else if ([model.identifier isEqualToString:kTodoExpandIdentifier]) {
        FHTodoListCell *todoListCell = [tableView dequeueReusableCellWithIdentifier:kTodoListCellReuseIdentifier];
        todoListCell.todoItem = model.object;
        return  todoListCell;
    }
    cell.textLabel.text = model.identifier;
    return cell;
}

- (void)FHExpandTableView:(FHExpandTableView *)tableView didSelectedIndexPath:(NSIndexPath *)indexPath expandModel:(FHExpandModel *)model
{
    if ([model.identifier isEqualToString:kCompleteHeadExpandIdentifier]) {
        FHExpandCompleteCell *completeCell = [tableView cellForRowAtIndexPath:indexPath];
        [completeCell setExpand:!model.expand];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
