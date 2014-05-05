#import <objc/runtime.h>
#import "NSObject+NISERuntimeFake.h"
#import "TestInheritingProtocol.h"
#import "TestBaseClass.h"
#import "TestInheritingClass.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NISERuntimeFakeSpec)

describe(@"NISERuntimeFake", ^{

    __block TestBaseClass *fake;

    beforeEach(^{
        fake = [TestBaseClass fake];
    });

    afterEach(^{
        fake = nil;
    });

    sharedExamplesFor(@"fake object", ^(NSDictionary *dictionary) {
        describe(@"fake object creation", ^{

            it(@"should create NISEFakeTestBaseClass class object", ^{
                NSStringFromClass([fake class]) should equal(@"NISEFakeTestBaseClass");
            });

            it(@"should not register created fake class", ^{
                Class expectedClass = NSClassFromString(@"NISEFakeTestBaseClass");
                expectedClass should be_nil;
            });

            it(@"should have TestBaseClass as superclass", ^{
                [fake superclass] should equal([TestBaseClass class]);
            });

            it(@"should be kind of TestBaseClass", ^{
                [fake isKindOfClass:[TestBaseClass class]] should be_truthy;
            });

            it(@"should respond to selector for methods from faked class", ^{
                [fake respondsToSelector:@selector(doSomething)] should be_truthy;
            });

            it(@"should have implementation for methods from faked class", ^{
                [fake doSomething] should equal(@"Old implementation");
                [fake exampleStringProperty] should equal(@"Testing method implementation");
            });

            it(@"should have property from faked class", ^{
                fake.exampleStringProperty = @"Testing property";
                fake.exampleStringProperty should equal(@"Testing property");
            });
        });
    });

    itShouldBehaveLike(@"fake object");

    describe(@"class inheritance", ^{

        __block TestInheritingClass *fake;

        subjectAction(^{
            fake = [TestInheritingClass fake];
        });

        it(@"should be NISEFakeTestInheritingClass class object", ^{
            NSStringFromClass([fake class]) should equal(@"NISEFakeTestInheritingClass");
        });

        it(@"should not register created fake class", ^{
            Class expectedClass = NSClassFromString(@"NISEFakeTestInheritingClass");
            expectedClass should be_nil;
        });

        it(@"should have TestInheritingClass as superclass", ^{
            [fake superclass] should equal([TestInheritingClass class]);
        });

        it(@"should be kind of TestInheritingClass", ^{
            [fake isKindOfClass:[TestInheritingClass class]] should be_truthy;
        });

        it(@"should be kind of TestBaseClass", ^{
            [fake isKindOfClass:[TestBaseClass class]] should be_truthy;
        });

        it(@"should respond to selector for methods from faked class", ^{
            [fake respondsToSelector:@selector(doSomethingInInheritingClass)] should be_truthy;
        });

        it(@"should respond to selector for methods from faked super class", ^{
            [fake respondsToSelector:@selector(doSomething)] should be_truthy;
        });

        it(@"should have implementation for methods from faked super class", ^{
            [fake doSomething] should equal(@"Old implementation");
            [fake exampleStringProperty] should equal(@"Testing method implementation");
        });

        it(@"should have property from faked super class", ^{
            fake.exampleStringProperty = @"Testing property";
            fake.exampleStringProperty should equal(@"Testing property");
        });
    });

    describe(@"fake object with protocol creation", ^{

        __block TestBaseClass <TestInheritingProtocol> *fake;
        __block BOOL optional;

        subjectAction(^{
            fake = [TestBaseClass fakeObjectWithProtocol:@protocol(TestInheritingProtocol) includeOptionalMethods:optional];
        });

        itShouldBehaveLike(@"fake object");

        it(@"should create NISEFakeTestBaseClass class object", ^{
            NSStringFromClass([fake class]) should equal(@"NISEFakeTestBaseClass");
        });

        it(@"should not register created fake class", ^{
            Class expectedClass = NSClassFromString(@"NISEFakeTestBaseClass");
            expectedClass should be_nil;
        });

        it(@"should conform to base protocol", ^{
            [fake conformsToProtocol:@protocol(TestBaseProtocol)] should be_truthy;
        });

        it(@"should conform to inheriting protocol", ^{
            [fake conformsToProtocol:@protocol(TestInheritingProtocol)] should be_truthy;
        });

        it(@"should not conform to other protocols", ^{
            [fake conformsToProtocol:@protocol(UITableViewDelegate)] should be_falsy;
        });

        it(@"should implement required method", ^{
            [fake respondsToSelector:@selector(testInheritingRequiredMethod)] should be_truthy;
        });

        context(@"when user choose to implement optional methods", ^{

            beforeEach(^{
                optional = YES;
            });

            it(@"should implement optional method", ^{
                [fake respondsToSelector:@selector(testInheritingOptionalMethod)] should be_truthy;
            });
        });


        context(@"when user choose not to implement optional methods", ^{

            beforeEach(^{
                optional = NO;
            });

            it(@"should not implement optional method", ^{
                [fake respondsToSelector:@selector(testInheritingOptionalMethod)] should_not be_truthy;
            });
        });

        describe(@"protocol inheritance", ^{

            it(@"should conform to base protocol", ^{
                [fake conformsToProtocol:@protocol(TestBaseProtocol)] should be_truthy;
            });

            it(@"should implement required method", ^{
                [fake respondsToSelector:@selector(testBaseRequiredMethod)] should be_truthy;
            });

            context(@"when user choose to implement optional methods", ^{

                beforeEach(^{
                    optional = YES;
                });

                it(@"should implement optional method", ^{
                    [fake respondsToSelector:@selector(testBaseOptionalMethod)] should be_truthy;
                });
            });

            context(@"when user choose not to implement optional methods", ^{

                beforeEach(^{
                    optional = NO;
                });

                it(@"should not implement optional method", ^{
                    [fake respondsToSelector:@selector(testBaseOptionalMethod)] should_not be_truthy;
                });
            });
        });
    });

    describe(@"overriding instance method", ^{

        __block IMP previousImplementation;

        beforeEach(^{
            Method method = class_getInstanceMethod([fake class], @selector(mutableCopy));
            previousImplementation = method_getImplementation(method);
        });

        subjectAction(^{
            [fake overrideInstanceMethod:@selector(mutableCopy) withImplementation:^id(NSObject *_self) {
                return nil;
            }];
        });

        it(@"should override method's implementation", ^{
            Method method = class_getInstanceMethod([fake class], @selector(mutableCopy));
            IMP implementation = method_getImplementation(method);
            implementation should_not equal(previousImplementation);
        });
    });

    describe(@"capturing parameter", ^{

        __block NSObject *passedObject;
        __block NSObject *capturedObject;

        beforeEach(^{
            passedObject = [[NSObject alloc] init];
        });

        subjectAction(^{
            [fake overrideInstanceMethod:@selector(performSelector:withObject:) withImplementation:^id(NSObject *_self, SEL selector, id object) {
                capturedObject = object;
                return nil;
            }];
            [fake performSelector:nil withObject:passedObject];
        });

        it(@"should return passed object", ^{
            capturedObject should equal(passedObject);
        });

    });

    describe(@"capturing property", ^{

        __block NSString *capturedPath;
        __block NSFileManager *fakeFileManager;

        beforeEach(^{
            fakeFileManager = [NSFileManager fake];
        });

        subjectAction(^{
            [fakeFileManager overrideInstanceMethod:@selector(removeItemAtPath:error:)
                                 withImplementation:^BOOL(NSFileManager *_self,
                                         NSString *path,
                                         NSError **error) {
                                     capturedPath = path;
                                     return YES;
                                 }];
            [fakeFileManager removeItemAtPath:@"fixture file path" error:nil];
        });

        it(@"should capture removed file's path", ^{
            capturedPath should equal(@"fixture file path");
        });
    });

    describe(@"returning different value", ^{

        __block NSArray *fakeArray;
        __block NSUInteger count;

        beforeEach(^{
            fakeArray = [NSArray fake];
        });

        subjectAction(^{
            [fakeArray overrideInstanceMethod:@selector(count) withImplementation:^NSUInteger(NSArray *_self) {
                return 42;
            }];
            count = [fakeArray count];
        });

        it(@"should return 42", ^{
            count should equal(42);
        });
    });

});
SPEC_END
