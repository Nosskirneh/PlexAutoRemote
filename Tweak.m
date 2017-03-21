NSString *const prefPath = @"/var/mobile/Library/Preferences/se.nosskirneh.plexautoremote.plist";
NSMutableDictionary *preferences;

@interface PMKRemotePlayer : NSObject
@property (nonatomic, assign, readwrite) NSString *description;
@end


@interface PMKPlayerListController : NSObject

@property (nonatomic, assign, readwrite) NSArray<PMKRemotePlayer *> *remotePlayers;
- (void)setSelectedPlayer:(id)arg;
- (id)initWithPlayerManager:(id)arg;

@end


PMKPlayerListController *playerListController;

%hook PMKPlayerManager

- (id)initWithName:(id)arg1 storageController:(id)arg2 remoteControlServerProvider:(id)arg3 playbackOptions:(id)arg4 remoteControlRouter:(id)arg5 resourceControllers:(id)arg6 deviceProvider:(id)arg7 localDevice:(id)arg8 serviceAdvertizer:(id)arg9 serverManager:(id)arg10 cloud:(id)arg11 {
    
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:prefPath];
    if (!preferences) preferences = [[NSMutableDictionary alloc] init];
    
    playerListController = [[%c(PMKPlayerListController) alloc] initWithPlayerManager:self];
    return %orig;
}

%end

BOOL didConnect = NO;

%hook PMHomeViewController

- (void)viewDidLoad {
    %orig;

    if (!didConnect && playerListController.remotePlayers.count > 0) {
        NSString *specName = [preferences objectForKey:@"specifiedDeviceName"];
        
        // Find the matching device
        for (PMKRemotePlayer *player in playerListController.remotePlayers) {
            NSString *name = [playerListController.remotePlayers[0].description substringFromIndex:48];
            name = [name substringToIndex:[name length] - 41];
            if ([name isEqualToString:specName]) {
                HBLogDebug(@"Found match!");
                [playerListController setSelectedPlayer:player];
                didConnect = YES;
            }
        }
    }
    
}

%end
