
#import <Foundation/Foundation.h>

@interface NSData (AES128)

-(NSData*)AES128DecryptWithKey:(NSString*)key;

-(NSData*)AES128EncryptWithKey:(NSString*)key;

+(NSData*)dataFromHexString:(NSString*)hexString;

+(NSString*)hexStringFromData:(NSData*)data;

@end
