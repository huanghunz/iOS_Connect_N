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
        int BOARD_SIZE = 8;
        isPlayerTurn = true;

        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCSprite *player = [CCSprite spriteWithFile:@"player.png"];
        player.position = ccp(player.contentSize.width/2, winSize.height/2);
        [self addChild:player];
        
        [self schedule:@selector(gameLogic:) interval:1.0];
        
        [self setTouchEnabled:YES];
        
        _monsters = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];
        _gameBoard = [[NSMutableDictionary alloc] init];
        
        CCSprite *emptySlot = [CCSprite spriteWithFile:@"slot.png"];
        
        int slotWidth = [emptySlot boundingBox].size.width;
        int slotHeight = [emptySlot boundingBox].size.height;
        
        for (int i = 0; i < BOARD_SIZE; i++ ){
            
            for ( int j = 0; j < BOARD_SIZE; j++){
                CCSprite *emptySlot = [CCSprite spriteWithFile:@"slot.png"
                                                          rect:CGRectMake(0, 0, 25, 25)];
                // Should be an ID
                emptySlot.tag = empty;
                
                // the x, y position is the center of that object,
                // if I do want to place them in "center" center, need to plus half the the width, theoratically
                
                float boardOriX = winSize.width/4;
                emptySlot.position = ccp(boardOriX+(j+1)*slotWidth, (i+1)*slotHeight);
                
                NSString *coor = [self toTupleFrom:j andY:i];
                
                // add to the mutable array
                [_gameBoard setObject:emptySlot forKey:coor];
                
                // add to layer/canvas
                [ self addChild: _gameBoard[coor]];
                
                
            }
        }

        [self schedule:@selector(update:)];
        
        //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
        
    }
    return self;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    // Set up initial location of projectile
//    CGSize winSize = [[CCDirector sharedDirector] winSize];
//    CCSprite *projectile = [CCSprite spriteWithFile:@"projectile.png"
//                                               rect:CGRectMake(0, 0, 20, 20)];
//    projectile.position = ccp(20, winSize.height/2);
//    
//    // Determine offset of location to projectile
//    CGPoint offset = ccpSub(location, projectile.position);
//    
//    // Bail out if you are shooting down or backwards
//    if (offset.x <= 0) return;
//    
//    // Ok to add now - we've double checked position
//    [self addChild:projectile];
//    
//    int realX = winSize.width + (projectile.contentSize.width/2);
//    float ratio = (float) offset.y / (float) offset.x;
//    int realY = (realX * ratio) + projectile.position.y;
//    CGPoint realDest = ccp(realX, realY);
//    
//    // Determine the length of how far you're shooting
//    int offRealX = realX - projectile.position.x;
//    int offRealY = realY - projectile.position.y;
//    float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
//    float velocity = 480/1; // 480pixels/1sec
//    float realMoveDuration = length/velocity;
//    
//    // Move projectile to actual endpoint
//    [projectile runAction:
//     [CCSequence actions:
//      [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
//      [CCCallBlockN actionWithBlock:^(CCNode *node) {
//         [_projectiles removeObject:node];
//         [node removeFromParentAndCleanup:YES];
//    }],
//      nil]];
//    
//    projectile.tag = 2;
//    [_projectiles addObject:projectile];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
    
    /////////////////////////////////////////////////
    
    for ( id key in _gameBoard){
        CCSprite *oneSlot = _gameBoard[key];
     //   CGRect rect = CGRectMake(0, 0, contentSize_.width, contentSize_.height);
      //  return CGRectApplyAffineTransform(rect, [self nodeToParentTransform]);
        
        //TODO: need some arrow above the slots
        if (CGRectContainsPoint(oneSlot.boundingBox, location)){
           
            if (oneSlot.tag == empty){ // do move
                
                int targetCol = [ self getXFromKey:key];
                int targetRow = [ self getYFromKey:key];
               
                // get the lowest empty slot
                while ( [self getNextSlotTag:targetCol and: targetRow] == empty){
                    targetRow -= 1;
                }
                
                
                NSString *targetCoor = [self toTupleFrom:targetCol andY:targetRow];
                CCSprite *targetSlot = _gameBoard[targetCoor];
                
                NSString *color = isPlayerTurn?@"red.png": @"green.png";
                CCSprite *movedRed = [CCSprite spriteWithFile:color
                                                         rect:CGRectMake(0, 0, 20, 20)];
                

                movedRed.position = ccp(oneSlot.position.x, (8+1)*[oneSlot boundingBox].size.height);
                [ self addChild:movedRed];
                
                CGPoint movedDest = ccp(oneSlot.position.x, targetSlot.position.y);
                
                
                [self setTouchEnabled:NO];

                [movedRed runAction:
                 [CCSequence actions:
                  [CCMoveTo actionWithDuration: 1 position:movedDest],
                  [CCCallBlockN actionWithBlock:^(CCNode *node) {
                    // [_projectiles removeObject:node];
                     [node removeFromParentAndCleanup:YES];
                     
                     [targetSlot setTexture:[[CCTextureCache sharedTextureCache] addImage:color]];
                     
                     
                     [self setTouchEnabled:YES];

                     
                 }],
                  nil]];
                
        
                targetSlot.tag = isPlayerTurn?player:opponment;
                isPlayerTurn = !isPlayerTurn;
               
                bool won = [self checkWin:targetCol and:targetRow with:targetSlot.tag];
                if (won)
                    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
                    

            }
        }
        
       
    }
}

