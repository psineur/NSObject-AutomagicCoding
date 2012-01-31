AMC
==================
__AMC is AutoMagic Coding__ - very easy to use NSCoding replacement for Mac & iOS Projects.
AMC gives you ability to create NSDictionary representation of any supported object, save it in PLIST
(or any other PLIST-compatible file format, i.e. JSON) and load again without writing a lot of code.

AMC uses Objective-C Runtime to determine object's properties automatically & Key-Value-Coding to
get & set them.

Repo Contents
-------------------------------------

* __AutoMagicCoding/__ - contains all AMC sources, that you need to import to your project.
* __Tests/__ - contains all AMC Unit Tests sources.
   * __ObjectsForTests/__ - contains test classes, that are used in Unit Tests. Good examples how to use AMC.
* __SupportingFiles/__ - XCode stuff (Info.plists, xibs, main.m, etc...)
* AutoMagicCoding.xcodeproj - Mac XCode Project for testing AMC on Mac.
* AutoMagicCoding-iOS.xcodeproj - iOS XCode Project for testing AMC on iOS.
* README.md - contains text that you're reading right now. ;)

Supported properties types
-------------------------------------
 * AMC Enabled Objects.
 * Common Collections (NSArray, NSMutableArray, NSDictionary, NSMutableDictionary)
 * Custom Collections (Mutable/Not-Mutable, that can be used as keyValue(Dictionary) or Ordered(Array) collections )
    * Note: Custom and/or Mutable Collections will not be recognized inside of collections itself. Ordered collections will be treated as NSArray, keyValue collections will be treated as NSDictionary.
 * Common Structures (NSRect/CGRect, NSSize/CGSize, NSPoint/CGPoint).
 * Custom Structures (You will need to write additional code to encode/decode them to/from NSString).
 
File Format
-------------------------------------  

AMC saves object to NSDictionary, that can be saved to PLIST (or JSON).   
Keys simply are ivars names and/or properties names.   
One special key ( "class" ) used to hold name of the object's class.   
Run unit tests on Mac & go look to your Documents folder - there will be a lot of PLISTs.   
They are test objects saved to PLIST files. 

Known Issues
==================
 * Structures can't be iVars - they must be used in AMC as properties (Issue #10) .
 * There's some troubles in XCode running Unit Tests on iOS. See Issue #9 for details.

How To Use
==================
 1. Drag'n'Drop NSObject+AutoMagicCoding.h | m to your project. This will add AMC methods to all objects
 inherited from NSObject.
 2. Import NSObject+AutoMagicCoding.h where you need it.
 3. Reimplement +(BOOL)AMCEnabled and return YES to enable AMC for all instances of your class.
 4. Reimplement -(id)initWithDictionaryRepresentation: and use [super initWithDictionaryRepresentation] inside of it. Ensure that all collections & other fields are created
 after calling super initWithDictionaryRepresentation. Do your own init routines after.
 4. Use -dictionaryRepresentation to encode your object to NSDictionary & NSObject::objectWithDictionaryRepresentation: to decode.
 * __Additionaly:__ reimplement -AMCKeysForDictionaryRepresentation to change amount & order of encoded/decoded fields. (See AMCKeysForDictionaryRepresentation below for more info ).
 * __Additionaly:__ reimplement -AMCEncodeStructWithValue:withName: & -AMCDecodeStructWithValue: withName: to support custom structs (See Custom Struct below for more info).
 * __Additionaly:__ reimplement -AMCFieldTypeForValueWithKey: for any non-scalar ivars, that you want to use
 as fields for AMC. 
 
 __ATTENTION__: It's recommended to avoid using iVars without properties in AMC due to
 harder memory management, need to write more code, unsupported custom structs & possible future restrictions.
 
