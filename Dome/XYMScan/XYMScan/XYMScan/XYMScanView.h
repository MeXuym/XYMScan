//
//  XYMScanView.h
//  healthcoming
//
//  Created by jack xu on 16/11/16.
//  Copyright © 2016年 Franky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XYMScanViewDelegate <NSObject>

-(void)getScanDataString:(NSString*)scanDataString;

@end


@interface XYMScanView : UIView

@property (nonatomic,assign) id<XYMScanViewDelegate> delegate;
@property (nonatomic,assign) int scanW; //扫描框的宽

- (void)startRunning; //开始扫描
- (void)stopRunning; //停止扫描

@end
