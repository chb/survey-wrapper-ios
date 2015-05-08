//
//  CHWebViewController.h
//  Surveys
//
//  Created by Pascal Pfiffner on 12/17/13.
//  Copyright (c) 2013 Boston Children's Hospital. All rights reserved.
//

@import UIKit;


/**
 *  Simple browser view controller.
 */
@interface CHWebViewController : UIViewController <UIWebViewDelegate>

/// The URL to load initially.
@property (strong, nonatomic) NSURL *startURL;

/// JavaScript to be executed when any page has loaded.
@property (copy, nonatomic) NSString *jsOnEveryLoad;

/// The web view to present HTML content in.
@property (weak, nonatomic) IBOutlet UIWebView *webView;

/// To navigate back.
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;

- (IBAction)loadURL:(NSURL *)url;
- (IBAction)reload:(id)sender;
- (IBAction)reset:(id)sender;
- (void)clearWebView;

- (void)showLoadingIndicator:(id)sender;
- (void)showLoadingHint:(NSString *)hintText animated:(BOOL)animated;
- (void)hideLoadingIndicator:(id)sender;

@end
