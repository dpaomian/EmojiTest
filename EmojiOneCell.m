//
//  EmojiOneCell.m
//  EmojiTest
//
//  Created by mac on 15/7/13.
//  Copyright (c) 2015年 wwr. All rights reserved.
//

#define kContentW SCREEN_WIDTH-140 //内容宽度

#define BEGIN_FLAG @"["
#define END_FLAG @"]"

#define KFacialSizeWidth  20
#define KFacialSizeHeight 20
#define MAX_WIDTH  SCREEN_WIDTH - 160

//屏幕尺寸
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width) //屏幕宽度
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height) //屏幕高度


#import "EmojiOneCell.h"
#import "RegexKitLite.h"

@interface EmojiOneCell()
{
    UIImageView *_headImageView;
    UILabel     *_nameLabel;
    
    UITextView  *_contentTextView;
    UILabel     *_timeLabel;
}

@end

@implementation EmojiOneCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        //内容label
        self.cellView = [[UIImageView alloc] init];
        [self addSubview:self.cellView];
        
        //内容label
        _contentTextView = [[UITextView alloc]init];
        _contentTextView.backgroundColor = [UIColor clearColor];
        [self.cellView addSubview:_contentTextView];
        
        
        //图片ImageView
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.clipsToBounds = YES;
        [self.contentView addSubview:_headImageView];
        
        //nameLabel
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _headImageView.frame.size.height+_headImageView.frame.origin.y, 50, 20)];
        _nameLabel.font = [UIFont systemFontOfSize:12];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.frame.size.width - 10 , 30)];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_timeLabel];
        
        
    }
    return self;
}

-(void)setCellContentWith:(Message *)message
{
    //头像内容
    if (message.icon.length == 0)
    {
        _headImageView.image = [UIImage imageNamed:@"center-logo"];
    }
    else
    {
        //程序里需解注释
        //[_headImageView sd_setImageWithURL:[NSURL URLWithString:message.icon]];
    }
    
    _nameLabel.text = message.phone;
    _timeLabel.text = message.time;
    

    UITextView *returnView =  [self assembleMessageAtIndex:message.content];
    CGSize useSize = CGSizeMake(returnView.frame.size.width, returnView.frame.size.height);
    _contentTextView.attributedText = returnView.attributedText;
    
    //修改位置
    if (message.type == MessageTypeMe)
    {
        //右侧
        _headImageView.frame = CGRectMake(SCREEN_WIDTH-50, 0, 40, 40);
        _nameLabel.frame = CGRectMake(SCREEN_WIDTH-60, _headImageView.frame.size.height+_headImageView.frame.origin.y+5, 60, 20);
        
        _contentTextView.frame = CGRectMake(0, 0, useSize.width, useSize.height);
        
        self.cellView.frame = CGRectMake(SCREEN_WIDTH-60-(useSize.width+20), 0, useSize.width+15, useSize.height+5);
        self.cellView.image = [UIImage imageNamed:@"liuyan-bg2.png"];
        self.cellView.image = [self.cellView.image stretchableImageWithLeftCapWidth:self.cellView.image.size.width * 0.5 topCapHeight:self.cellView.image.size.height * 0.7];
        
        _timeLabel.frame = CGRectMake(0, self.cellView.frame.size.height+self.cellView.frame.origin.y+5, SCREEN_WIDTH-70, 20);
        _timeLabel.textAlignment = NSTextAlignmentRight;
        
    }
    else
    {
        //左侧
        _headImageView.frame = CGRectMake(10, 0, 40, 40);
        _nameLabel.frame = CGRectMake(0, _headImageView.frame.size.height+_headImageView.frame.origin.y+5, 60, 20);
        
        _contentTextView.frame = CGRectMake(10, 0, useSize.width, useSize.height);
        
        self.cellView.frame = CGRectMake(60, 0, useSize.width+10, useSize.height+5);
        self.cellView.image = [UIImage imageNamed:@"liuyan-bg1.png"];
        self.cellView.image = [self.cellView.image stretchableImageWithLeftCapWidth:self.cellView.image.size.width * 0.5 topCapHeight:self.cellView.image.size.height * 0.7];
        
        _timeLabel.frame = CGRectMake(70, self.cellView.frame.size.height+self.cellView.frame.origin.y+5, SCREEN_WIDTH-70, 20);
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        
    }
    
}

