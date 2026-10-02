#import "GLLiveViewController.h"
#import "GLTheme.h"
#import "GLArt.h"
#import "GLStore.h"
#import "GLChatViewController.h"
#import "GLCaptureViewController.h"
#import "GLEventHubViewController.h"

@implementation GLLiveViewController
- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [GLTheme hex:0x12121A];
    UIScrollView *scroll = [UIScrollView new];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scroll];
    UIView *c = [UIView new];
    c.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:c];

    UIButton *close = [GLTheme circleSymbol:@"xmark" bg:[UIColor colorWithWhite:1 alpha:0.1] tint:UIColor.whiteColor size:36];
    [close addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    UILabel *live = [GLTheme label:@"●  Live  •  Rooftop Sunset" font:[GLTheme medium:12] color:UIColor.whiteColor];
    UIButton *vol = [GLTheme circleSymbol:@"speaker.wave.2" bg:[UIColor colorWithWhite:1 alpha:0.1] tint:UIColor.whiteColor size:36];

    UIView *check = [GLTheme card:20];
    check.backgroundColor = [GLTheme hex:0x1C1C28];
    UIStackView *avs = [UIStackView new];
    avs.translatesAutoresizingMaskIntoConstraints = NO;
    avs.spacing = -8;
    for (NSDictionary *g in [[GLStore shared].guests subarrayWithRange:NSMakeRange(0, MIN(3, [GLStore shared].guests.count))]) {
        UIColor *col = [g[@"color"] isEqualToString:@"orange"] ? [GLTheme coral] : ([g[@"color"] isEqualToString:@"teal"] ? [GLTheme mint] : [GLTheme purple]);
        [avs addArrangedSubview:[GLAvatarView initial:g[@"initial"] color:col size:32]];
    }
    UILabel *ci = [GLTheme label:@"18 of 24 checked in" font:[GLTheme title:15] color:UIColor.whiteColor];
    UILabel *qr = [GLTheme label:@"Share the event QR at the door" font:[GLTheme regular:12] color:[GLTheme sub]];
    UIView *qricon = [GLTheme iconBox:@"qrcode" bg:[GLTheme lime] tint:[GLTheme ink] size:44 radius:12];
    [check addSubview:avs]; [check addSubview:ci]; [check addSubview:qr]; [check addSubview:qricon];

    UIView *event = [GLTheme card:24];
    GLSunsetView *art = [GLSunsetView new];
    art.translatesAutoresizingMaskIntoConstraints = NO;
    art.showGlasses = YES;
    art.showPeople = NO;
    [event addSubview:art];
    UILabel *now = [GLTheme label:@"Now · 7:20–7:35 PM" font:[GLTheme medium:11] color:[GLTheme coral]];
    UILabel *et = [GLTheme label:@"Sunset toast" font:[GLTheme title:22] color:[GLTheme ink]];
    UILabel *lead = [GLTheme label:@"Led by Noah" font:[GLTheme regular:13] color:[GLTheme sub]];
    UIButton *done = [GLTheme fillButton:@"Mark done" bg:[GLTheme line] fg:[GLTheme ink] radius:16];
    [done addTarget:self action:@selector(markDone:) forControlEvents:UIControlEventTouchUpInside];
    [event addSubview:now]; [event addSubview:et]; [event addSubview:lead]; [event addSubview:done];

    UIButton *next = [UIButton buttonWithType:UIButtonTypeCustom];
    next.backgroundColor = [GLTheme hex:0x1C1C28];
    next.layer.cornerRadius = 18;
    UIView *note = [GLTheme iconBox:@"music.note" bg:[GLTheme lavender] tint:[GLTheme ink] size:36 radius:10];
    note.userInteractionEnabled = NO;
    UILabel *up = [GLTheme label:@"Up next · 7:35 PM" font:[GLTheme medium:11] color:[GLTheme sub]];
    UILabel *pl = [GLTheme label:@"Guest co-op playlist" font:[GLTheme title:15] color:UIColor.whiteColor];
    [next addSubview:note]; [next addSubview:up]; [next addSubview:pl];

    UIView *prompt = [GLTheme card:24];
    prompt.backgroundColor = [GLTheme hex:0x6B4CFF];
    UILabel *mp = [GLTheme label:@"✦  Moment prompt" font:[GLTheme medium:11] color:[GLTheme lime]];
    UILabel *pt = [GLTheme label:@"Tell us the brightest color on site." font:[GLTheme title:20] color:UIColor.whiteColor];
    pt.numberOfLines = 0;
    UILabel *ans = [GLTheme label:@"9 guests have responded" font:[GLTheme regular:13] color:[UIColor colorWithWhite:1 alpha:0.75]];
    UIButton *cap = [GLTheme fillButton:@"  Capture moment" bg:[GLTheme lime] fg:[GLTheme ink] radius:18];
    [cap setImage:[UIImage systemImageNamed:@"camera.fill"] forState:UIControlStateNormal];
    cap.tintColor = [GLTheme ink];
    [cap addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    [prompt addSubview:mp]; [prompt addSubview:pt]; [prompt addSubview:ans]; [prompt addSubview:cap];

    UIButton *chat = [self bottom:@"bubble.left.fill" title:@"Crew chat" badge:@"3"];
    [chat addTarget:self action:@selector(openChat) forControlEvents:UIControlEventTouchUpInside];
    UIButton *tasks = [self bottom:@"checklist" title:@"Quick tasks" badge:nil];
    [tasks addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    UIButton *help = [self bottom:@"questionmark.circle" title:@"Host help" badge:nil];
    [help addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];

    for (UIView *v in @[close, live, vol, check, event, next, prompt, chat, tasks, help]) [c addSubview:v];
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
        [close.topAnchor constraintEqualToAnchor:c.topAnchor constant:8],
        [close.leadingAnchor constraintEqualToAnchor:c.leadingAnchor constant:16],
        [live.centerYAnchor constraintEqualToAnchor:close.centerYAnchor],
        [live.centerXAnchor constraintEqualToAnchor:c.centerXAnchor],
        [vol.centerYAnchor constraintEqualToAnchor:close.centerYAnchor],
        [vol.trailingAnchor constraintEqualToAnchor:c.trailingAnchor constant:-16],
        [check.topAnchor constraintEqualToAnchor:close.bottomAnchor constant:16],
        [check.leadingAnchor constraintEqualToAnchor:c.leadingAnchor constant:16],
        [check.trailingAnchor constraintEqualToAnchor:c.trailingAnchor constant:-16],
        [avs.leadingAnchor constraintEqualToAnchor:check.leadingAnchor constant:12],
        [avs.centerYAnchor constraintEqualToAnchor:check.centerYAnchor],
        [ci.leadingAnchor constraintEqualToAnchor:avs.trailingAnchor constant:10],
        [ci.topAnchor constraintEqualToAnchor:check.topAnchor constant:14],
        [qr.leadingAnchor constraintEqualToAnchor:ci.leadingAnchor],
        [qr.topAnchor constraintEqualToAnchor:ci.bottomAnchor constant:2],
        [qr.bottomAnchor constraintEqualToAnchor:check.bottomAnchor constant:-14],
        [qricon.trailingAnchor constraintEqualToAnchor:check.trailingAnchor constant:-12],
        [qricon.centerYAnchor constraintEqualToAnchor:check.centerYAnchor],
        [event.topAnchor constraintEqualToAnchor:check.bottomAnchor constant:14],
        [event.leadingAnchor constraintEqualToAnchor:check.leadingAnchor],
        [event.trailingAnchor constraintEqualToAnchor:check.trailingAnchor],
        [art.topAnchor constraintEqualToAnchor:event.topAnchor],
        [art.leadingAnchor constraintEqualToAnchor:event.leadingAnchor],
        [art.trailingAnchor constraintEqualToAnchor:event.trailingAnchor],
        [art.heightAnchor constraintEqualToConstant:150],
        [now.topAnchor constraintEqualToAnchor:art.bottomAnchor constant:14],
        [now.leadingAnchor constraintEqualToAnchor:event.leadingAnchor constant:16],
        [et.topAnchor constraintEqualToAnchor:now.bottomAnchor constant:4],
        [et.leadingAnchor constraintEqualToAnchor:now.leadingAnchor],
        [lead.topAnchor constraintEqualToAnchor:et.bottomAnchor constant:4],
        [lead.leadingAnchor constraintEqualToAnchor:now.leadingAnchor],
        [done.trailingAnchor constraintEqualToAnchor:event.trailingAnchor constant:-16],
        [done.centerYAnchor constraintEqualToAnchor:et.centerYAnchor],
        [done.widthAnchor constraintEqualToConstant:110],
        [done.heightAnchor constraintEqualToConstant:36],
        [lead.bottomAnchor constraintEqualToAnchor:event.bottomAnchor constant:-16],
        [next.topAnchor constraintEqualToAnchor:event.bottomAnchor constant:12],
        [next.leadingAnchor constraintEqualToAnchor:event.leadingAnchor],
        [next.trailingAnchor constraintEqualToAnchor:event.trailingAnchor],
        [next.heightAnchor constraintEqualToConstant:64],
        [note.leadingAnchor constraintEqualToAnchor:next.leadingAnchor constant:12],
        [note.centerYAnchor constraintEqualToAnchor:next.centerYAnchor],
        [up.leadingAnchor constraintEqualToAnchor:note.trailingAnchor constant:10],
        [up.topAnchor constraintEqualToAnchor:next.topAnchor constant:12],
        [pl.leadingAnchor constraintEqualToAnchor:up.leadingAnchor],
        [pl.topAnchor constraintEqualToAnchor:up.bottomAnchor constant:2],
        [prompt.topAnchor constraintEqualToAnchor:next.bottomAnchor constant:12],
        [prompt.leadingAnchor constraintEqualToAnchor:next.leadingAnchor],
        [prompt.trailingAnchor constraintEqualToAnchor:next.trailingAnchor],
        [mp.topAnchor constraintEqualToAnchor:prompt.topAnchor constant:16],
        [mp.leadingAnchor constraintEqualToAnchor:prompt.leadingAnchor constant:16],
        [pt.topAnchor constraintEqualToAnchor:mp.bottomAnchor constant:8],
        [pt.leadingAnchor constraintEqualToAnchor:mp.leadingAnchor],
        [pt.trailingAnchor constraintEqualToAnchor:prompt.trailingAnchor constant:-16],
        [ans.topAnchor constraintEqualToAnchor:pt.bottomAnchor constant:8],
        [ans.leadingAnchor constraintEqualToAnchor:mp.leadingAnchor],
        [cap.topAnchor constraintEqualToAnchor:ans.bottomAnchor constant:14],
        [cap.leadingAnchor constraintEqualToAnchor:mp.leadingAnchor],
        [cap.widthAnchor constraintEqualToConstant:190],
        [cap.heightAnchor constraintEqualToConstant:44],
        [cap.bottomAnchor constraintEqualToAnchor:prompt.bottomAnchor constant:-16],
        [chat.topAnchor constraintEqualToAnchor:prompt.bottomAnchor constant:16],
        [chat.leadingAnchor constraintEqualToAnchor:prompt.leadingAnchor],
        [chat.trailingAnchor constraintEqualToAnchor:c.centerXAnchor constant:-52],
        [chat.heightAnchor constraintEqualToConstant:54],
        [tasks.centerYAnchor constraintEqualToAnchor:chat.centerYAnchor],
        [tasks.centerXAnchor constraintEqualToAnchor:c.centerXAnchor],
        [tasks.widthAnchor constraintEqualToAnchor:chat.widthAnchor],
        [tasks.heightAnchor constraintEqualToAnchor:chat.heightAnchor],
        [help.centerYAnchor constraintEqualToAnchor:chat.centerYAnchor],
        [help.leadingAnchor constraintEqualToAnchor:c.centerXAnchor constant:52],
        [help.trailingAnchor constraintEqualToAnchor:prompt.trailingAnchor],
        [help.heightAnchor constraintEqualToAnchor:chat.heightAnchor],
        [chat.bottomAnchor constraintEqualToAnchor:c.bottomAnchor constant:-24]
    ]];
}
- (UIButton *)bottom:(NSString *)icon title:(NSString *)title badge:(NSString *)badge {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.translatesAutoresizingMaskIntoConstraints = NO;
    b.backgroundColor = [GLTheme hex:0x1C1C28];
    b.layer.cornerRadius = 16;
    [b setTitle:[NSString stringWithFormat:@"  %@", title] forState:UIControlStateNormal];
    [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    b.titleLabel.font = [GLTheme medium:11];
    [b setImage:[UIImage systemImageNamed:icon] forState:UIControlStateNormal];
    b.tintColor = UIColor.whiteColor;
    if (badge) {
        UILabel *l = [GLTheme label:badge font:[GLTheme title:10] color:UIColor.whiteColor];
        l.backgroundColor = [GLTheme coral];
        l.textAlignment = NSTextAlignmentCenter;
        l.layer.cornerRadius = 8;
        l.clipsToBounds = YES;
        [b addSubview:l];
        [NSLayoutConstraint activateConstraints:@[
            [l.widthAnchor constraintEqualToConstant:16],
            [l.heightAnchor constraintEqualToConstant:16],
            [l.trailingAnchor constraintEqualToAnchor:b.trailingAnchor constant:-8],
            [l.topAnchor constraintEqualToAnchor:b.topAnchor constant:6]
        ]];
    }
    return b;
}
- (void)markDone:(UIButton *)b {
    [b setTitle:@"Done" forState:UIControlStateNormal];
    b.backgroundColor = [GLTheme mint];
}
- (void)capture {
    GLCaptureViewController *vc = [GLCaptureViewController new];
    vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)openChat { [self.navigationController pushViewController:[GLChatViewController new] animated:YES]; }
- (void)help {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Host help" message:@"Keep the toast short, then hand the playlist to Jay. Ice is in the kitchen bucket." preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"Got it" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)pop { [self.navigationController popViewControllerAnimated:YES]; }
@end
