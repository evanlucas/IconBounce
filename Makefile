ARCHS=armv7 armv7s arm64
TARGET = iphone:clang:7.0

include theos/makefiles/common.mk

export GO_EASY_ON_ME=1

TWEAK_NAME = IconBounce
IconBounce_FILES = Tweak.xm
IconBounce_FRAMEWORKS = UIKit QuartzCore CoreGraphics Foundation
IconBounce_PrivateFrameworks = BulletinBoard

ADDITIONAL_CFLAGS = -Iinclude

SUBPROJECTS = IconBouncePreferences

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"
