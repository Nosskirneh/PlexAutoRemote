NSString *const prefPath = @"/var/mobile/Library/Preferences/se.nosskirneh.plexautoremote.plist";
NSString *const deviceNamesKey = @"DeviceNames";
NSMutableDictionary *preferences;

@interface PMKRemotePlayer : NSObject
@property (nonatomic, assign, readwrite) NSString *description;
@end


@interface PMKPlayerListController : NSObject

@property (nonatomic, assign, readwrite) NSArray<PMKRemotePlayer *> *remotePlayers;
- (void)setSelectedPlayer:(id)arg;
- (id)initWithPlayerManager:(id)arg;

@end


// Method that updates changes to .plist
void writeToSettings() {
    if (![preferences writeToFile:prefPath atomically:YES]) {
        HBLogError(@"Could not save preferences!");
    }
}


PMKPlayerListController *playerListController;

%hook PMKPlayerManager

- (id)initWithName:(id)arg1 storageController:(id)arg2 remoteControlServerProvider:(id)arg3 remoteControlRouter:(id)arg4 resourceControllers:(id)arg5 deviceProvider:(id)arg6 localDevice:(id)arg7 serviceAdvertizer:(id)arg8 serverManager:(id)arg9 cloud:(id)arg10 {
    
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if (!preferences) preferences = [[NSMutableDictionary alloc] init];
    
    playerListController = [[%c(PMKPlayerListController) alloc] initWithPlayerManager:self];
    return %orig;
}

%end


BOOL didConnect = NO;

%hook PMHomeViewController

- (void)viewDidLoad {

    if (!didConnect && playerListController.remotePlayers.count > 0) {
        NSString *specName = [preferences objectForKey:@"specifiedDeviceName"];

        NSMutableArray<NSString *> *deviceNames = [[NSMutableArray alloc] init];
        
        // Find the matching device
        int i = 0;
        for (PMKRemotePlayer *player in playerListController.remotePlayers) {
            // Remove the first crap of text
            NSString *name = [playerListController.remotePlayers[i].description substringFromIndex:48];

            // Remove the last crap of text
            NSRange range = [name rangeOfString:@" - " options:NSBackwardsSearch];
            name = [name substringToIndex:range.location];

            // Connect to device if name matches
            if ([name isEqualToString:specName]) {
                didConnect = YES;
                HBLogDebug(@"Found match!");
                [playerListController setSelectedPlayer:player];
            }

            HBLogDebug(@"name: %@, specName: %@", name, specName);
            [deviceNames addObject:name];

            i++;
        }

        [preferences setObject:deviceNames forKey:deviceNamesKey];
        writeToSettings();
    }
    
    %orig;
}

%end
