//
//  NSManagedObject+StackHelpers.m
//  Slake
//
//  Created by Ben Williamson on 9/06/10.
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

#import "NSManagedObject+StackHelpers.h"


@implementation NSManagedObject (StackHelpers)

+ (NSManagedObjectModel *)managedObjectModel
{
	static NSManagedObjectModel* model = nil;
    if (model == nil) {
		model = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    }
	return model;
}

+ (NSPersistentStoreCoordinator*)makePersistentStoreCoordinator
{
	NSManagedObjectModel* model = [self managedObjectModel];
	NSPersistentStoreCoordinator* coordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model] autorelease];
	
	NSURL* storeURL = some url;
	NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
							 nil];
	NSError* error;
	if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
		NSLog(@"ERROR makePersistentStoreCoordinator addPersistentStore...: %@", [error localizedDescription]);
	}
	return coordinator;
}

+ (NSManagedObjectContext*)newManagedObjectContext
{
	NSPersistentStoreCoordinator* coordinator = [self makePersistentStoreCoordinator];
	NSAssert(coordinator != nil, @"Could not create persistent store coordinator");
	
	NSManagedObjectContext* context = [[[NSManagedObjectContext alloc] init] autorelease];
	[context setPersistentStoreCoordinator:coordinator];
	return context;
}

@end
