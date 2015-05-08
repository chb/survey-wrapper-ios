//
//  CHBarReaderViewController.m
//  Surveys
//
//  Created by Pascal Pfiffner on 1/24/14.
//  Copyright (c) 2014 Pascal Pfiffner. All rights reserved.
//

#import "CHBarReaderViewController.h"


@interface CHBarReaderViewController ()

@property (strong, nonatomic) ZBarReaderView *readerView;

@end


@implementation CHBarReaderViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	NSAssert(_readerViewContainer, @"Should now manually create a container view controller");
	
	// add reader view
	[_readerViewContainer addSubview:self.readerView];
	NSDictionary *views = @{@"reader": self.readerView};
	[_readerViewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[reader]|" options:0 metrics:nil views:views]];
	[_readerViewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[reader]|" options:0 metrics:nil views:views]];
	
	[self updateReaderViewOrientationWithDuration:0];
}

- (void)viewDidAppear:(BOOL)animated
{
	// calling "start" on an already started reader view is safe (no way to check if it's running anyway)
	[_readerView start];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self updateReaderViewForOrientation:toInterfaceOrientation withDuration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self updateReaderViewOrientationWithDuration:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[_readerView stop];
}



#pragma mark - Reader View & Scanner

- (ZBarReaderView *)readerView
{
	if (!_readerView) {
		ZBarReaderView *reader = [[ZBarReaderView alloc] initWithImageScanner:self.scanner];
		reader.translatesAutoresizingMaskIntoConstraints = NO;
		reader.zoom = 1.f;
		reader.readerDelegate = self;
		
		self.readerView = reader;
	}
	return _readerView;
}

- (void)updateReaderViewOrientationWithDuration:(NSTimeInterval)duration
{
	[self updateReaderViewForOrientation:self.interfaceOrientation withDuration:duration];
}

- (void)updateReaderViewForOrientation:(UIInterfaceOrientation)orientation withDuration:(NSTimeInterval)duration
{
	CGFloat angle = 0.f;
	if (UIInterfaceOrientationIsPortrait(orientation)) {
		angle = UIInterfaceOrientationPortraitUpsideDown == orientation ? M_PI : 0.f;
	}
	else {
		angle = (UIInterfaceOrientationLandscapeLeft == orientation) ? M_PI_2 : -M_PI_2;
	}
	
	[UIView animateWithDuration:duration
					 animations:^{
						 _readerView.transform = CGAffineTransformMakeRotation(angle);
					 }];
}


- (ZBarImageScanner *)scanner
{
	if (!_scanner) {
		ZBarImageScanner *scanner = [ZBarImageScanner new];
		[scanner setSymbology:0 config:ZBAR_CFG_X_DENSITY to:3];
		[scanner setSymbology:0 config:ZBAR_CFG_Y_DENSITY to:3];
		
		self.scanner = scanner;
	}
	return _scanner;
}



#pragma mark - Delegate

- (void)readerViewDidStart:(ZBarReaderView *)readerView
{
}

- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)syms fromImage:(UIImage *)image
{
	NSParameterAssert(syms);
	NSParameterAssert(image);
	
    [_delegate imagePickerController:(UIImagePickerController *)self didFinishPickingMediaWithInfo:@{UIImagePickerControllerOriginalImage: image, ZBarReaderControllerResults: syms}];
}

- (void)readerView:(ZBarReaderView *)readerView didStopWithError:(NSError *)error
{
}



#pragma mark - Actions

- (IBAction)dismiss:(id)sender
{
	[self.presentingViewController dismissViewControllerAnimated:(nil != sender) completion:NULL];
}


@end
