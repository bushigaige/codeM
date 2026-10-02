#import "GLMeViewController.h"
#import "GLTheme.h"
#import "GLStore.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

#pragma mark - Shared helpers

static void GLPush(UIViewController *from, UIViewController *vc) {
    UINavigationController *nav = from.navigationController;
    nav.navigationBarHidden = NO;
    vc.hidesBottomBarWhenPushed = YES;
    [nav pushViewController:vc animated:YES];
}

static UIView *GLSwitchRow(NSString *title, NSString *sub, BOOL on, id target, SEL action, UISwitch **outSwitch) {
    UIView *row = [GLTheme card:16];
    UILabel *t = [GLTheme label:title font:[GLTheme title:15] color:[GLTheme ink]];
    UILabel *s = [GLTheme label:sub font:[GLTheme regular:12] color:[GLTheme sub]];
    s.numberOfLines = 0;
    UISwitch *sw = [UISwitch new];
    sw.translatesAutoresizingMaskIntoConstraints = NO;
    sw.on = on;
    sw.onTintColor = [GLTheme purple];
    [sw addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    [row addSubview:t]; [row addSubview:s]; [row addSubview:sw];
    [NSLayoutConstraint activateConstraints:@[
        [t.topAnchor constraintEqualToAnchor:row.topAnchor constant:14],
        [t.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:14],
        [t.trailingAnchor constraintEqualToAnchor:sw.leadingAnchor constant:-10],
        [sw.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [sw.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-14],
        [s.topAnchor constraintEqualToAnchor:t.bottomAnchor constant:4],
        [s.leadingAnchor constraintEqualToAnchor:t.leadingAnchor],
        [s.trailingAnchor constraintEqualToAnchor:sw.leadingAnchor constant:-10],
        [s.bottomAnchor constraintEqualToAnchor:row.bottomAnchor constant:-14]
    ]];
    if (outSwitch) *outSwitch = sw;
    return row;
}

static UITextField *GLField(NSString *placeholder, NSString *text) {
    UITextField *tf = [UITextField new];
    tf.translatesAutoresizingMaskIntoConstraints = NO;
    tf.placeholder = placeholder;
    tf.text = text;
    tf.font = [GLTheme regular:15];
    tf.textColor = [GLTheme ink];
    tf.backgroundColor = [GLTheme bg];
    tf.layer.cornerRadius = 12;
    tf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)];
    tf.leftViewMode = UITextFieldViewModeAlways;
    tf.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 1)];
    tf.rightViewMode = UITextFieldViewModeAlways;
    [tf.heightAnchor constraintEqualToConstant:44].active = YES;
    return tf;
}

#pragma mark - Profile prefs

@interface GLProfilePrefsVC : UIViewController
@property (nonatomic, strong) UITextField *nameF;
@property (nonatomic, strong) UITextField *bioF;
@property (nonatomic, strong) UITextField *dietF;
@property (nonatomic, strong) UITextField *emailF;
@end

