//
//  MainController.m
//  snomURLHandler
//
//  Created by Alastair Houghton on 15/09/2004.
//  Copyright 2004 Coriolis Systems Limited. All rights reserved.
//

#import "MainController.h"
#import <Security/Security.h>

static MainController *mainController = nil;

@implementation MainController

+ (void)initialize
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *appDefaults = [NSDictionary
    dictionaryWithObjectsAndKeys:
    @"", @"phoneURL",
    @"", @"phoneUsername",
    @"", @"phonePassword",
    @"00", @"intlPrefix",
    @"", @"nationalPrefix",
    @"9", @"outsidePrefix",
    @"1", @"countryCode",
    nil];
  
  [defaults registerDefaults:appDefaults];
}

+ (MainController *)mainController
{
  return mainController;
}

- (void)applicationDidFinishLaunching:(NSNotification  *)notification
{
  NSStatusBar *bar = [NSStatusBar systemStatusBar];

  mainController = self;
  statusItem = [bar statusItemWithLength:NSSquareStatusItemLength];
  [statusItem retain];
  [statusItem setImage:[NSImage imageNamed:@"snomPhone.tiff"]];
  [statusItem setHighlightMode:YES];
  [statusItem setMenu:theMenu];
}

- (void)dealloc
{
  [statusItem release];
  [super dealloc];
}

- (void)setPassword:(NSString *)password
	     forURL:(NSString *)url
	   username:(NSString *)username
{
  SecProtocolType protocol = kSecProtocolTypeHTTP;
  SecKeychainItemRef itemRef = nil;
  char *passwordData;
  UInt32 passwordLen;
  OSStatus ret;
  
  if ([url hasPrefix:@"https:"])
    protocol = kSecProtocolTypeHTTPS;
  
  if ([url hasPrefix:@"http://"])
    url = [url substringFromIndex:7];
  else if ([url hasPrefix:@"https://"])
    url = [url substringFromIndex:8];
  
  ret = SecKeychainFindInternetPassword (NULL,
					 [url length],
					 [url UTF8String],
					 0,
					 NULL,
					 [username length],
					 [username UTF8String],
					 0,
					 "",
					 0,
					 protocol,
					 kSecAuthenticationTypeDefault,
					 NULL,
					 NULL,
					 &itemRef);

  if (ret == errSecItemNotFound) {
    ret = SecKeychainAddInternetPassword (NULL,
					  [url length],
					  [url UTF8String],
					  0,
					  NULL,
					  [username length],
					  [username UTF8String],
					  0,
					  "",
					  0,
					  protocol,
					  kSecAuthenticationTypeDefault,
					  [password length] + 1,
					  [password UTF8String],
					  NULL);
    return;
  }
  
  if (ret != noErr)
    return;

  ret = SecKeychainItemModifyAttributesAndData (itemRef,
						NULL,
						[password length],
						[password UTF8String]);
  
  CFRelease (itemRef);
}

- (NSString *)passwordForURL:(NSString *)url username:(NSString *)username
{
  SecProtocolType protocol = kSecProtocolTypeHTTP;
  char *passwordData;
  UInt32 passwordLen;
  OSStatus ret;
  
  if ([url hasPrefix:@"https:"])
    protocol = kSecProtocolTypeHTTPS;
  
  if ([url hasPrefix:@"http://"])
    url = [url substringFromIndex:7];
  else if ([url hasPrefix:@"https://"])
    url = [url substringFromIndex:8];
  
  ret = SecKeychainFindInternetPassword (NULL,
					 [url length],
					 [url UTF8String],
					 0,
					 NULL,
					 [username length],
					 [username UTF8String],
					 0,
					 NULL,
					 0,
					 protocol,
					 kSecAuthenticationTypeDefault,
					 &passwordLen,
					 (void **)&passwordData,
					 NULL);
  
  if (ret == noErr) {
    NSString *password;
    password = [[[NSString alloc] initWithBytes:passwordData 
					 length:passwordLen 
				       encoding:NSUTF8StringEncoding]
		autorelease];
    SecKeychainItemFreeContent (NULL, passwordData);
    
    return password;
  }
  
  return nil;
}

