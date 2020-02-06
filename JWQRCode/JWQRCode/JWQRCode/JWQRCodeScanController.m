//
//  JWQRCodeScanController.m
//  JWQRCode
//
//  Created by wangjun on 2018/8/2.
//  Copyright © 2018年 wangjun. All rights reserved.
//

#import "JWQRCodeScanController.h"

#import <AVFoundation/AVFoundation.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#define SCREEN_WIDTH     ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT    ([UIScreen mainScreen].bounds.size.height)
#define SCAN_WIDTH  260.0
#define SCAN_TOP    150.0

@interface JWQRCodeScanController ()<AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UITextField *jwQRCodeInputTextField;
@property (nonatomic, strong) UIImageView *jwQRCodePickImageView;
@property (nonatomic, strong) UIImageView *jwQRCodeLineImageView;
@property (nonatomic, strong) UILabel *jwQRCodeTitleLabel;
@property (nonatomic, strong) UIButton *jwQRCodeFlashlightButton;
@property (nonatomic, strong) AVCaptureSession *jwQRCodeScanSession;

@end

@implementation JWQRCodeScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"扫描";
    
    [self configJWQRCodeNavControl];
    
    [self configJWQRCodeUI];
    
    [self configJWQRCodeAnimation];
    
    [self configJWQRCodeScanSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configJWQRCodeNavControl
{
    UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [tempButton setImage:[self jwQRCodeImageWithName:@"jw_qrcode_nav_back"]
                forState:UIControlStateNormal];
    tempButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [tempButton addTarget:self action:@selector(jwQRCodeLeftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tempButton];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - Lazy loading

- (UITextField *)jwQRCodeInputTextField
{
    if (!_jwQRCodeInputTextField)
    {
        self.jwQRCodeInputTextField = [UITextField new];
        _jwQRCodeInputTextField.returnKeyType = UIReturnKeyGo;
        _jwQRCodeInputTextField.placeholder = @"扫描不出来，手动输入试试";
        _jwQRCodeInputTextField.textAlignment = NSTextAlignmentCenter;
        _jwQRCodeInputTextField.layer.cornerRadius = 15;
        _jwQRCodeInputTextField.layer.masksToBounds = YES;
        _jwQRCodeInputTextField.layer.borderWidth = (1.0 / [UIScreen mainScreen].scale);
        _jwQRCodeInputTextField.layer.borderColor = [UIColor whiteColor].CGColor;
        _jwQRCodeInputTextField.font = [UIFont fontWithName:@"Arial" size:15];
        _jwQRCodeInputTextField.textColor = [UIColor whiteColor];
        _jwQRCodeInputTextField.delegate = self;
        [_jwQRCodeInputTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        
        
        [self.view addSubview:_jwQRCodeInputTextField];
    }
    return _jwQRCodeInputTextField;
}

- (UIImageView *)jwQRCodePickImageView
{
    if (!_jwQRCodePickImageView)
    {
        self.jwQRCodePickImageView = [UIImageView new];
        _jwQRCodePickImageView.image = [self jwQRCodeImageWithName:@"jw_qrcode_scan_picker"];//[UIImage imageNamed:@"JWQRCode.bundle/qrcode_scan_picker"];
        [self.view addSubview:_jwQRCodePickImageView];
    }
    return _jwQRCodePickImageView;
}

- (UIImageView *)jwQRCodeLineImageView
{
    if (!_jwQRCodeLineImageView)
    {
        self.jwQRCodeLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - SCAN_WIDTH)/2,
                                                                           SCAN_TOP + 1,
                                                                           SCAN_WIDTH,
                                                                           2)];
        _jwQRCodeLineImageView.image = [self jwQRCodeImageWithName:@"jw_qrcode_scan_line"];//[UIImage imageNamed:@"JWQRCode.bundle/qrcode_scan_line"];
        [self.view addSubview:_jwQRCodeLineImageView];
    }
    return _jwQRCodeLineImageView;
}

- (UILabel *)jwQRCodeTitleLabel
{
    if (!_jwQRCodeTitleLabel)
    {
        self.jwQRCodeTitleLabel = [UILabel new];
        _jwQRCodeTitleLabel.textAlignment = NSTextAlignmentCenter;
        _jwQRCodeTitleLabel.textColor = [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1.0];
        _jwQRCodeTitleLabel.font = [UIFont fontWithName:@"Arial" size:15];
        _jwQRCodeTitleLabel.text = @"将二维码/条码放入框内，即可自动扫描";
        [self.view addSubview:_jwQRCodeTitleLabel];
    }
    return _jwQRCodeTitleLabel;
}

- (UIButton *)jwQRCodeFlashlightButton
{
    if (!_jwQRCodeFlashlightButton)
    {
        self.jwQRCodeFlashlightButton = [UIButton new];
        _jwQRCodeFlashlightButton.hidden = YES;
        [_jwQRCodeFlashlightButton setImage:[self jwQRCodeImageWithName:@"jw_qrcode_flashlight_close"]
                           forState:UIControlStateNormal];
        [_jwQRCodeFlashlightButton setImage:[self jwQRCodeImageWithName:@"jw_qrcode_flashlight_open"]
                           forState:UIControlStateSelected];
        [_jwQRCodeFlashlightButton setTitle:@"轻触照亮"
                           forState:UIControlStateNormal];
        [_jwQRCodeFlashlightButton setTitle:@"轻触关闭"
                           forState:UIControlStateSelected];
        [_jwQRCodeFlashlightButton setTitleColor:[UIColor whiteColor]
                                forState:UIControlStateNormal];
        [_jwQRCodeFlashlightButton addTarget:self
                              action:@selector(jwQRCodeRightButtonAction:)
                    forControlEvents:UIControlEventTouchDown];
        _jwQRCodeFlashlightButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:13];
        _jwQRCodeFlashlightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 25.5, 15, -25.5);
        _jwQRCodeFlashlightButton.titleEdgeInsets = UIEdgeInsetsMake(25, -10, 0, 10);
        [self.view addSubview:_jwQRCodeFlashlightButton];
        
    }
    return _jwQRCodeFlashlightButton;
}

