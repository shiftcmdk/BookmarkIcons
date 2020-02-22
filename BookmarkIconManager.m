#import "BookmarkIconManager.h"

@implementation BookmarkIconManager

+(void)addIcon:(UIImage *)icon forBookmarkIdentifier:(NSString *)identifier {
    NSData *imageData = UIImagePNGRepresentation(icon);

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];

    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", identifier]];

    [imageData writeToFile:filePath atomically:YES];
}

+(void)removeIconForBookmarkIdentifier:(NSString *)identifier {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];

    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", identifier]];

    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

+(UIImage *)iconImageForBookmarkIdentifier:(NSString *)identifier {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];

    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", identifier]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];
    }

    return nil;
}

@end