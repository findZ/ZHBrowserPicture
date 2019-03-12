//
//  ZHBrowseFlowLayout.h
//  ZHBrowserPicture
//
//  Created by wzh on 2019/2/18.
//  Copyright © 2019 com.ZH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZHBrowseFlowLayout : UICollectionViewFlowLayout
- (instancetype)initWithSectionInset:(UIEdgeInsets)insets andMiniLineSapce:(CGFloat)miniLineSpace andMiniInterItemSpace:(CGFloat)miniInterItemSpace andItemSize:(CGSize)itemSize;
@property (nonatomic, assign) BOOL scrollAnimation;/**是否有分页动画*/
@end

