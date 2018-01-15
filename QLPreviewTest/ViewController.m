//
//  ViewController.m
//  QLPreviewTest
//
//  Created by vinnie on 1/15/18.
//  Copyright © 2018 4th-a. All rights reserved.
//

#import "ViewController.h"
#import <QuickLook/QuickLook.h>
#import "OurQLPreviewController.h"


@implementation ViewController
{

    IBOutlet __weak UIView*         _vwContainer;

    IBOutlet __weak UITableView    *_tblFiles;
    IBOutlet __weak UISwitch       *_swUseCacheFolder;
    IBOutlet __weak UISwitch       *_swUseSubView;

    UIBarButtonItem *           _backActionButton;

    NSArray*                        testFiles;

    OurQLPreviewController*  ourQlPreviewController;

    NSURL*              previewURL;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    _backActionButton = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                       target:self

                                                                       action:@selector(handleNavigationBack:)];


     testFiles = self.createTestFilePaths;

    [_swUseCacheFolder setOn:NO];
    [_swUseSubView setOn:NO];

    _vwContainer.hidden = YES;
    [_tblFiles  reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{

    self.navigationItem.title  = @"QLPreview Tester";

    _vwContainer.hidden = YES;
    for (UIView *subview in _vwContainer.subviews)
        [subview removeFromSuperview];

    [_tblFiles  reloadData];

}

- (NSString *)identifier
{
    NSBundle *main = NSBundle.mainBundle;
    NSString *identifier = [main objectForInfoDictionaryKey: (NSString *)kCFBundleIdentifierKey];

    return identifier;
}


-(NSArray<NSURL *> * ) createTestFilePaths
{
    NSMutableArray *files = NSMutableArray.array;

    NSURL* directoryURL =  [NSBundle.mainBundle.bundleURL URLByAppendingPathComponent:@"Test files"];

    NSDirectoryEnumerationOptions options =
        NSDirectoryEnumerationSkipsSubdirectoryDescendants |
        NSDirectoryEnumerationSkipsPackageDescendants      |
        NSDirectoryEnumerationSkipsHiddenFiles;

    NSDirectoryEnumerator<NSURL *> *enumerator =
    [[NSFileManager defaultManager] enumeratorAtURL:directoryURL
                         includingPropertiesForKeys:@[ NSFileTypeDirectory,  ]
                                            options:options
                                       errorHandler:NULL];



    for (NSURL *url in enumerator)
    {
        NSNumber*  isDirectory = @(NO);
        NSNumber*  isPackage = @(NO);

        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        [url getResourceValue:&isPackage forKey:NSURLIsPackageKey error:NULL];

        if(isDirectory.boolValue && !isPackage.boolValue) continue;

        [files addObject:url];
    }

    return files;
}

- (NSURL *)appCacheDirectoryURL
{
    static NSURL *appCacheDirectoryURL = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        NSError *error = nil;
        NSURL *url = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory
                                                            inDomain:NSUserDomainMask
                                                   appropriateForURL:nil
                                                              create:YES
                                                               error:&error];

#if !TARGET_OS_IPHONE // Mac OS X
        if (!error)
        {
            url = [url URLByAppendingPathComponent:self.identifier isDirectory:YES];

            [[NSFileManager defaultManager] createDirectoryAtURL:url
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:&error];

            if (error) {
                DDLogError(@"%@: Error creating directory: %@", THIS_METHOD, error);
            }
        }
#endif

        appCacheDirectoryURL = url;
    });

    return appCacheDirectoryURL;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return testFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileCell"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"fileCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType =   UITableViewCellAccessoryDisclosureIndicator;
    }

    NSURL* url = testFiles[indexPath.row];
    cell.textLabel.text = url.lastPathComponent;

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL* url = testFiles[indexPath.row];
    NSError *error = nil;

    if(_swUseCacheFolder.on)
    {
        NSURL* newURL = [self.appCacheDirectoryURL URLByAppendingPathComponent:url.lastPathComponent];

        if([NSFileManager.defaultManager fileExistsAtPath:newURL.path])
            [NSFileManager.defaultManager removeItemAtPath:newURL.path error:NULL];

        [NSFileManager.defaultManager copyItemAtURL:url toURL:newURL error:&error];

        url = newURL;
    }

    if([NSFileManager.defaultManager fileExistsAtPath:url.path])
    {
        if(_swUseSubView.on)
        {
            // display using subview
            [self subViewPreviewFileAtURL:url];
        }
        else
        {
            // display using main view
            [self previewFileAtURL:url];
        }

    }
};


-(void) subViewPreviewFileAtURL:(NSURL*)url
{

    // clear any old subviews
    for (UIView *subview in _vwContainer.subviews)
        [subview removeFromSuperview];

    ourQlPreviewController = [[OurQLPreviewController alloc] init];

    [self  addChildViewController:ourQlPreviewController];

    ourQlPreviewController.view.frame = _vwContainer.bounds;
    ourQlPreviewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_vwContainer  addSubview:ourQlPreviewController.view];

    _vwContainer.hidden = NO;

    self.navigationItem.leftBarButtonItem = _backActionButton;
    [ourQlPreviewController displayURL:url withTitle:url.lastPathComponent];
    
}


-(IBAction) handleNavigationBack:(id)sender
{
    self.navigationItem.leftBarButtonItem = nil;
    _vwContainer.hidden = YES;

    for (UIView *subview in _vwContainer.subviews)
        [subview removeFromSuperview];

    [ourQlPreviewController removeFromParentViewController ];

    ourQlPreviewController = nil;
    
     [_tblFiles    reloadData];


}


-(void) previewFileAtURL:(NSURL*)url
{
    previewURL = url;

   QLPreviewController*  pvc = [[QLPreviewController alloc] init];
    pvc.dataSource = (id <QLPreviewControllerDataSource>) self;
    pvc.delegate   = (id <QLPreviewControllerDelegate>)self;
    pvc.currentPreviewItemIndex = 0;
    [self.navigationController pushViewController:pvc animated:YES];
}


#pragma mark - QLPreviewControllerDataSource

// Returns the number of items that the preview controller should preview
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)previewController
{
    NSInteger numToPreview = 1;
    return numToPreview;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    // if the preview dismissed (done button touched), use this method to post-process previews
}

// returns the item that the preview controller should preview
- (id)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx
{
     return previewURL;
}


@end
