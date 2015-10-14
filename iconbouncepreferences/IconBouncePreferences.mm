#import <UIKit/UIKit.h>
@interface PSListController
{
    NSArray *_specifiers;
}
- (NSArray *)loadSpecifiersFromPlistName:(NSString *)name target:(id)target;
@end
@interface IconBouncePreferencesListController: PSListController {
}
- (id)specifiers;
- (void)donate:(id)arg;
@end

@implementation IconBouncePreferencesListController
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
