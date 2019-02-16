//
//  ZHBrowseTool.h
//  PreviewDemo
//
//  Created by wangzhaohui-Mac on 2019/1/20.
//  Copyright © 2019 com.ZH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHBrowseTool : NSObject
+ (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView;
+ (CGSize)calculationImageSize:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
