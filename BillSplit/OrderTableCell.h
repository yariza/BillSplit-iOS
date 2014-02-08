//
//  OrderTableCell.h
//  BillSplit
//
//  Created by Yujin Ariza on 2/7/14.
//  Copyright (c) 2014 Yujin Ariza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *owner;
@property (weak, nonatomic) IBOutlet UILabel *price;

@end
