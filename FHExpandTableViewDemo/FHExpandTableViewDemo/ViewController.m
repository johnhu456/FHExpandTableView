//
//  ViewController.m
//  FHExpandTableViewDemo
//
//  Created by 胡翔 on 2017/3/23.
//  Copyright © 2017年 胡翔. All rights reserved.
//

#import "ViewController.h"
#import "FHExpandTableView.h"

@interface ViewController ()<FHExpandTableViewDelegate>

@property (nonatomic, strong) FHExpandModel *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    FHExpandTableView *tableView = [[FHExpandTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    FHExpandModel *data0 = [[FHExpandModel alloc] init];
    FHExpandModel *data1 = [[FHExpandModel alloc] init];
    FHExpandModel *data2 = [[FHExpandModel alloc] init];
    FHExpandModel *data3 = [[FHExpandModel alloc] init];
    FHExpandModel *data4 = [[FHExpandModel alloc] init];
    FHExpandModel *data5 = [[FHExpandModel alloc] init];
    FHExpandModel *data6 = [[FHExpandModel alloc] init];
    FHExpandModel *data7 = [[FHExpandModel alloc] init];
    FHExpandModel *data8 = [[FHExpandModel alloc] init];
    data0.identifier = @"0";
    data1.identifier = @"1";
    data2.identifier = @"2";
    data3.identifier = @"3";
    data4.identifier = @"4";
    data5.identifier = @"5";
    data6.identifier = @"6";
    data7.identifier = @"7";
    data8.identifier = @"8";
    data0.subModel = @[data1,data2];
    data1.subModel = @[data3,data4];
    data2.subModel = @[data5,data6];
    data7 = data0;
    data0.expand = NO;
    data8.expand = YES;
    data8.subModel = @[data0];
    self.data = data8;
    NSUInteger ha = data8.subModelCounts;
    NSLog(@"%lu",(unsigned long)ha);
    tableView.expandModel = data8;
    tableView.expandDelegate = self;
    [self.view addSubview:tableView];
}

- (UITableViewCell *)FHExpandTableView:(FHExpandTableView *)tableView cellForModel:(FHExpandModel *)model
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"1"];
    
    if ([model.identifier isEqualToString:@"8"])
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
    NSLog(@"======%@",model.identifier);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
