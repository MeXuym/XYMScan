//
//  ScanResultViewController.m
//  healthcoming
//
//  Created by jack xu on 16/11/16.
//  Copyright © 2016年 Franky. All rights reserved.
//


#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#import "ScanResultViewController.h"

@interface ScanResultViewController ()

@property (nonatomic,weak) UILabel *test;

@end

@implementation ScanResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *test = [[UILabel alloc]init];
    test.frame = CGRectMake(20, 200, ScreenWidth - 40, 200);
    test.numberOfLines = 0;
    [self.view addSubview:test];
    _test = test;

    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

-(void)setScanDataString:(NSString *)scanDataString{

    _scanDataString = scanDataString;
    
    _test.text = _scanDataString;
}

-(void)goBack{

    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
