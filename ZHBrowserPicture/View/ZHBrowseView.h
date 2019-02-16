//
//  ZHBrowseView.h
//  PreviewDemo
//
//  Created by wangzhaohui-Mac on 2019/1/19.
//  Copyright © 2019 com.ZH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHBrowseView : UIView

/**
 展示图片浏览器

 @param imageView 从哪个控件上触发
 @param dataArray （多图展示）数据源
 @param index 默认展示哪一张
 */
+ (void)showBrowseViewFrom:(UIImageView *)imageView dataArray:(NSArray *)dataArray currentIndex:(NSUInteger)index;

/**
 移除浏览器
 */
+ (void)disappearZHBrowseView;
@end

NS_ASSUME_NONNULL_END
