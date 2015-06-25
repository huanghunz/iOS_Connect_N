//
//  CCGameBoard.h
//  Cocos2DSimpleGame
//
//  Created by JIAYU ZENG on 6/22/15.
//  Copyright 2015 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCGameBoard : CCNode {
    NSMutableDictionary *gameNodes;
    
    
    
    
    
    
}

- (int)getSlotStateFrom:(int)x andY:(int)y;

- (NSString*) toStringFrom:(int)x andY: (int)y;


@end
