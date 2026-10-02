#import "GLCaptureViewController.h"
#import "GLTheme.h"
#import "GLArt.h"
#import "GLStore.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

static NSString *const kGLCaptureIntroShownKey = @"gatherloop.capture.permission-intro.v3";

@interface GLCaptureViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UILabel *noteVal;
@property (nonatomic, strong) UILabel *mediaMeta;
@property (nonatomic, strong) UIImageView *previewImage;
@property (nonatomic, strong) UIView *defaultPreview;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) UILabel *voiceTitle;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, strong) NSURL *recordingURL;
@property (nonatomic, assign) NSInteger recordSeconds;
@end

@implementation GLCaptureViewController

- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [GLTheme hex:0x1A1630];

    GLSunsetView *art = [GLSunsetView new];
    art.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:art];
    [GLTheme pin:art to:self.view insets:UIEdgeInsetsZero];

    UIButton *close = [GLTheme circleSymbol:@"xmark" bg:[UIColor colorWithWhite:0 alpha:0.35] tint:UIColor.whiteColor size:36];
    [close addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    UILabel *title = [GLTheme label:[GLStore shared].gathering[@"name"] font:[GLTheme title:15] color:UIColor.whiteColor];
    UIButton *refresh = [GLTheme circleSymbol:@"arrow.clockwise" bg:[UIColor colorWithWhite:0 alpha:0.35] tint:UIColor.whiteColor size:36];
    [refresh addTarget:self action:@selector(resetCapture) forControlEvents:UIControlEventTouchUpInside];
    UIView *prompt = [GLTheme pill:@"✨  Prompt answered" bg:[UIColor colorWithWhite:0 alpha:0.4] fg:UIColor.whiteColor];
    [self.view addSubview:close];
    [self.view addSubview:title];
    [self.view addSubview:refresh];
    [self.view addSubview:prompt];

    UIView *sheet = [UIView new];
    sheet.translatesAutoresizingMaskIntoConstraints = NO;
    sheet.backgroundColor = UIColor.whiteColor;
    sheet.layer.cornerRadius = 28;
    sheet.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    [self.view addSubview:sheet];

    UIView *handle = [UIView new];
    handle.translatesAutoresizingMaskIntoConstraints = NO;
    handle.backgroundColor = [GLTheme line];
    handle.layer.cornerRadius = 2.5;
    [sheet addSubview:handle];

    UILabel *captureTitle = [GLTheme label:@"Capture a moment" font:[GLTheme title:19] color:[GLTheme ink]];
    UILabel *permissionHint = [GLTheme label:@"Voice, camera and photos stay off until you choose one. First use will ask for permission." font:[GLTheme regular:11] color:[GLTheme sub]];
    permissionHint.numberOfLines = 0;
    [sheet addSubview:captureTitle];
    [sheet addSubview:permissionHint];

    self.voiceButton = [self captureButtonWithIcon:@"mic.fill" title:@"Voice" tint:[GLTheme coral] bg:[GLTheme softCoral]];
    self.voiceTitle = [self labelInsideCaptureButton:self.voiceButton];
    UIButton *cameraButton = [self captureButtonWithIcon:@"camera.fill" title:@"Camera" tint:[GLTheme purple] bg:[GLTheme lavender]];
    UIButton *photoButton = [self captureButtonWithIcon:@"photo.on.rectangle" title:@"Photos" tint:[GLTheme navy] bg:[GLTheme mint]];
    [self.voiceButton addTarget:self action:@selector(voiceAction) forControlEvents:UIControlEventTouchUpInside];
    [cameraButton addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
    [photoButton addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
    self.voiceButton.accessibilityLabel = @"Record a voice memo";
    cameraButton.accessibilityLabel = @"Take a photo with the camera";
    photoButton.accessibilityLabel = @"Choose a photo from the library";

    UIStackView *actions = [[UIStackView alloc] initWithArrangedSubviews:@[self.voiceButton, cameraButton, photoButton]];
    actions.translatesAutoresizingMaskIntoConstraints = NO;
    actions.axis = UILayoutConstraintAxisHorizontal;
    actions.spacing = 8;
    actions.distribution = UIStackViewDistributionFillEqually;
    [sheet addSubview:actions];

    self.mediaMeta = [GLTheme label:@"No media attached · choose an action above" font:[GLTheme medium:11] color:[GLTheme sub]];
    self.mediaMeta.numberOfLines = 1;
    [sheet addSubview:self.mediaMeta];

    UIView *thumb = [UIView new];
    thumb.translatesAutoresizingMaskIntoConstraints = NO;
    thumb.backgroundColor = [GLTheme softPurple];
    thumb.layer.cornerRadius = 10;
    thumb.clipsToBounds = YES;
    self.defaultPreview = [GLSunsetView new];
    self.defaultPreview.translatesAutoresizingMaskIntoConstraints = NO;
    ((GLSunsetView *)self.defaultPreview).compact = YES;
    ((GLSunsetView *)self.defaultPreview).showPeople = NO;
    [thumb addSubview:self.defaultPreview];
    [GLTheme pin:self.defaultPreview to:thumb insets:UIEdgeInsetsZero];
    self.previewImage = [UIImageView new];
    self.previewImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.previewImage.contentMode = UIViewContentModeScaleAspectFill;
    self.previewImage.clipsToBounds = YES;
    self.previewImage.hidden = YES;
    [thumb addSubview:self.previewImage];
    [GLTheme pin:self.previewImage to:thumb insets:UIEdgeInsetsZero];

    UILabel *add = [GLTheme label:@"Add a note" font:[GLTheme medium:10] color:[GLTheme sub]];
    self.noteVal = [GLTheme label:@"All orange glow — right on the money." font:[GLTheme title:15] color:[GLTheme ink]];
    self.noteVal.numberOfLines = 2;
    UIButton *mood = [GLTheme circleSymbol:@"face.smiling" bg:[GLTheme line] tint:[GLTheme ink] size:36];
    [mood addTarget:self action:@selector(editNote) forControlEvents:UIControlEventTouchUpInside];

    UIButton *vis = [UIButton buttonWithType:UIButtonTypeSystem];
    vis.translatesAutoresizingMaskIntoConstraints = NO;
    UIView *ppl = [GLTheme iconBox:@"person.2.fill" bg:[GLTheme lavender] tint:[GLTheme purple] size:40 radius:20];
    ppl.userInteractionEnabled = NO;
    UILabel *vt = [GLTheme label:@"Visible to this gathering only" font:[GLTheme title:14] color:[GLTheme ink]];
    UILabel *vs = [GLTheme label:@"18 guests checked in" font:[GLTheme regular:12] color:[GLTheme sub]];
    [vis addSubview:ppl];
    [vis addSubview:vt];
    [vis addSubview:vs];

    UIButton *dl = [GLTheme circleSymbol:@"arrow.down" bg:[GLTheme line] tint:[GLTheme ink] size:48];
    dl.layer.cornerRadius = 14;
    [dl addTarget:self action:@selector(downloadMedia) forControlEvents:UIControlEventTouchUpInside];
    dl.accessibilityLabel = @"Save selected photo to Photos";
    UIButton *save = [GLTheme fillButton:@"Save to shared story  ↑" bg:[GLTheme coral] fg:UIColor.whiteColor radius:18];
    [save addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];

    [sheet addSubview:thumb];
    [sheet addSubview:add];
    [sheet addSubview:self.noteVal];
    [sheet addSubview:mood];
    [sheet addSubview:vis];
    [sheet addSubview:dl];
    [sheet addSubview:save];

    [NSLayoutConstraint activateConstraints:@[
        [close.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:6],
        [close.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [title.centerYAnchor constraintEqualToAnchor:close.centerYAnchor],
        [title.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [refresh.centerYAnchor constraintEqualToAnchor:close.centerYAnchor],
        [refresh.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [prompt.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [prompt.bottomAnchor constraintEqualToAnchor:sheet.topAnchor constant:-16],
        [sheet.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [sheet.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [sheet.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [handle.topAnchor constraintEqualToAnchor:sheet.topAnchor constant:10],
        [handle.centerXAnchor constraintEqualToAnchor:sheet.centerXAnchor],
        [handle.widthAnchor constraintEqualToConstant:40],
        [handle.heightAnchor constraintEqualToConstant:5],
        [captureTitle.topAnchor constraintEqualToAnchor:handle.bottomAnchor constant:14],
        [captureTitle.leadingAnchor constraintEqualToAnchor:sheet.leadingAnchor constant:16],
        [permissionHint.topAnchor constraintEqualToAnchor:captureTitle.bottomAnchor constant:3],
        [permissionHint.leadingAnchor constraintEqualToAnchor:captureTitle.leadingAnchor],
        [permissionHint.trailingAnchor constraintEqualToAnchor:sheet.trailingAnchor constant:-16],
        [actions.topAnchor constraintEqualToAnchor:permissionHint.bottomAnchor constant:10],
        [actions.leadingAnchor constraintEqualToAnchor:sheet.leadingAnchor constant:16],
        [actions.trailingAnchor constraintEqualToAnchor:sheet.trailingAnchor constant:-16],
        [actions.heightAnchor constraintEqualToConstant:76],
        [self.mediaMeta.topAnchor constraintEqualToAnchor:actions.bottomAnchor constant:7],
        [self.mediaMeta.leadingAnchor constraintEqualToAnchor:actions.leadingAnchor],
        [self.mediaMeta.trailingAnchor constraintEqualToAnchor:actions.trailingAnchor],
        [thumb.topAnchor constraintEqualToAnchor:self.mediaMeta.bottomAnchor constant:10],
        [thumb.leadingAnchor constraintEqualToAnchor:sheet.leadingAnchor constant:16],
        [thumb.widthAnchor constraintEqualToConstant:52],
        [thumb.heightAnchor constraintEqualToConstant:52],
        [add.leadingAnchor constraintEqualToAnchor:thumb.trailingAnchor constant:12],
        [add.topAnchor constraintEqualToAnchor:thumb.topAnchor constant:4],
        [self.noteVal.leadingAnchor constraintEqualToAnchor:add.leadingAnchor],
        [self.noteVal.topAnchor constraintEqualToAnchor:add.bottomAnchor constant:2],
        [self.noteVal.trailingAnchor constraintEqualToAnchor:mood.leadingAnchor constant:-8],
        [mood.trailingAnchor constraintEqualToAnchor:sheet.trailingAnchor constant:-16],
        [mood.centerYAnchor constraintEqualToAnchor:thumb.centerYAnchor],
        [vis.topAnchor constraintEqualToAnchor:thumb.bottomAnchor constant:16],
        [vis.leadingAnchor constraintEqualToAnchor:sheet.leadingAnchor constant:16],
        [vis.trailingAnchor constraintEqualToAnchor:sheet.trailingAnchor constant:-16],
        [vis.heightAnchor constraintEqualToConstant:56],
        [ppl.leadingAnchor constraintEqualToAnchor:vis.leadingAnchor],
        [ppl.centerYAnchor constraintEqualToAnchor:vis.centerYAnchor],
        [vt.leadingAnchor constraintEqualToAnchor:ppl.trailingAnchor constant:10],
        [vt.topAnchor constraintEqualToAnchor:vis.topAnchor constant:8],
        [vs.leadingAnchor constraintEqualToAnchor:vt.leadingAnchor],
        [vs.topAnchor constraintEqualToAnchor:vt.bottomAnchor constant:2],
        [dl.leadingAnchor constraintEqualToAnchor:sheet.leadingAnchor constant:16],
        [dl.topAnchor constraintEqualToAnchor:vis.bottomAnchor constant:16],
        [save.leadingAnchor constraintEqualToAnchor:dl.trailingAnchor constant:10],
        [save.trailingAnchor constraintEqualToAnchor:sheet.trailingAnchor constant:-16],
        [save.centerYAnchor constraintEqualToAnchor:dl.centerYAnchor],
        [save.heightAnchor constraintEqualToConstant:52],
        [save.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-8]
    ]];
}

- (UIButton *)captureButtonWithIcon:(NSString *)icon title:(NSString *)title tint:(UIColor *)tint bg:(UIColor *)bg {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = bg;
    button.layer.cornerRadius = 16;
    UIView *iconBox = [GLTheme iconBox:icon bg:[UIColor colorWithWhite:1 alpha:0.58] tint:tint size:30 radius:9];
    UILabel *label = [GLTheme label:title font:[GLTheme medium:11] color:[GLTheme ink]];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = 7001;
    label.userInteractionEnabled = NO;
    [button addSubview:iconBox];
    [button addSubview:label];
    [NSLayoutConstraint activateConstraints:@[
        [iconBox.centerXAnchor constraintEqualToAnchor:button.centerXAnchor],
        [iconBox.topAnchor constraintEqualToAnchor:button.topAnchor constant:9],
        [label.topAnchor constraintEqualToAnchor:iconBox.bottomAnchor constant:4],
        [label.leadingAnchor constraintEqualToAnchor:button.leadingAnchor constant:3],
        [label.trailingAnchor constraintEqualToAnchor:button.trailingAnchor constant:-3],
        [label.bottomAnchor constraintEqualToAnchor:button.bottomAnchor constant:-7]
    ]];
    return button;
}

- (UILabel *)labelInsideCaptureButton:(UIButton *)button {
    for (UIView *subview in button.subviews) {
        if ([subview isKindOfClass:[UILabel class]] && subview.tag == 7001) return (UILabel *)subview;
    }
    return nil;
}

- (void)runAfterFirstUseNotice:(void (^)(void))work {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kGLCaptureIntroShownKey]) {
        if (work) work();
        return;
    }
    [defaults setBool:YES forKey:kGLCaptureIntroShownKey];
    UIAlertController *intro = [UIAlertController alertControllerWithTitle:@"Before you capture"
                                                                      message:@"Voice, camera and photo access are requested only when you choose that action. You can change them later in Settings."
                                                               preferredStyle:UIAlertControllerStyleAlert];
    [intro addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (work) work();
    }]];
    [self presentViewController:intro animated:YES completion:nil];
}

- (void)voiceAction {
    __weak typeof(self) weakSelf = self;
    [self runAfterFirstUseNotice:^{ [weakSelf beginVoicePermission]; }];
}

- (void)cameraAction {
    __weak typeof(self) weakSelf = self;
    [self runAfterFirstUseNotice:^{ [weakSelf beginCameraPermission]; }];
}

- (void)photoAction {
    __weak typeof(self) weakSelf = self;
    [self runAfterFirstUseNotice:^{ [weakSelf beginPhotoPermission]; }];
}

- (void)beginVoicePermission {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
                    mode:AVAudioSessionModeDefault
                 options:AVAudioSessionCategoryOptionDefaultToSpeaker
                   error:nil];
    AVAudioSessionRecordPermission permission = session.recordPermission;
    if (permission == AVAudioSessionRecordPermissionDenied || permission == AVAudioSessionRecordPermissionUndetermined) {
        if (permission == AVAudioSessionRecordPermissionDenied) {
            [self showSettingsFor:@"Microphone"];
            return;
        }
        [session requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) [self startRecording];
                else [self showSettingsFor:@"Microphone"];
            });
        }];
        return;
    }
    if (permission == AVAudioSessionRecordPermissionGranted) [self startRecording];
    else [self showSettingsFor:@"Microphone"];
}

