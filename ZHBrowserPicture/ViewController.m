//
//  ViewController.m
//  ZHBrowserPicture
//
//  Created by wangzhaohui-Mac on 2019/2/16.
//  Copyright © 2019 com.ZH. All rights reserved.
//

#import "ViewController.h"
#import "ZHBrowseView.h"

@interface ViewController ()
@property (nonatomic,strong) NSArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupSubView];
}
- (void)setupSubView
{
    NSArray *dataArray = @[@"image1", @"image2",@"image3", @"image4",@"image5",@"image6",@"image7",@"image8"];
    
    CGFloat leftRightMargin = 15.0;//左右间距
    CGFloat marginBetweenImage = 10.0;//图片间间距
    CGFloat imageWidth = ([UIScreen mainScreen].bounds.size.width - 2 * leftRightMargin - 2 * marginBetweenImage) / 3.0;//图片宽
    CGFloat imageHeight = imageWidth / 3.0 * 2.0;//图片高
    CGFloat imagesBeginY = 100;
    
    for (NSInteger i = 0; i < dataArray.count; i++) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = i;
        CGFloat row = i / 3;
        CGFloat col = i % 3;
        imageView.frame = CGRectMake(leftRightMargin + col * (imageWidth + marginBetweenImage), imagesBeginY + row * (imageHeight + marginBetweenImage), imageWidth, imageHeight);
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageNamed:dataArray[i]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        [imageView addGestureRecognizer:tap];
        [self.view addSubview:imageView];
    }
    self.dataArray = dataArray;
}

- (void)tapClick:(UITapGestureRecognizer *)tap
{
    //    NSLog(@"%@",tap.view);
    [ZHBrowseView showBrowseViewFrom:tap.view dataArray:self.dataArray currentIndex:tap.view.tag];
}
@end

