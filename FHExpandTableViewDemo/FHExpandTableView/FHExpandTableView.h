//
//  FHExpandTableView.h
//  FHExpandTableViewDemo
//
//  Created by 胡翔 on 2017/3/23.
//  Copyright © 2017年 胡翔. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FHExpandTableViewDelegate;

#pragma mark - FHExpandModel

@interface FHExpandModel : NSObject

/**
 Use to identify FHExpandModel
 */
@property (nonatomic, copy) NSString *identifier;

/**
 Child nodes, expanded when father's expand property is YES
 */
@property (nonatomic, strong) NSArray <FHExpandModel *> *subModel;

/**
 A bool value to flag whether the model needs to expand the child nodes
 */
@property (nonatomic, assign) BOOL expand;

/**
 The number of all child nodes.
 Including the children of the child nodes and their own,
 child nodes are calculated only when their father's expand property is YES,
 otherwise only count the father node.
 */
@property (nonatomic, assign) NSUInteger subModelCounts;

@property (nonatomic, strong, readonly) NSIndexPath *indexPath;

/**
 Use to storage your own custom object in FHExpandModel.
 */
@property (nonatomic, weak) id object;

/**
 Create a FHExpandModel bind with your own object.
 
 @param object Your own object
 @param identifier FHExpandModel's identifier
 @return FHExpandModel
 */
+ (instancetype)expandModelWithObject:(id)object identifier:(NSString *)identifier;

/**
 Add another FHExpandModel to its subModel.
 
 @param model FHExpandModel you want to add
 */
- (void)addSubModel:(FHExpandModel *)model;

@end

#pragma mark - FHExpandTableView

@interface FHExpandTableView : UITableView

@property (nonatomic, strong) FHExpandModel *expandModel;

@property (nonatomic, weak) id<FHExpandTableViewDelegate> expandDelegate;

@end

#pragma mark - FHExpandTableViewDelegate

@protocol FHExpandTableViewDelegate <NSObject>

@optional

/**
 Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
 @discuss Highly suggest that you should implement this proxy method,otherwise it will use UITableViewCell to display model's identifier default.
 For further use,see demo please.
 @param tableView FHExpandTableView
 @param model The FHExpandModel you want to display.You should establish an association between your own custom cell and FHExpandModel.
 @return You custom cell.
 */
- (UITableViewCell *)FHExpandTableView:(FHExpandTableView *)tableView
                          cellForModel:(FHExpandModel *)model;

/**
 Called after the user selected the cell.
 
 @discuss In FHExpandTableView, you don't have to change FHExpandModel's expand property after selected. FHExpandTableView will automatically solve this.
 @param indexPath Selected IndexPath
 @param model Selected FHExpandModel
 */
- (void)FHExpandTableView:(FHExpandTableView *)tableView
     didSelectedIndexPath:(NSIndexPath *)indexPath
              expandModel:(FHExpandModel *)model;

@end
