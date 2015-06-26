//
//  HelloWorldLayer.m
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 11/13/12.
//  Copyright Razeware LLC 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"
#import "GameOverLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

int BOARD_SIZE = 8;
enum{
    empty = 0,
    opponment = -1,
    player = 1
};

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    HelloWorldLayer *layer = [HelloWorldLayer node];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

-(void)gameLogic:(ccTime)dt {
    //[self addMonster];
}
 
- (id) init
{
    if ((self = [super initWithColor:ccc4(255,255,255,255)])) {
        
        isPlayerTurn = true;

        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCSprite *player = [CCSprite spriteWithFile:@"player.png"];
        player.position = ccp(player.contentSize.width/2, winSize.height/2);
        [self addChild:player];
        
        [self schedule:@selector(gameLogic:) interval:1.0];
        
        [self setTouchEnabled:YES];
        
        _gameBoard = [[NSMutableDictionary alloc] init];
        
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
                [ self addChild: _gameBoard[coor]];
                
            }
        }

        [self schedule:@selector(update:)];
    }
    return self;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
    
    /////////////////////////////////////////////////
    
    for ( id key in _gameBoard){
        CCSprite *oneSlot = _gameBoard[key];
        
        //TODO: need some arrow above the slots
        if (CGRectContainsPoint(oneSlot.boundingBox, location)){
           
            if (oneSlot.tag == empty){ // do move
                int targetCol = [ self getXFromKey:key];
                int targetRow = [ self getYFromKey:key];
               
                // get the lowest empty slot
                while ( [self getNextSlotTag:targetCol and: targetRow] == empty){ targetRow -= 1; }
                
                NSString *targetCoor = [self toTupleFrom:targetCol andY:targetRow];
                CCSprite *targetSlot = _gameBoard[targetCoor];
                
                //TODO: need to adjust the size
                NSString *color = isPlayerTurn?@"red.png": @"green.png";
                CCSprite *movedRed = [CCSprite spriteWithFile:color
                                                         rect:CGRectMake(0, 0, 20, 20)];
                
                movedRed.position = ccp(oneSlot.position.x, (8+1)*[oneSlot boundingBox].size.height);
                [self addChild:movedRed];
                
                CGPoint movedDest = ccp(oneSlot.position.x, targetSlot.position.y);
            
                [self setTouchEnabled:NO];

                //TODO: need to adjust the speed of falling piece
                [movedRed runAction:
                 [CCSequence actions:
                  [CCMoveTo actionWithDuration: 1 position:movedDest],
                  [CCCallBlockN actionWithBlock:^(CCNode *node) {
                     [node removeFromParentAndCleanup:YES];
                     [targetSlot setTexture:[[CCTextureCache sharedTextureCache] addImage:color]];
                     
                    // [self setTouchEnabled:YES];
                     targetSlot.tag = isPlayerTurn?player:opponment;
                     isPlayerTurn = !isPlayerTurn;
                     
                     bool won = [self checkWin:targetCol and:targetRow with:targetSlot.tag];
                     if (won)
                         [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];

                     else{
                         // call AI movement
                         [self AIopponmentActs];
                     }
                 }],
                  nil]];

            }
        }
        
       
    }
}

- (void) AIopponmentActs{
    CCSprite* targetSlot = nil;
    int randX = arc4random_uniform(BOARD_SIZE);
    int randY = arc4random_uniform(BOARD_SIZE);
    targetSlot = [self getSlotFrom:randX and:randY];
    
    while (targetSlot.tag != empty){
        randX = arc4random_uniform(BOARD_SIZE);
        randY = arc4random_uniform(BOARD_SIZE);
        targetSlot = [self getSlotFrom:randX and:randY];

    }
    
    while ( [self getNextSlotTag:randX and: randY] == empty){ randY -= 1; }
    
    NSString *color = isPlayerTurn?@"red.png": @"green.png";
    CCSprite *AIMoved = [CCSprite spriteWithFile:color
                                             rect:CGRectMake(0, 0, 20, 20)];
    
    targetSlot = [self getSlotFrom:randX and:randY];
    
    AIMoved.position = ccp(targetSlot.position.x, (8+1)*[targetSlot boundingBox].size.height);
    [self addChild:AIMoved];
    
    CGPoint movedDest = ccp(targetSlot.position.x, targetSlot.position.y);

    [AIMoved runAction:
     [CCSequence actions:
      [CCMoveTo actionWithDuration: 1 position:movedDest],
      [CCCallBlockN actionWithBlock:^(CCNode *node) {
         [node removeFromParentAndCleanup:YES];
         [targetSlot setTexture:[[CCTextureCache sharedTextureCache] addImage:color]];
         
         [self setTouchEnabled:YES];
         targetSlot.tag = isPlayerTurn?player:opponment;
         isPlayerTurn = !isPlayerTurn;
         
         bool won = [self checkWin:randX and:randY with:targetSlot.tag];
         if (won)
             [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
         
         else{
             // call AI movement
         }
     }],
      nil]];

    
    
}



- (void)update:(ccTime)dt {
    
//    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
//    for (CCSprite *projectile in _projectiles) {
//
//        NSMutableArray *monstersToDelete = [[NSMutableArray alloc] init];
//        for (CCSprite *monster in _monsters) {
//            
//            if (CGRectIntersectsRect(projectile.boundingBox, monster.boundingBox)) {
//                [monstersToDelete addObject:monster];
//            }
//        }
//        
//        for (CCSprite *monster in monstersToDelete) {
//            [_monsters removeObject:monster];
//            [self removeChild:monster cleanup:YES];
//            
//            _monstersDestroyed++;
//            if (_monstersDestroyed > 30) {
//                CCScene *gameOverScene = [GameOverLayer sceneWithWon:YES];
//                [[CCDirector sharedDirector] replaceScene:gameOverScene];
//            }
//        }
//        
//        if (monstersToDelete.count > 0) {
//            [projectilesToDelete addObject:projectile];
//        }
//        [monstersToDelete release];
//    }
//    
//    for (CCSprite *projectile in projectilesToDelete) {
//        [_projectiles removeObject:projectile];
//        [self removeChild:projectile cleanup:YES];
//    }
//    [projectilesToDelete release];
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [_gameBoard release];
    _gameBoard = nil;
 
    [super dealloc];
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


#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [[app navController] dismissModalViewControllerAnimated:YES];
}
@end
