include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PlexAutoRemotePrefs
PlexAutoRemotePrefs_FILES = $(wildcard *.m) $(wildcard *.x)
PlexAutoRemotePrefs_INSTALL_PATH = /Library/PreferenceBundles
PlexAutoRemotePrefs_FRAMEWORKS = UIKit
PlexAutoRemotePrefs_PRIVATE_FRAMEWORKS = Preferences

after-install::
	install.exec "killall -9 Preferences"

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PlexAutoRemotePrefs.plist$(ECHO_END)
