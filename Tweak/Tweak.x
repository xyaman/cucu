#import "Tweak.h"

#define RESPONDS_TO(item) [self respondsToSelector:@selector(item)]
#define ANCESTOR_RESPONDS_TO(item) [[self _viewControllerForAncestor] respondsToSelector:@selector(item)]

/*----------------------
 / Banner notification
 -----------------------*/
static BBServer* bbServer = nil;
// From litten lisa
static dispatch_queue_t getBBServerQueue() {

    static dispatch_queue_t queue;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        void* handle = dlopen(NULL, RTLD_GLOBAL);
        if (handle) {
            dispatch_queue_t __weak* pointer = (__weak dispatch_queue_t *) dlsym(handle, "__BBServerQueue");
            if (pointer) queue = *pointer;
            dlclose(handle);
        }
    });

    return queue;

}

%hook BBServer
- (id)initWithQueue:(id)arg1 {
    bbServer = %orig;
    return bbServer;

}

- (id)initWithQueue:(id)arg1 dataProviderManager:(id)arg2 syncService:(id)arg3 dismissalSyncCache:(id)arg4 observerListener:(id)arg5 utilitiesListener:(id)arg6 conduitListener:(id)arg7 systemStateListener:(id)arg8 settingsListener:(id)arg9 {
    
    bbServer = %orig;
    return bbServer;

}

- (void)dealloc {

    if (bbServer == self) bbServer = nil;
    %orig;
}
%end

static void fakeBanner() {
    
    BBBulletin* bulletin = [[%c(BBBulletin) alloc] init];

    bulletin.title = @"Cucu";
    bulletin.message = @"This is a test banner";
    bulletin.sectionID = @"com.apple.MobileSMS";
    bulletin.bulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.recordID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.publisherBulletinID = [[NSProcessInfo processInfo] globallyUniqueString];
    bulletin.date = [NSDate date];
    bulletin.defaultAction = [%c(BBAction) actionWithLaunchBundleID:@"com.apple.MobileSMS" callblock:nil];
    bulletin.clearable = YES;
    bulletin.showsMessagePreview = YES;
    bulletin.publicationDate = [NSDate date];
    bulletin.lastInterruptDate = [NSDate date];

    if ([bbServer respondsToSelector:@selector(publishBulletin:destinations:)]) {
        dispatch_sync(getBBServerQueue(), ^{
            [bbServer publishBulletin:bulletin destinations:15];
        });
    }
}

@implementation CucuTimerView : UIView
- (id) init {
    self = [super init];

    self.backgroundColor = [UIColor clearColor];

    self.count = [prefDismissDelay intValue] + 1; // lol

    self.countLabel = [UILabel new];
    self.countLabel.backgroundColor = [UIColor clearColor];
    self.countLabel.textColor = [UIColor labelColor];
    self.countLabel.font = [UIFont systemFontOfSize:8];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.countLabel];

    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];

    if(self.frame.origin.y > 0 && !self.shapeLayer) {

        // TODO: change this
        self.countLabel.bounds = self.bounds;

        // Shape layer
        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.fillColor = [UIColor clearColor].CGColor;
        self.shapeLayer.strokeColor = self.strokeColor.CGColor;
        self.shapeLayer.lineCap = kCALineCapRound;

        self.shapeLayer.lineWidth = self.lineWidth;
        self.shapeLayer.strokeEnd = 0;

        self.shapeLayer.path = [UIBezierPath bezierPathWithArcCenter:self.countLabel.center radius:self.frame.size.width/2 startAngle:-M_PI/2 endAngle:2* M_PI clockwise:YES].CGPath;

        [self.layer addSublayer:self.shapeLayer];

        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        anim.toValue = @(1);
        anim.duration = self.count + 0.3;
        [self.shapeLayer addAnimation:anim forKey:@"loli"];

        // Start count timer
        [self startCountTimer];
    }
}

- (void) startCountTimer {
    self.count -= 1;
    self.countLabel.text = [NSString stringWithFormat:@"%d", self.count]; 

    if(self.count > 0) [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startCountTimer) userInfo:nil repeats:NO];
}
@end

/*----------------------
 / Cucu
 -----------------------*/
%group Cucu

