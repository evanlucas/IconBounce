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
- (void)donate:(id)arg {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=evanlucas@me.com&item_number=IconBounce"]];
}
- (void)follow:(id)arg {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/evanhlucas"]];
}
@end

// vim:ft=objc
