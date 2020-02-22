@interface BookmarkIconManager: NSObject

+(void)addIcon:(UIImage *)icon forBookmarkIdentifier:(NSString *)identifier;
+(void)removeIconForBookmarkIdentifier:(NSString *)identifier;
+(UIImage *)iconImageForBookmarkIdentifier:(NSString *)identifier;

@end