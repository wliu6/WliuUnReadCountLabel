//
//  WliuUnReadContactCountLabel.m
//  CA阻尼动画
//
//  Created by 6 on 16/4/12.
//  Copyright © 2016年 w66. All rights reserved.
//

#define WliuBanAssert(desc) NSAssert(NO, desc)

#import "WliuUnReadContactCountLabel.h"

/*!
 *  偏移最大间距
 */
CGFloat const WliuUnReadContactCountLabelMaxDistance = 90.0f;
/*!
 *  最大未读数，更多的话显示99+
 */
NSUInteger const WliuMaxUnReadCount = 99;
/*!
 *  关联视图最小边长（直径）
 */
CGFloat const WliuUnReadContactCountLabelRelatedViewMinLengthOfSide = 4.f;
/*!
 *  remove image view 默认边长
 */
CGFloat const WliuUnReadContactCountLabelRemoveImageViewDefaultLengthOfSide = 36.f;
/*!
 *  删除动画默认持续时间
 */
CGFloat const WliuUnReadContactCountLabelRemoveImageViewDefaultAnimationDuration = 0.2f;
/*!
 *  删除动画默认重复次数
 */
NSInteger const WliuUnReadContactCountLabelRemoveImageViewDefaultAnimationRepeatCount = 3;

@interface WliuUnReadContactCountLabel ()
{
    NSArray<__kindof UIImage *> *_removeAnimationImagesArray;
    CGFloat _removeImageViewLengthOfSide;
    CGFloat _widthIncrement;
}
@property (nonatomic, strong) UIView *relatedView;
@property (nonatomic, strong) UIView *relatedViewSuperView;

@property (nonatomic, strong) UIImageView *removeImageView;
@property (nonatomic, strong) UIView *removeImageViewSuperView;

@property (nonatomic, assign) NSInteger originRadius;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, copy) WliuUnReadContactCountLabelRemoveBlock removeBlock;
@end

@implementation WliuUnReadContactCountLabel
#pragma mark - Reset Properties
- (UIView *)relatedView{
    if (!_relatedView) {
        _relatedView = [[UIView alloc] init];
    }
    if (![self superViewAllowAddSomeRelatedSubview]) return _relatedView;
    if (![self.superview.subviews containsObject:_relatedView]) {
        [self.superview insertSubview:_relatedView belowSubview:self];
        self.relatedViewSuperView = _relatedView.superview;
    }
    return _relatedView;
}

- (UIImageView *)removeImageView
{
    if (!_removeImageView) {
        _removeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.removeImageViewLengthOfSide, self.removeImageViewLengthOfSide)];
        _removeImageView.hidden = YES;
    }
    if (![self superViewAllowAddSomeRelatedSubview]) return _removeImageView;
    if (![self.superview.subviews containsObject:_removeImageView]) {
        [self.superview addSubview:_removeImageView];
        self.removeImageViewSuperView = _removeImageView.superview;
    }
    return _removeImageView;
}

- (CAShapeLayer *)shapeLayer{
    if (!_shapeLayer) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.fillColor = self.backgroundColor.CGColor;
        [self.superview.layer insertSublayer:shapeLayer below:self.layer];
        _shapeLayer = shapeLayer;
    }
    return _shapeLayer;
}

- (void)setUnReadCount:(NSUInteger)unReadCount
{
    if (unReadCount <= 0) return;
    _unReadCount = unReadCount;
    NSString *showText = unReadCount > WliuMaxUnReadCount ? @"99+" : [NSString stringWithFormat:@"%lu", unReadCount];
    [super setText:showText];
    if (!(unReadCount / 10)) return;
    CGPoint originCenter = self.center;
    _widthIncrement = [self getCornerRadiusWithBounds:self.bounds] / ((unReadCount / WliuMaxUnReadCount) ? 1 : 2);
    self.bounds = CGRectMake(0.f, 0.f, self.bounds.size.width + _widthIncrement, self.bounds.size.height);
    self.center = originCenter;
}

