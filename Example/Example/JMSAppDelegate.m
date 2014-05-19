//
//  JMSAppDelegate.m
//  Example
//
//  Created by José Manuel Sánchez on 5/19/14
//  Copyright (c) 2014 jms. All rights reserved.
//

#import "JMSAppDelegate.h"

#import <BMF/BMFDefaultConfiguration.h>

@implementation JMSAppDelegate

- (BOOL) application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	BMFDefaultConfiguration *config = [BMFDefaultConfiguration new];
	[[BMFBase sharedInstance] loadConfig:config];
	
	return YES;
}

@end