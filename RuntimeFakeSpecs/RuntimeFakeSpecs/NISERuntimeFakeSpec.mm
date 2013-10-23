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
        
    });
    
});

SPEC_END

