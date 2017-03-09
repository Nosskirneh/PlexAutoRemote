@interface PMKPlayerListController : NSObject

@property (nonatomic, assign, readwrite) NSArray *remotePlayers;
- (void)setSelectedPlayer:(id)arg;
- (id)initWithPlayerManager:(id)arg;
@end


PMKPlayerListController *playerListController;

%hook PMKPlayerManager

- (id)initWithName:(id)arg1 storageController:(id)arg2 remoteControlServerProvider:(id)arg3 playbackOptions:(id)arg4 remoteControlRouter:(id)arg5 resourceControllers:(id)arg6 deviceProvider:(id)arg7 localDevice:(id)arg8 serviceAdvertizer:(id)arg9 serverManager:(id)arg10 eventSourceManager:(id)arg11 cloud:(id)arg12 {
    
    playerListController = [[%c(PMKPlayerListController) alloc] initWithPlayerManager:self];
    return %orig;
}

%end


%hook PMHomeViewController

- (void)viewDidAppear:(BOOL)arg {
    %orig;
    
    if (playerListController.remotePlayers.count > 0) {
        [playerListController setSelectedPlayer:playerListController.remotePlayers[0]];
    }
    
}

%end
