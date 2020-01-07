%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(monster_ai).

-include_lib("btree/include/btree.hrl").

%% API
-compile([export_all]).
-compile(nowarn_export_all).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
born() ->
	io:format("born~n"),
	monster_util:set_hp(10),
	?SUCCESS.

die() ->
	io:format("die~n"),
	?SUCCESS.

guard() ->
	case rand:uniform(100) >= 50 of
		true  ->
			io:format("guard, found~n"),
			?SUCCESS;
		false ->
			io:format("guard, not found~n"),
			?FAILURE
	end.

attack() ->
	io:format("attack~n"),
	?SUCCESS.

patrol() ->
	io:format("patrol~n"),
	?SUCCESS.

speak() ->
	io:format("speak~n"),
	?SUCCESS.

idle() ->
	io:format("idle~n"),
	?SUCCESS.

bleed() ->
	io:format("bleed~n"),
	monster_util:del_hp(),
	?SUCCESS.

reborn() ->
	io:format("reborn~n"),
	monster_util:set_hp(10),
	?SUCCESS.


is_dead() ->
	Hp = monster_util:get_hp(),
	io:format("is_dead: ~w~n", [Hp]),
	Hp =< 0.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
