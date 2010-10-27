//
//  XMLStreamParser.m
//  Slake
//
//  Created by Ben Williamson on 7/05/10.
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

#import "XMLStreamParser.h"
#import <libxml/tree.h>


// Function prototypes for SAX callbacks.
static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI);
static void	charactersFoundSAX(void * ctx, const xmlChar * ch, int len);
static void errorEncounteredSAX(void * ctx, const char * msg, ...);

// Forward reference. The structure is defined in full at the end of the file.
static xmlSAXHandler simpleSAXHandlerStruct;


@interface XMLStreamParser ()	// private

@property (nonatomic, retain) NSMutableDictionary* startCallbacks;
@property (nonatomic, retain) NSMutableDictionary* completeCallbacks;
@property (nonatomic, retain) NSDictionary* document;
@property (nonatomic, retain) NSArray* keyStack;
@property (nonatomic, retain) NSArray* dictStack;
@property (nonatomic, readonly) NSMutableArray* mutableKeyStack;
@property (nonatomic, readonly) NSMutableArray* mutableDictStack;
@property (nonatomic) BOOL isEmpty;
@property (nonatomic, retain) NSMutableData *characterBuffer;
@property (nonatomic) BOOL storingCharacters;

- (void)appendCharacters:(const char *)charactersFound length:(NSInteger)length;

@end


@implementation XMLStreamParser

@synthesize startCallbacks;
@synthesize completeCallbacks;
@synthesize document;
@synthesize keyStack;
@synthesize dictStack;
@synthesize isEmpty;
@synthesize characterBuffer;
@synthesize storingCharacters;


- (void)dealloc
{
	[startCallbacks release];
	[completeCallbacks release];
	[document release];
	[keyStack release];
	[dictStack release];
	[characterBuffer release];
	xmlFreeParserCtxt(xmlContext);
	[super dealloc];
}

- (id)init
{
	if ((self = [super init])) {
		xmlContext = xmlCreatePushParserCtxt(&simpleSAXHandlerStruct, self, NULL, 0, NULL);
		self.characterBuffer = [NSMutableData data];
		self.startCallbacks = [NSMutableDictionary dictionary];
		self.completeCallbacks = [NSMutableDictionary dictionary];
		self.keyStack = [NSMutableArray array];
		self.dictStack = [NSMutableArray array];
		self.isEmpty = YES;
	}
	return self;
}

- (void)setStartCallback:(SEL)selector forElement:(NSString*)elementName
{
	NSValue* value = [NSValue valueWithPointer:selector];
	[self.startCallbacks setObject:value forKey:elementName];
}

- (void)setCompleteCallback:(SEL)selector forElement:(NSString*)elementName
{
	NSValue* value = [NSValue valueWithPointer:selector];
	[self.completeCallbacks setObject:value forKey:elementName];
}

- (void)parseData:(NSData *)data
{
    // Process the downloaded chunk of data.
    xmlParseChunk(xmlContext, (const char *)[data bytes], [data length], 0);
}

- (void)parseEnd
{
	// Signal the xmlContext that parsing is complete by passing "1" as the last parameter.
    xmlParseChunk(xmlContext, NULL, 0, 1);
}

// Character data is appended to a buffer until the current element ends.
- (void)appendCharacters:(const char *)charactersFound length:(NSInteger)length
{
    [characterBuffer appendBytes:charactersFound length:length];
}

- (void)parseError:(NSString*)errorMsg
{
	NSLog(@"XMLStreamParser: %@", errorMsg);
}

- (NSMutableArray*)mutableKeyStack
{
	return keyStack;
}

- (NSMutableArray*)mutableDictStack
{
	return dictStack;
}

@end


#pragma mark SAX Parsing Callbacks

