#import "SceneDelegate.h"
#import "AppDelegate.h"
#import "GLTabBarController.h"
#import "GLWelcomeViewController.h"
#import "GLStore.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) { return; }

    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    self.window.backgroundColor = UIColor.whiteColor;

    AppDelegate *appDelegate = (AppDelegate *)UIApplication.sharedApplication.delegate;
    appDelegate.window = self.window;

    self.window.rootViewController = [GLStore shared].onboarded ? [GLTabBarController new] : [GLWelcomeViewController new];
    [self.window makeKeyAndVisible];
}

- (void)showWelcome {
    self.window.rootViewController = [GLWelcomeViewController new];
}

- (void)showMain {
    self.window.rootViewController = [GLTabBarController new];
}

@end
