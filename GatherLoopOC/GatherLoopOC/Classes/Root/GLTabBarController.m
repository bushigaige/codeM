#import "GLTabBarController.h"
#import "GLHomeViewController.h"
#import "GLIdeasViewController.h"
#import "GLMemoriesViewController.h"
#import "GLMeViewController.h"
#import "GLCreateViewController.h"
#import "GLTheme.h"

@interface GLNavController : UINavigationController
@end
@implementation GLNavController
- (UIViewController *)childViewControllerForStatusBarStyle { return self.topViewController; }
- (UIViewController *)childViewControllerForStatusBarHidden { return self.topViewController; }
- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.topViewController.preferredStatusBarStyle;
}
@end

@interface GLTabBarController () <UITabBarControllerDelegate>
@property (nonatomic, strong) UIButton *plusButton;
@end

@implementation GLTabBarController
- (UINavigationController *)wrap:(UIViewController *)vc title:(NSString *)title icon:(NSString *)icon {
    UINavigationController *nav = [[GLNavController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    UIImage *img = [UIImage systemImageNamed:icon];
    nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:img selectedImage:img];
    return nav;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    UIViewController *placeholder = [UIViewController new];
    placeholder.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"" image:nil selectedImage:nil];
    placeholder.tabBarItem.enabled = NO;
    self.viewControllers = @[
        [self wrap:[GLHomeViewController new] title:@"Home" icon:@"house.fill"],
        [self wrap:[GLIdeasViewController new] title:@"Ideas" icon:@"safari"],
        placeholder,
        [self wrap:[GLMemoriesViewController new] title:@"Memories" icon:@"square.stack.3d.up"],
        [self wrap:[GLMeViewController new] title:@"Me" icon:@"person"]
    ];
    self.tabBar.tintColor = [GLTheme ink];
    self.tabBar.unselectedItemTintColor = [GLTheme sub];
    self.tabBar.backgroundColor = UIColor.whiteColor;
    if (@available(iOS 15.0, *)) {
        UITabBarAppearance *ap = [UITabBarAppearance new];
        [ap configureWithOpaqueBackground];
        ap.backgroundColor = UIColor.whiteColor;
        self.tabBar.standardAppearance = ap;
        self.tabBar.scrollEdgeAppearance = ap;
    }
    self.plusButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.plusButton.translatesAutoresizingMaskIntoConstraints = YES;
    self.plusButton.backgroundColor = [GLTheme coral];
    self.plusButton.tintColor = UIColor.whiteColor;
    self.plusButton.layer.cornerRadius = 18;
    UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:22 weight:UIImageSymbolWeightBold];
    [self.plusButton setImage:[UIImage systemImageNamed:@"plus" withConfiguration:cfg] forState:UIControlStateNormal];
    [self.plusButton addTarget:self action:@selector(openCreate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.plusButton];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat size = 58;
    CGFloat x = (self.view.bounds.size.width - size) / 2.0;
    CGFloat y = self.tabBar.frame.origin.y - 18;
    self.plusButton.frame = CGRectMake(x, y, size, size);
    [self.view bringSubviewToFront:self.plusButton];
}
- (void)openCreate {
    GLCreateViewController *vc = [GLCreateViewController new];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}
- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.selectedViewController;
}
- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.selectedViewController;
}
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return viewController != self.viewControllers[2];
}
@end
