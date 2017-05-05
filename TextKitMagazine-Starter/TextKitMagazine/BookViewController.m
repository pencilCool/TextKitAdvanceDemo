//
//  DetailViewController.m
//  TextKitMagazine
//
//  Created by Colin Eberhardt on 02/07/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//
#import "BookView.h"
#import "AppDelegate.h"

#import "BookViewController.h"
#import "BookViewDelegate.h"


@interface BookViewController ()<BookViewDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation BookViewController
{
    BookView *_bookView;
    UIPopoverController* _popover;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.87f alpha:1.0f];
    // 为了不让nav bar 把视图遮盖了，
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _bookView = [[BookView alloc] initWithFrame:self.view.bounds];
    _bookView.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    
    _bookView.bookMarkup = appDelegate.bookMarkup;
    _bookView.bookViewDelegate = self;
    [self.view addSubview:_bookView];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
}
- (void)viewDidLayoutSubviews
{
    [_bookView buildFrames];
}


- (void)navigateToCharacterLocation:(NSUInteger)location
{
    [self.masterPopoverController dismissPopoverAnimated:YES];
    [_bookView navigateToCharacterLocation:location];
}
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"Chapters";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}



- (void)bookView:(BookView *)bookView didHighlightWord:(NSString *)word inRect:(CGRect)rect {
    UIReferenceLibraryViewController *dictionaryVC = [[UIReferenceLibraryViewController alloc]
                                                      initWithTerm: word];
    _popover.contentViewController = dictionaryVC;
    _popover = [[UIPopoverController alloc] initWithContentViewController:dictionaryVC];
    _popover.delegate = self;
    [_popover presentPopoverFromRect:rect inView:_bookView
            permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)popoverControllerDidDismissPopover: (UIPopoverController *)popoverController
{
    [_bookView removeWordHighlight];
}



@end
