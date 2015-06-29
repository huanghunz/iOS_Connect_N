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
NSString *PLAYER_MOVED_IMG = @"red.png";
NSString *AI_MOVED_IMG = @"green.png";

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
        
       // [self schedule:@selector(gameLogic:) interval:1.0];
        
        [self setTouchEnabled:YES];
        
        _game = [[GameBoard alloc] init:(winSize)];
        boardSize = [ _game getBoardSize];

       // _gameBoard = [[NSMutableDictionary alloc] init];
        
        CCSprite *emptySlot = nil;
        
        for (int row = 0; row < boardSize; row++ ){
            for ( int col = 0; col < boardSize; col++){
                emptySlot = [_game getSlotFrom:col and:row ];
                [ self addChild: emptySlot];
                
            }
        }

        //[self schedule:@selector(update:)];
    }
    return self;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
    
    /////////////////////////////////////////////////
    
    NSMutableDictionary *_gameBoard = [_game getGameBoard];
    
    for ( id key in _gameBoard){
       
        CCSprite *oneSlot = _gameBoard[key];
       // NSLog(@"%d", oneSlot.tag);
        
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
    
    GameBoard *gameStateCopy = [[GameBoard alloc] makeGameCopy:_game];
   // NSMutableDictionary *_gameBoard = [gameStateCopy getGameBoard];
    
    
    // pass a copy to simulate
    MCSTNode *think = [[MCSTNode alloc] initWithGame:gameStateCopy] ;
    
    NSString *MCSTkey = [think runMCS:gameStateCopy];
    
    CCSprite* targetSlot = nil;
    
    NSMutableDictionary *board = [_game getGameBoard];
    
    targetSlot = board[MCSTkey];

    
    int randX = arc4random_uniform(BOARD_SIZE);
    int randY = arc4random_uniform(BOARD_SIZE);
   // targetSlot = [_game getSlotFrom:randX and:randY];
    
    while (targetSlot.tag != empty){
        randX = arc4random_uniform(BOARD_SIZE);
        randY = arc4random_uniform(BOARD_SIZE);
        targetSlot = [_game getSlotFrom:randX and:randY];

    }
    
    while ( [_game getNextSlotTag:randX and: randY] == empty){ randY -= 1; }
    
    NSString *color = AI_MOVED_IMG;
    CCSprite *AIMoved = [CCSprite spriteWithFile:color
                                             rect:CGRectMake(0, 0, 20, 20)];
    
    targetSlot = [_game getSlotFrom:randX and:randY];
    targetSlot = board[MCSTkey];
    
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
         
         int x = [_game getXFromKey:MCSTkey];
         int y = [_game getYFromKey:MCSTkey];

         bool won = [_game checkWin:x and:y with:targetSlot.tag];
         if (won)
             [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
         
         else{
            [self setTouchEnabled:YES];
         }
     }],
      nil]];

    
    
}


- (void)update:(ccTime)dt {
    

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
