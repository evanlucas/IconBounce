#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "CWLSynthesizeSingleton.h"
#import "SpringBoard.h"
#import "Firmware.h"

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
static BOOL debug = NO;
static double animationDuration = 1.6;
static double bounceInterval = 2.7;
static BOOL animateLabels = YES;
static NSArray *animations;

#define IBLog(fmt, ...) if (debug) NSLog((@"IconBounce [DEBUG] - " fmt), ##__VA_ARGS__);

@interface IBManager : NSObject
CWL_DECLARE_SINGLETON_FOR_CLASS(IBManager)
- (void)performBounce;
- (void)performAnimationForIconView:(SBIconView *)iv atIndex:(NSInteger)index;
- (void)repeatTimer:(NSTimer *)timer;
- (AnimationType)animationTypeForName:(NSString *)name;
- (void)startBouncing;
- (void)performBounceForIconView:(SBIconView *)iv atIndex:(NSInteger)index withAnimationType:(AnimationType)type;
- (void)removeAnimations;
- (NSArray *)positiveRotation:(BOOL)positive;
- (void)setAnchorPoint:(CGPoint)pt forView:(UIView *)v;
- (BOOL)dockSubviewsAreIconViews;
@property (nonatomic, retain) NSTimer *theTimer;
@end

@implementation IBManager
@synthesize theTimer;
CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(IBManager)

- (void)dealloc {
  [theTimer release];
  [super dealloc];
}

- (BOOL)dockSubviewsAreIconViews {
  SBIconController *controller = [NSClassFromString(@"SBIconController") sharedInstance];
  Class SBIconView = NSClassFromString(@"SBIconView");
  SBDockIconListView *dock = [controller iconBounceDock];
  NSArray *dockSubviews = [dock subviews];
  if (dockSubviews.count == 0) {
    IBLog(@"Dock has no subviews...");
    return NO;
  }
  if ([[dockSubviews objectAtIndex:0] isKindOfClass:[SBIconView class]]) {
    return YES;
  }
  
  return NO;
}

