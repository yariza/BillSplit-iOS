//
//  OrdersViewController.h
//  BillSplit
//
//  Created by Yujin Ariza on 2/6/14.
//  Copyright (c) 2014 Yujin Ariza. All rights reserved.
//

#import "ViewController.h"

@interface OrdersViewController : ViewController <UITableViewDelegate, UITableViewDataSource, CollapsableTableViewDelegate>

@property (weak, nonatomic) IBOutlet CollapsableTableView *table;

-(void) addOrder:(NSString*)name price:(NSDecimalNumber*)price owner:(NSString*)ownerID;
@end
