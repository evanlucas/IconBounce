#import <UIKit/UIKit.h>
#import "../NSObject+subscripts.h"
#import <objc/runtime.h>
#define PreferencesFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.curapps.iconbounce.plist"]
#define PreferencesChangedNotification "com.curapps.animationsupdated"

@interface ELManager : NSObject
+ (id)sharedELManager;
- (void)showBannerWithMessage:(NSString *)message;
@end
@interface PSViewController : NSObject
+ (void)load;
- (id)initForContentSize:(CGSize)size;
- (id)view;
- (id)navigationTitle;
- (void)setView:(id)view;
@end

@interface IBSettingsAnimationsController : PSViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *_tableView;
	NSMutableArray *_allAnimations;
	NSMutableArray *_enabledAnimations;
	NSMutableArray *_disabledAnimations;
	NSMutableDictionary *_settings;
    BOOL _settingsChanged;
}
@property (nonatomic, retain) NSMutableArray *allAnimations;
@property (nonatomic, retain) NSMutableArray *enabledAnimations;
@property (nonatomic, retain) NSMutableArray *disabledAnimations;
@property (nonatomic, retain) NSMutableDictionary *settings;
@property (nonatomic) BOOL settingsChanged;
+ (void)load;
- (id)initForContentSize:(CGSize)size;
- (id)view;
- (id)navigationTitle;
- (void)animationsChanged;
- (int) numberOfSectionsInTableView:(UITableView *)tableView;
- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(int)section;
- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(int)section;
- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation IBSettingsAnimationsController
@synthesize allAnimations = _allAnimations;
@synthesize enabledAnimations = _enabledAnimations;
@synthesize disabledAnimations = _disabledAnimations;
@synthesize settings = _settings;
@synthesize settingsChanged = _settingsChanged;
+ (void)load {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[pool drain];
}

- (id)initForContentSize:(CGSize)size {
    if ([[PSViewController class] instancesRespondToSelector:@selector(initForContentSize:)]) {
        self = [super initForContentSize:size];
    } else {
        self = [super init];
    }
	if (self) {
        self.settingsChanged = NO;
        [self loadPrefs];
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStyleGrouped];
		[_tableView setDataSource:self];
		[_tableView setDelegate:self];
		[_tableView setEditing:YES];
		[_tableView setAllowsSelectionDuringEditing:YES];
		if ([self respondsToSelector:@selector(setView:)]) {
			[self setView:_tableView];
		}
        UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(performSave)];
        [[self navigationItem] setRightBarButtonItem:bb];
        [bb release];
	}
	return self;
}
- (void)loadPrefs {
    self.settings = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    self.allAnimations = [[NSMutableArray alloc] initWithObjects:
                          [NSDictionary dictionaryWithObjectsAndKeys:@"RotateClockwise", @"key", @"Rotate Clockwise", @"title", nil],
                          [NSDictionary dictionaryWithObjectsAndKeys:@"RotateCounterClockwise", @"key", @"Rotate Counter Clockwise", @"title", nil],
                          [NSDictionary dictionaryWithObjectsAndKeys:@"FlipHorizontal", @"key", @"Flip Horizontal", @"title", nil],
                          [NSDictionary dictionaryWithObjectsAndKeys:@"FlipVertical", @"key", @"Flip Vertical", @"title", nil],
                          [NSDictionary dictionaryWithObjectsAndKeys:@"Bounce", @"key", @"Bounce", @"title", nil],
                          [NSDictionary dictionaryWithObjectsAndKeys:@"RotateFlipAndBounce", @"key", @"Rotate, Flip, and Bounce", @"title", nil],
                          nil];
    
    self.enabledAnimations = [[NSMutableArray alloc] initWithArray:[self.settings objectForKey:@"EnabledAnimations"]];
    self.disabledAnimations = [[NSMutableArray alloc] initWithArray:[self.settings objectForKey:@"DisabledAnimations"]];
}
- (void)performSave {
    if (!self.settingsChanged) {
        return;
    }
    NSLog(@"PERFORM SAVE");
    [self animationsChanged];
}
- (void)dealloc {
	[_tableView release];
	[_allAnimations release];
	[_enabledAnimations release];
	[_disabledAnimations release];
    [_settings release];
	[super dealloc];
}

- (id)navigationTitle {
	return @"Animations";
}
- (id)view {
	return _tableView;
}

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section {
	return (section == 0) ? _enabledAnimations.count : _disabledAnimations.count;
}

- (id)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
	return (section == 0) ? @"Enabled Animations" : @"Disabled Animations";
}
- (void)animationsChanged {
    [_settings setObject:self.enabledAnimations forKey:@"EnabledAnimations"];
    [_settings setObject:self.disabledAnimations forKey:@"DisabledAnimations"];
    [_settings writeToFile:PreferencesFilePath atomically:YES];
    Class ELManager = objc_getClass("ELManager");
    //[[ELManager sharedELManager] showBannerWithMessage:@"Animations successfully updated!"];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.curapps.showbanner"), NULL, NULL, true);
    NSLog(@"Animations changed");
    self.settingsChanged = NO;
    [self loadPrefs];
    
}
- (id)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IconBounceCell"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"IconBounceCell"] autorelease];
	}
	NSDictionary *animationObj;
    if (indexPath.section == 0) {
        animationObj = [self.enabledAnimations objectAtIndex:indexPath.row];
    } else {
        animationObj = [self.disabledAnimations objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = [animationObj objectForKey:@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSUInteger fromIndex = [fromIndexPath row];
    NSUInteger toIndex = [toIndexPath row];
    if (fromIndexPath.section == toIndexPath.section) return;
    if (fromIndexPath.section == 0) {
        NSDictionary *obj = [self.enabledAnimations objectAtIndex:fromIndex];
        [self.enabledAnimations removeObjectAtIndex:fromIndex];
        [self.disabledAnimations insertObject:obj atIndex:toIndex];
    } else {
        NSDictionary *obj = [self.disabledAnimations objectAtIndex:fromIndex];
        [self.disabledAnimations removeObjectAtIndex:fromIndex];
        [self.enabledAnimations insertObject:obj atIndex:toIndex];
    }
    
    self.settingsChanged = YES;
    // Prefs changed notification
    //[self animationsChanged];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}
@end
