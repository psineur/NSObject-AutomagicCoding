//
//  NSObject+AutoMagicCoding.h
//  AutoMagicCoding
//
//  31.08.11.
//  Copyright 2011 Stepan Generalov.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "objc/runtime.h"

#define kAMCDictionaryKeyClassName @"class"
extern NSString *const AMCEncodeException;
extern NSString *const AMCDecodeException;

#pragma mark Collection Protocols


/** Protocol that describes selectors, which object must respond to in order to
 * be detected as Ordered Collection. 
 */
@protocol AMCArrayProtocol <NSObject>

- (NSUInteger)count;
- (id) objectAtIndex:(NSUInteger) index; 
- (id) initWithArray:(NSArray *) array;

@end

/** Protocol that describes selectors, which object must respond to in order to
 * be detected as Mutable Ordered Collection.
 * It simply adds new methods to AMCArrayProtocol. 
 */
@protocol AMCArrayMutableProtocol <AMCArrayProtocol>

- (void) addObject: (id) anObject;

@end

/** Protocol that describes selectors, which object must respond to in order to
 * be detected as Hash(NSDictionary-Like Key-Value) Collection. 
 */
@protocol AMCHashProtocol <NSObject>

- (NSUInteger)count;
- (NSArray *) allKeys;
- (id) initWithDictionary: (NSDictionary *) aDict;

@end

/** Protocol that describes selectors, which object must respond to in order to
 * be detected as Mutable Hash(NSMutableDictionary-Like Key-Value) Collection. 
 * It simply adds new methods to AMCArrayProtocol. 
 */
@protocol AMCHashMutableProtocol <AMCHashProtocol>

- (void) setObject: (id) anObject forKey:(NSString *) aKey;

@end


// Object's fields types, that AMC recognizes.
typedef enum 
{
    kAMCFieldTypeScalar, //< Scalar value.
    
    kAMCFieldTypeCustomObject,             //< Your own object, that will be saved as it's dictionaryRepresentation
    kAMCFieldTypeCollectionHash,           //< NSDictionary-like objects.
    kAMCFieldTypeCollectionHashMutable,    //< NSMutableDictionary-like objects.
    kAMCFieldTypeCollectionArray,          //< NSArray-like objects.
    kAMCFieldTypeCollectionArrayMutable,   //< NSMutableArray-like objects.
    
    kAMCFieldTypeStructure, //< Struct
} AMCFieldType;


/** @category AutoMagicCoding AMC Public Interface.
 */
@interface NSObject (AutoMagicCoding)

/** Reimplement this method in your classes and return YES if you want to enable AutoMagicCoding.
 * Returns NO by default. 
 */
+ (BOOL) AMCEnabled;

#pragma mark Decode/Create/Init

/** Creates autoreleased object with given dictionary representation.
 * Returns nil, if aDict is nil or there's no class in your programm with name
 * provided in valueForKey: kAMCDictionaryKeyClassName.
 *
 * ATTENTION: Can throw exceptions - see README.md "Exceptions" part for details.
 * Define AMC_NO_THROW to disable throwing exceptions by this method and make
 * it return nil instead.
 *
 * @param aDict Dictionary that contains name of class NSString for
 * kAMCDictionaryKeyClassName key & all other values for keys in the saved object.
 */
+ (id) objectWithDictionaryRepresentation: (NSDictionary *) aDict;

/** Designated initializer for AMC. Use it as something like -initWithCoder:
 * Inits object with key values from given dictionary.
 * Doesn't test className to be equal with [self className].
 *
 * ATTENTION: Can throw exceptions - see README.md "Exceptions" part for details.
 * Define AMC_NO_THROW to disable throwing exceptions by this method and make
 * it return nil instead.
 *
 * @param aDict Dictionary that contains name of class NSString for
 * kAMCDictionaryKeyClassName key & all other values for keys in the saved object.
 */
- (id) initWithDictionaryRepresentation: (NSDictionary *) aDict;


#pragma mark Encode/Save

/** Encodes object and returns it's dictionary representation, that can be writed to PLIST.
 *
 * ATTENTION: Can throw exceptions - see README.md "Exceptions" part for details.
 * Define AMC_NO_THROW to disable throwing exceptions by this method and make
 * it return nil instead.
 */
