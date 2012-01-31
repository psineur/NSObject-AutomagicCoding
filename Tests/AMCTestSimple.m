//
//  AMCTestSimple.m
//  AutoMagicCodingTests
//
//   31.08.11.
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

#import "AMCTestSimple.h"
#import "Foo.h"
#import "Bar.h"
#import "NSObject+AutoMagicCoding.h"
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
    STAssertTrue(newFoo.integerValue == self.foo.integerValue, @"foo.integerValue value corrupted during save/load.");
    STAssertTrue([newFoo.publicBar.someString isEqualToString: self.foo.publicBar.someString],@"foo.bar.someString corrupted during save/load.");
    
    // Test addition to keys - ivars without public properties.
    STAssertNotNil([newFoo valueForKey: @"privateBar"], @"newFoo.privateBar failed to create.");
    
    NSString *oldPrivateString = ((Bar *)[self.foo valueForKey:@"privateBar"]).someString;
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
    STAssertTrue(newFoo.integerValue == self.foo.integerValue, @"foo.integerValue value corrupted during save/load.");
    STAssertTrue([newFoo.publicBar.someString isEqualToString: self.foo.publicBar.someString],@"foo.bar.someString corrupted during save/load.");
    
    // Test addition to keys - ivars without public properties.
    STAssertNotNil([newFoo valueForKey: @"privateBar"], @"newFoo.privateBar failed to create.");
    
    NSString *oldPrivateString = ((Bar *)[self.foo valueForKey:@"privateBar"]).someString;
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

- (void) testStructTypeDetection
{
    FooWithSctructs *foo = [FooWithSctructs new];
    
    
    objc_property_t propertyPoint = class_getProperty([foo class], [@"point" cStringUsingEncoding:NSUTF8StringEncoding]);
    NSString *structNamePoint = AMCPropertyStructName(propertyPoint);
    
    objc_property_t propertyRect = class_getProperty([foo class], [@"rect" cStringUsingEncoding:NSUTF8StringEncoding]);
    NSString *structNameRect = AMCPropertyStructName(propertyRect);
    
    objc_property_t propertySize = class_getProperty([foo class], [@"size" cStringUsingEncoding:NSUTF8StringEncoding]);
    NSString *structNameSize = AMCPropertyStructName(propertySize);
    
    objc_property_t propertyCustomStruct = class_getProperty([foo class], [@"customStruct" cStringUsingEncoding:NSUTF8StringEncoding]);
    NSString *structNameCustom = AMCPropertyStructName(propertyCustomStruct);
    
    
    STAssertTrue([structNamePoint isEqualToString: @"CGPoint"], @"structNamePoint = %@", structNamePoint );
    STAssertTrue([structNameSize isEqualToString: @"CGSize"], @"structNameSize = %@", structNameSize );
    STAssertTrue([structNameRect isEqualToString: @"CGRect"], @"structNameSize = %@", structNameRect );
    STAssertTrue([structNameCustom isEqualToString: @"CustomStruct"], @"structNameCustom = %@", structNameCustom );
    
    [foo release];
}

- (void) testCustomStructInMemory
{
    FooWithSctructs *foo = [FooWithSctructs new];
    foo.point = CGPointMake(15.0f, 16.0f);
    foo.size = CGSizeMake(154.45f, 129.0f);
    foo.rect = CGRectMake(39.0f, 235.0f, 1233.09f, 124.0f);
    
    CustomStruct custom;
    custom.d = 0.578;
    custom.f = 0.3456f;
    custom.i = -20;
    custom.ui = 55;
    foo.customStruct = custom;
    
    NSDictionary *fooDict = [foo dictionaryRepresentation];
    
    
    FooWithSctructs *newFoo = [[NSObject objectWithDictionaryRepresentation: fooDict] retain];
    
    STAssertTrue(newFoo.customStruct.ui == foo.customStruct.ui, 
                 @"newFoo.customStruct.ui should be %d, but it's %d", foo.customStruct.ui, newFoo.customStruct.ui );
    
    STAssertTrue(newFoo.customStruct.d == foo.customStruct.d, 
                 @"newFoo.customStruct.d should be %f, but it's %f", foo.customStruct.d, newFoo.customStruct.d );
    
    STAssertTrue(newFoo.customStruct.f == foo.customStruct.f, 
                 @"newFoo.customStruct.f should be %f, but it's %f", foo.customStruct.f, newFoo.customStruct.f );
    
    STAssertTrue(newFoo.customStruct.i == foo.customStruct.i, 
                 @"newFoo.customStruct.i should be %d, but it's %d", foo.customStruct.i, newFoo.customStruct.i );
    
    [newFoo release];
}

