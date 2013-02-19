#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "CWLSynthesizeSingleton.h"
#import "SpringBoard.h"
#define PreferencesFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.curapps.iconbounce.plist"]
#define PreferencesChangedNotification "com.curapps.iconbounce.prefschanged"

typedef enum AnimationType{
    AnimationTypeRotateClockwise = 0,
    AnimationTypeRotateCounterClockwise,
    AnimationTypeFlipHorizontal,
    AnimationTypeFlipVertical,
    AnimationTypeBounce,
    AnimationTypeRotateFlipAndBounce
} AnimationType;

static BOOL enabled = YES;
static double animationDuration = 1.6;
static double bounceInterval = 2.7;
static NSArray *animations;
@interface ELManager : NSObject <NSURLConnectionDelegate>
CWL_DECLARE_SINGLETON_FOR_CLASS(ELManager)
- (void)performBounce;
- (void)performAnimationForIconView:(SBIconView *)iv atIndex:(NSInteger)index;
- (void)repeatTimer:(NSTimer *)timer;
- (AnimationType)animationTypeForName:(NSString *)name;
- (void)startBouncing;
- (void)performBounceForIconView:(SBIconView *)iv atIndex:(NSInteger)index withAnimationType:(AnimationType)type;
- (BOOL)hasOtherDockTweaks;
- (void)removeAnimations;
- (NSArray *)positiveRotation:(BOOL)positive;
- (void)setAnchorPoint:(CGPoint)pt forView:(UIView *)v;
@property (nonatomic, retain) NSTimer *theTimer;
@end

@implementation ELManager
@synthesize theTimer;
CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(ELManager)
- (void)dealloc {
    [theTimer release];
    [super dealloc];
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
    @try {
        [theTimer invalidate];
        [self removeAnimations];
        double ti = bounceInterval;
        if (bounceInterval < animationDuration) {
            ti += animationDuration;
        }
        
        theTimer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(repeatTimer:) userInfo:nil repeats:YES];
        [self performBounce];

    }
    @catch (NSException *exception) {
        NSLog(@"IconBounce caught exception: %@", exception);
    }

   }
