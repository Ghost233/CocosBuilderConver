//
//  HelloWorldLayer.m
//  CocosBuilderConver
//
//  Created by Ghost on 12-12-7.
//  Copyright Ghost233 2012年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

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

-(void) deep:(NSDictionary*)dict withStore:(NSMutableDictionary*)store
{
    NSMutableArray *property = store[@"property"];
    NSMutableArray *ccmenuSelector = store[@"ccmenuSelector"];
    NSString *name = [dict objectForKey:@"memberVarAssignmentName"];
    if (!(name == NULL || name.length == 0))
    {
        NSString *class = [dict objectForKey:@"customClass"];
        if (class == NULL || class.length == 0)
        {
            class = [dict objectForKey:@"baseClass"];
            [property addObject:@{@"base":@YES, @"name":name, @"class":class}];
        }
        else
        {
            [property addObject:@{@"base":@NO, @"name":name, @"class":class}];
        }
    }
    
    for (NSDictionary *tempDict in [dict objectForKey:@"properties"])
    {
        if ([tempDict[@"type"] isEqualTo:@"Block"])
        {
            [ccmenuSelector addObject:@{@"name": tempDict[@"value"][0]}];
        }
    }
    
    for (NSDictionary *nextDict in dict[@"children"])
    {
        [self deep:nextDict withStore:store];
    }
}

#define nextLine @"\n"

