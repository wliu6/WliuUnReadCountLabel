//
//  WliuUnReadContactCountLabel.h
//  CA阻尼动画
//
//  Created by 6 on 16/4/12.
//  Copyright © 2016年 w66. All rights reserved.
//

#import <UIKit/UIKit.h>
/*!
 *  删除操作类型枚举
 */
typedef NS_ENUM(NSUInteger, WliuUnReadContactCountLabelRemoveType) {
    /*!
     *  只能拖动删除
     */
    WliuUnReadContactCountLabelOnlyPanRemove = 0,
    /*!
     *  拖动和点击均能删除
     */
    WliuUnReadContactCountLabelPanAndTapRemove
};
typedef void(^WliuUnReadContactCountLabelRemoveBlock)();
@interface WliuUnReadContactCountLabel : UILabel
/*!
 *  未阅读数（已做非负处理）
 */
@property (nonatomic, assign) NSUInteger unReadCount;
/*!
 *  删除操作类型
 */
@property (nonatomic, assign) WliuUnReadContactCountLabelRemoveType removeType;
/*!
 *  删除动画图片数组（已处理非UIImage和其自类的容错性）
 */
@property (nullable, nonatomic, strong) NSArray<__kindof UIImage *> *removeAnimationImagesArray;
/*!
 *  删除动画持续时间（一个周期，默认为0.2s -> 5fps）
 */
@property (nonatomic, assign) NSTimeInterval animationDuration;
/*!
 *  删除动画重复次数（默认为3）
 */
@property (nonatomic, assign) NSInteger animationRepeatCount;
/*!
 *  删除视图边长（默认为36.f),已做非负处理
 */
@property (nonatomic, assign) CGFloat removeImageViewLengthOfSide;
/*!
 *  捕获删除响应
 *
 *  @param handler 删除响应回调
 */
- (void)fetchRemoveCompletionWithHandler:(_Nonnull WliuUnReadContactCountLabelRemoveBlock)handler;
@end
