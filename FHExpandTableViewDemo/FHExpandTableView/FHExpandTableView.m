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

@property (nonatomic, strong) NSMutableArray <FHExpandModel *> *internalSubModels;
@end

@implementation FHExpandModel

#pragma mark - Initialize

- (instancetype)init {
    if (self = [super init]) {
        _totalCounts = 1;
    }
    return self;
}

+ (instancetype)expandModelWithObject:(id)object identifier:(NSString *)identifier {
    FHExpandModel *model = [[FHExpandModel alloc] init];
    model.object = object;
    model.identifier = identifier;
    return model;
}

#pragma mark - Getter

- (NSUInteger)subDataCount {
    return [self getSubModelCountWithModel:self];
}

- (NSMutableArray<FHExpandModel *> *)internalSubModels {
    if (_internalSubModels == nil) {
        _internalSubModels = [[NSMutableArray alloc] init];
    }
    return _internalSubModels;
}

- (NSArray<FHExpandModel *> *)subModels {
    return [self.internalSubModels copy];
}

#pragma mark - SubModel Operation

- (void)setSubModels:(NSArray<FHExpandModel *> *)subModels {
    self.internalSubModels = [[NSMutableArray alloc] initWithArray:subModels];
}

- (NSUInteger)getSubModelCountWithModel:(FHExpandModel *)model {
    // Traverse all child nodes
    if (model.subModels.count) {
        [model.subModels enumerateObjectsUsingBlock:^(FHExpandModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (model.expand) {
                [self getSubModelCountWithModel:obj];
            }
        }];
        if (model.expand) {
            _totalCounts += model.subModels.count;
        }
        return _totalCounts;
    } else {
        return 0;
    }
}

- (void)addSubModel:(FHExpandModel *)model {
    [self.internalSubModels addObject:model];
    model.fatherModel = self;
}

- (void)deleteSubModel:(FHExpandModel *)model {
    [self.internalSubModels removeObject:model];
    model.fatherModel = nil;
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

/**
 Use to package self.expandModels
 */
@property (nonatomic, strong) FHExpandModel *totalExpandModel;

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
        [_pureData addObjectsFromArray:self.expandModels];
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
    if ([_expandDelegate respondsToSelector:@selector(fhExpandTableView:cellForModel:)])
    {
        _delegateFlag.cellForModel = YES;
    }
    if ([_expandDelegate respondsToSelector:@selector(fhExpandTableView:didSelectedIndexPath:expandModel:)])
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
        return [_expandDelegate fhExpandTableView:self cellForModel:self.pureData[indexPath.row]];
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
    if (_delegateFlag.selectedForModel)
    {
        [_expandDelegate fhExpandTableView:self didSelectedIndexPath:indexPath expandModel:self.pureData[indexPath.row]];
    }
    self.totalExpandModel = [[FHExpandModel alloc] init];
    self.totalExpandModel.expand = YES;
    for (FHExpandModel *expandModel in self.expandModels) {
        [self.totalExpandModel addSubModel:expandModel];
    }
    
    FHExpandModel *data = self.pureData[indexPath.row];
    data.expand = !data.expand;
    if (data.sameLevelExclusion)
    {
        for (FHExpandModel *model in data.fatherModel.subModels) {
            if (model != data)
            {
                model.expand = NO;
                model.subModels = nil;
            }
        }
    }
    NSArray *tempPureDataArray = [NSArray arrayWithArray:self.pureData];
    [self.pureData removeAllObjects];
    [self getPureDataWithMetaData:self.totalExpandModel];
    
    
    [self beginUpdates];
    //    if (data.expand)
    //    {
    [self getWillExpandIndexPathsWithPreviousData:tempPureDataArray];
    [self insertRowsAtIndexPaths:self.willExpandPaths withRowAnimation:UITableViewRowAnimationTop];
    //    }
    //    else
    //    {
    [self getWillFoldIndexPathsWithPreviousData:tempPureDataArray];
    [self deleteRowsAtIndexPaths:self.willFoldPaths withRowAnimation:UITableViewRowAnimationTop];
    //    }
    [self endUpdates];
    [self.willExpandPaths removeAllObjects];
    [self.willFoldPaths removeAllObjects];
    [self deselectRowAtIndexPath:indexPath animated:YES];
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
    if (data.subModels.count) {
        [data.subModels enumerateObjectsUsingBlock:^(FHExpandModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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


