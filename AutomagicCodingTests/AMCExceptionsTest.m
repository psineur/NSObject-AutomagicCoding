//
//  AMCExceptionsTest.h
//  AutomagicCoding
//
//  03.12.11.
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

#import "AMCExceptionsTest.h"
#import "NSObject+AutomagicCoding.h"
#import "Bar.h"
#import "Foo.h"

@implementation AMCExceptionsTest

// BadClass have UnsupportedByAMCStruct ivar.
// -dictionaryRepresentation should crash with AMCEncodeException
- (void)testEncodeUnsupportedStructCrash
{
    BOOL crashed = NO; //< should be YES to pass the test.
    
    BadClass *object = [BadClass new];
    @try {
        [object dictionaryRepresentation];
    }
    @catch (NSException *exception) {
        crashed = YES;
        STAssertTrue([[exception name] isEqualToString: AMCEncodeException], 
                     @"Wrong exception name, should be %@ but is %@ instead", AMCEncodeException, [exception name] );
    }
    
    STAssertTrue(crashed, @"");
}

// BadClass have UnsupportedByAMCStruct ivar, that's name is added to 
// AMCKeysForDictionaryRepresentation.
// +objectWithDictionaryRepresentation should crash with AMCDecodeException
- (void)testDecodeUnsupportedStructCrash
{
    BOOL crashed = NO; //< should be YES to pass the test.
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjects: 
                          [NSArray arrayWithObjects: @"BadClass", @"i=5", nil ]
                                                     forKeys: 
                          [NSArray arrayWithObjects: @"class", @"struct", nil]
                          ];
    @try {
        [NSObject objectWithDictionaryRepresentation: dict];
    }
    @catch (NSException *exception) {
        crashed = YES;
        STAssertTrue([[exception name] isEqualToString: AMCDecodeException], 
                     @"Wrong exception name, should be %@ but is %@ instead", AMCDecodeException, [exception name] );
    }
    
    STAssertTrue(crashed, @"");
}

// Each time when AMC creates dictionary representation of an object - it uses
// -AMCKeysForDictionaryRepresentation return value as an array of keys.
// AMC Uses KVC's -valueForKey: method to retreive values.
// If it's impossible to get value - KVC throws NSUnkownKeyException
- (void) testEncodeWrongKeyInAMCKeysCrash
{
    BOOL crashed = NO; //< should be YES to pass the test.
    
    Foobar *object = [Foobar new];
    @try {
        [object dictionaryRepresentation];
    }
    @catch (NSException *exception) {
        crashed = YES;
        STAssertTrue([[exception name] isEqualToString: @"NSUnknownKeyException" ], 
                     @"Wrong exception name, should be %@ but is %@ instead", @"NSUnknownKeyException", [exception name] );
    }
    
    STAssertTrue(crashed, @"");
}


// Each time when object is created from dictionary representation - it uses
// className to create an instance, and then uses
// -AMCKeysForDictionaryRepresentation return value as an array of keys.
// If there's no such key in given dict - AMC will skip it &
// no crash will occur.
- (void) testDecodeUnnecessaryKeyInDict
{ 
    NSDictionary *dict = [[NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: @"Foobar", @"wrongString", nil]
                                                     forKeys: [NSArray arrayWithObjects: kAMCDictionaryKeyClassName, @"wrongKeyThatDoesntExist", nil]
                          ] retain];
    
    @try {
        id object = [[NSObject objectWithDictionaryRepresentation: dict] retain];
        [object release];
    }
    @catch (NSException *exception) {
        STFail(@"+objectWithDictionaryRepresentation crashed with Exception = %@ (%@).", [exception name], [exception reason] );
    }
}

