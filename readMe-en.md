# ZZXcodeFormat

## Updated Features

Support OC and swift code formatting, support xcode9 and 10.

## Installation Method

1. Create a self-signed certificate：

   ```
   Keychain access
   Open the menu: Keychain Access-> Certificate Assistant-> Create Certificate ...
   Enter the certificate name: XcodeSigner;
   Select Identity Type: Identity Type to Self Signed Root
   Select certificate type: Certificate Type to Code Signing 
   Continue all the way to generate the certificate XcodeSigner, which can be seen in the keychain after generation.
   ```

2. Download ZZXcodeFormat and run one_key_install directly，so easy。

## What does one_key_install do for you?

1. Add the `.clang-format` configuration file to the personal folder` ~ `, the rule configuration of the clang-format script is here, of course you can personalize the configuration, refer to [here](http://clang.llvm.org/docs/ClangFormatStyleOptions.html)
2. Check and add Xcode's UUID
3. Compile the plugin
4. Execute xcode self-signature (you need to enter a password during this time, self-signing will take about 10 minutes)

After execution, restart Xcode. If you select LoadBundle in the popup box, you can see ZZXcodeFormat in Xcode-> Edit. Plugin directory：

> open -R ~'/Library/Application Support/Developer/Shared/Xcode/Plug-ins/ZZXcodeFormat.xcplugin'

## Features


ZZXcodeFormat contains the following functions:

1. Format the current Focus window: FocusFile
2. Format multiple selected files: SelectFiles
3. Format the currently selected text area: SelectText

## Extra configuration

Currently I have added shortcut keys i / o / p for the above three items, and the auxiliary keys are control + option + command. Of course you can customize the configuration shortcuts. For example, to add a shortcut to FocusFile:

> System Settings-> Keyboard-> Shortcuts-> Application Shortcuts-> Click Add-> Application Select Xcode, enter FocusFile for the menu title, and set the keyboard shortcut to shift + command + L

Open Xcode, click on ZZXcodeForamt, and you will find it displayed in the menu we added.

## Attach a format FocusFile effect

![Focus](https://github.com/V5zhou/ZZClang-format/blob/master/ZZClang-format/FocusFile%E6%A0%BC%E5%BC%8F%E5%8C%96.gif)
