//
//  ZHBrowseFlowLayout.m
//  ZHBrowserPicture
//
//  Created by wzh on 2019/2/18.
//  Copyright © 2019 com.ZH. All rights reserved.
//

#import "ZHBrowseFlowLayout.h"

@interface ZHBrowseFlowLayout ()
@property (nonatomic, assign) UIEdgeInsets sectionInsets;
@property (nonatomic, assign) CGFloat miniLineSpace;
@property (nonatomic, assign) CGFloat miniInterItemSpace;
@property (nonatomic, assign) CGSize eachItemSize;
@end

@implementation ZHBrowseFlowLayout
/*初始化部分*/
- (instancetype)initWithSectionInset:(UIEdgeInsets)insets andMiniLineSapce:(CGFloat)miniLineSpace andMiniInterItemSpace:(CGFloat)miniInterItemSpace andItemSize:(CGSize)itemSize
{
    self = [self init];
    if (self) {
        //基本尺寸/边距设置
        self.sectionInsets = insets;
        self.miniLineSpace = miniLineSpace;
        self.miniInterItemSpace = miniInterItemSpace;
        self.eachItemSize = itemSize;
    }
    return self;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _lastOffset = CGPointZero;
    }
    return self;
}
- (void)prepareLayout
{
    [super prepareLayout];
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;// 水平滚动
    /*设置内边距*/
    self.sectionInset = _sectionInsets;
    self.minimumLineSpacing = _miniLineSpace;
    self.minimumInteritemSpacing = _miniInterItemSpace;
    self.itemSize = _eachItemSize;
    /**
     * decelerationRate系统给出了2个值：
     * 1. UIScrollViewDecelerationRateFast（速率快）
     * 2. UIScrollViewDecelerationRateNormal（速率慢）
     * 此处设置滚动加速度率为fast，这样在移动cell后就会出现明显的吸附效果
     */
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
}
/**
 * 这个方法的返回值，就决定了collectionView停止滚动时的偏移量
 */
-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat pageSpace = [self stepSpace];//计算分页步距
    CGFloat offsetMax = self.collectionView.contentSize.width - self.collectionView.bounds.size.width;
    CGFloat offsetMin = 0;
    /*修改之前记录的位置，如果小于最小contentsize或者大于最大contentsize则重置值*/
    if (_lastOffset.x < offsetMin)
    {
        _lastOffset.x = offsetMin;
    }else if (_lastOffset.x >offsetMax)
    {
        _lastOffset.x = offsetMax;
    }
    
    CGFloat offsetForCurrentPointX = ABS(proposedContentOffset.x - _lastOffset.x);//目标位移点距离当前点的距离绝对值
    BOOL direction = (proposedContentOffset.x - _lastOffset.x) > 0;//判断当前滑动方向,手指向左滑动：YES；手指向右滑动：NO
    CGFloat ratio = 8.0;//滑动部分占整个cell宽度的比例
    if (offsetForCurrentPointX > pageSpace/ratio
        && _lastOffset.x >= offsetMin
        && _lastOffset.x <= offsetMax)
    {
        NSInteger pageFactor = 1;//分页因子，用于计算滑过的cell个数, 默认为：1
        
        /*//这里是单个分页不需要一次滑动多个cell
         CGFloat velocityX = velocity.x;
         if (velocityX != 0)
         {
         //滑动
         pageFactor = ABS(velocityX);//速率越快，cell滑过数量越多
         }else
         {
         //拖动 没有速率，则计算：位移差/默认步距=分页因子
         
         pageFactor = ABS(offsetForCurrentPointX/pageSpace);
         }
         
         //设置pageFactor上限为1, 防止滑动速率过大，导致翻页过多
         pageFactor = 1;
         */
        
        CGFloat pageOffsetX = pageSpace*pageFactor;
        proposedContentOffset = CGPointMake(_lastOffset.x + (direction?pageOffsetX:-pageOffsetX), proposedContentOffset.y);
    }else
    {
        /*滚动距离，小于翻页步距一半，则不进行翻页操作*/
        proposedContentOffset = CGPointMake(_lastOffset.x, _lastOffset.y);
    }
    
    //记录当前最新位置
    _lastOffset.x = proposedContentOffset.x;
    return proposedContentOffset;
    
}

/**
 *计算每滑动一页的距离：步距
 */
-(CGFloat)stepSpace
{
    return self.eachItemSize.width + self.miniLineSpace;
}
#pragma mark - 动画效果
/**
 * 当collectionView的显示范围发生改变的时候，是否需要重新刷新布局
 * 一旦重新刷新布局，就会重新调用 layoutAttributesForElementsInRect:方法
 */
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

/**
 *防止报错先复制attributes
 */
- (NSArray *)getCopyOfAttributes:(NSArray *)attributes
{
    NSMutableArray *copyArr = [NSMutableArray new];
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        [copyArr addObject:[attribute copy]];
    }
    return copyArr;
}

/**
 *设置放大动画
 */
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    /*获取rect范围内的所有subview的UICollectionViewLayoutAttributes*/
    NSArray *arr = [self getCopyOfAttributes:[super layoutAttributesForElementsInRect:rect]];
    
    /*动画计算*/
    if (self.scrollAnimation)
    {
        /*计算屏幕中线*/
        CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width/2.0f;
        /*刷新cell缩放*/
        for (UICollectionViewLayoutAttributes *attributes in arr) {
            CGFloat distance = fabs(attributes.center.x - centerX);
            /*移动的距离和屏幕宽度的的比例*/
            CGFloat apartScale = distance/self.collectionView.bounds.size.width;
            /*把卡片移动范围固定到 -π/4到 +π/4这一个范围内*/
            CGFloat scale = fabs(cos(apartScale * M_PI/4));
            /*设置cell的缩放按照余弦函数曲线越居中越趋近于1*/
            CATransform3D plane_3D = CATransform3DIdentity;
            plane_3D = CATransform3DScale(plane_3D, 1, scale, 1);
            attributes.transform3D = plane_3D;
        }
    }
    return arr;
}
@end
