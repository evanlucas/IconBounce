include theos/makefiles/common.mk

BUNDLE_NAME = IconBouncePreferences
IconBouncePreferences_FILES = IconBouncePreferences.mm
IconBouncePreferences_INSTALL_PATH = /Library/PreferenceBundles
IconBouncePreferences_FRAMEWORKS = UIKit
IconBouncePreferences_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/IconBouncePreferences.plist$(ECHO_END)
