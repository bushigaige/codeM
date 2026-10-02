#import "GLArt.h"
#import "GLTheme.h"

@implementation GLSunsetView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.showPeople = YES;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    if (w < 2 || h < 2) return;

    CAGradientLayer *sky = [CAGradientLayer layer];
    sky.frame = self.bounds;
    sky.colors = @[(id)[GLTheme hex:0x6B4CFF].CGColor, (id)[GLTheme hex:0xFF8A5C].CGColor, (id)[GLTheme hex:0x1A1630].CGColor];
    sky.locations = @[@0, @0.42, @0.42];
    sky.startPoint = CGPointMake(0, 0);
    sky.endPoint = CGPointMake(1, 1);
    [self.layer addSublayer:sky];

    CAShapeLayer *sun = [CAShapeLayer layer];
    CGFloat sunR = MIN(w, h) * (self.compact ? 0.18 : 0.22);
    sun.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(w * 0.38, h * 0.22, sunR * 2, sunR * 2)].CGPath;
    sun.fillColor = [GLTheme hex:0xFFE38A].CGColor;
    [self.layer addSublayer:sun];

    if (self.showGlasses) {
        for (NSInteger i = 0; i < 3; i++) {
            CAShapeLayer *g = [CAShapeLayer layer];
            CGFloat x = w * 0.28 + i * w * 0.16;
            UIBezierPath *p = [UIBezierPath bezierPath];
            [p moveToPoint:CGPointMake(x, h * 0.78)];
            [p addLineToPoint:CGPointMake(x + 8, h * 0.52)];
            [p addLineToPoint:CGPointMake(x + 22, h * 0.52)];
            [p addLineToPoint:CGPointMake(x + 30, h * 0.78)];
            g.path = p.CGPath;
            g.strokeColor = [UIColor colorWithWhite:1 alpha:0.85].CGColor;
            g.fillColor = [UIColor clearColor].CGColor;
            g.lineWidth = 2;
            [self.layer addSublayer:g];
        }
    }

    if (self.showPeople && !self.compact) {
        NSArray *cols = @[[GLTheme hex:0xFF7A62], [GLTheme hex:0xC8E04A], [GLTheme hex:0xC9B6FF]];
        for (NSInteger i = 0; i < 3; i++) {
            CAShapeLayer *body = [CAShapeLayer layer];
            CGFloat x = w * 0.28 + i * w * 0.16;
            UIBezierPath *p = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, h * 0.62, 28, 46) cornerRadius:14];
            body.path = p.CGPath;
            body.fillColor = [cols[i] CGColor];
            [self.layer addSublayer:body];
        }
        CAShapeLayer *ground = [CAShapeLayer layer];
        ground.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(w * 0.18, h * 0.82, w * 0.64, h * 0.12)].CGPath;
        ground.fillColor = [GLTheme hex:0xD9B48A].CGColor;
        [self.layer addSublayer:ground];
    }

    CAShapeLayer *wire = [CAShapeLayer layer];
    UIBezierPath *wp = [UIBezierPath bezierPath];
    [wp moveToPoint:CGPointMake(0, h * 0.28)];
    [wp addQuadCurveToPoint:CGPointMake(w, h * 0.22) controlPoint:CGPointMake(w * 0.5, h * 0.38)];
    wire.path = wp.CGPath;
    wire.strokeColor = [UIColor colorWithWhite:0.1 alpha:0.7].CGColor;
    wire.fillColor = UIColor.clearColor.CGColor;
    wire.lineWidth = 1.2;
    [self.layer addSublayer:wire];
    for (NSInteger i = 0; i < 5; i++) {
        CAShapeLayer *dot = [CAShapeLayer layer];
        CGFloat t = (i + 1) / 6.0;
        dot.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(w * t - 4, h * 0.30, 8, 8)].CGPath;
        dot.fillColor = [GLTheme hex:0xFFE38A].CGColor;
        [self.layer addSublayer:dot];
    }
}
@end

@implementation GLLogoView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.opaque = NO;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect {
    CGFloat s = MIN(rect.size.width, rect.size.height);
    CGRect box = CGRectMake((rect.size.width - s) / 2, (rect.size.height - s) / 2, s, s);
    UIBezierPath *tile = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(box, s * 0.18, s * 0.18) cornerRadius:s * 0.18];
    [[GLTheme hex:0x1A1C2C] setFill];
    [tile fill];
    CGPoint c = CGPointMake(CGRectGetMidX(box), CGRectGetMidY(box));
    UIBezierPath *r1 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(c.x - s * 0.04, c.y) radius:s * 0.16 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    r1.lineWidth = s * 0.055;
    [[GLTheme coral] setStroke];
    [r1 stroke];
    UIBezierPath *r2 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(c.x + s * 0.05, c.y + s * 0.02) radius:s * 0.16 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    r2.lineWidth = s * 0.055;
    [[GLTheme lime] setStroke];
    [r2 stroke];
    UIBezierPath *dot = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(c.x - s * 0.14, c.y + s * 0.08, s * 0.045, s * 0.045)];
    [[UIColor whiteColor] setFill];
    [dot fill];
}
@end

@implementation GLAvatarView
+ (instancetype)initial:(NSString *)letter color:(UIColor *)color size:(CGFloat)size {
    GLAvatarView *v = [GLAvatarView new];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = color;
    v.layer.cornerRadius = size / 2.0;
    UILabel *l = [GLTheme label:letter font:[GLTheme title:size * 0.42] color:UIColor.whiteColor];
    l.textAlignment = NSTextAlignmentCenter;
    [v addSubview:l];
    [NSLayoutConstraint activateConstraints:@[
        [v.widthAnchor constraintEqualToConstant:size],
        [v.heightAnchor constraintEqualToConstant:size],
        [l.centerXAnchor constraintEqualToAnchor:v.centerXAnchor],
        [l.centerYAnchor constraintEqualToAnchor:v.centerYAnchor]
    ]];
    return v;
}
@end
