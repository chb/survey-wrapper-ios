/*
 SMActionView.h
 IndivoFramework
 
 Created by Pascal Pfiffner on 12/5/11.
 Copyright (c) 2011 Children's Hospital Boston
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#import "SMActionView.h"
@import QuartzCore;


@interface SMActionView ()

@property (weak, nonatomic) UIActivityIndicatorView *activityView;		//< The activity spinner
@property (weak, nonatomic) UILabel *mainLabel;							//< Main text label
@property (weak, nonatomic) UILabel *hintLabel;							//< Text below main text OR the spinner, a little more subtle

@end


@implementation SMActionView


- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.opaque = NO;
		self.layer.opacity = 0.f;
		self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.8f];
	}
	return self;
}



#pragma mark - Main Actions
/**
 *  Adds the view displaying a spinner to the given view
 *  @param aParent The view in which to display the spinner
 *  @param animated Whether the spinner should fade in
 */
- (void)showActivityIn:(UIView *)aParent animated:(BOOL)animated
{
	if (aParent != [self superview]) {
		self.frame = aParent.bounds;
		[aParent addSubview:self];
		[self layoutIfNeeded];
	}
	
	// fade in
	if (animated) {
		self.alpha = 0.f;
		[UIView animateWithDuration:0.25
						 animations:^{
							 self.alpha = 1.f;
							 [self showSpinnerAnimated:animated];
						 }];
	}
}

/**
 *  Adds the view with given main and hint text
 *  @param aParent The view in which to display the spinner
 *  @param mainText The text to display (can be nil)
 *  @param hintText The hint to display (can be nil); this is displayed smaller and faded when compared to mainText
 *  @param animated Whether the spinner should fade in
 */
- (void)showIn:(UIView *)aParent mainText:(NSString *)mainText hintText:(NSString *)hintText animated:(BOOL)animated;
{
	if (aParent != [self superview]) {
		self.frame = aParent.bounds;
		[aParent addSubview:self];
		[self layoutIfNeeded];
	}
	
	// fade in
	if (animated) {
		self.alpha = 0.f;
		[UIView animateWithDuration:0.25
						 animations:^{
							 self.alpha = 1.f;
							 
							 if ([mainText length] > 0) {
								 [self showMainText:mainText animated:animated];
							 }
							 if ([hintText length] > 0) {
								 [self showHintText:hintText animated:animated];
							 }
						 }];
	}
}

/**
 *  Hides the receiver by fading it out (if animated) and removing from superview.
 *  @param animated Whether the view should fade out
 *  @param completion The block to execute on completion
 */
- (void)hideAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
	[UIView animateWithDuration:(animated ? 0.25 : 0.0)
					 animations:^{
						 self.alpha = 0.f;
					 }
					 completion:^(BOOL finished) {
						 self.alpha = 1.f;
						 if (completion) {
							 completion(finished);
						 }
						 [self removeFromSuperview];
					 }];
}



#pragma mark - Changing Content
/**
 *  Display the spinner
 *  @param animated Whether to animated the action
 */
- (void)showSpinnerAnimated:(BOOL)animated
{
	if (_activityView && !_activityView.hidden) {
		return;
	}
	
	[self hideMainTextAnimated:animated];
	[self.activityView startAnimating];
	
	if (animated) {
		_activityView.alpha = 0.f;
		[UIView animateWithDuration:0.25
						 animations:^{
							 _activityView.alpha = 1.f;
						 }];
	}
}

/**
 *  Hides the spinner
 *  @param animated Whether to animated the action
 */
- (void)hideSpinnerAnimated:(BOOL)animated
{
	[_activityView stopAnimating];
	[UIView animateWithDuration:(animated ? 0.25 : 0.0)
					 animations:^{
						 _activityView.alpha = 0.f;
					 }
					 completion:^(BOOL finished) {
						 _activityView.hidden = YES;
						 _activityView.alpha = 1.f;
					 }];
}

