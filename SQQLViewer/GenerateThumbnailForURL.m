#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import <sqlite3.h>
#import <Cocoa/Cocoa.h>

#define CSS_STYLE "\
<style>                                 \
table{font-family:\"Lucida Sans Unicode\",\"Lucida Grande\",Sans-Serif;font-size:12px;\
background:#fff;border-collapse:collapse;text-align:left;margin:10px;}\
table th{font-size:14px;font-weight:normal;color:#eee;background-color:#6678b1;\
border:1px solid #ccc;padding:4px 8px;}\
table td{border:1px solid #ccc;color:#669;padding:6px 8px;}\
table tbody tr:hover td{color:#009;background-color:#ccc;}\
tr:nth-child(odd){background-color:#ddd;}\
h4{clear:both;margin:0px;padding:0px 15px;}\
</style>"



OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);
NSString *runQuery(NSString *query, sqlite3 *fdb);
/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */
//NSString *runQuery(NSString *query, sqlite3 *fdb)
//{
//    NSMutableString *html = [[NSMutableString alloc] init];
//    sqlite3_stmt    *statement;
//    NSMutableArray *keys = [[NSMutableArray alloc] init];
//    NSMutableArray *data = [[NSMutableArray alloc] init];
//    
//    //    NSString *query = @"SELECT tbl_name, type FROM sqlite_master";
//    if (sqlite3_prepare_v2(fdb, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
//    {
//        int count = sqlite3_column_count(statement);
//        for(int i=0; i<count; i++)
//        {
//            const char *name = sqlite3_column_name(statement, i);
//            [keys addObject:[[NSString alloc] initWithFormat:@"%s", name]];
//        }
//        
//        while (sqlite3_step(statement) == SQLITE_ROW)
//        {
//            NSMutableArray *row = [[NSMutableArray alloc] init];
//            for(int i=0; i<count; i++)
//            {
//                row[i] = [[NSString alloc] initWithFormat:@"%s", (char *)sqlite3_column_text(statement, i)];
//            }
//            [data addObject:row];
//        }
//        sqlite3_finalize(statement);
//    }
//    
//    [html appendString:@"<table>"];
//    [html appendString:@"<tr>"];
//    for (NSString *str in keys)
//    {
//        [html appendFormat:@"<th>%@</th>", str];
//    }
//    [html appendString:@"</tr>"];
//    
//    
//    for (NSArray *row in data)
//    {
//        [html appendString:@"<tr>"];
//        for (NSArray *cell in row)
//        {
//            [html appendFormat:@"<td>%@</td>", cell];
//        }
//        [html appendString:@"</tr>"];
//    }
//    
//    
//    [html appendString:@"</table>"];
//    
//    return html;
//}

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    printf("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA ");
    NSURL *nsurl = (__bridge NSURL *)url;
    
    sqlite3 *fdb;
    NSString *databasePath = nsurl.path;
    
    [[NSFileManager defaultManager] fileExistsAtPath:databasePath] ? NSLog(@"File Exists") : NSLog(@"File DOES NOT Exists");
    
    const char *dbpath = [databasePath UTF8String];
    
    int ret = sqlite3_open(dbpath, &fdb);
    if (ret == SQLITE_OK)
    {
        NSArray *tables = @[@"sqlite_master"];
//        [tables insertObject:@"sqlite_master" atIndex:0];
        
        NSMutableString *html = [[NSMutableString alloc] init];
        [html appendString:@"<html><head>"CSS_STYLE"</head><body><table>"];
        for (NSString *table in tables)
        {
            NSString *query = runQuery([[NSString alloc] initWithFormat:@"select * from %@ limit 100", table], fdb);
            [html appendFormat:@"<p><h4>%@</h4><div>", table];
            [html appendString:query];
            [html appendString:@"</div></p><br/><br/>"];
        }
        
        [html appendString:@"</body></html>"];
        sqlite3_close(fdb);
        
        CFDictionaryRef properties = (__bridge CFDictionaryRef)@{(NSString *) kQLPreviewPropertyWidthKey: @500, (NSString *)kQLPreviewPropertyWidthKey: @500};
        QLThumbnailRequestSetImageWithData(thumbnail, (__bridge CFDataRef)[html dataUsingEncoding:NSUTF8StringEncoding], properties);
    }
    

    // To complete your generator please implement the function GenerateThumbnailForURL in GenerateThumbnailForURL.c
    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    printf("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");

    // Implement only if supported
}
