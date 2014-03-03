//
//  GoodInfoViewController.m
//  flashShopping
//
//  Created by Width on 14-2-25.
//  Copyright (c) 2014年 chinawidth. All rights reserved.
//

#import "GoodInfoViewController.h"
#import "SGDataService.h"
#import "GoodInfoModle.h"
#import "GoodsDetailViewController.h"

@interface GoodInfoViewController ()<UITableViewDataSource , UITableViewDelegate , UITextFieldDelegate>
{
    UITableView *goodTableView ;
    NSMutableArray *dataArr ;
    CustomNavigationBar *navigationBar ;
    int index ;
    NSInteger Cellheight ;
}
@end

@implementation GoodInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
   
    //自定义导航
    navigationBar = [[CustomNavigationBar alloc]initWithFrame:CGRectMake(0, 20, SCREENMAIN_WIDTH, 44) andTitleArr:[NSArray arrayWithObjects:@"所有商品",@"橱窗中商品",@"出售中商品",@"仓库中商品",@"已下架商品", nil] andSetBarButtonDelegate:self andSetPullNenuDelegate:self ];
    [self.view addSubview:navigationBar];
    
    //加载goodTableView
    goodTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 54, SCREENMAIN_WIDTH, SCREENMAIN_HEIGHT - 54) style:UITableViewStylePlain];
    goodTableView.dataSource = self ;
    goodTableView.delegate = self ;
    [goodTableView setTableHeaderView:_searchBox];//加载搜索框
    [self.view addSubview:goodTableView];
    [self.view bringSubviewToFront:navigationBar];
    
    //加载网络数据
    [self loadNetData:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshNote:) name:@"refresh" object:nil];
}
- (void)loadNetData:(BOOL)isReloadData
{
    NSDictionary *dict = @{@"actionCode":@"441" , @"appType":@"json" , @"companyId":@"00000101"};
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc]initWithDictionary:dict];
    [SGDataService requestWithUrl:BASEURL dictParams:mutableDict httpMethod:@"post" completeBlock:^(id result){
        NSArray *jsonArr = result[@"content"];
        for (NSDictionary *dict in jsonArr) {
            GoodInfoModle *gInfoModle = [GoodInfoModle new];
            gInfoModle.goodsCode = dict[@"goodsCode"];
            gInfoModle.goodsId = dict[@"goodsId"];
            gInfoModle.Id = dict[@"id"];
            gInfoModle.isUp = dict[@"isUp"];
            gInfoModle.name = dict[@"name"];
            gInfoModle.num = dict[@"num"];
            gInfoModle.price = dict[@"price"];
            gInfoModle.viewUrl = dict[@"viewUrl"];
            if (dataArr == nil) {
                dataArr = [NSMutableArray new];
            }
            [dataArr addObject:gInfoModle];
        }
        
         [[NSNotificationCenter defaultCenter]postNotificationName:@"toGooDetaiView" object:dataArr[index]];
        
        if (isReloadData) {
            [goodTableView reloadData];

        }
        
    }];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden= YES ;
}
#pragma mark---UITableViewDataSource
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArr.count ;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *goodCellID = @"goodCellID";
    GoodsCell *goodCell = [tableView dequeueReusableCellWithIdentifier:goodCellID];
    if (goodCell == nil) {
        goodCell = [[GoodsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:goodCellID ];
    }
    GoodInfoModle *goodInfoModle = dataArr[indexPath.row];
    goodCell.goodsModel = goodInfoModle ;
    [goodCell setIntroductionText:goodInfoModle.name];
    return goodCell ;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsDetailViewController *goodsDetaiView = [[GoodsDetailViewController alloc]init];
    goodsDetaiView.goodsModel = dataArr[indexPath.row];
    goodsDetaiView.indexs = indexPath.row ;
    [self.navigationController pushViewController:goodsDetaiView animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return cell.frame.size.height;
    
}
#pragma mark-----NSNotification
- (void)refreshNote:(NSNotification*)note
{
    index = [[note object]intValue];
    [dataArr removeAllObjects];
    [self loadNetData:NO];
   
}
#pragma mark-----UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES ;
}
#pragma mark-----MemoryManager
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark---ChangeHeightProtocol
- (void)ChangeHeight:(NSInteger)height
{
        Cellheight = height ;
}
#pragma mark---customAction
- (void)actions:(id)sender{
    UIButton *b = (UIButton*)sender ;
    if (b.tag == 10) {
         [self.navigationController popViewControllerAnimated:YES];
    }else{
        NSLog(@"刷新…………");
        [dataArr removeAllObjects];
        [self loadNetData:YES];
    }
   
}
- (void)changeTitles:(NSString *)title
{
    [navigationBar.titleButton setTitle:title forState:UIControlStateNormal];
    navigationBar.pullNenu.hidden = YES , navigationBar.flag = !navigationBar.flag ;
}
- (IBAction)searchButton:(id)sender {
    NSLog(@"开始搜索…………");
}
@end