// Change notification banner dismiss delay
%hook SBNotificationBannerDestination
%property (nonatomic) BOOL canExecuteAction;
// Change dismiss delay (default is 6)
- (id) _startTimerWithDelay:(unsigned long long)arg1 eventHandler:(id)arg2 {
    return %orig([prefDismissDelay intValue], arg2);
}

// Every time a banner will appear, we set execute action to false
-(void)presentableWillAppearAsBanner:(id)arg0 {
    %orig;

    // We only initialize timer if there if prevent action time, this way we reduce memory usage
    if([prefPreventActionTime floatValue] == 0) {
        self.canExecuteAction = YES;
    
    } else {
        self.canExecuteAction = NO;
        [NSTimer scheduledTimerWithTimeInterval:[prefPreventActionTime floatValue] repeats:NO block:^(NSTimer *timer) {
            self.canExecuteAction = YES;
        }];
    }
}

// Tap or click
- (void) notificationViewController:(id)arg0 executeAction:(id)arg1 withParameters:(id)arg2 completion:(id)arg3 {
    if(self.canExecuteAction) %orig;
}
%end

%hook NCNotificationShortLookView
%property(nonatomic, retain) UILabel *cucuCountLabel;
%property(nonatomic) int cucuCount;

- (void) didMoveToWindow {
    %orig;

    if (!ANCESTOR_RESPONDS_TO(delegate)) return;
    if (![[[self _viewControllerForAncestor] delegate] isKindOfClass:%c(SBNotificationBannerDestination)]) return;

    if([prefDismissStyle intValue] == 0) return;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 13;

    if((RESPONDS_TO(baseView) || RESPONDS_TO(liddellView))) return;

    if([prefDismissStyle intValue] == 1) [self createTimerViewWithSuperview:self andConstraintsFrom:self];
    else if([prefDismissStyle intValue] == 2) [self createFillViewWithSuperview:self];
    
}

// Used to make it compatible with other tweaks >.<
- (void) didAddSubview:(UIView *)subview {
    %orig;

    if (!ANCESTOR_RESPONDS_TO(delegate)) return;
    if (![[[self _viewControllerForAncestor] delegate] isKindOfClass:%c(SBNotificationBannerDestination)]) return;

    if(RESPONDS_TO(liddellView) && subview == self.liddellView) {
        if([prefDismissStyle intValue] == 1) {
            [self createTimerViewWithSuperview:self andConstraintsFrom:self.liddellView];

        } else if([prefDismissStyle intValue] == 2) {
            [self createFillViewWithSuperview:self.liddellView];
        }

    } else if(RESPONDS_TO(baseView) && subview == self.baseView) {
        if([prefDismissStyle intValue] == 1) {
            [self createTimerViewWithSuperview:self andConstraintsFrom:self.baseView];

        } else if([prefDismissStyle intValue] == 2) {
            [self createFillViewWithSuperview:self.baseView];
        }
    
    }
    // } else if(RESPONDS_TO(velvetBackground) && [subview isKindOfClass:%c(VelvetBackgroundView)]) {
    //     self.velvetBackground = (id)subview;
    //     if([prefDismissStyle intValue] == 2) [self createFillViewWithSuperview:self.velvetBackground];
    // }

}

%new
-(UIView *) createTimerViewWithSuperview:(UIView *)superview andConstraintsFrom:(UIView *)sibling {

    CucuTimerView *timer = [CucuTimerView new];
    timer.userInteractionEnabled = NO;

    // Settings
    timer.countLabel.font = [UIFont systemFontOfSize:[prefTimerFontSize intValue]];
    timer.lineWidth = [prefTimerLineWidth floatValue];

    // Coloring
    if([prefTimerColorStyle intValue] == 1) timer.strokeColor = [Kuro getPrimaryColor:self.icons[0]];
    else if([prefTimerColorStyle intValue] == 2) timer.strokeColor = [GcColorPickerUtils colorWithHex:prefTimerCustomColor];

    // Font coloring
    if([prefTimerTextColorStyle intValue] == 1) timer.countLabel.textColor = [Kuro getPrimaryColor:self.icons[0]];
    else if([prefTimerTextColorStyle intValue] == 2) timer.countLabel.textColor = [GcColorPickerUtils colorWithHex:prefTimerTextCustomColor];

    // Add to superview
    [superview addSubview:timer];

    timer.translatesAutoresizingMaskIntoConstraints = NO;
    [timer.centerYAnchor constraintEqualToAnchor:sibling.centerYAnchor constant:[prefTimerSize floatValue]/2 + [prefTimerYOffset floatValue]].active = YES; 
    [timer.rightAnchor constraintEqualToAnchor:sibling.rightAnchor constant:-5 + [prefTimerXOffset floatValue]].active = YES;
    [timer.widthAnchor constraintEqualToConstant:[prefTimerSize floatValue]].active = YES;
    [timer.heightAnchor constraintEqualToConstant:[prefTimerSize floatValue]].active = YES;

    return timer;
}

