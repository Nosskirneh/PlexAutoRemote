#import "PARColorListItemsController.h"

#define PARColor [UIColor colorWithRed:0.88 green:0.62 blue:0.16 alpha:1.0]

@implementation PARColorListItemsController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Tint
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = PARColor;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = nil;
}

@end