- (AVCaptureSession *)jwQRCodeScanSession
{
    if (!_jwQRCodeScanSession)
    {
        self.jwQRCodeScanSession = [[AVCaptureSession alloc] init];
    }
    return _jwQRCodeScanSession;
}

#pragma mark - helper
- (void)configJWQRCodeUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    self.jwQRCodePickImageView.frame = CGRectMake((SCREEN_WIDTH - SCAN_WIDTH)/2.0,
                                          SCAN_TOP,
                                          SCAN_WIDTH,
                                          SCAN_WIDTH);
    
    [self configCoverViews];
    
    self.jwQRCodeInputTextField.frame = CGRectMake((SCREEN_WIDTH - SCAN_WIDTH)/2.0,
                                           SCAN_TOP-50,
                                           SCAN_WIDTH,
                                           30);
    self.jwQRCodeTitleLabel.frame = CGRectMake((SCREEN_WIDTH - SCAN_WIDTH)/2.0,
                                       CGRectGetMaxY(self.jwQRCodePickImageView.frame) + 20,
                                       SCAN_WIDTH,
                                       20);
    
    // 有闪光灯，才允许打开
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
    {
        self.jwQRCodeFlashlightButton.frame = CGRectMake((SCREEN_WIDTH - 80)/2.0,
                                                 CGRectGetMaxY(self.jwQRCodeTitleLabel.frame) + 20,
                                                 80,
                                                 60);
    }
}

- (void)configCoverViews
{
    UIView *tempTopView = [UIView new];
    tempTopView.frame = CGRectMake(0,
                                   0,
                                   SCREEN_WIDTH,
                                   CGRectGetMinY(self.jwQRCodePickImageView.frame));
    tempTopView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:tempTopView];
    
    UIView *tempLeftView = [UIView new];
    tempLeftView.frame = CGRectMake(0,
                                    CGRectGetMinY(self.jwQRCodePickImageView.frame),
                                    CGRectGetMinX(self.jwQRCodePickImageView.frame),
                                    CGRectGetHeight(self.jwQRCodePickImageView.frame));
    tempLeftView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:tempLeftView];
    
    UIView *tempRightView = [UIView new];
    tempRightView.frame = CGRectMake(CGRectGetMaxX(self.jwQRCodePickImageView.frame),
                                     CGRectGetMinY(self.jwQRCodePickImageView.frame),
                                     SCREEN_WIDTH - CGRectGetMaxX(self.jwQRCodePickImageView.frame),
                                     CGRectGetHeight(self.jwQRCodePickImageView.frame));
    tempRightView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:tempRightView];
    
    UIView *tempBottomView = [UIView new];
    tempBottomView.frame = CGRectMake(0,
                                      CGRectGetMaxY(self.jwQRCodePickImageView.frame),
                                      SCREEN_WIDTH,
                                      SCREEN_HEIGHT - CGRectGetMaxY(self.jwQRCodePickImageView.frame));
    tempBottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:tempBottomView];
}

