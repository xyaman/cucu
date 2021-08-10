#import "CCURootListController.h"

@implementation CCURootListController

- (instancetype) init {
    self = [super init];

    if (self) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:(36.0/255.0) green:(132.0/255.0) blue:(128.0/255.0) alpha:1.0];
        appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0.0 alpha:0.0];

        self.hb_appearanceSettings = appearanceSettings;
    }

    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];

     // Add respring at right
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Test banner" style:UIBarButtonItemStyleDone target:self action:@selector(testBanner:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:(36.0/255.0) green:(132.0/255.0) blue:(128.0/255.0) alpha:1.0];;
}

- (void) setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [super setPreferenceValue:value specifier:specifier];

    if([[specifier propertyForKey:@"key"] isEqualToString:@"isEnabled"]) [self respringPrompt];
}

- (void) respringPrompt {

    UIAlertController* resetAlert = [UIAlertController alertControllerWithTitle:@"Respring required" message:@"Changing this options requires a respring. Do you want to respring now?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* confirmAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [self respring:nil];
    }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];

    [resetAlert addAction:confirmAction];
    [resetAlert addAction:cancelAction];

    [self presentViewController:resetAlert animated:YES completion:nil];

}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleInsetGrouped;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)testBanner:(id)sender {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)@"com.xyaman.cucupreferences/TestBanner", nil, nil, true);
}

- (void)respring:(id)sender {
	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/shuffle.dylib"]) {
        [HBRespringController respringAndReturnTo:[NSURL URLWithString:@"prefs:root=Tweaks&path=Cucu"]];
    } else {
        [HBRespringController respringAndReturnTo:[NSURL URLWithString:@"prefs:root=Cucu"]];   
    }	
}
@end
