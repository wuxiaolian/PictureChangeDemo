//
//  ViewController.m
//  TestDemo
//
//  Created by Wuxiaolian on 2017/8/7.
//  Copyright © 2017年 Wu. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>
#import <Photos/PhotosDefines.h>

@interface ViewController (){
    CGRect originFrame;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageViewTag:)];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:singleTap];
}

- (void)imageViewTag:(UIGestureRecognizer *)gestureRecognizer{
    UIWindow  *window = [[UIApplication sharedApplication] keyWindow];
    UIView *bagView = [[UIView alloc] initWithFrame:self.view.frame];
    bagView.userInteractionEnabled = YES;
    originFrame = self.view.frame;

    bagView.backgroundColor = [UIColor blackColor];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.center = bagView.center;
    imageView.backgroundColor = [UIColor redColor];

    [bagView addSubview:imageView];
    [window addSubview:bagView];
    [bagView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clearSubView:)]];
    
    [UIView animateWithDuration:1 animations:^{
        [imageView setFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height-200-70)];
    } completion:nil];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clearSubView:(UIGestureRecognizer *)reg{
    NSLog(@"%@----",reg.view);
    UIView *backgroundView= reg.view;
    [UIView animateWithDuration:1 animations:^{
        [[backgroundView viewWithTag:1111] setFrame:originFrame];
        
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}
-(void)saveButtonOnclicked{
    NSLog(@"保存-----");
    __weak typeof(self) weakSelf = self;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:weakSelf.imageView.image];
        req = nil;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // tips message
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            UILabel *tipsLabel = [[UILabel alloc] init];
            tipsLabel.textColor = [UIColor whiteColor];
            tipsLabel.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
            tipsLabel.layer.cornerRadius = 5;
            tipsLabel.clipsToBounds = YES;
            tipsLabel.bounds = CGRectMake(0, 0, 200, 30);
            tipsLabel.center = window.center;
            tipsLabel.textAlignment = NSTextAlignmentCenter;
            tipsLabel.font = [UIFont boldSystemFontOfSize:17];
            [window addSubview:tipsLabel];
            [window bringSubviewToFront:tipsLabel];
            if (success) {
                tipsLabel.text = @"保存成功!";
            }else{
                if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
                    tipsLabel.text = @"保存成功!";
                }else{
                    // 处理第三种情况,监听用户第一次授权情况
                    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
                        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                            if (status == PHAuthorizationStatusAuthorized) {
                                // 递归处理一次 , 因为系统框只弹出这一次
                                [weakSelf saveButtonOnclicked];
                                return ;
                            }
                        }];
                    }else{
                        tipsLabel.text = @"暂无权限访问您的相册!";
                    }
                }
            }
            [tipsLabel performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
        });
    }];
}
- (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

@end