- (void)setRemoveAnimationImagesArray:(NSArray<__kindof UIImage *> *)removeAnimationImagesArray
{
    NSMutableArray *resultArr = [@[] mutableCopy];
    for (id obj in removeAnimationImagesArray) {
        if ([obj isKindOfClass:[UIImage class]]) {
            [resultArr addObject:obj];
        }
    }
    if (resultArr.count) {
        _removeAnimationImagesArray = resultArr;
    }
}

- (NSArray<__kindof UIImage *> *)removeAnimationImagesArray
{
    return _removeAnimationImagesArray ? _removeAnimationImagesArray : (_removeAnimationImagesArray = @[]);
}

- (void)setRemoveImageViewLengthOfSide:(CGFloat)removeImageViewLengthOfSide
{
    if (removeImageViewLengthOfSide <= 0) return;
    _removeImageViewLengthOfSide = removeImageViewLengthOfSide;
    CGPoint originPoint = self.removeImageView.frame.origin;
    self.removeImageView.frame = CGRectMake(originPoint.x, originPoint.y, removeImageViewLengthOfSide, removeImageViewLengthOfSide);
    self.removeImageView.center = self.center;
}

- (CGFloat)removeImageViewLengthOfSide
{
    return _removeImageViewLengthOfSide > 0.f ? _removeImageViewLengthOfSide : WliuUnReadContactCountLabelRemoveImageViewDefaultLengthOfSide;
}
#pragma mark - Reset Super Class Methods
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self frameRelatedConfig];
}
- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    self.relatedView.hidden = hidden;
}
- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (!backgroundColor) return;
    [super setBackgroundColor:backgroundColor];
    self.relatedView.backgroundColor = backgroundColor;
}
- (void)setText:(NSString *)text
{
    WliuBanAssert(@"禁止使用该赋值方法");
}

- (void)removeFromSuperview
{
    // MARK: TableViewCell 上边界问题处理
    if (self.superview) {
        if ([self.superview.superview isKindOfClass:[UITableViewCell class]]) {
            if (self.center.y < self.removeImageViewLengthOfSide) {
                if (![UIApplication sharedApplication].delegate.window) return;
                __weak typeof([UIApplication sharedApplication].delegate.window) targetView = [UIApplication sharedApplication].delegate.window;
                CGPoint targetPoint = CGPointMake(self.center.x, [self convertPoint:self.center toView:targetView].y);
                [self crossTheTableViewCellTopBorderResponseWithTargetView:targetView targetPoint:targetPoint];
                return;
            }
        }
    }
    
    // MARK: 正常算法逻辑
    [self.relatedView removeFromSuperview];
    
    self.hidden = YES;
    
    self.removeImageView.center = self.center;
    self.removeImageView.hidden = NO;
    [self configRemoveAnimationInfoWithTargetImageView:self.removeImageView];
    __weak typeof(self) wself = self;
    [self executeRemoveAnimationWithTargetImageView:self.removeImageView completeHandler:^{
        if (!wself) return ;
        wself.removeImageView.hidden = YES;
        [super removeFromSuperview];
        if (!wself.removeBlock) return;
        wself.removeBlock();
    }];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) return;
    if (!self.relatedViewSuperView || !self.removeImageViewSuperView) return;
    if (![self.relatedViewSuperView isEqual:self.removeImageViewSuperView]) return;
    if (![newSuperview isEqual:self.relatedViewSuperView]) return;
    self.relatedView.center = self.center;
    self.hidden = NO;
}

#pragma mark - System Initialized
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}
- (void)awakeFromNib{
    [self setUp];
}
#pragma mark - Initialized Related
- (void)frameRelatedConfig {
    CGFloat cornerRadius = [self getCornerRadiusWithBounds:self.bounds];
    
    _originRadius = cornerRadius / 2;
    _relatedView.frame = self.frame;
    self.removeImageView.center = self.center;
}

- (void)setUp{
    self.removeType = WliuUnReadContactCountLabelOnlyPanRemove;
    
    self.layer.masksToBounds = YES;
    self.userInteractionEnabled = YES;
    self.textAlignment = NSTextAlignmentCenter;
    
    [self frameRelatedConfig];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
}

