//
//  KBScanQrcodeViewController.m
//  ykbme_ios
//
//  Created by Alion on 16/12/7.
//  Copyright © 2016年 Chengdu Sanfast Technology Co., Ltd. All rights reserved.
//
#define SCREEN_WIDTH                [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT               [[UIScreen mainScreen] bounds].size.height
#define SCREEN_FRAME                [[UIScreen mainScreen] bounds]
#define LEFT                         12 * [UIScreen mainScreen].bounds.size.width / 375
#define RIGHT                       -12 * [UIScreen mainScreen].bounds.size.width / 375
#define WIDTH_SIZE                  [UIScreen mainScreen].bounds.size.width / 375
#define HEIGHT_SIZE                 ([UIScreen mainScreen].bounds.size.height / 667 < 1 ? 1:[UIScreen mainScreen].bounds.size.height / 667)

#import "KBScanQrcodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ImagePicker.h"
//webview
#import "KBScanWebViewController.h"
@interface KBScanQrcodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>{
    int number;
    NSTimer *timer;
    NSInteger _count;
    BOOL upOrdown;
    AVCaptureDevice *lightDevice;
}
@property (nonatomic,strong) UIView *centerView;//扫描的显示视图

/**
 * 二维码扫描参数
 */
@property (strong,nonatomic) AVCaptureDevice *device;
@property (strong,nonatomic) AVCaptureDeviceInput *input;
@property (strong,nonatomic) AVCaptureMetadataOutput *output;
@property (strong,nonatomic) AVCaptureSession *session;
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic,retain) UIImageView *imageView;//扫描线

@end

@implementation KBScanQrcodeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_session && ![_session isRunning]) {
        [_session startRunning];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(scanningAnimation) userInfo:nil repeats:YES];
    [self setupCamera];
}

- (void)viewWillDisappear:(BOOL)animated {
    _count= 0;
    [timer invalidate];
    [self stopReading];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫一扫";
    self.view.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    CGFloat top = 100 * HEIGHT_SIZE;
    CGFloat scanWide =  260* HEIGHT_SIZE;
    CGFloat scanHeight = 260 * HEIGHT_SIZE;
    _count = 0 ;
    //初始化闪光灯设备
    lightDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //扫描范围
    _centerView = [[UIView alloc]initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT)];
    _centerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_centerView];
    //扫描的视图加载
    UIView *scanningViewOne = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, top)];
    scanningViewOne.backgroundColor= [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.centerView addSubview:scanningViewOne];
    
    UIView *scanningViewTwo = [[UIView alloc]initWithFrame:CGRectMake(0, top, (self.view.frame.size.width-scanWide)/2, scanHeight)];
    scanningViewTwo.backgroundColor= [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.centerView addSubview:scanningViewTwo];
    
    UIView *scanningViewThree = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - (SCREEN_WIDTH - scanWide)/2, top, SCREEN_WIDTH - (SCREEN_WIDTH - scanWide)/2, scanHeight)];
    scanningViewThree.backgroundColor= [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.centerView addSubview:scanningViewThree];
    
    UIView *scanningViewFour = [[UIView alloc]initWithFrame:CGRectMake(0, top + scanHeight, self.view.frame.size.width,SCREEN_HEIGHT - top - scanHeight)];
    scanningViewFour.backgroundColor= [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.centerView addSubview:scanningViewFour];
    UIImageView * scanView = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - scanWide)/2, 100 * HEIGHT_SIZE, scanWide, scanHeight)];
    scanView.image = [UIImage imageNamed:@"saomakuang"];
    [self.view addSubview:scanView];
    UILabel *labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - scanWide)/2, top + scanWide + 10 * HEIGHT_SIZE, scanWide, 20)];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    labIntroudction.textColor = [UIColor whiteColor];
    labIntroudction.text = @"将二维码放入框内,即可自动扫描";
    labIntroudction.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:labIntroudction];
    UIButton *tempLabel= [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - scanWide)/2, top + scanWide + 20 + 20 * HEIGHT_SIZE, scanWide, 20)];
    tempLabel.backgroundColor = [UIColor clearColor];
    //tempLabel.textAlignment = NSTextAlignmentCenter;
    [tempLabel setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [tempLabel setTitle:@"识别二维码" forState:UIControlStateNormal];// .text = @"识别二维码";
    tempLabel.titleLabel.font = [UIFont systemFontOfSize:15];
    [tempLabel addTarget:self action:@selector(tempButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tempLabel];
    UIButton *openLight = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 25, top + scanWide + 20 + 20 * HEIGHT_SIZE + 30 * HEIGHT_SIZE, 50, 50)];
    [openLight setImage:[UIImage imageNamed:@"deng"] forState:UIControlStateNormal];
    [openLight setImage:[UIImage imageNamed:@"deng1"] forState:UIControlStateSelected];
    [openLight addTarget:self action:@selector(openLightWay:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem * rightBarbutton = [[UIBarButtonItem alloc] initWithCustomView:openLight];
//    self.navigationItem.rightBarButtonItem = rightBarbutton;
    [self.view addSubview:openLight];
    //扫描线
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - scanWide)/2 + 10 * WIDTH_SIZE, 10 * HEIGHT_SIZE + top, scanWide - 20, 5)];
    _imageView.image = [UIImage imageNamed:@"icon_xuanzhong"];
    [self.centerView addSubview:_imageView];
    
    //返回键用导航栏可以去掉
    UIButton * button  = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 50, SCREEN_HEIGHT-100, 100, 50)];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
