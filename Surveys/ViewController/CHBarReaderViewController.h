//
//  CHBarReaderViewController.h
//  Surveys
//
//  Created by Pascal Pfiffner on 1/24/14.
//  Copyright (c) 2014 Pascal Pfiffner. All rights reserved.
//

@import UIKit;
#import "ZBarSDK.h"


/**
 *  Need to create our own reader view controller because the one in ZBar contains a bad leak.
 */
@interface CHBarReaderViewController : UIViewController <ZBarReaderViewDelegate>

@property (weak, nonatomic) id<ZBarReaderDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *readerViewContainer;
@property (strong, nonatomic) ZBarImageScanner *scanner;

- (IBAction)dismiss:(id)sender;

@end
