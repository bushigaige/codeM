#import "GLHomeViewController.h"
#import "GLTheme.h"
#import "GLArt.h"
#import "GLStore.h"
#import "GLEventHubViewController.h"
#import "GLMemoriesViewController.h"
#import "GLCapsuleViewController.h"
#import "GLChatViewController.h"

@interface GLHomeViewController ()
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UIView *content;
@property (nonatomic, strong) UILabel *taskCount;
@property (nonatomic, strong) UILabel *budgetLeft;
@property (nonatomic, strong) UILabel *readyLabel;
@property (nonatomic, strong) UIView *progressFill;
@property (nonatomic, strong) NSLayoutConstraint *progressWidth;
@end

@implementation GLHomeViewController
- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleDarkContent; }
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [GLTheme bg];
    [self build];
    [self refresh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:GLStoreDidChangeNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }
- (void)push:(UIViewController *)vc {
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)build {
    self.scroll = [UIScrollView new];
    self.scroll.translatesAutoresizingMaskIntoConstraints = NO;
    self.scroll.alwaysBounceVertical = YES;
    self.scroll.showsVerticalScrollIndicator = NO;
    self.scroll.contentInset = UIEdgeInsetsMake(0, 0, 28, 0);
    self.scroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:self.scroll];
    self.content = [UIView new];
    self.content.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scroll addSubview:self.content];
    [NSLayoutConstraint activateConstraints:@[
        [self.scroll.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scroll.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [self.content.topAnchor constraintEqualToAnchor:self.scroll.contentLayoutGuide.topAnchor],
        [self.content.bottomAnchor constraintEqualToAnchor:self.scroll.contentLayoutGuide.bottomAnchor],
        [self.content.leadingAnchor constraintEqualToAnchor:self.scroll.frameLayoutGuide.leadingAnchor],
        [self.content.trailingAnchor constraintEqualToAnchor:self.scroll.frameLayoutGuide.trailingAnchor],
        [self.content.widthAnchor constraintEqualToAnchor:self.scroll.frameLayoutGuide.widthAnchor]
    ]];

    UILabel *date = [GLTheme label:@"Mon · Aug 31" font:[GLTheme medium:12] color:[GLTheme sub]];
    UILabel *hi = [GLTheme label:@"Good morning, Mia" font:[GLTheme display:28] color:[GLTheme ink]];
    GLAvatarView *av = [GLAvatarView initial:@"M" color:[GLTheme purple] size:44];
    av.layer.cornerRadius = 14;
    UIView *dot = [UIView new];
    dot.translatesAutoresizingMaskIntoConstraints = NO;
    dot.backgroundColor = [GLTheme hex:0x3DDC84];
    dot.layer.cornerRadius = 6;
    dot.layer.borderWidth = 2;
    dot.layer.borderColor = [GLTheme bg].CGColor;
    [av addSubview:dot];

    UIView *hero = [GLTheme card:28];
    GLSunsetView *art = [GLSunsetView new];
    art.translatesAutoresizingMaskIntoConstraints = NO;
    art.showPeople = NO;
    [hero addSubview:art];
    UIView *going = [GLTheme pill:@"18 going" bg:[UIColor colorWithWhite:0 alpha:0.45] fg:UIColor.whiteColor];
    UIView *lock = [GLTheme pill:@"Invite only" bg:[UIColor colorWithWhite:0 alpha:0.45] fg:UIColor.whiteColor];
    UILabel *next = [GLTheme label:@"Next gathering · in 5 days" font:[GLTheme medium:12] color:[GLTheme coral]];
    UILabel *name = [GLTheme label:@"Rooftop Sunset Club" font:[GLTheme title:22] color:[GLTheme ink]];
    UILabel *loc = [GLTheme label:@"Riverlight Terrace · 6:30 PM" font:[GLTheme regular:13] color:[GLTheme sub]];
    UIButton *go = [GLTheme circleSymbol:@"arrow.up.right" bg:[GLTheme navy] tint:UIColor.whiteColor size:44];
    [go addTarget:self action:@selector(openHub) forControlEvents:UIControlEventTouchUpInside];
    self.readyLabel = [GLTheme label:@"72% ready" font:[GLTheme medium:12] color:[GLTheme ink]];
    UILabel *frac = [GLTheme label:@"8 / 11" font:[GLTheme medium:12] color:[GLTheme sub]];
    UIView *track = [UIView new];
    track.translatesAutoresizingMaskIntoConstraints = NO;
    track.backgroundColor = [GLTheme line];
    track.layer.cornerRadius = 4;
    self.progressFill = [UIView new];
    self.progressFill.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressFill.backgroundColor = [GLTheme coral];
    self.progressFill.layer.cornerRadius = 4;
    [track addSubview:self.progressFill];
    self.progressWidth = [self.progressFill.widthAnchor constraintEqualToAnchor:track.widthAnchor multiplier:0.72];
    [hero addSubview:going];
    [hero addSubview:lock];
    [hero addSubview:next];
    [hero addSubview:name];
    [hero addSubview:loc];
    [hero addSubview:go];
    [hero addSubview:self.readyLabel];
    [hero addSubview:frac];
    [hero addSubview:track];

    UILabel *keep = [GLTheme label:@"Keep going" font:[GLTheme title:18] color:[GLTheme ink]];
    UIButton *viewPlan = [UIButton buttonWithType:UIButtonTypeSystem];
    viewPlan.translatesAutoresizingMaskIntoConstraints = NO;
    [viewPlan setTitle:@"View plan" forState:UIControlStateNormal];
    [viewPlan setTitleColor:[GLTheme purple] forState:UIControlStateNormal];
    viewPlan.titleLabel.font = [GLTheme medium:14];
    [viewPlan addTarget:self action:@selector(openHub) forControlEvents:UIControlEventTouchUpInside];

    UIButton *taskCard = [self miniCard:[GLTheme hex:0xDFF56A] icon:@"checklist" title:@"3 tasks left" sub:@"Pick a playlist" titleRef:&_taskCount];
    [taskCard addTarget:self action:@selector(openChat) forControlEvents:UIControlEventTouchUpInside];
    UIButton *budgetCard = [self miniCard:[GLTheme lavender] icon:@"creditcard" title:@"$124 left" sub:@"Shared budget" titleRef:&_budgetLeft];
    [budgetCard addTarget:self action:@selector(openHub) forControlEvents:UIControlEventTouchUpInside];
    UILabel *after = [GLTheme label:@"Recent afterglow" font:[GLTheme title:18] color:[GLTheme ink]];
    UIButton *allMem = [UIButton buttonWithType:UIButtonTypeSystem];
    allMem.translatesAutoresizingMaskIntoConstraints = NO;
    [allMem setTitle:@"All memories" forState:UIControlStateNormal];
    [allMem setTitleColor:[GLTheme purple] forState:UIControlStateNormal];
    allMem.titleLabel.font = [GLTheme medium:14];
    [allMem addTarget:self action:@selector(openMemoriesTab) forControlEvents:UIControlEventTouchUpInside];

    UIButton *pic = [self memoryCardSunset:@"27 moments" title:@"Sunday picnic"];
    [pic addTarget:self action:@selector(openMemory) forControlEvents:UIControlEventTouchUpInside];
    UIButton *cap = [self memoryCardDark:@"Unlocks Friday" title:@"June capsule"];
    [cap addTarget:self action:@selector(openCapsule) forControlEvents:UIControlEventTouchUpInside];

    NSArray *views = @[date, hi, av, hero, keep, viewPlan, taskCard, budgetCard, after, allMem, pic, cap];
    for (UIView *v in views) {
        v.translatesAutoresizingMaskIntoConstraints = NO;
        [self.content addSubview:v];
    }

    [NSLayoutConstraint activateConstraints:@[
        [date.topAnchor constraintEqualToAnchor:self.content.topAnchor constant:12],
        [date.leadingAnchor constraintEqualToAnchor:self.content.leadingAnchor constant:20],
        [hi.topAnchor constraintEqualToAnchor:date.bottomAnchor constant:4],
        [hi.leadingAnchor constraintEqualToAnchor:date.leadingAnchor],
        [hi.trailingAnchor constraintEqualToAnchor:av.leadingAnchor constant:-12],
        [av.centerYAnchor constraintEqualToAnchor:hi.centerYAnchor],
        [av.trailingAnchor constraintEqualToAnchor:self.content.trailingAnchor constant:-20],
        [dot.widthAnchor constraintEqualToConstant:12],
        [dot.heightAnchor constraintEqualToConstant:12],
        [dot.trailingAnchor constraintEqualToAnchor:av.trailingAnchor constant:2],
        [dot.bottomAnchor constraintEqualToAnchor:av.bottomAnchor constant:2],
        [hero.topAnchor constraintEqualToAnchor:hi.bottomAnchor constant:18],
        [hero.leadingAnchor constraintEqualToAnchor:self.content.leadingAnchor constant:16],
        [hero.trailingAnchor constraintEqualToAnchor:self.content.trailingAnchor constant:-16],
        [art.topAnchor constraintEqualToAnchor:hero.topAnchor],
        [art.leadingAnchor constraintEqualToAnchor:hero.leadingAnchor],
        [art.trailingAnchor constraintEqualToAnchor:hero.trailingAnchor],
        [art.heightAnchor constraintEqualToConstant:148],
        [going.leadingAnchor constraintEqualToAnchor:hero.leadingAnchor constant:14],
        [going.bottomAnchor constraintEqualToAnchor:art.bottomAnchor constant:-12],
        [lock.leadingAnchor constraintEqualToAnchor:going.trailingAnchor constant:8],
        [lock.centerYAnchor constraintEqualToAnchor:going.centerYAnchor],
        [next.topAnchor constraintEqualToAnchor:art.bottomAnchor constant:14],
        [next.leadingAnchor constraintEqualToAnchor:hero.leadingAnchor constant:16],
        [name.topAnchor constraintEqualToAnchor:next.bottomAnchor constant:6],
        [name.leadingAnchor constraintEqualToAnchor:next.leadingAnchor],
        [name.trailingAnchor constraintEqualToAnchor:go.leadingAnchor constant:-8],
        [loc.topAnchor constraintEqualToAnchor:name.bottomAnchor constant:4],
        [loc.leadingAnchor constraintEqualToAnchor:name.leadingAnchor],
        [go.centerYAnchor constraintEqualToAnchor:name.centerYAnchor],
        [go.trailingAnchor constraintEqualToAnchor:hero.trailingAnchor constant:-16],
        [self.readyLabel.topAnchor constraintEqualToAnchor:loc.bottomAnchor constant:16],
        [self.readyLabel.leadingAnchor constraintEqualToAnchor:name.leadingAnchor],
        [frac.centerYAnchor constraintEqualToAnchor:self.readyLabel.centerYAnchor],
        [frac.trailingAnchor constraintEqualToAnchor:hero.trailingAnchor constant:-16],
        [track.topAnchor constraintEqualToAnchor:self.readyLabel.bottomAnchor constant:8],
        [track.leadingAnchor constraintEqualToAnchor:hero.leadingAnchor constant:16],
        [track.trailingAnchor constraintEqualToAnchor:hero.trailingAnchor constant:-16],
        [track.heightAnchor constraintEqualToConstant:8],
        [track.bottomAnchor constraintEqualToAnchor:hero.bottomAnchor constant:-16],
        [self.progressFill.leadingAnchor constraintEqualToAnchor:track.leadingAnchor],
        [self.progressFill.topAnchor constraintEqualToAnchor:track.topAnchor],
        [self.progressFill.bottomAnchor constraintEqualToAnchor:track.bottomAnchor],
        self.progressWidth,
        [keep.topAnchor constraintEqualToAnchor:hero.bottomAnchor constant:22],
        [keep.leadingAnchor constraintEqualToAnchor:hero.leadingAnchor],
        [viewPlan.centerYAnchor constraintEqualToAnchor:keep.centerYAnchor],
        [viewPlan.trailingAnchor constraintEqualToAnchor:hero.trailingAnchor],
        [taskCard.topAnchor constraintEqualToAnchor:keep.bottomAnchor constant:12],
        [taskCard.leadingAnchor constraintEqualToAnchor:hero.leadingAnchor],
        [taskCard.trailingAnchor constraintEqualToAnchor:self.content.centerXAnchor constant:-6],
        [taskCard.heightAnchor constraintEqualToConstant:108],
        [budgetCard.topAnchor constraintEqualToAnchor:taskCard.topAnchor],
        [budgetCard.leadingAnchor constraintEqualToAnchor:self.content.centerXAnchor constant:6],
        [budgetCard.trailingAnchor constraintEqualToAnchor:hero.trailingAnchor],
        [budgetCard.heightAnchor constraintEqualToAnchor:taskCard.heightAnchor],
        [after.topAnchor constraintEqualToAnchor:taskCard.bottomAnchor constant:22],
        [after.leadingAnchor constraintEqualToAnchor:keep.leadingAnchor],
        [allMem.centerYAnchor constraintEqualToAnchor:after.centerYAnchor],
        [allMem.trailingAnchor constraintEqualToAnchor:viewPlan.trailingAnchor],
        [pic.topAnchor constraintEqualToAnchor:after.bottomAnchor constant:12],
        [pic.leadingAnchor constraintEqualToAnchor:taskCard.leadingAnchor],
        [pic.trailingAnchor constraintEqualToAnchor:taskCard.trailingAnchor],
        [pic.heightAnchor constraintEqualToConstant:150],
        [cap.topAnchor constraintEqualToAnchor:pic.topAnchor],
        [cap.leadingAnchor constraintEqualToAnchor:budgetCard.leadingAnchor],
        [cap.trailingAnchor constraintEqualToAnchor:budgetCard.trailingAnchor],
        [cap.heightAnchor constraintEqualToAnchor:pic.heightAnchor],
        [pic.bottomAnchor constraintEqualToAnchor:self.content.bottomAnchor constant:-24]
    ]];
}
- (UIButton *)miniCard:(UIColor *)bg icon:(NSString *)icon title:(NSString *)title sub:(NSString *)sub titleRef:(UILabel * __strong *)ref {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.translatesAutoresizingMaskIntoConstraints = NO;
    b.backgroundColor = bg;
    b.layer.cornerRadius = 22;
    UIView *box = [GLTheme iconBox:icon bg:[UIColor colorWithWhite:1 alpha:0.45] tint:[GLTheme ink] size:32 radius:10];
    box.userInteractionEnabled = NO;
    UILabel *t = [GLTheme label:title font:[GLTheme title:16] color:[GLTheme ink]];
    t.userInteractionEnabled = NO;
    UILabel *s = [GLTheme label:sub font:[GLTheme regular:12] color:[GLTheme ink]];
    s.alpha = 0.7;
    UIImageView *ch = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    ch.translatesAutoresizingMaskIntoConstraints = NO;
    ch.tintColor = [GLTheme ink];
    [b addSubview:box];
    [b addSubview:t];
    [b addSubview:s];
    [b addSubview:ch];
    [NSLayoutConstraint activateConstraints:@[
        [box.topAnchor constraintEqualToAnchor:b.topAnchor constant:14],
        [box.leadingAnchor constraintEqualToAnchor:b.leadingAnchor constant:14],
        [t.topAnchor constraintEqualToAnchor:box.bottomAnchor constant:12],
        [t.leadingAnchor constraintEqualToAnchor:box.leadingAnchor],
        [s.topAnchor constraintEqualToAnchor:t.bottomAnchor constant:2],
        [s.leadingAnchor constraintEqualToAnchor:t.leadingAnchor],
        [ch.trailingAnchor constraintEqualToAnchor:b.trailingAnchor constant:-12],
        [ch.bottomAnchor constraintEqualToAnchor:b.bottomAnchor constant:-14]
    ]];
    if (ref) *ref = t;
    return b;
}
- (UIButton *)memoryCardSunset:(NSString *)meta title:(NSString *)title {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.layer.cornerRadius = 22;
    b.clipsToBounds = YES;
    GLSunsetView *art = [GLSunsetView new];
    art.translatesAutoresizingMaskIntoConstraints = NO;
    art.compact = YES;
    art.showPeople = NO;
    art.userInteractionEnabled = NO;
    [b addSubview:art];
    [GLTheme pin:art to:b insets:UIEdgeInsetsZero];
    UILabel *m = [GLTheme label:meta font:[GLTheme regular:11] color:[UIColor colorWithWhite:1 alpha:0.85]];
    UILabel *t = [GLTheme label:title font:[GLTheme title:16] color:UIColor.whiteColor];
    [b addSubview:m];
    [b addSubview:t];
    [NSLayoutConstraint activateConstraints:@[
        [m.leadingAnchor constraintEqualToAnchor:b.leadingAnchor constant:12],
        [m.bottomAnchor constraintEqualToAnchor:t.topAnchor constant:-2],
        [t.leadingAnchor constraintEqualToAnchor:m.leadingAnchor],
        [t.bottomAnchor constraintEqualToAnchor:b.bottomAnchor constant:-12]
    ]];
    return b;
}
- (UIButton *)memoryCardDark:(NSString *)meta title:(NSString *)title {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.layer.cornerRadius = 22;
    b.clipsToBounds = YES;
    b.backgroundColor = [GLTheme hex:0x3A2B7A];
    UILabel *m = [GLTheme label:meta font:[GLTheme regular:11] color:[UIColor colorWithWhite:1 alpha:0.75]];
    UILabel *t = [GLTheme label:title font:[GLTheme title:16] color:UIColor.whiteColor];
    [b addSubview:m];
    [b addSubview:t];
    [NSLayoutConstraint activateConstraints:@[
        [m.leadingAnchor constraintEqualToAnchor:b.leadingAnchor constant:12],
        [m.bottomAnchor constraintEqualToAnchor:t.topAnchor constant:-2],
        [t.leadingAnchor constraintEqualToAnchor:m.leadingAnchor],
        [t.bottomAnchor constraintEqualToAnchor:b.bottomAnchor constant:-12]
    ]];
    return b;
}
- (void)refresh {
    GLStore *s = [GLStore shared];
    self.taskCount.text = [NSString stringWithFormat:@"%ld tasks left", (long)s.openTaskCount];
    NSInteger left = [s.gathering[@"budget"] integerValue] - s.spentAmount;
    self.budgetLeft.text = [NSString stringWithFormat:@"$%ld left", (long)left];
    NSInteger total = MAX(1, (NSInteger)s.tasks.count);
    CGFloat p = (CGFloat)s.readyCount / total;
    self.readyLabel.text = [NSString stringWithFormat:@"%.0f%% ready", p * 100];
}
- (void)openHub { [self push:[GLEventHubViewController new]]; }
- (void)openChat { [self push:[GLChatViewController new]]; }
- (void)openMemory { [self push:[GLMemoriesViewController new]]; }
- (void)openCapsule { [self push:[GLCapsuleViewController new]]; }
- (void)openMemoriesTab { self.tabBarController.selectedIndex = 3; }
@end
