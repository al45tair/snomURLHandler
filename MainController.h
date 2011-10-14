//
//  MainController.h
//  snomURLHandler
//
//  Created by Alastair Houghton on 15/09/2004.
//  Copyright 2004 Coriolis Systems Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainController : NSObject
{
  NSStatusItem *statusItem;
  
  IBOutlet NSMenu   *theMenu;
  IBOutlet NSWindow *preferencesWindow;
  
  IBOutlet NSTextField *phoneURLField;
  IBOutlet NSTextField *phoneUsernameField;
  IBOutlet NSTextField *phonePasswordField;
  IBOutlet NSTextField *internationalPrefixField;
  IBOutlet NSTextField *outsideLinePrefixField;
  IBOutlet NSTextField *countryCodeField;
  IBOutlet NSTextField *nationalPrefixField;
}

+ (MainController *)mainController;

- (IBAction)openPrefs:(id)sender;

- (IBAction)setPrefs:(id)sender;

- (NSString *)mapNumber:(NSString *)number;
- (void)dialNumber:(NSString *)number;

@end