- (void)startRecording {
    if (self.audioRecorder.isRecording) {
        [self stopRecording];
        return;
    }
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    NSString *folder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"VoiceMemos"];
    [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *filename = [NSString stringWithFormat:@"voice-%@.m4a", [[NSUUID UUID] UUIDString]];
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
        [self showMessage:@"Recording unavailable" message:error.localizedDescription ?: @"Please try again on a device with a microphone."];
        return;
    }
    self.recordSeconds = 0;
    [self setRecordingUI:YES];
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(recordTick:) userInfo:nil repeats:YES];
}

- (void)recordTick:(NSTimer *)timer {
    self.recordSeconds += 1;
    self.mediaMeta.text = [NSString stringWithFormat:@"Recording… %@ · tap Voice to stop", [self formattedDuration:self.recordSeconds]];
}

- (NSString *)formattedDuration:(NSInteger)seconds {
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)(seconds / 60), (long)(seconds % 60)];
}

- (void)stopRecording {
    if (!self.audioRecorder) return;
    [self.audioRecorder stop];
    self.audioRecorder = nil;
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [self setRecordingUI:NO];
    self.mediaMeta.text = [NSString stringWithFormat:@"Voice memo ready · %@", [self formattedDuration:self.recordSeconds]];
}

- (void)setRecordingUI:(BOOL)recording {
    self.voiceTitle.text = recording ? @"Stop" : @"Voice";
    self.voiceButton.backgroundColor = recording ? [GLTheme coral] : [GLTheme softCoral];
    self.voiceTitle.textColor = recording ? UIColor.whiteColor : [GLTheme ink];
    self.voiceButton.accessibilityValue = recording ? @"Recording; tap to stop" : @"Ready to record";
}

