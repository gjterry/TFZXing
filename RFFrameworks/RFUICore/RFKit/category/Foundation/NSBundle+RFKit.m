
#import "RFKit.h"
#import "NSBundle+RFKit.h"

@implementation NSBundle (RFKit)
+ (NSString *)mainBundlePathForCaches {
	return [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Caches/"];
}

+ (NSString *)mainBundlePathForPreferences {
	return [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/"];
}

+ (NSString *)mainBundlePathForDocuments {
	return [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/"];
}

+ (NSString *)mainBundlePathForTemp {
	return [NSHomeDirectory() stringByAppendingPathComponent:@"/tmp/"];
}

+ (NSString *)pathForMainBoundlePath:(NSString *)path {
    return [NSHomeDirectory() stringByAppendingPathComponent:path];
}

+ (NSString *)versionString {
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    return [NSString stringWithFormat:@"%@.%@", [info objectForKey:@"CFBundleShortVersionString"], [info objectForKey:@"CFBundleVersion"]];
}

+ (NSString *)shortVersionString {
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    return [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleShortVersionString"]];

}

+ (NSString *)bundleDisplayName {
    NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    return [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleDisplayName"]];
}

+ (double)versionToDouble:(NSString *)versionString {
   __block double value = 0.f;
    NSArray *versionArray = [NSArray arrayWithArray:[versionString componentsSeparatedByString:@"."]];
        double base = 10.f;
        [[[versionArray reverseObjectEnumerator]allObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            value += [[[versionArray reverseObjectEnumerator]allObjects][idx] doubleValue] * pow(base, idx*2);
        }];
    dout_float(value)
    return value;
}

@end