- (void)configJWQRCodeScanSetting
{
    if ([self jwQRCodeCanUseCamera])
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            // 设备
            AVCaptureDevice *tempDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            
            // 输入流
            AVCaptureDeviceInput *tempInput = [AVCaptureDeviceInput deviceInputWithDevice:tempDevice error:nil];
            
            // 输出流
            AVCaptureMetadataOutput *tempOutput = [[AVCaptureMetadataOutput alloc] init];
            // 扫码代理
            [tempOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            // 扫码限制区域（二维码）ps: 原点在右上角，xy颠倒，wh颠倒
            [tempOutput setRectOfInterest:CGRectMake((SCAN_TOP + 64/2)/SCREEN_HEIGHT,
                                                     (SCREEN_WIDTH-SCAN_WIDTH)/2.0/SCREEN_WIDTH,
                                                     SCAN_WIDTH/SCREEN_HEIGHT,
                                                     SCAN_WIDTH/SCREEN_WIDTH)];
            
            // 检测环境光的output
            AVCaptureVideoDataOutput *tempLightOutput = [[AVCaptureVideoDataOutput alloc] init];
            // 代理
            [tempLightOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
            
            // 扫码Session 二维码读取区域设置
            if ([UIScreen mainScreen].bounds.size.height == 480)
            {
                [self.jwQRCodeScanSession setSessionPreset:AVCaptureSessionPreset640x480];
            }
            else
            {
                [self.jwQRCodeScanSession setSessionPreset:AVCaptureSessionPresetHigh];
            }
            
            // 添加输出流到session
            if ([self.jwQRCodeScanSession canAddOutput:tempOutput])
            {
                [self.jwQRCodeScanSession addOutput:tempOutput];
                [self.jwQRCodeScanSession addOutput:tempLightOutput];
            }
            // 添加输入流到session
            if ([self.jwQRCodeScanSession canAddInput:tempInput])
            {
                [self.jwQRCodeScanSession addInput:tempInput];
            }
            
            // 配置扫码类型(配置扫码类型，需要先将output添加到session，否则会crash)
            tempOutput.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
                                               AVMetadataObjectTypeEAN8Code,
                                               AVMetadataObjectTypeCode128Code,
                                               AVMetadataObjectTypeQRCode];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 摄像区域
                AVCaptureVideoPreviewLayer *tempPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.jwQRCodeScanSession];
                tempPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                tempPreviewLayer.frame = self.view.layer.bounds;
                [self.view.layer insertSublayer:tempPreviewLayer atIndex:0];
                
                // Start
                [self.jwQRCodeScanSession startRunning];
            });
        });
    }
    else
    {
        UIAlertController *tempAlert = [UIAlertController alertControllerWithTitle:@"提示" message:@"尚未开启相机使用权限，无法使用该功能。请前往手机的 设置->隐私->相机，开启使用权限" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *tempAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            if (@available(iOS 8.0, *))
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];
        [tempAlert addAction:tempAction];
        [self presentViewController:tempAlert animated:YES completion:nil];
    }
}

- (BOOL)jwQRCodeCanUseCamera
{
    // 先检测有没有相机
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        return NO;
    }
    
    AVAuthorizationStatus tempStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (tempStatus == AVAuthorizationStatusDenied ||
        tempStatus == AVAuthorizationStatusRestricted)
    {
        return NO;
    }
    /*
    // 再检测相关权限
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        ALAuthorizationStatus tempStatus = [ALAssetsLibrary authorizationStatus];
        if (tempStatus == ALAuthorizationStatusRestricted || tempStatus == ALAuthorizationStatusDenied)
        {
            return NO;
        }
    }
    else
    {
        AVAuthorizationStatus tempStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (tempStatus == AVAuthorizationStatusDenied ||
            tempStatus == AVAuthorizationStatusRestricted)
        {
            return NO;
        }
    }
     */
    return YES;
}

- (void)configJWQRCodeAnimation
{
    [self jwQRCodeAnimationDown];
}

