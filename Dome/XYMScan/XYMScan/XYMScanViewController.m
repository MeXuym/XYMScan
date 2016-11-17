//
//  XYMScanViewController.m
//  healthcoming
//
//  Created by jack xu on 16/11/15.
//  Copyright © 2016年 Franky. All rights reserved.
//

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#import "XYMScanViewController.h"
#import "XYMScanView.h"
#import <AVFoundation/AVFoundation.h>
#import "ScanResultViewController.h"

@interface XYMScanViewController ()<XYMScanViewDelegate>
{
    int line_tag;
    UIView *highlightView;
    NSString *scanMessage;
    BOOL isRequesting;
}

@property (nonatomic,weak) XYMScanView *scanV;

@end

@implementation XYMScanViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];;

    XYMScanView *scanV = [[XYMScanView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    scanV.delegate = self;
    [self.view addSubview:scanV];
    _scanV = scanV;

}

-(void)getScanDataString:(NSString*)scanDataString{

    NSLog(@"二维码内容：%@",scanDataString);
    ScanResultViewController *scanResultVC = [[ScanResultViewController alloc]init];
    scanResultVC.view.backgroundColor = [UIColor whiteColor];
    scanResultVC.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    scanResultVC.scanDataString = scanDataString;
    [self.navigationController pushViewController:scanResultVC animated:YES];
}


@end
