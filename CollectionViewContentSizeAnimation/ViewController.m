//
//  ViewController.m
//  CollectionViewContentSizeAnimation
//
//  Created by Ole Begemann on 28.06.14.
//  Copyright (c) 2014 Ole Begemann. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *otherView;
@property (nonatomic) NSInteger numberOfItemsInCollectionView;

@end

@implementation ViewController

static void *KVOObserverContext = &KVOObserverContext;

- (void)dealloc
{
    [self.collectionView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.numberOfItemsInCollectionView = 1; // This is our model
    
    // Set up KVO for collectionView.contentSize
    [self.collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionOld context:KVOObserverContext];
}

- (IBAction)addItem:(id)sender
{
    // Change the model
    self.numberOfItemsInCollectionView += 1;
    
    // Animate cell insertion
    [self.collectionView performBatchUpdates:^{
        NSIndexPath *indexPathOfInsertedCell = [NSIndexPath indexPathForItem:self.numberOfItemsInCollectionView - 1 inSection:0];
        [self.collectionView insertItemsAtIndexPaths:@[ indexPathOfInsertedCell ]];
    } completion:nil];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == KVOObserverContext && object == self.collectionView && [keyPath isEqualToString:@"contentSize"]) {
        CGSize oldContentSize = [change[NSKeyValueChangeOldKey] CGSizeValue];
        if (!CGSizeEqualToSize(oldContentSize, self.collectionView.contentSize)) {
            NSLog(@"Observing contentSize change, adjusting collection view frame");
            CGRect collectionViewFrame = self.collectionView.frame;
            collectionViewFrame.size.height = (self.numberOfItemsInCollectionView * 40) + 94;
            self.collectionView.frame = collectionViewFrame;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.numberOfItemsInCollectionView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCell" forIndexPath:indexPath];
    return cell;
}

@end
