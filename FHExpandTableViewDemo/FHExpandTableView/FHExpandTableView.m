//
//  FHExpandTableView.m
//  FHExpandTableViewDemo
//
//  Created by 胡翔 on 2017/3/23.
//  Copyright © 2017年 胡翔. All rights reserved.
//

#import "FHExpandTableView.h"

@interface FHExpandModel()
{
    NSUInteger _totalCounts;
}

@end

@implementation FHExpandModel

- (instancetype)init
{
    if (self = [super init])
    {
        _totalCounts = 1;
    }
    return self;
}

- (NSUInteger)subDataCount
{
    return [self getSubModelCountWithModel:self];
}

- (NSUInteger)getSubModelCountWithModel:(FHExpandModel *)model
{
    // Traverse all child nodes
    if (model.subModel.count) {
        [model.subModel enumerateObjectsUsingBlock:^(FHExpandModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (model.expand)
            {
                [self getSubModelCountWithModel:obj];
            }
        }];
        if (model.expand)
        {
            _totalCounts += model.subModel.count;
        }
        return _totalCounts;
    } else {
        return 0;
    }
}

+ (instancetype)expandModelWithObject:(id)object identifier:(NSString *)identifier
{
    FHExpandModel *model = [[FHExpandModel alloc] init];
    model.object = object;
    model.identifier = identifier;
    return model;
}

- (void)addSubModel:(FHExpandModel *)model
{
    NSMutableArray *originSubModels;
    if (self.subModel)
    {
        originSubModels = [[NSMutableArray alloc] initWithArray:self.subModel];
    }
    else
    {
        originSubModels = [[NSMutableArray alloc] init];
    }
    [originSubModels addObject:model];
    self.subModel = [originSubModels copy];
}

@end

@interface FHExpandTableView() <UITableViewDataSource, UITableViewDelegate>
{
    struct {
        unsigned int cellForModel : 1;
        unsigned int selectedForModel : 1;
    }_delegateFlag;
}

@property (nonatomic, strong) NSMutableArray *pureData;

@property (nonatomic, strong) NSMutableArray <NSIndexPath *> *willFoldPaths;

@property (nonatomic, strong) NSMutableArray <NSIndexPath *> *willExpandPaths;

@end

@implementation FHExpandTableView

#pragma mark - LifeCycle
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style])
    {
        // Implement UITableViewDataSource & UITableViewDelegate by self
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

#pragma mark - Lazt Init

- (NSMutableArray *)pureData
{
    if (_pureData == nil)
    {
        _pureData = [[NSMutableArray alloc] init];
        [_pureData addObject:self.expandModel];
    }
    return _pureData;
}

-(NSMutableArray<NSIndexPath *> *)willFoldPaths
{
    if (_willFoldPaths == nil)
    {
        _willFoldPaths = [[NSMutableArray alloc] init];
    }
    return _willFoldPaths;
}

- (NSMutableArray<NSIndexPath *> *)willExpandPaths
{
    if (_willExpandPaths == nil)
    {
        _willExpandPaths = [[NSMutableArray alloc] init];
    }
    return _willExpandPaths;
}

#pragma mark - Setter
- (void)setExpandDelegate:(id<FHExpandTableViewDelegate>)expandDelegate
{
    _expandDelegate = expandDelegate;
    if ([_expandDelegate respondsToSelector:@selector(FHExpandTableView:cellForModel:)])
    {
        _delegateFlag.cellForModel = YES;
    }
    if ([_expandDelegate respondsToSelector:@selector(FHExpandTableView:didSelectedIndexPath:expandModel:)])
    {
        _delegateFlag.selectedForModel = YES;
    }
}

#pragma mark - UITableViewDataSource & Deleagte

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pureData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegateFlag.cellForModel)
    {
        return [_expandDelegate FHExpandTableView:self cellForModel:self.pureData[indexPath.row]];
    }
    else
    {
        UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"1"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"1"];
        }
        cell.textLabel.text = [self.pureData[indexPath.row] identifier];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHExpandModel *data = self.pureData[indexPath.row];
    data.expand = !data.expand;
    NSArray *tempPureDataArray = [NSArray arrayWithArray:self.pureData];
    self.pureData = nil;
    [self getPureDataWithMetaData:self.expandModel];
    
    
    [self beginUpdates];
    if (data.expand)
    {
        [self getWillExpandIndexPathsWithPreviousData:tempPureDataArray];
        [self insertRowsAtIndexPaths:self.willExpandPaths withRowAnimation:UITableViewRowAnimationTop];
    }
    else
    {
        [self getWillFoldIndexPathsWithPreviousData:tempPureDataArray];
        [self deleteRowsAtIndexPaths:self.willFoldPaths withRowAnimation:UITableViewRowAnimationTop];
    }
    [self endUpdates];
    [self.willExpandPaths removeAllObjects];
    [self.willFoldPaths removeAllObjects];
    [self deselectRowAtIndexPath:indexPath animated:YES];
    if (_delegateFlag.selectedForModel)
    {
        [_expandDelegate FHExpandTableView:self didSelectedIndexPath:indexPath expandModel:self.pureData[indexPath.row]];
    }
}

- (void)getWillFoldIndexPathsWithPreviousData:(NSArray <FHExpandModel *>*)data
{
    NSMutableSet *previousSet = [NSMutableSet setWithArray:data];
    NSMutableSet *currentSet = [NSMutableSet setWithArray:self.pureData];
    [previousSet minusSet:currentSet];
    for (FHExpandModel *obj in previousSet)
    {
        NSUInteger index = [data indexOfObject:obj];
        [self.willFoldPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
}

- (void)getWillExpandIndexPathsWithPreviousData:(NSArray <FHExpandModel *>*)data
{
    NSMutableSet *previousSet = [NSMutableSet setWithArray:data];
    NSMutableSet *currentSet = [NSMutableSet setWithArray:self.pureData];
    [currentSet minusSet:previousSet];
    for (FHExpandModel *obj in currentSet)
    {
        NSUInteger index = [self.pureData indexOfObject:obj];
        [self.willExpandPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
}

- (NSArray <FHExpandModel *> *)getPureDataWithMetaData:(FHExpandModel *)data {
    if (data.subModel.count) {
        [data.subModel enumerateObjectsUsingBlock:^(FHExpandModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (data.expand)
            {
                [self.pureData addObject:obj];
                [self getPureDataWithMetaData:obj];
            }
        }];
        return self.pureData;
    } else {
        return nil;
    }
}

@end


