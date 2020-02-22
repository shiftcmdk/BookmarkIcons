@interface BookmarkFavoritesGridView: UIView
@end

@interface WebBookmark : NSObject

@property (nonatomic,readonly) NSString * UUID;

@end

@interface _SFBookmarkInfoViewController: UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIViewController *imagePickerPresentingViewController;
@property (nonatomic, strong) UIImage *lastSelectedIcon;
@property (nonatomic,retain) WebBookmark * bookmark;

-(void)updateBookmarkIcon;

@end

@interface _SFSiteIconView : UIImageView

@property (nonatomic, strong) UIImageView *customImageView;
@property (nonatomic,retain) WebBookmark * bookmark;

-(void)_setImage:(id)arg1 withBackgroundColor:(id)arg2;

@end

@interface BookmarkFavoritesViewController: UIViewController
@end

@interface BookmarkFavoritesGridCollectionViewCell : UICollectionViewCell
@end