//
//  HelloWorldLayer.m
//  Connect4-Clone
//
//  Created by JIAYU ZENG on 7/2/15.
//  Copyright jz 2015. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer


NSString *PLAYER_MOVED_IMG = @"red_50.png";
NSString *AI_MOVED_IMG = @"green_50.png";

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene:(int)n
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [[[HelloWorldLayer alloc] initWithN:n] autorelease];
   
   	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
    
}
/* ========== initWithN =================
init the HelloWorld layer
 pre: int n --- defines connect-n game and winning condition
 post: displays the game board
 */
- (id) initWithN:(int)n
{
    if ((self = [super initWithColor:ccc4(255,255,255,255)])) {
        
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        _game = [[Game alloc] init:(winSize) andN:n];
        _gameStack = [[GameStack alloc] init];
        
        boardSize = [ _game getBoardSize];
        
        boardOriX = winSize.width/4;
        _arrowCol = [[NSMutableArray alloc] init];
        
        
        [self setSideSprites :winSize];
        numTurns = 0;
                
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
    
    animationStarted = false;
    animationRuning = false;
    [self setTouchEnabled:YES];
    return self;
}

/* ========== ccTouchesEnded =================
 Responds when player touches the screen
 If the location of touch collide with any sprite, responds accordingly
 pre:   NSSet *touches
        UIEvent *event
 post: if it collides with the game board, places a piece to the lowest slot
       if it collidse with button, quit game, or undo if the player hasn't done in 5 turns.
 */
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    
    int targetCol = -1;
    int targetRow = -1;
    bool found = false;
    
    NSMutableDictionary *_gameBoard = [_game getGameBoard];
    
    if (CGRectContainsPoint(_undo.boundingBox, location) && numTurns >= 5){
        [self handleUndo];
        return;
    }
    if (CGRectContainsPoint(_quit.boundingBox , location)){
        [[CCDirector sharedDirector] end];
        exit(0);
    }
    
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
                    
                     [_game getX:&targetCol andY:&targetRow fromKey:key];
                    
                    
                    // found, exit for loop
                    found = true;
                    break;
                    
                }
            }
        }
    }
    
    if (found){
        [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
        
        //  get the coordiantion of lowest empty slot
        while ( [_game getLowerSlotState:targetCol and: targetRow] == empty){ targetRow -= 1; }
        
        //  get the lowest empty slot/state. state will be upadated after animation finishes.
        NSString *targetCoor = [ _game toTupleFrom:targetCol andY:targetRow];
        GameState *targetSlot = _gameBoard[targetCoor];
        
        
        [self setTouchEnabled:NO];
        [self runAnimation:targetCol andY:targetRow withState:targetSlot];
      
    }
}

/* ========== AIopponmentActs =================
 After player moved, AI calculates to place a piece using Monte Carlo Tree Search algorithm
 
 pre:   nothing
 post:  AI places a piece
 */
- (void) AIopponmentActs{
    
    Game *gameStateCopy = [_game makeGameCopy:_game];
    NSMutableDictionary *board = [_game getGameBoard];
    
       // pass a copy to simulate
    MCTSNode *think = [[MCTSNode alloc] initWithGame:gameStateCopy] ;
    NSString *MCTSresult = [think runMCS:gameStateCopy];
    
    GameState* targetSlot = board[MCTSresult];
    
    int x, y;
    [_game getX:&x andY:&y fromKey:MCTSresult];
    [self runAnimation:x andY:y withState:targetSlot];
    
}

/* ========== runAnimation: andY: withState =================
 Based on the given location, drop a piece from top of the game board
 pre:   targetCol -- coordination, x
        targetRow -- coordination, y
        state     -- who places this piece
 post:  runs falling animation, and apply the action once the animatino is done.
 */
