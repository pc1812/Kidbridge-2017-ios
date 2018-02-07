//
//  MineAddressCell.h
//  Picturebooks
//
//  Created by jixiaoodong on 2017/12/19.
//  Copyright © 2017年 ZhiyuanNetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MineAddressCell : UITableViewCell
/** 联系人 */
@property (nonatomic,copy) NSString *nameStr;
/** 手机号 */
@property (nonatomic,copy) NSString *phoneStr;
/** 收货地址 */
@property (nonatomic,copy) NSString *detialStr;
@end
