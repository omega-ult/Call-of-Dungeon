#ifndef  _DOLUA_H_
#define  _DOLUA_H_

#include "cocos2d.h"

USING_NS_CC;

class  Doney
{
public:
    Doney() {

		CCDirector::getInstance()->getScheduler();//.scheduleScriptFunc()
		//ScriptEngineManager::getInstance()->getScriptEngine()->
	}
    ~Doney() {}
	static int getUserndex(){return 10;}
	int getUserKey(){return 20;}
};

#endif