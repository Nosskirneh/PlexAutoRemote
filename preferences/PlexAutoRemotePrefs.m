#import <Preferences/Preferences.h>
NSString *const prefPath = @"/var/mobile/Library/Preferences/se.nosskirneh.plexautoremote.plist";
NSString *const deviceNamesKey = @"DeviceNames";
NSString *const specifiedDeviceNameKey = @"specifiedDeviceName";

#define PARColor [UIColor colorWithRed:0.88 green:0.62 blue:0.16 alpha:1.0]

@interface PlexAutoRemotePrefsRootListController : PSListController {
    UIWindow *settingsView;
}
@end

@implementation PlexAutoRemotePrefsRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"PlexAutoRemote" target:self] retain];
	}

	return _specifiers;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self insertDevices];
}

- (void)reloadSpecifiers {
    [super reloadSpecifiers];

    [self insertDevices];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Tint
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = PARColor;

    [self reloadSpecifiers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    settingsView = [[UIApplication sharedApplication] keyWindow];
    settingsView.tintColor = nil;
}

- (void)setCellForRowAtIndexPath:(NSIndexPath *)indexPath enabled:(BOOL)enabled {
    UITableViewCell *cell = [self tableView:self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
    if (cell) {
        cell.userInteractionEnabled = enabled;
        cell.textLabel.enabled = enabled;
        cell.detailTextLabel.enabled = enabled;
        
        if ([cell isKindOfClass:[PSControlTableCell class]]) {
            PSControlTableCell *controlCell = (PSControlTableCell *)cell;
            if (controlCell.control) {
                controlCell.control.enabled = enabled;
            }
        } else if ([cell isKindOfClass:[PSTableCell class]]) {
            PSTableCell *tableCell = (PSTableCell *)cell;
            [tableCell setCellEnabled:enabled];
        }
    }
}

- (void)insertDevices {
    NSDictionary *preferences = [[NSDictionary alloc] initWithContentsOfFile:prefPath];
    NSMutableArray *deviceNames = ((NSMutableArray *)[preferences objectForKey:deviceNamesKey]);

    if (deviceNames.count > 0) {
        // Get the specifier for it
        PSSpecifier *devicesCell = self->_specifiersByID[@"Device"];

        [deviceNames insertObject:@"None" atIndex:0];

        [devicesCell setProperty:nil forKey:@"default"];
        [devicesCell setValues:deviceNames titles:deviceNames];

    } else {
        [self setCellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] enabled:NO];
    }
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:prefPath];
    NSString *key = [specifier propertyForKey:@"key"];

    if ([key isEqualToString:@"Device"] && preferences[specifiedDeviceNameKey]) {
        if ([preferences[specifiedDeviceNameKey] isEqualToString:@""]) {
            return @"None";
        }
        return preferences[specifiedDeviceNameKey];
    }

    return specifier.properties[@"default"];
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSMutableDictionary *preferences = [NSMutableDictionary dictionary];
    [preferences addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:prefPath]];
    NSString *key = [specifier propertyForKey:@"key"];

    if ([key isEqualToString:@"Device"]) {
        if ([value isEqualToString:@"None"]) {
            [preferences setObject:@"" forKey:specifiedDeviceNameKey];
        } else {
            [preferences setObject:value forKey:specifiedDeviceNameKey];
        }
    }

    [preferences writeToFile:prefPath atomically:YES];
}

@end


@interface PARHeaderCell : PSTableCell
@end

@implementation PARHeaderCell {
    UILabel *_headerLabel;
    UILabel *_subheaderLabel;
}

- (id)initWithSpecifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
    if (self) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:35];
        
        _headerLabel = [[UILabel alloc] init];
        [_headerLabel setText:@"PlexAutoRemote"];
        [_headerLabel setTextColor:[UIColor blackColor]];
        [_headerLabel setFont:font];
        
        _subheaderLabel = [[UILabel alloc] init];
        [_subheaderLabel setText:@"by Andreas Henriksson"];
        [_subheaderLabel setTextColor:[UIColor grayColor]];
        [_subheaderLabel setFont:[font fontWithSize:17]];
        
        [self addSubview:_headerLabel];
        [self addSubview:_subheaderLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_headerLabel sizeToFit];
    [_subheaderLabel sizeToFit];
    
    CGRect frame = _headerLabel.frame;
    frame.origin.y = 20;
    frame.origin.x = self.frame.size.width / 2 - _headerLabel.frame.size.width / 2;
    _headerLabel.frame = frame;
    
    frame.origin.y += _headerLabel.frame.size.height - 10;
    frame.origin.x = self.frame.size.width / 2 - _subheaderLabel.frame.size.width / 2;
    _subheaderLabel.frame = frame;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width {
    // Return a custom cell height.
    return 80;
}

@end