static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes)
{
	XMLStreamParser* parser = (XMLStreamParser*)ctx;
	NSString* tag = [NSString stringWithCString:(const char*)localname encoding:NSUTF8StringEncoding];

	// if (isEmpty) { dictStack.last[keyStack.last] = dictStack.push({}); } else { dictStack.push(dictStack.last[keyStack.last]) }	keyStack.push(localname); isEmpty = YES;
	NSString* key = [parser.keyStack lastObject];
	NSMutableDictionary* dict = [parser.dictStack lastObject];
	if (parser.isEmpty) {
		id newDict = [NSMutableDictionary dictionary];
		if (dict) {
			[dict setObject:newDict forKey:key];
		} else {
			parser.document = newDict;
		}
		[parser.mutableDictStack addObject:newDict];
	} else {
		id existingDict = [dict objectForKey:key];
		[parser.mutableDictStack addObject:existingDict];
	}
	[parser.mutableKeyStack addObject:tag];
	parser.isEmpty = YES;
	
    [parser.characterBuffer setLength:0];
    parser.storingCharacters = YES;
	
	NSValue* callback = [parser.startCallbacks objectForKey:tag];
	if (callback) {
		SEL selector = [callback pointerValue];
		[parser performSelector:selector withObject:tag];
	}
	
}

static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI)
{
	XMLStreamParser* parser = (XMLStreamParser*)ctx;

	// if (isEmpty) { dictStack.last[keyStack.last] = consumeString() }	keyStack.pop(); dictStack.pop(); isEmpty = NO;
	NSString* key = [parser.keyStack lastObject];	// Same as localname. libxml2 enforces tree correctness.
	NSMutableDictionary* dict = [parser.dictStack lastObject];
	if (parser.isEmpty) {
		id string = [[[NSString alloc] initWithData:parser.characterBuffer encoding:NSUTF8StringEncoding] autorelease];
		[dict setObject:string forKey:key];
	}

	NSValue* callback = [parser.completeCallbacks objectForKey:key];
	if (callback) {
		// Remove the element from the document, and pass it to the callback.
		id element = [[[dict objectForKey:key] retain] autorelease];
		[dict removeObjectForKey:key];
		SEL selector = [callback pointerValue];
		[parser performSelector:selector withObject:element];
	}

	[parser.mutableKeyStack removeLastObject];
	[parser.mutableDictStack removeLastObject];
	parser.isEmpty = NO;
	
    [parser.characterBuffer setLength:0];
    parser.storingCharacters = NO;
}

static void	charactersFoundSAX(void *ctx, const xmlChar *ch, int len)
{
	XMLStreamParser* parser = (XMLStreamParser*)ctx;
    if (parser.storingCharacters) {
		[parser appendCharacters:(const char *)ch length:len];
	}
}

static void errorEncounteredSAX(void *ctx, const char *msg, ...)
{
	XMLStreamParser* parser = (XMLStreamParser*)ctx;

	char buffer[1000];
	va_list args;
	va_start(args, msg);
	vsnprintf(buffer, sizeof(buffer), msg, args);
	va_end(args);

	NSString* errorMsg = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
	[parser parseError:errorMsg];
}

// The handler struct has positions for a large number of callback functions. If NULL is supplied at a given position,
// that callback functionality won't be used. Refer to libxml documentation at http://www.xmlsoft.org for more information
// about the SAX callbacks.
static xmlSAXHandler simpleSAXHandlerStruct = {
    NULL,                       /* internalSubset */
    NULL,                       /* isStandalone   */
    NULL,                       /* hasInternalSubset */
    NULL,                       /* hasExternalSubset */
    NULL,                       /* resolveEntity */
    NULL,                       /* getEntity */
    NULL,                       /* entityDecl */
    NULL,                       /* notationDecl */
    NULL,                       /* attributeDecl */
    NULL,                       /* elementDecl */
    NULL,                       /* unparsedEntityDecl */
    NULL,                       /* setDocumentLocator */
    NULL,                       /* startDocument */
    NULL,                       /* endDocument */
    NULL,                       /* startElement*/
    NULL,                       /* endElement */
    NULL,                       /* reference */
    charactersFoundSAX,         /* characters */
    NULL,                       /* ignorableWhitespace */
    NULL,                       /* processingInstruction */
    NULL,                       /* comment */
    NULL,                       /* warning */
    errorEncounteredSAX,        /* error */
    NULL,                       /* fatalError //: unused error() get all the errors */
    NULL,                       /* getParameterEntity */
    NULL,                       /* cdataBlock */
    NULL,                       /* externalSubset */
    XML_SAX2_MAGIC,             //
    NULL,
    startElementSAX,            /* startElementNs */
    endElementSAX,              /* endElementNs */
    NULL,                       /* serror */
};

