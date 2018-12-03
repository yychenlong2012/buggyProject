//
//  lineLayoutOne.m
//  自定义布局
//
//  Created by 陈龙 on 16/8/2.
//  Copyright © 2016年 chenlong. All rights reserved.
//

#import "lineLayoutOne.h"

@implementation lineLayoutOne

-(instancetype)init{
    if (self = [super init]) {
        /*UICollectionViewLayoutAttributes *attri ;
         1.一个cell对应一个UICollectionViewLayoutAttributes对象
         2.UICollectionViewLayoutAttributes对象决定了cell的frame等显示样式
         */
    }
    return self;
}
/*
 当collectionView的显示范围发生改变时是否需要重新布局
 一旦重新布局就会调用以下方法
 prepareLayout
 layoutAttributesForElementsInRect
 */
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

/*
 用来做布局的初始化操作（不建议在init方法中做布局的初始化操作）
 */
-(void)prepareLayout{
    [super prepareLayout];
    
    //设置cell的尺寸
//    self.itemSize = CGSizeMake(40, ScreenHeight-(statusBarH==20?0:statusBarH)-bottomSafeH-50-200);
    //设置水平滚动
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    //设置两边空白区域
    CGFloat inset = (self.collectionView.frame.size.width - self.itemSize.width) * 0.5;
    self.sectionInset = UIEdgeInsetsMake(0, inset, 0, inset);
}

//打开这个方法 实现了缩放效果
/*
 这个方法的返回值是一个UICollectionViewLayoutAttributes数组，数组里存放着rect范围内所有元素的布局属性
 这个数组决定了rect范围内所有元素的排布
 */
//-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
//{
//    //获得super已经计算好的布局属性
////    NSArray *array = [super layoutAttributesForElementsInRect:rect];
//     NSArray *array = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
//    /*
//     collectionView里面还有一个contentView，collectionView里面所有cell的位置都是根据contentView的计算的，坐标系是他
//
//     通过比较cell到原点的x值和collectionView到原点的x值，来确定cell的大小比例，两者都运用同一个坐标系contentView
//
//     collectionView的中心点x值 = contentView的偏移量 + collectionView宽度的一半
//     */
//
//    //collectionView中心点的x值   contentOffset内容偏移量
//    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.frame.size.width * 0.5;
//
//    //遍历数组中的元素，修改元素，在原有基础上进行调整
//    for (UICollectionViewLayoutAttributes *attrs in array) {
//
//        //两中心点的差值绝对值
//        CGFloat detal = ABS(attrs.center.x - centerX);
//
//        //根据间距值计算cell的缩放比例
//        CGFloat scale = 1 - detal / (self.collectionView.frame.size.width * 0.5);
//
//        //设置缩放
////        attrs.transform = CGAffineTransformMakeScale(scale, scale);
//
//        attrs.alpha = scale+0.2;
//    }
//    return array;
//}


#pragma mark - 这个方法里要实现的功能相当于scrollView的分页功能，这里是在停止滚动时cell总是在中心位置
/*
 这个方法的返回值决定了collectionView停止滚动时的偏移量，也就是说停止滚动了就会回到返回值所表示的偏移量处
 手一松开就会调用
 targetContentOffsetForProposedContentOffset 我们想要停留的位置
 proposedContentOffset 经过减速后本应该停留的位置（估算值）
 */
//-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
//    //计算最终停止时显示的矩形框
//    CGRect rect;
//    rect.origin.y = 0;
//    rect.origin.x = proposedContentOffset.x;
//    rect.size = self.collectionView.frame.size;
//    
//    //获得super已经计算好的布局属性
//    NSArray *array = [super layoutAttributesForElementsInRect:rect];
//    
//    //经过减速后本应该停留的位置的偏移量
//    CGFloat centerX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;
//    
//    //判断哪个cell离collectionView中心最近
//    CGFloat min = MAXFLOAT;
//    for (UICollectionViewLayoutAttributes *attrs in array) {
//        if (ABS(min) > ABS(centerX - attrs.center.x)) {  //比较时用绝对值
//            min = attrs.center.x - centerX;    //保存时有正有负
//        }
//    }
//    //修改原有偏移量
//    proposedContentOffset.x += min;
//    return proposedContentOffset;
//}


@end
