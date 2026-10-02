#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GLCaptureMode) {
    GLCaptureModeAll = 0,
    GLCaptureModeVoice,
    GLCaptureModeCamera,
    GLCaptureModePhotoLibrary
};

@interface GLCaptureViewController : UIViewController
/// Optional context for callers that want to remember a preferred action.
/// Permission is always requested only after the user taps that action.
@property (nonatomic, assign) GLCaptureMode preferredMode;
@end