/**
 *  Change the main text to the given string
 *  @param mainText The text to show (can be nil)
 *  @param animated Whether to animate showing the text
 */
- (void)showMainText:(NSString *)mainText animated:(BOOL)animated
{
	[self hideSpinnerAnimated:animated];
	
	self.mainLabel.text = mainText;
	_mainLabel.hidden = NO;
	
	if (animated) {
		_mainLabel.alpha = 0.f;
		[UIView animateWithDuration:0.25
						 animations:^{
							 _mainLabel.alpha = 1.f;
						 }];
	}
}

/**
 *  Hides the main text
 *  @param animated Whether or not to animate the hiding (results in animating the spinner sliding into place)
 */
- (void)hideMainTextAnimated:(BOOL)animated
{
	[UIView animateWithDuration:(animated ? 0.25 : 0.0)
					 animations:^{
						 _mainLabel.alpha = 0.f;
					 }
					 completion:^(BOOL finished) {
						 _mainLabel.hidden = YES;
						 _mainLabel.alpha = 1.f;
					 }];
}

/**
 *  Show the given hint (smaller and faded when compared to the main text)
 *  @param hintText The text to show as hint
 *  @param animated Whether to animate showing the text
 */
- (void)showHintText:(NSString *)hintText animated:(BOOL)animated
{
	self.hintLabel.text = hintText;
	_hintLabel.hidden = NO;
	
	if (animated) {
		_hintLabel.alpha = 0.f;
		[UIView animateWithDuration:0.25
						 animations:^{
							 _hintLabel.alpha = 1.f;
						 }];
	}
}

/**
 *  Hides the hint text label.
 *  @param animated Whether or not to animate the hiding (results in animating the spinner sliding into place)
 */
- (void)hideHintTextAnimated:(BOOL)animated
{
	[UIView animateWithDuration:(animated ? 0.25 : 0.0)
					 animations:^{
						 _hintLabel.alpha = 0.f;
					 }
					 completion:^(BOOL finished) {
						 _hintLabel.hidden = YES;
						 _hintLabel.alpha = 1.f;
					 }];
}



#pragma mark - KVC
- (UIActivityIndicatorView *)activityView
{
	if (!_activityView) {
		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		indicator.translatesAutoresizingMaskIntoConstraints = NO;
		self.activityView = indicator;
		
		[self addSubview:indicator];
		[self addConstraint:[NSLayoutConstraint constraintWithItem:indicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
		[self addConstraint:[NSLayoutConstraint constraintWithItem:indicator attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:0.9f constant:0.f]];
	}
	return _activityView;
}

- (UILabel *)mainLabel
{
	if (!_mainLabel) {
		UILabel *label = [UILabel new];
		label.translatesAutoresizingMaskIntoConstraints = NO;
		label.opaque = NO;
		label.backgroundColor = [UIColor clearColor];
		label.numberOfLines = 0;
		label.textColor = [UIColor whiteColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
		label.minimumScaleFactor = 0.8f;
		label.adjustsFontSizeToFitWidth = YES;
		self.mainLabel = label;
		
		[self addSubview:label];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[label]-|" options:0 metrics:nil views:@{@"label": label}]];
		[self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:0.9f constant:0.f]];
	}
	return _mainLabel;
}

- (UILabel *)hintLabel
{
	if (!_hintLabel) {
		UILabel *label = [UILabel new];
		label.translatesAutoresizingMaskIntoConstraints = NO;
		label.opaque = NO;
		label.backgroundColor = [UIColor clearColor];
		label.numberOfLines = 0;
		label.textColor = [UIColor lightGrayColor];
		label.textAlignment = NSTextAlignmentCenter;
		label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
		label.minimumScaleFactor = 0.8f;
		label.adjustsFontSizeToFitWidth = YES;
		self.hintLabel = label;
		
		[self addSubview:label];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[label]-|" options:0 metrics:nil views:@{@"label": label}]];
		[self addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.1f constant:0.f]];
	}
	return _hintLabel;
}


@end
