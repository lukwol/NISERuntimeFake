#import <objc/runtime.h>
#import "NSObject+NISERuntimeFake.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NISERuntimeFakeSpec)

describe(@"NISERuntimeFake", ^{

    __block NSObject *fake;

    beforeEach(^{
        fake = [NSObject fake];
    });

    describe(@"fake object creation", ^{

        subjectAction(^{
            fake = [NSObject fake];
        });

        it(@"should create FakeNSObject class object", ^{
            NSStringFromClass([fake class]) should equal(@"FakeNSObject");
        });

        it(@"should not register created fake class", ^{
            Class expectedClass = NSClassFromString(@"FakeNSObject");
            expectedClass should be_nil;
        });

    });
    
    describe(@"fake class creation", ^{
        
        __block Class fakeClass;
        
        subjectAction(^{
            fakeClass = [NSObject fakeClass];
        });
        
        it(@"should create FakeNSObject class", ^{
            NSStringFromClass(fakeClass) should equal(@"FakeNSObject");
        });
        
        it(@"should not register created fake class", ^{
            Class expectedClass = NSClassFromString(@"FakeNSObject");
            expectedClass should be_nil;
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

    describe(@"catching parameter", ^{

        __block NSObject *passedObject;
        __block NSObject *catchedObject;

        beforeEach(^{
            passedObject = [[NSObject alloc] init];
        });

        subjectAction(^{
            [fake overrideInstanceMethod:@selector(performSelector:withObject:) withImplementation:^id(NSObject *_self, SEL selector, id object) {
                catchedObject = object;
                return nil;
            }];
            [fake performSelector:nil withObject:passedObject];
        });

        it(@"should return passed object", ^{
            catchedObject should equal(passedObject);
        });

    });

    describe(@"catching property", ^{

        __block NSURL *catchedURL;
        __block NSURL *initialURL;
        __block Class fakeClass;

        beforeEach(^{
            fakeClass = [[NSURLConnection fake] class];
        });

        subjectAction(^{
            [fakeClass overrideInstanceMethod:@selector(start) withImplementation:^void(NSURLConnection *_self) {
                catchedURL = [[_self currentRequest] URL];
            }];
            initialURL = [[NSURL alloc] initWithString:@"http://FixtureURL.com"];
            NSURLRequest *URLRequest = [NSURLRequest requestWithURL:initialURL];
            [[fakeClass alloc] initWithRequest:URLRequest delegate:nil];
        });

        it(@"should get initial url", ^{
            catchedURL should equal(initialURL);
        });

    });

    describe(@"returning different object", ^{

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

    describe(@"fake delegate object creation", ^{

        __block BOOL optional;
        __block NSObject <UITableViewDataSource> *fakeDelegate;

        subjectAction(^{
            fakeDelegate = [NSObject fakeDelegate:@protocol(UITableViewDataSource) withOptionalMethods:optional];
        });

        it(@"should create FakeUITableViewDelegate class object", ^{
            NSStringFromClass([fakeDelegate class]) should equal(@"FakeUITableViewDataSource");
        });

        it(@"should not register created fake class", ^{
            Class expectedClass = NSClassFromString(@"FakeUITableViewDataSource");
            expectedClass should be_nil;
        });

        it(@"should conform to protocol ", ^{
            [fakeDelegate conformsToProtocol:@protocol(UITableViewDataSource)] should be_truthy;
        });

        it(@"should implement required method", ^{
            [fakeDelegate respondsToSelector:@selector(tableView:numberOfRowsInSection:)] should be_truthy;
        });

        context(@"when user choose to implement optional methods", ^{

            beforeEach(^{
                optional = YES;
            });

            it(@"should implement optional method", ^{
                [fakeDelegate respondsToSelector:@selector(numberOfSectionsInTableView:)] should be_truthy;
            });

        });

        context(@"when user choose not to implement optional methods", ^{

            beforeEach(^{
                optional = NO;
            });

            it(@"should not implement optional method", ^{
                [fakeDelegate respondsToSelector:@selector(numberOfSectionsInTableView:)] should_not be_truthy;
            });

        });

    });

});

SPEC_END