- (void) testCustomStructInFile
{
    FooWithSctructs *foo = [FooWithSctructs new];
    foo.point = CGPointMake(15.0f, 16.0f);
    foo.size = CGSizeMake(154.45f, 129.0f);
    foo.rect = CGRectMake(39.0f, 235.0f, 1233.09f, 124.0f);
    
    CustomStruct custom;
    custom.d = 0.578;
    custom.f = 0.3456f;
    custom.i = -20;
    custom.ui = 55;
    foo.customStruct = custom;
    
    NSDictionary *fooDict = [foo dictionaryRepresentation];
    NSString *path = [self testFilePathWithSuffix:@"CustomStruct"];
    [fooDict writeToFile: path atomically:YES];
   
    // Load newFoo from dict
    FooWithSctructs *newFoo = [[FooWithSctructs objectWithDictionaryRepresentation: [NSDictionary dictionaryWithContentsOfFile: path]] retain];
    
    STAssertTrue(newFoo.customStruct.ui == foo.customStruct.ui, 
                 @"newFoo.customStruct.ui should be %d, but it's %d", foo.customStruct.ui, newFoo.customStruct.ui );
    
    STAssertTrue(newFoo.customStruct.d == foo.customStruct.d, 
                 @"newFoo.customStruct.d should be %f, but it's %f", foo.customStruct.d, newFoo.customStruct.d );
    
    STAssertTrue(newFoo.customStruct.f == foo.customStruct.f, 
                 @"newFoo.customStruct.f should be %f, but it's %f", foo.customStruct.f, newFoo.customStruct.f );
    
    STAssertTrue(newFoo.customStruct.i == foo.customStruct.i, 
                 @"newFoo.customStruct.i should be %d, but it's %d", foo.customStruct.i, newFoo.customStruct.i );
    
    [newFoo release];
}

- (void) testAMCKeysForDictionaryRepresentation
{
    // Get AMC Keys.
    BarBarBar *barbarbar = [[BarBarBar new] autorelease];
    NSArray *keys = [barbarbar AMCKeysForDictionaryRepresentation];
    
    // Test that there's right amount of keys.
    NSArray *expectedKeys = [NSArray arrayWithObjects:@"someString", @"someOtherString", @"thirdString", nil];
    STAssertTrue([expectedKeys isEqual: keys], @"ExpectedKeys = %@, but got Keys = %@", expectedKeys, keys);
}

