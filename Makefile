export ARCHS=armv7
export TARGET=iphone:latest:4.3
include theos/makefiles/common.mk
export GO_EASY_ON_ME=1
TWEAK_NAME = iconbounce
iconbounce_FILES = Tweak.xm
iconbounce_FRAMEWORKS = UIKit QuartzCore CoreGraphics Foundation
SUBPROJECTS = iconbouncepreferences
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
