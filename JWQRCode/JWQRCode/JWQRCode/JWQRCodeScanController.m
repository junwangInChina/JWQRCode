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

@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) UIImageView *pickImageView;
@property (nonatomic, strong) UIImageView *lineImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *flashlightButton;
@property (nonatomic, strong) AVCaptureSession *scanSession;

@end

@implementation JWQRCodeScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"扫描";
    
    [self addNavControl];
    
    [self configUI];
    
    [self configAnimation];
    
    [self configScanSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addNavControl
{
    UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [tempButton setImage:[UIImage imageNamed:@"JWQRCode.bundle/qrcode_nav_back"]
                forState:UIControlStateNormal];
    tempButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [tempButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tempButton];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - Lazy loading

- (UITextField *)inputTextField
{
    if (!_inputTextField)
    {
        self.inputTextField = [UITextField new];
        _inputTextField.returnKeyType = UIReturnKeyGo;
        _inputTextField.placeholder = @"扫描不出来，手动输入试试";
        _inputTextField.textAlignment = NSTextAlignmentCenter;
        _inputTextField.layer.cornerRadius = 15;
        _inputTextField.layer.masksToBounds = YES;
        _inputTextField.layer.borderWidth = (1.0 / [UIScreen mainScreen].scale);
        _inputTextField.layer.borderColor = [UIColor whiteColor].CGColor;
        _inputTextField.font = [UIFont fontWithName:@"Arial" size:15];
        _inputTextField.textColor = [UIColor whiteColor];
        _inputTextField.delegate = self;
        [_inputTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        
        
        [self.view addSubview:_inputTextField];
    }
    return _inputTextField;
}

- (UIImageView *)pickImageView
{
    if (!_pickImageView)
    {
        self.pickImageView = [UIImageView new];
        _pickImageView.image = [UIImage imageNamed:@"JWQRCode.bundle/qrcode_scan_picker"];
        [self.view addSubview:_pickImageView];
    }
    return _pickImageView;
}

- (UIImageView *)lineImageView
{
    if (!_lineImageView)
    {
        self.lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - SCAN_WIDTH)/2,
                                                                           SCAN_TOP + 1,
                                                                           SCAN_WIDTH,
                                                                           2)];
        _lineImageView.image = [UIImage imageNamed:@"JWQRCode.bundle/qrcode_scan_line"];
        [self.view addSubview:_lineImageView];
    }
    return _lineImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        self.titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1.0];
        _titleLabel.font = [UIFont fontWithName:@"Arial" size:15];
        _titleLabel.text = @"将二维码/条码放入框内，即可自动扫描";
        [self.view addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)flashlightButton
{
    if (!_flashlightButton)
    {
        self.flashlightButton = [UIButton new];
        _flashlightButton.hidden = YES;
        [_flashlightButton setImage:[UIImage imageNamed:@"JWQRCode.bundle/qrcode_flashlight_close"]
                           forState:UIControlStateNormal];
        [_flashlightButton setImage:[UIImage imageNamed:@"JWQRCode.bundle/qrcode_flashlight_open"]
                           forState:UIControlStateSelected];
        [_flashlightButton setTitle:@"轻触照亮"
                           forState:UIControlStateNormal];
        [_flashlightButton setTitle:@"轻触关闭"
                           forState:UIControlStateSelected];
        [_flashlightButton setTitleColor:[UIColor whiteColor]
                                forState:UIControlStateNormal];
        [_flashlightButton addTarget:self
                              action:@selector(flashlightAction:)
                    forControlEvents:UIControlEventTouchDown];
        _flashlightButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:13];
        _flashlightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 25.5, 15, -25.5);
        _flashlightButton.titleEdgeInsets = UIEdgeInsetsMake(25, -10, 0, 10);
        [self.view addSubview:_flashlightButton];
        
    }
    return _flashlightButton;
}

- (AVCaptureSession *)scanSession
{
    if (!_scanSession)
    {
        self.scanSession = [[AVCaptureSession alloc] init];
    }
    return _scanSession;
}

