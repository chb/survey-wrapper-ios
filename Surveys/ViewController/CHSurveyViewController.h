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

/// The camera viewfinder.
@property (weak, nonatomic) IBOutlet UIView *scanView;

/// Dismisses the web view when pressed.
@property (weak, nonatomic) IBOutlet UIBarButtonItem *exitButton;

/// To bring up the scanner view without dismissing the web view.
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cameraButton;

/// Set to a domain if the start URL should be limited to a given domain.
@property (copy, nonatomic) NSString *limitToDomain;

/// Whether the camera button should be visible while web view is shown (can be used to scan all the things).
@property (nonatomic) BOOL enableInAppScan;


- (IBAction)showCameraScanner:(id)sender;

- (IBAction)askToReset:(id)sender;

@end
