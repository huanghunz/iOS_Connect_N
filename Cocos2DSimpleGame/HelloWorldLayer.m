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
NSString *PLAYER_MOVED_IMG = @"red_50.png";
NSString *AI_MOVED_IMG = @"green_50.png";

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
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        _game = [[GameBoard alloc] init:(winSize) andN:winN];
      
        boardSize = [ _game getBoardSize];
    
        boardOriX = winSize.width/4;
        _arrowCol = [[NSMutableArray alloc] init];
        
        for (int row = 0; row <= boardSize; row++ ){
            for ( int col = 0; col < boardSize; col++){
                NSString *image = (row == boardSize)? @"arrow-down-50x50.png":@"slot.png";
               
                CCSprite *emptySlot = [CCSprite spriteWithFile:image
                                                         rect:CGRectMake(0, 0, 25, 25)];

                emptySlot.position = ccp(boardOriX+(col+1)*25, (row+1)*25);
                emptySlot.anchorPoint = ccp(.0f, .0f);
                [self addChild: emptySlot z:0];
                
                if (row == boardSize){
                    [_arrowCol addObject:emptySlot];
                }
                
                
             }
        }
    }
    [self setTouchEnabled:YES];
    return self;
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
    
    /////////////////////////////////////////////////
    
    int targetCol = -1;
    int targetRow = -1;
    bool found = false;
    
    NSMutableDictionary *_gameBoard = [_game getGameBoard];
    
    for (CCSprite *arrow in _arrowCol){
        if (CGRectContainsPoint(arrow.boundingBox, location)){
            targetCol = (arrow.position.x - boardOriX)/25.0 -1 ;
            targetRow = arrow.position.y/25.0-1;
            
            // found exit
            found = true;
            break;
        }
    }
    
    if (!found){
        for ( id key in _gameBoard){
            GameState *oneSlot = _gameBoard[key];
            if (CGRectContainsPoint([oneSlot getLocation], location)){
                if ([oneSlot getState] == empty){
                   
                    targetCol = [ _game getXFromKey:key];
                    targetRow = [ _game getYFromKey:key];
                    
                    // found, exit for loop
                    found = true;
                    break;
                    
                }
            }
        }
    }
    
    if (found){
         // 1. get the coordiantion of lowest empty slot
        while ( [_game getNextSlotTag:targetCol and: targetRow] == empty){ targetRow -= 1; }
        
        // 2. get the lowest empty slot/state. state will be upadated after animation finishes.
        NSString *targetCoor = [ _game toTupleFrom:targetCol andY:targetRow];
        GameState *targetSlot = _gameBoard[targetCoor];
        
        
        [self setTouchEnabled:NO];
        [self runAnimation:targetCol andY:targetRow withState:targetSlot];
       // [self applyState:targetCol andY:targetRow withStateTag:[targetSlot getState]];

    }
}

- (void) AIopponmentActs{
    
    GameBoard *gameStateCopy = [[GameBoard alloc] makeGameCopy:_game];
    NSMutableDictionary *board = [_game getGameBoard];
    
    NSMutableArray *avaiSlots = [_game getAvailableSlots];
   
    if ([avaiSlots count] == 0){
                return;
    }
   
    GameState* targetSlot = nil;
    // pass a copy to simulate
    MCSTNode *think = [[MCSTNode alloc] initWithGame:gameStateCopy] ;
    
    NSString *MCSTkey = [think runMCS:gameStateCopy];
    
    targetSlot = board[MCSTkey];
    int x = [_game getXFromKey:MCSTkey];
    int y = [_game getYFromKey:MCSTkey];

    [self runAnimation:x andY:y withState:targetSlot];
    
}

-(void)runAnimation:(int)targetCol andY:(int)targetRow withState:(GameState*)state{
    CCSprite *newMoved = nil;
    CGPoint movedDest;
    
    if (!animationStarted){
        NSString *color = ([_game isPlayerTurn] == player)?PLAYER_MOVED_IMG: AI_MOVED_IMG;
        newMoved = [CCSprite spriteWithFile:color
                                                    rect:CGRectMake(0, 0, 25, 25)];
        newMoved.anchorPoint = ccp(.0f, .0f);
        
        CGRect targetLocation = [state getLocation]; // to calculate the destination and starting point
        CGFloat startY = (BOARD_SIZE+1)*targetLocation.size.height;
        CGFloat destY = (targetRow+1)*targetLocation.size.height;
        CGFloat destX = boardOriX+(targetCol+1)*25;
        
        newMoved.position = ccp(destX, startY );
        movedDest = ccp(destX, destY);

        animationRuning = false;
    }
    
    if(!animationRuning && !animationStarted){
        animationStarted = true;
        animationRuning = true;
        [self addChild:newMoved z:1];
        
        //TODO: need to adjust the speed of falling piece
        [newMoved runAction:
         [CCSequence actions:
          [CCMoveTo actionWithDuration: 1 position:movedDest],
          [CCDelayTime actionWithDuration:0.5],
          [CCCallBlockN actionWithBlock:^(CCNode *node){
             animationRuning = false;
             [self runAnimation:targetCol andY:targetRow withState:state];

         }],
          nil]];

        }
    if (!animationRuning){
        animationStarted = false;
        
      
        [self applyState:targetCol andY:targetRow with:state];
        
        // animationRuning = false;
    }
}

-(void) applyState:(int)targetCol andY:(int)targetRow with:(GameState*)state{
    [ _game applyAction:state];
    
    bool won = [ _game checkWin:targetCol and:targetRow with:[state getState]];
    
    if (won){
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
        [self gameOver];
    }
    else{
        
        if (![_game isPlayerTurn] )
            [self AIopponmentActs];
        else
            [self setTouchEnabled:YES];
    }
    

}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [_game release];
    _game = nil;
    [_arrowCol release];
    _arrowCol =nil;
 
    [super dealloc];
}

-(void)gameOver{
    bool playerWins = ([_game isPlayerTurn])?false:true;
    CCScene *endGameScene = [ GameOverLayer sceneWithWon:playerWins ];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:2.0 scene:endGameScene ]];
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
