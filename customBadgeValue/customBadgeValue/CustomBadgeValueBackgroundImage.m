//
//  CustomBadgeValueBackgroundImage.m
//  customTabbarItemBadgeValue
//
//  Created by 边智峰 on 15/7/22.
//  Copyright (c) 2015年 边智峰. All rights reserved.
//

#import "CustomBadgeValueBackgroundImage.h"
#import <objc/runtime.h>

@implementation CustomBadgeValueBackgroundImage

//判断层级可以在Debug view hierarchy中看到tabbar的层级结构

-(void)setBadgeValue:(NSString *)badgeValue{
    
    [super setBadgeValue:badgeValue];
    
    if(!badgeValue){
        
        return;
    }
    
    //根据UITabbarItem中的私有属性_target 来获取当前自定义tabbarItem的控制器
    //通过kvc获取私有属性
    UITabBarController *tabbarCtrl = [self valueForKeyPath:@"_target"];
    //    NSLog(@"%@",[self valueForKeyPath:@"_target"]);
    //    获取当前控制器的tabbar 取出来的肯定是自定义的tababr 所以强转 接收
    //    因为在自定义tabbarController中设置了每个控制器的tabbaritem都为当前自定义的
#warning  此处为获取当前控制器使用tabbar 根据控制器实际使用的tabbar为系统or自定义的来设置获取
    UITabBar *tabbar = (UITabBar *)tabbarCtrl.tabBar;
    //判断 遍历tabbar.subviews里面取出其子控件 判断其类型
    for (UIView *oneChildView in tabbar.subviews) {
        //根据图 往下判断
        if([oneChildView isKindOfClass:NSClassFromString(@"UITabBarButton")]){
            for (UIView *twoChildView in oneChildView.subviews) {
                if([twoChildView isKindOfClass:NSClassFromString(@"_UIBadgeView")]){
                    for (UIView *threeChildView in twoChildView.subviews) {
                        if([threeChildView isKindOfClass:NSClassFromString(@"_UIBadgeBackground")]){
                            //系统的属性看不到 不能够改变badge的一些属性 所以需要使用运行时 动态获取属性
                            Class class = [threeChildView class];
                            unsigned int outCount;
                            //设置运行时 动态获取类的属性
                            //取出class中对应的成员列表
                            Ivar *ivars = class_copyIvarList(class, &outCount);
                            //根据获取的成员列表的outcount来遍历属性
                            for (int i = 0; i < outCount; i++) {
                                //根据i来取属性
                                Ivar ivar = ivars[i];
                                //取出属性名 取出的属性名为const char * 类型 转换成oc字符串
                                NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
                                //取出属性类型
                                NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
                                
                                NSLog(@"ivarName=%@ ivarType=%@",ivarName,ivarType);
                                
                                //判断是不是我们想要的_image属性
                                if ([ivarName isEqualToString:@"_image"]) {
                                    //此处为需要设置的badgeValue的背景图片
                                    UIImage *badgeImage = [UIImage imageNamed:@"想要设置的图片名称"];;
                                    
                                    //设置
                                    [threeChildView setValue:badgeImage forKeyPath:ivarName];
                                    
                                }
                                
                            }
                            free(ivars);
                            
                        }
                    }
                    
                }
            }
            
        }
    }
    
}

@end
