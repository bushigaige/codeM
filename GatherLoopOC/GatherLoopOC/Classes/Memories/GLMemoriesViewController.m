#import "GLMemoriesViewController.h"
#import "GLTheme.h"
#import "GLArt.h"
#import "GLStore.h"
#import "GLCapsuleViewController.h"

@interface GLMemoriesViewController ()
@property (nonatomic, strong) UIButton *backButton;
@end

@implementation GLMemoriesViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [GLTheme bg];

    UIView *c = nil;
    UIScrollView *scroll = [GLTheme embedScrollIn:self.view
                                          content:&c
                                              top:self.view.safeAreaLayoutGuide.topAnchor
                                           bottom:self.view.safeAreaLayoutGuide.bottomAnchor];
    scroll.contentInset = UIEdgeInsetsMake(0, 0, 36, 0);

    self.backButton = [GLTheme circleSymbol:@"chevron.left" bg:UIColor.whiteColor tint:[GLTheme ink] size:36];
    [self.backButton addTarget:self action:@selector(backOrIgnore) forControlEvents:UIControlEventTouchUpInside];
    UIButton *share = [GLTheme circleSymbol:@"square.and.arrow.up" bg:UIColor.whiteColor tint:[GLTheme ink] size:36];
    [share addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];

    UIView *leftSlot = [UIView new];
    leftSlot.translatesAutoresizingMaskIntoConstraints = NO;
    [leftSlot addSubview:self.backButton];
    UILabel *date = [GLTheme label:@"Sat · Sep 5" font:[GLTheme medium:11] color:[GLTheme sub]];
    date.textAlignment = NSTextAlignmentCenter;
    UILabel *navTitle = [GLTheme label:@"Rooftop Sunset" font:[GLTheme title:16] color:[GLTheme ink]];
    navTitle.textAlignment = NSTextAlignmentCenter;
    UIStackView *titles = [GLTheme column:@[date, navTitle] spacing:2];
    titles.alignment = UIStackViewAlignmentCenter;

    UIStackView *nav = [[UIStackView alloc] initWithArrangedSubviews:@[leftSlot, titles, share]];
    nav.translatesAutoresizingMaskIntoConstraints = NO;
    nav.axis = UILayoutConstraintAxisHorizontal;
    nav.alignment = UIStackViewAlignmentCenter;
    nav.spacing = 8;

    UILabel *over = [GLTheme label:@"Your shared afterglow" font:[GLTheme medium:11] color:[GLTheme purple]];
    UILabel *h = [GLTheme label:@"One sunset, eighteen perspectives." font:[GLTheme display:28] color:[GLTheme ink]];
    h.numberOfLines = 0;
    UILabel *body = [GLTheme label:@"GatherLoop turned photos, notes, and voice into a private recap." font:[GLTheme regular:14] color:[GLTheme sub]];
    body.numberOfLines = 0;
    UILabel *stats = [GLTheme label:@"42 moments    11 people    6 voice notes" font:[GLTheme medium:14] color:[GLTheme ink]];

    UIView *photo = [GLTheme card:24];
    GLSunsetView *art = [GLSunsetView new];
    art.translatesAutoresizingMaskIntoConstraints = NO;
    art.showPeople = NO;
    art.userInteractionEnabled = NO;
    [photo addSubview:art];
    UILabel *pt = [GLTheme label:@"7:24 PM\nToast time" font:[GLTheme title:16] color:UIColor.whiteColor];
    pt.numberOfLines = 2;
    [photo addSubview:pt];

    UIView *quote = [GLTheme card:24];
    quote.backgroundColor = [GLTheme lime];
    UILabel *q = [GLTheme label:@"\"Nobody wanted that sky to end.\"" font:[GLTheme title:16] color:[GLTheme ink]];
    q.numberOfLines = 0;
    UILabel *ava = [GLTheme label:@"AVA" font:[GLTheme medium:11] color:[GLTheme ink]];
    [quote addSubview:q];
    [quote addSubview:ava];

    UIView *audio = [GLTheme card:24];
    audio.backgroundColor = [GLTheme purple];
    UIButton *play = [GLTheme circleSymbol:@"play.fill" bg:[GLTheme lime] tint:[GLTheme ink] size:52];
    [play addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    UILabel *dur = [GLTheme label:@"0:18" font:[GLTheme medium:13] color:UIColor.whiteColor];
    dur.textAlignment = NSTextAlignmentCenter;
    [audio addSubview:play];
    [audio addSubview:dur];

    UIStackView *right = [GLTheme column:@[quote, audio] spacing:10];
    UIStackView *row1 = [[UIStackView alloc] initWithArrangedSubviews:@[photo, right]];
    row1.translatesAutoresizingMaskIntoConstraints = NO;
    row1.axis = UILayoutConstraintAxisHorizontal;
    row1.spacing = 10;
    row1.distribution = UIStackViewDistributionFillEqually;
    row1.alignment = UIStackViewAlignmentFill;

    UIView *wide = [self tileBg:[GLTheme hex:0xE8D5C4] title:@"18 replies\nThe brightest colors" fg:[GLTheme ink]];
    UIView *kit = [self tileBg:[GLTheme hex:0xC46A3A] title:@"8:05 PM\nKitchen crew" fg:UIColor.whiteColor];
    UIButton *music = [self playlistButton];
    UIStackView *row2 = [[UIStackView alloc] initWithArrangedSubviews:@[kit, music]];
    row2.translatesAutoresizingMaskIntoConstraints = NO;
    row2.axis = UILayoutConstraintAxisHorizontal;
    row2.spacing = 10;
    row2.distribution = UIStackViewDistributionFillEqually;

    UIStackView *col = [GLTheme column:@[nav, over, h, body, stats, row1, wide, row2] spacing:10];
    [col setCustomSpacing:18 afterView:nav];
    [col setCustomSpacing:8 afterView:over];
    [col setCustomSpacing:8 afterView:h];
    [col setCustomSpacing:12 afterView:body];
    [col setCustomSpacing:16 afterView:stats];
    [c addSubview:col];

    [NSLayoutConstraint activateConstraints:@[
        [col.topAnchor constraintEqualToAnchor:c.topAnchor constant:8],
        [col.leadingAnchor constraintEqualToAnchor:c.leadingAnchor constant:16],
        [col.trailingAnchor constraintEqualToAnchor:c.trailingAnchor constant:-16],
        [col.bottomAnchor constraintEqualToAnchor:c.bottomAnchor constant:-24],
        [leftSlot.widthAnchor constraintEqualToConstant:36],
        [leftSlot.heightAnchor constraintEqualToConstant:36],
        [self.backButton.topAnchor constraintEqualToAnchor:leftSlot.topAnchor],
        [self.backButton.leadingAnchor constraintEqualToAnchor:leftSlot.leadingAnchor],
        [art.topAnchor constraintEqualToAnchor:photo.topAnchor],
        [art.leadingAnchor constraintEqualToAnchor:photo.leadingAnchor],
        [art.trailingAnchor constraintEqualToAnchor:photo.trailingAnchor],
        [art.bottomAnchor constraintEqualToAnchor:photo.bottomAnchor],
        [pt.leadingAnchor constraintEqualToAnchor:photo.leadingAnchor constant:12],
        [pt.trailingAnchor constraintEqualToAnchor:photo.trailingAnchor constant:-12],
        [pt.bottomAnchor constraintEqualToAnchor:photo.bottomAnchor constant:-12],
        [q.topAnchor constraintEqualToAnchor:quote.topAnchor constant:16],
        [q.leadingAnchor constraintEqualToAnchor:quote.leadingAnchor constant:12],
        [q.trailingAnchor constraintEqualToAnchor:quote.trailingAnchor constant:-12],
        [ava.leadingAnchor constraintEqualToAnchor:q.leadingAnchor],
        [ava.bottomAnchor constraintEqualToAnchor:quote.bottomAnchor constant:-12],
        [ava.topAnchor constraintGreaterThanOrEqualToAnchor:q.bottomAnchor constant:8],
        [play.centerXAnchor constraintEqualToAnchor:audio.centerXAnchor],
        [play.centerYAnchor constraintEqualToAnchor:audio.centerYAnchor constant:-8],
        [dur.centerXAnchor constraintEqualToAnchor:audio.centerXAnchor],
        [dur.topAnchor constraintEqualToAnchor:play.bottomAnchor constant:6],
        [quote.heightAnchor constraintEqualToConstant:120],
        [row1.heightAnchor constraintEqualToConstant:210],
        [wide.heightAnchor constraintEqualToConstant:92],
        [row2.heightAnchor constraintEqualToConstant:110]
    ]];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    BOOL canPop = self.navigationController.viewControllers.count > 1;
    self.backButton.hidden = !canPop;
    self.backButton.enabled = canPop;
}
- (UIView *)tileBg:(UIColor *)bg title:(NSString *)title fg:(UIColor *)fg {
    UIView *v = [GLTheme card:24];
    v.backgroundColor = bg;
    UILabel *l = [GLTheme label:title font:[GLTheme title:16] color:fg];
    l.numberOfLines = 0;
    [v addSubview:l];
    [NSLayoutConstraint activateConstraints:@[
        [l.leadingAnchor constraintEqualToAnchor:v.leadingAnchor constant:14],
        [l.trailingAnchor constraintEqualToAnchor:v.trailingAnchor constant:-12],
        [l.bottomAnchor constraintEqualToAnchor:v.bottomAnchor constant:-12]
    ]];
    return v;
}
- (UIButton *)playlistButton {
    UIButton *music = [UIButton buttonWithType:UIButtonTypeCustom];
    music.translatesAutoresizingMaskIntoConstraints = NO;
    music.backgroundColor = [GLTheme lavender];
    music.layer.cornerRadius = 24;
    music.clipsToBounds = YES;
    [music addTarget:self action:@selector(openCapsule) forControlEvents:UIControlEventTouchUpInside];
    UILabel *mt = [GLTheme label:@"Guest playlist\n34 songs" font:[GLTheme title:15] color:[GLTheme hex:0x4A2A8A]];
    mt.numberOfLines = 2;
    mt.userInteractionEnabled = NO;
    [music addSubview:mt];
    [NSLayoutConstraint activateConstraints:@[
        [mt.leadingAnchor constraintEqualToAnchor:music.leadingAnchor constant:12],
        [mt.trailingAnchor constraintEqualToAnchor:music.trailingAnchor constant:-12],
        [mt.bottomAnchor constraintEqualToAnchor:music.bottomAnchor constant:-12]
    ]];
    return music;
}
- (void)backOrIgnore {
    if (self.navigationController.viewControllers.count > 1) [self.navigationController popViewControllerAnimated:YES];
}
- (void)share {
    UIActivityViewController *a = [[UIActivityViewController alloc] initWithActivityItems:@[@"Rooftop Sunset — GatherLoop afterglow"] applicationActivities:nil];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)play {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Voice note" message:@"Playing Ava's 18-second toast voice note." preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)openCapsule {
    GLCapsuleViewController *vc = [GLCapsuleViewController new];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
