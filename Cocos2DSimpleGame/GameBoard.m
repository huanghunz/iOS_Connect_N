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
    
    CCSprite *emptySlot = [CCSprite spriteWithFile:@"slot.png"];
    
    int slotWidth = [emptySlot boundingBox].size.width;
    int slotHeight = [emptySlot boundingBox].size.height;
    
    for (int row = 0; row < BOARD_SIZE; row++ ){
        
        for ( int col = 0; col < BOARD_SIZE; col++){
           
            CCSprite *emptySlot = [CCSprite spriteWithFile:@"slot.png"
                                                      rect:CGRectMake(0, 0, 25, 25)];
            //slot state
            emptySlot.tag = empty;
            
            float boardOriX = winSize.width/4;
            emptySlot.position = ccp(boardOriX+(col+1)*slotWidth, (row+1)*slotHeight);
             emptySlot.anchorPoint = ccp(.0f, .0f);
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
    int connectN = self->_connectN;
    
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
    
    targetSlot.tag = playersTurn?player: opponment;
    playersTurn = !playersTurn;

    
}
-(void)applyAction:(CCSprite*)targetSlot{
   
    targetSlot.tag = playersTurn? player: opponment;
    playersTurn = !playersTurn;
    
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

-(float) evaluateState:(int)placedX andY:(int)placedY of:(NSInteger) whosTurn{
    
    bool eval = [ self checkWin:placedX and:placedY with:whosTurn];
    if (eval){
        return 1.0;
    }
    else{
        NSInteger oppsitePlayer =  (whosTurn == player)?opponment:player;
        for ( id keyId in _gameBoard){
            NSString *key = (NSString*) keyId;
            CCSprite *oneSlot = _gameBoard[key];
            
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
    
    CCSprite *oneSlot = nil;
    NSMutableArray *avaiSlots = [[NSMutableArray alloc] init];
    avaiSlots = [self getAvailableSlots];
    
    for (int leftToRightRange = (-1*connectN)+1; leftToRightRange < connectN; leftToRightRange++){
        
        
        // horizontal
        NSString* horKey = [self toTupleFrom:leftToRightRange + placedX andY:placedY];
        
        if ( [_gameBoard objectForKey:horKey] != nil){
            
            
            oneSlot = _gameBoard[horKey];
            horConnected = (oneSlot.tag == whosTurn)? horConnected + 1 :0;
            
            int beforeConnectedX = leftToRightRange + placedX - horConnected;
            int afterConnectedX = leftToRightRange + placedX + 1;
            
            CCSprite *beforeSlot = _gameBoard[[self toTupleFrom:beforeConnectedX andY:placedY]];
            CCSprite *afterSlot = _gameBoard[[ self toTupleFrom:afterConnectedX andY:placedY]];
            
            CCSprite *beforeSupportedSlot = _gameBoard[[self toTupleFrom:beforeConnectedX andY:placedY-1]];
            CCSprite *afterSupportedSlot = _gameBoard[[ self toTupleFrom:afterConnectedX andY:placedY-1]];
            
            // two sided
            if (connectN - horConnected == 2){
                
                if (beforeSlot.tag != oppsitePlayer && afterSlot.tag != oppsitePlayer){
                    if (placedY == 0){ // bottom line
                        return true;
                    }
                    // other than bottom line
                    else if (beforeSupportedSlot.tag != empty && afterSupportedSlot.tag != empty)
                        return true;
                    
                }
                
            }
            
            if (horConnected == connectN-1){
                if ( placedY == 0 && ( beforeSlot.tag != oppsitePlayer || afterSlot.tag != oppsitePlayer)){
                    return  true;
                }
                
                else if ( (beforeSlot.tag != oppsitePlayer && beforeSupportedSlot.tag != empty )|| ( afterSlot.tag != oppsitePlayer && afterSupportedSlot.tag != empty) ){
                    return true;
                }
            }
            
  
            
            
        }
        
        // vertical
        if ( leftToRightRange >=0 ){
            NSString* verKey = [self toTupleFrom:placedX andY:leftToRightRange+placedY];
            
            if ( [_gameBoard objectForKey:verKey] != nil){
                oneSlot = _gameBoard[verKey];
                
                verConnected = (oneSlot.tag == whosTurn)? verConnected+1 : 0;
                
                if (verConnected == connectN-1){
                    NSString* verUpKey = [self toTupleFrom:placedX andY:leftToRightRange+placedY+1];
                    
                    if ( ((CCSprite*)_gameBoard[verUpKey]).tag != oppsitePlayer)
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
            
            int beforeConnectedX =  leftToRightRange + placedX - leftTopRightBotConnected;
            
            int beforeConnectedY = (-1)*leftToRightRange+placedY + leftTopRightBotConnected;
            
            int afterConnectedX =  leftToRightRange + placedX + 1;
            
            int afterConnectedY = (-1)*leftToRightRange+placedY - 1;
            
            NSString *beforeKey = [self toTupleFrom:beforeConnectedX andY:beforeConnectedY];
            NSString *afterKey = [ self toTupleFrom:afterConnectedX andY:afterConnectedY];
            
            NSString *beforeSupported = [self toTupleFrom:beforeConnectedX andY:beforeConnectedY-1];
            NSString *afterSupported = [ self toTupleFrom:afterConnectedX andY:afterConnectedY-1];
            
            CCSprite *beforeSupportedSlot = _gameBoard[beforeSupported];
            CCSprite *afterSupportedSlot = _gameBoard[afterSupported];
            
            if (connectN - leftTopRightBotConnected == 2){
                
                
                if ( ((CCSprite*)_gameBoard[beforeKey]).tag == empty && ((CCSprite*)_gameBoard[afterKey]).tag == empty ){
                    
                    if( ((CCSprite*)_gameBoard[beforeSupported]).tag != empty && ((CCSprite*)_gameBoard[afterSupported]).tag != empty )
                        return true;
                }
                
            }
            
            
            if (leftTopRightBotConnected == connectN-1){
                // supported
                if ((((CCSprite*)_gameBoard[afterKey]).tag != oppsitePlayer && afterSupportedSlot.tag != empty)|| (((CCSprite*)_gameBoard[beforeKey]).tag != oppsitePlayer &&   beforeSupportedSlot.tag != empty))
                    return true;
            }
            
            
            
        }
        
        // dia left bot to right top
        NSString* fromLeftBotKey = [self toTupleFrom:
                                    leftToRightRange + placedX andY: leftToRightRange + placedY];
        if ( [_gameBoard objectForKey:fromLeftBotKey] != nil){
            oneSlot = _gameBoard[fromLeftBotKey];
            
            leftBotRightTopConnected = (oneSlot.tag == whosTurn)? leftBotRightTopConnected + 1 : 0;
            
            int beforeConnectedX = leftToRightRange + placedX - leftBotRightTopConnected;
            int afterConnectedX = leftToRightRange + placedX + 1;
            
            int beforeConnectedY =  leftToRightRange + placedY-leftBotRightTopConnected;
            int afterConnectedY =  leftToRightRange + placedY+1;
            
            NSString *beforeKey = [self toTupleFrom:beforeConnectedX andY:beforeConnectedY];
            NSString *afterKey = [ self toTupleFrom:afterConnectedX andY:afterConnectedY];
            
            NSString *beforeSupported = [self toTupleFrom:beforeConnectedX andY:beforeConnectedY-1];
            NSString *afterSupported = [ self toTupleFrom:afterConnectedX andY:afterConnectedY-1];
            
            CCSprite *beforeSupportedSlot = _gameBoard[beforeSupported];
            CCSprite *afterSupportedSlot = _gameBoard[afterSupported];

            CCSprite *beforeSlot = _gameBoard[beforeKey];
            CCSprite *afterSlot = _gameBoard[afterKey];

            
            if (connectN - leftBotRightTopConnected == 2){
                
                if ( ((CCSprite*)_gameBoard[beforeKey]).tag == empty && ((CCSprite*)_gameBoard[afterKey]).tag == empty ){
                    
                    if( ((CCSprite*)_gameBoard[beforeSupported]).tag != empty && ((CCSprite*)_gameBoard[afterSupported]).tag != empty )
                        return true;
                }
                
            }
            
            if (leftBotRightTopConnected  == connectN-1){
                
               if ( (beforeSlot.tag != oppsitePlayer && afterSupportedSlot.tag != empty)  || (afterSlot.tag != oppsitePlayer &&   beforeSupportedSlot.tag != empty))
                    return true;

            }
            
            
        }
        
    }
    
    return false;
}

-(void)setGameEnded{
    self->gameEnded =true;
}

-(bool)isGameEnded{
    return self->gameEnded;
}

@end
