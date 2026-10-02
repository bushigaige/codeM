#import "GLTheme.h"

@implementation GLTheme
+ (UIColor *)hex:(NSUInteger)hex {
    return [UIColor colorWithRed:((hex>>16)&0xFF)/255.0 green:((hex>>8)&0xFF)/255.0 blue:(hex&0xFF)/255.0 alpha:1];
}
+ (UIColor *)bg { return [self hex:0xF3F1ED]; }
+ (UIColor *)ink { return [self hex:0x16141F]; }
+ (UIColor *)sub { return [self hex:0x8B8794]; }
+ (UIColor *)muted { return [self hex:0xA8A4B0]; }
+ (UIColor *)line { return [self hex:0xE8E4DE]; }
+ (UIColor *)card { return [UIColor whiteColor]; }
+ (UIColor *)coral { return [self hex:0xFF6B55]; }
+ (UIColor *)purple { return [self hex:0x7C5CFF]; }
+ (UIColor *)lime { return [self hex:0xD4E14A]; }
+ (UIColor *)mint { return [self hex:0x7DE5C5]; }
+ (UIColor *)lavender { return [self hex:0xE6E0FF]; }
+ (UIColor *)navy { return [self hex:0x16141F]; }
+ (UIColor *)darkBg { return [self hex:0x0F0F17]; }
+ (UIColor *)softCoral { return [self hex:0xFFE3DC]; }
+ (UIColor *)softPurple { return [self hex:0xF1ECFF]; }
+ (UIFont *)display:(CGFloat)size { return [UIFont systemFontOfSize:size weight:UIFontWeightHeavy]; }
+ (UIFont *)title:(CGFloat)size { return [UIFont systemFontOfSize:size weight:UIFontWeightBold]; }
+ (UIFont *)medium:(CGFloat)size { return [UIFont systemFontOfSize:size weight:UIFontWeightSemibold]; }
+ (UIFont *)regular:(CGFloat)size { return [UIFont systemFontOfSize:size weight:UIFontWeightRegular]; }
+ (UILabel *)label:(NSString *)text font:(UIFont *)font color:(UIColor *)color {
    UILabel *l = [UILabel new];
    l.translatesAutoresizingMaskIntoConstraints = NO;
    l.text = text;
    l.font = font;
    l.textColor = color;
    return l;
}
+ (UIButton *)circleSymbol:(NSString *)name bg:(UIColor *)bg tint:(UIColor *)tint size:(CGFloat)size {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.translatesAutoresizingMaskIntoConstraints = NO;
    b.backgroundColor = bg;
    b.tintColor = tint;
    b.layer.cornerRadius = size / 2.0;
    UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:MAX(12, size * 0.38) weight:UIImageSymbolWeightMedium];
    [b setImage:[UIImage systemImageNamed:name withConfiguration:cfg] forState:UIControlStateNormal];
    [b.widthAnchor constraintEqualToConstant:size].active = YES;
    [b.heightAnchor constraintEqualToConstant:size].active = YES;
    return b;
}
+ (UIView *)iconBox:(NSString *)name bg:(UIColor *)bg tint:(UIColor *)tint size:(CGFloat)size radius:(CGFloat)radius {
    UIView *v = [UIView new];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = bg;
    v.layer.cornerRadius = radius;
    UIImageView *iv = [UIImageView new];
    iv.translatesAutoresizingMaskIntoConstraints = NO;
    iv.tintColor = tint;
    iv.contentMode = UIViewContentModeScaleAspectFit;
    UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:size * 0.42 weight:UIImageSymbolWeightMedium];
    iv.image = [UIImage systemImageNamed:name withConfiguration:cfg];
    [v addSubview:iv];
    [NSLayoutConstraint activateConstraints:@[
        [v.widthAnchor constraintEqualToConstant:size],
        [v.heightAnchor constraintEqualToConstant:size],
        [iv.centerXAnchor constraintEqualToAnchor:v.centerXAnchor],
        [iv.centerYAnchor constraintEqualToAnchor:v.centerYAnchor]
    ]];
    return v;
}
+ (UIView *)card:(CGFloat)radius {
    UIView *v = [UIView new];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = [self card];
    v.layer.cornerRadius = radius;
    v.clipsToBounds = YES;
    return v;
}
+ (UIView *)wrap:(UIView *)inner {
    inner.translatesAutoresizingMaskIntoConstraints = NO;
    return inner;
}
+ (void)gradient:(UIView *)view colors:(NSArray<UIColor *> *)colors start:(CGPoint)start end:(CGPoint)end {
    CAGradientLayer *g = [CAGradientLayer layer];
    g.frame = view.bounds;
    NSMutableArray *cg = [NSMutableArray array];
    for (UIColor *c in colors) { [cg addObject:(id)c.CGColor]; }
    g.colors = cg;
    g.startPoint = start;
    g.endPoint = end;
    g.name = @"gl.gradient";
    NSMutableArray *toRemove = [NSMutableArray array];
    for (CALayer *l in view.layer.sublayers) {
        if ([l.name isEqualToString:@"gl.gradient"]) { [toRemove addObject:l]; }
    }
    for (CALayer *l in toRemove) { [l removeFromSuperlayer]; }
    [view.layer insertSublayer:g atIndex:0];
}
+ (void)round:(UIView *)view radius:(CGFloat)radius {
    view.layer.cornerRadius = radius;
    view.clipsToBounds = YES;
}
+ (UIButton *)fillButton:(NSString *)title bg:(UIColor *)bg fg:(UIColor *)fg radius:(CGFloat)radius {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.translatesAutoresizingMaskIntoConstraints = NO;
    [b setTitle:title forState:UIControlStateNormal];
    [b setTitleColor:fg forState:UIControlStateNormal];
    b.titleLabel.font = [self title:16];
    b.backgroundColor = bg;
    b.layer.cornerRadius = radius;
    return b;
}
+ (UIView *)pill:(NSString *)text bg:(UIColor *)bg fg:(UIColor *)fg {
    UILabel *l = [self label:text font:[self medium:12] color:fg];
    UIView *v = [UIView new];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = bg;
    v.layer.cornerRadius = 14;
    [v addSubview:l];
    [NSLayoutConstraint activateConstraints:@[
        [l.leadingAnchor constraintEqualToAnchor:v.leadingAnchor constant:10],
        [l.trailingAnchor constraintEqualToAnchor:v.trailingAnchor constant:-10],
        [l.topAnchor constraintEqualToAnchor:v.topAnchor constant:6],
        [l.bottomAnchor constraintEqualToAnchor:v.bottomAnchor constant:-6]
    ]];
    return v;
}
+ (void)pin:(UIView *)v to:(UIView *)p insets:(UIEdgeInsets)insets {
    v.translatesAutoresizingMaskIntoConstraints = NO;
    if (v.superview != p) { [p addSubview:v]; }
    [NSLayoutConstraint activateConstraints:@[
        [v.topAnchor constraintEqualToAnchor:p.topAnchor constant:insets.top],
        [v.leadingAnchor constraintEqualToAnchor:p.leadingAnchor constant:insets.left],
        [v.trailingAnchor constraintEqualToAnchor:p.trailingAnchor constant:-insets.right],
        [v.bottomAnchor constraintEqualToAnchor:p.bottomAnchor constant:-insets.bottom]
    ]];
}
+ (NSLayoutConstraint *)vchain:(NSArray<UIView *> *)views in:(UIView *)parent start:(NSLayoutYAxisAnchor *)start pad:(CGFloat)pad gap:(CGFloat)gap {
    UIView *prev = nil;
    NSLayoutConstraint *lastBottom = nil;
    for (UIView *v in views) {
        v.translatesAutoresizingMaskIntoConstraints = NO;
        if (v.superview != parent) { [parent addSubview:v]; }
        if (!prev) {
            [v.topAnchor constraintEqualToAnchor:start constant:pad].active = YES;
        } else {
            [v.topAnchor constraintEqualToAnchor:prev.bottomAnchor constant:gap].active = YES;
        }
        prev = v;
    }
    if (prev) {
        lastBottom = [prev.bottomAnchor constraintEqualToAnchor:parent.bottomAnchor constant:-pad];
        lastBottom.active = YES;
    }
    return lastBottom;
}
+ (UIScrollView *)embedScrollIn:(UIView *)host content:(UIView * __strong *)content top:(NSLayoutYAxisAnchor *)top bottom:(NSLayoutYAxisAnchor *)bottom {
    UIScrollView *scroll = [UIScrollView new];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    scroll.alwaysBounceVertical = YES;
    scroll.showsVerticalScrollIndicator = NO;
    scroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    scroll.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [host addSubview:scroll];
    UIView *c = [UIView new];
    c.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:c];
    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:top],
        [scroll.leadingAnchor constraintEqualToAnchor:host.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:host.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:bottom],
        [c.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor],
        [c.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor],
        [c.leadingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.leadingAnchor],
        [c.trailingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.trailingAnchor],
        [c.widthAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.widthAnchor]
    ]];
    if (content) *content = c;
    return scroll;
}
+ (UIStackView *)column:(NSArray<UIView *> *)views spacing:(CGFloat)spacing {
    UIStackView *s = [UIStackView new];
    s.translatesAutoresizingMaskIntoConstraints = NO;
    s.axis = UILayoutConstraintAxisVertical;
    s.spacing = spacing;
    s.alignment = UIStackViewAlignmentFill;
    for (UIView *v in views) {
        v.translatesAutoresizingMaskIntoConstraints = NO;
        [s addArrangedSubview:v];
    }
    return s;
}
@end
