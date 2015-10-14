
@interface SBIconListView : UIView
- (id)initWithFrame:(CGRect)frame;
- (NSArray *)icons;
@end

@interface SBDockIconListView : SBIconListView
- (id)initWithFrame:(CGRect)frame;
@end

@interface SBIconView : UIView
{
    UIImageView *shadow;
}
- (void)_updateShadow;
- (id)iconImageView;
- (id)_iconImageView;
- (void)hideShadows;
- (void)setShadowsHidden:(BOOL)hidden;
@end
@interface SBFolderIconView : SBIconView
@end
@interface SBIcon
@end
@interface SBIconController
- (SBIconListView *)currentRootIconList;
- (id)isDock;
- (id)dock; // < iOS 7
+ (id)sharedInstance;
- (void)iconTapped:(SBIcon *)icon;
- (id)iconBounceDock;
- (id)dockListView; // iOS 7
- (BOOL)respondsToSelector:(SEL)a;
@end

@interface SBUIController : NSObject
- (void)launchIcon:(id)arg1;
@end

@interface SBUIController (pre_iOS7)
- (void)finishedUnscattering;
@end

@interface SBUIController (iOS7)
- (void)restoreContent;
@end
