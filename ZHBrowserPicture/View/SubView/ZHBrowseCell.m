//
//  ZHBrowseCell.m
//  PreviewDemo
//
//  Created by wangzhaohui-Mac on 2019/1/19.
//  Copyright © 2019 com.ZH. All rights reserved.
//

#import "ZHBrowseCell.h"
#import "ZHBrowseTool.h"

#define K_SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
#define K_SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width


@interface ZHBrowseCell ()<UIScrollViewDelegate>
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic,weak) UIImageView *moveImage;//拖拽时的展示image
@property (nonatomic,assign) BOOL doingPan;//正在拖拽
@property (nonatomic,assign) BOOL doingZoom;//正在缩放，此时不执行拖拽方法
///拖拽系数
@property (nonatomic,assign) CGFloat scale;

@end

@implementation ZHBrowseCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupSubView];
    }
    return self;
}
- (void)setupSubView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.bounds;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 3.0;
    scrollView.alwaysBounceVertical = YES;
    scrollView.alwaysBounceHorizontal = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
//    scrollView.directionalLockEnabled = YES;
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)){
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.scrollView addGestureRecognizer:singleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, K_SCREEN_WIDTH, self.bounds.size.height)];
    imageView.center = CGPointMake(K_SCREEN_WIDTH/2, self.bounds.size.height/2);
    imageView.backgroundColor = [UIColor clearColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:imageView];
    self.imageView = imageView;
    
    UIImageView *moveImage = [[UIImageView alloc] init];
    moveImage.hidden = YES;
    moveImage.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:moveImage];
    self.moveImage = moveImage;
    
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] init];
    loadingView.center = self.scrollView.center;
    loadingView.color = [UIColor redColor];
    [self addSubview:loadingView];
    self.loadingView = loadingView;
    
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
    [self.scrollView setZoomScale:1.0 animated:YES]; //还原
    CGSize size = [ZHBrowseTool calculationImageSize:image];
    self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
    self.imageView.center = self.scrollView.center;
    self.moveImage.image = self.image;
    self.moveImage.frame = self.imageView.frame;
}
//双击
- (void)doubleTap:(UITapGestureRecognizer *)tap
{
//    NSLog(@"doubleTap");

    CGPoint touchPoint = [tap locationInView:self];
    if (self.scrollView.zoomScale <= 1.0)
    {
        CGFloat scaleX = touchPoint.x + self.scrollView.contentOffset.x;//需要放大的图片的X点
        CGFloat sacleY = touchPoint.y + self.scrollView.contentOffset.y;//需要放大的图片的Y点
        [self.scrollView zoomToRect:CGRectMake(scaleX, sacleY, 10, 10) animated:YES];
    }
    else
    {
        [self.scrollView setZoomScale:1.0 animated:YES]; //还原
    }
}
//单击
- (void)singleTap:(UITapGestureRecognizer *)tap
{
//    NSLog(@"singleTap");
    if ([self.delegate respondsToSelector:@selector(didClickImage:)]) {
        [self.scrollView setZoomScale:1.0 animated:NO]; //还原
        [self.delegate didClickImage:self.imageView];
    }
}

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
//    NSLog(@"%f",self.scrollView.zoomScale);
    if (self.doingZoom == NO && self.scrollView.zoomScale == 1 )
    {
        [self doPan:self.scrollView.panGestureRecognizer];
    }
   
}
#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    self.imageView.center = [ZHBrowseTool centerOfScrollViewContent:scrollView];

    self.doingZoom = NO;

}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    self.doingZoom = YES;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.doingZoom == NO && self.scrollView.zoomScale == 1 ) {
        if ([self.delegate respondsToSelector:@selector(imageViewWillBeginDragging:)]) {
            [self.delegate imageViewWillBeginDragging:self.imageView];
        }
    }
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self endPan];
}

//拖拽中
- (void)doPan:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStatePossible)
    {
        self.doingPan = NO;
        return;
    }
    if (pan.numberOfTouches != 1 || self.doingZoom)//两个手指在拖，此时应该是在缩放，不执行继续执行
    {
        self.doingPan = NO;
        return;
    }
    
    self.doingPan = YES;
    self.imageView.hidden = YES;
    self.moveImage.hidden = NO;
    
    UIGestureRecognizerState state = pan.state;
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [pan translationInView:self.scrollView];
        CGPoint center = self.moveImage.center;
        CGFloat x = center.x + translation.x;
        CGFloat y = center.y + translation.y;
        [self.moveImage setCenter:CGPointMake(x, y)];
        [pan setTranslation:CGPointZero inView:self.scrollView];
        
        CGFloat scale = y/(K_SCREEN_HEIGHT/2);
        if (scale > 1.0) {
            scale = 1 - (scale - 1.0);
        }
        if (scale < 0.5) {
            scale = 0.5;
        }
//        NSLog(@"%f -- %f",scale,center.y);
        self.scale = scale;
        self.moveImage.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        if ([self.delegate respondsToSelector:@selector(imageViewDragging:imageView:)]) {
            [self.delegate imageViewDragging:self.scale imageView:self.moveImage];
        }
    }
    
}
//结束拖拽
- (void)endPan
{
    if (self.moveImage.hidden == NO) {
        self.scrollView.bounces = NO;//解决拖拽结束瞬间抖动
        [UIView animateWithDuration:0.25 animations:^{
            [self.moveImage setCenter:self.scrollView.center];
            self.moveImage.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.imageView.hidden = NO;
            self.moveImage.hidden = YES;//解决拖拽结束瞬间抖动
            self.scrollView.bounces = YES;
        }];
        if ([self.delegate respondsToSelector:@selector(imageViewEndDragging:imageview:)]) {
            [self.delegate imageViewEndDragging:self.scale imageview:self.moveImage];
        }
    }
}


@end
