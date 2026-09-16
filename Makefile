TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROVISIONING = YES

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DisableDouyinHotUpdate

DisableDouyinHotUpdate_FILES = Tweak.x
DisableDouyinHotUpdate_CFLAGS = -fobjc-arc
DisableDouyinHotUpdate_FRAMEWORKS = Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