AMCKeysForDictionaryRepresentation  
==================  

 -AMCKeysForDictionaryRepresentation returns NSArray of NSStrings, thar are passed to KVC methods
 to get & set fields of AMCEnabled objects.
 Default implementation returns complete set of all object properties (both readonly & readwrite),
 including properties declared by superclasses (NSObject's properties are not included).
 Reimplement this method to choose manually, what properties should be encoded/decoded by AMC.
 See tests in "Tests" folder for more info & usage examples.
 
Custom Struct Support   
==================  
 
To support your own custom structs you must do the following:

1. Your custom structs should be used __ONLY AS PROPERTIES__ in your classes. iVars custom structs are not supported.
2. Reimplement -AMCEncodeStructWithValue:withName: & AMCDecodeStructFromString:withName: like this: 

```
- (NSString *) AMCEncodeStructWithValue: (NSValue *) structValue withName: (NSString *) structName
{
    if ([structName isEqualToString: @"CustomStruct" ])
    {
        CustomStruct custom;
        [structValue getValue: &custom]; 
        
        return NSStringFromCustomStruct(custom);
    }
    
    return [super AMCEncodeStructWithValue: structValue withName: structName];
}

- (NSValue *) AMCDecodeStructFromString: (NSString *)value withName: (NSString *) structName
{
    if ([structName isEqualToString: @"CustomStruct" ])
    {
        CustomStruct custom = CustomStructFromNSString(value);
        return [NSValue valueWithBytes: &custom objCType:@encode(CustomStruct)];
    }
    
    return [super AMCDecodeStructFromString: value withName: structName];
}
```

See FooWithStructs & AMCTestSimple for working example.


Exceptions
==================

All exceptions, bad-data & unwanted behaviour tests are located in AMCExceptions.m. 

Here's a list of bad things, that can happen with AMC:   

* __Encoding__ ( calling -dictionaryRepresentation )
   1. **Unsupported struct**: throws AMCEncodeException (See Custom Struct Support above).
   2. **Wrong keys in -AMCKeysForDictionaryRepresentation**: Throws NSUnkownKeyException.( Wrong key = no such property, ivar or method - see KVC programming guide for details).
   3. **KVC bug/failure, when using -valueForKey: with method/property on struct with size that is not multiple of 4**: Throws AMCKeyValueCodingFailureException (Issue #19).
* __Decoding__ ( calling +objectWithDictionaryRepresentation: & -initWithDictionaryRepresentation: )
   1. **Unsupported struct**: Throws AMCDecodeException (See Custom Struct Support above).
   2. **Mismatch between -AMCKeysForDictionaryRepresentation & Dictionary Representation Keys**: No exceptions gets thrown. Only intersect of keys in 
   dictionary representation & -AMCKeysForDictionaryRepresentation are used to set values for decoding object's fields. So always check for neccessery fields in your -initWithDictionaryRepresentation and create them if they are nil.
   3. **Object for Scalar key in Dictionary Representation**: KVC will throw NSInvalidArgumentException i.e. if you're trying to set Object with it's own dictionary representation as simple int.
   4. **Scalar for Object key in Dictionary Representation**: No exception gets thrown. Object will not be set - so your property will still handle nil.
   5. **Object with different class name for Object Key in Dictionary Representation**: No exception gets thrown. I.e. it's possible to set Foo instance for Bar class property with AMC. Their own properties can be set with AMC or remain nil. Do [self.foo isKindOfClass: [Foo class]] checks in -initWithDictinoaryRepresentation: after calling super if it's necessary.
   
AMC_NO_THROW
------------------

You can define AMC_NO_THROW to disable exceptions throw by following methods:

* +objectWithDictionaryRepresentation:
* -initWithDictionaryRepresentation:
* -loadValueForKey:fromDictionaryRepresentation:
* -dictionaryRepresentation   

With AMC_NO_THROW defined they will simply return nil and/or do nothing instead.   
-AMCDecodeStructFromString:withName: & -AMCEncodeStructWithValue:withName: can 
throw exceptions even if AMC_NO_THROW is defined. Don't catch any exceptions in 
your reimplementations of these methods - you don't need to call them directly, so AMC
will catch their exceptions for you. 

License
==================
AMC is licensed under terms & conditions of MIT License.   
http://www.opensource.org/licenses/mit-license.php   

Copyright 2011 Stepan Generalov.  

Permission is hereby granted, free of charge, to any person obtaining a copy  
of this software and associated documentation files (the "Software"), to deal  
in the Software without restriction, including without limitation the rights  
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell  
copies of the Software, and to permit persons to whom the Software is  
furnished to do so, subject to the following conditions:  

The above copyright notice and this permission notice shall be included in  
all copies or substantial portions of the Software.  

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER  
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN  
THE SOFTWARE.  
