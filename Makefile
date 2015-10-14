IPHONE_ARCHS = armv7 armv7s arm64

TARGET_IPHONEOS_DEPLOYMENT_VERSION = 5.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION_arm64 = 7.0

export GO_EASY_ON_ME=1

TWEAK_NAME = IconBounce
IconBounce_FILES = Tweak.xm
IconBounce_FRAMEWORKS = UIKit QuartzCore CoreGraphics Foundation
IconBounce_PrivateFrameworks = BulletinBoard
IconBounce_LDFLAGS += -Wl,-segalign,4000
ADDITIONAL_CFLAGS = -Iinclude

SUBPROJECTS = IconBouncePreferences
include theos/makefiles/common.mk
include theos/makefiles/tweak.mk
include theos/makefiles/aggregate.mk

INSTALL_TARGET_PROCESSES = SpringBoard

after-install::
	install.exec "killall -9 SpringBoard"
