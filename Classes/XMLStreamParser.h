//
//  XMLStreamParser.h
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

#import <libxml/tree.h>

/**
 * XMLStreamParser is a wrapper around libxml2 operating as a stream push parser.
 * It is intended to be subclassed to build parsers for specific schemas.
 *
 * It makes the job of building state-machine-based parsing easier, by maintaining
 * a temporary pseudo-document tree object. This "document" is a dictionary
 * representing the document root, in which the keys are element names and the values
 * are either strings, or dictionaries of strings, etc. Because a dictionary is unordered
 * and can only hold a single value for any key name, some structure of the true XML
 * document is lost. This is made up for by providing a callback mechanism, in which
 * the client may register callbacks for the start or completion of any element names.
 * The document should be considered a temporary store for convenience, rather than
 * a complete representation of the input. Callbacks may interrogate the document
 * and the key / dictionay stack to retrieve context of the current element.
 * Elements passed to complete callbacks are removed from the document, with the
 * expectation that the callback implementation will deal with them sufficiently.
 *
 * The short version: Register callbacks for any repeated elements.
 */
@interface XMLStreamParser : NSObject
{
@private
	xmlParserCtxtPtr xmlContext;
	NSMutableDictionary* startCallbacks;
	NSMutableDictionary* completeCallbacks;

	NSMutableDictionary* document;
	NSMutableArray* keyStack;
	NSMutableArray* dictStack;
	BOOL isEmpty;
	
	BOOL storingCharacters;
	NSMutableData *characterBuffer;
}

@property (nonatomic, retain, readonly) NSDictionary* document;
@property (nonatomic, retain, readonly) NSArray* keyStack;
@property (nonatomic, retain, readonly) NSArray* dictStack;

/**
 * Add a callback, to be called when an element matching the given name is started.
 * The callback is invoked on self with one argument: the element name, e.g.:
 *
 * - (void) startPerson:(NSString*)elementName;
 */
- (void)setStartCallback:(SEL)selector forElement:(NSString*)elementName;

/**
 * Add a callback, to be called when an element matching the given name is completed.
 * Elements matching this callback will be removed from the document.
 * The callback is invoked on self with one argument: the element, e.g.:
 *
 * - (void) gotPerson:(id)element;
 *
 * The argument may be an NSString or an NSDictionary containing strings and/or dictionaries.
 *
 * When the callback is invoked, the matched element has been removed from the document,
 * and the dictionary on the top of dictStack is the element containing the matched element.
 */
- (void)setCompleteCallback:(SEL)selector forElement:(NSString*)elementName;

// Push chunks of data in here.
- (void)parseData:(NSData *)data;

// Call this when you run out of data.
- (void)parseEnd;

// Default implementation logs the error.
- (void)parseError:(NSString*)errorMsg;


@end