@implementation GLProfilePrefsVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Profile & Preferences";
    self.view.backgroundColor = [GLTheme bg];
    GLStore *st = [GLStore shared];
    self.nameF = GLField(@"Name", st.user[@"name"]);
    self.bioF = GLField(@"Bio", st.user[@"bio"]);
    self.dietF = GLField(@"Dietary notes", st.user[@"dietary"]);
    self.emailF = GLField(@"Email", st.user[@"email"]);
    self.emailF.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    UIButton *save = [GLTheme fillButton:@"Save changes" bg:[GLTheme ink] fg:UIColor.whiteColor radius:16];
    [save addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    UILabel *hint = [GLTheme label:@"Tap your avatar on the Me page to choose a photo with Camera or Photos. Dietary notes are visible to guests helping with shopping." font:[GLTheme regular:12] color:[GLTheme sub]];
    hint.numberOfLines = 0;
    UIStackView *col = [GLTheme column:@[
        [GLTheme label:@"Name" font:[GLTheme medium:11] color:[GLTheme sub]], self.nameF,
        [GLTheme label:@"Bio" font:[GLTheme medium:11] color:[GLTheme sub]], self.bioF,
        [GLTheme label:@"Dietary notes" font:[GLTheme medium:11] color:[GLTheme sub]], self.dietF,
        [GLTheme label:@"Email" font:[GLTheme medium:11] color:[GLTheme sub]], self.emailF,
        hint, save
    ] spacing:8];
    col.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:col];
    [NSLayoutConstraint activateConstraints:@[
        [col.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [col.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [col.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}
- (void)save {
    [[GLStore shared] updateProfileName:self.nameF.text bio:self.bioF.text dietary:self.dietF.text email:self.emailF.text];
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Saved" message:@"Your profile and preferences were updated." preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:a animated:YES completion:nil];
}
@end

#pragma mark - Notifications

@interface GLNotificationsVC : UIViewController
@end

@implementation GLNotificationsVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Notifications";
    self.view.backgroundColor = [GLTheme bg];
    GLStore *st = [GLStore shared];
    UISwitch *s1, *s2, *s3;
    UIView *r1 = GLSwitchRow(@"Task updates", @"Get notified when guests complete or assign tasks", [st settingEnabled:@"notifyTasks"], self, @selector(toggle:), &s1);
    s1.tag = 1;
    UIView *r2 = GLSwitchRow(@"Invites & replies", @"New invites, RSVPs, and waitlists", [st settingEnabled:@"notifyInvites"], self, @selector(toggle:), &s2);
    s2.tag = 2;
    UIView *r3 = GLSwitchRow(@"Capsule unlocks", @"When a time capsule unlocks or someone adds content", [st settingEnabled:@"notifyCapsule"], self, @selector(toggle:), &s3);
    s3.tag = 3;
    UIStackView *col = [GLTheme column:@[r1, r2, r3] spacing:12];
    col.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:col];
    [NSLayoutConstraint activateConstraints:@[
        [col.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [col.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [col.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16]
    ]];
}
- (void)toggle:(UISwitch *)sw {
    NSString *key = @[@"notifyTasks", @"notifyInvites", @"notifyCapsule"][sw.tag - 1];
    [[GLStore shared] setSetting:key enabled:sw.on];
}
@end

#pragma mark - My data

@interface GLMyDataVC : UIViewController
@end

@implementation GLMyDataVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My data";
    self.view.backgroundColor = [GLTheme bg];
    UILabel *info = [GLTheme label:@"You can export your locally stored GatherLoop data (JSON), or permanently delete your account and gathering data on this device." font:[GLTheme regular:14] color:[GLTheme sub]];
    info.numberOfLines = 0;
    UIButton *exp = [GLTheme fillButton:@"Export data" bg:[GLTheme purple] fg:UIColor.whiteColor radius:16];
    [exp addTarget:self action:@selector(exportData) forControlEvents:UIControlEventTouchUpInside];
    UIButton *reset = [GLTheme fillButton:@"Restore demo data" bg:[GLTheme line] fg:[GLTheme ink] radius:16];
    [reset addTarget:self action:@selector(resetDemo) forControlEvents:UIControlEventTouchUpInside];
    UIButton *del = [GLTheme fillButton:@"Delete local data" bg:[GLTheme coral] fg:UIColor.whiteColor radius:16];
    [del addTarget:self action:@selector(deleteData) forControlEvents:UIControlEventTouchUpInside];
    UIStackView *col = [GLTheme column:@[info, exp, reset, del] spacing:14];
    col.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:col];
    [NSLayoutConstraint activateConstraints:@[
        [col.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [col.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [col.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}
- (void)exportData {
    NSString *json = [[GLStore shared] exportJSONString];
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"GatherLoop-export.json"]];
    [json writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
    UIActivityViewController *av = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    [self presentViewController:av animated:YES completion:nil];
}
- (void)resetDemo {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Restore demo data?" message:@"This will overwrite your current local data and load the default demo gathering." preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [a addAction:[UIAlertAction actionWithTitle:@"Restore" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_) {
        [[GLStore shared] resetDemoData];
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)deleteData {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Delete local data?" message:@"This can't be undone. Gatherings, moments, messages, and settings will be cleared from this device." preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [a addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *_) {
        [[GLStore shared] deleteAllLocalData];
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:a animated:YES completion:nil];
}
@end

#pragma mark - Feedback

@interface GLFeedbackVC : UIViewController <UITextViewDelegate>
@property (nonatomic, strong) UITextView *tv;
@property (nonatomic, strong) UIStackView *list;
@end

@implementation GLFeedbackVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Send feedback";
    self.view.backgroundColor = [GLTheme bg];
    self.tv = [UITextView new];
    self.tv.translatesAutoresizingMaskIntoConstraints = NO;
    self.tv.font = [GLTheme regular:15];
    self.tv.textColor = [GLTheme ink];
    self.tv.backgroundColor = [GLTheme card];
    self.tv.layer.cornerRadius = 14;
    self.tv.textContainerInset = UIEdgeInsetsMake(12, 10, 12, 10);
    [self.tv.heightAnchor constraintEqualToConstant:120].active = YES;
    UIButton *send = [GLTheme fillButton:@"Submit feedback" bg:[GLTheme ink] fg:UIColor.whiteColor radius:16];
    [send addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    UILabel *hist = [GLTheme label:@"Submitted" font:[GLTheme medium:11] color:[GLTheme sub]];
    self.list = [UIStackView new];
    self.list.axis = UILayoutConstraintAxisVertical;
    self.list.spacing = 8;
    self.list.translatesAutoresizingMaskIntoConstraints = NO;
    UIScrollView *scroll; UIView *c;
    scroll = [GLTheme embedScrollIn:self.view content:&c top:self.view.safeAreaLayoutGuide.topAnchor bottom:self.view.safeAreaLayoutGuide.bottomAnchor];
    (void)scroll;
    UIStackView *col = [GLTheme column:@[
        [GLTheme label:@"Tell us what could be better" font:[GLTheme regular:13] color:[GLTheme sub]],
        self.tv, send, hist, self.list
    ] spacing:12];
    col.translatesAutoresizingMaskIntoConstraints = NO;
    [c addSubview:col];
    [NSLayoutConstraint activateConstraints:@[
        [col.topAnchor constraintEqualToAnchor:c.topAnchor constant:16],
        [col.leadingAnchor constraintEqualToAnchor:c.leadingAnchor constant:16],
        [col.trailingAnchor constraintEqualToAnchor:c.trailingAnchor constant:-16],
        [col.bottomAnchor constraintEqualToAnchor:c.bottomAnchor constant:-24]
    ]];
    [self reloadList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadList) name:GLStoreDidChangeNotification object:nil];
}
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }
- (void)send {
    [[GLStore shared] addFeedback:self.tv.text];
    self.tv.text = @"";
    [self.view endEditing:YES];
}
- (void)reloadList {
    for (UIView *v in self.list.arrangedSubviews) { [self.list removeArrangedSubview:v]; [v removeFromSuperview]; }
    NSArray *items = [GLStore shared].feedbackItems;
    if (items.count == 0) {
        [self.list addArrangedSubview:[GLTheme label:@"No feedback yet" font:[GLTheme regular:13] color:[GLTheme muted]]];
        return;
    }
    for (NSDictionary *item in items) {
        UIView *card = [GLTheme card:14];
        UILabel *t = [GLTheme label:item[@"text"] font:[GLTheme regular:14] color:[GLTheme ink]];
        t.numberOfLines = 0;
        UILabel *tm = [GLTheme label:item[@"time"] font:[GLTheme medium:11] color:[GLTheme sub]];
        UIStackView *s = [GLTheme column:@[tm, t] spacing:4];
        s.translatesAutoresizingMaskIntoConstraints = NO;
        [card addSubview:s];
        [GLTheme pin:s to:card insets:UIEdgeInsetsMake(12, 12, 12, 12)];
        [self.list addArrangedSubview:card];
    }
}
@end

#pragma mark - Safety / block

@interface GLSafetyVC : UIViewController
@property (nonatomic, strong) UIStackView *guestStack;
@property (nonatomic, strong) UIStackView *blockedStack;
@end

@implementation GLSafetyVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Safety & blocked guests";
    self.view.backgroundColor = [GLTheme bg];
    self.guestStack = [UIStackView new];
    self.guestStack.axis = UILayoutConstraintAxisVertical;
    self.guestStack.spacing = 8;
    self.blockedStack = [UIStackView new];
    self.blockedStack.axis = UILayoutConstraintAxisVertical;
    self.blockedStack.spacing = 8;
    UIView *c;
    [GLTheme embedScrollIn:self.view content:&c top:self.view.safeAreaLayoutGuide.topAnchor bottom:self.view.safeAreaLayoutGuide.bottomAnchor];
    UIStackView *col = [GLTheme column:@[
        [GLTheme label:@"Once blocked, they can no longer see your gathering invites or shared moments." font:[GLTheme regular:13] color:[GLTheme sub]],
        [GLTheme label:@"Current guests" font:[GLTheme medium:11] color:[GLTheme sub]],
        self.guestStack,
        [GLTheme label:@"Blocked" font:[GLTheme medium:11] color:[GLTheme sub]],
        self.blockedStack
    ] spacing:12];
    col.translatesAutoresizingMaskIntoConstraints = NO;
    [c addSubview:col];
    [NSLayoutConstraint activateConstraints:@[
        [col.topAnchor constraintEqualToAnchor:c.topAnchor constant:16],
        [col.leadingAnchor constraintEqualToAnchor:c.leadingAnchor constant:16],
        [col.trailingAnchor constraintEqualToAnchor:c.trailingAnchor constant:-16],
        [col.bottomAnchor constraintEqualToAnchor:c.bottomAnchor constant:-24]
    ]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:GLStoreDidChangeNotification object:nil];
    [self reload];
}
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }
- (void)clearStack:(UIStackView *)s {
    for (UIView *v in s.arrangedSubviews) { [s removeArrangedSubview:v]; [v removeFromSuperview]; }
}
- (UIView *)rowForGuest:(NSDictionary *)g blocked:(BOOL)blocked {
    UIView *card = [GLTheme card:14];
    UILabel *name = [GLTheme label:g[@"name"] ?: @"" font:[GLTheme title:15] color:[GLTheme ink]];
    NSString *sub = blocked ? [NSString stringWithFormat:@"Blocked · %@", g[@"blockedAt"] ?: @""] : (g[@"role"] ?: @"");
    UILabel *role = [GLTheme label:sub font:[GLTheme regular:12] color:[GLTheme sub]];
    UIButton *btn = [GLTheme fillButton:blocked ? @"Unblock" : @"Block" bg:blocked ? [GLTheme line] : [GLTheme softCoral] fg:[GLTheme ink] radius:12];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn.widthAnchor constraintEqualToConstant:88].active = YES;
    [btn.heightAnchor constraintEqualToConstant:34].active = YES;
    btn.accessibilityLabel = g[@"name"];
    [btn addTarget:self action:blocked ? @selector(unblock:) : @selector(block:) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:name]; [card addSubview:role]; [card addSubview:btn];
    [NSLayoutConstraint activateConstraints:@[
        [name.topAnchor constraintEqualToAnchor:card.topAnchor constant:14],
        [name.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:14],
        [name.trailingAnchor constraintEqualToAnchor:btn.leadingAnchor constant:-8],
        [role.topAnchor constraintEqualToAnchor:name.bottomAnchor constant:2],
        [role.leadingAnchor constraintEqualToAnchor:name.leadingAnchor],
        [role.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-14],
        [btn.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
        [btn.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-12]
    ]];
    return card;
}
- (void)reload {
    [self clearStack:self.guestStack];
    [self clearStack:self.blockedStack];
    GLStore *st = [GLStore shared];
    NSString *me = st.user[@"name"];
    NSInteger shown = 0;
    for (NSDictionary *g in st.guests) {
        if ([g[@"name"] isEqualToString:me]) continue;
        if ([st isGuestBlocked:g[@"name"]]) continue;
        [self.guestStack addArrangedSubview:[self rowForGuest:g blocked:NO]];
        shown++;
    }
    if (shown == 0) [self.guestStack addArrangedSubview:[GLTheme label:@"No guests to block" font:[GLTheme regular:13] color:[GLTheme muted]]];
    if (st.blockedGuests.count == 0) {
        [self.blockedStack addArrangedSubview:[GLTheme label:@"No one blocked yet" font:[GLTheme regular:13] color:[GLTheme muted]]];
    } else {
        for (NSDictionary *g in st.blockedGuests) {
            [self.blockedStack addArrangedSubview:[self rowForGuest:g blocked:YES]];
        }
    }
}
- (void)block:(UIButton *)b {
    NSString *name = b.accessibilityLabel;
    for (NSDictionary *g in [GLStore shared].guests) {
        if ([g[@"name"] isEqualToString:name]) { [[GLStore shared] blockGuest:g]; break; }
    }
}
- (void)unblock:(UIButton *)b {
    [[GLStore shared] unblockGuestNamed:b.accessibilityLabel];
}
@end

#pragma mark - Help

@interface GLHelpVC : UIViewController
@end

@implementation GLHelpVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Help center";
    self.view.backgroundColor = [GLTheme bg];
    NSArray *faqs = @[
        @[@"How do I invite guests?", @"Share an invite code or link from Gathering Hub. With Invite-only on, only people you invite can join."],
        @[@"Who can see moments?", @"By default, only guests at that gathering. You can turn off downloads in Settings, or auto-remove location after the event."],
        @[@"When does the time capsule open?", @"It opens on the unlock date you set. Hosts can seal content early; guests can still add voice notes and photos before unlock."],
        @[@"How do I export my data?", @"Go to My data → Export data to share a local JSON backup."],
        @[@"What happens when I block a guest?", @"Blocked guests can no longer see your invites, chat, or shared moments. You can unblock anytime on the Safety page."]
    ];
    UIView *c;
    [GLTheme embedScrollIn:self.view content:&c top:self.view.safeAreaLayoutGuide.topAnchor bottom:self.view.safeAreaLayoutGuide.bottomAnchor];
    NSMutableArray *rows = [NSMutableArray array];
    for (NSArray *faq in faqs) {
        UIView *card = [GLTheme card:16];
        UILabel *q = [GLTheme label:faq[0] font:[GLTheme title:15] color:[GLTheme ink]];
        UILabel *a = [GLTheme label:faq[1] font:[GLTheme regular:13] color:[GLTheme sub]];
        a.numberOfLines = 0;
        UIStackView *s = [GLTheme column:@[q, a] spacing:6];
        s.translatesAutoresizingMaskIntoConstraints = NO;
        [card addSubview:s];
        [GLTheme pin:s to:card insets:UIEdgeInsetsMake(14, 14, 14, 14)];
        [rows addObject:card];
    }
    UIStackView *col = [GLTheme column:rows spacing:10];
    col.translatesAutoresizingMaskIntoConstraints = NO;
    [c addSubview:col];
    [NSLayoutConstraint activateConstraints:@[
        [col.topAnchor constraintEqualToAnchor:c.topAnchor constant:16],
        [col.leadingAnchor constraintEqualToAnchor:c.leadingAnchor constant:16],
        [col.trailingAnchor constraintEqualToAnchor:c.trailingAnchor constant:-16],
        [col.bottomAnchor constraintEqualToAnchor:c.bottomAnchor constant:-24]
    ]];
}
@end

