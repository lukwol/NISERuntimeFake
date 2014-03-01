NISERuntimeFake
=

What is it?
-
It's a helper category for tests in Objective-C.

What is does?
-
It makes fake objects which can have different behaviour than real objects.  
You can define different behaviour by overriding implemented instace methods.

How does it work?
-
- Create fake object
- Override instance methods with your implementation
- Use your fake object in tests

Example:
-

    //Creating fake object - will create object of class FakeYourClass (subclass of YourClass)
    //You can make any NSObject's subclass fake (will not work with NSProxy)
    YourClass *fakeObject = [YourClass fake]; 
    
    //Overriding instance method - this code will be invoked instead of original implementation  
    //First argument is this object's self, rest arguments are in the same order as in the original method  
    //NOTE: You can write less arguments (or don't write at all) if you want, but you can't write more arguments than original method has   
    //WARNING: Make sure you override fake object's method. Otherwise you can override real class' method.
    __block NSString *catchedString;
    [fakeObject overrideInstanceMethod:@selector(doSomethingWithStringAndReturnArray:) withImplementation:^NSArray *(YourClass *_self, NSString *string){
      catchedString = string;
      return @[@"New implementation"];
    }];
    
    //Use your fake object as you would normally use a real object
    [fakeObject doSomethingWithStringAndReturnArray:@"Whatever"];
    
    //If you want to make new fake object with original implementation just create new one 
    fakeObject = [YourClass fake];
    
Fake delegate Example:
-

    //Create fake delegate with empty implementation of protocol's methods
    YourClass *fakeDelegate = [YourClass fakeDelegate:@protocol(ExampleDelegate) withOptionalMethods:YES];
    
Fake class Example:
-

    //Create fake class
    Class fakeClass = [YourClass fakeClass];
    
    //Override instance methods for all future objects of this class
    __block NSString *catchedString;
    [fakeClass overrideInstanceMethod:@selector(doSomethingWithStringAndReturnArray:) withImplementation:^NSArray *(YourClass *_self, NSString *string){
      catchedString = string;
      return @[@"New implementation"];
    }];
    
    //Create fake object with any method you want using previously created fake class
    YourClass *fake = [[fakeClass alloc] initWithDevice:[UIDevice currentDevice]];
    
    //Use your fake object as you would normally use a real object
    [fakeObject doSomethingWithStringAndReturnArray:@"Whatever"];


