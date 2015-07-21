//
//  MessageCell.h
//  EmojiTest
//
//  Created by mac on 15/6/15.
//  Copyright (c) 2015年 wwr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface MessageCell : UITableViewCell

@property (nonatomic, strong) UIImageView *cellView;

-(void)setCellContentWith:(Message *)message;

@end
