//
//  AboutViewController.m
//  Slake
//
//  Created by Ben Williamson on 8/04/10.
//
//  Copyright (c) 2010 Bureau of Meteorology
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "AboutViewController.h"
#import "AboutWebViewController.h"

@interface AboutViewController () // private

@property (nonatomic) BOOL creditsVisible;

- (void)showActionSheet;

@end

static float kCreditsPositionHidden = 400.0f;
static float kCreditsPositionVisible = 245.0f;

struct AboutPage {
	NSString* title;
	NSString* url;
};

// These are in the same order as the segmentedButton segments:
static const struct AboutPage pages[] = {
	{ @"Features", @"about/features.html" },
	{ @"Copyright", @"http://www.bom.gov.au/water/waterstorage/iphone/copyright.php" },
	{ @"Disclaimer", @"about/disclamer.html" }
};

static const int kNumberOfPages = sizeof pages / sizeof pages[0];

@implementation AboutViewController

@synthesize credits;
@synthesize versionLabel;
@synthesize creditsVisible;
@synthesize segmentedButton;


- (void)dealloc
{
	[credits release];
	[versionLabel release];
	[segmentedButton release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleGetInfoString"];
	self.versionLabel.text = [NSString stringWithFormat:@"Water Storage %@", version];
	self.segmentedButton.tintColor = [UIColor colorWithRed:20.0/255.0 green:130.0/255.0 blue:192.0/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.credits = nil;
	self.versionLabel = nil;
	self.segmentedButton = nil;

	[super viewDidUnload];
}

- (void)showActionSheet
{
	UIActionSheet* sheet = [[[UIActionSheet alloc] initWithTitle:@"Water Storage at www.bom.gov.au"
														delegate:self
											   cancelButtonTitle:@"Cancel"
										  destructiveButtonTitle:nil
											   otherButtonTitles:@"Open in Safari", @"Copy URL", nil] autorelease];
	sheet.actionSheetStyle = UIActionSheetStyleDefault;
	UIView* rootView = [UIApplication sharedApplication].keyWindow;
	[sheet showInView:rootView];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString* urlString = @"http://www.bom.gov.au/water/waterstorage/iphone.shtml";
	NSURL* url = [NSURL URLWithString:urlString];
	switch (buttonIndex) {
		case 0:
			[[UIApplication sharedApplication] openURL:url];
			break;
		case 1:
			[UIPasteboard generalPasteboard].string = urlString;
			break;
	}
}

- (IBAction)showWebsite
{
	[self showActionSheet];
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	CGRect frame = self.credits.frame;
	frame.origin.y = kCreditsPositionHidden;
	self.credits.frame = frame;	
	self.creditsVisible = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self becomeFirstResponder];
	self.segmentedButton.selectedSegmentIndex = -1;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	if (motion == UIEventSubtypeMotionShake) {
		if (self.creditsVisible) {
			[self hideCredits];
		} else {
			[self showCredits];
		}
	}
}

- (IBAction)sendFeedback
{
	MFMailComposeViewController *mailViewController = [[[MFMailComposeViewController alloc] init] autorelease];
	mailViewController.mailComposeDelegate = self;
	[mailViewController setToRecipients:[NSArray arrayWithObject:@"waterinfo@bom.gov.au"]];
	[mailViewController setSubject:@"Feedback on Water Storage"];
	[self presentModalViewController:mailViewController animated:YES];
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showCredits
{
	[UIView beginAnimations:@"credits" context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	CGRect frame = self.credits.frame;
	frame.origin.y = kCreditsPositionVisible;
	self.credits.frame = frame;
	[UIView commitAnimations];
	self.creditsVisible = YES;
	if (UIAccessibilityIsVoiceOverRunning != nil && UIAccessibilityIsVoiceOverRunning()) {
		UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
		UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Credits displayed");
	}
}

- (IBAction)hideCredits
{
	[UIView beginAnimations:@"credits" context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	CGRect frame = self.credits.frame;
	frame.origin.y = kCreditsPositionHidden;
	self.credits.frame = frame;
	[UIView commitAnimations];
	self.creditsVisible = NO;
	if (UIAccessibilityIsVoiceOverRunning != nil && UIAccessibilityIsVoiceOverRunning()) {
		UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
		UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Credits hidden");
	}
}

- (IBAction)segmentedButtonValueChanged
{
	int page = self.segmentedButton.selectedSegmentIndex;
	if (page >= 0 && page < kNumberOfPages) {
		NSURL* bundleURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];

		AboutWebViewController* awvc = [[[AboutWebViewController alloc] init] autorelease];
		awvc.title = pages[page].title;
		awvc.pageURL = [NSURL URLWithString:pages[page].url relativeToURL:bundleURL];
		[self.navigationController pushViewController:awvc animated:YES];
	}
}

@end
