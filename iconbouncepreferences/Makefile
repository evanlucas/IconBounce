IPHONE_ARCHS = armv7 armv7s arm64

export GO_EASY_ON_ME=1

BUNDLE_NAME = IconBouncePreferences
IconBouncePreferences_FILES = IconBouncePreferences.mm IBSettingsAnimationsController.mm
IconBouncePreferences_INSTALL_PATH = /Library/PreferenceBundles
IconBouncePreferences_FRAMEWORKS = UIKit Foundation
IconBouncePreferences_PRIVATE_FRAMEWORKS = Preferences
IconBouncePreferences_LDFLAGS += -Wl,-segalign,4000

include theos/makefiles/common.mk
include theos/makefiles/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/IconBouncePreferences.plist$(ECHO_END)