- (void)beginCameraPermission {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        [self showSettingsFor:@"Camera"];
    } else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) [self presentPicker:UIImagePickerControllerSourceTypeCamera];
                else [self showSettingsFor:@"Camera"];
            });
        }];
    } else {
        [self presentPicker:UIImagePickerControllerSourceTypeCamera];
    }
}

- (void)beginPhotoPermission {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
        [self showSettingsFor:@"Photos"];
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(PHAuthorizationStatus newStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (newStatus == PHAuthorizationStatusAuthorized || newStatus == PHAuthorizationStatusLimited) {
                    [self presentPicker:UIImagePickerControllerSourceTypePhotoLibrary];
                } else {
                    [self showSettingsFor:@"Photos"];
                }
            });
        }];
    } else {
        [self presentPicker:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void)presentPicker:(UIImagePickerControllerSourceType)sourceType {
    if (sourceType == UIImagePickerControllerSourceTypeCamera && ![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        [self showMessage:@"Camera unavailable" message:@"This simulator or device does not have a camera. Choose Photos to attach an existing image."];
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
        if (image) [self useImage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)useImage:(UIImage *)image {
    self.previewImage.image = image;
    self.previewImage.hidden = NO;
    self.defaultPreview.hidden = YES;
    self.mediaMeta.text = @"Photo attached · tap Save to add it to the shared story";
}

- (void)downloadMedia {
    UIImage *image = self.previewImage.image;
    if (!image) {
        [self showMessage:@"Nothing to save yet" message:@"Choose Camera or Photos first, then use the download button to save a copy."];
        return;
    }
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelAddOnly];
    void (^saveBlock)(void) = ^{
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        } completionHandler:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) [self showMessage:@"Saved to Photos" message:@"A copy of this gathering moment is now in your photo library."];
                else [self showMessage:@"Could not save photo" message:error.localizedDescription ?: @"Please try again."];
            });
        }];
    };
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:^(PHAuthorizationStatus newStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (newStatus == PHAuthorizationStatusAuthorized || newStatus == PHAuthorizationStatusLimited) saveBlock();
                else [self showSettingsFor:@"Photos"];
            });
        }];
    } else if (status == PHAuthorizationStatusAuthorized || status == PHAuthorizationStatusLimited) {
        saveBlock();
    } else {
        [self showSettingsFor:@"Photos"];
    }
}