- (void)panAction:(UIPanGestureRecognizer *)pan{
    CGPoint touchPoint = [pan translationInView:self];
    CGPoint center = self.center;
    center.x += touchPoint.x;
    center.y += touchPoint.y;
    self.center = center;
    [pan setTranslation:CGPointZero inView:self];
    
    // MARK: TableViewCell 上边界问题处理
    if (self.superview) {
        if ([self.superview.superview isKindOfClass:[UITableViewCell class]]) {
            if (self.center.y < 0) {
                [self crossTheTableViewCellTopBorderResponseWithGestureRecognizer:pan];
                return;
            }
        }
    }
    
    // MARK: 正常算法逻辑
    CGFloat circleDistance = [self distanceWithPointA:self.center pointB:self.relatedView.center];
    CGFloat relatedViewRadius = _originRadius - circleDistance / 10.0f;
    relatedViewRadius = relatedViewRadius > WliuUnReadContactCountLabelRelatedViewMinLengthOfSide ? relatedViewRadius : WliuUnReadContactCountLabelRelatedViewMinLengthOfSide;
    if (relatedViewRadius < 0) relatedViewRadius = 0;
    _relatedView.bounds = CGRectMake(0, 0, relatedViewRadius * 2, relatedViewRadius * 2);
    self.relatedView.layer.cornerRadius = relatedViewRadius;
    
    if (circleDistance > WliuUnReadContactCountLabelMaxDistance) {
        [self crossTheBorderResponse];
    }else{
        self.relatedView.hidden = NO;
        self.shapeLayer.path = [self getBezierPathWithRelatedCir:self targetCir:self.relatedView].CGPath;
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (circleDistance > WliuUnReadContactCountLabelMaxDistance) {
            [self removeFromSuperview];
        } else {
            [self.shapeLayer removeFromSuperlayer];
            self.shapeLayer = nil;
            [UIView animateWithDuration:0.6f delay:0.f usingSpringWithDamping:0.2f initialSpringVelocity:0.6f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.center = self.relatedView.center;
            } completion:nil];
        }
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tap
{
    // MARK: TableViewCell 上边界问题处理
    if (self.superview) {
        if ([self.superview.superview isKindOfClass:[UITableViewCell class]]) {
            if (self.center.y < self.removeImageViewLengthOfSide) {
                [self crossTheTableViewCellTopBorderResponseWithGestureRecognizer:tap];
                return;
            }
        }
    }
    
    // MARK: 正常算法逻辑
    if (self.removeType == WliuUnReadContactCountLabelPanAndTapRemove){
        [self removeFromSuperview];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            CGPoint originCenter = self.center;
            self.center = CGPointMake(originCenter.x + 6.f, originCenter.y + 6.f);
            self.relatedView.hidden = YES;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.6f delay:0.f usingSpringWithDamping:.1f initialSpringVelocity:16.f options:UIViewAnimationOptionCurveLinear animations:^{
                self.center = self.relatedView.center;
            } completion:^(BOOL finished) {
                self.relatedView.hidden = NO;
            }];
        }];
    }
}
#pragma mark - Private Methods
- (BOOL)superViewAllowAddSomeRelatedSubview
{
//    if (!self.unReadCount) return NO;
    if (!self.superview) return NO;
    return YES;
}
- (CGFloat)getCornerRadiusWithBounds:(CGRect)bounds {
    CGFloat radius = bounds.size.height;
    self.layer.cornerRadius = radius / 2;
    self.relatedView.layer.cornerRadius = radius / 2;
    return radius;
}

- (CGFloat)distanceWithPointA:(CGPoint)pointA pointB:(CGPoint)pointB{
    CGFloat offSetX = pointA.x - pointB.x;
    CGFloat offSetY = pointA.y - pointB.y;
    return sqrt(offSetX*offSetX + offSetY*offSetY);
}

