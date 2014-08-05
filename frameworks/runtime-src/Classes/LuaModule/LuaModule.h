#ifndef __LUAMODULE_H_
#define __LUAMODULE_H_
 
extern "C" {
#include "tolua++.h"
#include "tolua_fix.h"
}
 
 
TOLUA_API int tolua_LuaModule_open(lua_State* tolua_S); //这个函数我们只要在这里先声明就行了，到时候有工具自动给我们生成
 
#endif // __LUAMODULE_H_