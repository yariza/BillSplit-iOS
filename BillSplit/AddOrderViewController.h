//
//  AddOrderViewController.h
//  BillSplit
//
//  Created by Yujin Ariza on 2/7/14.
//  Copyright (c) 2014 Yujin Ariza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddOrderViewController : UITableViewController<UIPickerViewDataSource, UIPickerViewDelegate>


@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *price;
@property (weak, nonatomic) IBOutlet UIPickerView *ownerPicker;

@end