- (void)removeAnimations {
    SBIconController *controller = [NSClassFromString(@"SBIconController") sharedInstance];
    Class SBIconView = NSClassFromString(@"SBIconView");
    if (enabled){
        SBDockIconListView *dock = [controller dock];
        if ([self hasOtherDockTweaks]) {
            NSArray *a = [dock subviews];
            if (![[a objectAtIndex:0] isKindOfClass:[SBIconView class]]) {
                NSArray *dockIcons = [[a objectAtIndex:0] subviews];
                int count = [dockIcons count];
                for (int i=0; i<count; i++) {
                    if ([[dockIcons objectAtIndex:i] isKindOfClass:[SBIconView class]]) {
                        CALayer *layer = [[dockIcons objectAtIndex:i] layer];
                        [layer removeAllAnimations];
                    }
                }
            }
        } else {
            NSArray *dockIcons = [dock subviews];
            int count = [dockIcons count];
            for (int i=0; i<count; i++) {
                if ([[dockIcons objectAtIndex:i] isKindOfClass:[SBIconView class]]) {
                    CALayer *layer = [[dockIcons objectAtIndex:i] layer];
                    [layer removeAllAnimations];
                }
            }
        }
    }

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
- (NSNumber *)deg:(float)a {
    return [NSNumber numberWithFloat:(a/180.0f)*M_PI];
}

- (void)performBounce {
    SBIconController *controller = [NSClassFromString(@"SBIconController") sharedInstance];
    Class SBIconView = NSClassFromString(@"SBIconView");
    if (enabled){
        SBDockIconListView *dock = [controller dock];
        if ([self hasOtherDockTweaks]) {
            NSArray *a = [dock subviews];
            if (![[a objectAtIndex:0] isKindOfClass:[SBIconView class]]) {
                NSArray *dockIcons = [[a objectAtIndex:0] subviews];
                int count = [dockIcons count];
                if (count != 0) {
                    int current = (int)(arc4random() % count);
                    if ([[dockIcons objectAtIndex:current] isKindOfClass:[SBIconView class]]) {
//                      AnimationType animType = (AnimationType)(arc4random() % 6);
                        SBIconView *theIconView = [dockIcons objectAtIndex:current];
                        //[self performBounceForIconView:theIconView atIndex:current withAnimationType:animType];
                        [self performAnimationForIconView:theIconView atIndex:current];
                    }
                }
            }
        } else {
            NSArray *dockIcons = [dock subviews];
            int count = [dockIcons count];
            if (count != 0) {
                if ([[dockIcons objectAtIndex:0] isKindOfClass:[SBIconView class]]) {
                    int current = (int)(arc4random() % count);
//                    AnimationType animType = (AnimationType)(arc4random() % 6);
                    SBIconView *theIconView = [dockIcons objectAtIndex:current];
                    //[self performBounceForIconView:theIconView atIndex:current withAnimationType:animType];
                    [self performAnimationForIconView:theIconView atIndex:current];
                }
                
            }
        }
        
        
    }
}
- (void)repeatTimer:(NSTimer *)timer {
    if (enabled) {
        [self performBounce];
    }
}
- (AnimationType)animationTypeForName:(NSString *)name {
    if ([name isEqualToString:@"RotateClockwise"]) {
        return AnimationTypeRotateClockwise;
    } else if ([name isEqualToString:@"RotateCounterClockwise"]) {
        return AnimationTypeRotateCounterClockwise;
    } else if ([name isEqualToString:@"FlipHorizontal"]) {
        return AnimationTypeFlipHorizontal;
    } else if ([name isEqualToString:@"FlipVertical"]) {
        return AnimationTypeFlipVertical;
    } else if ([name isEqualToString:@"Bounce"]) {
        return AnimationTypeBounce;
    }
    return AnimationTypeRotateFlipAndBounce;
}
- (void)performAnimationForIconView:(SBIconView *)iv atIndex:(NSInteger)index {
    NSInteger totalCount = [animations count];
    int randomIndex = (int)(arc4random() % totalCount);
    NSString *name = [[animations objectAtIndex:randomIndex] objectForKey:@"key"];
    AnimationType animType = [self animationTypeForName:name];
    [self performBounceForIconView:iv atIndex:index withAnimationType:animType];
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
            anim.duration = animationDuration/2;
            anim.delegate = self;
    
            CAKeyframeAnimation *anim2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
            anim2.duration = animationDuration;
            anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim2.repeatCount = 1;
            anim2.removedOnCompletion = NO;
            anim2.fillMode = kCAFillModeForwards;
            anim2.values = [self positiveRotation:YES];
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.animations = [NSArray arrayWithObjects:anim, anim2, nil];
            group.duration = animationDuration;
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
            anim.duration = animationDuration/2;
            anim.delegate = self;
    
            CAKeyframeAnimation *anim2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
            anim2.duration = animationDuration;
            anim2.repeatCount = 1;
            anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim2.removedOnCompletion = NO;
            anim2.fillMode = kCAFillModeForwards;
            anim2.values = [self positiveRotation:NO];
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.animations = [NSArray arrayWithObjects:anim, anim2, nil];
            group.duration = animationDuration;
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
            anim.duration = animationDuration/2;
            anim.delegate = self;
    
            CAKeyframeAnimation *anim2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.y"];
            anim2.duration = animationDuration;
            anim2.repeatCount = 1;
            anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim2.removedOnCompletion = NO;
            anim2.fillMode = kCAFillModeForwards;
            anim2.values = [self positiveRotation:NO];
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.animations = [NSArray arrayWithObjects:anim, anim2, nil];
            group.duration = animationDuration;
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
            anim.duration = animationDuration/2;
            anim.delegate = self;
    
            CAKeyframeAnimation *anim2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.x"];
            anim2.duration = animationDuration;
            anim2.repeatCount = 1;
            anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim2.removedOnCompletion = NO;
            anim2.fillMode = kCAFillModeForwards;
            anim2.values = [self positiveRotation:NO];
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.animations = [NSArray arrayWithObjects:anim, anim2, nil];
            group.duration = animationDuration;
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
            anim.duration = animationDuration/2;
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
            anim.duration = animationDuration/2;
            anim.delegate = self;
    
            CAKeyframeAnimation *anim2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.x"];
            anim2.duration = animationDuration;
            anim2.repeatCount = 1;
            anim2.removedOnCompletion = NO;
            anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            anim2.fillMode = kCAFillModeForwards;
            anim2.values = [self positiveRotation:NO];
            
            CAKeyframeAnimation *anim3 = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.y"];
            anim3.duration = animationDuration;
            anim3.repeatCount = 1;
            anim3.removedOnCompletion = NO;
            anim3.fillMode = kCAFillModeForwards;
            anim3.values = [self positiveRotation:NO];
            
            
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.animations = [NSArray arrayWithObjects:anim, anim2, anim3, nil];
            group.duration = animationDuration;
            CGPathRelease(path);
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

%hook SBFolderIcon
- (void)launch {
    [[ELManager sharedELManager] removeAnimations];
    %orig;
}
%end

%hook SBIcon
- (void)launch {
    [[ELManager sharedELManager] removeAnimations];
    %orig;
}
%end
%hook SBIconController
- (void)closeFolderTimerFired {
    [[ELManager sharedELManager] startBouncing];
    %orig;
}
%end

static void LoadSettings()
{
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    id temp = [dict objectForKey:@"enableIconBounce"];
    enabled = !temp || [temp boolValue];
    if ([[dict objectForKey:@"animationDuration"] doubleValue]) {
        animationDuration = [[dict objectForKey:@"animationDuration"] doubleValue];
    } else {
        animationDuration = 1.6;
    }
    if ([[dict objectForKey:@"bounceInterval"] doubleValue]) {
        bounceInterval = [[dict objectForKey:@"bounceInterval"] doubleValue];
    } else {
        bounceInterval = 2.7;
    }
    NSArray *tempEnabledAnims = [dict objectForKey:@"EnabledAnimations"];
    NSArray *tempDisabledAnims = [dict objectForKey:@"DisabledAnimations"];
    NSArray *tempAllAnims = [dict objectForKey:@"AllAnimations"];
    animations = [[NSArray arrayWithArray:tempEnabledAnims] retain];
    [[ELManager sharedELManager] startBouncing];
    [dict release];
}

__attribute__((constructor)) static void ib_init() {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// SpringBoard only!
	if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
		return;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:PreferencesFilePath]) {
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        [d setValue:[NSNumber numberWithBool:YES] forKey:@"enableIconBounce"];
        [d setValue:[NSNumber numberWithDouble:1.6] forKey:@"animationDuration"];
        [d setValue:[NSNumber numberWithDouble:2.7] forKey:@"bounceInterval"];
        NSArray *allAnimations = [[NSMutableArray alloc] initWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:@"RotateClockwise", @"key", @"Rotate Clockwise", @"title", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"RotateCounterClockwise", @"key", @"Rotate Counter Clockwise", @"title", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"FlipHorizontal", @"key", @"Flip Horizontal", @"title", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"FlipVertical", @"key", @"Flip Vertical", @"title", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"Bounce", @"key", @"Bounce", @"title", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"RotateFlipAndBounce", @"key", @"Rotate, Flip, and Bounce", @"title", nil],
                            nil];
        NSArray *enabledAnimations = [[NSArray alloc] initWithArray:allAnimations];
        NSArray *disabledAnimations = [[NSArray alloc] init];
        [d setValue:enabledAnimations forKey:@"EnabledAnimations"];
        [d setValue:disabledAnimations forKey:@"DisabledAnimations"];
        [allAnimations release];
        [enabledAnimations release];
        [disabledAnimations release];
        [d writeToFile:PreferencesFilePath atomically:YES];
    } else {
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
        enabled = [[dict objectForKey:@"enableIconBounce"] boolValue];
        if ([[dict objectForKey:@"animationDuration"] doubleValue]) {
            animationDuration = [[dict objectForKey:@"animationDuration"] doubleValue];
        } else {
            animationDuration = 1.6;
        }
        if ([[dict objectForKey:@"bounceInterval"] doubleValue]) {
            bounceInterval = [[dict objectForKey:@"bounceInterval"] doubleValue];
        } else {
            bounceInterval = 2.7;
        }
        animations = [[NSArray arrayWithArray:[dict objectForKey:@"EnabledAnimations"]] retain];
        [dict release];
    }
    LoadSettings();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (void (*)(CFNotificationCenterRef, void *, CFStringRef, const void *, CFDictionaryRef))LoadSettings, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
	[pool release];
}

/* vim: set filetype=objcpp sw=4 ts=4 expandtab tw=80 ff=unix */