// No additional ...InFile test needed, cause we use same objects and if other tests
// pass - no need to test can these objects be saved to file or not.
- (void) testLoadValueInMemory
{
    // Prepare objects for test with scalar, customObject, struct & customStruct.
    Foo *foo = [Foo new];
    foo.publicBar = [Bar new];//< Custom Object
    foo.publicBar.someString = @"somestring";  //< Scalar in Custom Object.
    foo.integerValue = 15; //< Scalar.
    
    FooWithSctructs *fooWithStructs = [FooWithSctructs new];
    fooWithStructs.point = CGPointMake(156, 12.5f); // < Struct
    CustomStruct custom = {26, 26.1f, 26.2, -9};
    fooWithStructs.customStruct = custom;
    
    // Prepare dictionary representation of these objects.
    NSDictionary *fooRepresentation = [foo dictionaryRepresentation];
    NSDictionary *fooWithStructsRepresentation = [fooWithStructs dictionaryRepresentation];
    
    // Alloc new objects, that will be used to test -loadValueForKey:fromDictionaryRepresentation:
    Foo *newFoo = [Foo alloc];
    Bar *newBar = [Bar alloc]; //< will test how to create independent custom object from included custom object's representation.
    FooWithSctructs *newFooWithStructs = [FooWithSctructs alloc];
    
    
    // Load one value at time and test that other values aren't loaded.
   
    // IntegerValue - scalar.
    STAssertFalse(newFoo.integerValue == 15, @"newFoo already has integerValue loaded, but it shouldn't!");
    [newFoo loadValueForKey:@"integerValue" fromDictionaryRepresentation: fooRepresentation];
    STAssertTrue(newFoo.integerValue == 15, @"newFoo.integerValue = %d", newFoo.integerValue);
    
    // PublicBar - Custom Object.
    STAssertFalse(newFoo.publicBar != nil, @"Bar shouldn't be loaded at this step!");
    [newFoo loadValueForKey:@"publicBar" fromDictionaryRepresentation:fooRepresentation];
    STAssertNotNil(newFoo.publicBar, @"Bar should be loaded!");
    STAssertTrue([newFoo.publicBar.someString isEqualToString: @"somestring"], @"newFoo.publicBar.someString = %@", newFoo.publicBar.someString);
    
    // PublicBar as independent object.
    STAssertNil(newBar.someString, @"newBar.someString shouldn't be loaded at this step!");
    NSDictionary *publicBarInFooDictionary = [fooRepresentation objectForKey:@"publicBar"];
    [newBar loadValueForKey:@"someString" fromDictionaryRepresentation: publicBarInFooDictionary ];
    STAssertTrue([newBar.someString isEqualToString: @"somestring"], @"newBar.someString = %@", newBar.someString);
    
    // CGPoint - non-custom structure.
    STAssertFalse(CGPointEqualToPoint( newFooWithStructs.point, CGPointMake(156, 12.5f) ) , @"fooWithStructs.point shouldn't be loaded at this step!");
    [newFooWithStructs loadValueForKey:@"point" fromDictionaryRepresentation: fooWithStructsRepresentation];
    STAssertTrue(CGPointEqualToPoint( newFooWithStructs.point, CGPointMake(156, 12.5f) ) , @"fooWithStructs.point failed to load properly!");
    
    // CustomStruct.
    STAssertFalse(newFooWithStructs.customStruct.ui == 26 , @"fooWithStructs.customStruct shouldn't be loaded at this step!");
    STAssertFalse(newFooWithStructs.customStruct.f == 26.1f , @"fooWithStructs.customStruct shouldn't be loaded at this step!");
    STAssertFalse(newFooWithStructs.customStruct.d == 26.2 , @"fooWithStructs.customStruct shouldn't be loaded at this step!");
    STAssertFalse(newFooWithStructs.customStruct.i == -9 , @"fooWithStructs.customStruct shouldn't be loaded at this step!");
    [newFooWithStructs loadValueForKey:@"customStruct" fromDictionaryRepresentation:fooWithStructsRepresentation];
    
    STAssertTrue(newFooWithStructs.customStruct.ui == 26 , @"fooWithStructs.customStruct shouldn't be loaded at this step!");
    STAssertTrue(newFooWithStructs.customStruct.f == 26.1f , @"fooWithStructs.customStruct shouldn't be loaded at this step!");
    STAssertTrue(newFooWithStructs.customStruct.d == 26.2 , @"fooWithStructs.customStruct shouldn't be loaded at this step!");
    STAssertTrue(newFooWithStructs.customStruct.i == -9 , @"fooWithStructs.customStruct shouldn't be loaded at this step!");
}

@end
