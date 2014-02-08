//
//  NSMutableArray+QueueAdditions.h
//  BillSplit
//
//  Created by Yujin Ariza on 2/7/14.
//  Copyright (c) 2014 Yujin Ariza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueAdditions)

- (id) dequeue;
- (void) enqueue:(id)obj;

@end
