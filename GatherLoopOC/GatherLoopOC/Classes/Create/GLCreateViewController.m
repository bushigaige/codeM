#import "GLCreateViewController.h"
#import "GLTheme.h"
#import "GLStore.h"
#import "GLSmartPlanViewController.h"

@interface GLCreateViewController () <UITextFieldDelegate>
@property (nonatomic) NSInteger step;
@property (nonatomic, strong) UIView *bar1;
@property (nonatomic, strong) UIView *bar2;
@property (nonatomic, strong) UIView *bar3;
@property (nonatomic, strong) UIView *bar4;
@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) UILabel *heading;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) NSArray<UIButton *> *vibeButtons;
@property (nonatomic, copy) NSString *vibe;
@property (nonatomic, strong) UILabel *dateVal;
@property (nonatomic, strong) UILabel *timeVal;
@property (nonatomic, strong) UILabel *guestVal;
@property (nonatomic, strong) UILabel *budgetVal;
@property (nonatomic, strong) UISwitch *inviteSwitch;
@property (nonatomic, strong) UIButton *continueBtn;
@property (nonatomic, strong) UITextField *placeField;
@property (nonatomic, strong) UIView *basicsBox;
@property (nonatomic, strong) UIView *placeBox;
@end

@implementation GLCreateViewController
- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleDarkContent; }
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [GLTheme bg];
    self.step = 1;
    self.vibe = [GLStore shared].gathering[@"vibe"] ?: @"Laid-back";
    [self build];
    [self renderStep];
}
- (void)build {
    UIButton *close = [GLTheme circleSymbol:@"xmark" bg:[GLTheme line] tint:[GLTheme ink] size:36];
    [close addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    UILabel *nav = [GLTheme label:@"Create Gathering" font:[GLTheme title:16] color:[GLTheme ink]];
    UIButton *save = [UIButton buttonWithType:UIButtonTypeSystem];
    save.translatesAutoresizingMaskIntoConstraints = NO;
    [save setTitle:@"Save" forState:UIControlStateNormal];
    [save setTitleColor:[GLTheme purple] forState:UIControlStateNormal];
    save.titleLabel.font = [GLTheme title:16];
    [save addTarget:self action:@selector(persist) forControlEvents:UIControlEventTouchUpInside];

    UIStackView *bars = [UIStackView new];
    bars.translatesAutoresizingMaskIntoConstraints = NO;
    bars.spacing = 6;
    bars.distribution = UIStackViewDistributionFillEqually;
    self.bar1 = [self seg]; self.bar2 = [self seg]; self.bar3 = [self seg]; self.bar4 = [self seg];
    for (UIView *b in @[self.bar1, self.bar2, self.bar3, self.bar4]) [bars addArrangedSubview:b];

    self.continueBtn = [GLTheme fillButton:@"Continue to location  →" bg:[GLTheme navy] fg:UIColor.whiteColor radius:22];
    [self.continueBtn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:close];
    [self.view addSubview:nav];
    [self.view addSubview:save];
    [self.view addSubview:bars];
    [self.view addSubview:self.continueBtn];

    UIView *content = nil;
    [GLTheme embedScrollIn:self.view content:&content top:bars.bottomAnchor bottom:self.continueBtn.topAnchor];

    self.stepLabel = [GLTheme label:@"" font:[GLTheme medium:11] color:[GLTheme sub]];
    UIView *pop = [GLTheme iconBox:@"sparkles" bg:[GLTheme softCoral] tint:[GLTheme coral] size:36 radius:12];
    self.heading = [GLTheme label:@"" font:[GLTheme display:26] color:[GLTheme ink]];
    self.heading.numberOfLines = 0;
    UILabel *hint = [GLTheme label:@"You can edit anytime." font:[GLTheme regular:13] color:[GLTheme sub]];

    self.basicsBox = [self makeBasics];
    self.placeBox = [self makePlace];

    UIStackView *col = [GLTheme column:@[self.stepLabel, pop, self.heading, hint, self.basicsBox, self.placeBox] spacing:10];
    [content addSubview:col];
    [NSLayoutConstraint activateConstraints:@[
        [close.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:8],
        [close.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [nav.centerYAnchor constraintEqualToAnchor:close.centerYAnchor],
        [nav.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [nav.leadingAnchor constraintGreaterThanOrEqualToAnchor:close.trailingAnchor constant:8],
        [nav.trailingAnchor constraintLessThanOrEqualToAnchor:save.leadingAnchor constant:-8],
        [save.centerYAnchor constraintEqualToAnchor:close.centerYAnchor],
        [save.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-18],
        [bars.topAnchor constraintEqualToAnchor:close.bottomAnchor constant:14],
        [bars.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [bars.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [bars.heightAnchor constraintEqualToConstant:6],
        [self.continueBtn.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.continueBtn.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.continueBtn.heightAnchor constraintEqualToConstant:56],
        [self.continueBtn.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-10],
        [col.topAnchor constraintEqualToAnchor:content.topAnchor constant:18],
        [col.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:20],
        [col.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-20],
        [col.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-16]
    ]];
    [self.nameField addTarget:self action:@selector(nameChanged) forControlEvents:UIControlEventEditingChanged];
    [self nameChanged];
    [self pickVibeNamed:self.vibe];
}
- (UIView *)makeBasics {
    UILabel *nameL = [GLTheme label:@"Gathering name" font:[GLTheme medium:14] color:[GLTheme ink]];
    self.nameField = [UITextField new];
    self.nameField.translatesAutoresizingMaskIntoConstraints = NO;
    self.nameField.text = [GLStore shared].gathering[@"name"];
    self.nameField.font = [GLTheme title:16];
    self.nameField.delegate = self;
    UIView *nameBox = [GLTheme card:16];
    nameBox.layer.borderWidth = 1.5;
    nameBox.layer.borderColor = [GLTheme purple].CGColor;
    self.countLabel = [GLTheme label:@"0 / 40" font:[GLTheme regular:12] color:[GLTheme sub]];
    [nameBox addSubview:self.nameField];
    [nameBox addSubview:self.countLabel];

    UILabel *vibeL = [GLTheme label:@"Vibe" font:[GLTheme medium:14] color:[GLTheme ink]];
    UIStackView *vibes = [UIStackView new];
    vibes.translatesAutoresizingMaskIntoConstraints = NO;
    vibes.spacing = 8;
    vibes.distribution = UIStackViewDistributionFillEqually;
    NSArray *vs = @[@"sun.max.fill|Laid-back", @"music.note|High energy", @"fork.knife|Food first", @"sparkles|Surprise me"];
    NSMutableArray *btns = [NSMutableArray array];
    for (NSInteger i = 0; i < vs.count; i++) {
        NSArray *p = [vs[i] componentsSeparatedByString:@"|"];
        UIButton *b = [self vibeBtn:p[0] title:p[1]];
        b.tag = i;
        [b addTarget:self action:@selector(pickVibe:) forControlEvents:UIControlEventTouchUpInside];
        [vibes addArrangedSubview:b];
        [btns addObject:b];
    }
    self.vibeButtons = btns;

    UILabel *dt = [GLTheme label:@"Date & time" font:[GLTheme medium:14] color:[GLTheme ink]];
    UIView *dateBox = [self valueBox:@"calendar" cap:@"Date" val:[GLStore shared].gathering[@"dateText"] valRef:&_dateVal action:@selector(editDate)];
    UIView *timeBox = [self valueBox:@"clock" cap:@"Start" val:[GLStore shared].gathering[@"timeText"] valRef:&_timeVal action:@selector(editTime)];
    UIStackView *dtRow = [[UIStackView alloc] initWithArrangedSubviews:@[dateBox, timeBox]];
    dtRow.translatesAutoresizingMaskIntoConstraints = NO;
    dtRow.spacing = 12;
    dtRow.distribution = UIStackViewDistributionFillEqually;

    UILabel *pb = [GLTheme label:@"Guests & budget" font:[GLTheme medium:14] color:[GLTheme ink]];
    UIView *guestBox = [self valueBox:@"person" cap:@"Guests" val:[NSString stringWithFormat:@"%@ guests", [GLStore shared].gathering[@"guestCount"]] valRef:&_guestVal action:@selector(editGuests)];
    UIView *budBox = [self valueBox:@"creditcard" cap:@"Total" val:[NSString stringWithFormat:@"$%@", [GLStore shared].gathering[@"budget"]] valRef:&_budgetVal action:@selector(editBudget)];
    UIStackView *pbRow = [[UIStackView alloc] initWithArrangedSubviews:@[guestBox, budBox]];
    pbRow.translatesAutoresizingMaskIntoConstraints = NO;
    pbRow.spacing = 12;
    pbRow.distribution = UIStackViewDistributionFillEqually;

    UIView *invite = [GLTheme card:18];
    invite.backgroundColor = [GLTheme softPurple];
    UIView *lock = [GLTheme iconBox:@"lock.fill" bg:UIColor.whiteColor tint:[GLTheme purple] size:36 radius:10];
    UILabel *it = [GLTheme label:@"Invite only" font:[GLTheme title:15] color:[GLTheme ink]];
    UILabel *isub = [GLTheme label:@"Only approved guests can see moments" font:[GLTheme regular:12] color:[GLTheme sub]];
    isub.numberOfLines = 2;
    self.inviteSwitch = [UISwitch new];
    self.inviteSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    self.inviteSwitch.onTintColor = [GLTheme purple];
    self.inviteSwitch.on = [[GLStore shared].gathering[@"inviteOnly"] boolValue];
    [invite addSubview:lock]; [invite addSubview:it]; [invite addSubview:isub]; [invite addSubview:self.inviteSwitch];

    UIStackView *col = [GLTheme column:@[nameL, nameBox, vibeL, vibes, dt, dtRow, pb, pbRow, invite] spacing:8];
    [col setCustomSpacing:16 afterView:nameBox];
    [col setCustomSpacing:16 afterView:vibes];
    [col setCustomSpacing:16 afterView:dtRow];
    [NSLayoutConstraint activateConstraints:@[
        [nameBox.heightAnchor constraintEqualToConstant:52],
        [self.nameField.leadingAnchor constraintEqualToAnchor:nameBox.leadingAnchor constant:14],
        [self.nameField.centerYAnchor constraintEqualToAnchor:nameBox.centerYAnchor],
        [self.nameField.trailingAnchor constraintEqualToAnchor:self.countLabel.leadingAnchor constant:-8],
        [self.countLabel.trailingAnchor constraintEqualToAnchor:nameBox.trailingAnchor constant:-12],
        [self.countLabel.centerYAnchor constraintEqualToAnchor:nameBox.centerYAnchor],
        [vibes.heightAnchor constraintEqualToConstant:76],
        [dateBox.heightAnchor constraintEqualToConstant:70],
        [guestBox.heightAnchor constraintEqualToConstant:70],
        [lock.leadingAnchor constraintEqualToAnchor:invite.leadingAnchor constant:12],
        [lock.centerYAnchor constraintEqualToAnchor:invite.centerYAnchor],
        [it.leadingAnchor constraintEqualToAnchor:lock.trailingAnchor constant:10],
        [it.topAnchor constraintEqualToAnchor:invite.topAnchor constant:14],
        [it.trailingAnchor constraintLessThanOrEqualToAnchor:self.inviteSwitch.leadingAnchor constant:-8],
        [isub.leadingAnchor constraintEqualToAnchor:it.leadingAnchor],
        [isub.topAnchor constraintEqualToAnchor:it.bottomAnchor constant:2],
        [isub.trailingAnchor constraintEqualToAnchor:self.inviteSwitch.leadingAnchor constant:-8],
        [isub.bottomAnchor constraintEqualToAnchor:invite.bottomAnchor constant:-14],
        [self.inviteSwitch.trailingAnchor constraintEqualToAnchor:invite.trailingAnchor constant:-12],
        [self.inviteSwitch.centerYAnchor constraintEqualToAnchor:invite.centerYAnchor]
    ]];
    return col;
}
- (UIView *)makePlace {
    UILabel *locL = [GLTheme label:@"Location?" font:[GLTheme medium:14] color:[GLTheme ink]];
    self.placeField = [UITextField new];
    self.placeField.translatesAutoresizingMaskIntoConstraints = NO;
    self.placeField.text = [GLStore shared].gathering[@"location"];
    self.placeField.font = [GLTheme title:16];
    UIView *box = [GLTheme card:16];
    box.layer.borderWidth = 1;
    box.layer.borderColor = [GLTheme line].CGColor;
    [box addSubview:self.placeField];
    UIStackView *col = [GLTheme column:@[locL, box] spacing:8];
    [NSLayoutConstraint activateConstraints:@[
        [box.heightAnchor constraintEqualToConstant:52],
        [self.placeField.leadingAnchor constraintEqualToAnchor:box.leadingAnchor constant:14],
        [self.placeField.trailingAnchor constraintEqualToAnchor:box.trailingAnchor constant:-14],
        [self.placeField.centerYAnchor constraintEqualToAnchor:box.centerYAnchor]
    ]];
    return col;
}
- (UIView *)seg {
    UIView *v = [UIView new];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.backgroundColor = [GLTheme line];
    v.layer.cornerRadius = 3;
    return v;
}
- (UIButton *)vibeBtn:(NSString *)icon title:(NSString *)title {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.translatesAutoresizingMaskIntoConstraints = NO;
    b.backgroundColor = UIColor.whiteColor;
    b.layer.cornerRadius = 16;
    b.layer.borderWidth = 1;
    b.layer.borderColor = [GLTheme line].CGColor;
    [b setTitle:[NSString stringWithFormat:@"  %@", title] forState:UIControlStateNormal];
    [b setTitleColor:[GLTheme ink] forState:UIControlStateNormal];
    b.titleLabel.font = [GLTheme medium:11];
    b.titleLabel.numberOfLines = 2;
    b.titleLabel.textAlignment = NSTextAlignmentCenter;
    [b setImage:[UIImage systemImageNamed:icon] forState:UIControlStateNormal];
    b.tintColor = [GLTheme ink];
    return b;
}
- (UIView *)valueBox:(NSString *)icon cap:(NSString *)cap val:(NSString *)val valRef:(UILabel * __strong *)ref action:(SEL)sel {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.translatesAutoresizingMaskIntoConstraints = NO;
    b.backgroundColor = UIColor.whiteColor;
    b.layer.cornerRadius = 16;
    b.layer.borderWidth = 1;
    b.layer.borderColor = [GLTheme line].CGColor;
    [b addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:icon]];
    iv.translatesAutoresizingMaskIntoConstraints = NO;
    iv.tintColor = [GLTheme ink];
    iv.contentMode = UIViewContentModeScaleAspectFit;
    UILabel *c = [GLTheme label:cap font:[GLTheme medium:10] color:[GLTheme sub]];
    UILabel *v = [GLTheme label:val font:[GLTheme title:15] color:[GLTheme ink]];
    v.adjustsFontSizeToFitWidth = YES;
    [b addSubview:iv]; [b addSubview:c]; [b addSubview:v];
    [NSLayoutConstraint activateConstraints:@[
        [iv.leadingAnchor constraintEqualToAnchor:b.leadingAnchor constant:12],
        [iv.topAnchor constraintEqualToAnchor:b.topAnchor constant:12],
        [iv.widthAnchor constraintEqualToConstant:16],
        [iv.heightAnchor constraintEqualToConstant:16],
        [c.leadingAnchor constraintEqualToAnchor:iv.trailingAnchor constant:8],
        [c.centerYAnchor constraintEqualToAnchor:iv.centerYAnchor],
        [v.leadingAnchor constraintEqualToAnchor:b.leadingAnchor constant:12],
        [v.trailingAnchor constraintEqualToAnchor:b.trailingAnchor constant:-12],
        [v.bottomAnchor constraintEqualToAnchor:b.bottomAnchor constant:-12]
    ]];
    if (ref) *ref = v;
    return b;
}
- (void)renderStep {
    NSArray<UIView *> *fills = @[self.bar1, self.bar2, self.bar3, self.bar4];
    for (NSInteger i = 0; i < 4; i++) {
        fills[i].backgroundColor = (i <= self.step) ? [GLTheme coral] : [GLTheme line];
    }
    self.basicsBox.hidden = !(self.step == 1 || self.step == 3);
    self.placeBox.hidden = !(self.step == 2 || self.step == 3);
    if (self.step == 0) {
        self.stepLabel.text = @"Step 1/4 · Inspiration";
        self.heading.text = @"What's the occasion?";
        [self.continueBtn setTitle:@"Continue to basics  →" forState:UIControlStateNormal];
        self.basicsBox.hidden = YES;
        self.placeBox.hidden = YES;
    } else if (self.step == 1) {
        self.stepLabel.text = @"Step 2/4 · Basics";
        self.heading.text = @"What are we hosting?";
        [self.continueBtn setTitle:@"Continue to location  →" forState:UIControlStateNormal];
    } else if (self.step == 2) {
        self.stepLabel.text = @"Step 3/4 · Location";
        self.heading.text = @"Where is it?";
        [self.continueBtn setTitle:@"Continue with assistant  →" forState:UIControlStateNormal];
    } else {
        self.stepLabel.text = @"Step 4/4 · Done";
        self.heading.text = @"Looking good. Let's build the plan.";
        [self.continueBtn setTitle:@"Open Smart Plan  →" forState:UIControlStateNormal];
    }
}
- (void)pickVibe:(UIButton *)sender {
    NSArray *names = @[@"Laid-back", @"High energy", @"Food first", @"Surprise me"];
    self.vibe = names[sender.tag];
    [self pickVibeNamed:self.vibe];
}
- (void)pickVibeNamed:(NSString *)name {
    NSArray *names = @[@"Laid-back", @"High energy", @"Food first", @"Surprise me"];
    for (NSInteger i = 0; i < self.vibeButtons.count; i++) {
        BOOL on = [names[i] isEqualToString:name];
        UIButton *b = self.vibeButtons[i];
        b.layer.borderColor = (on ? [GLTheme purple] : [GLTheme line]).CGColor;
        b.layer.borderWidth = on ? 2 : 1;
        [b setTitleColor:(on ? [GLTheme purple] : [GLTheme ink]) forState:UIControlStateNormal];
        b.tintColor = on ? [GLTheme purple] : [GLTheme ink];
    }
}
- (void)nameChanged {
    if (self.nameField.text.length > 40) self.nameField.text = [self.nameField.text substringToIndex:40];
    self.countLabel.text = [NSString stringWithFormat:@"%ld / 40", (long)self.nameField.text.length];
}
- (void)editDate {
    self.dateVal.text = @"Sat, Sep 5";
}
- (void)editTime {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Start time" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *t in @[@"5:30 PM", @"6:00 PM", @"6:30 PM", @"7:00 PM"]) {
        [a addAction:[UIAlertAction actionWithTitle:t style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { self.timeVal.text = t; }]];
    }
    [a addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    a.popoverPresentationController.sourceView = self.view;
    [self presentViewController:a animated:YES completion:nil];
}
- (void)editGuests {
    NSInteger n = [self.guestVal.text integerValue];
    if (n < 4) n = 18;
    n = MIN(40, n + 2);
    self.guestVal.text = [NSString stringWithFormat:@"%ld guests", (long)n];
}
- (void)editBudget {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Total budget" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *t in @[@"$180", @"$280", @"$420"]) {
        [a addAction:[UIAlertAction actionWithTitle:t style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { self.budgetVal.text = t; }]];
    }
    [a addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    a.popoverPresentationController.sourceView = self.view;
    [self presentViewController:a animated:YES completion:nil];
}
- (void)persist {
    GLStore *s = [GLStore shared];
    if (self.nameField.text.length) s.gathering[@"name"] = self.nameField.text;
    s.gathering[@"vibe"] = self.vibe;
    s.gathering[@"dateText"] = self.dateVal.text;
    s.gathering[@"timeText"] = self.timeVal.text;
    s.gathering[@"location"] = self.placeField.text ?: @"Riverlight Terrace";
    s.gathering[@"inviteOnly"] = @(self.inviteSwitch.on);
    NSInteger guests = [self.guestVal.text integerValue];
    if (guests > 0) s.gathering[@"guestCount"] = @(guests);
    NSInteger budget = [[self.budgetVal.text stringByReplacingOccurrencesOfString:@"$" withString:@""] integerValue];
    if (budget > 0) s.gathering[@"budget"] = @(budget);
    [s notify];
}
- (void)next {
    [self persist];
    if (self.step < 3) {
        self.step += 1;
        [self renderStep];
        return;
    }
    GLSmartPlanViewController *vc = [GLSmartPlanViewController new];
    vc.fromOnboarding = self.fromOnboarding;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)close { [self dismissViewControllerAnimated:YES completion:nil]; }
@end
