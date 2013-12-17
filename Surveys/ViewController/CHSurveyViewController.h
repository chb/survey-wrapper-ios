//
//  CHViewController.h
//  Surveys
//
//  Created by Pascal Pfiffner on 12/17/13.
//  Copyright (c) 2013 Pascal Pfiffner. All rights reserved.
//

#import "CHWebViewController.h"
#import "ZBarSDK.h"


@interface CHSurveyViewController : CHWebViewController <ZBarReaderDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *scanView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *exitButton;			//< To exit the survey

- (IBAction)showCameraScanner:(id)sender;
- (IBAction)askToReset:(id)sender;

@end
