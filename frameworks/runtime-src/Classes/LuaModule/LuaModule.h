#ifndef __LUAMODULE_H_
#define __LUAMODULE_H_
 
extern "C" {
#include "tolua++.h"
#include "tolua_fix.h"
}
 
 
TOLUA_API int tolua_LuaModule_open(lua_State* tolua_S); //�����������ֻҪ�����������������ˣ���ʱ���й����Զ�����������
 
#endif // __LUAMODULE_H_