//
//  GameBoard.h
//  Cocos2DSimpleGame
//
//  Created by JIAYU ZENG on 6/22/15.
//  Copyright 2015 Razeware LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

//extern int const BOARD_SIZE;
//int const BOARD_SIZE = 8;

@interface GameBoard : NSObject {
    
    @public NSMutableDictionary *gameNodes;
    
}

- (void) initDict;
- (int)getSlotStateFrom:(int)x andY:(int)y;

- (NSString*) toStringFrom:(int)x andY: (int)y;


@end
