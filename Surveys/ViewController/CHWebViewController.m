//
//  CHWebViewController.m
//  Surveys
//
//  Created by Pascal Pfiffner on 12/17/13.
//  Copyright (c) 2013 Pascal Pfiffner. All rights reserved.
//

#import "CHWebViewController.h"
#import "SMActionView.h"


@interface CHWebViewController ()

@property (strong, nonatomic) NSMutableArray *history;				//< Holds NSURLs (currently only used to reload the last page when an error occurred)
@property (weak, nonatomic) UIBarButtonItem *loadingItem;			//< A bar item showing a spinner
@property (weak, nonatomic) SMActionView *loadingView;				//< A private view overlaid during loading activity

@end


@implementation CHWebViewController


#pragma mark - View Handling
- (void)viewDidLoad
{
	[super viewDidLoad];
	_webView.delegate = self;
}


/*
 *  If the view appears and has never loaded a URL, we load the startURL or show a hint if there is none.
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if ([_history count] < 1) {
		if (self.startURL) {
			[self loadURL:self.startURL];
		}
	}
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}



#pragma mark - Web View
/*
 *  Setting the startURL clears the entire history and loads that url, if the view has been loaded.
 */
- (void)setStartURL:(NSURL *)newURL
{
	if (newURL != _startURL) {
		_startURL = newURL;
		
		self.history = nil;
		
		if ([self isViewLoaded]) {
			if (_startURL) {
				[self loadURL:_startURL];
			}
			else {
				[self clearWebView];
			}
		}
	}
}


/**
 *  Loads a given URL
 *  @param url The URL to load
 */
- (IBAction)loadURL:(NSURL *)url
{
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:request];
}

/**
 *  Reloads current URL
 *  @param sender The button sending the action (can be nil)
 */
- (IBAction)reload:(id)sender
{
	if (_loadingView) {
		[_loadingView showSpinnerAnimated:YES];
		[_loadingView hideHintTextAnimated:YES];
	}
	[self loadURL:[_history lastObject]];
}

/**
 *  Reloads after a delay of half a second.
 *  This is needed to update the loading view so that the user sees that something happened, even if an error occurs immediately after reloading.
 *  @param sender The button sending the action (can be nil)
 */
- (void)reloadDelayed:(id)sender
{
	if (_loadingView) {
		[_loadingView showSpinnerAnimated:YES];
		[_loadingView hideHintTextAnimated:YES];
	}
	[self performSelector:@selector(reload:) withObject:sender afterDelay:0.5];
}

/**
 *  Clears the web view and history.
 */
- (void)reset:(id)sender
{
	self.startURL = nil;
}

- (void)clearWebView
{
	[self.webView loadHTMLString:@"" baseURL:nil];
	[_loadingView showHintText:@"Oh, cool, I can show hint text here, however much I'd like!" animated:YES];
}



#pragma mark - UIWebViewDelegate
/*
 *  We intercept requests here
 */
- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (aWebView != _webView) {
		return NO;
	}
	DLog(@"-->  %@", request.URL);
	
	// show loading indicator if not loading local files
	if (![[request.URL scheme] isEqualToString:@"file"]) {
		[self showLoadingIndicator:nil];
	}
	
	// handle history
	if (0 == [_history count] || UIWebViewNavigationTypeFormSubmitted == navigationType || UIWebViewNavigationTypeLinkClicked == navigationType) {
		[self.history addObject:request.URL];
	}
	
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	// execute javascript
	if (_jsOnEveryLoad) {
		[aWebView stringByEvaluatingJavaScriptFromString:_jsOnEveryLoad];
	}
	
	[self hideLoadingIndicator:nil];
	[self showHideBackButton];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
	// don't show cancel message
	if ([[error domain] isEqualToString:NSURLErrorDomain] && NSURLErrorCancelled == [error code]) {
		return;
	}
	
	// this is an interrupt error that we are provoking, don't display (figure out the constant for "WebKitErrorFrameLoadInterruptedByPolicyChange")
	if ([[error domain] isEqualToString:@"WebKitErrorDomain"] && 102 == [error code]) {
		return;
	}
	
	// show error
	if (_loadingView && error) {
		[_loadingView showIn:_webView mainText:[error localizedDescription] hintText:@"Tap to try again" animated:YES];
	}
	else {
		DLog(@"Failed loading URL: %@", [error localizedDescription]);
	}
}



#pragma mark - History
- (NSMutableArray *)history
{
	if (!_history) {
		self.history = [NSMutableArray array];
	}
	return _history;
}

/**
 *  Go back in time.
 *  @param sender The button sending the action (can be nil)
 */
- (void)goBack:(id)sender
{
	[_webView stopLoading];
	if ([_history count] > 1) {
		[_history removeLastObject];
		[self loadURL:[_history lastObject]];
	}
}

/**
 *  Show or hide the back button based on whether we have history URLs or not.
 */
- (void)showHideBackButton
{
	if ([_history count] > 1) {
		self.navigationItem.leftBarButtonItem = self.backButton;
	}
	else {
		self.navigationItem.leftBarButtonItem = nil;
		self.backButton = nil;
	}
}

- (UIBarButtonItem *)backButton
{
	if (!_backButton) {
		UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(goBack:)];
		self.backButton = bb;
	}
	return _backButton;
}



#pragma mark - Loading Indicator
/**
 *  Overlays the web view with a semi-transparent loading animatien.
 *  @param sender The button sending the action (can be nil)
 */
- (void)showLoadingIndicator:(id)sender
{
	if (_loadingView || _loadingItem) {
		return;
	}
	
	if (0 == [_history count]) {
		[self showLoadingOverlay:sender];
	}
	else {
		UIBarButtonItem *item = [self getLoadingItem];
		self.navigationItem.leftBarButtonItem = item;
		self.loadingItem = item;
	}
}

- (void)showLoadingOverlay:(id)sender
{
	SMActionView *loadingView = _loadingView;
	if (!loadingView) {
		loadingView = [[SMActionView alloc] initWithFrame:_webView.bounds];
		[loadingView addTarget:self action:@selector(reloadDelayed:) forControlEvents:UIControlEventTouchUpInside];
		self.loadingView = loadingView;
	}
	[loadingView showActivityIn:_webView animated:YES];
}

- (void)showLoadingHint:(NSString *)hintText animated:(BOOL)animated
{
	if (_webView == [_loadingView superview]) {
		[_loadingView showHintText:hintText animated:animated];
	}
	else {
		DLog(@"There doesn't seem to be a loading view, display that one first");
	}
}

/**
 *  Hides the loading overlay.
 *  @param sender The button sending the action (can be nil)
 */
- (void)hideLoadingIndicator:(id)sender
{
	[_loadingView hideAnimated:(nil != sender) completion:NULL];
	if (_loadingItem == self.navigationItem.leftBarButtonItem) {
		self.navigationItem.leftBarButtonItem = nil;
	}
}

- (UIBarButtonItem *)getLoadingItem
{
	if (_loadingItem) {
		return _loadingItem;
	}
	
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.hidesWhenStopped = YES;
	[spinner startAnimating];
	
	return [[UIBarButtonItem alloc] initWithCustomView:spinner];
}



#pragma mark - KVC
- (void)setTitle:(NSString *)newTitle
{
	self.navigationItem.title = newTitle;
	[super setTitle:newTitle];
}


@end