#pragma mark - helper
- (void)configUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    self.pickImageView.frame = CGRectMake((SCREEN_WIDTH - SCAN_WIDTH)/2.0,
                                          SCAN_TOP,
                                          SCAN_WIDTH,
                                          SCAN_WIDTH);
    
    [self configCoverViews];
    
    self.inputTextField.frame = CGRectMake((SCREEN_WIDTH - SCAN_WIDTH)/2.0,
                                           SCAN_TOP-50,
                                           SCAN_WIDTH,
                                           30);
    self.titleLabel.frame = CGRectMake((SCREEN_WIDTH - SCAN_WIDTH)/2.0,
                                       CGRectGetMaxY(self.pickImageView.frame) + 20,
                                       SCAN_WIDTH,
                                       20);
    
    // 有闪光灯，才允许打开
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
    {
        self.flashlightButton.frame = CGRectMake((SCREEN_WIDTH - 80)/2.0,
                                                 CGRectGetMaxY(self.titleLabel.frame) + 20,
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
                                   CGRectGetMinY(self.pickImageView.frame));
    tempTopView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:tempTopView];
    
    UIView *tempLeftView = [UIView new];
    tempLeftView.frame = CGRectMake(0,
                                    CGRectGetMinY(self.pickImageView.frame),
                                    CGRectGetMinX(self.pickImageView.frame),
                                    CGRectGetHeight(self.pickImageView.frame));
    tempLeftView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:tempLeftView];
    
    UIView *tempRightView = [UIView new];
    tempRightView.frame = CGRectMake(CGRectGetMaxX(self.pickImageView.frame),
                                     CGRectGetMinY(self.pickImageView.frame),
                                     SCREEN_WIDTH - CGRectGetMaxX(self.pickImageView.frame),
                                     CGRectGetHeight(self.pickImageView.frame));
    tempRightView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:tempRightView];
    
    UIView *tempBottomView = [UIView new];
    tempBottomView.frame = CGRectMake(0,
                                      CGRectGetMaxY(self.pickImageView.frame),
                                      SCREEN_WIDTH,
                                      SCREEN_HEIGHT - CGRectGetMaxY(self.pickImageView.frame));
    tempBottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:tempBottomView];
}

- (void)configScanSetting
{
    if ([self canUseCamera])
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
                [self.scanSession setSessionPreset:AVCaptureSessionPreset640x480];
            }
            else
            {
                [self.scanSession setSessionPreset:AVCaptureSessionPresetHigh];
            }
            
            // 添加输出流到session
            if ([self.scanSession canAddOutput:tempOutput])
            {
                [self.scanSession addOutput:tempOutput];
                [self.scanSession addOutput:tempLightOutput];
            }
            // 添加输入流到session
            if ([self.scanSession canAddInput:tempInput])
            {
                [self.scanSession addInput:tempInput];
            }
            
            // 配置扫码类型(配置扫码类型，需要先将output添加到session，否则会crash)
            tempOutput.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
                                               AVMetadataObjectTypeEAN8Code,
                                               AVMetadataObjectTypeCode128Code,
                                               AVMetadataObjectTypeQRCode];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 摄像区域
                AVCaptureVideoPreviewLayer *tempPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.scanSession];
                tempPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                tempPreviewLayer.frame = self.view.layer.bounds;
                [self.view.layer insertSublayer:tempPreviewLayer atIndex:0];
                
                // Start
                [self.scanSession startRunning];
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

- (BOOL)canUseCamera
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

- (void)configAnimation
{
    [self animationDown];
}

- (void)animationDown
{
    [UIView animateWithDuration:1.5 animations:^{
        
        [self.lineImageView setFrame:CGRectMake((SCREEN_WIDTH - SCAN_WIDTH)/2,
                                                SCAN_TOP + SCAN_WIDTH - 3,
                                                SCAN_WIDTH,
                                                2)];
        
    } completion:^(BOOL finished) {
        
        if (finished)
        {
            [self animationUp];
        }
    }];
}

- (void)animationUp
{
    [UIView animateWithDuration:1.5 animations:^{
        
        [self.lineImageView setFrame:CGRectMake((SCREEN_WIDTH - SCAN_WIDTH)/2,
                                                SCAN_TOP + 1,
                                                SCAN_WIDTH,
                                                2)];
        
    } completion:^(BOOL finished) {
        
        if (finished)
        {
            [self animationDown];
        }
    }];
}

- (void)leftButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)flashlightAction:(id)sender
{
    self.flashlightButton.selected = !self.flashlightButton.selected;
    
    [self flashlightOn:self.flashlightButton.selected];
}

- (void)flashlightOn:(BOOL)on
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

- (void)callbackResult:(NSString *)result
{
    [self.scanSession stopRunning];
    
    __weak __typeof(self)this = self;
    [self dismissViewControllerAnimated:YES completion:^{
        !this.scan?:this.scan(result);
    }];
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
    
    [self callbackResult:stringValue];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (self.flashlightButton.selected) return;
    
    CFDictionaryRef tempRef = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *tempData = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary *)tempRef];
    CFRelease(tempRef);
    NSDictionary *tempMetaDic = [[tempData objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    CGFloat tempValue = [[tempMetaDic objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    self.flashlightButton.hidden = (tempValue > -1.5);
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *tempValue = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (tempValue.length > 0)
    {
        [textField resignFirstResponder];
        
        [self callbackResult:tempValue];
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
