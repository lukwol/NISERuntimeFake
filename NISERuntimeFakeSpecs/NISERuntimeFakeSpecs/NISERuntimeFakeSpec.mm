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

    });
    
    describe(@"fake class creation", ^{
        
        __block Class fakeClass;
        
        subjectAction(^{
            fakeClass = [NSObject fakeClass];
        });
        
        it(@"should create NISEFakeNSObject class", ^{
            NSStringFromClass(fakeClass) should equal(@"NISEFakeNSObject");
        });
        
        it(@"should not register created fake class", ^{
            Class expectedClass = NSClassFromString(@"NISEFakeNSObject");
            expectedClass should be_nil;
        });
        
    });

    describe(@"fake object with protocol creation", ^{

        __block BOOL optional;
        __block NSObject <UITableViewDataSource> *fakeDelegate;

        subjectAction(^{
            fakeDelegate = [NSObject fakeObjectWithProtocol:@protocol(UITableViewDataSource) optionalMethods:optional];
        });

        it(@"should create NISEFakeUITableViewDelegate class object", ^{
            NSStringFromClass([fakeDelegate class]) should equal(@"NISEFakeUITableViewDataSource");
        });

        it(@"should not register created fake class", ^{
            Class expectedClass = NSClassFromString(@"NISEFakeUITableViewDataSource");
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

