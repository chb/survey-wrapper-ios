//
//  CHScannedNDCCodeHandler.m
//  Surveys
//
//  Created by Pascal Pfiffner on 5/7/15.
//  Copyright (c) 2015 Boston Children's Hospital. All rights reserved.
//

#import "CHScannedNDCCodeHandler.h"


@implementation CHScannedNDCCodeHandler

- (void)prepareReader:(CHBarReaderViewController *)reader
{
	[super prepareReader:reader];
	[reader.scanner setSymbology:0 config:ZBAR_CFG_ENABLE to:0];
	[reader.scanner setSymbology:ZBAR_UPCA config:ZBAR_CFG_ENABLE to:1];
	[reader.scanner setSymbology:ZBAR_EAN13 config:ZBAR_CFG_ENABLE to:1];
}

- (void)handleCode:(NSString *)code
{
	if ([code hasPrefix:@"3"] || [code hasPrefix:@"03"]) {
		code = [code hasPrefix:@"03"] ? [code substringFromIndex:2] : [code substringFromIndex:1];
		if ([code length] > 10) {
			[self handledCodeSuccessfully:[code substringToIndex:10]];
		}
		else {
			[self failedToHandleCode:code because:@"Seems to be too short to be an NDC code"];
		}
	}
	else {
		[self failedToHandleCode:code because:@"NDC barcodes start with \"3\" or \"03\""];
	}
}

+ (NSString *)scanPrompt
{
	return @"Center the barcode on screen";
}


@end
