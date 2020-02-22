#import "BookmarkIcons.h"
#import "BookmarkIconManager.h"

%hook _SFBookmarkInfoViewController

%property (nonatomic, strong) UIViewController *imagePickerPresentingViewController;
%property (nonatomic, strong) UIImage *lastSelectedIcon;

-(void)viewDidLoad {
    %orig;

    self.lastSelectedIcon = [BookmarkIconManager iconImageForBookmarkIdentifier:self.bookmark.UUID];
}

-(void)viewDidAppear:(BOOL)animated {
    %orig;

    UIImageView *imageView = [self valueForKey:@"_iconImageView"];
    imageView.userInteractionEnabled = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];

    [imageView addGestureRecognizer:tap];

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressImageView:)];

    [imageView addGestureRecognizer:longPress];
}

-(void)cancel {
    if (self.lastSelectedIcon) {
        [BookmarkIconManager addIcon:self.lastSelectedIcon forBookmarkIdentifier:self.bookmark.UUID];
    } else {
        [BookmarkIconManager removeIconForBookmarkIdentifier:self.bookmark.UUID];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"bi_iconimagechanged" object:self];

    %orig;
}

%new
-(void)longPressImageView:(UILongPressGestureRecognizer *)sender {
    [BookmarkIconManager removeIconForBookmarkIdentifier:self.bookmark.UUID];

    _SFSiteIconView *imageView = [self valueForKey:@"_iconImageView"];

    imageView.customImageView.image = nil;
    imageView.customImageView.backgroundColor = [UIColor clearColor];
}

%new
-(void)tapImageView:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];

    if (!self.imagePickerPresentingViewController) {
        self.imagePickerPresentingViewController = [[UIViewController alloc] init];
        self.imagePickerPresentingViewController.view.userInteractionEnabled = NO;

        [self.imagePickerPresentingViewController.view setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

        [self.view addSubview:self.imagePickerPresentingViewController.view];
    }

    self.imagePickerPresentingViewController.view.frame = self.view.bounds;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;

        [self.imagePickerPresentingViewController presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"Tap the icon to select a new one from your photo library. Long press the icon to reset it to the default icon.";
    }
    return %orig;
}

%new
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.imagePickerPresentingViewController dismissViewControllerAnimated:YES completion:nil];

    _SFSiteIconView *imageView = [self valueForKey:@"_iconImageView"];

    UIImage *image = info[UIImagePickerControllerOriginalImage];

    [BookmarkIconManager addIcon:image forBookmarkIdentifier:self.bookmark.UUID];

    imageView.customImageView.image = image;
    imageView.customImageView.backgroundColor = [UIColor whiteColor];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"bi_iconimagechanged" object:self];
}

%new
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePickerPresentingViewController dismissViewControllerAnimated:YES completion:nil];
}

%end

%hook BookmarkFavoritesViewController

-(void)viewDidLoad {
    %orig;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bi_iconImageChanged:) name:@"bi_iconimagechanged" object:nil];
}

%new
- (void)bi_iconImageChanged:(NSNotification *) notification {
    UICollectionView *collectionView = [[self valueForKey:@"_favoritesGridView"] valueForKey:@"collectionView"];

    for (UICollectionViewCell *cell in collectionView.visibleCells) {
        if ([cell isKindOfClass:[%c(BookmarkFavoritesGridCollectionViewCell) class]]) {
            [[[cell valueForKey:@"_bookmarkFavoriteView"] valueForKey:@"_iconView"] setNeedsLayout];
        }
    }
}

-(void)bookmarkFavoritesGridView:(id)arg1 deleteBookmark:(WebBookmark *)arg2 {
    %orig;

    [BookmarkIconManager removeIconForBookmarkIdentifier:arg2.UUID];
}

- (void)deleteBookmark:(WebBookmark *)arg1 userInfo:(id)arg2 {
    %orig;

    [BookmarkIconManager removeIconForBookmarkIdentifier:arg1.UUID];
}

%end

%hook _SFSiteIconView

%property (nonatomic, strong) UIImageView *customImageView;

-(void)layoutSubviews {
    %orig;

    if (!self.customImageView) {
        self.customImageView = [[UIImageView alloc] init];
        self.customImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.customImageView.clipsToBounds = YES;

        [self addSubview:self.customImageView];
    }

    self.customImageView.frame = self.bounds;
    self.customImageView.image = [BookmarkIconManager iconImageForBookmarkIdentifier:self.bookmark.UUID];

    if (self.customImageView.image) {
        self.customImageView.backgroundColor = [UIColor whiteColor];
    } else {
        self.customImageView.backgroundColor = [UIColor clearColor];
    }

    [self bringSubviewToFront:self.customImageView];

    if (@available(iOS 13, *)) {
        self.customImageView.layer.cornerRadius = ((UIView *)[self valueForKey:@"_imageView"]).layer.cornerRadius;

        UIView *border = [self valueForKey:@"_borderView"];

        if (border) {
            [self bringSubviewToFront:border];
        }
    } else {
        self.customImageView.layer.cornerRadius = self.layer.cornerRadius;
    }
}

%end
