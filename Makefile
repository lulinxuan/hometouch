
THEOS_DEVICE_IP=192.168.1.104
export TARGET = iphone:8.2:8.2
ARCHS=arm64
include theos/makefiles/common.mk

TWEAK_NAME = HomeTouch
HomeTouch_FILES = Tweak.xm
HomeTouch_FRAMEWORKS= UIKit IOKit
HomeTouch_PRIVATE_FRAMEWORKS = BiometricKit
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
