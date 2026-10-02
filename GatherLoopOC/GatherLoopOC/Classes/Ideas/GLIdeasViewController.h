#import <UIKit/UIKit.h>
@interface GLIdeasViewController : UIViewController
+ (UIView *)ideaRowForIdea:(NSDictionary *)idea target:(id)target action:(SEL)action saveAction:(SEL)saveAction;
@end
