//
//  GameBoard.m
//  Cocos2DSimpleGame
//
//  Created by JIAYU ZENG on 6/25/15.
//  Copyright 2015 Razeware LLC. All rights reserved.
//

#import "GameBoard.h"


@implementation GameBoard



-(id)init:(CGSize)winSize{
    
    self->_gameBoard = [[NSMutableDictionary alloc] init];
    self->BOARD_SIZE = 8;
    self->playersTurn = true;
    
    CCSprite *emptySlot = [CCSprite spriteWithFile:@"slot.png"];
    
    int slotWidth = [emptySlot boundingBox].size.width;
    int slotHeight = [emptySlot boundingBox].size.height;
    
    for (int row = 0; row < BOARD_SIZE; row++ ){
        
        for ( int col = 0; col < BOARD_SIZE; col++){
            CCSprite *emptySlot = [CCSprite spriteWithFile:@"slot.png"
                                                      rect:CGRectMake(0, 0, 25, 25)];
            // Should be an ID
            emptySlot.tag = empty;
            
            // the x, y position is the center of that object, // if I do want to place them in "center" center, // need to plus half the the width theoratically
            
            float boardOriX = winSize.width/4;
            emptySlot.position = ccp(boardOriX+(col+1)*slotWidth, (row+1)*slotHeight);
            
            NSString *coor = [self toTupleFrom:col andY:row];
            
            // add to the mutable dictionary
            [self->_gameBoard setObject:emptySlot forKey:coor];
            
        }
    }

    
    return self;
}

- (GameBoard*)makeGameCopy:(GameBoard*)game{
    
    GameBoard *copy = [GameBoard alloc];
  
    copy->BOARD_SIZE = [game getBoardSize];
    
    copy->_gameBoard = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *originBoard = [game getGameBoard];
    
    for (id key in originBoard ){
        CCSprite *oneSlot = [CCSprite spriteWithFile:@"slot.png"
                                                rect:CGRectMake(0, 0, 25, 25)];
        CCSprite *originSlot = originBoard[key];
        
        oneSlot.tag = originSlot.tag;
        [copy->_gameBoard setObject:oneSlot forKey:key];
        
    }
    copy->playersTurn = [game isPlayerTurn];
    
    return copy;
}

-(bool)isPlayerTurn{
    return self->playersTurn;
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
-(CCSprite*) getSlotFromKey:(id)key{ return  _gameBoard[key]; }
-(NSMutableDictionary*)getGameBoard{ return self->_gameBoard; }




-(int)getBoardSize{ return self->BOARD_SIZE; }

-(void)dealloc{
    [_gameBoard release];
    _gameBoard = nil;
    
    [super dealloc];
}

-(void)applyAction:(int)targetCol and:(int)targetRow{
    
    NSString *targetCoor = [ self toTupleFrom:targetCol andY:targetRow];
    CCSprite *targetSlot = _gameBoard[targetCoor];
    
    NSLog(@"==== before assign: %d", targetSlot.tag);
    targetSlot.tag = playersTurn?player: opponment;
    NSLog(@"---- after assign: %d", targetSlot.tag);
    playersTurn = !playersTurn;

    
}
-(void)applyAction:(CCSprite*)targetSlot{
    NSLog(@"==== before assign: %d", targetSlot.tag);
    targetSlot.tag = playersTurn? player: opponment;
    
    if (playersTurn){
        targetSlot.tag = player;
    }
    else{
        targetSlot.tag = opponment;
    }
    NSLog(@"---- after assign: %d", targetSlot.tag);
    playersTurn = !playersTurn;
    if (playersTurn){
        NSLog(@"yes");
    }
    
}

- (NSMutableArray* )getAvailableSlots{
    
    int boardSize = self->BOARD_SIZE;
    NSMutableArray *availableSlots = [[NSMutableArray alloc] init];
    
    //CCSprite* oneSlot = nil;
    for (int col = 0; col < boardSize; col++){
        int emptyRow = 0;
        
        while ([self getSlotFrom:col and:emptyRow].tag != empty
               && emptyRow != boardSize){
            emptyRow++;
        }
        
        if (emptyRow != boardSize){
            NSString *key = [self toTupleFrom:col andY:emptyRow];
            [availableSlots addObject:(NSString*)key];
        }
    }
    
    return  availableSlots;
}

- (int) evaluateState:(int)placedX andY:(int)placedY of:(NSInteger) whosTurn{
    int horConnected = 0, verConnected = 0, leftTopRightBotConnected = 0, leftBotRightTopConnected = 0;
    int horAvailable = 0, verAvailable = 0, leftTopRightBotAvailable = 0, leftBotRightTopAvailable = 0;
   // int horEnemy = 0, verEnemy = 0, leftTopEnemy =0, leftBotEnemy = 0;
    
    int connectN = 4;
    
    NSInteger oppsitePlayer = (whosTurn == player)?opponment:player;
    
    CCSprite *oneSlot = nil;
    
    for (int leftToRightRange = (-1*connectN)+1; leftToRightRange < connectN; leftToRightRange++){
        
        // horizontal
        NSString* horKey = [self toTupleFrom:leftToRightRange + placedX andY:placedY];
        if ( [_gameBoard objectForKey:horKey] != nil){
            oneSlot = _gameBoard[horKey];
            
            
            horConnected = (oneSlot.tag == whosTurn)? horConnected+2 :0;
            if (horConnected == connectN) return 999;
            
            
            horAvailable = (oneSlot.tag != oppsitePlayer)? horAvailable+1 :0;
        }
        
        // vertical
        NSString* verKey = [self toTupleFrom:placedX andY:leftToRightRange+placedY];
        if ( [_gameBoard objectForKey:verKey] != nil){
            oneSlot = _gameBoard[verKey];
            
            
            verConnected = (oneSlot.tag == whosTurn)? verConnected+2 : 0;
            if (verConnected == connectN) return 999;
            
            verAvailable = (oneSlot.tag != oppsitePlayer)? verAvailable+1 : 0;
            
        }
        
        // dia left top to right bot
        NSString* fromLeftTopKey = [self toTupleFrom:
                                    leftToRightRange + placedX andY: (-1)*leftToRightRange+placedY];
        if ( [_gameBoard objectForKey:fromLeftTopKey] != nil){
            oneSlot = _gameBoard[fromLeftTopKey];
            
            
            leftTopRightBotConnected = (oneSlot.tag == whosTurn)? leftTopRightBotConnected + 2 : 0;
            if (leftTopRightBotConnected == connectN) return 999;
            
            leftTopRightBotAvailable = (oneSlot.tag != oppsitePlayer)? leftTopRightBotAvailable+1 : 0;
            
        }
        
        // dia left bot to right top
        NSString* fromLeftBotKey = [self toTupleFrom:
                                    leftToRightRange + placedX andY: leftToRightRange + placedY];
        if ( [_gameBoard objectForKey:fromLeftBotKey] != nil){
            oneSlot = _gameBoard[fromLeftBotKey];
            
            leftBotRightTopConnected = (oneSlot.tag == whosTurn)? leftBotRightTopConnected + 2 : 0;
            
            if (leftBotRightTopConnected  == connectN) return 999;
            
            leftBotRightTopAvailable = (oneSlot.tag != oppsitePlayer)? leftBotRightTopAvailable+1 : 0;
            
        }
        
    }
    
    return horConnected + horAvailable + verConnected + verAvailable + leftTopRightBotConnected + leftTopRightBotAvailable + leftBotRightTopConnected + leftBotRightTopAvailable;

    
    return 0;
}

@end
