%% See LICENSE for licensing information.
-module(online).

-export([start/0,
         stop/0]).


%% +-----------------------------------------------------------------+
%% | INTERFACE FUNCTIONS                                             |
%% +-----------------------------------------------------------------+

start() ->
    up_me(online, permanent).

stop() ->
    application:stop(online).

%% +-----------------------------------------------------------------+
%% | PRIVATE FUNCTIONS                                               |
%% +-----------------------------------------------------------------+

up_me(App, Type) ->
    up_me(App, Type, application:start(App, Type)).

up_me(_App, _Type, ok) -> ok;
up_me(_App, _Type, {error, {already_started, _App}}) -> ok;
up_me(App, Type, {error, {not_started, Dep}}) ->
	ok = up_me(Dep, Type),
	up_me(App, Type);
up_me(App, _Type, {error, Reason}) ->
	erlang:error({app_start_failed, App, Reason}).
