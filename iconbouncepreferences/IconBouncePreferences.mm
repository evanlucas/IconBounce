#import <UIKit/UIKit.h>
@interface PSListController
{
  NSArray *_specifiers;
}
- (NSArray *)loadSpecifiersFromPlistName:(NSString *)name target:(id)target;
@end

@interface PSSpecifier : NSObject {
@private
  NSMutableDictionary *_properties;
}

@property(retain) NSMutableDictionary* properties;
@end

@interface IconBouncePreferencesListController: PSListController {
}
- (id)specifiers;
- (void)donate:(id)arg;
- (id)readPreferenceValue:(PSSpecifier *)specifier;
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier;
@end

#define PATH_COMPONENT @"Library/Preferences/com.curapps.iconbounce.plist"
#define HOME NSHomeDirectory()
#define PREFS_PATH [HOME stringByAppendingPathComponent:PATH_COMPONENT]

@implementation IconBouncePreferencesListController

// The next two are from
// http://iphonedevwiki.net/index.php/PreferenceBundles#Loading_Preferences_into_sandboxed.2Funsandboxed_processes_in_iOS_8
- (id)readPreferenceValue:(PSSpecifier *)specifier {
	NSDictionary *s = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH];
	if (!s[specifier.properties[@"key"]]) {
		return specifier.properties[@"default"];
	}
	return s[specifier.properties[@"key"]];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PREFS_PATH]];
	[defaults setObject:value forKey:specifier.properties[@"key"]];
	[defaults writeToFile:PREFS_PATH atomically:YES];
	CFStringRef toPost = (CFStringRef)specifier.properties[@"PostNotification"];
	if (toPost) {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                         toPost,
                                         NULL,
                                         NULL,
                                         YES);
  }
}

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"IconBouncePreferences" target:self] retain];
	}
	return _specifiers;
}

#define PAYPAL_URL @"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=evanlucas@me.com&item_number=IconBounce"
#define TWITTER_URL @"https://twitter.com/evanhlucas"
#define GITHUB_URL @"https://github.com/evanlucas"

- (void)donate:(id)arg {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PAYPAL_URL]];
}

- (void)follow:(id)arg {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:TWITTER_URL]];
}

- (void)github:(id)arg {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:GITHUB_URL]];
}
@end

// vim:ft=objc