- (void)removeAnimations {
  SBIconController *controller = [NSClassFromString(@"SBIconController") sharedInstance];
  Class SBIconView = NSClassFromString(@"SBIconView");
  if (enabled) {
    SBDockIconListView *dock = [controller iconBounceDock];
    if (![self dockSubviewsAreIconViews]) {
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

- (void)startBouncing {
  IBLog(@"startBouncing");
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

- (void)repeatTimer:(NSTimer *)timer {
  if (enabled) {
    [self performBounce];
  }
}

- (void)performBounce {
  IBLog(@"performBounce");
  SBIconController *controller = [NSClassFromString(@"SBIconController") sharedInstance];
  Class SBIconView = NSClassFromString(@"SBIconView");
  if (enabled) {
    IBLog(@"enabled");
    SBDockIconListView *dock = [controller iconBounceDock];
    if (![self dockSubviewsAreIconViews]) {
      IBLog(@"dock subviews are not of class SBIconView");
      NSArray *a = [dock subviews];
      if (![[a objectAtIndex:0] isKindOfClass:[SBIconView class]]) {
        NSArray *dockIcons = [[a objectAtIndex:0] subviews];
        int count = [dockIcons count];
        if (count != 0) {
          int current = (int)(arc4random() % count);
          if ([[dockIcons objectAtIndex:current] isKindOfClass:[SBIconView class]]) {
            id theIconView = [dockIcons objectAtIndex:current];
            if (!animateLabels) {
              if ([theIconView respondsToSelector:@selector(iconImageView)]) {
                IBLog(@"[SBIconView respondsToSelector:@select(iconImageView)] - YES");
                id iv = [theIconView iconImageView];
                [theIconView hideShadows];
                [self performAnimationForIconView:iv atIndex:current];
              } else if ([theIconView respondsToSelector:@selector(_iconImageView)]) {
                IBLog(@"[SBIconView respondsToSelector:@select(_iconImageView)] - YES");
                id iv = [theIconView _iconImageView];
                [theIconView hideShadows];
                [self performAnimationForIconView:iv atIndex:current];
              } else {
                IBLog(@"[SBIconView respondsToSelector:@select(iconImageView)] - NO");
                [self performAnimationForIconView:theIconView atIndex:current];
              }
            } else {
              [self performAnimationForIconView:theIconView atIndex:current];
            }
          }
        }
      }
    } else {
      IBLog(@"dock subviews are of class SBIconView");
      NSArray *dockIcons = [dock subviews];
      int count = [dockIcons count];
      if (count != 0) {
        if ([[dockIcons objectAtIndex:0] isKindOfClass:[SBIconView class]]) {
          int current = (int)(arc4random() % count);
          id theIconView = [dockIcons objectAtIndex:current];
          if (!animateLabels) {
            if ([theIconView respondsToSelector:@selector(iconImageView)]) {
              IBLog(@"[SBIconView respondsToSelector:@select(iconImageView)] - YES");
              id iv = [theIconView iconImageView];
              [theIconView hideShadows];
              [self performAnimationForIconView:iv atIndex:current];
            } else if ([theIconView respondsToSelector:@selector(_iconImageView)]) {
              IBLog(@"[SBIconView respondsToSelector:@select(_iconImageView)] - YES");
              id iv = [theIconView _iconImageView];
              [theIconView hideShadows];
              [self performAnimationForIconView:iv atIndex:current];
            } else {
              IBLog(@"[SBIconView respondsToSelector:@select(iconImageView)] - NO");
              [self performAnimationForIconView:theIconView atIndex:current];
            }
          } else {
            [self performAnimationForIconView:theIconView atIndex:current];
          }
        }
      }
    }
  }
}

- (void)performAnimationForIconView:(SBIconView *)iv atIndex:(NSInteger)index {
  NSInteger totalCount = [animations count];
	if (totalCount < 1) return;
  int randomIndex = (int)(arc4random() % totalCount);
  NSString *name = [[animations objectAtIndex:randomIndex] objectForKey:@"key"];
  AnimationType animType = [self animationTypeForName:name];
  [self performBounceForIconView:iv atIndex:index withAnimationType:animType];
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

- (void)performBounceForIconView:(SBIconView *)iv atIndex:(NSInteger)index withAnimationType:(AnimationType)type {
  switch (type) {
      
    case AnimationTypeRotateClockwise:
    {
      [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:iv];
      CGPoint c = iv.center;
      CALayer *layer = iv.layer;
      NSString *animationName = [NSString stringWithFormat:@"Animation%ld", (long)index];
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
      NSString *animationName = [NSString stringWithFormat:@"Animation%ld", (long)index];
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
      NSString *animationName = [NSString stringWithFormat:@"Animation%ld", (long)index];
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
      NSString *animationName = [NSString stringWithFormat:@"Animation%ld", (long)index];
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
      NSString *animationName = [NSString stringWithFormat:@"Animation%ld", (long)index];
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
      NSString *animationName = [NSString stringWithFormat:@"Animation%ld", (long)index];
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


// Hooks

%hook SBUIController %group FIRMWARE_LTE_iOS_7_0
- (void)finishedUnscattering {
  %orig;
  [[IBManager sharedIBManager] startBouncing];
}
%end %end

%hook SBUIController %group FIRMWARE_GTE_iOS_7_0
- (void)restoreContent {
  %orig;
  [[IBManager sharedIBManager] startBouncing];
}
%end %end

%hook SBIconController
%new
- (id)iconBounceDock {
  if ([self respondsToSelector:@selector(dock)]) {
    return [self dock];
  }
  return [self dockListView];
}
%end

%hook SBIconView
%new
- (void)hideShadows {
  if ([self respondsToSelector:@selector(setShadowsHidden:)]) {
    IBLog(@"Hiding shadow");
    [self setShadowsHidden:YES];
  }
}
%end


static void ReloadSettings() {
  NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
  NSArray *tempEnabledAnims = [dict objectForKey:@"EnabledAnimations"];
  animations = [[NSArray arrayWithArray:tempEnabledAnims] retain];
  [dict release];
}

static void LoadSettings() {
  NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
  IBLog(@"Loading settings");
  id temp = [dict objectForKey:@"enableIconBounce"];
  if (!temp) {
    IBLog(@"enableIconBounce: YES");
    enabled = YES;
  } else {
    IBLog(@"enableIconBounce %@", [temp boolValue] ? @"YES" : @"NO");
    enabled = [temp boolValue];
  }
  
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
  
  if ([[dict objectForKey:@"bounceLabels"] boolValue]) {
    animateLabels = YES;
  } else {
    animateLabels = NO;
  }
  
  if ([[dict objectForKey:@"debugIconBounce"] boolValue]) {
    debug = YES;
  } else {
    debug = NO;
  }
  [dict release];
}

static void CreateSettings() {
  NSLog(@"IconBounce - Welcome to the machine...");
  NSMutableDictionary *d = [NSMutableDictionary dictionary];
  [d setValue:[NSNumber numberWithBool:YES] forKey:@"enableIconBounce"];
  [d setValue:[NSNumber numberWithBool:NO] forKey:@"debugIconBounce"];
  [d setValue:[NSNumber numberWithDouble:1.6] forKey:@"animationDuration"];
  [d setValue:[NSNumber numberWithDouble:2.7] forKey:@"bounceInterval"];
  [d setValue:[NSNumber numberWithBool:YES] forKey:@"bounceLabels"];
  NSArray *allAnimations = [[NSMutableArray alloc] initWithObjects:
                            [NSDictionary dictionaryWithObjectsAndKeys:@"RotateClockwise", @"key", @"Rotate Clockwise", @"title", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"RotateCounterClockwise", @"key", @"Rotate Counter Clockwise", @"title", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"FlipHorizontal", @"key", @"Flip Horizontal", @"title", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"FlipVertical", @"key", @"Flip Vertical", @"title", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"Bounce", @"key", @"Bounce", @"title", nil],
                            [NSDictionary dictionaryWithObjectsAndKeys:@"RotateFlipAndBounce", @"key", @"Rotate, Flip, and Bounce", @"title", nil],
                            nil];
  NSArray *enabledAnimations = [[NSArray alloc] initWithArray:allAnimations];
  [d setValue:enabledAnimations forKey:@"EnabledAnimations"];
  [d setValue:[NSNumber numberWithBool:YES] forKey:@"HasRun"];
  [allAnimations release];
  [enabledAnimations release];
  [d writeToFile:PreferencesFilePath atomically:YES];
}

__attribute__((constructor)) static void ib_init() {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"])
    return;
  
  if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_6_0) {
    %init(FIRMWARE_GTE_iOS_7_0);
  } else {
    %init(FIRMWARE_LTE_iOS_7_0);
  }
  
  %init;
  
  if (![[NSFileManager defaultManager] fileExistsAtPath:PreferencesFilePath]) {
    CreateSettings();
  } else {
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    enabled = [[dict objectForKey:@"enableIconBounce"] boolValue];
    
    debug = [[dict objectForKey:@"debugIconBounce"] boolValue];
    
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
    if ([[dict objectForKey:@"bounceLabels"] boolValue]) {
      animateLabels = YES;
    } else {
      animateLabels = NO;
    }
    BOOL hasRun = [[dict objectForKey:@"HasRun"] boolValue];
    if (!hasRun) {
      CreateSettings();
    }
    animations = [[NSArray arrayWithArray:[dict objectForKey:@"EnabledAnimations"]] retain];
    [dict release];
  }
  LoadSettings();
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (void (*)(CFNotificationCenterRef, void *, CFStringRef, const void *, CFDictionaryRef))LoadSettings, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (void (*)(CFNotificationCenterRef, void *, CFStringRef, const void *, CFDictionaryRef))ReloadSettings, CFSTR("com.curapps.prefschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	[pool drain];
}
