#import "GLIdeasViewController.h"
#import "GLTheme.h"
#import "GLArt.h"
#import "GLStore.h"
#import "GLCreateViewController.h"

@interface GLIdeaListVC : UIViewController
@property (nonatomic, copy) NSString *filter;
@property (nonatomic, copy) NSString *query;
@property (nonatomic, strong) UIStackView *stack;
@property (nonatomic, copy) void (^onUse)(NSDictionary *idea);
@end

@implementation GLIdeaListVC
- (instancetype)initWithTitle:(NSString *)title filter:(NSString *)filter query:(NSString *)query {
    if (self = [super init]) {
        self.title = title;
        self.filter = filter;
        self.query = query;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [GLTheme bg];
    UIView *c;
    [GLTheme embedScrollIn:self.view content:&c top:self.view.safeAreaLayoutGuide.topAnchor bottom:self.view.safeAreaLayoutGuide.bottomAnchor];
    self.stack = [UIStackView new];
    self.stack.axis = UILayoutConstraintAxisVertical;
    self.stack.spacing = 10;
    self.stack.translatesAutoresizingMaskIntoConstraints = NO;
    [c addSubview:self.stack];
    [NSLayoutConstraint activateConstraints:@[
        [self.stack.topAnchor constraintEqualToAnchor:c.topAnchor constant:16],
        [self.stack.leadingAnchor constraintEqualToAnchor:c.leadingAnchor constant:16],
        [self.stack.trailingAnchor constraintEqualToAnchor:c.trailingAnchor constant:-16],
        [self.stack.bottomAnchor constraintEqualToAnchor:c.bottomAnchor constant:-24]
    ]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:GLStoreDidChangeNotification object:nil];
    [self reload];
}
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }
- (void)reload {
    for (UIView *v in self.stack.arrangedSubviews) { [self.stack removeArrangedSubview:v]; [v removeFromSuperview]; }
    NSArray *ideas = [[GLStore shared] ideasMatchingQuery:self.query filter:self.filter];
    if (ideas.count == 0) {
        [self.stack addArrangedSubview:[GLTheme label:@"No matching ideas. Try different keywords or filters." font:[GLTheme regular:14] color:[GLTheme sub]]];
        return;
    }
    for (NSDictionary *idea in ideas) {
        UIView *row = [GLIdeasViewController ideaRowForIdea:idea target:self action:@selector(tapUse:) saveAction:@selector(tapSave:)];
        [self.stack addArrangedSubview:row];
    }
}
- (void)tapUse:(UIButton *)b {
    NSDictionary *idea = [self ideaNamed:b.accessibilityLabel];
    if (idea && self.onUse) self.onUse(idea);
}
- (void)tapSave:(UIButton *)b {
    [[GLStore shared] toggleSaveIdeaTitle:b.accessibilityLabel];
}
- (void)rowTapped:(UITapGestureRecognizer *)g {
    NSDictionary *idea = [self ideaNamed:g.view.accessibilityLabel];
    if (idea && self.onUse) self.onUse(idea);
}
- (NSDictionary *)ideaNamed:(NSString *)title {
    for (NSDictionary *i in [GLStore shared].ideas) {
        if ([i[@"title"] isEqualToString:title]) return i;
    }
    return nil;
}
@end

@interface GLIdeasViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) UIView *content;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) UIStackView *chipRow;
@property (nonatomic, strong) NSArray<UIButton *> *chipButtons;
@property (nonatomic, copy) NSString *activeFilter;
@property (nonatomic, strong) UIButton *bookmarkBtn;
@property (nonatomic, strong) UIView *featCard;
@property (nonatomic, strong) UILabel *featPick;
@property (nonatomic, strong) UILabel *featTitle;
@property (nonatomic, strong) UILabel *featDesc;
@property (nonatomic, strong) UILabel *featMeta;
@property (nonatomic, strong) UIButton *featSaveBtn;
@property (nonatomic, strong) UIStackView *listStack;
@property (nonatomic, strong) UILabel *sectionTitle;
@property (nonatomic, strong) UIStackView *bodyStack;
@property (nonatomic, strong) UIView *sectionHeader;
@end

@implementation GLIdeasViewController

