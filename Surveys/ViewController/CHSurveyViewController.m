//
//  CHViewController.m
//  Surveys
//
//  Created by Pascal Pfiffner on 12/17/13.
//  Copyright (c) 2013 Pascal Pfiffner. All rights reserved.
//

#import "CHSurveyViewController.h"
#import "CHBarReaderViewController.h"


@interface CHSurveyViewController () {
	BOOL askToExit;
	BOOL waitingToDismissReader;
}

@end


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
#if TARGET_IPHONE_SIMULATOR
	self.startURL = [NSURL URLWithString:@"http://192.168.88.22/?token=simulated"];
	return;
#endif
	
	CHBarReaderViewController *reader = [self.storyboard instantiateViewControllerWithIdentifier:@"BarReader"];
	reader.delegate = self;
	
	//ZBarReaderViewController *reader = [ZBarReaderViewController new];
	//reader.readerDelegate = self;
	
	// configure to look out for QR-codes
	[reader.scanner setSymbology:0 config:ZBAR_CFG_ENABLE to:0];
	[reader.scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE to:1];
	
	[self presentViewController:reader animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
	if (waitingToDismissReader) {
		return;
	}
	
	id<NSFastEnumeration> results = info[ZBarReaderControllerResults];
	for (ZBarSymbol *rslt in results) {
		
		// only requirement is that the link should start with "https"
		if ([rslt isKindOfClass:[ZBarSymbol class]]) {
			if ([rslt.data hasPrefix:@"https"]) {
				NSURL *url = [NSURL URLWithString:rslt.data];
				
				// hide picker and show URL
				waitingToDismissReader = YES;
				[self performSelector:@selector(imagePickerControllerDidCancel:) withObject:picker afterDelay:0.25];		// use a timeout to show the green square
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
	waitingToDismissReader = NO;
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

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	// when hitting "exit", reset the web view. When hitting "logout", don't ask for confirmation when tapping the "Exit" button
	if ([[webView.request.URL lastPathComponent] isEqualToString:@"exit"]) {
		askToExit = NO;
		[self reset:webView];
	}
	else if ([[webView.request.URL lastPathComponent] isEqualToString:@"logout"]) {
		askToExit = NO;
	}
	else {
		askToExit = YES;
	}
	
	[super webViewDidFinishLoad:webView];
}

- (IBAction)askToReset:(id)sender
{
	if (!askToExit) {
		[self reset:sender];
		return;
	}
	
	// ask to exit
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exit Survey?"
													message:@"You can scan the QR code again to return to this screen."
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