- (UIBezierPath *)getBezierPathWithRelatedCir:(UIView *)relatedCir targetCir:(UIView *)targetCir{
    if (targetCir.frame.size.width < relatedCir.frame.size.width) {
        UIView *view = targetCir;
        targetCir = relatedCir;
        relatedCir = view;
    }
    
    CGFloat d = [self distanceWithPointA:relatedCir.center pointB:targetCir.center];
    
    CGFloat x1 = relatedCir.center.x;
    CGFloat y1 = relatedCir.center.y;
    CGFloat r1 = relatedCir.bounds.size.width/2;

    CGFloat x2 = targetCir.center.x;
    CGFloat y2 = targetCir.center.y;
    CGFloat r2 = _originRadius;
    
    //  解决圆心距为0 float -> nan(not a number) bug
    d = d ? d : 0.1f;

    CGFloat cosA = (y2 - y1)/d;
    CGFloat sinA = (x2 - x1)/d;

    CGPoint pointA = CGPointMake(x1 - cosA*r1, y1 + sinA * r1);
    CGPoint pointB = CGPointMake(x1 + cosA*r1, y1 - sinA * r1);
    CGPoint pointC = CGPointMake(x2 + cosA*r2, y2 - sinA * r2);
    CGPoint pointD = CGPointMake(x2 - cosA*r2, y2 + sinA * r2);

    CGPoint pointO = CGPointMake(pointA.x + _originRadius * sinA , pointA.y + _originRadius * cosA);
    CGPoint pointP =  CGPointMake(pointB.x + _originRadius * sinA , pointB.y + _originRadius * cosA);

    UIBezierPath *path =[UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    [path addLineToPoint:pointB];
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    [path addLineToPoint:pointD];
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    return path;
}

- (void)configRemoveAnimationInfoWithTargetImageView:(UIImageView *)targetImageView;
{
    targetImageView.animationImages = self.removeAnimationImagesArray;
    targetImageView.animationDuration = self.animationDuration ? self.animationDuration : WliuUnReadContactCountLabelRemoveImageViewDefaultAnimationDuration;
    targetImageView.animationRepeatCount = self.animationRepeatCount ? self.animationRepeatCount : WliuUnReadContactCountLabelRemoveImageViewDefaultAnimationRepeatCount;
}

- (void)executeRemoveAnimationWithTargetImageView:(UIImageView *)targetImageView completeHandler:(void(^)())complete
{
    [targetImageView startAnimating];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * 3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [targetImageView stopAnimating];
        complete();
    });
}

- (void)crossTheBorderResponse {
    [self.shapeLayer removeFromSuperlayer];
    self.relatedView.hidden = YES;
    self.shapeLayer = nil;
}

- (void)crossTheTableViewCellTopBorderResponseWithTargetView:(UIView *)targetView targetPoint:(CGPoint)targetPoint
{
    if (!targetView) return;
    
    [self.relatedView removeFromSuperview];
    self.hidden = YES;
    self.removeImageView.hidden = YES;
    
    UIImageView *removeView = [[UIImageView alloc] initWithFrame:CGRectMake(targetPoint.x - self.removeImageViewLengthOfSide / 2, targetPoint.y - self.removeImageViewLengthOfSide / 2, self.removeImageViewLengthOfSide, self.removeImageViewLengthOfSide)];
    [targetView addSubview:removeView];
    
    [self configRemoveAnimationInfoWithTargetImageView:removeView];
    __weak typeof(self) wself = self;
    __weak typeof(removeView) wremoveView = removeView;
    [self executeRemoveAnimationWithTargetImageView:removeView completeHandler:^{
        if (!wself) return ;
        if (!wremoveView) return;
        [super removeFromSuperview];
        [wremoveView removeFromSuperview];
        if (!wself.removeBlock) return;
        wself.removeBlock();
    }];
}

- (void)crossTheTableViewCellTopBorderResponseWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    [self crossTheBorderResponse];
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (![UIApplication sharedApplication].delegate.window) return;
        __weak typeof([UIApplication sharedApplication].delegate.window) targetView = [UIApplication sharedApplication].delegate.window;
        CGPoint point = [gestureRecognizer locationInView:self];
        CGPoint targetPoint = CGPointMake(self.center.x, [self convertPoint:point toView:targetView].y);
        [self crossTheTableViewCellTopBorderResponseWithTargetView:targetView targetPoint:targetPoint];
    }
}
#pragma mark - Public Methods
- (void)fetchRemoveCompletionWithHandler:(WliuUnReadContactCountLabelRemoveBlock)handler
{
    self.removeBlock = handler;
}

@end