- (void)update:(ccTime)dt {
    
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    for (CCSprite *projectile in _projectiles) {
        
        NSMutableArray *monstersToDelete = [[NSMutableArray alloc] init];
        for (CCSprite *monster in _monsters) {
            
            if (CGRectIntersectsRect(projectile.boundingBox, monster.boundingBox)) {
                [monstersToDelete addObject:monster];
            }
        }
        
        for (CCSprite *monster in monstersToDelete) {
            [_monsters removeObject:monster];
            [self removeChild:monster cleanup:YES];
            
            _monstersDestroyed++;
            if (_monstersDestroyed > 30) {
                CCScene *gameOverScene = [GameOverLayer sceneWithWon:YES];
                [[CCDirector sharedDirector] replaceScene:gameOverScene];
            }
        }
        
        if (monstersToDelete.count > 0) {
            [projectilesToDelete addObject:projectile];
        }
        [monstersToDelete release];
    }
    
    for (CCSprite *projectile in projectilesToDelete) {
        [_projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
    }
    [projectilesToDelete release];
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [_gameBoard release];
    _gameBoard = nil;
 
    [super dealloc];
}


- (bool) checkWin:(int)x and:(int)y with:(NSInteger)whosTurn{
    // hor ver dia
    int horConnected = 0, verConnected = 0, leftTopRightBotConnected = 0, RightTopLeftBotConnected = 0;
    int connectN = 4;
    CCSprite *oneSlot = nil;
    //int range = connectN*2+1;
    
    for (int leftToRight = connectN*-1; leftToRight<= connectN; leftToRight++){
        
        // horizontal
        NSString* horKey = [self toTupleFrom:leftToRight+x andY:y];
        if ( [_gameBoard objectForKey:horKey] != nil){
            oneSlot = _gameBoard[horKey];
            if (horConnected == 4) return true;
            
            horConnected = (oneSlot.tag == whosTurn)? horConnected+1 :0;
        }
        
        // vertical
        NSString* verKey = [self toTupleFrom:x andY:leftToRight+y];
        if ( [_gameBoard objectForKey:horKey] != nil){
            oneSlot = _gameBoard[verKey];
            if (verConnected == 4) return true;
            
            verConnected = (oneSlot.tag == whosTurn)? verConnected+1 :0;
            
        }
        
        // dia left top to right bot
        NSString* leftTopKey = [self toTupleFrom:leftToRight+x andY:leftToRight+y];
        if ( [_gameBoard objectForKey:leftTopKey] != nil){
            oneSlot = _gameBoard[verKey];
            if (leftTopRightBotConnected == 4) return true;
            
            leftTopRightBotConnected = (oneSlot.tag == whosTurn)? leftTopRightBotConnected+1 :0;
            
        }

        // dia right bot to left top
        NSString* RightBotKey = [self toTupleFrom:leftToRight+x andY: leftToRight*-1 + y];
        if ( [_gameBoard objectForKey:RightBotKey] != nil){
            oneSlot = _gameBoard[verKey];
            if (RightTopLeftBotConnected  == 4) return true;
            
           RightTopLeftBotConnected = (oneSlot.tag == whosTurn)? RightTopLeftBotConnected + 1 :0;
            
        }

        
    }
    
    return false;
//    int connected = 0;
//    
//    
//    // horzontal check
//    for (int hor = x-4; hor <= x+4; hor++){
//        NSString* key = [self toTupleFrom:hor andY:y];
//        if ( [_gameBoard objectForKey:key] != nil){
//            CCSprite *oneSlot = _gameBoard[key];
//            if (connected == 4){
//                return true;
//            }
//            if (oneSlot.tag == whosTurn){
//                connected++;
//            }
//            else{
//                connected =0;
//            }
//        }
//    }
//    
//    // vertical check
//    for (int ver = y-4; ver <= y+4; ver++){
//        NSString* key = [self toTupleFrom:x andY:ver];
//        if ( [_gameBoard objectForKey:key] != nil){
//            CCSprite *oneSlot = _gameBoard[key];
//            if (connected == 4){
//                return true;
//            }
//            if (oneSlot.tag == whosTurn){
//                connected++;
//            }
//            else{
//                connected = 0;
//            }
//        }
//        
//    }
//    
//    for (int hor = x - 4; hor <= x+4; hor++){
//        for (int topDownDia = 0; topDownDia <= y+4; topDownDia++ ){
//            NSString* key = [self toTupleFrom:hor andY:topDownDia];
//            if ( [_gameBoard] objectForKey:key] != nil){
//                CCSprite *oneSlot = _gameBoard[key];
//                if (connected == 4){
//                    return true;
//                }
//                if (oneSlot.tag == whosTurn){
//                    connected++;
//                }
//                else{
//                    connected =0;
//                }
//            }
//        }
//    }
  
}

- (NSString*) toTupleFrom:(int)x andY: (int)y{
    
    NSString *coor = [ NSString stringWithFormat: @"(%d,%d)",x, y];
    
    return coor;
}

- (int) getYFromKey:(id)key{
    NSString *tuple = (NSString*)key;
    NSString * yChar = [tuple substringWithRange:NSMakeRange(3, 1)];
    int y = [yChar intValue];
    
    return y;
};

- (int) getXFromKey:(id)key{
    NSString *tuple = (NSString*)key;
    NSString * xChar = [tuple substringWithRange:NSMakeRange(1, 1)];
    int x = [xChar intValue];
    
    return x;
};

- (CCSprite*) getNextSlot:(id)key{
    //NSString *tuple = (NSString*)key;
    int x = [self getXFromKey:key];
    int y = [self getYFromKey:key];
    CCSprite *lowerSlot = nil;
    
    if (y > 0){
        y -= 1;
        NSString* lowerCoor =  [self toTupleFrom:x andY:y];
        lowerSlot = _gameBoard[lowerCoor];
    }
    
    return lowerSlot;

}

- (CCSprite*) getNextSlot:(int)x and:(int)y{
    CCSprite *lowerSlot = nil;
    
    if (y > 0){
        y -= 1;
        NSString* lowerCoor =  [self toTupleFrom:x andY:y];
        lowerSlot = _gameBoard[lowerCoor];
    }
    
    return lowerSlot;
}

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

- (NSInteger) getNextSlotTag:(id)key{
    int x = [self getXFromKey:key];
    int y = [self getYFromKey:key];
    
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
