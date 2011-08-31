//
//  NSObject+AutomagicCoding.h
//  AutomagicCoding
//
//  Created by Stepan Generalov on 31.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AutomagicCoding)

/** Reimplement this method in your classes and return YES if you want to enable AutomagicCoding.
 * Returns NO by default. */
+ (BOOL) isAutomagicCodingEnabled;

#pragma Decode/Create/Init

/** Creates autoreleased object with given dictionary representation.
 * Returns nil, if object there's no such class name or aDict is nil.
 * Doesn't catch any exceptions, that can be thrown by KVC methods.
 *
 * @param aDict Dictionary that contains @"class" NSString with name of class & all other
 * values for keys in the saved object.
 */
+ (id) objectWithDictionaryRepresentation: (NSDictionary *) aDict;

/** Inits object with key values from given dictionary.
 * Doesn't test className to be equal with self className.
 * Reimplement this method to add your custom init behavior while initing from saved state.
 */
- (id) initWithDictionaryRepresentation: (NSDictionary *) aDict;


#pragma mark Encode/Save

- (NSDictionary *) dictionaryRepresentation;


#pragma Info for Serialization

/** Returns array of keys, that will used get dictionaryWithValuesForKeys: for
 * automagic coding.
 * By default - uses list of all available properties in the object via runtime methods.
 * You can expand it with your custom non-property ivars, by appending your keys to returned in super. */
- (NSArray *) keysForValuesInDictionaryRepresentation;

/** Returns YES if object contains property for given key. 
 * Reimplement this method & return YES for your object ivars without readwrite properties.*/
- (BOOL) isObjectValueForKey: (NSString *) aKey;

@end
