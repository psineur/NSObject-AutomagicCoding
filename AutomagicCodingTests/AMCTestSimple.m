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
#import "FooWithSctructs.h"

#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
    #define NSStringFromCGRect(X) NSStringFromRect(NSRectFromCGRect(X))
#endif

@implementation AMCTestSimple
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
    // Save object representation in PLIST & Create new object from that PLIST.
    NSString *path = [self testFilePathWithSuffix:nil];
    NSDictionary *dictRepr =[self.foo dictionaryRepresentation];
    [dictRepr writeToFile: path atomically:YES]; 
    Foo *newFoo = [[Foo objectWithDictionaryRepresentation: [NSDictionary dictionaryWithContentsOfFile: path]] retain];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: path ])
        STFail(@"Test file with path = %@ not exist! Dictionary representation = %@", path, dictRepr);
    
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

- (void) testStructsInFile
{
    // Prepare and save Foo in Dict.
    FooWithSctructs *foo = [FooWithSctructs new];
    foo.point = CGPointMake(15.0f, 16.0f);
    foo.size = CGSizeMake(154.45f, 129.0f);
    foo.rect = CGRectMake(39.0f, 235.0f, 1233.09f, 124.0f);
    NSDictionary *fooDict = [foo dictionaryRepresentation];
    
    // Save object representation in PLIST & Create new object from that PLIST.
    NSString *path = [self testFilePathWithSuffix:@"Struct"];
    [fooDict writeToFile: path atomically:YES];
    // Load newFoo from dict
    FooWithSctructs *newFoo = [[FooWithSctructs objectWithDictionaryRepresentation: [NSDictionary dictionaryWithContentsOfFile: path]] retain];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: path ])
        STFail(@"Test file with path = %@ not exist! Dictionary representation = %@", path, fooDict);
    
    // Test Foo
    STAssertNotNil(newFoo, @"newFoo failed to create.");
    
    if (![[newFoo className] isEqualToString: [FooWithSctructs className]])
        STFail(@"newFoo should be FooWithStructs!");
    STAssertTrue( [newFoo isMemberOfClass: [FooWithSctructs class]], @"isMemberOfClass not working: Foo isn't FooWithSctructs according to it." );
    
    // Test foo's equality.
    STAssertTrue( CGSizeEqualToSize(foo.size, newFoo.size), @"foo.size = {%f, %f} newFoo.size = {%f, %f} ",
                 foo.size.width, foo.size.height, newFoo.size.width, newFoo.size.height);
    STAssertTrue( CGPointEqualToPoint(foo.point, newFoo.point),@"foo.point = {%f, %f} newFoo.point = {%f, %f}",
                 foo.point.x, foo.point.y, newFoo.point.x, newFoo.point.y);
    STAssertTrue( CGRectEqualToRect(foo.rect, newFoo.rect), @"Foo.rect = %@ newFoo.rect = %@", NSStringFromCGRect(foo.rect), NSStringFromCGRect(newFoo.rect) );
    
    
    // Release foo's.
    [foo release];
    [newFoo release];
}

- (void) testStructsInMemory
{
    // Prepare and save Foo in Dict.
    FooWithSctructs *foo = [FooWithSctructs new];
    foo.point = CGPointMake(15.0f, 16.0f);
    foo.size = CGSizeMake(154.45f, 129.0f);
    foo.rect = CGRectMake(39.0f, 235.0f, 1233.09f, 124.0f);
    NSDictionary *fooDict = [foo dictionaryRepresentation];
    
    // Load newFoo from dict
    FooWithSctructs *newFoo = [[FooWithSctructs objectWithDictionaryRepresentation: fooDict] retain];
    
    // Test foo's equality.
    STAssertTrue( CGSizeEqualToSize(foo.size, newFoo.size), @"foo.size = {%f, %f} newFoo.size = {%f, %f} ",
                 foo.size.width, foo.size.height, newFoo.size.width, newFoo.size.height);
    STAssertTrue( CGPointEqualToPoint(foo.point, newFoo.point),@"foo.point = {%f, %f} newFoo.point = {%f, %f}",
                 foo.point.x, foo.point.y, newFoo.point.x, newFoo.point.y);
    STAssertTrue( CGRectEqualToRect(foo.rect, newFoo.rect), @"Foo.rect = %@ newFoo.rect = %@", NSStringFromCGRect(foo.rect), NSStringFromCGRect(newFoo.rect) );
    
    // Release foo's.
    [foo release];
    [newFoo release];
}

@end
