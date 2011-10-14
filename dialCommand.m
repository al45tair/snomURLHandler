//
//  dialCommand.m
//  snomURLHandler
//
//  Created by Alastair Houghton on 15/09/2004.
//  Copyright 2004 Coriolis Systems Limited. All rights reserved.
//

#import "dialCommand.h"
#import "MainController.h"

@implementation dialCommand

- (id)performDefaultImplementation
{
  NSString *dialString = [self directParameter];
  MainController *mainController = [MainController mainController];
  
  // NSLog (@"dialString = %@", dialString);
  
  if ([dialString hasPrefix:@"sip:"] || [dialString rangeOfString:@"@"].length)
    [mainController dialNumber:dialString];
  else {
    if ([dialString hasPrefix:@"tel:"])
      dialString = [dialString substringFromIndex:4];
    [mainController dialNumber:[mainController mapNumber:dialString]];
  }
  
  return nil;
}

@end
