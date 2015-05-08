//
//  CHViewController.m
//  Surveys
//
//  Created by Pascal Pfiffner on 12/17/13.
//  Copyright (c) 2013 Boston Children's Hospital. All rights reserved.
//

#import "CHSurveyViewController.h"
#import "CHBarReaderViewController.h"
#import "CHScannedQRCodeURLHandler.h"
#import "CHScannedNDCCodeHandler.h"


@interface CHSurveyViewController () {
	BOOL askToExit;
}

@property (nonatomic) BOOL waitingToDismissReader;

@property (strong, nonatomic) CHScannedQRCodeURLHandler *startHandler;
@property (strong, nonatomic) CHScannedCodeHandler *inAppHandler;
@property (strong, nonatomic) CHScannedCodeHandler *currentHandler;

@end


@implementation CHSurveyViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// somehow this gets lost from storyboard?
	[_exitButton setTarget:self];
	[_exitButton setAction:@selector(askToReset:)];
	
	__weak typeof(self) this = self;
	
	// setup the main handler, looking for URLs and loading the first one it finds
	self.startHandler = [CHScannedQRCodeURLHandler new];
	_startHandler.limitToDomain = _limitToDomain;
	_startHandler.handleCallback = ^(NSString *code, NSError *error) {
		if (error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid QR Code" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
		}
		else {
			this.waitingToDismissReader = YES;
			this.startURL = [NSURL URLWithString:code];
			[this hideCameraScanner:nil];
		}
	};
	
	[self handleCameraButtonVisibility];
}

- (void)setInAppScan:(BOOL)flag
{
	if (_enableInAppScan != flag) {
		_enableInAppScan = flag;
		[self handleCameraButtonVisibility];
	}
}

- (void)handleCameraButtonVisibility
{
	if (![self isViewLoaded]) {
		return;
	}
	
	// if enabled, set up an NDC handler
	if (_enableInAppScan) {
		__weak typeof(self) this = self;
		self.inAppHandler = [CHScannedNDCCodeHandler new];
		_inAppHandler.handleCallback = ^(NSString *code, NSError *error) {
			if (error) {
				DLog(@"INVALID CODE \"%@\": %@", code, error.localizedDescription);
			}
			else {
#warning You should define here which action a successful code scan executes
				[this hideCameraScanner:nil];
			}
		};
		self.navigationItem.rightBarButtonItems = @[_exitButton, _cameraButton];
	}
	else {
		self.inAppHandler = nil;
		self.navigationItem.rightBarButtonItem = _exitButton;
	}
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
	
	// configure the handler, depending on which button was pressed
	self.currentHandler = (_cameraButton == sender) ? _inAppHandler : _startHandler;
	[_currentHandler prepareReader:reader];
	[self presentViewController:reader animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
	if (_waitingToDismissReader) {
		return;
	}
	
	// handle the first code that we find
	id<NSFastEnumeration> results = info[ZBarReaderControllerResults];
	for (ZBarSymbol *rslt in results) {
		if ([rslt isKindOfClass:[ZBarSymbol class]]) {
			[_currentHandler handleCode:rslt.data];
			return;
		}
		else {
			DLog(@"No ZBarSymbol, got: %@", rslt);
		}
	}
	
	// still here? Nothing valid was scanned, then
}

- (void)hideCameraScanner:(id)sender
{
	[self performSelector:@selector(imagePickerControllerDidCancel:) withObject:nil afterDelay:0.6];		// use a timeout to not cut off showing the green square
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
	self.waitingToDismissReader = NO;
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
	_cameraButton.enabled = YES;
	
	[super loadURL:url];
}

- (void)clearWebView
{
	[super clearWebView];
	[self showScanButtonAnimated:YES];
	_exitButton.enabled = NO;
	_cameraButton.enabled = NO;
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