+ (NSString *)symbolForIcon:(NSString *)icon {
    if ([icon isEqualToString:@"dice"]) return @"dice.fill";
    if ([icon isEqualToString:@"cup"]) return @"cup.and.saucer.fill";
    if ([icon isEqualToString:@"leaf"]) return @"leaf.fill";
    if ([icon isEqualToString:@"moon"]) return @"moon.stars.fill";
    if ([icon isEqualToString:@"flame"]) return @"flame.fill";
    if ([icon isEqualToString:@"sun"]) return @"sun.max.fill";
    return @"sparkles";
}
+ (UIColor *)colorForIcon:(NSString *)icon {
    if ([icon isEqualToString:@"dice"]) return [GLTheme lavender];
    if ([icon isEqualToString:@"cup"]) return [GLTheme hex:0xF6E7A1];
    if ([icon isEqualToString:@"leaf"]) return [GLTheme mint];
    if ([icon isEqualToString:@"moon"]) return [GLTheme softPurple];
    if ([icon isEqualToString:@"flame"]) return [GLTheme softCoral];
    return [GLTheme lavender];
}
+ (UIView *)ideaRowForIdea:(NSDictionary *)idea target:(id)target action:(SEL)action saveAction:(SEL)saveAction {
    UIView *row = [GLTheme card:20];
    NSString *icon = idea[@"icon"] ?: @"sparkles";
    UIView *box = [GLTheme iconBox:[self symbolForIcon:icon] bg:[self colorForIcon:icon] tint:[GLTheme ink] size:48 radius:16];
    UILabel *p = [GLTheme label:idea[@"people"] ?: @"" font:[GLTheme medium:11] color:[GLTheme sub]];
    UILabel *t = [GLTheme label:idea[@"title"] ?: @"" font:[GLTheme title:16] color:[GLTheme ink]];
    UILabel *s = [GLTheme label:idea[@"meta"] ?: @"" font:[GLTheme regular:12] color:[GLTheme sub]];
    UIButton *add = [GLTheme circleSymbol:@"plus" bg:[GLTheme line] tint:[GLTheme ink] size:36];
    add.accessibilityLabel = idea[@"title"];
    [add addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    BOOL saved = [[GLStore shared] isIdeaSaved:idea[@"title"]];
    UIButton *bm = [GLTheme circleSymbol:saved ? @"bookmark.fill" : @"bookmark" bg:[GLTheme bg] tint:saved ? [GLTheme purple] : [GLTheme ink] size:32];
    bm.accessibilityLabel = idea[@"title"];
    [bm addTarget:target action:saveAction forControlEvents:UIControlEventTouchUpInside];
    [row addSubview:box]; [row addSubview:p]; [row addSubview:t]; [row addSubview:s]; [row addSubview:add]; [row addSubview:bm];
    [NSLayoutConstraint activateConstraints:@[
        [row.heightAnchor constraintGreaterThanOrEqualToConstant:78],
        [box.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:12],
        [box.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [box.topAnchor constraintGreaterThanOrEqualToAnchor:row.topAnchor constant:14],
        [box.bottomAnchor constraintLessThanOrEqualToAnchor:row.bottomAnchor constant:-14],
        [p.leadingAnchor constraintEqualToAnchor:box.trailingAnchor constant:12],
        [p.topAnchor constraintEqualToAnchor:row.topAnchor constant:14],
        [t.leadingAnchor constraintEqualToAnchor:p.leadingAnchor],
        [t.topAnchor constraintEqualToAnchor:p.bottomAnchor constant:2],
        [t.trailingAnchor constraintLessThanOrEqualToAnchor:bm.leadingAnchor constant:-8],
        [s.leadingAnchor constraintEqualToAnchor:p.leadingAnchor],
        [s.topAnchor constraintEqualToAnchor:t.bottomAnchor constant:2],
        [s.trailingAnchor constraintLessThanOrEqualToAnchor:bm.leadingAnchor constant:-8],
        [s.bottomAnchor constraintEqualToAnchor:row.bottomAnchor constant:-14],
        [add.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-12],
        [add.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [bm.trailingAnchor constraintEqualToAnchor:add.leadingAnchor constant:-6],
        [bm.centerYAnchor constraintEqualToAnchor:row.centerYAnchor]
    ]];
    if ([target respondsToSelector:@selector(rowTapped:)]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:@selector(rowTapped:)];
        row.accessibilityLabel = idea[@"title"];
        row.userInteractionEnabled = YES;
        [row addGestureRecognizer:tap];
    }
    return row;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [GLTheme bg];
    self.activeFilter = @"For you";

    self.scroll = [UIScrollView new];
    self.scroll.translatesAutoresizingMaskIntoConstraints = NO;
    self.scroll.alwaysBounceVertical = YES;
    self.scroll.contentInset = UIEdgeInsetsMake(0, 0, 28, 0);
    self.scroll.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.scroll.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.scroll];
    self.content = [UIView new];
    self.content.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scroll addSubview:self.content];
    [NSLayoutConstraint activateConstraints:@[
        [self.scroll.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scroll.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [self.content.topAnchor constraintEqualToAnchor:self.scroll.contentLayoutGuide.topAnchor],
        [self.content.bottomAnchor constraintEqualToAnchor:self.scroll.contentLayoutGuide.bottomAnchor],
        [self.content.leadingAnchor constraintEqualToAnchor:self.scroll.frameLayoutGuide.leadingAnchor],
        [self.content.trailingAnchor constraintEqualToAnchor:self.scroll.frameLayoutGuide.trailingAnchor],
        [self.content.widthAnchor constraintEqualToAnchor:self.scroll.frameLayoutGuide.widthAnchor]
    ]];

    UILabel *over = [GLTheme label:@"Make it yours" font:[GLTheme medium:12] color:[GLTheme sub]];
    UILabel *title = [GLTheme label:@"Gathering ideas" font:[GLTheme display:30] color:[GLTheme ink]];
    self.bookmarkBtn = [GLTheme circleSymbol:@"bookmark" bg:[GLTheme line] tint:[GLTheme ink] size:40];
    [self.bookmarkBtn addTarget:self action:@selector(openSaved) forControlEvents:UIControlEventTouchUpInside];

    UIView *search = [GLTheme card:22];
    search.backgroundColor = [GLTheme line];
    UIImageSymbolConfiguration *iconCfg = [UIImageSymbolConfiguration configurationWithPointSize:15 weight:UIImageSymbolWeightMedium];
    UIImageView *mag = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"magnifyingglass" withConfiguration:iconCfg]];
    mag.translatesAutoresizingMaskIntoConstraints = NO;
    mag.tintColor = [GLTheme sub];
    mag.contentMode = UIViewContentModeScaleAspectFit;
    [mag setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [mag setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [mag setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    self.searchField = [UITextField new];
    self.searchField.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchField.placeholder = @"Search vibe, place, or guest count";
    self.searchField.font = [GLTheme regular:14];
    self.searchField.delegate = self;
    self.searchField.returnKeyType = UIReturnKeySearch;
    self.searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.searchField addTarget:self action:@selector(searchChanged) forControlEvents:UIControlEventEditingChanged];
    UIButton *filterBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    filterBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [filterBtn setImage:[UIImage systemImageNamed:@"slider.horizontal.3" withConfiguration:iconCfg] forState:UIControlStateNormal];
    filterBtn.tintColor = [GLTheme ink];
    [filterBtn addTarget:self action:@selector(openFilterSheet) forControlEvents:UIControlEventTouchUpInside];
    [search addSubview:mag];
    [search addSubview:self.searchField];
    [search addSubview:filterBtn];

    UIScrollView *chips = [UIScrollView new];
    chips.translatesAutoresizingMaskIntoConstraints = NO;
    chips.showsHorizontalScrollIndicator = NO;
    self.chipRow = [UIStackView new];
    self.chipRow.translatesAutoresizingMaskIntoConstraints = NO;
    self.chipRow.spacing = 8;
    NSArray *names = @[@"For you", @"Under $100", @"Outdoor", @"Cozy"];
    NSMutableArray *btns = [NSMutableArray array];
    for (NSInteger i = 0; i < names.count; i++) {
        UIButton *b = [self chipButton:names[i] selected:(i == 0)];
        b.tag = i;
        [b addTarget:self action:@selector(chipTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.chipRow addArrangedSubview:b];
        [btns addObject:b];
    }
    self.chipButtons = btns;
    [chips addSubview:self.chipRow];

    self.featCard = [GLTheme card:26];
    GLSunsetView *art = [GLSunsetView new];
    art.translatesAutoresizingMaskIntoConstraints = NO;
    art.showPeople = NO;
    [self.featCard addSubview:art];
    self.featPick = [GLTheme label:@"" font:[GLTheme medium:11] color:[GLTheme sub]];
    self.featTitle = [GLTheme label:@"" font:[GLTheme title:20] color:[GLTheme ink]];
    self.featDesc = [GLTheme label:@"" font:[GLTheme regular:13] color:[GLTheme sub]];
    self.featDesc.numberOfLines = 0;
    self.featMeta = [GLTheme label:@"" font:[GLTheme medium:12] color:[GLTheme sub]];
    UIButton *use = [GLTheme fillButton:@"Use this plan  →" bg:[GLTheme navy] fg:UIColor.whiteColor radius:16];
    [use addTarget:self action:@selector(useFeatured) forControlEvents:UIControlEventTouchUpInside];
    self.featSaveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.featSaveBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.featSaveBtn setTitle:@"Save" forState:UIControlStateNormal];
    [self.featSaveBtn setTitleColor:[GLTheme purple] forState:UIControlStateNormal];
    self.featSaveBtn.titleLabel.font = [GLTheme medium:13];
    [self.featSaveBtn addTarget:self action:@selector(toggleFeaturedSave) forControlEvents:UIControlEventTouchUpInside];
    [self.featCard addSubview:self.featPick]; [self.featCard addSubview:self.featTitle]; [self.featCard addSubview:self.featDesc];
    [self.featCard addSubview:self.featMeta]; [self.featCard addSubview:use]; [self.featCard addSubview:self.featSaveBtn];

    self.sectionTitle = [GLTheme label:@"Small & memorable" font:[GLTheme title:18] color:[GLTheme ink]];
    UIButton *see = [UIButton buttonWithType:UIButtonTypeSystem];
    see.translatesAutoresizingMaskIntoConstraints = NO;
    [see setTitle:@"See all" forState:UIControlStateNormal];
    [see setTitleColor:[GLTheme purple] forState:UIControlStateNormal];
    see.titleLabel.font = [GLTheme medium:14];
    [see addTarget:self action:@selector(seeAll) forControlEvents:UIControlEventTouchUpInside];
    self.sectionHeader = [UIView new];
    self.sectionHeader.translatesAutoresizingMaskIntoConstraints = NO;
    [self.sectionHeader addSubview:self.sectionTitle];
    [self.sectionHeader addSubview:see];
    [NSLayoutConstraint activateConstraints:@[
        [self.sectionHeader.heightAnchor constraintEqualToConstant:28],
        [self.sectionTitle.leadingAnchor constraintEqualToAnchor:self.sectionHeader.leadingAnchor],
        [self.sectionTitle.centerYAnchor constraintEqualToAnchor:self.sectionHeader.centerYAnchor],
        [see.trailingAnchor constraintEqualToAnchor:self.sectionHeader.trailingAnchor],
        [see.centerYAnchor constraintEqualToAnchor:self.sectionHeader.centerYAnchor]
    ]];

    self.listStack = [UIStackView new];
    self.listStack.translatesAutoresizingMaskIntoConstraints = NO;
    self.listStack.axis = UILayoutConstraintAxisVertical;
    self.listStack.spacing = 10;

    self.bodyStack = [UIStackView new];
    self.bodyStack.translatesAutoresizingMaskIntoConstraints = NO;
    self.bodyStack.axis = UILayoutConstraintAxisVertical;
    self.bodyStack.spacing = 16;
    [self.bodyStack addArrangedSubview:self.featCard];
    [self.bodyStack addArrangedSubview:self.sectionHeader];
    [self.bodyStack addArrangedSubview:self.listStack];
    self.bodyStack.layoutMarginsRelativeArrangement = NO;

    for (UIView *v in @[over, title, self.bookmarkBtn, search, chips, self.bodyStack]) {
        [self.content addSubview:v];
    }

    [NSLayoutConstraint activateConstraints:@[
        [over.topAnchor constraintEqualToAnchor:self.content.topAnchor constant:8],
        [over.leadingAnchor constraintEqualToAnchor:self.content.leadingAnchor constant:20],
        [title.topAnchor constraintEqualToAnchor:over.bottomAnchor constant:4],
        [title.leadingAnchor constraintEqualToAnchor:over.leadingAnchor],
        [self.bookmarkBtn.centerYAnchor constraintEqualToAnchor:title.centerYAnchor],
        [self.bookmarkBtn.trailingAnchor constraintEqualToAnchor:self.content.trailingAnchor constant:-20],
        [search.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:16],
        [search.leadingAnchor constraintEqualToAnchor:self.content.leadingAnchor constant:16],
        [search.trailingAnchor constraintEqualToAnchor:self.content.trailingAnchor constant:-16],
        [search.heightAnchor constraintEqualToConstant:46],
        [mag.leadingAnchor constraintEqualToAnchor:search.leadingAnchor constant:14],
        [mag.centerYAnchor constraintEqualToAnchor:search.centerYAnchor],
        [mag.widthAnchor constraintEqualToConstant:18],
        [mag.heightAnchor constraintEqualToConstant:18],
        [self.searchField.leadingAnchor constraintEqualToAnchor:mag.trailingAnchor constant:8],
        [self.searchField.centerYAnchor constraintEqualToAnchor:search.centerYAnchor],
        [self.searchField.trailingAnchor constraintEqualToAnchor:filterBtn.leadingAnchor constant:-8],
        [filterBtn.trailingAnchor constraintEqualToAnchor:search.trailingAnchor constant:-12],
        [filterBtn.centerYAnchor constraintEqualToAnchor:search.centerYAnchor],
        [filterBtn.widthAnchor constraintEqualToConstant:28],
        [filterBtn.heightAnchor constraintEqualToConstant:28],
        [chips.topAnchor constraintEqualToAnchor:search.bottomAnchor constant:12],
        [chips.leadingAnchor constraintEqualToAnchor:search.leadingAnchor],
        [chips.trailingAnchor constraintEqualToAnchor:search.trailingAnchor],
        [chips.heightAnchor constraintEqualToConstant:40],
        [self.chipRow.leadingAnchor constraintEqualToAnchor:chips.contentLayoutGuide.leadingAnchor],
        [self.chipRow.trailingAnchor constraintEqualToAnchor:chips.contentLayoutGuide.trailingAnchor],
        [self.chipRow.topAnchor constraintEqualToAnchor:chips.contentLayoutGuide.topAnchor],
        [self.chipRow.bottomAnchor constraintEqualToAnchor:chips.contentLayoutGuide.bottomAnchor],
        [self.chipRow.heightAnchor constraintEqualToAnchor:chips.frameLayoutGuide.heightAnchor],
        [self.bodyStack.topAnchor constraintEqualToAnchor:chips.bottomAnchor constant:16],
        [self.bodyStack.leadingAnchor constraintEqualToAnchor:search.leadingAnchor],
        [self.bodyStack.trailingAnchor constraintEqualToAnchor:search.trailingAnchor],
        [self.bodyStack.bottomAnchor constraintEqualToAnchor:self.content.bottomAnchor constant:-24],
        [art.topAnchor constraintEqualToAnchor:self.featCard.topAnchor],
        [art.leadingAnchor constraintEqualToAnchor:self.featCard.leadingAnchor],
        [art.trailingAnchor constraintEqualToAnchor:self.featCard.trailingAnchor],
        [art.heightAnchor constraintEqualToConstant:140],
        [self.featPick.topAnchor constraintEqualToAnchor:art.bottomAnchor constant:14],
        [self.featPick.leadingAnchor constraintEqualToAnchor:self.featCard.leadingAnchor constant:16],
        [self.featSaveBtn.centerYAnchor constraintEqualToAnchor:self.featPick.centerYAnchor],
        [self.featSaveBtn.trailingAnchor constraintEqualToAnchor:self.featCard.trailingAnchor constant:-16],
        [self.featTitle.topAnchor constraintEqualToAnchor:self.featPick.bottomAnchor constant:6],
        [self.featTitle.leadingAnchor constraintEqualToAnchor:self.featPick.leadingAnchor],
        [self.featTitle.trailingAnchor constraintEqualToAnchor:self.featCard.trailingAnchor constant:-16],
        [self.featDesc.topAnchor constraintEqualToAnchor:self.featTitle.bottomAnchor constant:6],
        [self.featDesc.leadingAnchor constraintEqualToAnchor:self.featTitle.leadingAnchor],
        [self.featDesc.trailingAnchor constraintEqualToAnchor:self.featTitle.trailingAnchor],
        [self.featMeta.topAnchor constraintEqualToAnchor:self.featDesc.bottomAnchor constant:10],
        [self.featMeta.leadingAnchor constraintEqualToAnchor:self.featTitle.leadingAnchor],
        [use.topAnchor constraintEqualToAnchor:self.featMeta.bottomAnchor constant:14],
        [use.leadingAnchor constraintEqualToAnchor:self.featCard.leadingAnchor constant:16],
        [use.trailingAnchor constraintEqualToAnchor:self.featCard.trailingAnchor constant:-16],
        [use.heightAnchor constraintEqualToConstant:48],
        [use.bottomAnchor constraintEqualToAnchor:self.featCard.bottomAnchor constant:-16]
    ]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUI) name:GLStoreDidChangeNotification object:nil];
    [self reloadUI];
}
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self reloadUI];
}

