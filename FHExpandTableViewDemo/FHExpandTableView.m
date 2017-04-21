//
//  FHExpandTableView.m
//  FHExpandTableView
//
//  Created by Moxtra on 2017/3/23.
//  Copyright © 2017年 Moxtra. All rights reserved.
//

#import "FHExpandTableView.h"

@interface FHExpandModel()
{
    NSUInteger _totalCounts;
}

@property (nonatomic, strong) NSMutableArray <FHExpandModel *> *subModelInternal;

@end

@implementation FHExpandModel

- (instancetype)init {
    if (self = [super init]) {
        _totalCounts = 1;
        _interactionEnabled = YES;
    }
    return self;
}

#pragma mark - Getter

- (NSUInteger)subDataCount {
    return [self getSubModelCountWithModel:self];
}

- (NSMutableArray<FHExpandModel *> *)subModelInternal {
    if (_subModelInternal == nil) {
        _subModelInternal = [[NSMutableArray alloc] init];
    }
    return _subModelInternal;
}

- (NSArray<FHExpandModel *> *)subModels {
    return [self.subModelInternal copy];
}

- (void)setSubModels:(NSArray<FHExpandModel *> *)subModels {
    self.subModelInternal = [[NSMutableArray alloc] initWithArray:subModels];
}

#pragma mark - DataHelper

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

#pragma mark - Public

+ (instancetype)expandModelWithObject:(id)object identifier:(NSString *)identifier {
    FHExpandModel *model = [[FHExpandModel alloc] init];
    model.object = object;
    model.identifier = identifier;
    return model;
}

- (void)addSubModel:(FHExpandModel *)model {
    [self.subModelInternal addObject:model];
    model.fatherModel = self;
}

- (void)deleteSubModel:(FHExpandModel *)model {
    model.fatherModel = nil;
    [self.subModelInternal removeObject:model];
}

@end

@interface FHExpandTableView() <UITableViewDataSource, UITableViewDelegate>
{
    struct {
        unsigned int cellForModel : 1;
        unsigned int selectedForModel : 1;
        unsigned int heightForModel: 1;
        unsigned int viewForHead:1;
        unsigned int titleForHead:1;
    }_delegateFlag;
}

@property (nonatomic, strong) NSMutableArray *pureData;

@property (nonatomic, strong) FHExpandModel *totalExpandModel;

@property (nonatomic, strong) NSMutableArray <NSIndexPath *> *willFoldPaths;

@property (nonatomic, strong) NSMutableArray <NSIndexPath *> *willExpandPaths;

@end

static CGFloat const kDefaultCellHeight = 44.f;
static NSString *const kFHExpandTableViewDefaultReuseIdentifier = @"kFHExpandTableViewDefaultReuseIdentifier";

@implementation FHExpandTableView

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        // Implement UITableViewDataSource & UITableViewDelegate by self
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

#pragma mark - Lazt Init

- (NSMutableArray *)pureData {
    if (_pureData == nil) {
        _pureData = [[NSMutableArray alloc] init];
        [_pureData addObjectsFromArray:self.expandModels];
    }
    return _pureData;
}

-(NSMutableArray<NSIndexPath *> *)willFoldPaths {
    if (_willFoldPaths == nil) {
        _willFoldPaths = [[NSMutableArray alloc] init];
    }
    return _willFoldPaths;
}

- (NSMutableArray<NSIndexPath *> *)willExpandPaths {
    if (_willExpandPaths == nil) {
        _willExpandPaths = [[NSMutableArray alloc] init];
    }
    return _willExpandPaths;
}

#pragma mark - Setter

- (void)setExpandModels:(NSArray<FHExpandModel *> *)expandModels {
    _expandModels = expandModels;
    [self.pureData removeAllObjects];
    [self.pureData addObjectsFromArray:self.expandModels];
}

- (void)setExpandDelegate:(id<FHExpandTableViewDelegate>)expandDelegate {
    _expandDelegate = expandDelegate;
    if ([_expandDelegate respondsToSelector:@selector(FHExpandTableView:cellForModel:)]) {
        _delegateFlag.cellForModel = YES;
    }
    if ([_expandDelegate respondsToSelector:@selector(FHExpandTableView:didSelectedIndexPath:expandModel:)]) {
        _delegateFlag.selectedForModel = YES;
    }
    if ([_expandDelegate respondsToSelector:@selector(FHExpandTableView:heightForRowAtIndexPath:expandModel:)]) {
        _delegateFlag.heightForModel = YES;
    }
    if ([_expandDelegate respondsToSelector:@selector(FHExpandTableView:viewForHeaderInSection:)]) {
        _delegateFlag.viewForHead = YES;
    }
    if ([_expandDelegate respondsToSelector:@selector(FHExpandTableView:titleForHeaderInSection:)]) {
        _delegateFlag.titleForHead = YES;
    }
}

#pragma mark - Public Method

- (void)clearData {
    if (self.expandModels) {
        self.expandModels = nil;
        self.pureData = nil;
        [self reloadData];
    }
}

