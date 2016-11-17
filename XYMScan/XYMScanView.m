//
//  XYMScanView.m
//
//  Created by jack xu on 16/11/16.
//  Copyright © 2016年 jack xu All rights reserved.
//

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height


#import "XYMScanView.h"
#import <AVFoundation/AVFoundation.h>


@interface XYMScanView ()<AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession * session;//输入输出的中间桥梁
    int line_tag;
    UIView *highlightView;
    NSString *scanMessage;
    BOOL isRequesting;
}

@property (nonatomic,weak) UIView *leftView;
@property (nonatomic,weak) UIView *rightView;
@property (nonatomic,weak) UIView *upView;
@property (nonatomic,weak) UIView *downView;
@property (nonatomic,weak) UIImageView *centerView; //扫描框
@property (nonatomic,weak) UIImageView *line; //扫描线

@end



@implementation XYMScanView

@synthesize delegate;

- (instancetype)init{
    
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}

/**
 * 不管调用的init还是initWithFrame,都会来到这里
 */
- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self =[super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

/**
 *  初始化
 */
- (void)setUp{

    [self instanceDevice];
}


/**
 *  设置扫码框的宽
 */
-(void)setScanW:(int)scanW{
    
    _scanW = scanW;
    
    [self layoutSubviews];
}


/**
 *  配置相机属性
 */
- (void)instanceDevice{
    
    line_tag = 10000 + 1116; //0-99 为系统所用

    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    session = [[AVCaptureSession alloc]init];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if (input) {
        
        [session addInput:input];
    }
    if (output) {
        
        [session addOutput:output];
        NSMutableArray *a = [[NSMutableArray alloc] init];
        
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [a addObject:AVMetadataObjectTypeQRCode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [a addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [a addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [a addObject:AVMetadataObjectTypeCode128Code];
        }
        output.metadataObjectTypes=a;
    }
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.layer.bounds;
    [self.layer insertSublayer:layer atIndex:0];
    
    [self setOverlayPickerView];
    
    [session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
    
    [session startRunning];
}

/**
 *  监听扫码状态-修改扫描动画
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    
    if ([object isKindOfClass:[AVCaptureSession class]]) {
        
        BOOL isRunning = ((AVCaptureSession *)object).isRunning;
        if (isRunning) {
            
            [self addAnimation];
        }else{
            [self removeAnimation];
        }
    }
}


/**
 *  获取扫码结果
 */
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {

        [self stopRunning];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex :0];
        
        //输出扫描字符串
        NSString *data = metadataObject.stringValue;
        
        if (data) {
            NSLog(@"%@",data);

            scanMessage = data;
            
            if(delegate && [delegate respondsToSelector:@selector(getScanDataString:)])
            {
                [delegate getScanDataString:scanMessage];
            }
            NSLog(@"%@",scanMessage);
        }
    }
}



/**
 *  创建扫码页面
 */
- (void)setOverlayPickerView
{
    //左侧的view 原来宽30
    UIView *leftView = [[UIView alloc]init];
    leftView.alpha = 0.5;
    leftView.backgroundColor = [UIColor blackColor];
    [self addSubview:leftView];
    _leftView = leftView;
    
    //右侧的view
    UIView *rightView = [[UIView alloc]init];
    rightView.alpha = 0.5;
    rightView.backgroundColor = [UIColor blackColor];
    [self addSubview:rightView];
    _rightView = rightView;
    
    //最上部view
    UIView *upView = [[UIView alloc]init];
    upView.alpha = 0.5;
    upView.backgroundColor = [UIColor blackColor];
    [self addSubview:upView];
    _upView = upView;
    
    //底部view
    UIView *downView = [[UIView alloc]init];
    downView.alpha = 0.5;
    downView.backgroundColor = [UIColor blackColor];
    [self addSubview:downView];
    _downView = downView;
    
    UIImageView *centerView = [[UIImageView alloc]init];
    //扫描框图片的拉伸，拉伸中间一块区域
    UIImage *scanImage = [UIImage imageNamed:@"QR"];
    CGFloat top = 34*0.5-1; // 顶端盖高度
    CGFloat bottom = top ; // 底端盖高度
    CGFloat left = 34*0.5-1; // 左端盖宽度
    CGFloat right = left; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    scanImage = [scanImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    
    centerView.image = scanImage;
    centerView.contentMode = UIViewContentModeScaleAspectFit;
    centerView.backgroundColor = [UIColor clearColor];
    [self addSubview:centerView];
    _centerView = centerView;
    
    //扫描线
    UIImageView *line = [[UIImageView alloc]init];
    line.tag = line_tag;
    line.image = [UIImage imageNamed:@"scanline"];
    line.contentMode = UIViewContentModeScaleAspectFill;
    line.backgroundColor = [UIColor clearColor];
    line.clipsToBounds = YES;
    [self addSubview:line];
    _line = line;
    
    [self layoutSubviews];
}


- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    if(self.scanW){
        
    }else{
        
        self.scanW = 250;
    }
    
    //扫描框的宽
    CGFloat scanViewW = self.scanW;
    
    //左侧的view 原来宽30
    _leftView.frame = CGRectMake(0, 0, (ScreenWidth - scanViewW) * 0.5, self.frame.size.height);
    //右侧的view
    _rightView.frame = CGRectMake(self.frame.size.width-((ScreenWidth - scanViewW) * 0.5), 0, (ScreenWidth - scanViewW) * 0.5, self.frame.size.height);
    //最上部view
    _upView.frame = CGRectMake((ScreenWidth - scanViewW) * 0.5, 0, scanViewW, 150);
    //底部view
    _downView.frame = CGRectMake((ScreenWidth - scanViewW) * 0.5, CGRectGetMaxY(_upView.frame) + scanViewW, scanViewW, ScreenHeight - (CGRectGetMaxY(_upView.frame) + scanViewW));
    //扫码框
    _centerView.frame = CGRectMake(CGRectGetMaxX(_leftView.frame), CGRectGetMaxY(_upView.frame), scanViewW, scanViewW);
    //扫描线
    _line.frame = CGRectMake((ScreenWidth - scanViewW) * 0.5, CGRectGetMaxY(_upView.frame), scanViewW, 2);

}


/**
 *  添加扫码动画
 */
- (void)addAnimation{
    
    UIView *line = [self viewWithTag:line_tag];
    line.hidden = NO;
    CABasicAnimation *animation = [XYMScanView moveYTime:2 fromY:[NSNumber numberWithFloat:4] toY:[NSNumber numberWithFloat:self.scanW -2] rep:OPEN_MAX];
    [line.layer addAnimation:animation forKey:@"LineAnimation"];
}

+ (CABasicAnimation *)moveYTime:(float)time fromY:(NSNumber *)fromY toY:(NSNumber *)toY rep:(int)rep{
    
    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [animationMove setFromValue:fromY];
    [animationMove setToValue:toY];
    animationMove.duration = time;
    animationMove.delegate = self;
    animationMove.repeatCount  = rep;
    animationMove.fillMode = kCAFillModeForwards;
    animationMove.removedOnCompletion = NO;
    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animationMove;
}


/**
 *  去除扫码动画
 */
- (void)removeAnimation{
    
    UIView *line = [self viewWithTag:line_tag];
    [line.layer removeAnimationForKey:@"LineAnimation"];
    line.hidden = YES;
}

/**
 *  开始扫码
 */
- (void)startRunning{

    [session startRunning];
}

/**
 *  结束扫码
 */
- (void)stopRunning{
    
    [session stopRunning];
}


/**
 *  移除监听
 */
- (void)dealloc{
    
    [session removeObserver:self forKeyPath:@"running"];
}


@end
