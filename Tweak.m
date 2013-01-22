#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#define PreferencesFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.ia.iconbouncepreferences.plist"]
#define PreferencesChangedNotification "com.iconbouncepreferences.prefs"
@interface SBIconListView : UIView
- (id)initWithFrame:(CGRect)frame;
- (NSArray *)icons;
@end

@interface SBDockIconListView : SBIconListView
- (id)initWithFrame:(CGRect)frame;
@end

@interface SBIconView : UIView
@end
@interface SBFolderIconView : SBIconView
@end
@interface SBIcon
@end
@interface SBIconController
- (SBIconListView *)currentRootIconList;
- (id)isDock;
- (id)dock;
+ (id)sharedInstance;
- (void)iconTapped:(SBIcon *)icon;
@end

@interface SBUIController : NSObject
- (void)finishedUnscattering;
- (void)launchIcon:(id)arg1;
@end

typedef enum AnimationType{
    AnimationTypeRotateClockwise = 0,
    AnimationTypeRotateCounterClockwise,
    AnimationTypeFlipHorizontal,
    AnimationTypeFlipVertical,
    AnimationTypeBounce,
    AnimationTypeRotateFlipAndBounce,
    AnimationTypeSwing
} AnimationType;

@interface ELManager : NSObject
{
    NSTimer *theTimer;
}
+ (ELManager *)sharedELManager;
- (void)performBounce;
- (void)performBounceForIconView:(SBIconView *)iv atIndex:(NSInteger)index withAnimationType:(AnimationType)type;
- (void)repeatTimer:(NSTimer *)timer;
- (void)startBouncing;
- (BOOL)enabled;
- (BOOL)hasOtherDockTweaks;
- (NSArray *)positiveRotation:(BOOL)positive;
@property (nonatomic, retain) NSTimer *theTimer;
@end
//static NSDictionary *prefsDict = nil;

@implementation ELManager
static ELManager *sharedManager;
@synthesize theTimer;
+ (ELManager *)sharedELManager {
    @synchronized(self){
        if (sharedManager == nil) {
            sharedManager = [[[self alloc] init] autorelease];
        }
    }
    return sharedManager;
}
- (void)dealloc {
    [theTimer release];
    [super dealloc];
}
- (BOOL)enabled {
    NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:PreferencesFilePath];
    if (d) {
        return [[d objectForKey:@"enableIconBounce"] boolValue];
    }
    return YES;
}
- (BOOL)hasOtherDockTweaks {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Infinidock.dylib"]) {
        return YES;
    }
    if ([fm fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/ScrollingBoard.dylib"]) {
        return YES;
    }
    return NO;
}

- (void)startBouncing {
    if (!theTimer) {
        theTimer = [NSTimer scheduledTimerWithTimeInterval:2.7 target:self selector:@selector(repeatTimer:) userInfo:nil repeats:YES];
    }
    [self performBounce];
}
- (NSArray *)positiveRotation:(BOOL)positive {
    NSMutableArray *tempArray = [NSMutableArray array];
    if (positive) {
        for (int i=1.0; i<360.0; i++) {
            [tempArray addObject:[NSNumber numberWithFloat:(i/180.0)*M_PI]];
        }
        
    } else {
         for (int i=1.0; i<360.0; i++) {
            [tempArray addObject:[NSNumber numberWithFloat:(-i/180.0)*M_PI]];
        }
    }
    return [NSArray arrayWithArray:tempArray];
}

