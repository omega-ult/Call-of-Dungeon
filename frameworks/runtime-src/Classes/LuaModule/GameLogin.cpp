// created [8/8/2014 gzpanqi]

#include "GameLogin.h"



bool GameLoginAccount::onTextFieldAttachWithIME( TextFieldTTF * sender )
{
	return true;
}

bool GameLoginAccount::onTextFieldDetachWithIME( TextFieldTTF * sender )
{
		return true;
}

bool GameLoginAccount::onTextFieldInsertText( TextFieldTTF * sender, const char * text, int nLen )
{
		return true;
}

bool GameLoginAccount::onTextFieldDeleteBackward( TextFieldTTF * sender, const char * delText, int nLen )
{
		return true;
}

GameLoginAccount::GameLoginAccount()
{

}

GameLogin::GameLogin()
{
	mScene = Scene::create();

}

GameLogin::~GameLogin()
{
	
}

bool GameLogin::init()
{
	if ( !Layer::init() )
	{
		return false;
	}

	mScene->addChild(this);
	Size visibleSize = Director::getInstance()->getVisibleSize();
	Point origin = Director::getInstance()->getVisibleOrigin();

	Sprite* bg = Sprite::create("res/farm.jpg");
	//bg->setPosition(origin.x + visibleSize.width/2 + 80, origin.y + visibleSize.height/2);
	addChild(bg);

	mAccountInput = TextFieldTTF::textFieldWithPlaceHolder("Account","Arial", 24);
	mAccountInput->setPosition(origin.x + visibleSize.width/2, visibleSize.height/2 );
	mAccountInput->setDelegate(this);
	addChild(mAccountInput);
	mAccountInput->attachWithIME();

	mPasswordInput = TextFieldTTF::textFieldWithPlaceHolder("Password","Arial", 24);
	mPasswordInput->setPosition(origin.x + visibleSize.width/2 + 80, visibleSize.height/2 );
	mPasswordInput->setDelegate(this);
	addChild(mPasswordInput);
//	mPasswordInput->attachWithIME();

	return true;
}

Scene* GameLogin::getScene()
{
	return mScene;
}

bool GameLogin::onTextFieldAttachWithIME( TextFieldTTF * sender )
{
	CCLOG("open");
	return true;
}

bool GameLogin::onTextFieldDetachWithIME( TextFieldTTF * sender )
{
	CCLOG("close");
	return false;
}

bool GameLogin::onTextFieldInsertText( TextFieldTTF * sender, const char * text, int nLen )
{
	CCLOG("input...");
	return false;
}

bool GameLogin::onTextFieldDeleteBackward( TextFieldTTF * sender, const char * delText, int nLen )
{
	CCLOG("del");
	return false;
}