-(NSString*) makeHeadFileWithClassName:(NSDictionary*)basic withStore:(NSDictionary*)store
{
    NSString *className = basic[@"className"];
    NSString *author = basic[@"author"];
    NSString *time = basic[@"time"];
    NSString *project = basic[@"project"];
    
    NSArray *property = store[@"property"];
    NSArray *ccmenuSelector = store[@"ccmenuSelector"];
    
    NSMutableString *finalString = [NSMutableString string];
    [finalString appendFormat:@"//%@", nextLine];
    [finalString appendFormat:@"//  %@.h%@", className, nextLine];
    [finalString appendFormat:@"//  %@%@", project, nextLine];
    [finalString appendFormat:@"//%@", nextLine];
    [finalString appendFormat:@"//  Created by %@ on %@.%@", author, time, nextLine];
    [finalString appendFormat:@"//%@", nextLine];
    [finalString appendFormat:@"//%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"#ifndef __%@__%@__%@", project, className, nextLine];
    [finalString appendFormat:@"#define __%@__%@__%@", project, className, nextLine];
    [finalString appendFormat:@"%@", nextLine];
    
    
    
    [finalString appendFormat:@"#include \"GameConfig.h\"%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"class %@ : public CCLayer, public CCBSelectorResolver, public CCBMemberVariableAssigner%@", className, nextLine];
    [finalString appendFormat:@"{%@", nextLine];
    
    
    [finalString appendFormat:@"public:%@", nextLine];
    [finalString appendFormat:@"    static %@* createFromCCBI(CCObject *owner);%@", className, nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"    CCB_STATIC_NEW_AUTORELEASE_OBJECT_WITH_INIT_METHOD(%@, create);%@", className, nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"    %@();%@", className, nextLine];
    [finalString appendFormat:@"    virtual ~%@();%@", className, nextLine];
    [finalString appendFormat:@"    virtual bool init();%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"    void initNext();%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"    virtual SEL_MenuHandler onResolveCCBCCMenuItemSelector(CCObject * pTarget, CCString * pSelectorName);%@", nextLine];
    [finalString appendFormat:@"    virtual SEL_CCControlHandler onResolveCCBCCControlSelector(CCObject * pTarget, CCString * pSelectorName);%@", nextLine];
    [finalString appendFormat:@"    virtual bool onAssignCCBMemberVariable(CCObject * pTarget, CCString * pMemberVariableName, CCNode * pNode);%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    
    NSMutableSet *set = [NSMutableSet set];
    for (NSDictionary *dict in ccmenuSelector)
    {
        [set addObject:dict[@"name"]];
    }
    for (NSString *name in set)
    {
        if ([name isEqualTo:@""]) continue;
        [finalString appendFormat:@"    void %@(CCObject* pSender);%@", name, nextLine];
    }
    
    [finalString appendFormat:@"%@", nextLine];
    
    for (NSDictionary *dict in property)
    {
        NSString *name = dict[@"name"];
        if ([name isEqualTo:@""]) continue;
        
        unichar c = [name characterAtIndex:0];
        if (!(c >= 65 && c <= 90)) c -= 32;
        name = [NSString stringWithFormat:@"%c%@", c, [name substringFromIndex:1]];
        
        [finalString appendFormat:@"    CC_SYNTHESIZE_RETAIN(%@*, %@, %@);%@", dict[@"class"], dict[@"name"], name, nextLine];
    }
    
    [finalString appendFormat:@"};%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"#endif /* defined(__%@__%@__) */%@", project, className, nextLine];
    return finalString;
}

-(NSString*) makeCPPFileWithClassName:(NSDictionary*)basic withStore:(NSDictionary*)store
{
    NSString *className = basic[@"className"];
    NSString *author = basic[@"author"];
    NSString *time = basic[@"time"];
    NSString *project = basic[@"project"];
    
    NSArray *property = store[@"property"];
    NSArray *ccmenuSelector = store[@"ccmenuSelector"];
    
    NSMutableSet *set = [NSMutableSet set];
    for (NSDictionary *dict in ccmenuSelector)
    {
        [set addObject:dict[@"name"]];
    }
    
    NSMutableString *finalString = [NSMutableString string];
    [finalString appendFormat:@"//%@", nextLine];
    [finalString appendFormat:@"//  %@.cpp%@", className, nextLine];
    [finalString appendFormat:@"//  %@%@", project, nextLine];
    [finalString appendFormat:@"//%@", nextLine];
    [finalString appendFormat:@"//  Created by %@ on %@.%@", author, time, nextLine];
    [finalString appendFormat:@"//%@", nextLine];
    [finalString appendFormat:@"//%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    
    
    
    [finalString appendFormat:@"#include \"%@.h\"%@", className, nextLine];
    [finalString appendFormat:@"#include \"%@Loader.h\"%@", className, nextLine];
    [finalString appendFormat:@"%@", nextLine];
    
    [finalString appendFormat:@"%@* %@::createFromCCBI(CCObject *owner)%@", className, className, nextLine];
    [finalString appendFormat:@"{%@", nextLine];
    [finalString appendFormat:@"    CCNodeLoaderLibrary * ccNodeLoaderLibrary = CCNodeLoaderLibrary::newDefaultCCNodeLoaderLibrary();%@", nextLine];
    [finalString appendFormat:@"    ccNodeLoaderLibrary->registerCCNodeLoader(\"%@\", %@Loader::loader());%@", className, className, nextLine];
    [finalString appendFormat:@"    cocos2d::extension::CCBReader * ccbReader = new cocos2d::extension::CCBReader(ccNodeLoaderLibrary);%@", nextLine];
    [finalString appendFormat:@"    %@ * node = (%@*) ccbReader->readNodeGraphFromFile(\"%@.ccbi\", owner);%@", className, className, className, nextLine];
    [finalString appendFormat:@"    ccbReader->release();%@", nextLine];
    [finalString appendFormat:@"    return node;%@", nextLine];
    [finalString appendFormat:@"}%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"%@::%@()%@", className, className, nextLine];
    [finalString appendFormat:@"{%@", nextLine];
    for (NSDictionary *dict in property)
    {
        NSString *name = dict[@"name"];
        
        if ([name isEqualTo:@""]) continue;
        
        [finalString appendFormat:@"    %@ = NULL;%@", name, nextLine];
    }
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"}%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"%@::~%@()%@", className, className, nextLine];
    [finalString appendFormat:@"{%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"}%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"bool %@::init()%@", className, nextLine];
    [finalString appendFormat:@"{%@", nextLine];
    [finalString appendFormat:@"    return true;%@", nextLine];
    [finalString appendFormat:@"}%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"void %@::initNext()%@", className, nextLine];
    [finalString appendFormat:@"{%@", nextLine];
    [finalString appendFormat:@"    return;%@", nextLine];
    [finalString appendFormat:@"}%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"SEL_MenuHandler %@::onResolveCCBCCMenuItemSelector(CCObject * pTarget, CCString * pSelectorName)%@", className, nextLine];
    [finalString appendFormat:@"{%@", nextLine];
    for (NSString *name in set)
    {
        if ([name isEqualTo:@""]) continue;
        [finalString appendFormat:@"    CCB_SELECTORRESOLVER_CCMENUITEM_GLUE(this, \"%@\", %@::%@);%@", name, className, name, nextLine];
    }
    [finalString appendFormat:@"    return NULL;%@", nextLine];
    [finalString appendFormat:@"}%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"SEL_CCControlHandler %@::onResolveCCBCCControlSelector(CCObject * pTarget, CCString * pSelectorName)%@", className, nextLine];
    [finalString appendFormat:@"{%@", nextLine];
    [finalString appendFormat:@"    return NULL;%@", nextLine]; 
    [finalString appendFormat:@"}%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"bool %@::onAssignCCBMemberVariable(CCObject * pTarget, CCString * pMemberVariableName, CCNode * pNode)%@", className, nextLine];
    [finalString appendFormat:@"{%@", nextLine];
    for (NSDictionary *dict in property)
    {
        NSString *name = dict[@"name"];
        NSString *class = dict[@"class"];
        
        if ([name isEqualTo:@""]) continue;

        [finalString appendFormat:@"    CCB_MEMBERVARIABLEASSIGNER_GLUE(this, \"%@\", %@*, %@);%@", name, class, name, nextLine];
    }
    [finalString appendFormat:@"    return false;%@", nextLine];
    [finalString appendFormat:@"}%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    
    for (NSString *name in set)
    {
        if ([name isEqualTo:@""]) continue;
        
        [finalString appendFormat:@"void %@::%@(CCObject* pSender)%@", className, name, nextLine];
        [finalString appendFormat:@"{%@", nextLine];
        [finalString appendFormat:@"    CCLOG(\"%@\");%@", name, nextLine];
        [finalString appendFormat:@"}%@", nextLine];
        [finalString appendFormat:@"%@", nextLine];
    }
    
    return finalString;
}

-(NSString*) makeHeadLoaderFileWithClassName:(NSDictionary*)basic withStore:(NSDictionary*)store
{
    NSString *className = basic[@"className"];
    NSString *author = basic[@"author"];
    NSString *time = basic[@"time"];
    NSString *project = basic[@"project"];
    
    NSMutableString *finalString = [NSMutableString string];
    [finalString appendFormat:@"//%@", nextLine];
    [finalString appendFormat:@"//  %@Loader.h%@", className, nextLine];
    [finalString appendFormat:@"//  %@%@", project, nextLine];
    [finalString appendFormat:@"//%@", nextLine];
    [finalString appendFormat:@"//  Created by %@ on %@.%@", author, time, nextLine];
    [finalString appendFormat:@"//%@", nextLine];
    [finalString appendFormat:@"//%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"#ifndef __%@__%@Loader__%@", project, className, nextLine];
    [finalString appendFormat:@"#define __%@__%@Loader__%@", project, className, nextLine];
    [finalString appendFormat:@"%@", nextLine];
    
    
    
    [finalString appendFormat:@"#include \"%@.h\"%@", className, nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"class CCBReader;%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"class %@Loader : public CCLayerLoader%@", className, nextLine];
    [finalString appendFormat:@"{%@", nextLine];
    
    
    [finalString appendFormat:@"public:%@", nextLine];
    [finalString appendFormat:@"    CCB_STATIC_NEW_AUTORELEASE_OBJECT_METHOD(%@Loader, loader);%@", className, nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"protected:%@", nextLine];
    [finalString appendFormat:@"    CCB_VIRTUAL_NEW_AUTORELEASE_CREATECCNODE_METHOD(%@);%@", className, nextLine];
    [finalString appendFormat:@"%@", nextLine];
    
    [finalString appendFormat:@"};%@", nextLine];
    [finalString appendFormat:@"%@", nextLine];
    [finalString appendFormat:@"#endif /* defined(__%@__%@Loader__) */%@", project, className, nextLine];
    return finalString;
}

-(void) conver:(NSString*)filePath saveWithPath:(NSString*)savePath
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    dict = [dict objectForKey:@"nodeGraph"];
    NSString *rootClassName = [dict objectForKey:@"customClass"];
    NSString *author = @"Ghost";
    NSString *time = @"12-12-21";
    NSString *project = @"Tests";

    NSMutableDictionary *store = [NSMutableDictionary dictionary];
    store[@"property"] = [NSMutableArray array];
    store[@"ccmenuSelector"] = [NSMutableArray array];
    [self deep:dict withStore:store];
    NSDictionary *basic = @{@"className":rootClassName, @"author":author, @"time":time, @"project":project};
    NSString *headFileContent = [self makeHeadFileWithClassName:basic withStore:store];
    
    NSError *error;
    
    NSString *newFilePath = [NSString stringWithFormat:@"%@/%@.h", savePath, rootClassName];
    [headFileContent writeToFile:newFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    newFilePath = [NSString stringWithFormat:@"%@/%@.cpp", savePath, rootClassName];
    NSString *CPPFileContent = [self makeCPPFileWithClassName:basic withStore:store];
    [CPPFileContent writeToFile:newFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    newFilePath = [NSString stringWithFormat:@"%@/%@Loader.h", savePath, rootClassName];
    NSString *HearLoaderFileContent = [self makeHeadLoaderFileWithClassName:basic withStore:store];
    [HearLoaderFileContent writeToFile:newFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    NSLog(@"%@ %@", filePath, rootClassName);
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init]) ) {
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hello World" fontName:@"Marker Felt" fontSize:64];

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];
	}
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentDir = @"/CocosBuilderConver";
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    
    NSLog(@"%d", [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/source", documentDir] withIntermediateDirectories:YES attributes:NULL error:&error]);
    
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
  
    for (NSString *filePath in fileList)
    {
        NSArray *array = [filePath componentsSeparatedByString:@"."];
        if ([array.lastObject isEqualTo:@"ccb"])
        {
            NSString *fileFinalPath = [[documentDir stringByAppendingString:@"/"] stringByAppendingString:filePath];
            [self conver:fileFinalPath saveWithPath:[documentDir stringByAppendingString:@"/source"]];
        }
    }
    
    
    

    exit(0);
    
    
    
    
    
    
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
