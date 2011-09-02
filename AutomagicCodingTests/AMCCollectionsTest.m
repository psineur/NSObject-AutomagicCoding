//
//  AMCCollectionsTest.m
//  AutomagicCoding
//
//  Created by Stepan Generalov on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AMCCollectionsTest.h"
#import "FooWithCollections.h"
#import "NSObject+AutomagicCoding.h"

@implementation AMCCollectionsTest
@synthesize fooWithCollections = _fooWithCollections;

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    self.fooWithCollections = [[FooWithCollections new] autorelease];
}

- (void) testEmptyCollectionsInMemory
{
    // Prepare source foo.
    self.fooWithCollections.array =[NSArray array];
    self.fooWithCollections.dict = [NSDictionary dictionary];
    
    // Save & Load.
    NSDictionary *fooDict = [self.fooWithCollections dictionaryRepresentation];   
    // Create new object from that dictionary.
    FooWithCollections *newFoo = [[FooWithCollections objectWithDictionaryRepresentation: fooDict] retain];
    
    // Test newFoo.
    STAssertNotNil(newFoo, @"newFoo failed to create.");
    
    if (![[newFoo className] isEqualToString: [FooWithCollections className]])
        STFail(@"newFoo should be FooWithCollections!");
    STAssertTrue( [newFoo isMemberOfClass: [FooWithCollections class]], @"newFoo is NOT MemberOfClass FooWithCollections!" );
    
    // Test newFoo collections.
    STAssertNotNil(newFoo.array, @"newFoo.array failed to create.");
    STAssertNotNil(newFoo.dict, @"newFoo.dict failed to create.");    
    STAssertTrue( [newFoo.array isKindOfClass: [NSArray class]], @"newFoo.array is NOT KindOfClass NSArray!" );    
    STAssertTrue( [newFoo.dict isKindOfClass: [NSDictionary class]], @"newFoo.dict is NOT KindOfClass NSDictionary!" );
    
    // Test newFoo collections to be empty.
    STAssertTrue([newFoo.array count] == 0, @"newFoo.array is not empty!" );
    STAssertTrue([newFoo.dict count] == 0, @"newFoo.dict is not empty!" );
}

- (void) testEmptyCollectionsInFile
{
    // Prepare source foo.
    self.fooWithCollections.array =[NSArray array];
    self.fooWithCollections.dict = [NSDictionary dictionary];    
    
    // Save object representation in PLIST & Create new object from that PLIST.
    NSString *path = [self testFilePathWithSuffix:@"Empty"];
    [[self.fooWithCollections dictionaryRepresentation] writeToFile: path atomically:YES]; 
    FooWithCollections *newFoo = [[FooWithCollections objectWithDictionaryRepresentation: [NSDictionary dictionaryWithContentsOfFile: path]] retain];
    
    // Test newFoo.
    STAssertNotNil(newFoo, @"newFoo failed to create.");
    
    if (![[newFoo className] isEqualToString: [FooWithCollections className]])
        STFail(@"newFoo should be FooWithCollections!");
    STAssertTrue( [newFoo isMemberOfClass: [FooWithCollections class]], @"newFoo is NOT MemberOfClass FooWithCollections!" );
    
    // Test newFoo collections.
    STAssertNotNil(newFoo.array, @"newFoo.array failed to create.");
    STAssertNotNil(newFoo.dict, @"newFoo.dict failed to create.");    
    STAssertTrue( [newFoo.array isKindOfClass: [NSArray class]], @"newFoo.array is NOT KindOfClass NSArray!" );    
    STAssertTrue( [newFoo.dict isKindOfClass: [NSDictionary class]], @"newFoo.dict is NOT KindOfClass NSDictionary!" );
    
    // Test newFoo collections to be empty.
    STAssertTrue([newFoo.array count] == 0, @"newFoo.array is not empty!" );
    STAssertTrue([newFoo.dict count] == 0, @"newFoo.dict is not empty!" );
}

