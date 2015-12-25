//
//  ImageMaker.m
//  MBM
//
//  Created by Guan on 15/11/27.
//  Copyright © 2015年 meibumei. All rights reserved.
//

#import "ImageMaker.h"

@interface ImageMaker ()<UIScrollViewDelegate>

@property (strong ,nonatomic)UIImage *image;

@property (strong ,nonatomic)UIImageView *imageView;

@property (strong ,nonatomic)UIView *targetView;

@property (weak, nonatomic)UIScrollView *container;

@property (strong ,nonatomic)UIView *toolView ;

@end

@implementation ImageMaker


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    
    [_toolView removeFromSuperview];
}


+ (instancetype)ImageMakerWithImage:(UIImage *)image delegate:(id<ImageMakerDelegate>)delegate{
    
    ImageMaker *maker = [[ImageMaker alloc]init];
    
    maker.image = image;
    maker.delegate = delegate;
    
    return maker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareViews];
}

- (void)cancle{
    
    if ([self.delegate respondsToSelector:@selector(ImageMakerDidCancleImageMake:)]) {
        
        [self.delegate ImageMakerDidCancleImageMake:self];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareViews{
    
    self.navigationController.view.backgroundColor = [UIColor blackColor];
    
    CGFloat screenWidth = self.view.frame.size.width ;
    CGFloat screenHeight = self.view.frame.size.height ;
    
    CGFloat btnH = 50 ;
    CGFloat btnW = 60 ;
    CGFloat btnX = 20 ;
    CGFloat btnY = 0 ;
    CGFloat toolY = screenHeight - btnH ;
    
    UIView *toolView = [[UIView alloc]init];
    
    _toolView = toolView;
    
    toolView.frame = CGRectMake(0, toolY, screenWidth, btnH);
    
    
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    
    cancel.frame = CGRectMake(btnX , btnY, btnW, btnH);
    [cancel addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    
    
    
    UIButton *save = [UIButton buttonWithType:UIButtonTypeCustom];
    
    save.frame = CGRectMake(screenWidth - btnW - btnX, btnY, btnW, btnH);
    
    [save addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    
    [save setTitle:@"保存" forState:UIControlStateNormal];

    [_toolView addSubview:cancel];
    [_toolView addSubview:save];
    
    
    [[UIApplication sharedApplication].keyWindow  addSubview:_toolView];
    
    

    CGFloat targetViewW = screenWidth - 20;
    CGFloat targetViewH = targetViewW ;
    CGFloat targetViewX = (screenWidth - targetViewW )* 0.5 ;
    CGFloat targetViewY = (screenHeight - targetViewH )* 0.5 - 64;
    
    _targetView = [[UIView alloc]initWithFrame:CGRectMake(targetViewX, targetViewY, targetViewW, targetViewH)];
    
    _targetView.userInteractionEnabled = NO;
    _targetView.layer.borderColor = [UIColor whiteColor].CGColor;
    _targetView.layer.borderWidth = 0.3 ;
    
    [self.view addSubview:_targetView ];
    
    
    
    UIScrollView *sv = [[UIScrollView alloc]init];
    
    sv.delegate = self;
    sv.frame = self.view.bounds;
    sv.maximumZoomScale = 5.0;
    //设置最小伸缩比例
    sv.minimumZoomScale = 1.0;
    sv.bounces = NO;//关闭回弹
    sv.showsHorizontalScrollIndicator = NO;//关闭提示条
    sv.showsVerticalScrollIndicator = NO;
    _container = sv ;
    
    sv.contentSize = CGSizeMake(sv.frame.size.width, sv.frame.size.height);
    
    sv.backgroundColor = [UIColor blackColor];
    
    
    
    UIView *view = [[UIView alloc]init];
    
    view.frame = sv.bounds;
    view.tag = 1000 ;
    view.userInteractionEnabled = YES;
    
    view.backgroundColor = [UIColor blackColor];
    
    [sv addSubview:view];
    
    
    CGSize imageSize = _image.size ;
    
    UIView * conV = [[UIView alloc]init];
    
    conV.frame = _targetView.frame ;
    
    [view addSubview:conV];
    
    conV.backgroundColor = [UIColor blackColor];
    
    CGFloat imgW = imageSize.width ;
    CGFloat imgH = imageSize.height ;
    CGFloat imgX = 0 ;
    CGFloat imgY = 0 ;
    
    if (imgW > imgH) {
        
        CGFloat factor = targetViewW / imgW ;
        imgW = targetViewW ;
        imgH = factor * imgH ;
        imgY = (conV.frame.size.height - imgH )* 0.5 ;
        
    }else {
        
        CGFloat factor = targetViewH / imgH ;
        imgW = imgW * factor;
        imgH = targetViewH ;
        imgX = (conV.frame.size.width - imgW )* 0.5 ;
    }
    _imageView = [[UIImageView alloc] init];
    _imageView.userInteractionEnabled = YES;
    _imageView.multipleTouchEnabled = YES;
    
    _imageView.frame = CGRectMake(imgX, imgY, imgW, imgH) ;
    _imageView.image = _image ;
    [conV addSubview:_imageView];
    
    
    [self.view addSubview:sv];
    
    [self.view bringSubviewToFront:_targetView];
    
    
}


- (void)save{
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 1);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImage *resultImg = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(img.CGImage, _targetView.frame)];
    
    //    这个可以将剪裁的保存到相册
    //    UIImageWriteToSavedPhotosAlbum(resultImg, self, nil, nil);
    
    if ([self.delegate respondsToSelector:@selector(ImageMakerDidFinishImageMake:editedImage:)]) {
        
        [self.delegate ImageMakerDidFinishImageMake:self editedImage:resultImg];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 滚动视图的协议方法
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    
    return [scrollView viewWithTag:1000];
}

@end
