#import "GLStore.h"

NSNotificationName const GLStoreDidChangeNotification = @"GLStoreDidChangeNotification";
static NSString *const kGLStoreKey = @"gatherloop.store.v3.en";

@implementation GLStore
+ (instancetype)shared {
    static GLStore *s;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ s = [GLStore new]; [s loadOrSeed]; });
    return s;
}
- (NSMutableDictionary *)defaultSettings {
    return [@{
        @"notifyTasks": @YES,
        @"notifyInvites": @YES,
        @"notifyCapsule": @YES,
        @"defaultInviteOnly": @YES,
        @"removeLocationAfter": @YES,
        @"momentsDownloadable": @YES,
        @"hideOnlineStatus": @NO
    } mutableCopy];
}
- (void)ensureDefaults {
    if (![self.user isKindOfClass:[NSMutableDictionary class]]) self.user = [NSMutableDictionary dictionary];
    if (!self.user[@"email"]) self.user[@"email"] = @"mia@gatherloop.app";
    if (!self.user[@"dietary"]) self.user[@"dietary"] = @"Vegetarian preferred, no nuts";
    if (!self.user[@"initial"]) {
        NSString *n = self.user[@"name"] ?: @"M";
        self.user[@"initial"] = [[n substringToIndex:MIN(1, n.length)] uppercaseString];
    }
    if (![self.settings isKindOfClass:[NSMutableDictionary class]]) self.settings = [self defaultSettings];
    for (NSString *k in [self defaultSettings]) {
        if (self.settings[k] == nil) self.settings[k] = [self defaultSettings][k];
    }
    if (![self.blockedGuests isKindOfClass:[NSMutableArray class]]) self.blockedGuests = [NSMutableArray array];
    if (![self.feedbackItems isKindOfClass:[NSMutableArray class]]) self.feedbackItems = [NSMutableArray array];
    if (![self.savedIdeaTitles isKindOfClass:[NSMutableArray class]]) self.savedIdeaTitles = [NSMutableArray array];
    if (self.user[@"gatherings"] == nil) self.user[@"gatherings"] = @((NSInteger)1);
    if (self.user[@"moments"] == nil) self.user[@"moments"] = @(self.moments.count);
    if (self.user[@"capsules"] == nil) self.user[@"capsules"] = @([self.capsule[@"sealed"] boolValue] ? 1 : 0);
    if (self.user[@"emailVerified"] == nil) self.user[@"emailVerified"] = @YES;
    [self ensureIdeaCatalog];
}
- (NSArray *)defaultIdeaCatalog {
    return @[
        [@{@"id":@"golden", @"title":@"Golden Hour Potluck", @"people":@"8-16 people", @"hours":@"3 hours", @"cost":@"$$", @"budget":@120, @"vibe":@"Easygoing", @"desc":@"A ready-to-run 3-hour plan with role cards, a shopping list, and conversation prompts.", @"featured":@YES, @"icon":@"sun", @"tags":@[@"featured", @"cozy"], @"location":@"Outdoor patio", @"meta":@"Editor's pick · Role cards"} mutableCopy],
        [@{@"id":@"games", @"title":@"Late-night Board Games", @"people":@"4-8 people", @"hours":@"4 hours", @"cost":@"$", @"budget":@68, @"vibe":@"Cozy", @"desc":@"A laid-back game night with task cards, snack rotations, and a winner's trophy.", @"featured":@NO, @"icon":@"dice", @"tags":@[@"cozy", @"budget"], @"location":@"Living room", @"meta":@"7 tasks · ~$68"} mutableCopy],
        [@{@"id":@"brunch", @"title":@"Easy Sunday Brunch", @"people":@"6-10 people", @"hours":@"2.5 hours", @"cost":@"$$", @"budget":@92, @"vibe":@"Easygoing", @"desc":@"A slow-paced brunch with a shopping list and place cards.", @"featured":@NO, @"icon":@"cup", @"tags":@[@"cozy", @"budget"], @"location":@"Balcony", @"meta":@"5 tasks · ~$92"} mutableCopy],
        [@{@"id":@"park", @"title":@"Park Picnic Blanket", @"people":@"6-12 people", @"hours":@"3 hours", @"cost":@"$", @"budget":@55, @"vibe":@"Outdoor", @"desc":@"A grass picnic with blanket zones, a shared food list, and a photo corner.", @"featured":@NO, @"icon":@"leaf", @"tags":@[@"outdoor", @"budget"], @"location":@"City park", @"meta":@"6 tasks · ~$55"} mutableCopy],
        [@{@"id":@"rooftop", @"title":@"Rooftop Stargazing Movie", @"people":@"8-14 people", @"hours":@"3.5 hours", @"cost":@"$$", @"budget":@110, @"vibe":@"Outdoor", @"desc":@"Projector, pillow nest, and a BYO-snacks rule.", @"featured":@NO, @"icon":@"moon", @"tags":@[@"outdoor", @"cozy"], @"location":@"Rooftop", @"meta":@"8 tasks · ~$110"} mutableCopy],
        [@{@"id":@"tea", @"title":@"Afternoon Tea Salon", @"people":@"4-6 people", @"hours":@"2 hours", @"cost":@"$", @"budget":@48, @"vibe":@"Cozy", @"desc":@"A small tea gathering with conversation cards and a soft playlist.", @"featured":@NO, @"icon":@"cup", @"tags":@[@"cozy", @"budget"], @"location":@"Coffee nook", @"meta":@"4 tasks · ~$48"} mutableCopy],
        [@{@"id":@"bbq", @"title":@"Weekend Charcoal BBQ", @"people":@"10-18 people", @"hours":@"4 hours", @"cost":@"$$$", @"budget":@180, @"vibe":@"Outdoor", @"desc":@"Zoned heat, a veggie grill, and a cleanup checklist.", @"featured":@NO, @"icon":@"flame", @"tags":@[@"outdoor"], @"location":@"Yard", @"meta":@"9 tasks · ~$180"} mutableCopy]
    ];
}
- (void)ensureIdeaCatalog {
    NSArray *catalog = [self defaultIdeaCatalog];
    if (self.ideas.count < catalog.count) {
        NSMutableSet *titles = [NSMutableSet set];
        for (NSDictionary *i in self.ideas) { if (i[@"title"]) [titles addObject:i[@"title"]]; }
        NSMutableArray *merged = [self.ideas mutableCopy] ?: [NSMutableArray array];
        for (NSDictionary *idea in catalog) {
            if (![titles containsObject:idea[@"title"]]) [merged addObject:[idea mutableCopy]];
        }
        self.ideas = merged;
    }
    for (NSMutableDictionary *idea in self.ideas) {
        if (!idea[@"tags"]) idea[@"tags"] = @[@"featured"];
        if (!idea[@"budget"]) idea[@"budget"] = @80;
        if (!idea[@"hours"]) idea[@"hours"] = @"3 hours";
        if (!idea[@"cost"]) idea[@"cost"] = @"$$";
        if (!idea[@"vibe"]) idea[@"vibe"] = @"Easygoing";
        if (!idea[@"icon"]) idea[@"icon"] = @"sparkles";
        if (!idea[@"meta"] && idea[@"people"]) idea[@"meta"] = idea[@"people"];
    }
}
- (void)loadOrSeed {
    NSDictionary *saved = [[NSUserDefaults standardUserDefaults] objectForKey:kGLStoreKey];
    if ([saved isKindOfClass:[NSDictionary class]] && saved[@"user"]) {
        self.onboarded = [saved[@"onboarded"] boolValue];
        self.user = [saved[@"user"] mutableCopy];
        self.gathering = [saved[@"gathering"] mutableCopy];
        self.settings = [saved[@"settings"] mutableCopy] ?: [self defaultSettings];
        self.tasks = [self mutableItems:saved[@"tasks"]];
        self.timeline = [self mutableItems:saved[@"timeline"]];
        self.messages = [self mutableItems:saved[@"messages"]];
        self.moments = [self mutableItems:saved[@"moments"]];
        self.guests = [self mutableItems:saved[@"guests"]];
        self.ideas = [self mutableItems:saved[@"ideas"]];
        self.memories = [self mutableItems:saved[@"memories"]];
        self.capsule = [saved[@"capsule"] mutableCopy];
        self.blockedGuests = [self mutableItems:saved[@"blockedGuests"]];
        self.feedbackItems = [self mutableItems:saved[@"feedbackItems"]];
        self.savedIdeaTitles = [saved[@"savedIdeaTitles"] mutableCopy] ?: [NSMutableArray array];
        [self ensureDefaults];
        return;
    }
    [self seed];
}
- (NSMutableArray *)mutableItems:(NSArray *)arr {
    NSMutableArray *out = [NSMutableArray array];
    for (NSDictionary *d in arr ?: @[]) { [out addObject:[d mutableCopy]]; }
    return out;
}
- (void)seed {
    self.onboarded = NO;
    self.user = [@{
        @"name": @"Mia Chen",
        @"first": @"Mia",
        @"bio": @"Host, list-keeper, sunset chaser.",
        @"initial": @"M",
        @"email": @"mia@gatherloop.app",
        @"dietary": @"Vegetarian preferred, no nuts",
        @"emailVerified": @YES,
        @"gatherings": @8,
        @"moments": @126,
        @"capsules": @3
    } mutableCopy];
    self.settings = [self defaultSettings];
    self.gathering = [@{
        @"name": @"Rooftop Sunset Club",
        @"vibe": @"Easy and relaxed",
        @"dateText": @"Sat, Sep 5",
        @"timeText": @"6:30 PM",
        @"location": @"Riverlight Terrace",
        @"guestCount": @18,
        @"capacity": @24,
        @"budget": @280,
        @"inviteOnly": @YES,
        @"daysAway": @5,
        @"checkedIn": @18,
        @"feel": @"Warm and social",
        @"mustHave": @"Sunset toast, vegetarian options, one surprise activity...",
        @"budgetTier": @1
    } mutableCopy];
    self.tasks = [@[
        [@{@"title":@"Confirm vegetarian dishes", @"who":@"Ava", @"when":@"Tomorrow", @"tag":@"Food", @"tagTone":@"food", @"done":@NO} mutableCopy],
        [@{@"title":@"Share the speaker playlist", @"who":@"Jay", @"when":@"Today", @"tag":@"Sound", @"tagTone":@"sound", @"done":@NO} mutableCopy],
        [@{@"title":@"Pick a playlist", @"who":@"Noah", @"when":@"Today", @"tag":@"Sound", @"tagTone":@"sound", @"done":@NO} mutableCopy],
        [@{@"title":@"Buy ice and citrus", @"who":@"Mia", @"when":@"Saturday morning", @"tag":@"Food", @"tagTone":@"food", @"done":@YES} mutableCopy],
        [@{@"title":@"Check the string lights", @"who":@"Jay", @"when":@"Saturday 4 PM", @"tag":@"Setup", @"tagTone":@"setup", @"done":@YES} mutableCopy]
    ] mutableCopy];
    self.timeline = [@[
        [@{@"time":@"5:45", @"ampm":@"PM", @"cat":@"Setup · MIA + JAY", @"title":@"Lights, table, and welcome drinks", @"detail":@"3 of 4 done", @"kind":@"setup"} mutableCopy],
        [@{@"time":@"6:30", @"ampm":@"PM", @"cat":@"Arrive", @"title":@"Doors open · golden hour", @"detail":@"Hosted by Mia", @"kind":@"arrive"} mutableCopy],
        [@{@"time":@"7:20", @"ampm":@"PM", @"cat":@"Now · Toast", @"title":@"Sunset toast", @"detail":@"Hosted by Noah", @"kind":@"now"} mutableCopy],
        [@{@"time":@"7:35", @"ampm":@"PM", @"cat":@"Sound", @"title":@"Guest co-op playlist", @"detail":@"18 songs · collaborative", @"kind":@"music"} mutableCopy]
    ] mutableCopy];
    self.messages = [@[
        [@{@"kind":@"task", @"name":@"Ava", @"title":@"Ava completed a task", @"body":@"Vegetarian dishes confirmed", @"time":@"9:10 AM"} mutableCopy],
        [@{@"kind":@"in", @"name":@"Ava", @"initial":@"A", @"color":@"orange", @"time":@"9:12 AM", @"text":@"I can bring two mains and a salad. Already added to the shared list."} mutableCopy],
        [@{@"kind":@"out", @"name":@"You", @"time":@"9:18 AM", @"text":@"Perfect. I'll grab drinks and ice. ✦"} mutableCopy],
        [@{@"kind":@"playlist", @"name":@"Jay", @"initial":@"J", @"color":@"lime", @"time":@"9:24 AM", @"title":@"Sunset arrival mix", @"body":@"18 songs · collaborative"} mutableCopy]
    ] mutableCopy];
    self.moments = [@[
        [@{@"title":@"Toast moment", @"time":@"7:24 PM", @"kind":@"photo"} mutableCopy],
        [@{@"title":@"The brightest color", @"time":@"7:40 PM", @"kind":@"prompt", @"answers":@18} mutableCopy],
        [@{@"title":@"Kitchen crew", @"time":@"8:05 PM", @"kind":@"photo"} mutableCopy]
    ] mutableCopy];
    self.guests = [@[
        [@{@"name":@"Ava", @"initial":@"A", @"role":@"Food", @"color":@"orange"} mutableCopy],
        [@{@"name":@"Jay", @"initial":@"J", @"role":@"Sound", @"color":@"teal"} mutableCopy],
        [@{@"name":@"Noah", @"initial":@"N", @"role":@"Co-host", @"color":@"coral"} mutableCopy],
        [@{@"name":@"Mia", @"initial":@"M", @"role":@"Host", @"color":@"purple"} mutableCopy]
    ] mutableCopy];
    self.ideas = [[self defaultIdeaCatalog] mutableCopy];
    self.memories = [@[
        [@{@"title":@"Sunday picnic", @"moments":@27, @"kind":@"sunset"} mutableCopy],
        [@{@"title":@"June capsule", @"moments":@14, @"kind":@"capsule", @"unlock":@"Unlocks Friday"} mutableCopy]
    ] mutableCopy];
    self.capsule = [@{
        @"title":@"Rooftop Sunset Club",
        @"note":@"Wherever we are next year, remember how easy tonight felt...",
        @"unlock":@"Sep 5, 2027",
        @"subtitle":@"One year after the gathering",
        @"photos":@12,
        @"notes":@2,
        @"voice":@1,
        @"sealed":@NO,
        @"guests":@18
    } mutableCopy];
    self.blockedGuests = [NSMutableArray array];
    self.feedbackItems = [NSMutableArray array];
    self.savedIdeaTitles = [NSMutableArray array];
    [self save];
}
- (void)save {
    NSDictionary *payload = @{
        @"onboarded": @(self.onboarded),
        @"user": self.user ?: @{},
        @"gathering": self.gathering ?: @{},
        @"settings": self.settings ?: @{},
        @"tasks": self.tasks ?: @[],
        @"timeline": self.timeline ?: @[],
        @"messages": self.messages ?: @[],
        @"moments": self.moments ?: @[],
        @"guests": self.guests ?: @[],
        @"ideas": self.ideas ?: @[],
        @"memories": self.memories ?: @[],
        @"capsule": self.capsule ?: @{},
        @"blockedGuests": self.blockedGuests ?: @[],
        @"feedbackItems": self.feedbackItems ?: @[],
        @"savedIdeaTitles": self.savedIdeaTitles ?: @[]
    };
    [[NSUserDefaults standardUserDefaults] setObject:payload forKey:kGLStoreKey];
}
- (void)notify {
    [self save];
    [[NSNotificationCenter defaultCenter] postNotificationName:GLStoreDidChangeNotification object:self];
}
- (NSInteger)openTaskCount {
    NSInteger n = 0;
    for (NSDictionary *t in self.tasks) { if (![t[@"done"] boolValue]) n++; }
    return n;
}
- (NSInteger)readyCount {
    NSInteger n = 0;
    for (NSDictionary *t in self.tasks) { if ([t[@"done"] boolValue]) n++; }
    return n;
}
- (NSInteger)spentAmount {
    return MAX(0, [self.gathering[@"budget"] integerValue] - 124);
}
- (void)toggleTaskAt:(NSInteger)index {
    if (index < 0 || index >= (NSInteger)self.tasks.count) return;
    NSMutableDictionary *t = self.tasks[index];
    t[@"done"] = @(![t[@"done"] boolValue]);
    [self notify];
}
- (void)sendChat:(NSString *)text {
    if (text.length == 0) return;
    NSDateFormatter *f = [NSDateFormatter new];
    f.dateFormat = @"h:mm a";
    [self.messages addObject:[@{@"kind":@"out", @"name":@"You", @"time":[f stringFromDate:[NSDate date]], @"text":text} mutableCopy]];
    [self notify];
}
- (void)sendVoiceMessageWithDuration:(NSInteger)duration filePath:(NSString *)filePath {
    NSDateFormatter *f = [NSDateFormatter new];
    f.dateFormat = @"h:mm a";
    NSDictionary *message = @{
        @"kind": @"voice",
        @"name": @"You",
        @"time": [f stringFromDate:[NSDate date]],
        @"duration": @(MAX(1, duration)),
        @"filePath": filePath ?: @""
    };
    [self.messages addObject:[message mutableCopy]];
    [self notify];
}
- (void)addMomentTitle:(NSString *)title note:(NSString *)note {
    [self addMomentTitle:title note:note kind:@"photo"];
}
- (void)addMomentTitle:(NSString *)title note:(NSString *)note kind:(NSString *)kind {
    [self.moments insertObject:[@{@"title":title ?: @"Untitled", @"note":note ?: @"", @"time":@"Just now", @"kind":kind ?: @"photo"} mutableCopy] atIndex:0];
    NSInteger m = [self.user[@"moments"] integerValue] + 1;
    self.user[@"moments"] = @(m);
    [self notify];
}
- (void)applyIdea:(NSDictionary *)idea {
    if (![idea isKindOfClass:[NSDictionary class]]) return;
    if (idea[@"title"]) self.gathering[@"name"] = idea[@"title"];
    if (idea[@"vibe"]) self.gathering[@"vibe"] = idea[@"vibe"];
    if (idea[@"location"]) self.gathering[@"location"] = idea[@"location"];
    if (idea[@"budget"]) self.gathering[@"budget"] = idea[@"budget"];
    if (idea[@"desc"]) self.gathering[@"mustHave"] = idea[@"desc"];
    if (idea[@"people"]) {
        NSString *p = idea[@"people"];
        NSInteger cap = 12;
        NSScanner *sc = [NSScanner scannerWithString:p];
        NSInteger low = 0, high = 0;
        if ([sc scanInteger:&low]) {
            [sc scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
            if ([sc scanInteger:&high] && high > 0) cap = high;
            else if (low > 0) cap = low;
        }
        self.gathering[@"capacity"] = @(cap);
        self.gathering[@"guestCount"] = @(MAX(1, cap / 2));
    }
    NSInteger budget = [idea[@"budget"] integerValue];
    if (budget > 0) {
        if (budget < 80) self.gathering[@"budgetTier"] = @0;
        else if (budget < 150) self.gathering[@"budgetTier"] = @1;
        else self.gathering[@"budgetTier"] = @2;
    }
    // Seed a few starter tasks from the idea title if tasks look empty/generic
    if (self.tasks.count == 0 || idea[@"title"]) {
        NSString *who = self.user[@"first"] ?: @"You";
        NSMutableArray *seedTasks = [@[
            [@{@"title":[NSString stringWithFormat:@"Confirm shopping list for \"%@\"", idea[@"title"] ?: @"gathering"], @"who":who, @"when":@"Today", @"tag":@"Food", @"tagTone":@"food", @"done":@NO} mutableCopy],
            [@{@"title":@"Invite core guests", @"who":who, @"when":@"Tomorrow", @"tag":@"Invite", @"tagTone":@"setup", @"done":@NO} mutableCopy],
            [@{@"title":@"Set the space and vibe", @"who":who, @"when":@"This week", @"tag":@"Setup", @"tagTone":@"setup", @"done":@NO} mutableCopy]
        ] mutableCopy];
        if ([idea[@"icon"] isEqualToString:@"dice"] || [idea[@"title"] containsString:@"Board Games"]) {
            [seedTasks addObject:[@{@"title":@"Prep board games and scorecards", @"who":who, @"when":@"Day of", @"tag":@"Fun", @"tagTone":@"sound", @"done":@NO} mutableCopy]];
        }
        self.tasks = seedTasks;
    }
    NSInteger g = [self.user[@"gatherings"] integerValue];
    if (g < 1) self.user[@"gatherings"] = @1;
    [self notify];
}
- (NSDictionary *)featuredIdea {
    for (NSDictionary *i in self.ideas) {
        if ([i[@"featured"] boolValue]) return i;
    }
    return self.ideas.firstObject;
}
- (NSArray<NSDictionary *> *)ideasMatchingQuery:(NSString *)query filter:(NSString *)filter {
    NSString *q = [[query ?: @"" stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    NSString *f = filter ?: @"For you";
    NSMutableArray *out = [NSMutableArray array];
    for (NSDictionary *idea in self.ideas) {
        if ([idea[@"featured"] boolValue] && ![f isEqualToString:@"Saved"]) {
            // featured still appears in "For you" list section separately; include in all/view filters
        }
        NSArray *tags = idea[@"tags"] ?: @[];
        BOOL passFilter = YES;
        if ([f isEqualToString:@"Under $100"]) {
            passFilter = [idea[@"budget"] integerValue] > 0 && [idea[@"budget"] integerValue] < 100;
        } else if ([f isEqualToString:@"Outdoor"]) {
            passFilter = [tags containsObject:@"outdoor"] || [idea[@"vibe"] containsString:@"Outdoor"] || [idea[@"location"] containsString:@"Rooftop"] || [idea[@"location"] containsString:@"Park"] || [idea[@"location"] containsString:@"Yard"];
        } else if ([f isEqualToString:@"Cozy"]) {
            passFilter = [tags containsObject:@"cozy"] || [idea[@"vibe"] containsString:@"Cozy"] || [idea[@"vibe"] containsString:@"Easygoing"];
        } else if ([f isEqualToString:@"Saved"]) {
            passFilter = [self isIdeaSaved:idea[@"title"]];
        } else {
            // For you: prefer featured + cozy/budget mix — show non-featured for list, all for search
            passFilter = YES;
        }
        if (!passFilter) continue;
        if (q.length) {
            NSString *hay = [[NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@",
                              idea[@"title"] ?: @"", idea[@"vibe"] ?: @"", idea[@"people"] ?: @"",
                              idea[@"location"] ?: @"", idea[@"desc"] ?: @"", idea[@"meta"] ?: @""] lowercaseString];
            if (![hay containsString:q]) continue;
        }
        [out addObject:idea];
    }
    return out;
}
- (BOOL)isIdeaSaved:(NSString *)title {
    if (title.length == 0) return NO;
    return [self.savedIdeaTitles containsObject:title];
}
- (void)toggleSaveIdeaTitle:(NSString *)title {
    if (title.length == 0) return;
    if ([self.savedIdeaTitles containsObject:title]) {
        [self.savedIdeaTitles removeObject:title];
    } else {
        [self.savedIdeaTitles addObject:title];
    }
    [self notify];
}
- (void)sealCapsule {
    self.capsule[@"sealed"] = @YES;
    NSInteger c = [self.user[@"capsules"] integerValue] + 1;
    self.user[@"capsules"] = @(c);
    [self notify];
}
- (void)updateProfileName:(NSString *)name bio:(NSString *)bio dietary:(NSString *)dietary email:(NSString *)email {
    if (name.length) {
        self.user[@"name"] = name;
        NSArray *parts = [name componentsSeparatedByString:@" "];
        self.user[@"first"] = parts.firstObject ?: name;
        self.user[@"initial"] = [[name substringToIndex:MIN(1, name.length)] uppercaseString];
    }
    if (bio) self.user[@"bio"] = bio;
    if (dietary) self.user[@"dietary"] = dietary;
    if (email) {
        self.user[@"email"] = email;
        self.user[@"emailVerified"] = @([email containsString:@"@"]);
    }
    [self notify];
}
- (void)setSetting:(NSString *)key enabled:(BOOL)on {
    if (key.length == 0) return;
    self.settings[key] = @(on);
    if ([key isEqualToString:@"defaultInviteOnly"]) {
        self.gathering[@"inviteOnly"] = @(on);
    }
    [self notify];
}
- (BOOL)settingEnabled:(NSString *)key {
    return [self.settings[key] boolValue];
}
- (NSInteger)privacyPassCount {
    NSInteger n = 0;
    if ([self settingEnabled:@"defaultInviteOnly"]) n++;
    if ([self settingEnabled:@"removeLocationAfter"]) n++;
    if ([self settingEnabled:@"momentsDownloadable"]) n++;
    if ([self.user[@"emailVerified"] boolValue]) n++;
    return MIN(4, n);
}
- (NSString *)privacySummaryLine {
    NSMutableArray *parts = [NSMutableArray array];
    [parts addObject:[self settingEnabled:@"defaultInviteOnly"] ? @"Invite-only by default" : @"Open to join"];
    [parts addObject:[self settingEnabled:@"removeLocationAfter"] ? @"Remove location after event" : @"Keep event location"];
    [parts addObject:[self settingEnabled:@"momentsDownloadable"] ? @"Downloadable" : @"Not downloadable"];
    if (self.blockedGuests.count) {
        [parts addObject:[NSString stringWithFormat:@"%lu blocked", (unsigned long)self.blockedGuests.count]];
    }
    return [parts componentsJoinedByString:@" · "];
}
- (BOOL)isGuestBlocked:(NSString *)name {
    for (NSDictionary *g in self.blockedGuests) {
        if ([g[@"name"] isEqualToString:name]) return YES;
    }
    return NO;
}
- (void)blockGuest:(NSDictionary *)guest {
    NSString *name = guest[@"name"];
    if (name.length == 0 || [self isGuestBlocked:name]) return;
    NSMutableDictionary *row = [guest mutableCopy] ?: [NSMutableDictionary dictionary];
    NSDateFormatter *f = [NSDateFormatter new];
    f.dateFormat = @"yyyy/MM/dd HH:mm";
    row[@"blockedAt"] = [f stringFromDate:[NSDate date]];
    [self.blockedGuests addObject:row];
    [self notify];
}
- (void)unblockGuestNamed:(NSString *)name {
    NSMutableArray *keep = [NSMutableArray array];
    for (NSDictionary *g in self.blockedGuests) {
        if (![g[@"name"] isEqualToString:name]) [keep addObject:g];
    }
    self.blockedGuests = keep;
    [self notify];
}
- (void)addFeedback:(NSString *)text {
    NSString *t = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (t.length == 0) return;
    NSDateFormatter *f = [NSDateFormatter new];
    f.dateFormat = @"yyyy/MM/dd HH:mm";
    [self.feedbackItems insertObject:[@{@"text": t, @"time": [f stringFromDate:[NSDate date]]} mutableCopy] atIndex:0];
    [self notify];
}
- (NSString *)exportJSONString {
    NSISO8601DateFormatter *iso = [NSISO8601DateFormatter new];
    NSDictionary *payload = @{
        @"exportedAt": [iso stringFromDate:[NSDate date]] ?: @"",
        @"user": self.user ?: @{},
        @"settings": self.settings ?: @{},
        @"gathering": self.gathering ?: @{},
        @"tasks": self.tasks ?: @[],
        @"moments": self.moments ?: @[],
        @"guests": self.guests ?: @[],
        @"messages": self.messages ?: @[],
        @"memories": self.memories ?: @[],
        @"capsule": self.capsule ?: @{},
        @"blockedGuests": self.blockedGuests ?: @[],
        @"feedbackItems": self.feedbackItems ?: @[],
        @"savedIdeaTitles": self.savedIdeaTitles ?: @[]
    };
    NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingPrettyPrinted error:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"{}";
}
- (void)deleteAllLocalData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGLStoreKey];
    self.onboarded = NO;
    self.user = [@{
        @"name": @"",
        @"first": @"",
        @"bio": @"",
        @"initial": @"?",
        @"email": @"",
        @"dietary": @"",
        @"emailVerified": @NO,
        @"gatherings": @0,
        @"moments": @0,
        @"capsules": @0
    } mutableCopy];
    self.settings = [self defaultSettings];
    self.gathering = [NSMutableDictionary dictionary];
    self.tasks = [NSMutableArray array];
    self.timeline = [NSMutableArray array];
    self.messages = [NSMutableArray array];
    self.moments = [NSMutableArray array];
    self.guests = [NSMutableArray array];
    self.ideas = [NSMutableArray array];
    self.memories = [NSMutableArray array];
    self.capsule = [NSMutableDictionary dictionary];
    self.blockedGuests = [NSMutableArray array];
    self.feedbackItems = [NSMutableArray array];
    self.savedIdeaTitles = [NSMutableArray array];
    [self notify];
}
- (void)resetDemoData {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGLStoreKey];
    [self seed];
    self.onboarded = YES;
    [self notify];
}
@end
