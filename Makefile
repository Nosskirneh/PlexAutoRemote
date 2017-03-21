include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PlexAutoRemote
PlexAutoRemote_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 PlexMobile"

SUBPROJECTS += parprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
