//
//  ViewController.m
//  JWQRCode
//
//  Created by wangjun on 2018/8/2.
//  Copyright © 2018年 wangjun. All rights reserved.
//

#import "ViewController.h"

#import "JWQRCodeScanController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)scan:(id)sender {
    
    JWQRCodeScanController *scanController = [[JWQRCodeScanController alloc] init];
    UINavigationController *scanNav = [[UINavigationController alloc] initWithRootViewController:scanController];
    [self presentViewController:scanNav animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