//返回
-(void)click{
    [self dismissViewControllerAnimated:YES completion:^{
         NSLog(@"移除");
    }];
}
//#pragma mark -- 设置参数
- (void)setupCamera {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
        
        _output = [[AVCaptureMetadataOutput alloc]init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        _session = [[AVCaptureSession alloc]init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        if ([_session canAddInput:self.input])
        {
            [_session addInput:self.input];
        }
        
        if ([_session canAddOutput:self.output])
        {
            [_session addOutput:self.output];
        }
        
        // 条码类型 AVMetadataObjectTypeQRCode
        _output.metadataObjectTypes = [NSArray arrayWithObjects:AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode, nil];
        //设置扫码区域／／ x,y,h,w 颠倒并且要除以屏幕宽高
         [_output setRectOfInterest :CGRectMake(100 * HEIGHT_SIZE/SCREEN_HEIGHT, ((SCREEN_WIDTH - 260 * HEIGHT_SIZE)/2)/SCREEN_WIDTH , 260 * HEIGHT_SIZE/SCREEN_HEIGHT, 260 * HEIGHT_SIZE/SCREEN_WIDTH)] ;
        dispatch_async(dispatch_get_main_queue(), ^{
            //更新界面
            _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
            _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
            _preview.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            [self.centerView.layer insertSublayer:self.preview atIndex:0];
            [_session startRunning];
        });
    });
}

//扫描动画
- (void)scanningAnimation {
    if (upOrdown == NO) {
        number ++;
        _imageView.frame = CGRectMake((SCREEN_WIDTH - 260* HEIGHT_SIZE)/2 + 10 * WIDTH_SIZE, 10 * HEIGHT_SIZE + 2*number * HEIGHT_SIZE + 100 * HEIGHT_SIZE,240* HEIGHT_SIZE , 5);
        if (2*number >= 240) {
            upOrdown = YES;
        }
    }
    else {
        number --;
        _imageView.frame = CGRectMake((SCREEN_WIDTH - 260* HEIGHT_SIZE)/2 + 10 * WIDTH_SIZE, 10 * HEIGHT_SIZE + 100 * HEIGHT_SIZE + 2*number * HEIGHT_SIZE, 240* HEIGHT_SIZE, 5);
        if (number == 0) {
            upOrdown = NO;
        }
    }
}

- (void)stopReading {
    [_session stopRunning];
    _session = nil;
    [_preview removeFromSuperlayer];
    [timer invalidate];
    timer = nil ;
}

-(void)openLightWay:(UIButton *)sender {
    
    if (![lightDevice hasTorch]) {//判断是否有闪光灯
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"当前设备没有闪光灯，不能提供手电筒功能" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:sureAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    sender.selected = !sender.selected;
    if (sender.selected == YES) {
        [lightDevice lockForConfiguration:nil];
        [lightDevice setTorchMode:AVCaptureTorchModeOn];
        [lightDevice unlockForConfiguration];
    }
    else
    {
        [lightDevice lockForConfiguration:nil];
        [lightDevice setTorchMode: AVCaptureTorchModeOff];
        [lightDevice unlockForConfiguration];
    }
}

#pragma mark -- AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSString *stringValue;
    if ([metadataObjects count] >0){
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    _count ++ ;//加锁
    if (stringValue && _count == 1) {
        //扫描完成
     [self HandleResult:stringValue];
    }
}

#pragma mark -action
-(void)tempButtonClick{
    [[ImagePicker sharedInstance] pickImageIn:self bySourceType:SourceTypePhotoLibrary allowsEditing:NO withCompletionHandler:^(NSData *imageData, UIImage *image) {
        _count ++;//加锁
        NSString *content = @"" ;
        CIImage *ciImage = [CIImage imageWithData:imageData];
        //创建探测器
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
        NSArray *feature = [detector featuresInImage:ciImage];
        //取出探测到的数据
        for (CIQRCodeFeature *result in feature) {
            content = result.messageString;
        }
        //进行处理(音效、网址分析、页面跳转等)
        [self HandleResult:content];
    }];
}
//对结果进行处理。。这里只做了简单的判断是否是网址
-(void)HandleResult:(NSString *)result{
    [self playBeep];
    NSLog(@"扫描结果 =%@",result);
    if([self validateHttps:result]){
        //是网址
        KBScanWebViewController * con = [[KBScanWebViewController alloc]init];
        con.url = result;
        [self presentViewController:con animated:YES completion:^{
            
        }];
    }else{
        //不是网址
        NSLog(@"扫描结果 =%@",@"不是网址");
    }
    //扫码间隔4秒可自行设置
    [self performSelector:@selector(unlocked) withObject:nil afterDelay:4.0f];
}
//解锁
-(void)unlocked{
    if(_count != 0){
        _count = 0;
    }
}
- (void)playBeep{
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"saoyisao"ofType:@"mp3"]], &soundID);
    AudioServicesPlaySystemSound(soundID);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
- (BOOL)validateHttps:(NSString *)https{
    NSString *httpStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSPredicate *httpPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", httpStr];
    return [httpPredicate evaluateWithObject:https];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
