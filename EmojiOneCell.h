//
//  EmojiOneCell.h
//  EmojiTest
//
//  Created by mac on 15/7/13.
//  Copyright (c) 2015年 wwr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface EmojiOneCell : UITableViewCell

@property (nonatomic, strong) UIImageView *cellView;

-(void)setCellContentWith:(Message *)message;

@end
