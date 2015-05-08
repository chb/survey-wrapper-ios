//
//  CHScannedCodeHandler.h
//  Surveys
//
//  Created by Pascal Pfiffner on 5/7/15.
//  Copyright (c) 2015 Pascal Pfiffner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHBarReaderViewController.h"

@class ZBarSymbol;


/**
 *  Can configure the ZBar scanner and postprocess scanned codes.
 */
@interface CHScannedCodeHandler : NSObject

/// Called during `handleCode:`.
@property (nonatomic, copy) void (^handleCallback)(NSString *code, NSError *error);

- (void)prepareReader:(CHBarReaderViewController *)reader;

/**
 *  Handle the scanned code and execute our `handleCallback` block, supplying an error if the code was malformed.
 */
- (void)handleCode:(NSString *)code;


#pragma mark Subclasses

- (void)handledCodeSuccessfully:(NSString *)code;
- (void)failedToHandleCode:(NSString *)code because:(NSString *)error;

@end
