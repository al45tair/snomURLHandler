//
//  URLHandlerCommand.m
//  snomURLHandler
//
//  Created by Alastair Houghton on 15/09/2004.
//  Copyright 2004 Coriolis Systems Limited. All rights reserved.
//

#import "URLHandlerCommand.h"
#import "MainController.h"

@implementation URLHandlerCommand

- (id)performDefaultImplementation
{
  NSString *urlString = [self directParameter];
  MainController *mainController = [MainController mainController];

  // NSLog (@"url = %@", urlString);
  
  if ([urlString hasPrefix:@"tel:"]) {
    NSString *dialString = [mainController mapNumber:[urlString substringFromIndex:4]];
    [mainController dialNumber:dialString];
  } else if ([urlString hasPrefix:@"sip:"]) {
    [mainController dialNumber:urlString];
  }
  
  return nil;
}

@end
