#import "GLEventHubViewController.h"
#import "GLTheme.h"
#import "GLArt.h"
#import "GLStore.h"
#import "GLLiveViewController.h"
#import "GLChatViewController.h"

@interface GLEventHubViewController ()
@property (nonatomic) NSInteger tab;
@property (nonatomic, strong) UIView *underline;
@property (nonatomic, strong) NSLayoutConstraint *underlineX;
@property (nonatomic, strong) NSLayoutConstraint *backTop;
@property (nonatomic, strong) NSLayoutConstraint *heroHeight;
@property (nonatomic, strong) UIStackView *planStack;
@property (nonatomic, strong) UIStackView *peopleStack;
@property (nonatomic, strong) UIStackView *momentsStack;
@property (nonatomic, strong) UIButton *planBtn;
@property (nonatomic, strong) UIButton *peopleBtn;
@property (nonatomic, strong) UIButton *momentsBtn;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIButton *moreBtn;
@end

@implementation GLEventHubViewController
- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
- (BOOL)prefersStatusBarHidden { return NO; }
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [GLTheme bg];
    self.tab = 0;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self build];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebuildLists) name:GLStoreDidChangeNotification object:nil];
}
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIView *hero = [self.view viewWithTag:50];
    [GLTheme gradient:hero colors:@[[GLTheme hex:0x5B3DFF], [GLTheme hex:0xFF8A5C]] start:CGPointMake(0, 0) end:CGPointMake(1, 1)];
    CGFloat top = self.view.safeAreaInsets.top;
    if (top < 20) top = 44; // fallback before insets settle
    self.backTop.constant = top + 8;
    self.heroHeight.constant = 260 + top;
    [self.view bringSubviewToFront:self.backBtn];
    [self.view bringSubviewToFront:self.shareBtn];
    [self.view bringSubviewToFront:self.moreBtn];
}
- (void)build {
    UIScrollView *scroll = [UIScrollView new];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    scroll.alwaysBounceVertical = YES;
    scroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:scroll];
    UIView *c = [UIView new];
    c.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:c];

    UIView *hero = [UIView new];
    hero.translatesAutoresizingMaskIntoConstraints = NO;
    hero.tag = 50;
    hero.clipsToBounds = YES;
    GLSunsetView *art = [GLSunsetView new];
    art.translatesAutoresizingMaskIntoConstraints = NO;
    art.showPeople = NO;
    [hero addSubview:art];
    self.backBtn = [GLTheme circleSymbol:@"chevron.left" bg:[UIColor colorWithWhite:0 alpha:0.28] tint:UIColor.whiteColor size:36];
    [self.backBtn addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    self.shareBtn = [GLTheme circleSymbol:@"square.and.arrow.up" bg:[UIColor colorWithWhite:0 alpha:0.28] tint:UIColor.whiteColor size:36];
    [self.shareBtn addTarget:self action:@selector(invite) forControlEvents:UIControlEventTouchUpInside];
    self.moreBtn = [GLTheme circleSymbol:@"ellipsis" bg:[UIColor colorWithWhite:0 alpha:0.28] tint:UIColor.whiteColor size:36];
    [self.moreBtn addTarget:self action:@selector(more) forControlEvents:UIControlEventTouchUpInside];
    UILabel *when = [GLTheme label:@"In 5 days · Invite only" font:[GLTheme medium:11] color:UIColor.whiteColor];
    UILabel *title = [GLTheme label:[GLStore shared].gathering[@"name"] font:[GLTheme display:28] color:UIColor.whiteColor];
    title.numberOfLines = 0;
    UILabel *loc = [GLTheme label:[NSString stringWithFormat:@"📍  %@", [GLStore shared].gathering[@"location"]] font:[GLTheme regular:14] color:UIColor.whiteColor];
    [hero addSubview:when]; [hero addSubview:title]; [hero addSubview:loc];

    UIView *stats = [GLTheme card:22];
    UILabel *g = [self stat:[NSString stringWithFormat:@"%@", [GLStore shared].gathering[@"guestCount"]] sub:@"Going"];
    UILabel *r = [self stat:@"72%" sub:@"Ready"];
    r.tag = 71;
    UILabel *s = [self stat:[NSString stringWithFormat:@"$%ld", (long)[GLStore shared].spentAmount] sub:@"Spent"];
    UIButton *inv = [GLTheme fillButton:@"  Invite" bg:[GLTheme coral] fg:UIColor.whiteColor radius:18];
    [inv setImage:[UIImage systemImageNamed:@"person.badge.plus"] forState:UIControlStateNormal];
    inv.tintColor = UIColor.whiteColor;
    [inv addTarget:self action:@selector(invite) forControlEvents:UIControlEventTouchUpInside];
    [stats addSubview:g]; [stats addSubview:r]; [stats addSubview:s]; [stats addSubview:inv];

    self.planBtn = [self tabBtn:@"Plan"];
    self.peopleBtn = [self tabBtn:@"People"];
    self.momentsBtn = [self tabBtn:@"Moments 3"];
    self.planBtn.tag = 0; self.peopleBtn.tag = 1; self.momentsBtn.tag = 2;
    [self.planBtn addTarget:self action:@selector(switchTab:) forControlEvents:UIControlEventTouchUpInside];
    [self.peopleBtn addTarget:self action:@selector(switchTab:) forControlEvents:UIControlEventTouchUpInside];
    [self.momentsBtn addTarget:self action:@selector(switchTab:) forControlEvents:UIControlEventTouchUpInside];
    self.underline = [UIView new];
    self.underline.translatesAutoresizingMaskIntoConstraints = NO;
    self.underline.backgroundColor = [GLTheme coral];
    self.underline.layer.cornerRadius = 2;

    UILabel *tl = [GLTheme label:@"Saturday schedule" font:[GLTheme title:18] color:[GLTheme ink]];
    UIButton *add = [UIButton buttonWithType:UIButtonTypeSystem];
    add.translatesAutoresizingMaskIntoConstraints = NO;
    [add setTitle:@"+ Add" forState:UIControlStateNormal];
    [add setTitleColor:[GLTheme purple] forState:UIControlStateNormal];
    add.titleLabel.font = [GLTheme medium:14];
    [add addTarget:self action:@selector(addItem) forControlEvents:UIControlEventTouchUpInside];

    self.planStack = [UIStackView new];
    self.planStack.translatesAutoresizingMaskIntoConstraints = NO;
    self.planStack.axis = UILayoutConstraintAxisVertical;
    self.planStack.spacing = 10;
    self.peopleStack = [UIStackView new];
    self.peopleStack.translatesAutoresizingMaskIntoConstraints = NO;
    self.peopleStack.axis = UILayoutConstraintAxisVertical;
    self.peopleStack.spacing = 10;
    self.peopleStack.hidden = YES;
    self.momentsStack = [UIStackView new];
    self.momentsStack.translatesAutoresizingMaskIntoConstraints = NO;
    self.momentsStack.axis = UILayoutConstraintAxisVertical;
    self.momentsStack.spacing = 10;
    self.momentsStack.hidden = YES;

    [self.view addSubview:scroll];
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.shareBtn];
    [self.view addSubview:self.moreBtn];
    [c addSubview:hero]; [c addSubview:stats];
    [c addSubview:self.planBtn]; [c addSubview:self.peopleBtn]; [c addSubview:self.momentsBtn]; [c addSubview:self.underline];
    [c addSubview:tl]; [c addSubview:add];
    [c addSubview:self.planStack]; [c addSubview:self.peopleStack]; [c addSubview:self.momentsStack];

    self.backTop = [self.backBtn.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:54];
    self.heroHeight = [hero.heightAnchor constraintEqualToConstant:320];

    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [c.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor],
        [c.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor],
        [c.leadingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.leadingAnchor],
        [c.trailingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.trailingAnchor],
        [c.widthAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.widthAnchor],
        [hero.topAnchor constraintEqualToAnchor:c.topAnchor],
        [hero.leadingAnchor constraintEqualToAnchor:c.leadingAnchor],
        [hero.trailingAnchor constraintEqualToAnchor:c.trailingAnchor],
        self.heroHeight,
        [art.topAnchor constraintEqualToAnchor:hero.topAnchor],
        [art.leadingAnchor constraintEqualToAnchor:hero.leadingAnchor],
        [art.trailingAnchor constraintEqualToAnchor:hero.trailingAnchor],
        [art.bottomAnchor constraintEqualToAnchor:hero.bottomAnchor],
        self.backTop,
        [self.backBtn.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.moreBtn.centerYAnchor constraintEqualToAnchor:self.backBtn.centerYAnchor],
        [self.moreBtn.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.shareBtn.centerYAnchor constraintEqualToAnchor:self.backBtn.centerYAnchor],
        [self.shareBtn.trailingAnchor constraintEqualToAnchor:self.moreBtn.leadingAnchor constant:-8],
        [when.leadingAnchor constraintEqualToAnchor:hero.leadingAnchor constant:20],
        [when.bottomAnchor constraintEqualToAnchor:title.topAnchor constant:-6],
        [title.leadingAnchor constraintEqualToAnchor:when.leadingAnchor],
        [title.trailingAnchor constraintEqualToAnchor:hero.trailingAnchor constant:-20],
        [title.bottomAnchor constraintEqualToAnchor:loc.topAnchor constant:-4],
        [loc.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [loc.bottomAnchor constraintEqualToAnchor:hero.bottomAnchor constant:-28],
        [stats.topAnchor constraintEqualToAnchor:hero.bottomAnchor constant:-22],
        [stats.leadingAnchor constraintEqualToAnchor:c.leadingAnchor constant:16],
        [stats.trailingAnchor constraintEqualToAnchor:c.trailingAnchor constant:-16],
        [g.leadingAnchor constraintEqualToAnchor:stats.leadingAnchor constant:16],
        [g.topAnchor constraintEqualToAnchor:stats.topAnchor constant:14],
        [g.bottomAnchor constraintEqualToAnchor:stats.bottomAnchor constant:-14],
        [r.leadingAnchor constraintEqualToAnchor:g.trailingAnchor constant:18],
        [r.centerYAnchor constraintEqualToAnchor:g.centerYAnchor],
        [s.leadingAnchor constraintEqualToAnchor:r.trailingAnchor constant:18],
        [s.centerYAnchor constraintEqualToAnchor:g.centerYAnchor],
        [inv.trailingAnchor constraintEqualToAnchor:stats.trailingAnchor constant:-12],
        [inv.centerYAnchor constraintEqualToAnchor:g.centerYAnchor],
        [inv.widthAnchor constraintEqualToConstant:108],
        [inv.heightAnchor constraintEqualToConstant:42],
        [self.planBtn.topAnchor constraintEqualToAnchor:stats.bottomAnchor constant:18],
        [self.planBtn.leadingAnchor constraintEqualToAnchor:stats.leadingAnchor],
        [self.peopleBtn.centerYAnchor constraintEqualToAnchor:self.planBtn.centerYAnchor],
        [self.peopleBtn.leadingAnchor constraintEqualToAnchor:self.planBtn.trailingAnchor constant:22],
        [self.momentsBtn.centerYAnchor constraintEqualToAnchor:self.planBtn.centerYAnchor],
        [self.momentsBtn.leadingAnchor constraintEqualToAnchor:self.peopleBtn.trailingAnchor constant:22],
        [self.underline.topAnchor constraintEqualToAnchor:self.planBtn.bottomAnchor constant:4],
        [self.underline.heightAnchor constraintEqualToConstant:3],
        [self.underline.widthAnchor constraintEqualToConstant:28],
        [tl.topAnchor constraintEqualToAnchor:self.underline.bottomAnchor constant:18],
        [tl.leadingAnchor constraintEqualToAnchor:stats.leadingAnchor],
        [add.centerYAnchor constraintEqualToAnchor:tl.centerYAnchor],
        [add.trailingAnchor constraintEqualToAnchor:stats.trailingAnchor],
        [self.planStack.topAnchor constraintEqualToAnchor:tl.bottomAnchor constant:12],
        [self.planStack.leadingAnchor constraintEqualToAnchor:stats.leadingAnchor],
        [self.planStack.trailingAnchor constraintEqualToAnchor:stats.trailingAnchor],
        [self.peopleStack.topAnchor constraintEqualToAnchor:self.planStack.topAnchor],
        [self.peopleStack.leadingAnchor constraintEqualToAnchor:self.planStack.leadingAnchor],
        [self.peopleStack.trailingAnchor constraintEqualToAnchor:self.planStack.trailingAnchor],
        [self.momentsStack.topAnchor constraintEqualToAnchor:self.planStack.topAnchor],
        [self.momentsStack.leadingAnchor constraintEqualToAnchor:self.planStack.leadingAnchor],
        [self.momentsStack.trailingAnchor constraintEqualToAnchor:self.planStack.trailingAnchor],
        [self.planStack.bottomAnchor constraintEqualToAnchor:c.bottomAnchor constant:-24]
    ]];
    self.underlineX = [self.underline.centerXAnchor constraintEqualToAnchor:self.planBtn.centerXAnchor];
    self.underlineX.active = YES;
    [self rebuildLists];
}
- (UILabel *)stat:(NSString *)v sub:(NSString *)sub {
    UILabel *l = [GLTheme label:[NSString stringWithFormat:@"%@\n%@", v, sub] font:[GLTheme title:20] color:[GLTheme ink]];
    l.numberOfLines = 2;
    NSMutableAttributedString *a = [[NSMutableAttributedString alloc] initWithString:v attributes:@{NSFontAttributeName:[GLTheme title:20], NSForegroundColorAttributeName:[GLTheme ink]}];
    [a appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", sub] attributes:@{NSFontAttributeName:[GLTheme regular:12], NSForegroundColorAttributeName:[GLTheme sub]}]];
    l.attributedText = a;
    return l;
}
- (UIButton *)tabBtn:(NSString *)t {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.translatesAutoresizingMaskIntoConstraints = NO;
    [b setTitle:t forState:UIControlStateNormal];
    [b setTitleColor:[GLTheme ink] forState:UIControlStateNormal];
    b.titleLabel.font = [GLTheme title:16];
    return b;
}
- (void)rebuildLists {
    for (UIView *v in self.planStack.arrangedSubviews) [self.planStack removeArrangedSubview:v], [v removeFromSuperview];
    GLStore *s = [GLStore shared];
    for (NSDictionary *it in s.timeline) {
        UIButton *row = [UIButton buttonWithType:UIButtonTypeCustom];
        row.backgroundColor = UIColor.whiteColor;
        row.layer.cornerRadius = 18;
        row.layer.borderWidth = 1;
        row.layer.borderColor = [GLTheme softPurple].CGColor;
        UILabel *tm = [GLTheme label:it[@"time"] font:[GLTheme title:18] color:[GLTheme ink]];
        UILabel *ap = [GLTheme label:it[@"ampm"] font:[GLTheme medium:11] color:[GLTheme sub]];
        UILabel *cat = [GLTheme label:it[@"cat"] font:[GLTheme medium:10] color:[GLTheme sub]];
        UILabel *tt = [GLTheme label:[NSString stringWithFormat:@"●  %@", it[@"title"]] font:[GLTheme title:14] color:[GLTheme ink]];
        UILabel *d = [GLTheme label:it[@"detail"] font:[GLTheme regular:12] color:[GLTheme sub]];
        for (UIView *x in @[tm, ap, cat, tt, d]) { x.userInteractionEnabled = NO; [row addSubview:x]; }
        [NSLayoutConstraint activateConstraints:@[
            [row.heightAnchor constraintGreaterThanOrEqualToConstant:78],
            [tm.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:14],
            [tm.topAnchor constraintEqualToAnchor:row.topAnchor constant:14],
            [ap.topAnchor constraintEqualToAnchor:tm.bottomAnchor],
            [ap.leadingAnchor constraintEqualToAnchor:tm.leadingAnchor],
            [cat.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:78],
            [cat.topAnchor constraintEqualToAnchor:row.topAnchor constant:12],
            [tt.leadingAnchor constraintEqualToAnchor:cat.leadingAnchor],
            [tt.topAnchor constraintEqualToAnchor:cat.bottomAnchor constant:4],
            [tt.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-28],
            [d.leadingAnchor constraintEqualToAnchor:cat.leadingAnchor],
            [d.topAnchor constraintEqualToAnchor:tt.bottomAnchor constant:2],
            [d.bottomAnchor constraintEqualToAnchor:row.bottomAnchor constant:-12]
        ]];
        [row addTarget:self action:@selector(openLive) forControlEvents:UIControlEventTouchUpInside];
        [self.planStack addArrangedSubview:row];
    }
    UILabel *ot = [GLTheme label:@"Open tasks" font:[GLTheme title:18] color:[GLTheme ink]];
    [self.planStack addArrangedSubview:ot];
    [s.tasks enumerateObjectsUsingBlock:^(NSMutableDictionary *t, NSUInteger idx, BOOL *stop) {
        UIButton *row = [UIButton buttonWithType:UIButtonTypeCustom];
        row.tag = (NSInteger)idx;
        [row addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventTouchUpInside];
        UIView *box = [UIView new];
        box.translatesAutoresizingMaskIntoConstraints = NO;
        box.layer.cornerRadius = 6;
        box.layer.borderWidth = 1.5;
        BOOL done = [t[@"done"] boolValue];
        box.backgroundColor = done ? [GLTheme mint] : UIColor.clearColor;
        box.layer.borderColor = done ? [GLTheme mint].CGColor : [GLTheme line].CGColor;
        box.userInteractionEnabled = NO;
        UILabel *tt = [GLTheme label:t[@"title"] font:[GLTheme title:14] color:[GLTheme ink]];
        UILabel *sub = [GLTheme label:[NSString stringWithFormat:@"Assigned to %@ · %@", t[@"who"], t[@"when"]] font:[GLTheme regular:12] color:[GLTheme sub]];
        UIColor *tagBg = [t[@"tagTone"] isEqualToString:@"food"] ? [GLTheme hex:0xF6E7A1] : [GLTheme lavender];
        UIView *tag = [GLTheme pill:t[@"tag"] bg:tagBg fg:[GLTheme ink]];
        tag.userInteractionEnabled = NO;
        [row addSubview:box]; [row addSubview:tt]; [row addSubview:sub]; [row addSubview:tag];
        [NSLayoutConstraint activateConstraints:@[
            [row.heightAnchor constraintEqualToConstant:64],
            [box.leadingAnchor constraintEqualToAnchor:row.leadingAnchor],
            [box.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
            [box.widthAnchor constraintEqualToConstant:22],
            [box.heightAnchor constraintEqualToConstant:22],
            [tt.leadingAnchor constraintEqualToAnchor:box.trailingAnchor constant:12],
            [tt.topAnchor constraintEqualToAnchor:row.topAnchor constant:12],
            [sub.leadingAnchor constraintEqualToAnchor:tt.leadingAnchor],
            [sub.topAnchor constraintEqualToAnchor:tt.bottomAnchor constant:2],
            [tag.trailingAnchor constraintEqualToAnchor:row.trailingAnchor],
            [tag.centerYAnchor constraintEqualToAnchor:row.centerYAnchor]
        ]];
        [self.planStack addArrangedSubview:row];
    }];

    for (UIView *v in self.peopleStack.arrangedSubviews) [self.peopleStack removeArrangedSubview:v], [v removeFromSuperview];
    for (NSDictionary *g in s.guests) {
        UIView *row = [GLTheme card:16];
        UIColor *col = [g[@"color"] isEqualToString:@"orange"] ? [GLTheme coral] : ([g[@"color"] isEqualToString:@"teal"] ? [GLTheme mint] : [GLTheme purple]);
        GLAvatarView *av = [GLAvatarView initial:g[@"initial"] color:col size:40];
        UILabel *n = [GLTheme label:g[@"name"] font:[GLTheme title:15] color:[GLTheme ink]];
        UILabel *r = [GLTheme label:g[@"role"] font:[GLTheme regular:12] color:[GLTheme sub]];
        [row addSubview:av]; [row addSubview:n]; [row addSubview:r];
        [NSLayoutConstraint activateConstraints:@[
            [row.heightAnchor constraintEqualToConstant:64],
            [av.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:12],
            [av.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
            [n.leadingAnchor constraintEqualToAnchor:av.trailingAnchor constant:10],
            [n.topAnchor constraintEqualToAnchor:row.topAnchor constant:12],
            [r.leadingAnchor constraintEqualToAnchor:n.leadingAnchor],
            [r.topAnchor constraintEqualToAnchor:n.bottomAnchor constant:2]
        ]];
        [self.peopleStack addArrangedSubview:row];
    }
    for (UIView *v in self.momentsStack.arrangedSubviews) [self.momentsStack removeArrangedSubview:v], [v removeFromSuperview];
    for (NSDictionary *m in s.moments) {
        UIView *row = [GLTheme card:16];
        UILabel *t = [GLTheme label:m[@"title"] font:[GLTheme title:15] color:[GLTheme ink]];
        UILabel *tm = [GLTheme label:m[@"time"] font:[GLTheme regular:12] color:[GLTheme sub]];
        [row addSubview:t]; [row addSubview:tm];
        [NSLayoutConstraint activateConstraints:@[
            [row.heightAnchor constraintEqualToConstant:64],
            [t.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:14],
            [t.topAnchor constraintEqualToAnchor:row.topAnchor constant:12],
            [tm.leadingAnchor constraintEqualToAnchor:t.leadingAnchor],
            [tm.topAnchor constraintEqualToAnchor:t.bottomAnchor constant:2]
        ]];
        [self.momentsStack addArrangedSubview:row];
    }
}
- (void)switchTab:(UIButton *)b {
    self.tab = b.tag;
    self.planStack.hidden = self.tab != 0;
    self.peopleStack.hidden = self.tab != 1;
    self.momentsStack.hidden = self.tab != 2;
    self.underlineX.active = NO;
    UIButton *t = self.tab == 0 ? self.planBtn : (self.tab == 1 ? self.peopleBtn : self.momentsBtn);
    self.underlineX = [self.underline.centerXAnchor constraintEqualToAnchor:t.centerXAnchor];
    self.underlineX.active = YES;
    [self.view layoutIfNeeded];
}
- (void)toggle:(UIButton *)b { [[GLStore shared] toggleTaskAt:b.tag]; }
- (void)openLive { [self.navigationController pushViewController:[GLLiveViewController new] animated:YES]; }
- (void)invite {
    NSString *text = [NSString stringWithFormat:@"Join %@ at %@. Invite code: SUNSET", [GLStore shared].gathering[@"name"], [GLStore shared].gathering[@"location"]];
    UIActivityViewController *a = [[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:nil];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)more {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:[GLStore shared].gathering[@"name"] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [a addAction:[UIAlertAction actionWithTitle:@"Open crew chat" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.navigationController pushViewController:[GLChatViewController new] animated:YES];
    }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Go live" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { [self openLive]; }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)addItem {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Add schedule item" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Title"; }];
    [a addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [a addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *t = a.textFields.firstObject.text;
        if (t.length == 0) return;
        [[GLStore shared].timeline addObject:[@{@"time":@"8:00", @"ampm":@"PM", @"cat":@"Custom", @"title":t, @"detail":@"Added by Mia", @"kind":@"custom"} mutableCopy]];
        [[GLStore shared] notify];
    }]];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)pop { [self.navigationController popViewControllerAnimated:YES]; }
@end
