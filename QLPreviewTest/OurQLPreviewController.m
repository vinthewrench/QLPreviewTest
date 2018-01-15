//
//  QLPreviewController.m
//  QLPreviewTest
//
//  Created by vinnie on 1/15/18.
//  Copyright © 2018 4th-a. All rights reserved.
//

#import "OurQLPreviewController.h"
#import <QuickLook/QuickLook.h>


@interface PreviewItem: NSObject <QLPreviewItem>
@property (nonatomic, strong   )            NSString        *title;
@property (nonatomic, strong   )            NSURL           *url;
@property (nonatomic, strong   )            UIImage         *thumbnail;
@end;

@implementation PreviewItem
@synthesize  title = title;
@synthesize  url = url;
@synthesize thumbnail = thumbnail;


- (NSString*) previewItemTitle
{
    return title;
}

-( NSURL*) previewItemURL
{
    return url;
}

@end


@implementation OurQLPreviewController
{
    QLPreviewController*    pvc;

    PreviewItem*            previewItem;
    NSInteger               previewItemCount;
}


- (instancetype)init
{
    if ((self = [super initWithNibName:@"OurQLPreviewController" bundle:nil]))
    {
    }
    return self;
}

- (void)dealloc
{
    if(pvc)
    {
        previewItemCount = 0;
        pvc.currentPreviewItemIndex = 0;
        [pvc reloadData];
        [pvc viewWillDisappear:NO];

    }
    pvc = nil;
    previewItem = nil;
 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillDisappear:(BOOL)animated
{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)displayURL:(NSURL*)url  withTitle:(NSString*)titleIn
{
    NSString* title = titleIn;
    if(!title)
    {
        title =   [url.absoluteString stringByDeletingPathExtension];
    }

    previewItem         = [[PreviewItem alloc]init];
    previewItem.url     = url.fileReferenceURL;
    previewItem.title   = title;
  //  previewItem.thumbnail = _imgThumbNail.image;
    previewItemCount = 1;
    if([QLPreviewController canPreviewItem:previewItem])
    {
        if(pvc)
        {
            [ pvc.view removeFromSuperview];
            pvc = nil;

        }
        pvc = [[QLPreviewController alloc] init];
        pvc.dataSource = (id <QLPreviewControllerDataSource>) self;
        pvc.delegate   = (id <QLPreviewControllerDelegate>)self;
        pvc.currentPreviewItemIndex = 0;
        pvc.view.frame = self.view.frame;

        [self.view addSubview:pvc.view];
    }
}

#pragma mark - QLPreviewControllerDelegate

/*---------------------------------------------------------------------------
 *
 *--------------------------------------------------------------------------*/
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return  previewItemCount;
}
//
//- (UIImage *)previewController:(QLPreviewController *)controller transitionImageForPreviewItem:(id <QLPreviewItem>)item contentRect:(CGRect *)contentRect
//{
//    __block PreviewItem *pvItem = item;
//
//    return pvItem.thumbnail;
//}



- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item
{
    BOOL shouldOpen = YES;

    return shouldOpen;
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{

    return (previewItemCount)?previewItem:nil;

}

@end