- (void)editNote {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Add a note" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.text = self.noteVal.text; }];
    [a addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.noteVal.text = a.textFields.firstObject.text;
    }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}

- (void)save {
    [self stopRecording];
    NSString *title = self.previewImage.image ? @"Photo moment" : (self.recordingURL ? @"Voice moment" : @"Brightest color");
    NSString *kind = self.previewImage.image ? @"photo" : (self.recordingURL ? @"voice" : @"prompt");
    NSString *note = self.noteVal.text ?: @"";
    if (self.previewImage.image) note = [NSString stringWithFormat:@"%@\nPhoto attached to this gathering.", note];
    else if (self.recordingURL) note = [NSString stringWithFormat:@"%@\nVoice memo %@.", note, [self formattedDuration:self.recordSeconds]];
    [[GLStore shared] addMomentTitle:title note:note kind:kind];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetCapture {
    [self stopRecording];
    self.recordingURL = nil;
    self.previewImage.image = nil;
    self.previewImage.hidden = YES;
    self.defaultPreview.hidden = NO;
    self.mediaMeta.text = @"No media attached · choose an action above";
    self.noteVal.text = @"All orange glow — right on the money.";
}

- (void)showSettingsFor:(NSString *)feature {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ access is off", feature]
                                                                  message:[NSString stringWithFormat:@"Allow %@ access in Settings to use this gathering feature.", feature.lowercaseString]
                                                           preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"Not now" style:UIAlertActionStyleCancel handler:nil]];
    [a addAction:[UIAlertAction actionWithTitle:@"Open Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }]];
    [self presentViewController:a animated:YES completion:nil];
}

- (void)showMessage:(NSString *)title message:(NSString *)message {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.audioRecorder.isRecording) [self stopRecording];
}

- (void)dealloc {
    [self.recordTimer invalidate];
}

- (void)close { [self dismissViewControllerAnimated:YES completion:nil]; }

@end
