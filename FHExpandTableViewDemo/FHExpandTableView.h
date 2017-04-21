//
//  FHExpandTableView.h
//  FHExpandTableView
//
//  Created by 胡翔 on 2017/3/23.
//  Copyright © 2017年 胡翔. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHExpandTableViewDelegate;

#pragma mark - FHExpandModel

@interface FHExpandModel : NSObject

/**
 Use to identify FHExpandModel
 */
@property (nonatomic, copy, nullable) NSString *identifier;

/**
 Child nodes, expanded when father's expand property is YES
 */
@property (nonatomic, strong, nullable) NSArray <FHExpandModel *> *subModels;

@property (nonatomic, weak, nullable) FHExpandModel *fatherModel;

/**
 A bool value to flag whether the model needs to expand the child nodes
 */
@property (nonatomic, assign) BOOL expand;

/**
 A bool value to decide whether the model can respond to expand or fold, default is YES.
 */
@property (nonatomic, assign) BOOL interactionEnabled;

/**
 A bool value to decide whether the models in same level can expand at the same time
 */
@property (nonatomic, assign) BOOL sameLevelExclusion;

/**
 A bool value to decide whether clear the subModels after it be fold. Normally for saving memory, default is NO.
 */
@property (nonatomic, assign) BOOL clearSubModelsWhenFold;

/**
 Use to storage your own custom object in FHExpandModel.
 */
@property (nonatomic, weak, nullable) id object;

@property (nonatomic, assign) Class objectClass;


/**
 Create a FHExpandModel bind with your own object.

 @param object Your own object
 @param identifier FHExpandModel's identifier
 @return FHExpandModel
 */
+ (instancetype)expandModelWithObject:(nullable id)object identifier:(nullable NSString *)identifier;

/**
 Add another FHExpandModel to its subModel.

 @param model The FHExpandModel you want to add
 */
- (void)addSubModel:(FHExpandModel *)model;

/**
 Delete a subModel.
 
 @param model The FHExpandModel you want to delete
 */
- (void)deleteSubModel:(FHExpandModel *)model;


@end

#pragma mark - FHExpandTableView

@interface FHExpandTableView : UITableView

@property (nonatomic, strong, nullable) NSArray<FHExpandModel*> *expandModels;

@property (nonatomic, weak, nullable) id<FHExpandTableViewDelegate> expandDelegate;

/**
 Use this method to clear datas
 */
- (void)clearData;

/**
 Use this method to reload data
 */
- (void)updateData;
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

 @discuss In normal case, you don't have to change FHExpandModel's expand property after selected. FHExpandTableView will automatically solve this. But if you have some more complex needs，manager FHExpandModel's expand property by yourself
 @param indexPath Selected IndexPath
 @param model Selected FHExpandModel
 */
- (void)FHExpandTableView:(FHExpandTableView *)tableView
     didSelectedIndexPath:(NSIndexPath *)indexPath
              expandModel:(FHExpandModel *)model;

/**
 Row height.Default is 44.

 @param tableView FHExpandTableView
 @param indexPath The indexPath you want to specify a height
 @param model The FHExpandModel you want to specify a height
 @return Height value 
 */
- (CGFloat)FHExpandTableView:(FHExpandTableView *)tableView
     heightForRowAtIndexPath:(NSIndexPath *)indexPath
                 expandModel:(FHExpandModel *)model;

/**
 Head view in section

 @param tableView FHExpandTableView
 @param section The section you want to specify a header
 @return UIView
 */
- (UIView *)FHExpandTableView:(FHExpandTableView *)tableView
       viewForHeaderInSection:(NSInteger)section;

/**
 Title for section
 
 @param tableView FHExpandTableView
 @param section The section you want to specify a title
 @return NSString
 */
- (NSString *)FHExpandTableView:(FHExpandTableView *)tableView
       titleForHeaderInSection:(NSInteger)section;
@end

NS_ASSUME_NONNULL_END
