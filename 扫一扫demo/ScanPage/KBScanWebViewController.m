//
//  KBScanWebViewController.m
//  ykbme_ios
//
//  Created by Alion on 16/12/21.
//  Copyright © 2016年 Chengdu Sanfast Technology Co., Ltd. All rights reserved.
//
#define SCREEN_FRAME                [[UIScreen mainScreen] bounds]
#import "KBScanWebViewController.h"

@interface KBScanWebViewController ()<UIWebViewDelegate>

@end

@implementation KBScanWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //返回键用导航栏可以去掉
    UIButton * button  = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_FRAME.size.width/2 - 50, 20, 100, 50)];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    UIWebView * webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_FRAME.size.width, SCREEN_FRAME.size.height)];
    webView.delegate = self;
    [self.view addSubview:webView];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//返回
-(void)click{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
