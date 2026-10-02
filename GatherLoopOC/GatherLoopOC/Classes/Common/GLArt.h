#import <UIKit/UIKit.h>

@interface GLSunsetView : UIView
@property (nonatomic) BOOL showPeople;
@property (nonatomic) BOOL showGlasses;
@property (nonatomic) BOOL compact;
@end

@interface GLLogoView : UIView
@end

@interface GLAvatarView : UIView
+ (instancetype)initial:(NSString *)letter color:(UIColor *)color size:(CGFloat)size;
@end
