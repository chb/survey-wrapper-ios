//
//  CHScannedQRCodeURLHandler.m
//  Surveys
//
//  Created by Pascal Pfiffner on 5/7/15.
//  Copyright (c) 2015 Pascal Pfiffner. All rights reserved.
//

#import "CHScannedQRCodeURLHandler.h"


@implementation CHScannedQRCodeURLHandler

- (void)prepareReader:(CHBarReaderViewController *)reader
{
	[reader.scanner setSymbology:0 config:ZBAR_CFG_ENABLE to:0];
	[reader.scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:1];
}

- (void)handleCode:(NSString *)code
{
	if ([code hasPrefix:@"http"]) {
		if (_limitToDomain) {
			NSURLComponents *url = [NSURLComponents componentsWithString:code];
			if ([url.host hasSuffix:_limitToDomain]) {
				[self handledCodeSuccessfully:code];
			}
			else {
				NSString *reason = [NSString stringWithFormat:@"Must be in domain \"%@\", but is in \"%@\"", _limitToDomain, url.host];
				[self failedToHandleCode:code because:reason];
			}
		}
		else {
			[self handledCodeSuccessfully:code];
		}
	}
	else {
		[self failedToHandleCode:code because:@"Must start with \"http\""];
	}
}


@end
