/*
** Lua binding: LuaModule
** Generated automatically by tolua++-1.0.92 on 08/06/14 21:22:58.
*/

#ifndef __cplusplus
#include "stdlib.h"
#endif
#include "string.h"

#include "tolua++.h"

/* Exported function */
TOLUA_API int  tolua_LuaModule_open (lua_State* tolua_S);

#include "LuaModule.h"
#include "Test.h"
#include "GameLogic.h"

/* function to release collected object via destructor */
#ifdef __cplusplus

static int tolua_collect_Doney (lua_State* tolua_S)
{
 Doney* self = (Doney*) tolua_tousertype(tolua_S,1,0);
	Mtolua_delete(self);
	return 0;
}
#endif


/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"GameLogic");
 tolua_usertype(tolua_S,"Doney");
}

/* method: new of class  Doney */
#ifndef TOLUA_DISABLE_tolua_LuaModule_Doney_new00
static int tolua_LuaModule_Doney_new00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"Doney",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   Doney* tolua_ret = (Doney*)  Mtolua_new((Doney)());
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"Doney");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'new'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: new_local of class  Doney */
#ifndef TOLUA_DISABLE_tolua_LuaModule_Doney_new00_local
static int tolua_LuaModule_Doney_new00_local(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"Doney",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   Doney* tolua_ret = (Doney*)  Mtolua_new((Doney)());
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"Doney");
    tolua_register_gc(tolua_S,lua_gettop(tolua_S));
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'new'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getUserndex of class  Doney */
#ifndef TOLUA_DISABLE_tolua_LuaModule_Doney_getUserndex00
static int tolua_LuaModule_Doney_getUserndex00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"Doney",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   int tolua_ret = (int)  Doney::getUserndex();
   tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getUserndex'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getUserKey of class  Doney */
#ifndef TOLUA_DISABLE_tolua_LuaModule_Doney_getUserKey00
static int tolua_LuaModule_Doney_getUserKey00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"Doney",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  Doney* self = (Doney*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getUserKey'", NULL);
#endif
  {
   int tolua_ret = (int)  self->getUserKey();
   tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getUserKey'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getInstance of class  GameLogic */
#ifndef TOLUA_DISABLE_tolua_LuaModule_GameLogic_getInstance00
static int tolua_LuaModule_GameLogic_getInstance00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"GameLogic",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   GameLogic* tolua_ret = (GameLogic*)  GameLogic::getInstance();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"GameLogic");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getInstance'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: boooooo of class  GameLogic */
#ifndef TOLUA_DISABLE_tolua_LuaModule_GameLogic_boooooo00
static int tolua_LuaModule_GameLogic_boooooo00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"GameLogic",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  GameLogic* self = (GameLogic*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'boooooo'", NULL);
#endif
  {
   int tolua_ret = (int)  self->boooooo();
   tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'boooooo'.",&tolua_err);
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
  #ifdef __cplusplus
  tolua_cclass(tolua_S,"Doney","Doney","",tolua_collect_Doney);
  #else
  tolua_cclass(tolua_S,"Doney","Doney","",NULL);
  #endif
  tolua_beginmodule(tolua_S,"Doney");
   tolua_function(tolua_S,"new",tolua_LuaModule_Doney_new00);
   tolua_function(tolua_S,"new_local",tolua_LuaModule_Doney_new00_local);
   tolua_function(tolua_S,".call",tolua_LuaModule_Doney_new00_local);
   tolua_function(tolua_S,"getUserndex",tolua_LuaModule_Doney_getUserndex00);
   tolua_function(tolua_S,"getUserKey",tolua_LuaModule_Doney_getUserKey00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"GameLogic","GameLogic","",NULL);
  tolua_beginmodule(tolua_S,"GameLogic");
   tolua_function(tolua_S,"getInstance",tolua_LuaModule_GameLogic_getInstance00);
   tolua_function(tolua_S,"boooooo",tolua_LuaModule_GameLogic_boooooo00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_LuaModule (lua_State* tolua_S) {
 return tolua_LuaModule_open(tolua_S);
};
#endif

