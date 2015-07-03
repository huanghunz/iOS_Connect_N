//
//  GameBoard.m
//  Cocos2DSimpleGame
//
//  Created by JIAYU ZENG on 6/25/15.
//  Copyright 2015 Razeware LLC. All rights reserved.
//

#import "GameBoard.h"

@implementation GameBoard


-(id)init:(CGSize)winSize andN:(int)n{
    
    self->_gameBoard = [[NSMutableDictionary alloc] init];
    self->BOARD_SIZE = 8;
    self->playersTurn = true;
    self->_connectN = n;
    
    for (int row = 0; row < BOARD_SIZE; row++ ){
        
        for ( int col = 0; col < BOARD_SIZE; col++){
            
            float boardOriX = winSize.width/4;
            CGRect newBox = CGRectMake(boardOriX+(col+1)*25, (row+1)*25, 25, 25);

            NSString *coor = [self toTupleFrom:col andY:row];
            GameState *newState = [[GameState alloc] initWithBoxLocaton:newBox andState:empty];
            
            // add to the mutable dictionary
            [self->_gameBoard setObject:newState forKey:coor];
        }
    }

    
    return self;
}

- (GameBoard*)makeGameCopy:(GameBoard*)game{
    
    GameBoard *copy = [GameBoard alloc];
    
    copy->_connectN = game->_connectN;
  
    copy->BOARD_SIZE = [game getBoardSize];
    
    copy->_gameBoard = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *originBoard = [game getGameBoard];
    
    for (id key in originBoard ){
        
        GameState *tmp = originBoard[key];
        GameState *stateCopy = [[GameState alloc] initWithBoxLocaton:[tmp getLocation] andState:[tmp getState]];
        
        [copy->_gameBoard setObject:stateCopy forKey:key];
        
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
    int connectN = self->_connectN;
    
    GameState *oneSlot = nil;
    
    for (int leftToRightRange = (-1*connectN)+1; leftToRightRange < connectN; leftToRightRange++){
        
        // horizontal
        NSString* horKey = [self toTupleFrom:leftToRightRange + placedX andY:placedY];
        if ( [_gameBoard objectForKey:horKey] != nil){
            oneSlot = _gameBoard[horKey];
    
            horConnected = ([oneSlot getState] == whosTurn)? horConnected+1 :0;
            if (horConnected == connectN) return true;
        }
        
        // vertical
        NSString* verKey = [self toTupleFrom:placedX andY:leftToRightRange+placedY];
        if ( [_gameBoard objectForKey:verKey] != nil){
            oneSlot = _gameBoard[verKey];
            
            verConnected = ([oneSlot getState] == whosTurn)? verConnected+1 :0;
            if (verConnected == connectN) return true;
            
        }
        
        // dia left top to right bot
        NSString* fromLeftTopKey = [self toTupleFrom:
                                    leftToRightRange + placedX andY: (-1)*leftToRightRange+placedY];
        if ( [_gameBoard objectForKey:fromLeftTopKey] != nil){
            oneSlot = _gameBoard[fromLeftTopKey];
            
            
            leftTopRightBotConnected = ([oneSlot getState] == whosTurn)? leftTopRightBotConnected + 1 : 0;
            if (leftTopRightBotConnected == connectN) return true;
            
        }
        
        // dia left bot to right top
        NSString* fromLeftBotKey = [self toTupleFrom:
                                    leftToRightRange + placedX andY: leftToRightRange + placedY];
        if ( [_gameBoard objectForKey:fromLeftBotKey] != nil){
            oneSlot = _gameBoard[fromLeftBotKey];
            
            leftBotRightTopConnected = ([oneSlot getState] == whosTurn)? leftBotRightTopConnected + 1 : 0;
            
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
    
    GameState *lowerSlot;
    
    if (y > 0){
        y -= 1;
        NSString* lowerCoor =  [self toTupleFrom:x andY:y];
        lowerSlot = _gameBoard[lowerCoor];
        return [lowerSlot getState];
    }
    else{
        NSInteger none = -99;
        return none;
    }
}

- (GameState*) getSlotFrom:(int)x and: (int)y{
    NSString *key = [self toTupleFrom:x andY:y];
    GameState* oneSlot = _gameBoard[key];
    return oneSlot;
}

-(NSInteger) getSlotStateFromX:(int)x andY:(int)y{
    NSString *key = [self toTupleFrom:x andY:y];
    GameState* oneSlot = _gameBoard[key];
    return [oneSlot getState];
}
-(GameState*) getSlotFromKey:(id)key{ return  _gameBoard[key]; }
-(NSMutableDictionary*)getGameBoard{ return self->_gameBoard; }



-(int)getBoardSize{ return self->BOARD_SIZE; }

-(void)dealloc{
    [_gameBoard release];
    _gameBoard = nil;
    
    [super dealloc];
}

-(void)applyAction:(int)targetCol and:(int)targetRow{
    
    NSString *targetCoor = [ self toTupleFrom:targetCol andY:targetRow];
    GameState *targetSlot = _gameBoard[targetCoor];
    
    NSInteger tag = playersTurn?player: opponment;
    [targetSlot setState:tag];
    playersTurn = !playersTurn;

    
}
-(void)applyAction:(GameState*)targetSlot{
   
    NSInteger tag = playersTurn?player: opponment;
    [targetSlot setState:tag];
    playersTurn = !playersTurn;
}

- (NSMutableArray* )getAvailableSlots{
    
    int boardSize = self->BOARD_SIZE;
    NSMutableArray *availableSlots = [[NSMutableArray alloc] init];
    
    //CCSprite* oneSlot = nil;
    for (int col = 0; col < boardSize; col++){
        int emptyRow = 0;
        
        while ([[self getSlotFrom:col and:emptyRow] getState] != empty
               && emptyRow != boardSize){
            emptyRow++;
        }
        
        if (emptyRow != boardSize){
            NSString *key = [self toTupleFrom:col andY:emptyRow];
            [availableSlots addObject:key];
        }
    }
    
    return  availableSlots;
}

-(float) evaluateState:(int)placedX andY:(int)placedY of:(NSInteger) whosTurn{
    
    bool eval = [ self checkWin:placedX and:placedY with:whosTurn];
    if (eval){
        return 1.0;
    }
    else{
        NSInteger oppsitePlayer =  (whosTurn == player)?opponment:player;
        for ( id keyId in _gameBoard){
            NSString *key = (NSString*) keyId;
            GameState  *oneSlot = _gameBoard[key];
            
            if (oneSlot.tag == oppsitePlayer){
                int x = [self getXFromKey:key];
                int y = [self getYFromKey:key];
                bool lost = [ self opponmentAlmostWin:x andY:y of:oppsitePlayer];
                if (lost){
                    return  -1;
                }
                
            }
        }
    }
    
    return 0.5;
    
}

- (bool)opponmentAlmostWin:(int)placedX andY:(int)placedY of:(NSInteger)whosTurn{
    
    int horConnected = 0, verConnected = 0, leftTopRightBotConnected = 0, leftBotRightTopConnected = 0;
    
    int connectN = self->_connectN;
    
    NSInteger oppsitePlayer = (whosTurn == player)?opponment:player;
    
    GameState *oneSlot = nil;
    NSMutableArray *avaiSlots = [[NSMutableArray alloc] init];
    avaiSlots = [self getAvailableSlots];
    
    for (int leftToRightRange = (-1*connectN)+1; leftToRightRange < connectN; leftToRightRange++){
        
        
        // horizontal
        NSString* horKey = [self toTupleFrom:leftToRightRange + placedX andY:placedY];
        
        if ( [_gameBoard objectForKey:horKey] != nil){
            
            oneSlot = _gameBoard[horKey];
            horConnected = ([oneSlot getState] == whosTurn)? horConnected + 1 :0;
            
            // most left/right are related to the number of connected pieces
            int mostLeftX = leftToRightRange + placedX - horConnected;
            NSInteger mostLeftSlotState = [ self getSlotStateFromX:mostLeftX andY:placedY];
            bool mostLeftSupported = [self isSupported:mostLeftX andY:placedY];
            
            int mostRightX = leftToRightRange + placedX + 1;
            NSInteger mostRightSlotState = [ self getSlotStateFromX:mostRightX andY:placedY];
            bool mostRightSupported = [self isSupported:mostRightX andY:placedY];
    
            if (connectN - horConnected == 2){ // check its two sides
                
                if (mostLeftSlotState != oppsitePlayer && mostRightSlotState != oppsitePlayer &&  mostLeftSupported && mostRightSupported )
                        return true;
                
            }
            else if (connectN - horConnected == 1){
               if ( (mostLeftSlotState != oppsitePlayer && mostLeftSupported )||
                   ( mostRightSlotState != oppsitePlayer && mostRightSupported) ){
                    return true;
                }
            }
        

        }
        // vertical
        if ( leftToRightRange >=0 ){
            NSString* verKey = [self toTupleFrom:placedX andY:leftToRightRange+placedY];
            
            if ( [_gameBoard objectForKey:verKey] != nil){
                oneSlot = _gameBoard[verKey];
                
                verConnected = ([oneSlot getState] == whosTurn)? verConnected+1 : 0;
                
                if (verConnected == connectN-1){
                    NSInteger upperSlotState = [self getSlotStateFromX:placedX andY:leftToRightRange+placedY+1];
                    if ( upperSlotState != oppsitePlayer)
                        return true;
                }
                
            }
        }
        
        // dia left top to right bot
        NSString* fromLeftTopKey = [self toTupleFrom:
                                    leftToRightRange + placedX andY: (-1)*leftToRightRange+placedY];
        if ( [_gameBoard objectForKey:fromLeftTopKey] != nil){
            oneSlot = _gameBoard[fromLeftTopKey];
            
            
            leftTopRightBotConnected = (oneSlot.tag == whosTurn)? leftTopRightBotConnected + 1 : 0;
            
            int mostLeftX =  leftToRightRange + placedX - leftTopRightBotConnected;
            int mostLeftY = (-1)*leftToRightRange+placedY + leftTopRightBotConnected;
            NSInteger mostLeftSlotState = [ self getSlotStateFromX:mostLeftX andY:mostLeftY];
            bool mostLeftSupported = [self isSupported:mostLeftX andY:mostLeftY];

            
            int mostRightX =  leftToRightRange + placedX + 1;
            int mostRightY = (-1)*leftToRightRange+placedY - 1;
            NSInteger mostRightSlotState = [ self getSlotStateFromX:mostRightX andY:mostRightY];
            bool mostRightSupported = [self isSupported:mostRightX andY:mostRightY];

            
            if (connectN - leftTopRightBotConnected == 2){
                
                if (mostLeftSlotState != oppsitePlayer && mostRightSlotState != oppsitePlayer &&  mostLeftSupported && mostRightSupported )
                return true;
                
            }
            
            
            if (connectN - leftTopRightBotConnected == 1){
                if ( (mostLeftSlotState != oppsitePlayer && mostLeftSupported )||
                    ( mostRightSlotState != oppsitePlayer && mostRightSupported) ){
                    return true;
                }
            }
        }
        
        // dia left bot to right top
        NSString* fromLeftBotKey = [self toTupleFrom:
                                    leftToRightRange + placedX andY: leftToRightRange + placedY];
        if ( [_gameBoard objectForKey:fromLeftBotKey] != nil){
            oneSlot = _gameBoard[fromLeftBotKey];
            
            leftBotRightTopConnected = (oneSlot.tag == whosTurn)? leftBotRightTopConnected + 1 : 0;
            
            int mostLeftX = leftToRightRange + placedX - leftBotRightTopConnected;
            int mostLeftY =  leftToRightRange + placedY-leftBotRightTopConnected;
            
            
            NSInteger mostLeftSlotState = [ self getSlotStateFromX:mostLeftX andY:mostLeftY];
            bool mostLeftSupported = [self isSupported:mostLeftX andY:mostLeftY];
    
            
            int mostRightY =  leftToRightRange + placedY+1;
            int mostRightX = leftToRightRange + placedX + 1;

            NSInteger mostRightSlotState = [ self getSlotStateFromX:mostRightX andY:mostRightY];
            bool mostRightSupported = [self isSupported:mostRightX andY:mostRightY];
            
            if (connectN - leftBotRightTopConnected == 2){
                
                if (mostLeftSlotState != oppsitePlayer && mostRightSlotState != oppsitePlayer &&  mostLeftSupported && mostRightSupported )
                    return true;
                
            }
            
            if (leftBotRightTopConnected  == connectN-1){
                
                if ( (mostLeftSlotState != oppsitePlayer && mostLeftSupported )||
                    ( mostRightSlotState != oppsitePlayer && mostRightSupported) ){
                    return true;
                }
            }
        }
        
    }
    
    return false;
}
- (bool)isSupported:(int)col andY:(int)row{
    
    if (row - 1 < 0)
        return true;

    NSString *lowerSlotKey = [self toTupleFrom:col andY:row-1];
    GameState *lowerSlot = _gameBoard[lowerSlotKey];
    
    return  ([lowerSlot getState] != empty)?true:false;

    
}


-(void) getX:(int*)x andY:(int*)y fromKey:(NSString*)key{
    NSString * xChar = [key substringWithRange:NSMakeRange(1, 1)];
    NSString * yChar = [key substringWithRange:NSMakeRange(3, 1)];
    
    *x = [xChar intValue];
    *y = [yChar intValue];
}

-(void)setGameEnded{
    self->gameEnded =true;
}

-(bool)isGameEnded{
    return self->gameEnded;
}

@end
