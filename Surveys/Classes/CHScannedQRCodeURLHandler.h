//
//  CHScannedQRCodeURLHandler.h
//  Surveys
//
//  Created by Pascal Pfiffner on 5/7/15.
//  Copyright (c) 2015 Pascal Pfiffner. All rights reserved.
//

#import "CHScannedCodeHandler.h"


/**
 *  A code handler that expects a "http" or "https" URL from a QR code, optionally in a given domain.
 */
@interface CHScannedQRCodeURLHandler : CHScannedCodeHandler

/// If URLs should be limited to a given domain.
@property (copy, nonatomic) NSString *limitToDomain;

@end
