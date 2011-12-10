AMC
==================
AMC is AutoMagic Coding - very easy to use NSCoding replacement for Mac & iOS Projects.
AMC gives you ability to create NSDictionary representation of any supported object, save it in PLIST
(or any other PLIST-compatible file format) and load again without writing a lot of code.

AMC uses Objective-C Runtime to determine object's properties automatically & Key-Value-Coding to
get & set them.

Supported properties types
-------------------------------------
 * AMC Enabled Objects.
 * Common Collections (NSArray, NSMutableArray, NSDictionary, NSMutableDictionary)
 * Custom Collections (Mutable/Not-Mutable, that can be used as keyValue(Dictionary) or Ordered(Array) collections )
 * Common Structures (NSRect/CGRect, NSSize/CGSize, NSPoint/CGPoint).
 * Custom Structures (You will need to write additional code to encode/decode them to/from NSString).
 
File Format
-------------------------------------  

AMC saves object to NSDictionary, that can be saved to PLIST (or JSON).   
Keys simply are ivars names and/or properties names.   
One special key ( "class" ) used to hold name of the object's class.   
Run unit tests on Mac & go look to your documents folder - there will be a lot of PLISTs.   
They are test objects saved to PLIST files. 

Known Issues
==================
 * Structures can't be iVars - they must be used in AMC as properties (Issue #10) .
 * There's some troubles in XCode running Unit Tests on iOS. See Issue #9 for details.

How To Use
==================
 1. Drag'n'Drop NSObject+AutomagicCoding.h | m to your project. This will add AMC methods to all objects
 inherited from NSObject.
 2. Import NSObject+AutomagicCoding.h where you need it.
 3. Reimplement +(BOOL)AMCEnabled and return YES to enable AMC for you class.
 4. Use -dictionaryRepresentation to encode your object to NSDictionary & NSObject::objectWithDictionaryRepresentation: to decode.
 * Additionaly: reimplement -AMCKeysForDictionaryRepresentation to change amount & order of encoded/decoded fields. (See AMCKeysForDictionaryRepresentation below for more info ).
 * Additionaly: reimplement -AMCEncodeStructWithValue: withName: /-AMCDecodeStructWithValue: withName:  to support custom structs (See Custom Struct below for more info).
 * Additionaly: reimplement -AMCFieldTypeForValueWithKey: for any non-scalar ivar, that you want to use
 as fields for AMC. (ATTENTION: It's recommended to avoid using iVars without properties in AMC due to
 harder memory management, need to write more code, unsupported custom structs & possible future restrictions)
 
 AMCKeysForDictionaryRepresentation  
==================  

 -AMCKeysForDictionaryRepresentation returns NSArray of NSStrings, thar are passed to KVC methods
 to get & set fields of AMCEnabled objects.
 Default implementation returns complete set of all object properties (both readonly & readwrite).
 Reimplement this method choose manually, what properties should be encoded in NSDictionary.
 See tests in AutomagicCodingTests for more info & usage examples.
 
Custom Struct   
==================  
 
 __TODO__
 See Unit Tests for Examples of Usage.
 

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
