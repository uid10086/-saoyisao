//
//  ViewController.m
//  扫一扫demo
//
//  Created by Alion on 16/12/28.
//  Copyright © 2016年 Alion. All rights reserved.
//
#define SCREEN_WIDTH                [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT               [[UIScreen mainScreen] bounds].size.height
#import "ViewController.h"
#import "KBScanQrcodeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)initUI{
    
    self.title = @"扫一扫跳转页面";
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(50, 100, SCREEN_WIDTH - 100, 300)];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:20];
    label.textColor = [UIColor redColor];
    label.text = @"1.注意要先在plist里设置相机权限,图库权限。\n2.图片和声音文件也须导入\n3.如果想访问网页还需配置http权限\n＊ScanPage文件夹的内容都是所需的";
/** 将权限添加到plist里
 <key>NSAppTransportSecurity</key>
 <dict>
 <key>NSAllowsArbitraryLoads</key>
 <true/>
 </dict>
 <key>NSPhotoLibraryUsageDescription</key>
 <string>App需要您的同意,才能访问相册</string>
 <key>NSCameraUsageDescription</key>
 <string>App需要您的同意,才能访问相机</string>
 **/
    [self.view addSubview:label];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 400, SCREEN_WIDTH - 200, 50);
    button.backgroundColor = [UIColor greenColor];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setTitle:@"点击进入扫一扫" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}
-(void)click{
    
    KBScanQrcodeViewController * controller = [[KBScanQrcodeViewController alloc]init];
    [self presentViewController:controller animated:YES completion:^{
        
    }];
    //[self.navigationController pushViewController:controller animated:YES];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