#pragma mark -
#pragma mark 图文混排

//图文混排
-(void)getImageRange:(NSString*)message andMutableArray:(NSMutableArray*)array
{
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0)
    {
        if (range.location > 0)
        {
            NSString *str;
            if (range1.location > range.location)
            {
                if (range1.location - range.location > 6)
                {
                    NSString *beginS = [message substringWithRange:NSMakeRange(range1.location - 6 + 1, 1)];
                    if ([beginS isEqualToString:BEGIN_FLAG])
                    {
                        [array addObject:[message substringToIndex:range1.location - 6 + 1 ]];
                        str = [message substringFromIndex:range1.location - 6 + 1];
                    }
                    else
                    {
                        [array addObject:[message substringToIndex:range1.location + 1]];
                        str = [message substringFromIndex:range1.location + 1];
                    }
                }
                else
                {
                    [array addObject:[message substringToIndex:range.location]];
                    [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
                    str = [message substringFromIndex:range1.location+1];
                }
            }
            else
            {
                [array addObject:[message substringToIndex:range1.location + 1]];
                str = [message substringFromIndex:range1.location+1];
            }
            [self getImageRange:str andMutableArray:array];
        }
        else
        {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""])
            {
                NSString *str;
                if (range1.location - range.location > 6)
                {
                    NSString *beginS = [message substringWithRange:NSMakeRange(range1.location - 6 + 1, 1)];
                    if ([beginS isEqualToString:BEGIN_FLAG])
                    {
                        [array addObject:[message substringToIndex:range1.location - 6 + 1 ]];
                        str = [message substringFromIndex:range1.location - 6 + 1];
                    }
                    else
                    {
                        [array addObject:[message substringToIndex:range1.location + 1]];
                        str = [message substringFromIndex:range1.location + 1];
                    }
                }
                else
                {
                    //                    [array addObject:[message substringToIndex:range.location]];
                    [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
                    str = [message substringFromIndex:range1.location+1];
                }
                [self getImageRange:str andMutableArray:array];
            }
            else
            {
                return;
            }
        }
        
    }
    else if (message != nil)
    {
        [array addObject:message];
    }
}

