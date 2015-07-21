
#import "Message.h"

@implementation Message

- (void)setDict:(NSDictionary *)dict{
    
    _dict = dict;
    NSString * date = dict[@"time"];
    date = [date substringToIndex:19];
    NSString * phoneNum = dict[@"USERNAME"];
    phoneNum = [phoneNum substringFromIndex:7];
    
    self.icon = dict[@"icon"];
    self.time = date;
    self.content = dict[@"content"];
    self.type = [dict[@"type"] intValue];
    self.phone = phoneNum;
}



@end
