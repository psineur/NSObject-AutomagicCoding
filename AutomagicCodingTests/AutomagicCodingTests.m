//
//  AutomagicCodingTests.m
//  AutomagicCodingTests
//
//  Created by Stepan Generalov on 31.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AutomagicCodingTests.h"
#import "Foo.h"
#import "Bar.h"
#import "NSObject+AutomagicCoding.h"

@implementation AutomagicCodingTests
@synthesize foo = _foo;

- (void)setUp
{
    [super setUp];
    
    // Prepare Foo class - that we will serialize & deserialize in-memory.
    Foo *foo = [Foo new];
    foo.publicBar = [[Bar new] autorelease];
    foo.integerValue = 17;
    Bar *privateBarInFoo = [[Bar new]autorelease];
    [foo setValue: privateBarInFoo forKey:@"privateBar"];
    
    // Prepare inside bar objects in Foo.
    foo.publicBar.someString = @"Some Randooooom String! =)";
    privateBarInFoo.someString = @"Some another random string - this time it's int private bar!";
    
    // Retain Foo.
    self.foo = foo;
}

- (void)tearDown
{
    // Release Foo,
    self.foo = nil;
    
    [super tearDown];
}

- (void) testInMemory
{
    // Save object representation in NSDictionary.
    NSDictionary *fooDict = [self.foo dictionaryRepresentation];
    
    // Create new object from that dictionary.
    Foo *newFoo = [Foo objectWithDictionaryRepresentation: fooDict];
    
    // Test object equality.
    STAssertTrue([newFoo isMemberOfClass: [Foo class]], @"foo class currupted during save/load.");
    STAssertTrue(newFoo.integerValue == self.foo.integerValue, @"foo.integerValue value currupted during save/load.");
    STAssertTrue([newFoo.publicBar isMemberOfClass:[Bar class]], @"foo.bar class wasn't currupted during save/load.");
    STAssertTrue([newFoo.publicBar.someString isEqualToString: self.foo.publicBar.someString],@"foo.bar.someString currupted during save/load.");
    
    NSString *oldPrivateString = ((Bar *)[newFoo valueForKey:@"privateBar"]).someString;
    NSString *newPrivateString = ((Bar *)[newFoo valueForKey:@"privateBar"]).someString;
    STAssertTrue([oldPrivateString isEqualToString: newPrivateString],@"foo.privateBar.someString corrupted during save/load.");
    
}

@end