-(UITextView *)assembleMessageAtIndex:(NSString *)message
{
    NSLog(@"走次数");
    
    NSMutableAttributedString *useAttrMessage = [[NSMutableAttributedString alloc]init];
    
    //表情字典
    NSString *expressionPlist = [[NSBundle mainBundle] pathForResource:@"expression2" ofType:@"plist"];
    NSDictionary *expressionDic = [[NSDictionary alloc] initWithContentsOfFile:expressionPlist];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [self getImageRange:message andMutableArray:array];
    
    UITextView *returnUseView = [[UITextView alloc] initWithFrame:CGRectZero];
    NSArray *data = array;
    UIFont *fon = [UIFont systemFontOfSize:15];
    returnUseView.font = fon;
    CGFloat allWidth = 0;
    CGFloat upWidth = 0;
    CGFloat width = 0;
    CGFloat height = 0;
    if (data)
    {
        for (int i=0;i < [data count];i++)
        {
            NSString *str=[data objectAtIndex:i];
            //从字典中找到[f001];
            NSString *useStr = [expressionDic objectForKey:str];
            if (useStr.length>0)
            {
                NSString *imageName=[str substringWithRange:NSMakeRange(1, str.length - 2)];
                imageName = [NSString stringWithFormat:@"%@.png",imageName];
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc]init];//添加附件,图片
                textAttachment.image = [UIImage imageNamed:imageName];
                textAttachment.bounds = CGRectMake(0, -5, KFacialSizeWidth, KFacialSizeWidth);
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                [useAttrMessage appendAttributedString:imageStr];
                
                allWidth = KFacialSizeWidth+allWidth;
                
                upWidth=KFacialSizeWidth+upWidth;
                if (allWidth<MAX_WIDTH)
                {
                    width = upWidth;
                    height = KFacialSizeHeight+10;
                }
                else
                {
                    width = MAX_WIDTH;
                    int tempAllWidth = allWidth;
                    int tempMaxWidth = MAX_WIDTH;
                    int tempYu = tempAllWidth%tempMaxWidth;
                    int tempChu = tempAllWidth/tempMaxWidth;
                    double tempDoubleChu = (double) tempAllWidth/tempMaxWidth;
                    NSLog(@"除值 图片  除＝%d  double除= %.2f 余＝%d 最大宽度=%d 总宽度=%d",tempChu,tempDoubleChu,tempYu,tempMaxWidth,tempAllWidth);
                    
                    if (tempYu>0)
                    {
                        height = KFacialSizeHeight*(tempDoubleChu+1);
                    }
                    else
                    {
                        height = KFacialSizeHeight*tempDoubleChu;
                    }
                }
            }
            else
            {
                for (int j = 0; j < [str length]; j++)
                {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    NSString *tempStr;
                    if (j<str.length-1)
                    {
                        tempStr = [str substringWithRange:NSMakeRange(j, 2)];
                        if ([self stringContainsEmoji:tempStr]==YES)
                        {
                            temp = tempStr;
                            j++;
                        }
                    }
                    
                    CGSize size = CGSizeMake(0.0f, 0.0f);
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
                    size = [temp sizeWithFont:fon constrainedToSize:CGSizeMake(MAX_WIDTH, 20)];
#else
                    NSDictionary *attributesDic = @{NSFontAttributeName:fon};
                    size = [temp boundingRectWithSize:CGSizeMake(MAX_WIDTH, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDic context:nil].size;
#endif
                    NSDictionary *fontDic = [NSDictionary dictionaryWithObject:fon forKey:NSFontAttributeName];
                    NSAttributedString *useStr = [[NSAttributedString alloc]initWithString:temp attributes:fontDic];
                    [useAttrMessage appendAttributedString:useStr];
                   
                    allWidth = size.width+allWidth;
                    
                    upWidth = upWidth+size.width;
                    if (allWidth<MAX_WIDTH)
                    {
                        width = upWidth+10;
                        height = KFacialSizeHeight+10;
                    }
                    else
                    {
                        width = MAX_WIDTH;
                        int tempAllWidth = allWidth;
                        int tempMaxWidth = MAX_WIDTH;
                        int tempYu = tempAllWidth%tempMaxWidth;
                        int tempChu = tempAllWidth/tempMaxWidth;
                        double tempDoubleChu = (double) tempAllWidth/tempMaxWidth;
                        NSLog(@"除值 值  除＝%d  double除= %.2f 余＝%d 最大宽度=%d 总宽度=%d",tempChu,tempDoubleChu,tempYu,tempMaxWidth,tempAllWidth);
                        if (tempYu>0)
                        {
                            height =KFacialSizeHeight*(tempDoubleChu+1);
                        }
                        else
                        {
                            height =KFacialSizeHeight*tempDoubleChu;
                        }
                    }
                }
            }
        }
    }
    
    returnUseView.frame = CGRectMake(0,0, width, height); //@ 需要将该view的尺寸记下，方便以后使用
    returnUseView.attributedText = useAttrMessage;
    
    NSLog(@"allWidth = %.1f %.1f 高 ＝ %.1f", allWidth ,width, height );
    
    return returnUseView;
}

-(BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
     {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff)
         {
             if (substring.length > 1)
             {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f)
                 {
                     returnValue = YES;
                 }
             }
         }
         else if (substring.length > 1)
         {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3)
             {
                 returnValue = YES;
             }
             
         }
         else
         {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff)
             {
                 returnValue = YES;
             }
             else if (0x2B05 <= hs && hs <= 0x2b07)
             {
                 returnValue = YES;
             }
             else if (0x2934 <= hs && hs <= 0x2935)
             {
                 returnValue = YES;
             }
             else if (0x3297 <= hs && hs <= 0x3299)
             {
                 returnValue = YES;
             }
             else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50)
             {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
