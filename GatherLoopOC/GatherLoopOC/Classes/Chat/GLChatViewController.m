#import "GLChatViewController.h"
#import "GLTheme.h"
#import "GLArt.h"
#import "GLStore.h"
#import "GLEventHubViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface GLChatViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UIStackView *stack;
@property (nonatomic, strong) UITextField *field;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *voicePlayer;
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, strong) NSURL *recordingURL;
@property (nonatomic, assign) NSInteger recordSeconds;
@end

@implementation GLChatViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [GLTheme bg];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:GLStoreDidChangeNotification object:nil];
    UIButton *back = [GLTheme circleSymbol:@"chevron.left" bg:[GLTheme line] tint:[GLTheme ink] size:36];
    [back addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    UIView *icon = [UIView new];
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    icon.layer.cornerRadius = 10;
    [GLTheme gradient:icon colors:@[[GLTheme purple], [GLTheme coral]] start:CGPointMake(0, 0) end:CGPointMake(1, 1)];
    UILabel *name = [GLTheme label:@"Rooftop crew" font:[GLTheme title:16] color:[GLTheme ink]];
    UILabel *sub = [GLTheme label:@"●  12 online  •  Invite only" font:[GLTheme regular:12] color:[GLTheme sub]];
    UIButton *people = [GLTheme circleSymbol:@"person.2" bg:[GLTheme line] tint:[GLTheme ink] size:36];
    [self.view addSubview:back]; [self.view addSubview:icon]; [self.view addSubview:name]; [self.view addSubview:sub]; [self.view addSubview:people];

    UIButton *tasks = [self action:@"checklist" title:@"Tasks" badge:@"3"];
    [tasks addTarget:self action:@selector(openTasks) forControlEvents:UIControlEventTouchUpInside];
    UIButton *split = [self action:@"dollarsign.circle" title:@"Split costs" badge:nil];
    [split addTarget:self action:@selector(split) forControlEvents:UIControlEventTouchUpInside];
    UIButton *loc = [self action:@"mappin.circle" title:@"Location" badge:nil];
    [loc addTarget:self action:@selector(location) forControlEvents:UIControlEventTouchUpInside];

    self.scroll = [UIScrollView new];
    self.scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scroll];
    self.stack = [UIStackView new];
    self.stack.translatesAutoresizingMaskIntoConstraints = NO;
    self.stack.axis = UILayoutConstraintAxisVertical;
    self.stack.spacing = 12;
    [self.scroll addSubview:self.stack];

    UIView *input = [GLTheme card:22];
    input.layer.borderWidth = 1;
    input.layer.borderColor = [GLTheme line].CGColor;
    self.voiceButton = [GLTheme circleSymbol:@"mic.fill" bg:[GLTheme line] tint:[GLTheme ink] size:36];
    self.voiceButton.accessibilityLabel = @"Record voice message";
    [self.voiceButton addTarget:self action:@selector(toggleVoiceRecording) forControlEvents:UIControlEventTouchUpInside];
    self.field = [UITextField new];
    self.field.translatesAutoresizingMaskIntoConstraints = NO;
    self.field.placeholder = @"Message the crew";
    self.field.font = [GLTheme regular:15];
    self.field.delegate = self;
    self.field.returnKeyType = UIReturnKeySend;
    UIButton *send = [GLTheme circleSymbol:@"arrow.up" bg:[GLTheme navy] tint:UIColor.whiteColor size:36];
    [send addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    [input addSubview:self.voiceButton]; [input addSubview:self.field]; [input addSubview:send];
    [self.view addSubview:tasks]; [self.view addSubview:split]; [self.view addSubview:loc]; [self.view addSubview:input];

    [NSLayoutConstraint activateConstraints:@[
        [back.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:6],
        [back.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [icon.leadingAnchor constraintEqualToAnchor:back.trailingAnchor constant:10],
        [icon.centerYAnchor constraintEqualToAnchor:back.centerYAnchor],
        [icon.widthAnchor constraintEqualToConstant:36],
        [icon.heightAnchor constraintEqualToConstant:36],
        [name.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:8],
        [name.topAnchor constraintEqualToAnchor:icon.topAnchor],
        [sub.leadingAnchor constraintEqualToAnchor:name.leadingAnchor],
        [sub.topAnchor constraintEqualToAnchor:name.bottomAnchor],
        [people.centerYAnchor constraintEqualToAnchor:back.centerYAnchor],
        [people.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [tasks.topAnchor constraintEqualToAnchor:back.bottomAnchor constant:14],
        [tasks.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [tasks.heightAnchor constraintEqualToConstant:40],
        [split.centerYAnchor constraintEqualToAnchor:tasks.centerYAnchor],
        [split.leadingAnchor constraintEqualToAnchor:tasks.trailingAnchor constant:8],
        [split.heightAnchor constraintEqualToAnchor:tasks.heightAnchor],
        [loc.centerYAnchor constraintEqualToAnchor:tasks.centerYAnchor],
        [loc.leadingAnchor constraintEqualToAnchor:split.trailingAnchor constant:8],
        [loc.heightAnchor constraintEqualToAnchor:tasks.heightAnchor],
        [self.scroll.topAnchor constraintEqualToAnchor:tasks.bottomAnchor constant:12],
        [self.scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scroll.bottomAnchor constraintEqualToAnchor:input.topAnchor constant:-8],
        [self.stack.topAnchor constraintEqualToAnchor:self.scroll.contentLayoutGuide.topAnchor constant:8],
        [self.stack.bottomAnchor constraintEqualToAnchor:self.scroll.contentLayoutGuide.bottomAnchor constant:-8],
        [self.stack.leadingAnchor constraintEqualToAnchor:self.scroll.frameLayoutGuide.leadingAnchor constant:16],
        [self.stack.trailingAnchor constraintEqualToAnchor:self.scroll.frameLayoutGuide.trailingAnchor constant:-16],
        [self.stack.widthAnchor constraintEqualToAnchor:self.scroll.frameLayoutGuide.widthAnchor constant:-32],
        [input.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [input.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [input.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-8],
        [input.heightAnchor constraintEqualToConstant:52],
        [self.voiceButton.leadingAnchor constraintEqualToAnchor:input.leadingAnchor constant:8],
        [self.voiceButton.centerYAnchor constraintEqualToAnchor:input.centerYAnchor],
        [self.field.leadingAnchor constraintEqualToAnchor:self.voiceButton.trailingAnchor constant:8],
        [self.field.centerYAnchor constraintEqualToAnchor:input.centerYAnchor],
        [self.field.trailingAnchor constraintEqualToAnchor:send.leadingAnchor constant:-8],
        [send.trailingAnchor constraintEqualToAnchor:input.trailingAnchor constant:-8],
        [send.centerYAnchor constraintEqualToAnchor:input.centerYAnchor]
    ]];
    [self reload];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.recordTimer invalidate];
    [self.voicePlayer stop];
}
- (UIButton *)action:(NSString *)icon title:(NSString *)title badge:(NSString *)badge {
    UIButton *b = [GLTheme fillButton:[NSString stringWithFormat:@"  %@", title] bg:[GLTheme line] fg:[GLTheme ink] radius:14];
    [b setImage:[UIImage systemImageNamed:icon] forState:UIControlStateNormal];
    b.tintColor = [GLTheme ink];
    b.titleLabel.font = [GLTheme medium:13];
    if (badge) {
        UILabel *l = [GLTheme label:badge font:[GLTheme title:10] color:UIColor.whiteColor];
        l.backgroundColor = [GLTheme coral];
        l.textAlignment = NSTextAlignmentCenter;
        l.layer.cornerRadius = 8;
        l.clipsToBounds = YES;
        [b addSubview:l];
        [NSLayoutConstraint activateConstraints:@[
            [l.widthAnchor constraintEqualToConstant:16], [l.heightAnchor constraintEqualToConstant:16],
            [l.trailingAnchor constraintEqualToAnchor:b.trailingAnchor constant:4],
            [l.topAnchor constraintEqualToAnchor:b.topAnchor constant:-4]
        ]];
    }
    return b;
}
- (void)reload {
    for (UIView *v in self.stack.arrangedSubviews) [self.stack removeArrangedSubview:v], [v removeFromSuperview];
    UILabel *today = [GLTheme label:@"  Today  " font:[GLTheme medium:11] color:[GLTheme sub]];
    today.textAlignment = NSTextAlignmentCenter;
    [self.stack addArrangedSubview:today];
    for (NSDictionary *m in [GLStore shared].messages) {
        [self.stack addArrangedSubview:[self bubble:m]];
    }
    UILabel *typing = [GLTheme label:@"● ● ●   Noah is typing" font:[GLTheme regular:12] color:[GLTheme sub]];
    [self.stack addArrangedSubview:typing];
}
- (UIView *)bubble:(NSDictionary *)m {
    NSString *kind = m[@"kind"];
    if ([kind isEqualToString:@"task"]) {
        UIView *v = [GLTheme card:16];
        v.backgroundColor = [GLTheme softPurple];
        UILabel *t = [GLTheme label:m[@"title"] font:[GLTheme title:14] color:[GLTheme ink]];
        UILabel *b = [GLTheme label:m[@"body"] font:[GLTheme regular:13] color:[GLTheme ink]];
        UIButton *view = [UIButton buttonWithType:UIButtonTypeSystem];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [view setTitle:@"View" forState:UIControlStateNormal];
        [view setTitleColor:[GLTheme purple] forState:UIControlStateNormal];
        [view addTarget:self action:@selector(openTasks) forControlEvents:UIControlEventTouchUpInside];
        [v addSubview:t]; [v addSubview:b]; [v addSubview:view];
        [NSLayoutConstraint activateConstraints:@[
            [t.topAnchor constraintEqualToAnchor:v.topAnchor constant:12],
            [t.leadingAnchor constraintEqualToAnchor:v.leadingAnchor constant:14],
            [b.topAnchor constraintEqualToAnchor:t.bottomAnchor constant:2],
            [b.leadingAnchor constraintEqualToAnchor:t.leadingAnchor],
            [b.bottomAnchor constraintEqualToAnchor:v.bottomAnchor constant:-12],
            [view.trailingAnchor constraintEqualToAnchor:v.trailingAnchor constant:-14],
            [view.centerYAnchor constraintEqualToAnchor:v.centerYAnchor]
        ]];
        return v;
    }
    if ([kind isEqualToString:@"playlist"]) {
        UIView *wrap = [UIView new];
        GLAvatarView *av = [GLAvatarView initial:m[@"initial"] color:[GLTheme lime] size:28];
        UILabel *meta = [GLTheme label:[NSString stringWithFormat:@"%@ · %@", m[@"name"], m[@"time"]] font:[GLTheme regular:11] color:[GLTheme sub]];
        UIView *card = [GLTheme card:16];
        card.layer.borderWidth = 1;
        card.layer.borderColor = [GLTheme line].CGColor;
        UIView *box = [GLTheme iconBox:@"music.note" bg:[GLTheme lime] tint:[GLTheme ink] size:40 radius:10];
        UILabel *k = [GLTheme label:@"Playlist" font:[GLTheme medium:10] color:[GLTheme sub]];
        UILabel *t = [GLTheme label:m[@"title"] font:[GLTheme title:15] color:[GLTheme ink]];
        UILabel *s = [GLTheme label:m[@"body"] font:[GLTheme regular:12] color:[GLTheme sub]];
        [card addSubview:box]; [card addSubview:k]; [card addSubview:t]; [card addSubview:s];
        [wrap addSubview:av]; [wrap addSubview:meta]; [wrap addSubview:card];
        [NSLayoutConstraint activateConstraints:@[
            [av.leadingAnchor constraintEqualToAnchor:wrap.leadingAnchor],
            [av.topAnchor constraintEqualToAnchor:wrap.topAnchor],
            [meta.leadingAnchor constraintEqualToAnchor:av.trailingAnchor constant:8],
            [meta.centerYAnchor constraintEqualToAnchor:av.centerYAnchor],
            [card.topAnchor constraintEqualToAnchor:av.bottomAnchor constant:6],
            [card.leadingAnchor constraintEqualToAnchor:av.leadingAnchor],
            [card.trailingAnchor constraintEqualToAnchor:wrap.trailingAnchor],
            [card.bottomAnchor constraintEqualToAnchor:wrap.bottomAnchor],
            [box.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:12],
            [box.centerYAnchor constraintEqualToAnchor:card.centerYAnchor],
            [k.leadingAnchor constraintEqualToAnchor:box.trailingAnchor constant:10],
            [k.topAnchor constraintEqualToAnchor:card.topAnchor constant:10],
            [t.leadingAnchor constraintEqualToAnchor:k.leadingAnchor],
            [t.topAnchor constraintEqualToAnchor:k.bottomAnchor constant:2],
            [s.leadingAnchor constraintEqualToAnchor:k.leadingAnchor],
            [s.topAnchor constraintEqualToAnchor:t.bottomAnchor constant:2],
            [s.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-10]
        ]];
        return wrap;
    }
    if ([kind isEqualToString:@"voice"]) {
        UIView *wrap = [UIView new];
        UILabel *meta = [GLTheme label:[NSString stringWithFormat:@"%@ · %@", m[@"name"], m[@"time"]] font:[GLTheme regular:11] color:[GLTheme sub]];
        UIButton *bubble = [UIButton buttonWithType:UIButtonTypeCustom];
        bubble.translatesAutoresizingMaskIntoConstraints = NO;
        bubble.backgroundColor = [GLTheme purple];
        bubble.layer.cornerRadius = 18;
        bubble.accessibilityLabel = @"Play voice message";
        bubble.accessibilityValue = [NSString stringWithFormat:@"%ld seconds", (long)[m[@"duration"] integerValue]];
        bubble.accessibilityIdentifier = [m[@"filePath"] isKindOfClass:[NSString class]] ? m[@"filePath"] : @"";
        UIImageView *wave = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"waveform"]];
        wave.translatesAutoresizingMaskIntoConstraints = NO;
        wave.tintColor = UIColor.whiteColor;
        UILabel *label = [GLTheme label:@"Voice message" font:[GLTheme medium:14] color:UIColor.whiteColor];
        UILabel *duration = [GLTheme label:[NSString stringWithFormat:@"%ld sec", (long)MAX(1, [m[@"duration"] integerValue])] font:[GLTheme regular:11] color:[UIColor colorWithWhite:1 alpha:0.82]];
        [bubble addSubview:wave];
        [bubble addSubview:label];
        [bubble addSubview:duration];
        [bubble addTarget:self action:@selector(playVoiceMessage:) forControlEvents:UIControlEventTouchUpInside];
        [wrap addSubview:meta];
        [wrap addSubview:bubble];
        [NSLayoutConstraint activateConstraints:@[
            [meta.trailingAnchor constraintEqualToAnchor:wrap.trailingAnchor],
            [meta.topAnchor constraintEqualToAnchor:wrap.topAnchor],
            [bubble.topAnchor constraintEqualToAnchor:meta.bottomAnchor constant:6],
            [bubble.trailingAnchor constraintEqualToAnchor:wrap.trailingAnchor],
            [bubble.widthAnchor constraintEqualToConstant:190],
            [bubble.heightAnchor constraintEqualToConstant:52],
            [bubble.bottomAnchor constraintEqualToAnchor:wrap.bottomAnchor],
            [wave.leadingAnchor constraintEqualToAnchor:bubble.leadingAnchor constant:14],
            [wave.centerYAnchor constraintEqualToAnchor:bubble.centerYAnchor],
            [wave.widthAnchor constraintEqualToConstant:22],
            [wave.heightAnchor constraintEqualToConstant:22],
            [label.leadingAnchor constraintEqualToAnchor:wave.trailingAnchor constant:8],
            [label.centerYAnchor constraintEqualToAnchor:bubble.centerYAnchor],
            [duration.leadingAnchor constraintEqualToAnchor:label.trailingAnchor constant:8],
            [duration.trailingAnchor constraintEqualToAnchor:bubble.trailingAnchor constant:-12],
            [duration.centerYAnchor constraintEqualToAnchor:bubble.centerYAnchor]
        ]];
        return wrap;
    }
    BOOL out = [kind isEqualToString:@"out"];
    UIView *wrap = [UIView new];
    UILabel *meta = [GLTheme label:[NSString stringWithFormat:@"%@ · %@", m[@"name"], m[@"time"]] font:[GLTheme regular:11] color:[GLTheme sub]];
    UIView *bubble = [GLTheme card:18];
    bubble.backgroundColor = out ? [GLTheme purple] : UIColor.whiteColor;
    if (!out) { bubble.layer.borderWidth = 1; bubble.layer.borderColor = [GLTheme line].CGColor; }
    UILabel *text = [GLTheme label:m[@"text"] font:[GLTheme regular:15] color:(out ? UIColor.whiteColor : [GLTheme ink])];
    text.numberOfLines = 0;
    [bubble addSubview:text];
    [wrap addSubview:meta]; [wrap addSubview:bubble];
    if (!out) {
        UIColor *col = [m[@"color"] isEqualToString:@"orange"] ? [GLTheme coral] : [GLTheme purple];
        GLAvatarView *av = [GLAvatarView initial:m[@"initial"] ?: @"?" color:col size:28];
        [wrap addSubview:av];
        [NSLayoutConstraint activateConstraints:@[
            [av.leadingAnchor constraintEqualToAnchor:wrap.leadingAnchor],
            [av.topAnchor constraintEqualToAnchor:wrap.topAnchor],
            [meta.leadingAnchor constraintEqualToAnchor:av.trailingAnchor constant:8],
            [meta.centerYAnchor constraintEqualToAnchor:av.centerYAnchor],
            [bubble.topAnchor constraintEqualToAnchor:av.bottomAnchor constant:6],
            [bubble.leadingAnchor constraintEqualToAnchor:av.leadingAnchor],
            [bubble.trailingAnchor constraintLessThanOrEqualToAnchor:wrap.trailingAnchor constant:-40],
            [bubble.bottomAnchor constraintEqualToAnchor:wrap.bottomAnchor]
        ]];
    } else {
        [NSLayoutConstraint activateConstraints:@[
            [meta.trailingAnchor constraintEqualToAnchor:wrap.trailingAnchor],
            [meta.topAnchor constraintEqualToAnchor:wrap.topAnchor],
            [bubble.topAnchor constraintEqualToAnchor:meta.bottomAnchor constant:6],
            [bubble.trailingAnchor constraintEqualToAnchor:wrap.trailingAnchor],
            [bubble.leadingAnchor constraintGreaterThanOrEqualToAnchor:wrap.leadingAnchor constant:40],
            [bubble.bottomAnchor constraintEqualToAnchor:wrap.bottomAnchor]
        ]];
    }
    [NSLayoutConstraint activateConstraints:@[
        [text.topAnchor constraintEqualToAnchor:bubble.topAnchor constant:10],
        [text.leadingAnchor constraintEqualToAnchor:bubble.leadingAnchor constant:12],
        [text.trailingAnchor constraintEqualToAnchor:bubble.trailingAnchor constant:-12],
        [text.bottomAnchor constraintEqualToAnchor:bubble.bottomAnchor constant:-10]
    ]];
    return wrap;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField { [self send]; return YES; }
- (void)send {
    if (self.audioRecorder.isRecording) {
        [self stopRecordingAndSend];
        return;
    }
    [[GLStore shared] sendChat:self.field.text];
    self.field.text = @"";
    [self.field resignFirstResponder];
}
- (void)toggleVoiceRecording {
    if (self.audioRecorder.isRecording) {
        [self stopRecordingAndSend];
        return;
    }
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord mode:AVAudioSessionModeDefault options:0 error:nil];
    AVAudioSessionRecordPermission permission = session.recordPermission;
    if (permission == AVAudioSessionRecordPermissionDenied) {
        [self showMicrophoneSettings];
        return;
    }
    if (permission == AVAudioSessionRecordPermissionUndetermined) {
        __weak typeof(self) weakSelf = self;
        [session requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) self = weakSelf;
                if (!self) return;
                if (granted) [self startVoiceRecording];
                else [self showMicrophoneSettings];
            });
        }];
        return;
    }
    if (permission == AVAudioSessionRecordPermissionGranted) {
        [self startVoiceRecording];
    } else {
        [self showMicrophoneSettings];
    }
}
- (void)startVoiceRecording {
    if (self.audioRecorder.isRecording) return;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError = nil;
    [session setActive:YES error:&sessionError];
    NSString *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *folder = [documents stringByAppendingPathComponent:@"VoiceMessages"];
    [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *filename = [NSString stringWithFormat:@"chat-%@.m4a", [[NSUUID UUID] UUIDString]];
    self.recordingURL = [NSURL fileURLWithPath:[folder stringByAppendingPathComponent:filename]];
    NSDictionary *settings = @{
        AVFormatIDKey: @(kAudioFormatMPEG4AAC),
        AVSampleRateKey: @44100,
        AVNumberOfChannelsKey: @1,
        AVEncoderAudioQualityKey: @(AVAudioQualityHigh)
    };
    NSError *error = nil;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.recordingURL settings:settings error:&error];
    if (!self.audioRecorder || ![self.audioRecorder prepareToRecord] || ![self.audioRecorder record]) {
        self.audioRecorder = nil;
        self.recordingURL = nil;
        [session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        [self showChatMessage:@"Recording unavailable" message:error.localizedDescription ?: @"Please try again on a device with a microphone."];
        return;
    }
    self.recordSeconds = 0;
    [self.voiceButton setImage:[UIImage systemImageNamed:@"stop.fill"] forState:UIControlStateNormal];
    self.voiceButton.backgroundColor = [GLTheme coral];
    self.voiceButton.tintColor = UIColor.whiteColor;
    self.voiceButton.accessibilityLabel = @"Stop and send voice message";
    self.field.userInteractionEnabled = NO;
    self.field.placeholder = @"Recording 00:00 · tap mic to send";
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(recordTick:) userInfo:nil repeats:YES];
}
- (void)recordTick:(NSTimer *)timer {
    self.recordSeconds += 1;
    self.field.placeholder = [NSString stringWithFormat:@"Recording %02ld:%02ld · tap mic to send", (long)(self.recordSeconds / 60), (long)(self.recordSeconds % 60)];
}
- (void)stopRecordingAndSend {
    if (!self.audioRecorder) return;
    [self.audioRecorder stop];
    NSString *path = self.recordingURL.path;
    NSInteger duration = MAX(1, self.recordSeconds);
    self.audioRecorder = nil;
    self.recordingURL = nil;
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [self.voiceButton setImage:[UIImage systemImageNamed:@"mic.fill"] forState:UIControlStateNormal];
    self.voiceButton.backgroundColor = [GLTheme line];
    self.voiceButton.tintColor = [GLTheme ink];
    self.voiceButton.accessibilityLabel = @"Record voice message";
    self.field.userInteractionEnabled = YES;
    self.field.placeholder = @"Message the crew";
    if (path.length > 0) {
        [[GLStore shared] sendVoiceMessageWithDuration:duration filePath:path];
    } else {
        [self showChatMessage:@"Voice message unavailable" message:@"Please try recording again."];
    }
}
- (void)cancelVoiceRecording {
    if (self.audioRecorder.isRecording) [self.audioRecorder stop];
    NSString *path = self.recordingURL.path;
    if (path.length > 0) [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    self.audioRecorder = nil;
    self.recordingURL = nil;
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [self.voiceButton setImage:[UIImage systemImageNamed:@"mic.fill"] forState:UIControlStateNormal];
    self.voiceButton.backgroundColor = [GLTheme line];
    self.voiceButton.tintColor = [GLTheme ink];
    self.voiceButton.accessibilityLabel = @"Record voice message";
    self.field.userInteractionEnabled = YES;
    self.field.placeholder = @"Message the crew";
}
- (void)showMicrophoneSettings {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Microphone access is off"
                                                                  message:@"Allow microphone access in Settings to record and send a voice message."
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"Not now" style:UIAlertActionStyleCancel handler:nil]];
    [a addAction:[UIAlertAction actionWithTitle:@"Open Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (url) [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }]];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)showChatMessage:(NSString *)title message:(NSString *)message {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)playVoiceMessage:(UIButton *)sender {
    NSString *path = sender.accessibilityIdentifier;
    if (path.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [self showChatMessage:@"Voice file unavailable" message:@"This local recording is no longer on the device."];
        return;
    }
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeDefault options:0 error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    self.voicePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    [self.voicePlayer prepareToPlay];
    if (![self.voicePlayer play]) {
        [self showChatMessage:@"Playback unavailable" message:error.localizedDescription ?: @"Please try again."];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.audioRecorder || self.recordingURL) [self cancelVoiceRecording];
}
- (void)openTasks {
    if (self.navigationController.viewControllers.count > 1) [self.navigationController popViewControllerAnimated:YES];
    else [self.navigationController pushViewController:[GLEventHubViewController new] animated:YES];
}
- (void)split {
    NSInteger n = [[GLStore shared].gathering[@"guestCount"] integerValue];
    NSInteger budget = [[GLStore shared].gathering[@"budget"] integerValue];
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Split costs" message:[NSString stringWithFormat:@"$%ld split among %ld guests — about $%.0f each.", (long)budget, (long)n, budget / (CGFloat)MAX(1, n)] preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)location {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:[GLStore shared].gathering[@"location"] message:@"Riverlight Terrace · Rooftop elevator to floor 12. Host arrives at 5:45." preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
- (void)pop {
    if (self.navigationController.viewControllers.count > 1) [self.navigationController popViewControllerAnimated:YES];
}
@end
