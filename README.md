## destination

Objective-C is a neat language. Clang is an incredibly powerful compiler. Xcode... well Xcode's a bit like wading through a olympic swimming pool full of elephant turds.

Thing is, though, Obj-C and Clang *don't actually need Xcode*. Destination (shortened to **dest** in your terminal) is a way to build Objective-C code without having to deal with Xcode. Right now it's rudimentary, but eventually this puppy should be able to build everything from a small `main.m` script to a giant application. We'll see how that goes.

### Getting started

```bash
# Clone the repo
git clone https://github.com/dirk/dest.git
# Go into the test project directory
cd test/project
# Invoke destination
rake build
# Launch the program it just built!
./project
```

### License

Copyright 2014 Dirk Gadsden and licensed under the MIT license. See LICENSE for details.
