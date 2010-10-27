//
//  DataLoader.m
//  Slake
//
//  Created by Ben Williamson on 7/06/10.
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

#import "DataLoader.h"
#import "DataParser.h"
#import "DataManager.h"
#import "NSManagedObjectContext+Helpers.h"
#import <sys/utsname.h>

@interface DataLoader ()	// private

@property (nonatomic, retain) NSURLConnection* connection;
@property (nonatomic, retain) DataParser* parser;
@property (nonatomic, retain) NSManagedObjectContext* context;

@end


@implementation DataLoader

@synthesize delegate;
@synthesize delegateThread;
@synthesize connection;
@synthesize parser;
@synthesize context;


- (void)dealloc
{
	[connection release];
	[parser release];
	[context release];
	[super dealloc];
}

- (id)init
{
	if ((self = [super init])) {
		self.delegateThread = [NSThread currentThread];
	}
	return self;
}

- (NSString*)userAgent
{
	static NSString* userAgent = nil;
	if (userAgent == nil)
	{
		NSBundle* mainBundle = [NSBundle mainBundle];
		NSString* bundleAppName = [[mainBundle infoDictionary] objectForKey:@"CFBundleName"];
		NSString* bundleAppVersion = [[mainBundle infoDictionary] objectForKey:@"CFBundleVersion"];
		NSString* versionFilePath = [mainBundle pathForResource:@"version" ofType:@"txt"];
		NSString* versionFileBuildVersion = [[NSString stringWithContentsOfFile:versionFilePath encoding:NSUTF8StringEncoding error:nil] 
								  stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
		//#import <sys/utsname.h>
		struct utsname systemInfo;
		uname (&systemInfo);
		NSString* sysInfoMachine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]; // iPhone2,1 / Machine hardware platform.
		/*NSString* sysInfoSysname = [NSString stringWithCString:systemInfo.sysname encoding:NSUTF8StringEncoding]; // Darwin / Name of the operating system implementation. 
		NSString* sysInfoNodename = [NSString stringWithCString:systemInfo.nodename encoding:NSUTF8StringEncoding]; // Qs-iPhone / Network name of this machine.
		NSString* sysInfoRelease = [NSString stringWithCString:systemInfo.release encoding:NSUTF8StringEncoding]; // 10.3.1 / Release level of the operating system.
		NSString* sysInfoVersion = [NSString stringWithCString:systemInfo.version encoding:NSUTF8StringEncoding]; // (see below) / Version level of the operating system. 
		// Darwin Kernel Version 10.3.1: Wed May 26 22:20:21 PDT 2010; root:xnu-1504.50.73~2/RELEASE_ARM_S5L8920X
		
		NSLog(@"sysInfoMachine= %@\nsysInfoSysname= %@\nsysInfoNodename= %@\nsysInfoRelease= %@\nsysInfoVersion= %@",
			  sysInfoMachine, sysInfoSysname, sysInfoNodename, sysInfoRelease, sysInfoVersion);*/
		
		UIDevice* device = [UIDevice currentDevice];
		NSString* deviceSystemName = [device systemName]; // iPhone OS
		NSString* deviceSystemVersion = [device systemVersion]; // 4.0 / OS number
		NSString* deviceModel = [device model]; // [iPhone, iPad...]
		userAgent = [[NSString stringWithFormat:@"%@/%@ (%@/%@; %@; %@; %@)", bundleAppName, bundleAppVersion, deviceSystemName, deviceSystemVersion, deviceModel, sysInfoMachine, versionFileBuildVersion] retain];
		// example: WaterStorage/7.0 (iPhone OS/4.0; iPhone; iPhone2,1; v0.7-8-g2cf26bf-dirty)
	}
	return userAgent;
}

- (void)startLoading
{
	// To quote from "Core Data" by Marcus Zarra:
	//
	// The biggest issue with dealing with Core Data in multiple threads is keeping
	// the NSManagedObjectContext in sync. When a change is made to an NSManagedObject
	// on a thread that is different from the one that created the NSManagedObjectContext,
	// the context is not aware of it and can have potentially stale data. This is the part
	// of Core Data that is not thread safe. The NSPersistentStore, NSPersistentStoreCoordinator,
	// and NSManagedObjectModel can all be used on multiple threads due to the NSManagedObjectContext
	// locking them properly, the NSManagedObjectContext itself is not thread safe.

	// That's why we create the context here in the thread, not in init:
			
	self.context = [[[NSManagedObjectContext alloc] init] autorelease];
	[self.context setPersistentStoreCoordinator:[[DataManager manager] persistentStoreCoordinator]];
	
	NSURL* baseURL = [NSURL URLWithString:[DataManager baseUrl]];
	NSURL* url = [NSURL URLWithString:[self resourcePath] relativeToURL:baseURL];
	NSLog(@"URL: %@", [url absoluteString]);
	
	NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url
															  cachePolicy:NSURLRequestUseProtocolCachePolicy
														  timeoutInterval:60.0];
	[urlRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	//default user-agent is automatically set to something like "WaterStorage/7.0 CFNetwork/485.2 Darwin/10.3.1"
	[urlRequest setValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];
	
	self.connection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
	NSAssert(self.connection != nil, @"Failed to create connection");
}

- (void)main
{
	NSAutoreleasePool* topPool = [[NSAutoreleasePool alloc] init];
	
	[self startLoading];

	while (!done) {
		NSAutoreleasePool* loopPool = [[NSAutoreleasePool alloc] init];

		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];

		[loopPool drain];
	}
	[topPool drain];
}

- (void)endCurrentRequest
{
	[self.context saveAndLogErrors];
	done = YES;
	[(NSObject*)self.delegate performSelector:@selector(dataLoaderDidFinish:) onThread:self.delegateThread withObject:self waitUntilDone:NO];
}

- (void)actuallyTerminateLoading
{
	[self.connection cancel];
	done = YES;
}

- (void)terminateLoading
{
	@try {
		[self performSelector:@selector(actuallyTerminateLoading) onThread:self withObject:nil waitUntilDone:YES];
	}
	@catch (NSException* e) {
		// Presumably the loader thread exited of its own accord before performSelector: could be dispatched. Fine.
	}
}

#pragma mark NSURLConnection Delegate informal protocol methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
		NSInteger statusCode = [httpResponse statusCode];
		if (statusCode != 200) {
			NSLog(@"'%d %@'", statusCode,
				  [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
		}
		if ([self shouldContinueWithStatusCode:statusCode]) {
			self.parser = [self makeParser];
		} else {
			[self.connection cancel];
			[self endCurrentRequest];
		}
	} else {
		self.parser = [self makeParser];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.parser parseData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// FIXME Report the error
	NSLog(@"Failed to load: %@", [error userInfo]);
	[self endCurrentRequest];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[parser parseEnd];
	[self didFinishLoading];
	[self endCurrentRequest];
}

- (NSString*)resourcePath
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (BOOL)shouldContinueWithStatusCode:(NSInteger)statusCode
{
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (DataParser*)makeParser
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)didFinishLoading
{
	[self doesNotRecognizeSelector:_cmd];
}

@end
