include $(THEOS)/makefiles/common.mk

ARCHS = arm64 arm64e

TWEAK_NAME = BookmarkIcons

BookmarkIcons_FILES = Tweak.xm BookmarkIconManager.m
BookmarkIcons_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileSafari"
