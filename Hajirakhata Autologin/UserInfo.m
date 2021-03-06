//
//  UserInfo.m
//  ArchivingTest
//
//  Created by Mujtahid Akon on 5/12/17.
//  Copyright © 2017 Mujtahid Akon. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

- (void) printData{
    NSLog(@"Username: %@\nPassword: %@\n", self.username, self.password);
}

+ (void) writeData{
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *fileURL = [[urls lastObject] URLByAppendingPathComponent:@"info.data"];
    NSLog(@"%@", fileURL.path);
    
    NSLog(@"Writing object to file");
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    //standard class
    [items addObject:@"Hello"];
    [items addObject:[NSDate date]];
    [items addObject:[NSNumber numberWithInt:100]];
    
    //custom class
    UserInfo *info = [[UserInfo alloc]init];
    info.username = @"mujtahid";
    info.password = @"pass";
    [items addObject:info];
    
    //write to file
    NSData *fileData = [NSKeyedArchiver archivedDataWithRootObject:items];
    [fileData writeToURL:fileURL atomically:YES];
    NSLog(@"Data written successfully");
}

+ (UserInfo*) readData{//returns (Userinfo*)
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *fileURL = [[urls lastObject] URLByAppendingPathComponent:@"info.data"];
    NSLog(@"%@", fileURL.path);
    
    NSLog(@"Reading data from file");
    NSData *fileData = [NSData dataWithContentsOfFile:fileURL.path];
    NSMutableArray *items = [NSKeyedUnarchiver unarchiveObjectWithData:fileData];
    return [items firstObject];
}
+ (void) writeUsername:(NSString*) username password: (NSString*) password andLastLoginDate:(NSDate *)lastLoginDate{
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *fileURL = [[urls lastObject] URLByAppendingPathComponent:@"info.data"];
    NSLog(@"%@", fileURL.path);
    
    NSLog(@"Writing object to file...");
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    //custom class
    UserInfo *info = [[UserInfo alloc]init];
    info.username = username;
    info.password = password;
    info.lastLoginDate = lastLoginDate;
    [items addObject:info];
    
    //write to file
    NSData *fileData = [NSKeyedArchiver archivedDataWithRootObject:items];
    [fileData writeToURL:fileURL atomically:YES];
    NSLog(@"Data written successfully.");
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.password forKey:@"password"];
    [aCoder encodeObject:self.lastLoginDate forKey:@"lastLoginDate"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.password = [aDecoder decodeObjectForKey:@"password"];
        self.lastLoginDate = [aDecoder decodeObjectForKey:@"lastLoginDate"];
    }
    return self;
}

@end
