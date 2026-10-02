#import "GLWelcomeViewController.h"
#import "GLTheme.h"
#import "GLArt.h"
#import "GLStore.h"
#import "GLCreateViewController.h"
#import "SceneDelegate.h"

@implementation GLWelcomeViewController
- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [GLTheme darkBg];
    [self build];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [GLTheme gradient:self.view colors:@[[GLTheme hex:0x1A1424], [GLTheme darkBg], [GLTheme hex:0x12151C]] start:CGPointMake(0.7, 0) end:CGPointMake(0.3, 1)];
}
- (void)build {
    UIView *content = nil;
    UIScrollView *scroll = [GLTheme embedScrollIn:self.view content:&content top:self.view.safeAreaLayoutGuide.topAnchor bottom:self.view.safeAreaLayoutGuide.bottomAnchor];
    scroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;

    UIView *hero = [UIView new];
    hero.translatesAutoresizingMaskIntoConstraints = NO;
    GLLogoView *logo = [GLLogoView new];
    logo.translatesAutoresizingMaskIntoConstraints = NO;
    [hero addSubview:logo];
    UIView *chip1 = [self glass:@"checkmark.circle.fill" text:@"Plan together"];
    UIView *chip3 = [self glass:@"timer" text:@"Time capsule"];
    [hero addSubview:chip1];
    [hero addSubview:chip3];

    UILabel *brand = [GLTheme label:@"GatherLoop" font:[GLTheme medium:15] color:UIColor.whiteColor];
    brand.textAlignment = NSTextAlignmentCenter;
    UILabel *headline = [GLTheme label:@"Every gathering deserves an afterglow." font:[GLTheme display:32] color:UIColor.whiteColor];
    headline.numberOfLines = 0;
    headline.textAlignment = NSTextAlignmentCenter;
    headline.adjustsFontSizeToFitWidth = YES;
    headline.minimumScaleFactor = 0.75;
    UILabel *sub = [GLTheme label:@"Plan the details with friends and turn every gathering into a shared story." font:[GLTheme regular:15] color:[UIColor colorWithWhite:0.72 alpha:1]];
    sub.numberOfLines = 0;
    sub.textAlignment = NSTextAlignmentCenter;

    UIView *spacer = [UIView new];
    spacer.translatesAutoresizingMaskIntoConstraints = NO;
    [spacer setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
    [spacer setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];

    UIButton *create = [GLTheme fillButton:@"Create your first gathering  →" bg:[GLTheme coral] fg:UIColor.whiteColor radius:22];
    [create addTarget:self action:@selector(onCreate) forControlEvents:UIControlEventTouchUpInside];
    UIButton *invite = [UIButton buttonWithType:UIButtonTypeSystem];
    invite.translatesAutoresizingMaskIntoConstraints = NO;
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:@"I have an invite" attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSForegroundColorAttributeName: UIColor.whiteColor, NSFontAttributeName: [GLTheme medium:15]}];
    [invite setAttributedTitle:attr forState:UIControlStateNormal];
    [invite addTarget:self action:@selector(onInvite) forControlEvents:UIControlEventTouchUpInside];
    UILabel *foot = [GLTheme label:@"Private by default · You're in control of every moment" font:[GLTheme regular:11] color:[UIColor colorWithWhite:0.45 alpha:1]];
    foot.textAlignment = NSTextAlignmentCenter;

    UIStackView *col = [GLTheme column:@[hero, brand, headline, sub, spacer, create, invite, foot] spacing:0];
    col.alignment = UIStackViewAlignmentFill;
    [content addSubview:col];
    [col setCustomSpacing:8 afterView:hero];
    [col setCustomSpacing:14 afterView:brand];
    [col setCustomSpacing:12 afterView:headline];
    [col setCustomSpacing:22 afterView:sub];
    [col setCustomSpacing:8 afterView:create];
    [col setCustomSpacing:16 afterView:invite];

    NSLayoutConstraint *minH = [content.heightAnchor constraintGreaterThanOrEqualToAnchor:scroll.frameLayoutGuide.heightAnchor];
    minH.priority = UILayoutPriorityDefaultLow + 1;
    NSLayoutConstraint *heroH = [hero.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.28];
    heroH.priority = 750;
    [NSLayoutConstraint activateConstraints:@[
        [col.topAnchor constraintEqualToAnchor:content.topAnchor constant:8],
        [col.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:22],
        [col.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-22],
        [col.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-12],
        minH,
        [hero.heightAnchor constraintGreaterThanOrEqualToConstant:160],
        [hero.heightAnchor constraintLessThanOrEqualToConstant:240],
        heroH,
        [logo.centerXAnchor constraintEqualToAnchor:hero.centerXAnchor],
        [logo.centerYAnchor constraintEqualToAnchor:hero.centerYAnchor],
        [logo.widthAnchor constraintEqualToAnchor:hero.widthAnchor multiplier:0.82],
        [logo.heightAnchor constraintEqualToAnchor:hero.heightAnchor],
        [chip1.topAnchor constraintEqualToAnchor:hero.topAnchor constant:18],
        [chip1.leadingAnchor constraintEqualToAnchor:hero.leadingAnchor],
        [chip3.bottomAnchor constraintEqualToAnchor:hero.bottomAnchor constant:-4],
        [chip3.centerXAnchor constraintEqualToAnchor:hero.centerXAnchor],
        [create.heightAnchor constraintEqualToConstant:56],
        [spacer.heightAnchor constraintGreaterThanOrEqualToConstant:12]
    ]];
}
- (UIView *)glass:(NSString *)symbol text:(NSString *)text {
    UIVisualEffectView *v = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.layer.cornerRadius = 14;
    v.clipsToBounds = YES;
    UIImageView *iv = [UIImageView new];
    iv.translatesAutoresizingMaskIntoConstraints = NO;
    iv.tintColor = UIColor.whiteColor;
    iv.image = [UIImage systemImageNamed:symbol];
    UILabel *l = [GLTheme label:text font:[GLTheme medium:12] color:UIColor.whiteColor];
    [v.contentView addSubview:iv];
    [v.contentView addSubview:l];
    [NSLayoutConstraint activateConstraints:@[
        [iv.leadingAnchor constraintEqualToAnchor:v.contentView.leadingAnchor constant:10],
        [iv.centerYAnchor constraintEqualToAnchor:v.contentView.centerYAnchor],
        [l.leadingAnchor constraintEqualToAnchor:iv.trailingAnchor constant:6],
        [l.trailingAnchor constraintEqualToAnchor:v.contentView.trailingAnchor constant:-10],
        [l.topAnchor constraintEqualToAnchor:v.contentView.topAnchor constant:8],
        [l.bottomAnchor constraintEqualToAnchor:v.contentView.bottomAnchor constant:-8],
        [v.heightAnchor constraintEqualToConstant:34]
    ]];
    return v;
}
- (void)onCreate {
    GLCreateViewController *vc = [GLCreateViewController new];
    vc.fromOnboarding = YES;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    vc.modalPresentationCapturesStatusBarAppearance = YES;
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)onInvite {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Enter invite code" message:@"Ask the host for the gathering invite code." preferredStyle:UIAlertControllerStyleAlert];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"e.g. SUNSET"; tf.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters; }];
    [a addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [a addAction:[UIAlertAction actionWithTitle:@"Join" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *code = a.textFields.firstObject.text;
        if (code.length == 0) return;
        [GLStore shared].onboarded = YES;
        [[GLStore shared] notify];
        SceneDelegate *sd = (SceneDelegate *)self.view.window.windowScene.delegate;
        [sd showMain];
    }]];
    [self presentViewController:a animated:YES completion:nil];
}
@end
