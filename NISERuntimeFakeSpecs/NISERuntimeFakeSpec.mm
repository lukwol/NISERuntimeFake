#import <objc/runtime.h>
#import "NSObject+NISERuntimeFake.h"
#import "TestInheritingProtocol.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NISERuntimeFakeSpec)

describe(@"NISERuntimeFake", ^{

    __block NSObject *fake;

    beforeEach(^{
        fake = [NSObject fake];
    });

    afterEach(^{
        fake = nil;
    });

    describe(@"fake object creation", ^{

        subjectAction(^{
            fake = [NSObject fake];
        });

        it(@"should create NISEFakeNSObject class object", ^{
            NSStringFromClass([fake class]) should equal(@"NISEFakeNSObject");
        });

        it(@"should not register created fake class", ^{
            Class expectedClass = NSClassFromString(@"NISEFakeNSObject");
            expectedClass should be_nil;
        });

        it(@"should be subclass of NSObject", ^{
            fake should be_instance_of(NSObject.class).or_any_subclass();
        });
    });

    describe(@"fake object with protocol creation", ^{

        __block NSObject <TestInheritingProtocol> *fakeDelegate;
        __block BOOL optional;

        subjectAction(^{
            fakeDelegate = [NSObject fakeObjectWithProtocol:@protocol(TestInheritingProtocol) includeOptionalMethods:optional];
        });

        it(@"should create NISEFakeNSObject class object", ^{
            NSStringFromClass([fakeDelegate class]) should equal(@"NISEFakeNSObject");
        });

        it(@"should not register created fake class", ^{
            Class expectedClass = NSClassFromString(@"NISEFakeNSObject");
            expectedClass should be_nil;
        });

        it(@"should conform to protocol", ^{
            [fakeDelegate conformsToProtocol:@protocol(TestInheritingProtocol)] should be_truthy;
        });

        it(@"should implement required method", ^{
            [fakeDelegate respondsToSelector:@selector(testInheritingRequiredMethod)] should be_truthy;
        });

        context(@"when user choose to implement optional methods", ^{

            beforeEach(^{
                optional = YES;
            });

            it(@"should implement optional method", ^{
                [fakeDelegate respondsToSelector:@selector(testInheritingOptionalMethod)] should be_truthy;
            });
        });

        context(@"when user choose not to implement optional methods", ^{

            beforeEach(^{
                optional = NO;
            });

            it(@"should not implement optional method", ^{
                [fakeDelegate respondsToSelector:@selector(testInheritingOptionalMethod)] should_not be_truthy;
            });
        });

        describe(@"protocol inheritance", ^{

            it(@"should conform to base protocol", ^{
                [fakeDelegate conformsToProtocol:@protocol(TestBaseProtocol)] should be_truthy;
            });

            it(@"should implement required method", ^{
                [fakeDelegate respondsToSelector:@selector(testBaseRequiredMethod)] should be_truthy;
            });

            context(@"when user choose to implement optional methods", ^{

                beforeEach(^{
                    optional = YES;
                });

                it(@"should implement optional method", ^{
                    [fakeDelegate respondsToSelector:@selector(testBaseOptionalMethod)] should be_truthy;
                });
            });

            context(@"when user choose not to implement optional methods", ^{

                beforeEach(^{
                    optional = NO;
                });

                it(@"should not implement optional method", ^{
                    [fakeDelegate respondsToSelector:@selector(testBaseOptionalMethod)] should_not be_truthy;
                });
            });
        });
    });

    describe(@"overriding instance method", ^{

        __block IMP previousImplementation;

        beforeEach(^{
            Method method = class_getInstanceMethod([fake class], @selector(mutableCopy));
            previousImplementation =  method_getImplementation(method);
        });

        subjectAction(^{
            [fake overrideInstanceMethod:@selector(mutableCopy) withImplementation:^id(NSObject *_self){
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

        __block NSURL *capturedURL;
        __block NSURL *initialURL;
        __block Class fakeClass;

        beforeEach(^{
            fakeClass = [[NSURLConnection fake] class];
        });

        subjectAction(^{
            [fakeClass overrideInstanceMethod:@selector(start) withImplementation:^void(NSURLConnection *_self) {
                capturedURL = [[_self currentRequest] URL];
            }];
            initialURL = [[NSURL alloc] initWithString:@"http://FixtureURL.com"];
            NSURLRequest *URLRequest = [NSURLRequest requestWithURL:initialURL];
            [[fakeClass alloc] initWithRequest:URLRequest delegate:nil];
        });

        it(@"should get initial url", ^{
            capturedURL should equal(initialURL);
        });
    });

    describe(@"returning different value", ^{

        __block NSArray *fakeArray;
        __block NSUInteger count;

        beforeEach(^{
            fakeArray = [NSArray fake];
        });

        subjectAction(^{
            [fakeArray overrideInstanceMethod:@selector(count) withImplementation:^NSUInteger(NSArray *_self){
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
