#import <UIKit/UIKit.h>

@interface GLTheme : NSObject
+ (UIColor *)hex:(NSUInteger)hex;
+ (UIColor *)bg;
+ (UIColor *)ink;
+ (UIColor *)sub;
+ (UIColor *)muted;
+ (UIColor *)line;
+ (UIColor *)card;
+ (UIColor *)coral;
+ (UIColor *)purple;
+ (UIColor *)lime;
+ (UIColor *)mint;
+ (UIColor *)lavender;
+ (UIColor *)navy;
+ (UIColor *)darkBg;
+ (UIColor *)softCoral;
+ (UIColor *)softPurple;
+ (UIFont *)display:(CGFloat)size;
+ (UIFont *)title:(CGFloat)size;
+ (UIFont *)medium:(CGFloat)size;
+ (UIFont *)regular:(CGFloat)size;
+ (UILabel *)label:(NSString *)text font:(UIFont *)font color:(UIColor *)color;
+ (UIButton *)circleSymbol:(NSString *)name bg:(UIColor *)bg tint:(UIColor *)tint size:(CGFloat)size;
+ (UIView *)iconBox:(NSString *)name bg:(UIColor *)bg tint:(UIColor *)tint size:(CGFloat)size radius:(CGFloat)radius;
+ (UIView *)card:(CGFloat)radius;
+ (UIView *)wrap:(UIView *)inner;
+ (void)gradient:(UIView *)view colors:(NSArray<UIColor *> *)colors start:(CGPoint)start end:(CGPoint)end;
+ (void)round:(UIView *)view radius:(CGFloat)radius;
+ (UIButton *)fillButton:(NSString *)title bg:(UIColor *)bg fg:(UIColor *)fg radius:(CGFloat)radius;
+ (UIView *)pill:(NSString *)text bg:(UIColor *)bg fg:(UIColor *)fg;
+ (void)pin:(UIView *)v to:(UIView *)p insets:(UIEdgeInsets)insets;
+ (NSLayoutConstraint *)vchain:(NSArray<UIView *> *)views in:(UIView *)parent start:(NSLayoutYAxisAnchor *)start pad:(CGFloat)pad gap:(CGFloat)gap;
+ (UIScrollView *)embedScrollIn:(UIView *)host content:(UIView * __strong *)content top:(NSLayoutYAxisAnchor *)top bottom:(NSLayoutYAxisAnchor *)bottom;
+ (UIStackView *)column:(NSArray<UIView *> *)views spacing:(CGFloat)spacing;
@end