- (void)jwQRCodeAnimationDown
{
    [UIView animateWithDuration:1.5 animations:^{
        
        [self.jwQRCodeLineImageView setFrame:CGRectMake((SCREEN_WIDTH - SCAN_WIDTH)/2,
                                                SCAN_TOP + SCAN_WIDTH - 3,
                                                SCAN_WIDTH,
                                                2)];
        
    } completion:^(BOOL finished) {
        
        if (finished)
        {
            [self jwQRCodeAnimationUp];
        }
    }];
}

- (void)jwQRCodeAnimationUp
{
    [UIView animateWithDuration:1.5 animations:^{
        
        [self.jwQRCodeLineImageView setFrame:CGRectMake((SCREEN_WIDTH - SCAN_WIDTH)/2,
                                                SCAN_TOP + 1,
                                                SCAN_WIDTH,
                                                2)];
        
    } completion:^(BOOL finished) {
        
        if (finished)
        {
            [self jwQRCodeAnimationDown];
        }
    }];
}

- (void)jwQRCodeLeftButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)jwQRCodeRightButtonAction:(id)sender
{
    self.jwQRCodeFlashlightButton.selected = !self.jwQRCodeFlashlightButton.selected;
    
    [self jwQRCodeFlashlightOn:self.jwQRCodeFlashlightButton.selected];
}

- (void)jwQRCodeFlashlightOn:(BOOL)on
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil)
    {
        AVCaptureDevice *tempDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([tempDevice hasTorch] && [tempDevice hasFlash])
        {
            [tempDevice lockForConfiguration:nil];
            if (on)
            {
                [tempDevice setTorchMode:AVCaptureTorchModeOn];
                [tempDevice setFlashMode:AVCaptureFlashModeOn];
            }
            else
            {
                [tempDevice setTorchMode:AVCaptureTorchModeOff];
                [tempDevice setFlashMode:AVCaptureFlashModeOff];
            }
        }
        else
        {
            
        }
    }
    else
    {
        UIAlertController *tempAlert = [UIAlertController alertControllerWithTitle:@"提示" message:@"没有闪光设备" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *tempAction = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleDestructive handler:nil];
        [tempAlert addAction:tempAction];
        [self presentViewController:tempAlert animated:YES completion:nil];
    }
}

- (void)jwQRCodeCallback:(NSString *)result
{
    [self.jwQRCodeScanSession stopRunning];
    
    __weak __typeof(self)this = self;
    [self dismissViewControllerAnimated:YES completion:^{
        !this.scan?:this.scan(result);
    }];
}

- (UIImage *)jwQRCodeImageWithName:(NSString *)imgName
{
    NSBundle *tempBundle = [self jwQRCodeGetResourceBundle];
    if (tempBundle)
    {
        return [UIImage imageNamed:imgName inBundle:tempBundle compatibleWithTraitCollection:nil];
    }
    else
    {
        NSString *tempFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"JWQRCode.bundle/%@",imgName] ofType:@"png"];
        return [UIImage imageWithContentsOfFile:tempFilePath];
    }
}

- (NSBundle *)jwQRCodeGetResourceBundle
{
    NSBundle *tempBundle = [NSBundle bundleForClass:[self class]];
    NSURL *tempBundleUrl = [tempBundle URLForResource:@"JWQRCode" withExtension:@"bundle"];
    NSBundle *tempResourceBundle = [NSBundle bundleWithURL:tempBundleUrl];
    if (!tempResourceBundle)
    {
        NSString *tempBundlePath = [tempBundle.resourcePath stringByAppendingPathComponent:@"JWQRCode.bundle"];
        tempResourceBundle = [NSBundle bundleWithPath:tempBundlePath];
    }
    return tempResourceBundle;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [self jwQRCodeCallback:stringValue];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (self.jwQRCodeFlashlightButton.selected) return;
    
    CFDictionaryRef tempRef = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *tempData = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary *)tempRef];
    CFRelease(tempRef);
    NSDictionary *tempMetaDic = [[tempData objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    CGFloat tempValue = [[tempMetaDic objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    self.jwQRCodeFlashlightButton.hidden = (tempValue > -1.5);
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *tempValue = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (tempValue.length > 0)
    {
        [textField resignFirstResponder];
        
        [self jwQRCodeCallback:tempValue];
    }
    else
    {
#ifdef DEBUG
        NSLog(@"请输入扫描内容");
#endif
    }
    
    return YES;
    
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
