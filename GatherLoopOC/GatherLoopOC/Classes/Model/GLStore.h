#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSNotificationName const GLStoreDidChangeNotification;

@interface GLStore : NSObject
+ (instancetype)shared;
@property (nonatomic) BOOL onboarded;
@property (nonatomic, strong) NSMutableDictionary *user;
@property (nonatomic, strong) NSMutableDictionary *gathering;
@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *tasks;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *timeline;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *messages;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *moments;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *guests;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *ideas;
@property (nonatomic, strong) NSMutableArray<NSString *> *savedIdeaTitles;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *memories;
@property (nonatomic, strong) NSMutableDictionary *capsule;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *blockedGuests;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *feedbackItems;
@property (nonatomic, strong) NSMutableArray<NSString *> *chatUnread;
- (void)save;
- (void)notify;
- (NSInteger)openTaskCount;
- (NSInteger)readyCount;
- (NSInteger)spentAmount;
- (void)toggleTaskAt:(NSInteger)index;
- (void)sendChat:(NSString *)text;
- (void)sendVoiceMessageWithDuration:(NSInteger)duration filePath:(NSString *)filePath;
- (void)addMomentTitle:(NSString *)title note:(NSString *)note;
- (void)addMomentTitle:(NSString *)title note:(NSString *)note kind:(NSString *)kind;
- (void)applyIdea:(NSDictionary *)idea;
- (NSDictionary *)featuredIdea;
- (NSArray<NSDictionary *> *)ideasMatchingQuery:(NSString *)query filter:(NSString *)filter;
- (BOOL)isIdeaSaved:(NSString *)title;
- (void)toggleSaveIdeaTitle:(NSString *)title;
- (void)sealCapsule;
- (void)updateProfileName:(NSString *)name bio:(NSString *)bio dietary:(NSString *)dietary email:(NSString *)email;
- (void)setSetting:(NSString *)key enabled:(BOOL)on;
- (BOOL)settingEnabled:(NSString *)key;
- (NSInteger)privacyPassCount;
- (NSString *)privacySummaryLine;
- (BOOL)isGuestBlocked:(NSString *)name;
- (void)blockGuest:(NSDictionary *)guest;
- (void)unblockGuestNamed:(NSString *)name;
- (void)addFeedback:(NSString *)text;
- (NSString *)exportJSONString;
- (void)deleteAllLocalData;
- (void)resetDemoData;
@end
