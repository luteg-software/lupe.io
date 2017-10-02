//
//  LTGFileInfo.h
//  Connect
//
//  Created by Fatih YASAR on 13/12/2016.
//  Copyright © 2016 Luteg Software Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LTGFileInfo : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *filePath;
@property(nonatomic, strong) NSNumber *size;
@property(nonatomic, strong) NSString *type;

@end
