//
//  GameBoard.m
//  Cocos2DSimpleGame
//
//  Created by JIAYU ZENG on 6/25/15.
//  Copyright 2015 Razeware LLC. All rights reserved.
//

#import "GameBoard.h"


@implementation GameBoard



enum{
    empty = 0,
    opponment = -1,
    player = 1
};

-(id)init:(CGSize)winSize{
    
    self->_gameBoard = [[NSMutableDictionary alloc] init];
    self->BOARD_SIZE = 8;
    
    CCSprite *emptySlot = [CCSprite spriteWithFile:@"slot.png"];
    
    int slotWidth = [emptySlot boundingBox].size.width;
    int slotHeight = [emptySlot boundingBox].size.height;
    
    for (int row = 0; row < BOARD_SIZE; row++ ){
        
        for ( int col = 0; col < BOARD_SIZE; col++){
            CCSprite *emptySlot = [CCSprite spriteWithFile:@"slot.png"
                                                      rect:CGRectMake(0, 0, 25, 25)];
            // Should be an ID
            emptySlot.tag = empty;
            
            // the x, y position is the center of that object,
            // if I do want to place them in "center" center,
            // need to plus half the the width theoratically
            
            float boardOriX = winSize.width/4;
            emptySlot.position = ccp(boardOriX+(col+1)*slotWidth, (row+1)*slotHeight);
            
            NSString *coor = [self toTupleFrom:col andY:row];
            
            // add to the mutable array
            [_gameBoard setObject:emptySlot forKey:coor];
            
            // add to layer/canvas
            
        }
    }

    
    return self;
}

- (id)initWithGame:(GameBoard*)game{
    //_gameBoard = [[NSMutableDictionary alloc] init];
    self->BOARD_SIZE = [game getBoardSize];
    self->_gameBoard = [[game getGameBoard] mutableCopy];
    
    return self;
}

/* ====================================
 
 checkWin function checks if the current player wins after placing a piece,
 Pre: placedX: the x coordination of the placed piece
 placedY: the y coordination of the placed piece
 whosTurn: the tag of current player
 Post: return true if the current player connects N pieces
 
 ==================================== */
- (bool) checkWin:(int)placedX and:(int)placedY with:(NSInteger)whosTurn{
    // hor ver dia
    int horConnected = 0, verConnected = 0, leftTopRightBotConnected = 0, leftBotRightTopConnected = 0;
    int connectN = 4;
    
    CCSprite *oneSlot = nil;
    
    for (int leftToRightRange = (-1*connectN)+1; leftToRightRange < connectN; leftToRightRange++){
        
        // horizontal
        NSString* horKey = [self toTupleFrom:leftToRightRange + placedX andY:placedY];
        if ( [_gameBoard objectForKey:horKey] != nil){
            oneSlot = _gameBoard[horKey];
            
            
            horConnected = (oneSlot.tag == whosTurn)? horConnected+1 :0;
            if (horConnected == connectN) return true;
        }
        
        // vertical
        NSString* verKey = [self toTupleFrom:placedX andY:leftToRightRange+placedY];
        if ( [_gameBoard objectForKey:verKey] != nil){
            oneSlot = _gameBoard[verKey];
            
            
            verConnected = (oneSlot.tag == whosTurn)? verConnected+1 :0;
            if (verConnected == connectN) return true;
            
        }
        
        // dia left top to right bot
        NSString* fromLeftTopKey = [self toTupleFrom:
                                    leftToRightRange + placedX andY: (-1)*leftToRightRange+placedY];
        if ( [_gameBoard objectForKey:fromLeftTopKey] != nil){
            oneSlot = _gameBoard[fromLeftTopKey];
            
            
            leftTopRightBotConnected = (oneSlot.tag == whosTurn)? leftTopRightBotConnected + 1 : 0;
            if (leftTopRightBotConnected == connectN) return true;
            
        }
        
        // dia left bot to right top
        NSString* fromLeftBotKey = [self toTupleFrom:
                                    leftToRightRange + placedX andY: leftToRightRange + placedY];
        if ( [_gameBoard objectForKey:fromLeftBotKey] != nil){
            oneSlot = _gameBoard[fromLeftBotKey];
            
            leftBotRightTopConnected = (oneSlot.tag == whosTurn)? leftBotRightTopConnected + 1 : 0;
            
            if (leftBotRightTopConnected  == connectN) return true;
            
        }
        
    }
    
    return false;
}

/* ====================================
 
 toTupleFrom returns the string as key for the _gameBoard dictionary
 Pre: x: the x coordination of a slot
 y: the y coordination of a slot
 
 Post: return a string (x,y) as key
 ==================================== */
- (NSString*) toTupleFrom:(int)x andY: (int)y{
    return [ NSString stringWithFormat: @"(%d,%d)", x, y];
}

/* ====================================
 getYFromKey parses the string to x and y value
 Pre: key: an id or a string that is a key in _gameBoard dictionary
 Post: return the y value
 ==================================== */
- (int) getYFromKey:(id)key{
    NSString *tuple = (NSString*)key;
    NSString * yChar = [tuple substringWithRange:NSMakeRange(3, 1)];
    int y = [yChar intValue];
    
    return y;
};
/* ====================================
 getXFromKey parses the string to x and y value
 Pre: key: an id or a string that is a key in _gameBoard dictionary
 Post: return the x value
 ==================================== */
- (int) getXFromKey:(id)key{
    NSString *tuple = (NSString*)key;
    NSString * xChar = [tuple substringWithRange:NSMakeRange(1, 1)];
    int x = [xChar intValue];
    
    return x;
};

/* ====================================
 getXFromKey parses the string to x and y value
 Pre: key: an id or a string that is a key in _gameBoard dictionary
 Post: return the x value
 ==================================== */
- (NSInteger) getNextSlotTag:(int)x and: (int)y{
    
    CCSprite *lowerSlot;
    
    if (y > 0){
        y -= 1;
        NSString* lowerCoor =  [self toTupleFrom:x andY:y];
        lowerSlot = _gameBoard[lowerCoor];
        return lowerSlot.tag;
    }
    else{
        NSInteger none = -99;
        return none;
    }
}

- (CCSprite*) getSlotFrom:(int)x and: (int)y{
    NSString *key = [self toTupleFrom:x andY:y];
    CCSprite* oneSlot = _gameBoard[key];
    
    return oneSlot;
}


-(NSMutableDictionary*)getGameBoard{
    return self->_gameBoard;
    
}

-(int)getBoardSize{
    return self->BOARD_SIZE;
}

-(void)dealloc{
    [_gameBoard release];
    _gameBoard = nil;
    
    [super dealloc];
}

@end
