//
//  ViewController.h
//  BillSplit
//
//  Created by Yujin Ariza on 2/2/14.
//  Copyright (c) 2014 Yujin Ariza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollapsableTableViewDelegate.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CollapsableTableViewDelegate>
@property (weak, nonatomic) IBOutlet CollapsableTableView *table;

@end
