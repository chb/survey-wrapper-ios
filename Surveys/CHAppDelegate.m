//
//  CHAppDelegate.m
//  Surveys
//
//  Created by Pascal Pfiffner on 12/17/13.
//  Copyright (c) 2013 Boston Children's Hospital. All rights reserved.
//

#import "CHAppDelegate.h"
#import "CHSurveyViewController.h"


@implementation CHAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// configure scanner mode
	UINavigationController *root = (UINavigationController *)_window.rootViewController;
	CHSurveyViewController *main = (CHSurveyViewController *)root.topViewController;
	if ([main isKindOfClass:[CHSurveyViewController class]]) {
		main.limitToDomain = @"harvard.edu";
		//main.enableInAppScan = YES;
	}
	
    return YES;
}


@end