// Changed Foo's dictionaryRepresentation to have Object dictionaryRepresentation 
// in one property instead of simple int value.
// Should crash in KVC's methods with NSInvalidArgumentException
- (void) testDecodeObjectToInt
{
    BOOL crashed = NO; //< Should be YES to pass the test.
    
    // Prepare Foo class - that we will serialize & deserialize in-memory.
    Foo *foo = [[Foo new] autorelease];
    foo.publicBar = [[Bar new] autorelease];
    foo.integerValue = 17;
    
    Bar *privateBarInFoo = [[Bar new]autorelease];
    [foo setValue: privateBarInFoo forKey:@"privateBar"];
    
    // Prepare inside bar objects in Foo.
    foo.publicBar.someString = @"Some Randooooom String! =)";
    privateBarInFoo.someString = @"Some another random string - this time it's in private bar!";
    
    // Retain Foo.
    [foo retain];
    
    // Save object representation in mutable NSDictionary.
    NSMutableDictionary *fooDict = [NSMutableDictionary dictionaryWithDictionary: [foo dictionaryRepresentation] ];
    
    // Change integerValue representation with Bar representation in dictionary representation.
    NSDictionary *newBarDict = [NSDictionary dictionaryWithObjects: [NSArray arrayWithObjects: @"Bar", @"New Bar to set as Int!", nil]
                                                            forKeys: [NSArray arrayWithObjects: kAMCDictionaryKeyClassName, @"someString", nil]
                                 ];
    [fooDict setObject: newBarDict forKey:@"integerValue"];
    
    
    @try {  
        // Try to create new object from that dictionary.
        Foo *newFoo = [[Foo objectWithDictionaryRepresentation: fooDict] retain];
        [newFoo release];
    }
    @catch (NSException *exception) {
        crashed = YES;
        STAssertTrue( [[exception name] isEqualToString:NSInvalidArgumentException], @"Exception name should be %@, but its %@ ( %@ )", NSInvalidArgumentException, [exception name], [exception reason]);
    }    
    
    STAssertTrue(crashed, @"Did not crashed.");
}

// Changed Foo's dictionaryRepresentation to have simple intValue in
// one property instead of object's (Bar) dictionaryRepresentation.
// Shouldn't crash, but publicBar should be nil.
- (void) testDecodeIntToObject
{
    // Prepare Foo class - that we will serialize & deserialize in-memory.
    Foo *foo = [[Foo new] autorelease];
    foo.publicBar = [[Bar new] autorelease];
    foo.integerValue = 17;
    
    Bar *privateBarInFoo = [[Bar new]autorelease];
    [foo setValue: privateBarInFoo forKey:@"privateBar"];
    
    // Prepare inside bar objects in Foo.
    foo.publicBar.someString = @"Some Randooooom String! =)";
    privateBarInFoo.someString = @"Some another random string - this time it's in private bar!";
    
    // Retain Foo.
    [foo retain];
    
    // Save object representation in mutable NSDictionary.
    NSMutableDictionary *fooDict = [NSMutableDictionary dictionaryWithDictionary: [foo dictionaryRepresentation] ];
    
    // Change publicBar representation with integerValue representation in dictionary representation.
    [fooDict setObject: [NSNumber numberWithInt: 19] forKey:@"publicBar"];
    
    @try {
        // Try to create new object from that dictionary.
        Foo *newFoo = [[Foo objectWithDictionaryRepresentation: fooDict] retain];
        STAssertTrue([newFoo isKindOfClass: [Foo class]], @"foo class should be Foo but it is %@ instead.", [Foo className]);
        
        STAssertNil(newFoo.publicBar, @"publicBar can't init from int representation. It should be nil, but it's %@ instead", newFoo.publicBar );
        
        STAssertFalse([newFoo.publicBar isKindOfClass: [NSNumber class]], @"PublicBar is an NSNumber!");
        
        [newFoo release];
    }
    @catch (NSException *exception) {
        STFail(@"Crashed %@ %@", [exception name], [exception reason]);
    }    
}

@end

@implementation BadClass

// Note: structs can't be just ivars - they must be properties.
// This is needed, because AMC uses property runtime info for getting
// structName;
//@synthesize struct = _struct;

+ (BOOL) AMCEnabled
{
    return YES;
}

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [NSArray arrayWithObjects: @"struct", nil];
}

- (AMCFieldType) AMCFieldTypeForValueWithKey: (NSString *) aKey
{
    if ([aKey isEqualToString:@"struct"])
    {
        return kAMCFieldTypeStructure;
    }
    
    return [super AMCFieldTypeForValueWithKey: aKey];
}


@end

@implementation Foobar

- (NSArray *) AMCKeysForDictionaryRepresentation
{
    return [NSArray arrayWithObjects: @"noSuchKey", @"anotherWrongKey", nil];
}

@end
