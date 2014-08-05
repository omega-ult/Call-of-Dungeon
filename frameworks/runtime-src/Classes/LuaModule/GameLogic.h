// created [8/5/2014 gzpanqi]

#ifndef _GAMELOGIC_H_
#define _GAMELOGIC_H_

#include "cocos2d.h"
#include "Singleton.h"

USING_NS_CC;

class GameLogic : public Singleton<GameLogic>
{
public:
	GameLogic();
	virtual ~GameLogic();

	void	initialize();

	int boooooo() { return 100; }

	void	update();

	void	shutdown();

	static GameLogic*	getInstance();
private:

};


#endif