- (NSArray *)positiveSwing:(BOOL)positive {
    NSMutableArray *tempArray = [NSMutableArray array];
    if (positive) {
        for (int i=1.0; i<45.0; i++) {
            [tempArray addObject:[self deg:i]];
        }
    } else {
        for (int i=1.0; i<45.0; i++) {
            [tempArray addObject:[self deg:-i]];
        }
    }
    return [NSArray arrayWithArray:tempArray];
}
- (NSArray *)swing {
    return [NSArray arrayWithObjects:[self deg:45], [self deg:-45], [self deg:30], [self deg:-30], [self deg:15], [self deg:-15], nil];
}
- (NSNumber *)deg:(float)a {
    return [NSNumber numberWithFloat:(a/180.0f)*M_PI];
}
- (void)performBounce {
    SBIconController *controller = [NSClassFromString(@"SBIconController") sharedInstance];
    Class SBIconView = NSClassFromString(@"SBIconView");
    if ([self enabled]){
        SBDockIconListView *dock = [controller dock];
        if ([self hasOtherDockTweaks]) {
            //Class IFScrollView = NSClassFromString(@"IFScrollView");
            NSArray *a = [dock subviews];
            if (![[a objectAtIndex:0] isKindOfClass:[SBIconView class]]) {
                NSArray *dockIcons = [[a objectAtIndex:0] subviews];
                int count = [dockIcons count];
                if (count != 0) {
                    int current = (int)(arc4random() % count);
                    if ([[dockIcons objectAtIndex:current] isKindOfClass:[SBIconView class]]) {
                        AnimationType animType = (AnimationType)(arc4random() % 7);
                        SBIconView *theIconView = [dockIcons objectAtIndex:current];
                        [self performBounceForIconView:theIconView atIndex:current withAnimationType:animType];
                    }
                }
            }
        } else {
            NSArray *dockIcons = [dock subviews];
            int count = [dockIcons count];
            if (count != 0) {
                if ([[dockIcons objectAtIndex:0] isKindOfClass:[SBIconView class]]) {
                    int current = (int)(arc4random() % count);
                    AnimationType animType = (AnimationType)(arc4random() % 7);
                    SBIconView *theIconView = [dockIcons objectAtIndex:current];
                    [self performBounceForIconView:theIconView atIndex:current withAnimationType:animType];
                }
                
            }
        }
        
        
    }
}
- (void)repeatTimer:(NSTimer *)timer {
    if ([self enabled]) {
        [self performBounce];
    }
}
- (void)updateShadow:(NSTimer *)timer {
    
}
- (void)performBounceForIconView:(SBIconView *)iv atIndex:(NSInteger)index withAnimationType:(AnimationType)type {
    switch (type) {
    
        case AnimationTypeRotateClockwise:
        {
            [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:iv];
            CGPoint c = iv.center;
            CALayer *layer = iv.layer;
            NSString *animationName = [NSString stringWithFormat:@"Animation%d", index];
            [layer removeAnimationForKey:animationName];
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, c.x, c.y);
            CGPathAddLineToPoint(path, NULL, c.x, c.y-20);
            CGPathAddLineToPoint(path, NULL, c.x, c.y);
            CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            anim.path = path;
            anim.repeatCount = 2;
            anim.duration = 0.8;
            anim.delegate = self;
    
            CAKeyframeAnimation *anim2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
            anim2.duration = 1.6;
            anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim2.repeatCount = 1;
            anim2.removedOnCompletion = NO;
            anim2.fillMode = kCAFillModeForwards;
            anim2.values = [self positiveRotation:YES];
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.animations = [NSArray arrayWithObjects:anim, anim2, nil];
            group.duration = 1.6;
            CGPathRelease(path);
            [layer addAnimation:group forKey:animationName];
            
        
        }
            break;
        case AnimationTypeRotateCounterClockwise:
        {
            [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:iv];
            CGPoint c = iv.center;
            CALayer *layer = iv.layer;
            NSString *animationName = [NSString stringWithFormat:@"Animation%d", index];
            [layer removeAnimationForKey:animationName];
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, c.x, c.y);
            CGPathAddLineToPoint(path, NULL, c.x, c.y-20);
            CGPathAddLineToPoint(path, NULL, c.x, c.y);
            CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            anim.path = path;
            anim.repeatCount = 2;
            anim.duration = 0.8;
            anim.delegate = self;
    
            CAKeyframeAnimation *anim2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
            anim2.duration = 1.6;
            anim2.repeatCount = 1;
            anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim2.removedOnCompletion = NO;
            anim2.fillMode = kCAFillModeForwards;
            anim2.values = [self positiveRotation:NO];
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.animations = [NSArray arrayWithObjects:anim, anim2, nil];
            group.duration = 1.6;
            CGPathRelease(path);
            [layer addAnimation:group forKey:animationName];
        }
            break;
        case AnimationTypeFlipHorizontal:
        {
            [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:iv];
            CGPoint c = iv.center;
            CALayer *layer = iv.layer;
            NSString *animationName = [NSString stringWithFormat:@"Animation%d", index];
            [layer removeAnimationForKey:animationName];
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, c.x, c.y);
            CGPathAddLineToPoint(path, NULL, c.x, c.y-20);
            CGPathAddLineToPoint(path, NULL, c.x, c.y);
            CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            anim.path = path;
            anim.repeatCount = 2;
            anim.duration = 0.8;
            anim.delegate = self;
    
            CAKeyframeAnimation *anim2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.y"];
            anim2.duration = 1.6;
            anim2.repeatCount = 1;
            anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim2.removedOnCompletion = NO;
            anim2.fillMode = kCAFillModeForwards;
            anim2.values = [self positiveRotation:NO];
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.animations = [NSArray arrayWithObjects:anim, anim2, nil];
            group.duration = 1.6;
            CGPathRelease(path);
            [layer addAnimation:group forKey:animationName];
        }
            break;
        case AnimationTypeFlipVertical:
        {
            [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:iv];
            CGPoint c = iv.center;
            CALayer *layer = iv.layer;
            NSString *animationName = [NSString stringWithFormat:@"Animation%d", index];
            [layer removeAnimationForKey:animationName];
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, c.x, c.y);
            CGPathAddLineToPoint(path, NULL, c.x, c.y-20);
            CGPathAddLineToPoint(path, NULL, c.x, c.y);
            CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            anim.path = path;
            anim.repeatCount = 2;
            anim.duration = 0.8;
            anim.delegate = self;
    
            CAKeyframeAnimation *anim2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.x"];
            anim2.duration = 1.6;
            anim2.repeatCount = 1;
            anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim2.removedOnCompletion = NO;
            anim2.fillMode = kCAFillModeForwards;
            anim2.values = [self positiveRotation:NO];
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.animations = [NSArray arrayWithObjects:anim, anim2, nil];
            group.duration = 1.6;
            CGPathRelease(path);
            [layer addAnimation:group forKey:animationName];
        }
            break;
        case AnimationTypeBounce:
        {
            [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:iv];
            CGPoint c = iv.center;
            CALayer *layer = iv.layer;
            NSString *animationName = [NSString stringWithFormat:@"Animation%d", index];
            [layer removeAnimationForKey:animationName];
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, c.x, c.y);
            CGPathAddLineToPoint(path, NULL, c.x, c.y-20);
            CGPathAddLineToPoint(path, NULL, c.x, c.y);
            CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            anim.path = path;
            anim.repeatCount = 2;
            anim.duration = 0.8;
            anim.delegate = self;
            [layer addAnimation:anim forKey:animationName];
        }
            break;
        case AnimationTypeRotateFlipAndBounce:
        {
            [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:iv];
            CGPoint c = iv.center;
            CALayer *layer = iv.layer;
            NSString *animationName = [NSString stringWithFormat:@"Animation%d", index];
            [layer removeAnimationForKey:animationName];
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, c.x, c.y);
            CGPathAddLineToPoint(path, NULL, c.x, c.y-20);
            CGPathAddLineToPoint(path, NULL, c.x, c.y);
            CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            anim.path = path;
            anim.repeatCount = 2;
            anim.duration = 0.8;
            anim.delegate = self;
    
            CAKeyframeAnimation *anim2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.x"];
            anim2.duration = 1.6;
            anim2.repeatCount = 1;
            anim2.removedOnCompletion = NO;
            anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim2.fillMode = kCAFillModeForwards;
            anim2.values = [self positiveRotation:NO];
            
            CAKeyframeAnimation *anim3 = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.y"];
            anim3.duration = 1.6;
            anim3.repeatCount = 1;
            anim3.removedOnCompletion = NO;
            anim3.fillMode = kCAFillModeForwards;
            anim3.values = [self positiveRotation:NO];
            
            
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.animations = [NSArray arrayWithObjects:anim, anim2, anim3, nil];
            group.duration = 1.6;
            CGPathRelease(path);
            [layer addAnimation:group forKey:animationName];
        }
            break;
        case AnimationTypeSwing:
        {
            [self setAnchorPoint:CGPointMake(0.5, 0) forView:iv];
            
            CGPoint c = iv.center;
            CALayer *layer = iv.layer;
            NSString *animationName = [NSString stringWithFormat:@"Animation%d", index];
            [layer removeAnimationForKey:animationName];
            CAKeyframeAnimation *anim1 = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
            anim1.repeatCount = 1;
            anim1.duration = 0.6;
            anim1.removedOnCompletion = NO;
            anim1.fillMode = kCAFillModeForwards;
            anim1.values = [self positiveSwing:YES];
            
            CAKeyframeAnimation *anim2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
            anim2.repeatCount = 1;
            anim2.duration = 0.6;
            anim2.removedOnCompletion = NO;
            anim2.fillMode = kCAFillModeForwards;
            anim2.values = [self positiveSwing:NO];
            
            CAKeyframeAnimation *anim3 = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
            anim3.repeatCount = 1;
            anim3.duration = 0.6;
            anim3.removedOnCompletion = NO;
            anim3.fillMode = kCAFillModeForwards;
            anim3.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0], nil];
            
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.animations = [NSArray arrayWithObjects:anim1, anim2, anim3, nil];
            group.duration = 1.6;
            [layer addAnimation:group forKey:animationName];
        }
            break;
        default:
            break;
    }
}

- (void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view {
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

@end

%hook SBUIController
- (void)finishedUnscattering {
    %orig;
    [[ELManager sharedELManager] startBouncing];
}
%end
/*
static void preferenceChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[prefsDict release];
	prefsDict = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
}
 */

__attribute__((constructor)) static void sbc_init() {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// SpringBoard only!
	if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
		return;
    if (![[NSFileManager defaultManager] fileExistsAtPath:PreferencesFilePath]) {
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        [d setValue:[NSNumber numberWithBool:YES] forKey:@"enableIconBounce"];
        [d writeToFile:PreferencesFilePath atomically:YES];
    }
    /*
	prefsDict = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, preferenceChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
    */

	[pool release];
}
