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