#pragma mark - Settings

@interface GLSettingsVC : UIViewController
@end

@implementation GLSettingsVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Settings";
    self.view.backgroundColor = [GLTheme bg];
    GLStore *st = [GLStore shared];
    UISwitch *s1, *s2, *s3;
    UIView *r1 = GLSwitchRow(@"Invite-only by default", @"New gatherings default to invite-only", [st settingEnabled:@"defaultInviteOnly"], self, @selector(toggle:), &s1);
    s1.tag = 1;
    UIView *r2 = GLSwitchRow(@"Remove location after event", @"Hide the exact address after the gathering ends", [st settingEnabled:@"removeLocationAfter"], self, @selector(toggle:), &s2);
    s2.tag = 2;
    UIView *r3 = GLSwitchRow(@"Allow moment downloads", @"Guests can export shared photos and notes", [st settingEnabled:@"momentsDownloadable"], self, @selector(toggle:), &s3);
    s3.tag = 3;
    UILabel *about = [GLTheme label:@"GatherLoop · Local demo\nData stays on this device and is never uploaded." font:[GLTheme regular:13] color:[GLTheme sub]];
    about.numberOfLines = 0;
    about.textAlignment = NSTextAlignmentCenter;
    UIStackView *col = [GLTheme column:@[
        [GLTheme label:@"Privacy defaults" font:[GLTheme medium:11] color:[GLTheme sub]],
        r1, r2, r3, about
    ] spacing:12];
    col.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:col];
    [NSLayoutConstraint activateConstraints:@[
        [col.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [col.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [col.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16]
    ]];
}
- (void)toggle:(UISwitch *)sw {
    NSArray *keys = @[@"defaultInviteOnly", @"removeLocationAfter", @"momentsDownloadable"];
    [[GLStore shared] setSetting:keys[sw.tag - 1] enabled:sw.on];
}
@end

#pragma mark - Me

@interface GLMeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *bioLabel;
@property (nonatomic, strong) UILabel *initialLabel;
@property (nonatomic, strong) UIView *avatarView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *verLabel;
@property (nonatomic, strong) UILabel *stat1;
@property (nonatomic, strong) UILabel *stat2;
@property (nonatomic, strong) UILabel *stat3;
@property (nonatomic, strong) UILabel *privHead;
@property (nonatomic, strong) UILabel *privSub;
@property (nonatomic, strong) UIView *privBadge;
@end

@implementation GLMeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [GLTheme bg];
    UIScrollView *scroll = [UIScrollView new];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    scroll.alwaysBounceVertical = YES;
    scroll.contentInset = UIEdgeInsetsMake(0, 0, 28, 0);
    scroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:scroll];
    UIView *c = [UIView new];
    c.translatesAutoresizingMaskIntoConstraints = NO;
    [scroll addSubview:c];

    UILabel *over = [GLTheme label:@"Your space" font:[GLTheme medium:11] color:[GLTheme sub]];
    UILabel *title = [GLTheme label:@"Me & Privacy" font:[GLTheme display:28] color:[GLTheme ink]];
    UIButton *gear = [GLTheme circleSymbol:@"slider.horizontal.3" bg:[GLTheme line] tint:[GLTheme ink] size:36];
    [gear addTarget:self action:@selector(openSettings) forControlEvents:UIControlEventTouchUpInside];
    gear.accessibilityLabel = @"Settings";

    UIView *profile = [GLTheme card:24];
    [GLTheme gradient:profile colors:@[[GLTheme hex:0xF3E8FF], [UIColor whiteColor]] start:CGPointMake(0, 0) end:CGPointMake(1, 1)];
    UIView *av = [UIView new];
    av.translatesAutoresizingMaskIntoConstraints = NO;
    av.layer.cornerRadius = 18;
    av.clipsToBounds = YES;
    [GLTheme gradient:av colors:@[[GLTheme purple], [GLTheme coral]] start:CGPointMake(0, 0) end:CGPointMake(1, 1)];
    self.avatarView = av;
    self.initialLabel = [GLTheme label:@"M" font:[GLTheme display:28] color:UIColor.whiteColor];
    [av addSubview:self.initialLabel];
    self.avatarImageView = [UIImageView new];
    self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 18;
    self.avatarImageView.hidden = YES;
    [av addSubview:self.avatarImageView];
    [GLTheme pin:self.avatarImageView to:av insets:UIEdgeInsetsZero];
    UIButton *avatarTap = [UIButton buttonWithType:UIButtonTypeCustom];
    avatarTap.translatesAutoresizingMaskIntoConstraints = NO;
    avatarTap.backgroundColor = UIColor.clearColor;
    avatarTap.accessibilityLabel = @"Change avatar photo";
    [avatarTap addTarget:self action:@selector(changeAvatar) forControlEvents:UIControlEventTouchUpInside];
    UIButton *edit = [GLTheme circleSymbol:@"pencil" bg:UIColor.whiteColor tint:[GLTheme ink] size:26];
    [edit addTarget:self action:@selector(editProfile) forControlEvents:UIControlEventTouchUpInside];
    self.nameLabel = [GLTheme label:@"" font:[GLTheme title:18] color:[GLTheme ink]];
    self.bioLabel = [GLTheme label:@"" font:[GLTheme regular:13] color:[GLTheme sub]];
    self.bioLabel.numberOfLines = 2;
    self.verLabel = [GLTheme label:@"" font:[GLTheme medium:12] color:[GLTheme hex:0x2FA36B]];
    [profile addSubview:av]; [profile addSubview:avatarTap]; [profile addSubview:edit]; [profile addSubview:self.nameLabel]; [profile addSubview:self.bioLabel]; [profile addSubview:self.verLabel];

    UIView *stats = [GLTheme card:20];
    self.stat1 = [self stat:@"0" sub:@"Gatherings"];
    self.stat2 = [self stat:@"0" sub:@"Moments"];
    self.stat3 = [self stat:@"0" sub:@"Capsules"];
    UIView *l1 = [self vline]; UIView *l2 = [self vline];
    [stats addSubview:self.stat1]; [stats addSubview:l1]; [stats addSubview:self.stat2]; [stats addSubview:l2]; [stats addSubview:self.stat3];

    UIView *priv = [GLTheme card:20];
    priv.backgroundColor = [GLTheme hex:0xDFF6EA];
    UILabel *pc = [GLTheme label:@"Privacy check" font:[GLTheme medium:10] color:[GLTheme hex:0x1F7A4C]];
    self.privHead = [GLTheme label:@"" font:[GLTheme title:16] color:[GLTheme ink]];
    self.privHead.numberOfLines = 0;
    self.privBadge = [GLTheme pill:@"0 / 4" bg:UIColor.whiteColor fg:[GLTheme ink]];
    self.privSub = [GLTheme label:@"" font:[GLTheme regular:11] color:[GLTheme sub]];
    self.privSub.numberOfLines = 0;
    [priv addSubview:pc]; [priv addSubview:self.privHead]; [priv addSubview:self.privBadge]; [priv addSubview:self.privSub];
    UITapGestureRecognizer *tapPriv = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openSettings)];
    [priv addGestureRecognizer:tapPriv];
    priv.userInteractionEnabled = YES;

    UILabel *g1 = [GLTheme label:@"Your GatherLoop" font:[GLTheme medium:11] color:[GLTheme sub]];
    UIView *list1 = [self group:@[
        @[@"person.crop.circle", @"Profile & Preferences", @"Name, avatar, dietary notes"],
        @[@"bell", @"Notifications", @"Tasks, invites, and capsule unlocks"],
        @[@"tray.and.arrow.down", @"My data", @"Export or delete your info"]
    ]];
    UILabel *g2 = [GLTheme label:@"Support" font:[GLTheme medium:11] color:[GLTheme sub]];
    UIView *list2 = [self group:@[
        @[@"bubble.left", @"Send feedback", @""],
        @[@"exclamationmark.shield", @"Safety & blocked guests", @""],
        @[@"questionmark.circle", @"Help center", @""]
    ]];

    for (UIView *v in @[over, title, gear, profile, stats, priv, g1, list1, g2, list2]) [c addSubview:v];
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
        [over.topAnchor constraintEqualToAnchor:c.topAnchor constant:8],
        [over.leadingAnchor constraintEqualToAnchor:c.leadingAnchor constant:20],
        [title.topAnchor constraintEqualToAnchor:over.bottomAnchor constant:4],
        [title.leadingAnchor constraintEqualToAnchor:over.leadingAnchor],
        [gear.centerYAnchor constraintEqualToAnchor:title.centerYAnchor],
        [gear.trailingAnchor constraintEqualToAnchor:c.trailingAnchor constant:-20],
        [profile.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:16],
        [profile.leadingAnchor constraintEqualToAnchor:c.leadingAnchor constant:16],
        [profile.trailingAnchor constraintEqualToAnchor:c.trailingAnchor constant:-16],
        [av.leadingAnchor constraintEqualToAnchor:profile.leadingAnchor constant:14],
        [av.topAnchor constraintEqualToAnchor:profile.topAnchor constant:14],
        [av.widthAnchor constraintEqualToConstant:64],
        [av.heightAnchor constraintEqualToConstant:64],
        [av.bottomAnchor constraintEqualToAnchor:profile.bottomAnchor constant:-14],
        [avatarTap.leadingAnchor constraintEqualToAnchor:av.leadingAnchor],
        [avatarTap.topAnchor constraintEqualToAnchor:av.topAnchor],
        [avatarTap.widthAnchor constraintEqualToAnchor:av.widthAnchor],
        [avatarTap.heightAnchor constraintEqualToAnchor:av.heightAnchor],
        [self.initialLabel.centerXAnchor constraintEqualToAnchor:av.centerXAnchor],
        [self.initialLabel.centerYAnchor constraintEqualToAnchor:av.centerYAnchor],
        [edit.trailingAnchor constraintEqualToAnchor:av.trailingAnchor constant:6],
        [edit.bottomAnchor constraintEqualToAnchor:av.bottomAnchor constant:6],
        [self.nameLabel.leadingAnchor constraintEqualToAnchor:av.trailingAnchor constant:12],
        [self.nameLabel.topAnchor constraintEqualToAnchor:av.topAnchor constant:4],
        [self.bioLabel.leadingAnchor constraintEqualToAnchor:self.nameLabel.leadingAnchor],
        [self.bioLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:2],
        [self.bioLabel.trailingAnchor constraintEqualToAnchor:profile.trailingAnchor constant:-12],
        [self.verLabel.leadingAnchor constraintEqualToAnchor:self.nameLabel.leadingAnchor],
        [self.verLabel.topAnchor constraintEqualToAnchor:self.bioLabel.bottomAnchor constant:6],
        [stats.topAnchor constraintEqualToAnchor:profile.bottomAnchor constant:12],
        [stats.leadingAnchor constraintEqualToAnchor:profile.leadingAnchor],
        [stats.trailingAnchor constraintEqualToAnchor:profile.trailingAnchor],
        [stats.heightAnchor constraintEqualToConstant:78],
        [self.stat1.leadingAnchor constraintEqualToAnchor:stats.leadingAnchor],
        [self.stat1.centerYAnchor constraintEqualToAnchor:stats.centerYAnchor],
        [self.stat1.widthAnchor constraintEqualToAnchor:stats.widthAnchor multiplier:0.33],
        [l1.leadingAnchor constraintEqualToAnchor:self.stat1.trailingAnchor],
        [l1.centerYAnchor constraintEqualToAnchor:stats.centerYAnchor],
        [l1.widthAnchor constraintEqualToConstant:1],
        [l1.heightAnchor constraintEqualToConstant:36],
        [self.stat2.leadingAnchor constraintEqualToAnchor:l1.trailingAnchor],
        [self.stat2.centerYAnchor constraintEqualToAnchor:stats.centerYAnchor],
        [self.stat2.widthAnchor constraintEqualToAnchor:self.stat1.widthAnchor],
        [l2.leadingAnchor constraintEqualToAnchor:self.stat2.trailingAnchor],
        [l2.centerYAnchor constraintEqualToAnchor:l1.centerYAnchor],
        [l2.widthAnchor constraintEqualToConstant:1],
        [l2.heightAnchor constraintEqualToAnchor:l1.heightAnchor],
        [self.stat3.leadingAnchor constraintEqualToAnchor:l2.trailingAnchor],
        [self.stat3.trailingAnchor constraintEqualToAnchor:stats.trailingAnchor],
        [self.stat3.centerYAnchor constraintEqualToAnchor:stats.centerYAnchor],
        [priv.topAnchor constraintEqualToAnchor:stats.bottomAnchor constant:12],
        [priv.leadingAnchor constraintEqualToAnchor:stats.leadingAnchor],
        [priv.trailingAnchor constraintEqualToAnchor:stats.trailingAnchor],
        [pc.topAnchor constraintEqualToAnchor:priv.topAnchor constant:14],
        [pc.leadingAnchor constraintEqualToAnchor:priv.leadingAnchor constant:14],
        [self.privBadge.trailingAnchor constraintEqualToAnchor:priv.trailingAnchor constant:-12],
        [self.privBadge.centerYAnchor constraintEqualToAnchor:pc.centerYAnchor],
        [self.privHead.topAnchor constraintEqualToAnchor:pc.bottomAnchor constant:6],
        [self.privHead.leadingAnchor constraintEqualToAnchor:pc.leadingAnchor],
        [self.privHead.trailingAnchor constraintEqualToAnchor:priv.trailingAnchor constant:-14],
        [self.privSub.topAnchor constraintEqualToAnchor:self.privHead.bottomAnchor constant:8],
        [self.privSub.leadingAnchor constraintEqualToAnchor:pc.leadingAnchor],
        [self.privSub.trailingAnchor constraintEqualToAnchor:self.privHead.trailingAnchor],
        [self.privSub.bottomAnchor constraintEqualToAnchor:priv.bottomAnchor constant:-14],
        [g1.topAnchor constraintEqualToAnchor:priv.bottomAnchor constant:20],
        [g1.leadingAnchor constraintEqualToAnchor:priv.leadingAnchor],
        [list1.topAnchor constraintEqualToAnchor:g1.bottomAnchor constant:8],
        [list1.leadingAnchor constraintEqualToAnchor:priv.leadingAnchor],
        [list1.trailingAnchor constraintEqualToAnchor:priv.trailingAnchor],
        [g2.topAnchor constraintEqualToAnchor:list1.bottomAnchor constant:18],
        [g2.leadingAnchor constraintEqualToAnchor:g1.leadingAnchor],
        [list2.topAnchor constraintEqualToAnchor:g2.bottomAnchor constant:8],
        [list2.leadingAnchor constraintEqualToAnchor:list1.leadingAnchor],
        [list2.trailingAnchor constraintEqualToAnchor:list1.trailingAnchor],
        [list2.bottomAnchor constraintEqualToAnchor:c.bottomAnchor constant:-24]
    ]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUI) name:GLStoreDidChangeNotification object:nil];
    [self refreshUI];
}
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self refreshUI];
}
- (void)setStatLabel:(UILabel *)l value:(NSString *)v sub:(NSString *)sub {
    NSMutableAttributedString *a = [[NSMutableAttributedString alloc] initWithString:v attributes:@{NSFontAttributeName:[GLTheme title:22], NSForegroundColorAttributeName:[GLTheme ink]}];
    [a appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", sub] attributes:@{NSFontAttributeName:[GLTheme regular:12], NSForegroundColorAttributeName:[GLTheme sub]}]];
    l.attributedText = a;
}
- (void)refreshUI {
    GLStore *st = [GLStore shared];
    NSString *name = st.user[@"name"] ?: @"";
    self.nameLabel.text = name.length ? name : @"No name set";
    self.bioLabel.text = st.user[@"bio"] ?: @"";
    NSString *ini = st.user[@"initial"] ?: @"?";
    self.initialLabel.text = ini.length ? ini : @"?";
    NSString *avatarPath = [st.user[@"avatarPath"] isKindOfClass:[NSString class]] ? st.user[@"avatarPath"] : @"";
    UIImage *avatarImage = avatarPath.length ? [UIImage imageWithContentsOfFile:avatarPath] : nil;
    self.avatarImageView.image = avatarImage;
    self.avatarImageView.hidden = (avatarImage == nil);
    self.initialLabel.hidden = (avatarImage != nil);
    BOOL verified = [st.user[@"emailVerified"] boolValue];
    self.verLabel.text = verified ? @"✓  Email verified" : @"!  Please verify your email";
    self.verLabel.textColor = verified ? [GLTheme hex:0x2FA36B] : [GLTheme coral];
    [self setStatLabel:self.stat1 value:[NSString stringWithFormat:@"%ld", (long)[st.user[@"gatherings"] integerValue]] sub:@"Gatherings"];
    [self setStatLabel:self.stat2 value:[NSString stringWithFormat:@"%ld", (long)[st.user[@"moments"] integerValue]] sub:@"Moments"];
    [self setStatLabel:self.stat3 value:[NSString stringWithFormat:@"%ld", (long)[st.user[@"capsules"] integerValue]] sub:@"Capsules"];
    NSInteger pass = [st privacyPassCount];
    self.privHead.text = pass >= 4 ? @"Your shared moments are protected" : [NSString stringWithFormat:@"%ld more ways to strengthen privacy", (long)(4 - pass)];
    self.privSub.text = [st privacySummaryLine];
    for (UIView *sub in self.privBadge.subviews) {
        if ([sub isKindOfClass:[UILabel class]]) {
            ((UILabel *)sub).text = [NSString stringWithFormat:@"%ld / 4", (long)pass];
        }
    }
}
- (UILabel *)stat:(NSString *)v sub:(NSString *)sub {
    UILabel *l = [UILabel new];
    l.translatesAutoresizingMaskIntoConstraints = NO;
    l.numberOfLines = 2;
    l.textAlignment = NSTextAlignmentCenter;
    [self setStatLabel:l value:v sub:sub];
    return l;
}
- (UIView *)vline {
    UIView *v = [UIView new];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = [GLTheme line];
    return v;
}
- (UIView *)group:(NSArray *)rows {
    UIView *box = [GLTheme card:20];
    UIStackView *s = [UIStackView new];
    s.translatesAutoresizingMaskIntoConstraints = NO;
    s.axis = UILayoutConstraintAxisVertical;
    [box addSubview:s];
    [GLTheme pin:s to:box insets:UIEdgeInsetsMake(6, 0, 6, 0)];
    for (NSArray *r in rows) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.accessibilityLabel = r[1];
        [b addTarget:self action:@selector(page:) forControlEvents:UIControlEventTouchUpInside];
        UIView *icon = [GLTheme iconBox:r[0] bg:[GLTheme bg] tint:[GLTheme ink] size:36 radius:10];
        icon.userInteractionEnabled = NO;
        UILabel *t = [GLTheme label:r[1] font:[GLTheme title:15] color:[GLTheme ink]];
        UILabel *sub = [GLTheme label:r[2] font:[GLTheme regular:12] color:[GLTheme sub]];
        UIImageView *ch = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
        ch.translatesAutoresizingMaskIntoConstraints = NO;
        ch.tintColor = [GLTheme muted];
        [b addSubview:icon]; [b addSubview:t]; [b addSubview:sub]; [b addSubview:ch];
        [NSLayoutConstraint activateConstraints:@[
            [b.heightAnchor constraintGreaterThanOrEqualToConstant:64],
            [icon.leadingAnchor constraintEqualToAnchor:b.leadingAnchor constant:14],
            [icon.centerYAnchor constraintEqualToAnchor:b.centerYAnchor],
            [t.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:10],
            [t.topAnchor constraintEqualToAnchor:b.topAnchor constant:[r[2] length] ? 12 : 22],
            [sub.leadingAnchor constraintEqualToAnchor:t.leadingAnchor],
            [sub.topAnchor constraintEqualToAnchor:t.bottomAnchor constant:2],
            [ch.trailingAnchor constraintEqualToAnchor:b.trailingAnchor constant:-14],
            [ch.centerYAnchor constraintEqualToAnchor:b.centerYAnchor]
        ]];
        [s addArrangedSubview:b];
    }
    return box;
}
- (void)openSettings { GLPush(self, [GLSettingsVC new]); }
- (void)page:(UIButton *)b {
    NSString *t = b.accessibilityLabel ?: @"";
    UIViewController *vc = nil;
    if ([t isEqualToString:@"Profile & Preferences"]) vc = [GLProfilePrefsVC new];
    else if ([t isEqualToString:@"Notifications"]) vc = [GLNotificationsVC new];
    else if ([t isEqualToString:@"My data"]) vc = [GLMyDataVC new];
    else if ([t isEqualToString:@"Send feedback"]) vc = [GLFeedbackVC new];
    else if ([t isEqualToString:@"Safety & blocked guests"]) vc = [GLSafetyVC new];
    else if ([t isEqualToString:@"Help center"]) vc = [GLHelpVC new];
    else vc = [GLSettingsVC new];
    GLPush(self, vc);
}
- (void)editProfile {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"Edit profile" message:@"Update your gathering identity." preferredStyle:UIAlertControllerStyleActionSheet];
    [menu addAction:[UIAlertAction actionWithTitle:@"Change avatar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self changeAvatar]; });
    }]];
    [menu addAction:[UIAlertAction actionWithTitle:@"Edit details" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self editProfileDetails]; });
    }]];
    [menu addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    if (menu.popoverPresentationController) {
        menu.popoverPresentationController.sourceView = self.avatarView;
        menu.popoverPresentationController.sourceRect = self.avatarView.bounds;
    }
    [self presentViewController:menu animated:YES completion:nil];
}
- (void)editProfileDetails {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Edit profile" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.text = [GLStore shared].user[@"name"]; tf.placeholder = @"Name"; }];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.text = [GLStore shared].user[@"bio"]; tf.placeholder = @"Bio"; }];
    [a addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [a addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        GLStore *st = [GLStore shared];
        [st updateProfileName:a.textFields[0].text bio:a.textFields[1].text dietary:st.user[@"dietary"] email:st.user[@"email"]];
    }]];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)changeAvatar {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"Change avatar" message:@"Choose a new photo for your gathering profile." preferredStyle:UIAlertControllerStyleActionSheet];
    [menu addAction:[UIAlertAction actionWithTitle:@"Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self requestPhotoAccessAndPresent]; });
    }]];
    [menu addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self requestCameraAccessAndPresent]; });
    }]];
    [menu addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    if (menu.popoverPresentationController) {
        menu.popoverPresentationController.sourceView = self.avatarView;
        menu.popoverPresentationController.sourceRect = self.avatarView.bounds;
    }
    [self presentViewController:menu animated:YES completion:nil];
}
- (void)requestPhotoAccessAndPresent {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
        [self showMediaSettingsFor:@"Photos"];
        return;
    }
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus newStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (newStatus == PHAuthorizationStatusAuthorized || newStatus == PHAuthorizationStatusLimited) {
                    [self presentAvatarPicker:UIImagePickerControllerSourceTypePhotoLibrary];
                } else {
                    [self showMediaSettingsFor:@"Photos"];
                }
            });
        }];
        return;
    }
    [self presentAvatarPicker:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (void)requestCameraAccessAndPresent {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        [self showMediaSettingsFor:@"Camera"];
        return;
    }
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) [self presentAvatarPicker:UIImagePickerControllerSourceTypeCamera];
                else [self showMediaSettingsFor:@"Camera"];
            });
        }];
        return;
    }
    [self presentAvatarPicker:UIImagePickerControllerSourceTypeCamera];
}
- (void)presentAvatarPicker:(UIImagePickerControllerSourceType)sourceType {
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        NSString *message = sourceType == UIImagePickerControllerSourceTypeCamera
            ? @"This device does not have a camera. Choose Photos instead."
            : @"Photos are unavailable on this device.";
        UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Unavailable" message:message preferredStyle:UIAlertControllerStyleAlert];
        [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:a animated:YES completion:nil];
        return;
    }
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:picker animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage] ?: info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        if (image) [self saveAvatarImage:image];
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)saveAvatarImage:(UIImage *)image {
    NSData *data = UIImageJPEGRepresentation(image, 0.88);
    if (!data) {
        [self showMediaMessage:@"Avatar unavailable" message:@"Choose another image and try again."];
        return;
    }
    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *folder = [documents stringByAppendingPathComponent:@"Avatars"];
    [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *path = [folder stringByAppendingPathComponent:@"profile-avatar.jpg"];
    if (![data writeToFile:path atomically:YES]) {
        [self showMediaMessage:@"Could not save avatar" message:@"Please try again."];
        return;
    }
    [GLStore shared].user[@"avatarPath"] = path;
    [[GLStore shared] notify];
}
- (void)showMediaSettingsFor:(NSString *)feature {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ access is off", feature]
                                                                  message:[NSString stringWithFormat:@"Allow %@ access in Settings to change your gathering avatar.", feature.lowercaseString]
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"Not now" style:UIAlertActionStyleCancel handler:nil]];
    [a addAction:[UIAlertAction actionWithTitle:@"Open Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (url) [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }]];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)showMediaMessage:(NSString *)title message:(NSString *)message {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
@end
