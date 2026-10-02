#import "GLSmartPlanViewController.h"
#import "GLTheme.h"
#import "GLStore.h"
#import "GLEventHubViewController.h"
#import "GLTabBarController.h"
#import "SceneDelegate.h"

@interface GLSmartPlanViewController () <UITextViewDelegate>
@property (nonatomic, strong) NSMutableArray<UIButton *> *feelBtns;
@property (nonatomic, copy) NSString *feel;
@property (nonatomic, strong) UITextView *must;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *lean;
@property (nonatomic, strong) UILabel *bal;
@property (nonatomic, strong) UILabel *extra;
@end

@implementation GLSmartPlanViewController
- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [GLTheme hex:0x2A1B6B];
    self.feel = [GLStore shared].gathering[@"feel"] ?: @"Warm & social";
    [self build];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIView *header = [self.view viewWithTag:100];
    [GLTheme gradient:header colors:@[[GLTheme hex:0x2A1B6B], [GLTheme hex:0x3B2A8A]] start:CGPointMake(0, 0) end:CGPointMake(1, 1)];
}
- (void)build {
    UIView *header = [UIView new];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    header.tag = 100;
    [self.view addSubview:header];
    UIButton *back = [GLTheme circleSymbol:@"chevron.left" bg:[UIColor colorWithWhite:1 alpha:0.12] tint:UIColor.whiteColor size:36];
    [back addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    UILabel *nav = [GLTheme label:@"Smart Plan" font:[GLTheme title:16] color:UIColor.whiteColor];
    UIButton *hist = [GLTheme circleSymbol:@"clock" bg:[UIColor colorWithWhite:1 alpha:0.12] tint:UIColor.whiteColor size:36];
    UIView *wand = [GLTheme iconBox:@"wand.and.stars" bg:[GLTheme lime] tint:[GLTheme ink] size:44 radius:14];
    UILabel *cop = [GLTheme label:@"GATHERLOOP ASSISTANT" font:[GLTheme medium:11] color:[UIColor colorWithWhite:1 alpha:0.8]];
    UILabel *h = [GLTheme label:@"Turn the vibe into an actionable plan." font:[GLTheme title:22] color:UIColor.whiteColor];
    h.numberOfLines = 0;
    [header addSubview:back]; [header addSubview:nav]; [header addSubview:hist]; [header addSubview:wand]; [header addSubview:cop]; [header addSubview:h];

    UIView *sheet = [UIView new];
    sheet.translatesAutoresizingMaskIntoConstraints = NO;
    sheet.backgroundColor = UIColor.whiteColor;
    sheet.layer.cornerRadius = 28;
    sheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    [self.view addSubview:sheet];

    UIScrollView *scroll = [UIScrollView new];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [sheet addSubview:scroll];
    UIView *c = [UIView new];
    c.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:c];

    UIView *info = [GLTheme card:16];
    info.backgroundColor = [GLTheme hex:0xDFF8E8];
    UILabel *infoT = [GLTheme label:@"Tailored to your event" font:[GLTheme title:14] color:[GLTheme hex:0x1F7A4C]];
    UILabel *infoS = [GLTheme label:@"Suggestions are editable and become real tasks—not just chat." font:[GLTheme regular:12] color:[GLTheme ink]];
    infoS.numberOfLines = 0;
    [info addSubview:infoT]; [info addSubview:infoS];

    UILabel *feelL = [GLTheme label:@"What's the feel?" font:[GLTheme title:15] color:[GLTheme ink]];
    self.feelBtns = [NSMutableArray array];
    UIStackView *feelCol = [UIStackView new];
    feelCol.translatesAutoresizingMaskIntoConstraints = NO;
    feelCol.axis = UILayoutConstraintAxisVertical;
    feelCol.spacing = 8;
    for (NSString *n in @[@"Warm & social", @"Low effort", @"Photo-ready", @"Family-friendly"]) {
        UIButton *b = [GLTheme fillButton:n bg:UIColor.whiteColor fg:[GLTheme ink] radius:18];
        b.layer.borderWidth = 1;
        b.layer.borderColor = [GLTheme line].CGColor;
        [b.heightAnchor constraintEqualToConstant:44].active = YES;
        [b addTarget:self action:@selector(pickFeel:) forControlEvents:UIControlEventTouchUpInside];
        [feelCol addArrangedSubview:b];
        [self.feelBtns addObject:b];
    }

    UILabel *mustL = [GLTheme label:@"Must-haves" font:[GLTheme title:15] color:[GLTheme ink]];
    self.must = [UITextView new];
    self.must.translatesAutoresizingMaskIntoConstraints = NO;
    self.must.font = [GLTheme regular:15];
    self.must.text = [GLStore shared].gathering[@"mustHave"];
    self.must.layer.cornerRadius = 16;
    self.must.layer.borderWidth = 1;
    self.must.layer.borderColor = [GLTheme line].CGColor;
    self.must.textContainerInset = UIEdgeInsetsMake(12, 8, 12, 8);
    self.must.delegate = self;

    UILabel *budL = [GLTheme label:@"Budget comfort" font:[GLTheme title:15] color:[GLTheme ink]];
    self.lean = [GLTheme label:@"$180 Lean" font:[GLTheme medium:13] color:[GLTheme sub]];
    self.bal = [GLTheme label:@"$280 Balanced" font:[GLTheme title:13] color:[GLTheme purple]];
    self.extra = [GLTheme label:@"$420 Generous" font:[GLTheme medium:13] color:[GLTheme sub]];
    self.slider = [UISlider new];
    self.slider.translatesAutoresizingMaskIntoConstraints = NO;
    self.slider.minimumValue = 0;
    self.slider.maximumValue = 2;
    self.slider.value = 1;
    self.slider.minimumTrackTintColor = [GLTheme purple];
    [self.slider addTarget:self action:@selector(slide) forControlEvents:UIControlEventValueChanged];

    UIView *sum = [GLTheme card:18];
    sum.backgroundColor = [GLTheme lavender];
    UILabel *st = [GLTheme label:@"Your plan will include" font:[GLTheme title:15] color:[GLTheme ink]];
    UILabel *ss = [GLTheme label:@"Based on 18 guests · 3 hours" font:[GLTheme regular:12] color:[GLTheme sub]];
    UIStackView *tags = [UIStackView new];
    tags.translatesAutoresizingMaskIntoConstraints = NO;
    tags.spacing = 6;
    for (NSString *t in @[@"Timeline", @"11 tasks", @"Shopping", @"2 tips"]) {
        [tags addArrangedSubview:[GLTheme pill:t bg:UIColor.whiteColor fg:[GLTheme ink]]];
    }
    [sum addSubview:st]; [sum addSubview:ss]; [sum addSubview:tags];

    UIButton *build = [GLTheme fillButton:@"Generate editable plan  ✦" bg:[GLTheme coral] fg:UIColor.whiteColor radius:24];
    [build addTarget:self action:@selector(buildPlan) forControlEvents:UIControlEventTouchUpInside];

    for (UIView *v in @[info, feelL, feelCol, mustL, self.must, budL, self.lean, self.bal, self.extra, self.slider, sum, build]) [c addSubview:v];

    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [header.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [header.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [back.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:4],
        [back.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:16],
        [nav.centerYAnchor constraintEqualToAnchor:back.centerYAnchor],
        [nav.centerXAnchor constraintEqualToAnchor:header.centerXAnchor],
        [hist.centerYAnchor constraintEqualToAnchor:back.centerYAnchor],
        [hist.trailingAnchor constraintEqualToAnchor:header.trailingAnchor constant:-16],
        [wand.leadingAnchor constraintEqualToAnchor:back.leadingAnchor],
        [wand.topAnchor constraintEqualToAnchor:back.bottomAnchor constant:16],
        [cop.leadingAnchor constraintEqualToAnchor:wand.trailingAnchor constant:10],
        [cop.topAnchor constraintEqualToAnchor:wand.topAnchor],
        [h.leadingAnchor constraintEqualToAnchor:cop.leadingAnchor],
        [h.topAnchor constraintEqualToAnchor:cop.bottomAnchor constant:4],
        [h.trailingAnchor constraintEqualToAnchor:header.trailingAnchor constant:-16],
        [header.bottomAnchor constraintEqualToAnchor:h.bottomAnchor constant:28],
        [sheet.topAnchor constraintEqualToAnchor:header.bottomAnchor constant:-16],
        [sheet.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [sheet.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [sheet.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [scroll.topAnchor constraintEqualToAnchor:sheet.topAnchor constant:8],
        [scroll.leadingAnchor constraintEqualToAnchor:sheet.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:sheet.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [c.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor],
        [c.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor],
        [c.leadingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.leadingAnchor],
        [c.trailingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.trailingAnchor],
        [c.widthAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.widthAnchor],
        [info.topAnchor constraintEqualToAnchor:c.topAnchor constant:18],
        [info.leadingAnchor constraintEqualToAnchor:c.leadingAnchor constant:16],
        [info.trailingAnchor constraintEqualToAnchor:c.trailingAnchor constant:-16],
        [infoT.topAnchor constraintEqualToAnchor:info.topAnchor constant:12],
        [infoT.leadingAnchor constraintEqualToAnchor:info.leadingAnchor constant:14],
        [infoS.topAnchor constraintEqualToAnchor:infoT.bottomAnchor constant:4],
        [infoS.leadingAnchor constraintEqualToAnchor:infoT.leadingAnchor],
        [infoS.trailingAnchor constraintEqualToAnchor:info.trailingAnchor constant:-14],
        [infoS.bottomAnchor constraintEqualToAnchor:info.bottomAnchor constant:-12],
        [feelL.topAnchor constraintEqualToAnchor:info.bottomAnchor constant:18],
        [feelL.leadingAnchor constraintEqualToAnchor:info.leadingAnchor],
        [feelCol.topAnchor constraintEqualToAnchor:feelL.bottomAnchor constant:10],
        [feelCol.leadingAnchor constraintEqualToAnchor:info.leadingAnchor],
        [feelCol.trailingAnchor constraintEqualToAnchor:info.trailingAnchor],
        [mustL.topAnchor constraintEqualToAnchor:feelCol.bottomAnchor constant:18],
        [mustL.leadingAnchor constraintEqualToAnchor:feelL.leadingAnchor],
        [self.must.topAnchor constraintEqualToAnchor:mustL.bottomAnchor constant:8],
        [self.must.leadingAnchor constraintEqualToAnchor:info.leadingAnchor],
        [self.must.trailingAnchor constraintEqualToAnchor:info.trailingAnchor],
        [self.must.heightAnchor constraintEqualToConstant:88],
        [budL.topAnchor constraintEqualToAnchor:self.must.bottomAnchor constant:18],
        [budL.leadingAnchor constraintEqualToAnchor:mustL.leadingAnchor],
        [self.lean.topAnchor constraintEqualToAnchor:budL.bottomAnchor constant:10],
        [self.lean.leadingAnchor constraintEqualToAnchor:info.leadingAnchor],
        [self.bal.centerYAnchor constraintEqualToAnchor:self.lean.centerYAnchor],
        [self.bal.centerXAnchor constraintEqualToAnchor:c.centerXAnchor],
        [self.extra.centerYAnchor constraintEqualToAnchor:self.lean.centerYAnchor],
        [self.extra.trailingAnchor constraintEqualToAnchor:info.trailingAnchor],
        [self.slider.topAnchor constraintEqualToAnchor:self.lean.bottomAnchor constant:8],
        [self.slider.leadingAnchor constraintEqualToAnchor:info.leadingAnchor],
        [self.slider.trailingAnchor constraintEqualToAnchor:info.trailingAnchor],
        [sum.topAnchor constraintEqualToAnchor:self.slider.bottomAnchor constant:16],
        [sum.leadingAnchor constraintEqualToAnchor:info.leadingAnchor],
        [sum.trailingAnchor constraintEqualToAnchor:info.trailingAnchor],
        [st.topAnchor constraintEqualToAnchor:sum.topAnchor constant:14],
        [st.leadingAnchor constraintEqualToAnchor:sum.leadingAnchor constant:14],
        [ss.topAnchor constraintEqualToAnchor:st.bottomAnchor constant:4],
        [ss.leadingAnchor constraintEqualToAnchor:st.leadingAnchor],
        [tags.topAnchor constraintEqualToAnchor:ss.bottomAnchor constant:10],
        [tags.leadingAnchor constraintEqualToAnchor:st.leadingAnchor],
        [tags.bottomAnchor constraintEqualToAnchor:sum.bottomAnchor constant:-14],
        [build.topAnchor constraintEqualToAnchor:sum.bottomAnchor constant:18],
        [build.leadingAnchor constraintEqualToAnchor:info.leadingAnchor],
        [build.trailingAnchor constraintEqualToAnchor:info.trailingAnchor],
        [build.heightAnchor constraintEqualToConstant:56],
        [build.bottomAnchor constraintEqualToAnchor:c.bottomAnchor constant:-28]
    ]];
    [self styleFeel];
}
- (void)pickFeel:(UIButton *)b {
    self.feel = [b titleForState:UIControlStateNormal];
    [self styleFeel];
}
- (void)styleFeel {
    for (UIButton *b in self.feelBtns) {
        BOOL on = [[b titleForState:UIControlStateNormal] isEqualToString:self.feel];
        b.backgroundColor = on ? [GLTheme navy] : UIColor.whiteColor;
        [b setTitleColor:(on ? UIColor.whiteColor : [GLTheme ink]) forState:UIControlStateNormal];
        b.layer.borderWidth = on ? 0 : 1;
    }
}
- (void)slide {
    NSInteger v = (NSInteger)lroundf(self.slider.value);
    self.slider.value = v;
    NSArray<UILabel *> *labs = @[self.lean, self.bal, self.extra];
    for (NSInteger i = 0; i < 3; i++) {
        UILabel *lab = labs[i];
        lab.textColor = (i == v) ? [GLTheme purple] : [GLTheme sub];
        lab.font = (i == v) ? [GLTheme title:13] : [GLTheme medium:13];
    }
}
- (void)buildPlan {
    GLStore *s = [GLStore shared];
    s.gathering[@"feel"] = self.feel;
    s.gathering[@"mustHave"] = self.must.text;
    NSArray *budgets = @[@180, @280, @420];
    s.gathering[@"budget"] = budgets[(NSInteger)self.slider.value];
    s.onboarded = YES;
    [s notify];
    UIViewController *presenter = self.presentingViewController;
    while (presenter.presentingViewController) presenter = presenter.presentingViewController;
    [presenter dismissViewControllerAnimated:YES completion:^{
        SceneDelegate *sd = (SceneDelegate *)UIApplication.sharedApplication.connectedScenes.anyObject;
        if ([sd isKindOfClass:[SceneDelegate class]]) {
            [sd showMain];
        } else {
            for (UIWindowScene *ws in UIApplication.sharedApplication.connectedScenes) {
                if ([ws.delegate isKindOfClass:[SceneDelegate class]]) {
                    [(SceneDelegate *)ws.delegate showMain];
                    UIViewController *root = ((SceneDelegate *)ws.delegate).window.rootViewController;
                    if ([root isKindOfClass:[GLTabBarController class]]) {
                        UINavigationController *nav = ((GLTabBarController *)root).viewControllers.firstObject;
                        [nav pushViewController:[GLEventHubViewController new] animated:YES];
                    }
                }
            }
        }
    }];
}
- (void)close { [self dismissViewControllerAnimated:YES completion:nil]; }
@end
