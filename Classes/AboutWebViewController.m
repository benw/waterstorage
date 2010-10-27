//
//  AboutWebViewController.h
//  Slake
//
//  Created by Quentin Leseney on 10/08/10.
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

#import "AboutWebViewController.h"

@implementation AboutWebViewController

@synthesize pageURL = _pageURL;
@synthesize actionURL = _actionURL;


- (void)dealloc
{
	[_pageURL release];
	[_actionURL release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	UIWebView* webView = (UIWebView*)self.view;
	NSURLRequest* request = [NSURLRequest requestWithURL:self.pageURL];
	webView.scalesPageToFit = YES;
	webView.delegate = self;
	[webView loadRequest:request];
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)showActionSheetForURL:(NSURL*)url
{
	self.actionURL = url;
	NSString* scheme = [url scheme];
	NSString* openButtonTitle;
	NSString* copyButtonTitle;
	if ([scheme isEqualToString:@"mailto"]) {
		openButtonTitle = @"Open in Mail";
		copyButtonTitle = @"Copy Email Address";
	} else {
		openButtonTitle = @"Open in Safari";
		copyButtonTitle = @"Copy URL";
	}
	UIActionSheet* sheet = [[[UIActionSheet alloc] initWithTitle:[url absoluteString]
														delegate:self
											   cancelButtonTitle:@"Cancel"
										  destructiveButtonTitle:nil
											   otherButtonTitles:openButtonTitle, copyButtonTitle, nil] autorelease];
	sheet.actionSheetStyle = UIActionSheetStyleDefault;
	UIView* rootView = [UIApplication sharedApplication].keyWindow;
	[sheet showInView:rootView];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case 0:
			[[UIApplication sharedApplication] openURL:self.actionURL];
			break;
		case 1:
			[UIPasteboard generalPasteboard].string = [self.actionURL absoluteString];
			break;
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		NSURL* url = [request URL];
		NSString* scheme = [url scheme];
		if ([scheme isEqualToString:@"mailto"] && [MFMailComposeViewController canSendMail]) {
			// Trim off "mailto:"
			NSString* emailAddress = [[url absoluteString] substringFromIndex:[scheme length] + 1];
			MFMailComposeViewController *mailViewController = [[[MFMailComposeViewController alloc] init] autorelease];
			mailViewController.mailComposeDelegate = self;
			[mailViewController setToRecipients:[NSArray arrayWithObject:emailAddress]];
			[self presentModalViewController:mailViewController animated:YES];
		} else {
			[self showActionSheetForURL:[request URL]];
		}
		return NO;
	}
	return YES;
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