%new
- (UIView *) createFillViewWithSuperview:(UIView *)superview {
    UIView *fill = [UIView new];
    fill.userInteractionEnabled = NO;

    // Coloring
    if([prefFillColorStyle intValue] == 1) fill.backgroundColor = [Kuro getPrimaryColor:self.icons[0]];
    else if([prefFillColorStyle intValue] == 2) fill.backgroundColor = [GcColorPickerUtils colorWithHex:prefFillCustomColor];

    // Add to superview
    [superview insertSubview:fill atIndex:0];

    // Animation
    fill.translatesAutoresizingMaskIntoConstraints = NO;
    [fill.topAnchor constraintEqualToAnchor:superview.topAnchor].active = YES;
    [fill.bottomAnchor constraintEqualToAnchor:superview.bottomAnchor].active = YES;
    [fill.leftAnchor constraintEqualToAnchor:superview.leftAnchor].active = YES;
    // [superview layoutIfNeeded];

    [UIView animateWithDuration:[prefDismissDelay intValue] + 0.3
        delay:0 
        options:UIViewAnimationOptionCurveLinear
        animations:^{
            [fill.widthAnchor constraintEqualToConstant:359].active = YES;
            [superview layoutIfNeeded];
        } 
        completion:nil
    ];


    return fill;
}

%new
- (void) startCountTimer {
    self.cucuCount -= 1;
    self.cucuCountLabel.text = [NSString stringWithFormat:@"%d", self.cucuCount]; 

    if(self.cucuCount > 0) [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startCountTimer) userInfo:nil repeats:NO];
}
%end

%end

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)fakeBanner, (CFStringRef)@"com.xyaman.cucupreferences/TestBanner", NULL, (CFNotificationSuspensionBehavior)kNilOptions);
    %init;

    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.xyaman.cucupreferences"];

    [preferences registerBool:&isEnabled default:NO forKey:@"isEnabled"];
    if(!isEnabled) return;

    // Dismiss
    [preferences registerObject:&prefPreventActionTime default:@(0) forKey:@"preventActionTime"];

    [preferences registerObject:&prefDismissDelay default:@(6) forKey:@"dismissDelay"];
    [preferences registerObject:&prefDismissStyle default:@(0) forKey:@"dismissStyle"];

    // Fill preferences
    [preferences registerObject:&prefFillColorStyle default:@(1) forKey:@"fillColorStyle"];
    [preferences registerObject:&prefFillCustomColor default:@"000000" forKey:@"fillCustomColor"];

    // Timer preferences
    [preferences registerObject:&prefTimerColorStyle default:@(1) forKey:@"timerColorStyle"];
    [preferences registerObject:&prefTimerCustomColor default:@"000000" forKey:@"timerCustomColor"];
    [preferences registerObject:&prefTimerTextColorStyle default:@(1) forKey:@"timerTextColorStyle"];
    [preferences registerObject:&prefTimerTextCustomColor default:@"000000" forKey:@"timerTextCustomColor"];
    [preferences registerObject:&prefTimerSize default:@(20) forKey:@"timerSize"];
    [preferences registerObject:&prefTimerFontSize default:@(8) forKey:@"timerFontSize"];
    [preferences registerObject:&prefTimerLineWidth default:@(3) forKey:@"timerLineWidth"];
    [preferences registerObject:&prefTimerYOffset default:@(0) forKey:@"timerYOffset"];
    [preferences registerObject:&prefTimerXOffset default:@(0) forKey:@"timerXOffset"];

    %init(Cucu);
}