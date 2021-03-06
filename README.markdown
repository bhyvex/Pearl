[![Gittip](http://img.shields.io/gittip/lhunath.png)](https://www.gittip.com/lhunath/)
[![Travis CI](http://img.shields.io/travis-ci/Lyndir/Pearl.png)](https://travis-ci.org/Lyndir/Pearl)

Getting Started
===============

Pearl is a modularized iOS library that provides convenience utilities for a wide range of fields.

You can use only the modules that you require.  Some modules do depend on others, and some have external dependencies.  You'll need to add these dependant modules and externals to your project as well.

Any external dependencies can be checked out from the URL in the External/[project]/.source file.


Integration
-----------

The standard way of adding Pearl to your project is by following these steps:

1. Add the Pearl code to your project.  If your project is in a GIT repository, this will do, from your project root:

    `mkdir -p External && git submodule add git://github.com/Lyndir/Pearl.git External/Pearl`

2. Create a Pearl *static library* target in your project.
3. Navigate to the *Build Phases* settings of your main target and add the newly created Pearl target as a *Target Dependency*, and its static library under *Link Binary With Libraries*.
4. In your Project Navigator, choose where you want to place the code of the Pearl modules and add the directory of each Pearl module you wish to use to your new Pearl target.
5. (optional) If any of the Pearl modules you've selected for use depend on other Pearl modules or external dependencies, add those modules and dependencies to your project as well.  I recommend you make separate targets for each external dependency, but that's really up to you.
6. Open the `Pearl-Prefix.pch` that was created for your Pearl target in step 1, and add configuration reflecting your choice of Pearl modules (see below).
7. Open the prefix file of your main target and import Pearl's prefix:

    `#import "Pearl-Prefix.pch"`

![Adding a new target](/Lyndir/Pearl/raw/master/.images/1-target.png)
![Configuring build phases](/Lyndir/Pearl/raw/master/.images/2-phases.png)
![Adding module and dependency sources](/Lyndir/Pearl/raw/master/.images/3-sources.png)
![Configuring your Pearl prefix](/Lyndir/Pearl/raw/master/.images/4-prefix.png)
![Configuring your application prefix](/Lyndir/Pearl/raw/master/.images/5-application.png)


Pearl Configuration
-------------------

Pearl modules can use each other when they know other Pearl modules are available.  For instance, when the Pearl-Media module is activated, the Pearl-Cocos2D module will activate its sound effect and music support.  In order for modules to know which other modules are enabled, you need to define which modules you've selected for inclusion in your project.  You do this in your Pearl target's prefix, which will probably be `Pearl-Prefix.pch`, by enumerating each module with `#define` statements.  For example, assuming you selected Pearl, Pearl-Media and Pearl-Cocos2D, you'd specify these `#define` statements in your Pearl prefix:

    #define PEARL
    #define PEARL_MEDIA
    #define PEARL_COCOS2D

After having defined which modules you'll be using, you need to import their module headers.  Pearl module headers are a single header file for each module that immediately imports all the headers of each file provided by that module.  Importing the module header of each Pearl module you'll be using gives you instant access to any of those Pearl modules' features.  Assuming the example above, you'd import the following:

    #import "Pearl.h"
    #import "Pearl-Media.h"
    #import "Pearl-Cocos2D.h"

Note that Pearl module headers are set up to break the build if you try to import them without first having set up your defines correctly.  This is a protection measure to make sure you don't forget to set up your defines as specified above.

With your `Pearl-Prefix.pch` file set up, your Pearl target should now build fine.  What's left is to give your main application's target access to Pearl.  You'd effectively have to do the same thing, but it's simpler (and safer) to just import your Pearl prefix in your main application's prefix.  For instance, in the Gorillas application, I have a `Gorillas-Prefix.pch` which contains:

    #import "Pearl-Prefix.pch"

If you're writing an open source library that uses Pearl, it's best for your library's prefix file to also assert that the `Pearl-Prefix.pch` of the library's host project has correctly imported the Pearl modules necessary for the library, when it builds your library's code.  I recommend you do that by putting the following in your library's prefix, instead of the one-liner above:

    #import "Pearl-Prefix.pch"
    #if !defined(PEARL) || !defined(PEARL_CRYPTO)
        #error Pearl-Prefix.pch should define: PEARL PEARL_CRYPTO
    #endif

In this example, the library requires the `Pearl` and `Pearl-Crypto` modules.  If your library's prefix declares this, it forces the host application to have a `Pearl-Prefix.pch` that correctly defines and imports these modules.  If you don't do this and the host application's `Pearl-Prefix.pch` omits certain Pearl modules that you need, linkage errors or runtime errors may follow as Pearl won't be compiled with the correct modules.
