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
//		main.limitToDomain = @"harvard.edu";
		main.enableInAppScan = YES;
	}
	
	// create a new NSURLCache
	int cacheSizeMemory = 16 * 1024 * 1024;			// 16 MB
	int cacheSizeDisk = 64 * 1024 * 1024;			// 64 MB
	NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
	[NSURLCache setSharedURLCache:sharedCache];
	
    return YES;
}


@end
