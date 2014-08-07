#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"

#include "struct.c"

#include "LuaModule.h"

#include "GameLogic.h"



using namespace CocosDenshion;

USING_NS_CC;
using namespace std;

AppDelegate::AppDelegate()
{
	mGameLogic = new GameLogic();
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
	delete mGameLogic;
}

bool AppDelegate::applicationDidFinishLaunching()
{
    auto engine = LuaEngine::getInstance();
	tolua_LuaModule_open(engine->getLuaStack()->getLuaState());
	luaopen_struct(engine->getLuaStack()->getLuaState());
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    if (engine->executeScriptFile("src/main.lua")) {
        return false;
    }

    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();

    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();

    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}
