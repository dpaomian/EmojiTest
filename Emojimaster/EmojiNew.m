//
//  EmojiNew.m
//  xuexin
//
//  Created by julong on 14-5-28.
//  Copyright (c) 2014年 mx. All rights reserved.
//

#import "EmojiNew.h"

@implementation EmojiNew

+ (NSString *)emojiWithCode:(int)code
{
    return nil;
}

+ (NSArray *)allEmoji
{
    NSMutableArray *array = [NSMutableArray new];
    for (int i=0; i<71; i++)
    {
        NSString *emojiStr;
        if (i<10)
        {
            emojiStr = [NSString stringWithFormat:@"[f00%d]",i];
        }
        else if (i>9&&i<100)
        {
            emojiStr = [NSString stringWithFormat:@"[f0%d]",i];
        }
        else
        {
            emojiStr = [NSString stringWithFormat:@"[f%d]",i];
        }
        [array addObject:emojiStr];
    }
    return array;
}

@end