- (NSDictionary *) dictionaryRepresentation;

#pragma mark Structure Support

/** Returns NSString representation of structure given in NSValue.
 * Reimplement this method to support your own custom structs.
 * When reimplementing - use structName to detect you custom struct & 
 * & return [super AMCEncodeStructWithValue: value withName: structName] for 
 * all other struct names.
 * (See README.md "Custom Struct Support" part for details).
 *
 * Default implementation encodes NS/CG Point, Size & Rect & returns nil if
 * structName is not equal to @"NSPoint", @"NSSize", @"NSRect", @"CGPoint", 
 * @"CGSize" or @"CGRect".
 *
 * @param structValue NSValue that holds structure to encode.
 *
 * @param structName Name of structure type to encode. 
 *
 * ATTENTION: Can throw exceptions - see README.md "Exceptions" part for details.
 * Even if AMC_NO_THROW is defined - this method can throw exceptions, that will 
 * be caught in -dictionaryRepresentation.
 *
 */
- (NSString *) AMCEncodeStructWithValue: (NSValue *) structValue withName: (NSString *) structName;

/** Decodes structure from given string & returns NSValue that is ready to be set 
 * with setValue:forKey:.
 *
 * Reimplement this method to support your own custom structs.
 * When reimplementing - use structName to detect you custom struct & 
 * & return [super AMCDecodeStructFromString: value withName: structName] for 
 * all other struct names.
 * (See README.md "Custom Struct Support" part for details).
 *
 * @param value NSString repreentation of structure.
 *
 * @param structName Name of structure type to decode.
 *
 * ATTENTION: Can throw exceptions - see README.md "Exceptions" part for details.
 * Even if AMC_NO_THROW is defined - this method can throw exceptions, that will 
 * be caught in -initWithDictionaryRepresentation.
 */
- (NSValue *) AMCDecodeStructFromString: (NSString *)value withName: (NSString *) structName;


#pragma mark Info for Serialization

/** Returns array of keys, that will used to create dictionaryWithValuesForKeys: .
 * By default - uses list of all available properties in the object 
 * provided by Objective-C Runtime methods.
 * You can expand it with your custom non-property ivars, by appending your  own
 * keys to keys that were returned by [super AMCKeysForDictionaryRepresentation].  
 */
- (NSArray *) AMCKeysForDictionaryRepresentation;

/** Returns field type for given key to save/load it in dictionaryRepresentation
 * as Scalar, CustomObject, Collection, etc...
 * Reimplement this method to add your custom ivar without properties. If you will not
 * reimplement this method for your custom ivars - they will treated as kAMCFieldTypeScalar .
 */
- (AMCFieldType) AMCFieldTypeForValueWithKey: (NSString *) aKey;

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

/** Declared by AMC when building for iOS, on Mac exists by default. */
- (NSString *) className;
+ (NSString *) className;

#endif

@end

#pragma mark Encode/Decode Helper Functions

/** Returns value, prepared for setValue:forKey: based on it's fieldType 
 * Recursively uses itself for objects in collections. 
 */
id AMCDecodeObject (id value, AMCFieldType fieldType, id collectionClass);

/** Returns object that can be added to dictionary for dictionaryRepresentation. */
id AMCEncodeObject (id value, AMCFieldType fieldType);

#pragma mark Property Info Helper Functions

/** Returns Class of given property if it is a Objective-C object.
* Otherwise returns nil.
*/
id AMCPropertyClass (objc_property_t property);

/** Returns name of struct, if given property type is struct.
 * Otherwise returns nil.
 */
NSString *AMCPropertyStructName(objc_property_t property);

#pragma mark Field Type Info Helper Functions

/** Tries to guess fieldType for given encoded object. Used in collections decoding to create objects in collections. */
AMCFieldType AMCFieldTypeForEncodedObject(id object);

/** Returns fieldType for given not yet encoded object. */
AMCFieldType AMCFieldTypeForObjectToEncode(id object);

/** Returns YES, if instances of given class respond to all required instance methods listed
 * in protocol p.
 * Otherwise returns NO;
 */
BOOL classInstancesRespondsToAllSelectorsInProtocol(id class, Protocol *p );