-(void)runAnimation:(int)targetCol andY:(int)targetRow withState:(GameState*)state{
    CCSprite *newMoved = nil;
    CGPoint movedDest;
    
    if (!animationStarted){
        NSString *color = ([_game isPlayerTurn] == player)?PLAYER_MOVED_IMG: AI_MOVED_IMG;
        newMoved = [CCSprite spriteWithFile:color
                                       rect:CGRectMake(0, 0, 25, 25)];
        newMoved.anchorPoint = ccp(.0f, .0f);
        
        newMoved.userObject = [ _game toTupleFrom:targetCol andY:targetRow];
        //newMoved.userData =
        
        CGRect targetLocation = [state getLocation]; // to calculate the destination and starting point
        CGFloat startY = (boardSize+1)*targetLocation.size.height;
        CGFloat destY = (targetRow+1)*targetLocation.size.height;
        CGFloat destX = boardOriX+(targetCol+1)*25;
        
        newMoved.position = ccp(destX, startY );
        movedDest = ccp(destX, destY);
        
        animationRuning = false;
    }
    
    if(!animationRuning && !animationStarted){
        animationStarted = true;
        animationRuning = true;
        
        [_gameStack push:newMoved];
        [self addChild:newMoved z:1];
        float delayTime = ([_game isPlayerTurn])?0.5:0.1;
        //TODO: need to adjust the speed of falling piece
        [newMoved runAction:
         [CCSequence actions:
          [CCMoveTo actionWithDuration: 1 position:movedDest],
          [CCDelayTime actionWithDuration:delayTime],
          [CCCallBlockN actionWithBlock:^(CCNode *node){
             animationRuning = false;
             [self runAnimation:targetCol andY:targetRow withState:state];
             
         }],
          nil]];
        
    }
    
    // when the animation finishes
    if (!animationRuning){
        animationStarted = false;
        
        
        [self applyState:targetCol andY:targetRow with:state];
        
        // animationRuning = false;
    }
}

/* ========== applyState: andY: with: =================
 Based on the given location and the state, changed gameState content
 ex. if the AI places this move, gameState (x,y) belongs to AI
 pre:   targetCol -- coordination, x
        targetRow -- coordination, y
        state     -- who places this piece
 post:  changes the game states, and check if this player wins.
 */
-(void) applyState:(int)targetCol andY:(int)targetRow with:(GameState*)state{
    [ _game applyAction:state];
    
    bool won = [ _game checkWin:targetCol and:targetRow with:[state getState]];
    
    
    if (won){
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
        NSInteger winner = ([_game isPlayerTurn])?opponment:player;
        [self gameOver:winner];
    }
    else{
        
        if (![_game isPlayerTurn] )
            [self AIopponmentActs];
        else{
            
            NSMutableArray *avaiSlots = [_game getAvailableSlots];
            
            if ([avaiSlots count] == 0){
                [self gameOver:empty];
                return;
            }
            
            [self setTouchEnabled:YES];
            numTurns++;
            
            if (numTurns >= 5) {
                CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:@"undo-ready.png"];
                [_undo setTexture: tex];
            }
        }
    }
    
    
}



/* ========== gameOver: =================
 Calls gameOver layer
 pre:   winner -- the player, AI or no one.
 post:  changes interface to gameOver layer
 */
-(void)gameOver:(NSInteger)winner{
    CCScene *endGameScene = [ GameOverLayer sceneWithWon:winner ];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:2.0 scene:endGameScene ]];
}


/* ========== seSideSriptes: =================
Sets the quit and undo sprites
 pre:   winSize -- window size
 post:  Sets the quit and undo sprites
 */
-(void)setSideSprites:(CGSize)winSize{
    
    _undo = [CCSprite spriteWithFile:@"undo-not-ready.png"
                                rect:CGRectMake(0, 0, 100, 50)];
    _undo.anchorPoint = ccp(.0f, .0f);
    
    _undo.position = ccp(100, winSize.height/2 - 50 );
    
    _quit = [CCSprite spriteWithFile:@"quit.png"
                                rect:CGRectMake(0, 0, 100, 50)];
    _quit.anchorPoint = ccp(.0f, .0f);
    
    _quit.position = ccp(100, winSize.height/2 - 100 );
    
    [self addChild:_undo];
    [self addChild:_quit];
}

/* ========== seSideSriptes: =================
 *Precondition: player doesn't undo in 5 turns
 Removes the last move of the player and AI
 pre:   nothing
 post:  the last two moves on game board is removed.
 */

-(void)handleUndo{
    numTurns = 0;
    
    CCSprite *AILast = [ _gameStack pop];
    CCSprite *playeLast  = [_gameStack pop];
    
    GameState *AIpiece = [_game getSlotFromKey:(NSString*)AILast.userObject];
    GameState *playerPiece = [_game getSlotFromKey:(NSString*)playeLast.userObject];
    
    [AIpiece setState:empty];
    [playerPiece setState:empty];
    
    [self removeChild:AILast cleanup:YES];
    [self removeChild:playeLast cleanup:YES];
    
    CCTexture2D* tex = [[CCTextureCache sharedTextureCache] addImage:@"undo-not-ready.png"];
    [_undo setTexture: tex];
    
    return;
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