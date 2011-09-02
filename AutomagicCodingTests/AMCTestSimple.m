//
//  AMCTestSimple.m
//  AutomagicCodingTests
//
//  Created by Stepan Generalov on 31.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AMCTestSimple.h"
#import "Foo.h"
#import "Bar.h"
#import "NSObject+AutomagicCoding.h"

@implementation AutomagicCodingTests
@synthesize foo = _foo;

- (void)setUp
{
    [super setUp];
    
    // Prepare Foo class - that we will serialize & deserialize in-memory.
    Foo *foo = [[Foo new] autorelease];
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
    Foo *newFoo = [[Foo objectWithDictionaryRepresentation: fooDict] retain];
    
    // Test Foo
    STAssertNotNil(newFoo, @"newFoo failed to create.");
    
    if (![[newFoo className] isEqualToString: [Foo className]])
        STFail(@"newFoo should be Foo!");
    STAssertTrue( [newFoo isMemberOfClass: [Foo class]], @"isMemberOfClass not working: Foo isn't Foo according to it." );
    
    // Test Foo.publicBar
    STAssertNotNil(newFoo.publicBar, @"newFoo.publicBar failed to create.");
    
    if (![[newFoo.publicBar className] isEqualToString: [Bar className]])
        STFail(@"newFoo.publicBar should be Bar!");
    STAssertTrue( [newFoo.publicBar isMemberOfClass: [Bar class]], @"isMemberOfClass not working: Bar isn't Bar according to it." );
    
    // Test object equality.
    STAssertTrue(newFoo.integerValue == self.foo.integerValue, @"foo.integerValue value currupted during save/load.");
    STAssertTrue([newFoo.publicBar.someString isEqualToString: self.foo.publicBar.someString],@"foo.bar.someString currupted during save/load.");
    
    // Test addition to keys - ivars without public properties.
    STAssertNotNil([newFoo valueForKey: @"privateBar"], @"newFoo.privateBar failed to create.");
    
    NSString *oldPrivateString = ((Bar *)[newFoo valueForKey:@"privateBar"]).someString;
    NSString *newPrivateString = ((Bar *)[newFoo valueForKey:@"privateBar"]).someString;
    STAssertTrue([oldPrivateString isEqualToString: newPrivateString],@"foo.privateBar.someString corrupted during save/load.");
    
    [newFoo release];
    
}

- (void) testInFile
{
    // Save object representation in PLIST.
    [[self.foo dictionaryRepresentation] writeToFile:[self testFilePathWithSuffix:nil] atomically:YES];
    
    // Create new object from that PLIST.
    Foo *newFoo = [[Foo objectWithDictionaryRepresentation: [NSDictionary dictionaryWithContentsOfFile:[self testFilePathWithSuffix:nil]]] retain];
    
    // Test Foo
    STAssertNotNil(newFoo, @"newFoo failed to create.");
    
    if (![[newFoo className] isEqualToString: [Foo className]])
        STFail(@"newFoo should be Foo!");
    STAssertTrue( [newFoo isMemberOfClass: [Foo class]], @"isMemberOfClass not working: Foo isn't Foo according to it." );
    
    // Test Foo.publicBar
    STAssertNotNil(newFoo.publicBar, @"newFoo.publicBar failed to create.");
    
    if (![[newFoo.publicBar className] isEqualToString: [Bar className]])
        STFail(@"newFoo.publicBar should be Bar!");
    STAssertTrue( [newFoo.publicBar isMemberOfClass: [Bar class]], @"isMemberOfClass not working: Bar isn't Bar according to it." );
    
    // Test object equality.
    STAssertTrue(newFoo.integerValue == self.foo.integerValue, @"foo.integerValue value currupted during save/load.");
    STAssertTrue([newFoo.publicBar.someString isEqualToString: self.foo.publicBar.someString],@"foo.bar.someString currupted during save/load.");
    
    // Test addition to keys - ivars without public properties.
    STAssertNotNil([newFoo valueForKey: @"privateBar"], @"newFoo.privateBar failed to create.");
    
    NSString *oldPrivateString = ((Bar *)[newFoo valueForKey:@"privateBar"]).someString;
    NSString *newPrivateString = ((Bar *)[newFoo valueForKey:@"privateBar"]).someString;
    STAssertTrue([oldPrivateString isEqualToString: newPrivateString],@"foo.privateBar.someString corrupted during save/load.");
    
    [newFoo release];
}

@end
