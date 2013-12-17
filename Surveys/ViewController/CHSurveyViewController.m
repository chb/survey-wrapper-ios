//
//  CHViewController.m
//  Surveys
//
//  Created by Pascal Pfiffner on 12/17/13.
//  Copyright (c) 2013 Pascal Pfiffner. All rights reserved.
//

#import "CHSurveyViewController.h"


@implementation CHSurveyViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// somehow this gets lost from storyboard?
	[_exitButton setTarget:self];
	[_exitButton setAction:@selector(askToReset:)];
}



#pragma mark - Barcode Scanning  and ZBarReaderDelegate
- (IBAction)showCameraScanner:(id)sender
{
#if 0
	self.startURL = [NSURL URLWithString:@"https://ihl-indivoui-staging.tch.harvard.edu/survey_app/launch?token=eyJhbGciOiJIUzUxMiJ9.eyJyZWNvcmRJZCI6ImY2ZDc3ZTg0LTNkZjMtNGFjMi1iOGEzLTEzMzNhOWQ1NGE0MyIsImV4cCI6MTM4NzI5NDY5Njg3OSwianRpIjoiOWI3OWE0OGUtYmJjZS00ZmNhLWFkYmMtNDkwNGRhNmI3ZDZjIiwiaWF0IjoxMzg3Mjk0MDk2ODc5fQ.huErbCvESvBdrD_sgmoEkrL9kW0rRby5GxCmKrXQdS1ta2CAaICuKJtVt-gyItzuRN_Ltk-aT6GPhNRfLWeYOQ"];
	return;
#endif
	
	ZBarReaderViewController *reader = [ZBarReaderViewController new];
	reader.readerDelegate = self;
	
	// we only need to look out for QR-codes
	[reader.scanner setSymbology:0 config:ZBAR_CFG_ENABLE to:0];
	[reader.scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:1];
	
	reader.readerView.zoom = 1.0;
//	reader.scanCrop = CGRectMake(0.f, 0.3f, 1.f, 0.4f);
	
	[self presentViewController:reader animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
	id<NSFastEnumeration> results = info[ZBarReaderControllerResults];
	for (ZBarSymbol *rslt in results) {
		
		// only requirement is that the link should start with "https"
		if ([rslt isKindOfClass:[ZBarSymbol class]]) {
			if ([rslt.data hasPrefix:@"https"]) {
				NSURL *url = [NSURL URLWithString:rslt.data];
				
				// hide picker and show URL
				[self imagePickerControllerDidCancel:picker];
				self.startURL = url;
				return;
			}
			else {
				DLog(@"INVALID SCAN: %@", rslt.data);
			}
		}
		else {
			DLog(@"No ZBarSymbol, got: %@", rslt);
		}
	}
	
	// still here? Nothing valid was scanned, then
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Scan Button View
- (void)showScanButtonAnimated:(BOOL)animated
{
	if (!_scanView.hidden || !animated) {
		_scanView.hidden = NO;
		return;
	}
	
	_scanView.alpha = 0.f;
	_scanView.transform = CGAffineTransformMakeScale(1.8f, 1.8f);
	_scanView.hidden = NO;
	[UIView animateWithDuration:0.25
					 animations:^{
						 _scanView.alpha = 1.f;
						 _scanView.transform = CGAffineTransformIdentity;
					 }];
}

- (void)hideScanButtonAnimated:(BOOL)animated
{
	if (_scanView.hidden || !animated) {
		_scanView.hidden = YES;
		return;
	}
	
	[UIView animateWithDuration:0.25
					 animations:^{
						 _scanView.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
						 _scanView.alpha = 0.f;
					 }
					 completion:^(BOOL finished) {
						 _scanView.hidden = YES;
						 _scanView.alpha = 1.f;
					 }];
}



#pragma mark - Web View
- (IBAction)loadURL:(NSURL *)url
{
	[self hideScanButtonAnimated:YES];
	_exitButton.enabled = YES;
	
	[super loadURL:url];
}

- (void)clearWebView
{
	[super clearWebView];
	
	[self showScanButtonAnimated:YES];
	_exitButton.enabled = NO;
}

- (IBAction)askToReset:(id)sender
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exit Survey?"
													message:@"Are you sure?"
												   delegate:self
										  cancelButtonTitle:@"Stay"
										  otherButtonTitles:@"Exit", nil];
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != alertView.cancelButtonIndex) {
		[self reset:self];
	}
}


@end
