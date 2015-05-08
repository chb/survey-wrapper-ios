//
//  CHScannedCodeHandler.m
//  Surveys
//
//  Created by Pascal Pfiffner on 5/7/15.
//  Copyright (c) 2015 Boston Children's Hospital. All rights reserved.
//

#import "CHScannedCodeHandler.h"


@implementation CHScannedCodeHandler

- (void)prepareReader:(CHBarReaderViewController *)reader
{
	reader.instructionLabel.text = [[self class] scanPrompt];
}

- (void)handleCode:(NSString *)code
{
	[self failedToHandleCode:code because:@"Abstract class use"];
}

- (void)handledCodeSuccessfully:(NSString *)code
{
	if (_handleCallback) {
		_handleCallback(code, nil);
	}
}

- (void)failedToHandleCode:(NSString *)code because:(NSString *)error
{
	if (_handleCallback) {
		_handleCallback(code, [NSError errorWithDomain:NSCocoaErrorDomain code:999 userInfo:@{NSLocalizedDescriptionKey: error}]);
	}
}

+ (NSString *)scanPrompt
{
	return @"Center the code on screen";
}


@end
