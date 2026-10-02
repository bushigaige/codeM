#import "GLCapsuleViewController.h"
#import "GLTheme.h"
#import "GLStore.h"
#import "GLArt.h"

@interface GLCapsuleViewController () <UITextViewDelegate>
@property (nonatomic, strong) UITextView *note;
@property (nonatomic, strong) UILabel *count;
@property (nonatomic, strong) UIButton *seal;
@end

@implementation GLCapsuleViewController
- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [GLTheme hex:0x171628];
    UIScrollView *scroll = [UIScrollView new];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scroll];
    UIView *c = [UIView new];
    c.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:c];

    UIButton *back = [GLTheme circleSymbol:@"chevron.left" bg:[UIColor colorWithWhite:1 alpha:0.08] tint:UIColor.whiteColor size:36];
    [back addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    UILabel *title = [GLTheme label:@"Memory Capsule" font:[GLTheme display:28] color:UIColor.whiteColor];
    UIButton *help = [GLTheme circleSymbol:@"questionmark.circle" bg:[UIColor colorWithWhite:1 alpha:0.08] tint:UIColor.whiteColor size:36];

    UIView *illus = [UIView new];
    illus.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *card = [GLTheme card:20];
    card.backgroundColor = [GLTheme hex:0x5B3DFF];
    UIView *lock = [GLTheme iconBox:@"lock.fill" bg:[GLTheme mint] tint:[GLTheme ink] size:54 radius:16];
    [illus addSubview:card];
    [card addSubview:lock];

    UILabel *cat = [GLTheme label:@"Rooftop Sunset Club" font:[GLTheme medium:11] color:[GLTheme mint]];
    UILabel *h = [GLTheme label:@"Seal tonight. Open later." font:[GLTheme display:28] color:UIColor.whiteColor];
    h.numberOfLines = 0;
    UILabel *d = [GLTheme label:@"Pick a few moments and a note. On the unlock date, everyone opens the same capsule." font:[GLTheme regular:14] color:[GLTheme sub]];
    d.numberOfLines = 0;

    UIView *box = [GLTheme card:22];
    box.backgroundColor = [GLTheme hex:0x252639];
    UIView *ph = [GLTheme iconBox:@"photo.on.rectangle" bg:[GLTheme lavender] tint:[GLTheme purple] size:40 radius:12];
    UILabel *sel = [GLTheme label:@"12 moments selected" font:[GLTheme title:15] color:UIColor.whiteColor];
    UILabel *ss = [GLTheme label:@"Photos, 2 notes & 1 voice memo" font:[GLTheme regular:12] color:[GLTheme sub]];
    UIButton *edit = [UIButton buttonWithType:UIButtonTypeSystem];
    edit.translatesAutoresizingMaskIntoConstraints = NO;
    [edit setTitle:@"Edit" forState:UIControlStateNormal];
    [edit setTitleColor:[GLTheme mint] forState:UIControlStateNormal];
    UIView *cal = [GLTheme iconBox:@"calendar" bg:[GLTheme lime] tint:[GLTheme ink] size:40 radius:12];
    UILabel *un = [GLTheme label:@"Unlocks · Sep 5, 2027" font:[GLTheme title:15] color:UIColor.whiteColor];
    UILabel *us = [GLTheme label:@"One year after the gathering" font:[GLTheme regular:12] color:[GLTheme sub]];

    UIView *noteBox = [GLTheme card:16];
    noteBox.backgroundColor = [GLTheme hex:0x1B1C2C];
    UILabel *nl = [GLTheme label:@"A note to future us" font:[GLTheme medium:10] color:[GLTheme sub]];
    self.note = [UITextView new];
    self.note.translatesAutoresizingMaskIntoConstraints = NO;
    self.note.backgroundColor = UIColor.clearColor;
    self.note.textColor = UIColor.whiteColor;
    self.note.font = [GLTheme regular:15];
    self.note.text = [GLStore shared].capsule[@"note"];
    self.note.delegate = self;
    self.count = [GLTheme label:@"0 / 240" font:[GLTheme regular:11] color:[GLTheme sub]];
    [noteBox addSubview:nl]; [noteBox addSubview:self.note]; [noteBox addSubview:self.count];
    [box addSubview:ph]; [box addSubview:sel]; [box addSubview:ss]; [box addSubview:edit];
    [box addSubview:cal]; [box addSubview:un]; [box addSubview:us]; [box addSubview:noteBox];

    self.seal = [GLTheme fillButton:@"Seal for 18 guests  🔒" bg:[GLTheme mint] fg:[GLTheme ink] radius:22];
    [self.seal addTarget:self action:@selector(sealNow) forControlEvents:UIControlEventTouchUpInside];
    UILabel *disc = [GLTheme label:@"🛡  Even the host can't open early" font:[GLTheme regular:12] color:[GLTheme sub]];
    disc.textAlignment = NSTextAlignmentCenter;

    for (UIView *v in @[back, title, help, illus, cat, h, d, box, self.seal, disc]) [c addSubview:v];
    [NSLayoutConstraint activateConstraints:@[
        [scroll.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [c.topAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.topAnchor],
        [c.bottomAnchor constraintEqualToAnchor:scroll.contentLayoutGuide.bottomAnchor],
        [c.leadingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.leadingAnchor],
        [c.trailingAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.trailingAnchor],
        [c.widthAnchor constraintEqualToAnchor:scroll.frameLayoutGuide.widthAnchor],
        [back.topAnchor constraintEqualToAnchor:c.topAnchor constant:8],
        [back.leadingAnchor constraintEqualToAnchor:c.leadingAnchor constant:16],
        [help.centerYAnchor constraintEqualToAnchor:back.centerYAnchor],
        [help.trailingAnchor constraintEqualToAnchor:c.trailingAnchor constant:-16],
        [title.topAnchor constraintEqualToAnchor:back.bottomAnchor constant:16],
        [title.leadingAnchor constraintEqualToAnchor:back.leadingAnchor],
        [illus.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:16],
        [illus.centerXAnchor constraintEqualToAnchor:c.centerXAnchor],
        [illus.widthAnchor constraintEqualToConstant:160],
        [illus.heightAnchor constraintEqualToConstant:110],
        [card.centerXAnchor constraintEqualToAnchor:illus.centerXAnchor],
        [card.centerYAnchor constraintEqualToAnchor:illus.centerYAnchor],
        [card.widthAnchor constraintEqualToConstant:120],
        [card.heightAnchor constraintEqualToConstant:90],
        [lock.centerXAnchor constraintEqualToAnchor:card.centerXAnchor],
        [lock.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
        [cat.topAnchor constraintEqualToAnchor:illus.bottomAnchor constant:16],
        [cat.leadingAnchor constraintEqualToAnchor:c.leadingAnchor constant:20],
        [h.topAnchor constraintEqualToAnchor:cat.bottomAnchor constant:8],
        [h.leadingAnchor constraintEqualToAnchor:cat.leadingAnchor],
        [h.trailingAnchor constraintEqualToAnchor:c.trailingAnchor constant:-20],
        [d.topAnchor constraintEqualToAnchor:h.bottomAnchor constant:8],
        [d.leadingAnchor constraintEqualToAnchor:h.leadingAnchor],
        [d.trailingAnchor constraintEqualToAnchor:h.trailingAnchor],
        [box.topAnchor constraintEqualToAnchor:d.bottomAnchor constant:18],
        [box.leadingAnchor constraintEqualToAnchor:c.leadingAnchor constant:16],
        [box.trailingAnchor constraintEqualToAnchor:c.trailingAnchor constant:-16],
        [ph.topAnchor constraintEqualToAnchor:box.topAnchor constant:14],
        [ph.leadingAnchor constraintEqualToAnchor:box.leadingAnchor constant:14],
        [sel.leadingAnchor constraintEqualToAnchor:ph.trailingAnchor constant:10],
        [sel.topAnchor constraintEqualToAnchor:ph.topAnchor],
        [ss.leadingAnchor constraintEqualToAnchor:sel.leadingAnchor],
        [ss.topAnchor constraintEqualToAnchor:sel.bottomAnchor constant:2],
        [edit.trailingAnchor constraintEqualToAnchor:box.trailingAnchor constant:-14],
        [edit.centerYAnchor constraintEqualToAnchor:ph.centerYAnchor],
        [cal.topAnchor constraintEqualToAnchor:ph.bottomAnchor constant:16],
        [cal.leadingAnchor constraintEqualToAnchor:ph.leadingAnchor],
        [un.leadingAnchor constraintEqualToAnchor:cal.trailingAnchor constant:10],
        [un.topAnchor constraintEqualToAnchor:cal.topAnchor],
        [us.leadingAnchor constraintEqualToAnchor:un.leadingAnchor],
        [us.topAnchor constraintEqualToAnchor:un.bottomAnchor constant:2],
        [noteBox.topAnchor constraintEqualToAnchor:cal.bottomAnchor constant:16],
        [noteBox.leadingAnchor constraintEqualToAnchor:box.leadingAnchor constant:12],
        [noteBox.trailingAnchor constraintEqualToAnchor:box.trailingAnchor constant:-12],
        [noteBox.heightAnchor constraintEqualToConstant:110],
        [noteBox.bottomAnchor constraintEqualToAnchor:box.bottomAnchor constant:-12],
        [nl.topAnchor constraintEqualToAnchor:noteBox.topAnchor constant:10],
        [nl.leadingAnchor constraintEqualToAnchor:noteBox.leadingAnchor constant:12],
        [self.note.topAnchor constraintEqualToAnchor:nl.bottomAnchor constant:4],
        [self.note.leadingAnchor constraintEqualToAnchor:nl.leadingAnchor],
        [self.note.trailingAnchor constraintEqualToAnchor:noteBox.trailingAnchor constant:-8],
        [self.note.bottomAnchor constraintEqualToAnchor:self.count.topAnchor],
        [self.count.trailingAnchor constraintEqualToAnchor:noteBox.trailingAnchor constant:-10],
        [self.count.bottomAnchor constraintEqualToAnchor:noteBox.bottomAnchor constant:-8],
        [self.seal.topAnchor constraintEqualToAnchor:box.bottomAnchor constant:18],
        [self.seal.leadingAnchor constraintEqualToAnchor:box.leadingAnchor],
        [self.seal.trailingAnchor constraintEqualToAnchor:box.trailingAnchor],
        [self.seal.heightAnchor constraintEqualToConstant:54],
        [disc.topAnchor constraintEqualToAnchor:self.seal.bottomAnchor constant:10],
        [disc.centerXAnchor constraintEqualToAnchor:c.centerXAnchor],
        [disc.bottomAnchor constraintEqualToAnchor:c.bottomAnchor constant:-24]
    ]];
    [self textViewDidChange:self.note];
    if ([[GLStore shared].capsule[@"sealed"] boolValue]) {
        [self.seal setTitle:@"Sealed until Sep 5, 2027" forState:UIControlStateNormal];
        self.seal.enabled = NO;
        self.seal.alpha = 0.7;
    }
}
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 240) textView.text = [textView.text substringToIndex:240];
    self.count.text = [NSString stringWithFormat:@"%ld / 240", (long)textView.text.length];
}
- (void)sealNow {
    [GLStore shared].capsule[@"note"] = self.note.text;
    [[GLStore shared] sealCapsule];
    [self.seal setTitle:@"Sealed until Sep 5, 2027" forState:UIControlStateNormal];
    self.seal.enabled = NO;
}
- (void)pop {
    if (self.navigationController.viewControllers.count > 1) [self.navigationController popViewControllerAnimated:YES];
    else [self dismissViewControllerAnimated:YES completion:nil];
}
@end