- (IBAction)openPrefs:(id)sender
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *phoneURL = [defaults stringForKey:@"phoneURL"];
  NSString *phoneUsername = [defaults stringForKey:@"phoneUsername"];
  NSString *phonePassword = nil;
  NSString *intlPrefix, *outsidePrefix, *countryCode, *nationalPrefix;
  
  if (!phoneURL)
    phoneURL = @"";
  
  if (!phoneUsername)
    phoneUsername = @"";
  
  [phoneURLField setStringValue:phoneURL];

  if ([phoneUsername length]) {
    phonePassword = [self passwordForURL:phoneURL username:phoneUsername];
  }

  if (!phonePassword)
    phonePassword = @"";
  
  [phoneUsernameField setStringValue:phoneUsername];
  [phonePasswordField setStringValue:phonePassword];
  
  intlPrefix = [defaults stringForKey:@"intlPrefix"];
  if (!intlPrefix)
    intlPrefix = @"";
  outsidePrefix = [defaults stringForKey:@"outsidePrefix"];
  if (!outsidePrefix)
    outsidePrefix = @"";
  countryCode = [defaults stringForKey:@"countryCode"];
  if (!countryCode)
    countryCode = @"";
  nationalPrefix = [defaults stringForKey:@"nationalPrefix"];
  if (!nationalPrefix)
    nationalPrefix = @"";
  
  [internationalPrefixField setStringValue:intlPrefix];
  [outsideLinePrefixField setStringValue:outsidePrefix];
  [countryCodeField setStringValue:countryCode];
  [nationalPrefixField setStringValue:nationalPrefix];
  
  [preferencesWindow center];
  [preferencesWindow makeKeyAndOrderFront:self];
}

- (IBAction)setPrefs:(id)sender
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  [preferencesWindow orderOut:self];
  
  [defaults setObject:[phoneURLField stringValue] forKey:@"phoneURL"];
  [defaults setObject:[phoneUsernameField stringValue] forKey:@"phoneUsername"];
  [self setPassword:[phonePasswordField stringValue]
	     forURL:[phoneURLField stringValue]
	   username:[phoneUsernameField stringValue]];
  [defaults setObject:[internationalPrefixField stringValue]
	       forKey:@"intlPrefix"];
  [defaults setObject:[outsideLinePrefixField stringValue]
	       forKey:@"outsidePrefix"];
  [defaults setObject:[countryCodeField stringValue]
	       forKey:@"countryCode"];
  [defaults setObject:[nationalPrefixField stringValue]
	       forKey:@"nationalPrefix"];
  
  [defaults synchronize];
}

- (NSString *)mapNumber:(NSString *)number
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *intlPrefix = [defaults stringForKey:@"intlPrefix"];
  NSString *outsidePrefix = [defaults stringForKey:@"outsidePrefix"];
  NSString *countryCode = [defaults stringForKey:@"countryCode"];
  NSString *nationalPrefix = [defaults stringForKey:@"nationalPrefix"];
  NSMutableString *newNumber = [NSMutableString string];
  NSScanner *scanner = [NSScanner scannerWithString:number];
  NSCharacterSet *skipset = [NSCharacterSet characterSetWithCharactersInString:@"()-., \t"];
  
  [scanner setCharactersToBeSkipped:skipset];
  if ([scanner scanString:@"+" intoString:NULL]) {
    [newNumber appendString:outsidePrefix];
    if ([scanner scanString:countryCode intoString:NULL]) {
      [newNumber appendString:nationalPrefix];
    } else {
      [newNumber appendString:intlPrefix];
    }
  }
  
  while (![scanner isAtEnd]) {
    NSString *numberString;

    if ([scanner scanUpToCharactersFromSet:skipset
				intoString:&numberString]) {
      [newNumber appendString:numberString];
    }
    [scanner scanCharactersFromSet:skipset intoString:NULL];
  }
  
  return newNumber;
}

- (void)dialNumber:(NSString *)number
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *phoneURL = [defaults stringForKey:@"phoneURL"];
  NSURL *url = [NSURL URLWithString:phoneURL];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  NSURLConnection *connection;
  
  // NSLog (@"Dialling \"%@\"", number);
  
  [request setHTTPMethod:@"POST"];
  [request setHTTPBody:[[@"number=" stringByAppendingString:number]
			dataUsingEncoding:NSUTF8StringEncoding]];
  [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
  
  connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
  [connection release];

  NSRunAlertPanel (@"Unable to contact snom phone",
		   [error localizedDescription],
		   @"OK", nil, nil);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  [connection release];
}

- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
  NSURLCredential *credentials = nil;

  if ([challenge previousFailureCount] == 0) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phoneURL = [defaults stringForKey:@"phoneURL"];
    NSString *phoneUsername = [defaults stringForKey:@"phoneUsername"];
    NSString *phonePassword 
      = [self passwordForURL:phoneURL username:phoneUsername];

    if (phonePassword) {
      credentials = [NSURLCredential credentialWithUser:phoneUsername
					       password:phonePassword
					    persistence:NSURLCredentialPersistenceNone];
    }
  }
  
  if (!credentials) {
    [[challenge sender] cancelAuthenticationChallenge:challenge];
    
    [self openPrefs:self];
    NSRunAlertPanel (@"Incorrect phone username/password",
		     @"The username or password you specified for your snom "
		     @"phone are incorrect; please enter a valid username "
		     @"and password combination.",
		     @"OK",
		     nil, nil);
  } else {
    [[challenge sender] useCredential:credentials
	   forAuthenticationChallenge:challenge];
  }
}

@end
