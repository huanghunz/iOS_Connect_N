//
//  GameBoard.m
//  Cocos2DSimpleGame
//
//  Created by JIAYU ZENG on 6/22/15.
//  Copyright 2015 Razeware LLC. All rights reserved.
//

#import "GameBoard.h"


@implementation GameBoard: NSObject


-(void)initDict{
    int BOARD_SIZE = 8;
    
    gameNodes = [[NSMutableDictionary alloc] init];
    
    for (int col = 1; col <= BOARD_SIZE; col++){
        for (int row = 1; row <= BOARD_SIZE; row++){
            NSString *coor = [self toStringFrom:col andY:row];
            
            CCSprite *emptySlot = [CCSprite spriteWithFile:@"slot.png"
                                          rect:CGRectMake(0, 0, 25, 25)];
            // Should be an ID
            emptySlot.tag = "E";

            // the x, y position is the center of that object,
            // if I do want to place them in "center" center, need to plus half the the width, theoratically
            //emptySlot.position = ccp(boardOriX+j*slotWidth, boardOriY+i*slotHeight);


            // add to the mutable array
           // [_emptySlots addObject: emptySlot];
            [gameNodes setObject:emptySlot forKey:coor];

            // add to layer/canvas
           // [ self addChild: emptySlot];
            
                    
        }
    }
            
}

- (int)getSlotStateFrom:(int)x andY:(int)y{
    return  0;
}

- (NSString*) toStringFrom:(int)x andY: (int)y{
    
    NSString *coor = [ NSString stringWithFormat: @"(%d,%d)",x, y];
    
    return coor;
}

@end
