//
//  CHScannedNDCCodeHandler.h
//  Surveys
//
//  Created by Pascal Pfiffner on 5/7/15.
//  Copyright (c) 2015 Pascal Pfiffner. All rights reserved.
//

#import "CHScannedCodeHandler.h"


/**
 *  A code handler that scans NDC codes and cuts off leading and check digits on success.
 */
@interface CHScannedNDCCodeHandler : CHScannedCodeHandler

@end
