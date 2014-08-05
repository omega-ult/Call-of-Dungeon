#ifndef _SINGLETON_H_
#define _SINGLETON_H_

#include <assert.h>

template <class T>
class Singleton
{
	// forbidden operation.
private:
	Singleton(const Singleton<T> &);
	Singleton& operator=(const Singleton<T> &);

	static T* & msSingleton()
	{
		static T* msSingleton_ =0 ;
		return msSingleton_;
	}



public:
	// father class will do for sub-class
	Singleton(void)
	{
		assert(!(msSingleton()));
		msSingleton() = static_cast<T*>(this);
	}
	// this will be call after sub-class's destruction 
	virtual ~Singleton(void)
	{
		assert((msSingleton()));
		msSingleton() = 0;
	}
	// use _yourClass_::getSingleton() to get a reference of the class.
	static T& getSingleton(void)
	{
		assert((msSingleton()));
		return (*msSingleton());
	}
	// use _yourClass_::getSingletonPtr() to get a pointer to the class.
	static T* getSingletonPtr(void)
	{
		return (msSingleton());
	}
};

#endif