- (UIButton *)chipButton:(NSString *)name selected:(BOOL)on {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
    b.translatesAutoresizingMaskIntoConstraints = NO;
    b.layer.cornerRadius = 16;
    b.contentEdgeInsets = UIEdgeInsetsMake(8, 14, 8, 14);
    b.titleLabel.font = [GLTheme medium:13];
    [b setTitle:name forState:UIControlStateNormal];
    [self styleChip:b selected:on];
    return b;
}
- (void)styleChip:(UIButton *)b selected:(BOOL)on {
    if (on) {
        b.backgroundColor = [GLTheme navy];
        [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        b.layer.borderWidth = 0;
    } else {
        b.backgroundColor = UIColor.whiteColor;
        [b setTitleColor:[GLTheme ink] forState:UIControlStateNormal];
        b.layer.borderWidth = 1;
        b.layer.borderColor = [GLTheme line].CGColor;
    }
}
- (void)chipTapped:(UIButton *)sender {
    self.activeFilter = [sender titleForState:UIControlStateNormal];
    for (UIButton *b in self.chipButtons) {
        [self styleChip:b selected:(b == sender)];
    }
    [self reloadUI];
}
- (void)searchChanged { [self reloadUI]; }
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self reloadUI];
    return YES;
}

- (void)reloadUI {
    NSDictionary *feat = [[GLStore shared] featuredIdea];
    self.featPick.text = [NSString stringWithFormat:@"Editor's pick · %@", feat[@"people"] ?: @""];
    self.featTitle.text = feat[@"title"] ?: @"";
    self.featDesc.text = feat[@"desc"] ?: @"";
    self.featMeta.text = [NSString stringWithFormat:@"⏱  %@     %@     ✦ %@", feat[@"hours"] ?: @"", feat[@"cost"] ?: @"", feat[@"vibe"] ?: @""];
    BOOL savedFeat = [[GLStore shared] isIdeaSaved:feat[@"title"]];
    [self.featSaveBtn setTitle:savedFeat ? @"Saved" : @"Save" forState:UIControlStateNormal];

    BOOL showFeatured = [self.activeFilter isEqualToString:@"For you"] && self.searchField.text.length == 0;
    self.featCard.hidden = !showFeatured;

    NSString *section = @"Small & memorable";
    if ([self.activeFilter isEqualToString:@"Under $100"]) section = @"Budget-friendly";
    else if ([self.activeFilter isEqualToString:@"Outdoor"]) section = @"Outdoor gatherings";
    else if ([self.activeFilter isEqualToString:@"Cozy"]) section = @"Cozy evenings";
    else if ([self.activeFilter isEqualToString:@"Saved"]) section = @"Saved";
    if (self.searchField.text.length) section = @"Search results";
    self.sectionTitle.text = section;

    for (UIView *v in self.listStack.arrangedSubviews) { [self.listStack removeArrangedSubview:v]; [v removeFromSuperview]; }
    NSArray *ideas = [[GLStore shared] ideasMatchingQuery:self.searchField.text filter:self.activeFilter];
    NSInteger shown = 0;
    for (NSDictionary *idea in ideas) {
        if (showFeatured && [idea[@"featured"] boolValue]) continue;
        [self.listStack addArrangedSubview:[[self class] ideaRowForIdea:idea target:self action:@selector(useIdeaButton:) saveAction:@selector(saveIdeaButton:)]];
        shown++;
        if (showFeatured && shown >= 4) break;
    }
    if (shown == 0) {
        UILabel *empty = [GLTheme label:@"No ideas match right now." font:[GLTheme regular:14] color:[GLTheme muted]];
        [self.listStack addArrangedSubview:empty];
    }

    BOOL anySaved = [GLStore shared].savedIdeaTitles.count > 0;
    [self.bookmarkBtn setImage:[UIImage systemImageNamed:anySaved ? @"bookmark.fill" : @"bookmark"] forState:UIControlStateNormal];
    self.bookmarkBtn.tintColor = anySaved ? [GLTheme purple] : [GLTheme ink];
}