#pragma mark - UITableViewDataSource & Deleagte

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pureData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegateFlag.cellForModel) {
        return [_expandDelegate FHExpandTableView:self cellForModel:self.pureData[indexPath.row]];
    }
    else {
        UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:kFHExpandTableViewDefaultReuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:kFHExpandTableViewDefaultReuseIdentifier];
        }
        cell.textLabel.text = [self.pureData[indexPath.row] identifier];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegateFlag.selectedForModel) {
        [_expandDelegate FHExpandTableView:self didSelectedIndexPath:indexPath expandModel:self.pureData[indexPath.row]];
    }
    self.totalExpandModel = [[FHExpandModel alloc] init];
    self.totalExpandModel.expand = YES;
    for (FHExpandModel *expandModel in self.expandModels) {
        [self.totalExpandModel addSubModel:expandModel];
    }
    
    FHExpandModel *data = self.pureData[indexPath.row];
    if (data.interactionEnabled) {
        data.expand = !data.expand;
    }
    if (data.sameLevelExclusion) {
        for (FHExpandModel *model in data.fatherModel.subModels) {
            if (model != data) {
                model.expand = NO;
                model.subModels = nil;
            }
        }
    }
    NSArray *tempPureDataArray = [NSArray arrayWithArray:self.pureData];
    [self.pureData removeAllObjects];
    [self getPureDataWithMetaData:self.totalExpandModel];


    [self beginUpdates];
    [self getWillExpandIndexPathsWithPreviousData:tempPureDataArray];
    [self insertRowsAtIndexPaths:self.willExpandPaths withRowAnimation:UITableViewRowAnimationTop];
    [self getWillFoldIndexPathsWithPreviousData:tempPureDataArray];
    [self deleteRowsAtIndexPaths:self.willFoldPaths withRowAnimation:UITableViewRowAnimationTop];
    [self endUpdates];
    [self.willExpandPaths removeAllObjects];
    [self.willFoldPaths removeAllObjects];
    [self deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegateFlag.heightForModel) {
        return [_expandDelegate FHExpandTableView:self heightForRowAtIndexPath:indexPath expandModel:self.pureData[indexPath.row]];
    }
    else {
        return kDefaultCellHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_delegateFlag.viewForHead) {
        return [_expandDelegate FHExpandTableView:self viewForHeaderInSection:section];
    }
    else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_delegateFlag.titleForHead) {
        return [_expandDelegate FHExpandTableView:self titleForHeaderInSection:section];
    }
    else {
        return nil;
    }
}

#pragma mark - Private Method

- (void)getWillFoldIndexPathsWithPreviousData:(NSArray <FHExpandModel *>*)data {
    NSMutableSet *previousSet = [NSMutableSet setWithArray:data];
    NSMutableSet *currentSet = [NSMutableSet setWithArray:self.pureData];
    [previousSet minusSet:currentSet];
    for (FHExpandModel *obj in previousSet) {
        NSUInteger index = [data indexOfObject:obj];
        [self.willFoldPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
}

- (void)getWillExpandIndexPathsWithPreviousData:(NSArray <FHExpandModel *>*)data {
    NSMutableSet *previousSet = [NSMutableSet setWithArray:data];
    NSMutableSet *currentSet = [NSMutableSet setWithArray:self.pureData];
    [currentSet minusSet:previousSet];
    for (FHExpandModel *obj in currentSet) {
        NSUInteger index = [self.pureData indexOfObject:obj];
        [self.willExpandPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
}

- (NSArray <FHExpandModel *> *)getPureDataWithMetaData:(FHExpandModel *)data {
    if (data.subModels.count) {
        [data.subModels enumerateObjectsUsingBlock:^(FHExpandModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (data.expand) {
                [self.pureData addObject:obj];
                [self getPureDataWithMetaData:obj];
            }
        }];
        return self.pureData;
    } else {
        return nil;
    }
}

#pragma mark - Public Method

- (void)update
{
    self.totalExpandModel = [[FHExpandModel alloc] init];
    self.totalExpandModel.expand = YES;
    for (FHExpandModel *expandModel in self.expandModels) {
        [self.totalExpandModel addSubModel:expandModel];
    }
    
    NSArray *tempPureDataArray = [NSArray arrayWithArray:self.pureData];
    [self.pureData removeAllObjects];
    [self getPureDataWithMetaData:self.totalExpandModel];
    
    
    [self beginUpdates];
    [self getWillExpandIndexPathsWithPreviousData:tempPureDataArray];
    [self insertRowsAtIndexPaths:self.willExpandPaths withRowAnimation:UITableViewRowAnimationTop];
    [self getWillFoldIndexPathsWithPreviousData:tempPureDataArray];
    [self deleteRowsAtIndexPaths:self.willFoldPaths withRowAnimation:UITableViewRowAnimationTop];
    [self endUpdates];
    [self.willExpandPaths removeAllObjects];
    [self.willFoldPaths removeAllObjects];
}

- (void)updateData
{
//    NSArray *tempPureDataArray = [NSArray arrayWithArray:self.pureData];
    [self.pureData removeAllObjects];
    [self getPureDataWithMetaData:self.totalExpandModel];
    [self reloadData];
    
//    [self beginUpdates];
//    [self getWillExpandIndexPathsWithPreviousData:tempPureDataArray];
//    [self insertRowsAtIndexPaths:self.willExpandPaths withRowAnimation:UITableViewRowAnimationTop];
//    [self getWillFoldIndexPathsWithPreviousData:tempPureDataArray];
//    [self deleteRowsAtIndexPaths:self.willFoldPaths withRowAnimation:UITableViewRowAnimationTop];
//    [self endUpdates];
//    [self.willExpandPaths removeAllObjects];
//    [self.willFoldPaths removeAllObjects];
}
@end
