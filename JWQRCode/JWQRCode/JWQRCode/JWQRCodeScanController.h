//
//  JWQRCodeScanController.h
//  JWQRCode
//
//  Created by wangjun on 2018/8/2.
//  Copyright © 2018年 wangjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JWQRCodeScanController : UIViewController

@property (nonatomic, copy) void(^scan)(NSString *result);

@end
