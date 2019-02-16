//
//  ZHBrowseView.m
//  PreviewDemo
//
//  Created by wangzhaohui-Mac on 2019/1/19.
//  Copyright © 2019 com.ZH. All rights reserved.
//

#import "ZHBrowseView.h"
#import "ZHBrowseCell.h"
#import "ZHBrowseTool.h"

static NSString *_identifier = @"ZHBrowseCell";

#define K_KEY_WINDOW            [UIApplication sharedApplication].keyWindow
#define K_SCREEN_BOUNDE     [UIScreen mainScreen].bounds
#define K_SCREEN_WIDTH      [UIScreen mainScreen].bounds.size.width
#define K_SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

#define K_BROWSE_TAG 99999
#define K_AnimateDuration 0.25
#define K_DisappearScale 0.7


@interface ZHBrowseView ()<UICollectionViewDataSource,UICollectionViewDelegate,ZHBrowseCellDelegate >
@property (nonatomic, weak) UICollectionView *mainView;
@property (nonatomic, weak) UIView *fromView;
@property (nonatomic, weak) UIImageView *currentView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIButton *saveButton;
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic, assign) CGRect originalFrame;

@end

@implementation ZHBrowseView
+ (void)showBrowseViewFrom:(UIImageView *)imageView dataArray:(NSArray *)dataArray currentIndex:(NSUInteger)index
{
    ZHBrowseView *browseView = [[ZHBrowseView alloc] initWithFrame:K_SCREEN_BOUNDE];
    [K_KEY_WINDOW addSubview:browseView];
    browseView.tag = K_BROWSE_TAG;
    browseView.dataArray = dataArray;
    browseView.fromView = imageView;
    browseView.fromView.hidden = YES;
    CGRect frame = [browseView convertRect:imageView.frame fromView:imageView.superview];
    browseView.originalFrame = frame;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [browseView.mainView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    browseView.titleLabel.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)index+1,(unsigned long)dataArray.count];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.contentMode = UIViewContentModeScaleAspectFit;
    tempView.frame = [imageView.superview convertRect:imageView.frame toView:browseView];
    tempView.image = imageView.image;
    [browseView addSubview:tempView];
    
    CGSize size = [ZHBrowseTool calculationImageSize:imageView.image];
    CGRect targetRect = CGRectMake(0, 0, size.width, size.height);
    
    [UIView animateWithDuration:K_AnimateDuration animations:^{
        tempView.frame = targetRect;
        tempView.center = browseView.center;
    } completion:^(BOOL finished) {
        [tempView removeFromSuperview];
        browseView.mainView.hidden = NO;
    }];
    
    UIView *statusBar = [[UIApplication sharedApplication] valueForKey:@"_statusBar"];
    if (statusBar) {
        statusBar.alpha = 0.0;
    }

}
+ (void)disappearZHBrowseView
{
    ZHBrowseView *browseView = [K_KEY_WINDOW viewWithTag:K_BROWSE_TAG];
    [UIView animateWithDuration:0.25 animations:^{
        browseView.currentView.frame = browseView.originalFrame;
        browseView.backgroundColor = [UIColor colorWithRed:0/255 green:0/255  blue:0/255  alpha:0];

    } completion:^(BOOL finished) {
        browseView.fromView.hidden = NO;
        if (browseView) {
            [browseView removeFromSuperview];
        }
    }];
    UIView *statusBar = [[UIApplication sharedApplication] valueForKey:@"_statusBar"];
    if (statusBar) {
        statusBar.alpha = 1.0;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self setupSubView];
    }
    return self;
}
- (void)setupSubView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(K_SCREEN_WIDTH, K_SCREEN_HEIGHT);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;

    UICollectionView *mainView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, K_SCREEN_WIDTH, K_SCREEN_HEIGHT) collectionViewLayout:layout];
    [mainView registerClass:[ZHBrowseCell class] forCellWithReuseIdentifier:_identifier];
    mainView.dataSource = self;
    mainView.delegate = self;
    mainView.pagingEnabled = YES;
    mainView.hidden = YES;
    mainView.backgroundColor = [UIColor clearColor];
    [self addSubview:mainView];
    self.mainView = mainView;
    
    CGFloat titleY = [UIApplication sharedApplication].statusBarFrame.size.height;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleY, K_SCREEN_WIDTH, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(K_SCREEN_WIDTH - 60, K_SCREEN_HEIGHT - 80, 50, 30)];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(loadImageFinished:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:saveButton];
    self.saveButton = saveButton;
}
#pragma mark - saveImage
- (void)loadImageFinished:(UIButton *)btn
{
    if (self.currentView.image) {
        UIImageWriteToSavedPhotosAlbum(self.currentView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"保存成功" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alertView show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    });
    if (error) {
        NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    }
}

#pragma mark - UICollectionViewDataSouer
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (ZHBrowseCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZHBrowseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
    cell.delegate = self;
    UIImage *image = [UIImage imageNamed:self.dataArray[indexPath.item]];
//    [cell.loadingView startAnimating];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [cell.loadingView stopAnimating];
//
//    });
    cell.image = image;
    self.currentView = cell.imageView;
    return cell;
}
#pragma mark - UICollectionViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 得到每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    // 根据当前的x坐标和页宽度计算出当前页数
    int index = fabs(scrollView.contentOffset.x)/pageWidth;
    self.titleLabel.text = [NSString stringWithFormat:@"%d/%lu",index+1,(unsigned long)self.dataArray.count];
}

#pragma mark - BrowseCellDelegate
- (void)didClickImage:(UIImageView *)imageView
{
    self.currentView = imageView;
    [self.class disappearZHBrowseView];
}
- (void)imageViewWillBeginDragging:(UIImageView *)imageView
{
    self.mainView.scrollEnabled = NO;
}
- (void)imageViewDragging:(CGFloat)scale imageView:(nonnull UIImageView *)imageView
{
    self.currentView = imageView;
    self.backgroundColor = [UIColor colorWithRed:0/255 green:0/255  blue:0/255  alpha:scale];
    UIView *statusBar = [[UIApplication sharedApplication] valueForKey:@"_statusBar"];
    if (statusBar) {
        statusBar.alpha = scale;
    }
}
- (void)imageViewEndDragging:(CGFloat)scale imageview:(nonnull UIImageView *)imageView
{
    self.currentView = imageView;
    if (scale < K_DisappearScale) {
        [self.class disappearZHBrowseView];
    }else{
        self.backgroundColor = [UIColor blackColor];
        self.mainView.scrollEnabled = YES;
    }
}
@end
