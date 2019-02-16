//
//  ZHBrowseCell.h
//  PreviewDemo
//
//  Created by wangzhaohui-Mac on 2019/1/19.
//  Copyright © 2019 com.ZH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZHBrowseCellDelegate <NSObject>
- (void)didClickImage:(UIImageView *)imageView;
- (void)imageViewWillBeginDragging:(UIImageView *)imageView;
- (void)imageViewDragging:(CGFloat)scale imageView:(UIImageView *)imageView;
- (void)imageViewEndDragging:(CGFloat)scale imageview:(UIImageView *)imageView;
@end

@interface ZHBrowseCell : UICollectionViewCell
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIActivityIndicatorView *loadingView;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,assign) id<ZHBrowseCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
