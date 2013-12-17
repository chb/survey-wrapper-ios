//
//  CHWebViewController.h
//  Surveys
//
//  Created by Pascal Pfiffner on 12/17/13.
//  Copyright (c) 2013 Pascal Pfiffner. All rights reserved.
//

@import UIKit;


/**
 *  Simple browser view controller.
 */
@interface CHWebViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSURL *startURL;								//< The URL to load initially

@property (copy, nonatomic) NSString *jsOnEveryLoad;						//< JavaScript to be executed when any page has loaded

@property (weak, nonatomic) IBOutlet UIWebView *webView;					//< The web view to present HTML
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;			//< To navigate back

- (IBAction)loadURL:(NSURL *)url;
- (IBAction)reload:(id)sender;
- (IBAction)reset:(id)sender;
- (void)clearWebView;

- (void)showLoadingIndicator:(id)sender;
- (void)showLoadingHint:(NSString *)hintText animated:(BOOL)animated;
- (void)hideLoadingIndicator:(id)sender;

@end
