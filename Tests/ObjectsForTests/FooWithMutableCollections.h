//
//  FooWithMutableCollections.h
//  AutoMagicCoding
//
//   02.09.11.
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

/** @class FooWithMutableCollections Almost like FooWithCollections, but ivars & properties are mutable.
 * You must use NSMutableArray instead of NSArray in order to AMC work properly.
 * NSObject(AutoMagicCoding)#fieldTypeForValueWithKey: uses property type to get class 
 * and ask it about is it mutable or not.
 */
@interface FooWithMutableCollections : NSObject
{
    NSMutableArray *_array;
    NSMutableDictionary *_dict;
}

@property(readwrite, retain) NSMutableArray *array;
@property(readwrite, retain) NSMutableDictionary *dict;

@end
