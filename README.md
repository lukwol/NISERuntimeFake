NISERuntimeFake
=

[![Version](https://cocoapod-badges.herokuapp.com/v/NISERuntimeFake/badge.png)](http://cocoadocs.org/docsets/NISERuntimeFake)
[![Platform](http://cocoapod-badges.herokuapp.com/p/NISERuntimeFake/badge.png)](http://cocoadocs.org/docsets/NISERuntimeFake)

What is it?
-
`NISERuntimeFake` is an `NSObject` category which creates fake objects at runtime.

What is does?
-
It makes fake objects which can have different behaviour than real objects.  
You can define different behaviour by overriding implemented instance methods.

How does it work?
-
- Create fake object
- Override instance methods with your implementation
- Use your fake object in tests

Example:
-

    //Creating fake object
    YourClass *fakeObject = [YourClass fake]; 
    
    //Overriding instance method
    __block NSString *capturedString;
    [fakeObject overrideInstanceMethod:@selector(doSomethingWithString:) withImplementation:^(YourClass *_self, NSString *string){
      capturedString = string;
    }];
    
    //Use your fake object as you would normally use a real object
    [fakeObject doSomethingWithString:@"Whatever"];
    
    NSLog(@"%@", capturedString); //Output will be "Whatever"

    
    //If you want to make new fake object with original implementation just create new one 
    fakeObject = [YourClass fake];
    
Fake object with protocol example:
-

    //Create fake object with protocol methods
    YourClass *fakeObjectWithProtocol = [YourClass fakeObjectWithProtocol:@protocol(YourProtocol) includeOptionalMethods:YES];