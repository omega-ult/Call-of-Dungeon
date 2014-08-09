/*
** Lua binding: LuaModule
** Generated automatically by tolua++-1.0.92 on 08/09/14 11:15:43.
*/

#ifndef __cplusplus
#include "stdlib.h"
#endif
#include "string.h"

#include "tolua++.h"

/* Exported function */
TOLUA_API int  tolua_LuaModule_open (lua_State* tolua_S);

#include "LuaModule.h"
#include "GameLogic.h"
#include "GameLogin.h"

/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"GameLogin");
 tolua_usertype(tolua_S,"cocos2d::Scene");
}

/* method: getScene of class  GameLogin */
#ifndef TOLUA_DISABLE_tolua_LuaModule_GameLogin_getScene00
static int tolua_LuaModule_GameLogin_getScene00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"GameLogin",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  GameLogin* self = (GameLogin*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getScene'", NULL);
#endif
  {
   cocos2d::Scene* tolua_ret = (cocos2d::Scene*)  self->getScene();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"cocos2d::Scene");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getScene'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class  GameLogin */
#ifndef TOLUA_DISABLE_tolua_LuaModule_GameLogin_create00
static int tolua_LuaModule_GameLogin_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"GameLogin",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   GameLogin* tolua_ret = (GameLogin*)  GameLogin::create();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"GameLogin");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_LuaModule_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"GameLogin","GameLogin","",NULL);
  tolua_beginmodule(tolua_S,"GameLogin");
   tolua_function(tolua_S,"getScene",tolua_LuaModule_GameLogin_getScene00);
   tolua_function(tolua_S,"create",tolua_LuaModule_GameLogin_create00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_LuaModule (lua_State* tolua_S) {
 return tolua_LuaModule_open(tolua_S);
};
#endif

