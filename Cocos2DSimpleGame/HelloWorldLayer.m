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
int winN = 0;
NSString *PLAYER_MOVED_IMG = @"red.png";
NSString *AI_MOVED_IMG = @"green.png";

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene:(int)n
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    winN = n;
    HelloWorldLayer *layer = [HelloWorldLayer node];
   
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

 
- (id) init
{
    if ((self = [super initWithColor:ccc4(255,255,255,255)])) {
        
        isPlayerTurn = true;
       
       
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
         float boardOriX = winSize.width/4;
        one = [[GameState alloc] initWithBoxLocaton:CGRectMake(boardOriX+25, 25, 25, 25)andState:empty];
             //  [self draw];
        [self setTouchEnabled:YES];
        
        _game = [[GameBoard alloc] init:(winSize) andN:winN];
        NSMutableDictionary *gameBoard = [_game getGameBoard];
        //CGRect boxSize = [ (GameState)gameBoard[@"(0,0)" g]
        
        boardSize = [ _game getBoardSize];
        
        for (int row = 0; row < boardSize; row++ ){
            for ( int col = 0; col < boardSize; col++){
                
              CCSprite *emptySlot = [CCSprite spriteWithFile:@"slot.png"
                                                          rect:CGRectMake(0, 0, 25, 25)];
//                float boardOriX = winSize.width/4;
               // emptySlot.position = ccp(boardOriX+(col+1)*slotWidth, (row+1)*slotHeight);
                emptySlot = [_game getSlotFrom:col and:row ];
                
             //   float boardOriX = winSize.width/4;
              //  emptySlot.position = ccp(boardOriX+(col+1)*slotWidth, (row+1)*slotHeight);
                [ self addChild: emptySlot];
                
             }
        }
    }
    return self;
}



- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
    
    /////////////////////////////////////////////////
    
    if (CGRectContainsPoint([one getLocation], location)){
         [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
    }
    NSMutableDictionary *_gameBoard = [_game getGameBoard];
   
    
    for ( id key in _gameBoard){
       
        CCSprite *oneSlot = _gameBoard[key];
             
        //TODO: need some arrow above the slots
        if (CGRectContainsPoint(oneSlot.boundingBox, location)){
           
            if (oneSlot.tag == empty){ // do move
                int targetCol = [ _game getXFromKey:key];
                int targetRow = [  _game getYFromKey:key];
               
                // get the lowest empty slot
                while ( [_game getNextSlotTag:targetCol and: targetRow] == empty){ targetRow -= 1; }
                
                NSString *targetCoor = [ _game toTupleFrom:targetCol andY:targetRow];
                CCSprite *targetSlot = _gameBoard[targetCoor];
                
                //TODO: need to adjust the size
                NSString *color = PLAYER_MOVED_IMG;
                CCSprite *playerMoved = [CCSprite spriteWithFile:color
                                                         rect:CGRectMake(0, 0, 20, 20)];
                
                CGFloat startY = (8+1)*[targetSlot boundingBox].size.height;
                playerMoved.position = ccp(targetSlot.position.x, startY );
                CGPoint movedDest = ccp(oneSlot.position.x, targetSlot.position.y);
            
                [self setTouchEnabled:NO];
                [self addChild:playerMoved];

                //TODO: need to adjust the speed of falling piece
                [playerMoved runAction:
                 [CCSequence actions:
                  [CCMoveTo actionWithDuration: 1 position:movedDest],
                  [CCCallBlockN actionWithBlock:^(CCNode *node) {
                        [node removeFromParentAndCleanup:YES];
                        [targetSlot setTexture:[[CCTextureCache sharedTextureCache] addImage:color]];
                     
                        [ _game applyAction:targetSlot];

                        bool won = [ _game checkWin:targetCol and:targetRow with:targetSlot.tag];

                     if (won){
                            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
                         [_game setGameEnded];
                     }

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
    
    GameBoard *gameStateCopy = [[GameBoard alloc] makeGameCopy:_game];
    NSMutableDictionary *board = [_game getGameBoard];
    
    NSMutableArray *avaiSlots = [_game getAvailableSlots];
    NSString *bestTry = nil;
    float bestTryValue = -9999;
    if ([avaiSlots count] == 0){
        // end game
        return;
    }
    
    CCSprite* targetSlot = nil;

    int tryX = 0;
    int tryY = 0;
    
    // pass a copy to simulate
    MCSTNode *think = [[MCSTNode alloc] initWithGame:gameStateCopy] ;
    
    NSString *MCSTkey = [think runMCS:gameStateCopy];
    
    
    
    targetSlot = board[MCSTkey];
    int x = [_game getXFromKey:MCSTkey];
    int y = [_game getYFromKey:MCSTkey];

    NSString *color = AI_MOVED_IMG;
    CCSprite *AIMoved = [CCSprite spriteWithFile:color
                                             rect:CGRectMake(0, 0, 20, 20)];
    
   // targetSlot = board[MCSTkey];
    
    CGFloat startY = (8+1)*[targetSlot boundingBox].size.height;
    AIMoved.position = ccp(targetSlot.position.x, startY );
    
    CGPoint movedDest = ccp(targetSlot.position.x, targetSlot.position.y);
    
    [self addChild:AIMoved];

    [AIMoved runAction:
     [CCSequence actions:
      [CCMoveTo actionWithDuration: 1 position:movedDest],
      [CCCallBlockN actionWithBlock:^(CCNode *node) {
         [node removeFromParentAndCleanup:YES];
         [targetSlot setTexture:[[CCTextureCache sharedTextureCache] addImage:color]];
         
        [ _game applyAction:targetSlot];

        // bool won = [_game checkWin:tryX and:tryY with:targetSlot.tag];
         bool won = [_game checkWin:x and:y with:targetSlot.tag];

         if (won){
             [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
             [_game setGameEnded];
         }
         
         else{
            [self setTouchEnabled:YES];
         }
     }],
      nil]];

    
    
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [_game release];
    _game = nil;
 
    [super dealloc];
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