- (void)useFeatured {
    [self applyAndCreate:[[GLStore shared] featuredIdea]];
}
- (void)useIdeaButton:(UIButton *)b {
    [self applyAndCreate:[self ideaNamed:b.accessibilityLabel]];
}
- (void)saveIdeaButton:(UIButton *)b {
    [[GLStore shared] toggleSaveIdeaTitle:b.accessibilityLabel];
}
- (void)rowTapped:(UITapGestureRecognizer *)g {
    [self applyAndCreate:[self ideaNamed:g.view.accessibilityLabel]];
}
- (NSDictionary *)ideaNamed:(NSString *)title {
    for (NSDictionary *i in [GLStore shared].ideas) {
        if ([i[@"title"] isEqualToString:title]) return i;
    }
    return nil;
}
- (void)applyAndCreate:(NSDictionary *)idea {
    if (!idea) return;
    [[GLStore shared] applyIdea:idea];
    GLCreateViewController *vc = [GLCreateViewController new];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)toggleFeaturedSave {
    NSDictionary *feat = [[GLStore shared] featuredIdea];
    [[GLStore shared] toggleSaveIdeaTitle:feat[@"title"]];
}
- (void)openSaved {
    GLIdeaListVC *vc = [[GLIdeaListVC alloc] initWithTitle:@"Saved ideas" filter:@"Saved" query:nil];
    __weak typeof(self) weakSelf = self;
    vc.onUse = ^(NSDictionary *idea) { [weakSelf applyAndCreate:idea]; };
    self.navigationController.navigationBarHidden = NO;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)seeAll {
    GLIdeaListVC *vc = [[GLIdeaListVC alloc] initWithTitle:self.sectionTitle.text ?: @"All ideas" filter:self.activeFilter query:self.searchField.text];
    __weak typeof(self) weakSelf = self;
    vc.onUse = ^(NSDictionary *idea) { [weakSelf applyAndCreate:idea]; };
    self.navigationController.navigationBarHidden = NO;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)openFilterSheet {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Filter ideas" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *name in @[@"For you", @"Under $100", @"Outdoor", @"Cozy", @"Saved"]) {
        [a addAction:[UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction *_) {
            self.activeFilter = name;
            BOOL matched = NO;
            for (UIButton *b in self.chipButtons) {
                BOOL on = [[b titleForState:UIControlStateNormal] isEqualToString:name];
                [self styleChip:b selected:on];
                if (on) matched = YES;
            }
            if (!matched) {
                for (UIButton *b in self.chipButtons) [self styleChip:b selected:NO];
            }
            [self reloadUI];
        }]];
    }
    [a addAction:[UIAlertAction actionWithTitle:@"Clear search" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *_) {
        self.searchField.text = @"";
        [self reloadUI];
    }]];
    [a addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}
@end
