// created [8/8/2014 gzpanqi]

#ifndef _GAMELOGIN_H_
#define _GAMELOGIN_H_


#include "cocos2d.h"


USING_NS_CC;

class GameLoginAccount : public TextFieldDelegate
{
public:
	GameLoginAccount();
	//��������
	virtual bool onTextFieldAttachWithIME(TextFieldTTF * sender);

	//�رռ��� 
	virtual bool onTextFieldDetachWithIME(TextFieldTTF * sender);

	//����ʱ  
	virtual bool onTextFieldInsertText(TextFieldTTF * sender, const char * text, int nLen);
	//ɾ��ʱ   
	virtual bool onTextFieldDeleteBackward(TextFieldTTF * sender, const char * delText, int nLen);

	TextFieldTTF*	getAccountInputControl() { return mAccountInput; }
	TextFieldTTF*	getPasswordInputControl() { return mPasswordInput; }

protected:
	TextFieldTTF*	mAccountInput;
	TextFieldTTF*	mPasswordInput;
};

class GameLogin : public Layer, public TextFieldDelegate
{
public:
	GameLogin();
	~GameLogin();
	
	virtual bool init();

	Scene*		getScene();
	//��������
	virtual bool onTextFieldAttachWithIME(TextFieldTTF * sender);

	//�رռ��� 
	virtual bool onTextFieldDetachWithIME(TextFieldTTF * sender);

	//����ʱ  
	virtual bool onTextFieldInsertText(TextFieldTTF * sender, const char * text, int nLen);
	//ɾ��ʱ   
	virtual bool onTextFieldDeleteBackward(TextFieldTTF * sender, const char * delText, int nLen);

	CREATE_FUNC(GameLogin);
protected:
	Scene*	mScene;
	TextFieldTTF*	mAccountInput;
	TextFieldTTF*	mPasswordInput;
};


#endif