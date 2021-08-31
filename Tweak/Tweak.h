#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>
#import <dlfcn.h>

#import <Kuro/libKuro.h>
#import <GcUniversal/GcColorPickerUtils.h>


// Preferences
HBPreferences *preferences = nil;
BOOL isEnabled = NO;

NSNumber *prefDismissStyle = nil;

// Delay
NSNumber *prefPreventActionTime = nil;
NSNumber *prefDismissDelay = nil;

// Fill preferences
NSNumber *prefFillColorStyle = nil;
NSString *prefFillCustomColor = nil;

// Fill preferences
NSNumber *prefTimerColorStyle = nil;
NSString *prefTimerCustomColor = nil;

NSNumber *prefTimerTextColorStyle = nil;
NSString *prefTimerTextCustomColor = nil;
NSNumber *prefTimerSize = nil;
NSNumber *prefTimerFontSize = nil;
NSNumber *prefTimerLineWidth = nil;
NSNumber *prefTimerYOffset = nil;
NSNumber *prefTimerXOffset = nil;

@interface UIView (Private)
- (id)_viewControllerForAncestor;
@end

@interface VelvetBackgroundView : UIView
@end

@interface PLPlatterHeaderContentView : UIView
-(UIView *)backgroundView;
@end

@interface SBNotificationBannerDestination : NSObject
@property(nonatomic) BOOL canExecuteAction;
-(id)_startTimerWithDelay:(unsigned long long)arg1 eventHandler:(id)arg2;
@end

@interface NCNotificationShortLookView : UIView
@property(nonatomic) BOOL isBanner;
@property(nonatomic, retain) UILabel *cucuCountLabel;
@property(nonatomic) int cucuCount;

// Compatibility
@property(nonatomic, retain) UIView *liddellView; // Liddell
@property(nonatomic, retain) UIView *baseView; //
@property(nonatomic, retain, readwrite) VelvetBackgroundView *velvetBackground; // Velvet

@property (nonatomic,copy) NSArray *icons; 

// Timer
- (UIView *) createTimerViewWithSuperview:(UIView *)superview andConstraintsFrom:(UIView *)sibling;

// Fill
- (UIView *) createFillViewWithSuperview:(UIView *)superview;
@end

@interface BBAction : NSObject
+ (id)actionWithLaunchBundleID:(id)arg1 callblock:(id)arg2;
@end

@interface BBBulletin : NSObject
@property(nonatomic, copy)NSString* sectionID;
@property(nonatomic, copy)NSString* recordID;
@property(nonatomic, copy)NSString* publisherBulletinID;
@property(nonatomic, copy)NSString* title;
@property(nonatomic, copy)NSString* message;
@property(nonatomic, retain)NSDate* date;
@property(assign, nonatomic)BOOL clearable;
@property(nonatomic)BOOL showsMessagePreview;
@property(nonatomic, copy)BBAction* defaultAction;
@property(nonatomic, copy)NSString* bulletinID;
@property(nonatomic, retain)NSDate* lastInterruptDate;
@property(nonatomic, retain)NSDate* publicationDate;
@end

@interface BBServer : NSObject
- (void)publishBulletin:(BBBulletin *)arg1 destinations:(NSUInteger)arg2 alwaysToLockScreen:(BOOL)arg3;
- (void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2;
@end

@interface BBObserver : NSObject
@end

@interface NCBulletinNotificationSource : NSObject
- (BBObserver *)observer;
@end

@interface CucuTimerView : UIView
@property(nonatomic, retain) CAShapeLayer *shapeLayer;
@property(nonatomic, retain) UILabel *countLabel;
@property(nonatomic) int count;
@property(nonatomic) UIColor *strokeColor;
@property(nonatomic) int lineWidth;

- (void) startCountTimer;
@end