- (void) testStringCollectionsInMemory
{
    // Prepare source foo.
    self.fooWithCollections.array =[NSArray arrayWithObjects:@"one", @"three", @"two", @"ah!",  nil];
    self.fooWithCollections.dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: @"obj1", @"obj2", @"obj3", nil] 
                                                               forKeys:[NSArray arrayWithObjects: @"key1", @"key2", @"key3", nil]];
    
    // Save & Load.
    NSDictionary *fooDict = [self.fooWithCollections dictionaryRepresentation];   
    // Create new object from that dictionary.
    FooWithCollections *newFoo = [[FooWithCollections objectWithDictionaryRepresentation: fooDict] retain];
    
    // Test newFoo.
    STAssertNotNil(newFoo, @"newFoo failed to create.");
    
    if (![[newFoo className] isEqualToString: [FooWithCollections className]])
        STFail(@"newFoo should be FooWithCollections!");
    STAssertTrue( [newFoo isMemberOfClass: [FooWithCollections class]], @"newFoo is NOT MemberOfClass FooWithCollections!" );
    
    // Test newFoo collections.
    STAssertNotNil(newFoo.array, @"newFoo.array failed to create.");
    STAssertNotNil(newFoo.dict, @"newFoo.dict failed to create.");    
    STAssertTrue( [newFoo.array isKindOfClass: [NSArray class]], @"newFoo.array is NOT KindOfClass NSArray!" );    
    STAssertTrue( [newFoo.dict isKindOfClass: [NSDictionary class]], @"newFoo.dict is NOT KindOfClass NSDictionary!" );
    
    // Test newFoo collections to be the same size.
    STAssertTrue([newFoo.array count] == [self.fooWithCollections.array count], @"newFoo.array count is not wrong!" );
    STAssertTrue([newFoo.dict count] == [self.fooWithCollections.dict count], @"newFoo.dict count is not wrong!" );
    
    STAssertTrue([newFoo.array isEqualTo: self.fooWithCollections.array], @"newFoo.array is not equal with the original!" );
    STAssertTrue([newFoo.dict isEqualTo: self.fooWithCollections.dict], @"newFoo.dict is not equal with the original!" );
}

- (void) testStringCollectionsInFile
{
    // Prepare source foo.
    self.fooWithCollections.array =[NSArray arrayWithObjects:@"one", @"three", @"two", @"ah!",  nil];
    self.fooWithCollections.dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: @"obj1", @"obj2", @"obj3", nil] 
                                                               forKeys:[NSArray arrayWithObjects: @"key1", @"key2", @"key3", nil]];
    
    // Save object representation in PLIST & Create new object from that PLIST.
    NSString *path = [self testFilePathWithSuffix:@"String"];
    [[self.fooWithCollections dictionaryRepresentation] writeToFile: path atomically:YES]; 
    FooWithCollections *newFoo = [[FooWithCollections objectWithDictionaryRepresentation: [NSDictionary dictionaryWithContentsOfFile: path]] retain];
    
    // Test newFoo.
    STAssertNotNil(newFoo, @"newFoo failed to create.");
    
    if (![[newFoo className] isEqualToString: [FooWithCollections className]])
        STFail(@"newFoo should be FooWithCollections!");
    STAssertTrue( [newFoo isMemberOfClass: [FooWithCollections class]], @"newFoo is NOT MemberOfClass FooWithCollections!" );
    
    // Test newFoo collections.
    STAssertNotNil(newFoo.array, @"newFoo.array failed to create.");
    STAssertNotNil(newFoo.dict, @"newFoo.dict failed to create.");    
    STAssertTrue( [newFoo.array isKindOfClass: [NSArray class]], @"newFoo.array is NOT KindOfClass NSArray!" );    
    STAssertTrue( [newFoo.dict isKindOfClass: [NSDictionary class]], @"newFoo.dict is NOT KindOfClass NSDictionary!" );
    
    // Test newFoo collections to be the same size.
    STAssertTrue([newFoo.array count] == [self.fooWithCollections.array count], @"newFoo.array count is not wrong!" );
    STAssertTrue([newFoo.dict count] == [self.fooWithCollections.dict count], @"newFoo.dict count is not wrong!" );
    
    STAssertTrue([newFoo.array isEqualTo: self.fooWithCollections.array], @"newFoo.array is not equal with the original!" );
    STAssertTrue([newFoo.dict isEqualTo: self.fooWithCollections.dict], @"newFoo.dict is not equal with the original!" );}

- (void) testCustomObjectsCollectionInMemory
{
    STFail(@"Test not implemented");
}

- (void) testCustomObjectsCollectionInFile
{
    STFail(@"Test not implemented");
}

- (void) testCollectionsOfCollectionsInMemory
{
    STFail(@"Test not implemented");
}

- (void) testCollectionsOfCollectionsInFile
{
    STFail(@"Test not implemented");
}

- (void)tearDown
{
    // Tear-down code here.
    self.fooWithCollections = nil;
    
    [super tearDown];
}

@end
