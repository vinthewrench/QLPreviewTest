# QLPreviewTest

QLPreviewTest is a IOS app that tests simple functionality of QLPreviewController.
there are some bugs introduced in ios 11 that seem to effect the QLPreviewController
depending on whether the files are located in the App mainbundle directory or 
possibly in the NSCachesDirectory.

This app optionally allows testing the use of the QLPreviewController when displaying within a subview.

QuickLook Framework

Summary:

QLPreviewController behavior changed in recent releases of ios 11.  It will fail to preview a file depending on if the files are located in the main bundle or possibly the caches folder .  Further the QLPreviewController will no longer reliably display files when used as a subview.


Steps to Reproduce:

1) build test app found at https://github.com/vinthewrench/QLPreviewTest

2) run on device -  select a variety of sample numbers files.

3) Try again using "Use NSCachesDirectory" and "Use SubView" options  

Expected Results:

1) file should display with Use SubView option.

Actual Results:


1) when running with NSCachesDirectory option off, we get the following log message.

[default] Couldn't issue file extension for url: file:///private/var/containers/Bundle/Application/18ECF6A7-3739-4E2B-8E3D-26B4AB650AD3/QLPreviewTest.app/Test%20files/gasPrices.numbers #PreviewItem

if you preview from the NSCachesDirectory (must copy the file there) a file will preview..

-- 

2) try the NSCachesDirectory on and Use Subview ON.  

The app preview will fail and you will get multiple log entries of 

[default] View service did terminate with error: Error Domain=_UIViewServiceInterfaceErrorDomain Code=3 "(null)" UserInfo={Message=Service Connection Interrupted} #Remote

Version/Build:

Version 9.2 (9C40b)
iOS 11.2.2 (15C202)

Configuration:
Model: iPhone 8 (Model A1863, A1905, A1906, A1907)