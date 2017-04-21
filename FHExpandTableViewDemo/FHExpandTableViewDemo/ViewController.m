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

static NSString *const kCollectionExpandIdentifier = @"kCollectionExpandIdentifier";
static NSString *const kTodoExpandIdentifier = @"kTodoExpandIdentifier";
static NSString *const kCompleteHeadExpandIdentifier = @"kCompleteHeadExpandIdentifier";

@interface ViewController ()<FHExpandTableViewDelegate>

@property (nonatomic, strong) FHExpandModel *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    FHExpandTableView *tableView = [[FHExpandTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];

    NSArray *todoCollections = [[[FHTodoModelManager alloc] init] getAllTodoCollection];
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
            [collectionModel addSubModel:completedHeader];
        }
        [expandArray addObject:collectionModel];
    }
    tableView.expandModels = expandArray;
    [self.view addSubview:tableView];
}

- (UITableViewCell *)FHExpandTableView:(FHExpandTableView *)tableView cellForModel:(FHExpandModel *)model
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"1"];
    
    if ([model.identifier isEqualToString:kCollectionExpandIdentifier])
    {
        cell.backgroundColor = [UIColor redColor];
    }
    else
    {
        cell.backgroundColor = [UIColor blueColor];
    }
    cell.textLabel.text = model.identifier;
    return cell;
}

- (void)FHExpandTableView:(FHExpandTableView *)tableView didSelectedCellForModel:(FHExpandModel *)model
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
