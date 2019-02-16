//
//  ZHBrowseTool.m
//  PreviewDemo
//
//  Created by wangzhaohui-Mac on 2019/1/20.
//  Copyright © 2019 com.ZH. All rights reserved.
//

#import "ZHBrowseTool.h"

@implementation ZHBrowseTool
+ (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;//x偏移
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;//y偏移
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}
+ (CGSize)calculationImageSize:(UIImage *)image
{
    CGFloat width = 0;
    CGFloat height = 0;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    if (screenHeight >= 812)//适配iPhone X系列
    {
        screenHeight -= (44 + 34);
    }
    
    if (image.size.width && image.size.height) {
        
        CGFloat imageWidth = image.size.width;
        CGFloat imageHeight = image.size.height;
        
        CGFloat widthSpace = fabs(screenWidth - imageWidth);
        CGFloat heightSpace = fabs(screenHeight - imageHeight);
        
        if (widthSpace >= heightSpace) {
            if (screenWidth > imageWidth) {
                width = imageWidth * (screenHeight / imageHeight);
                height = imageHeight * (screenHeight / imageHeight);
            }else {
                width = imageWidth / (imageWidth / screenWidth);
                height = imageHeight / (imageWidth / screenWidth);
            }
        }else {
            if (screenHeight > imageHeight) {
                width = imageWidth * (screenWidth / imageWidth);
                height = imageHeight * (screenWidth / imageWidth);
            }else {
                width = imageWidth / (imageHeight / screenHeight);
                height = imageHeight / (imageHeight / screenHeight);
            }
        }
        return CGSizeMake(width, height);
    }else{
        return CGSizeMake(0, 0);
    }
}
@end
