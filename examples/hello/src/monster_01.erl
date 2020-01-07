%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(monster_01).

-behaviour(gen_server).

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).

-define(SERVER, ?MODULE).
-record(state, {ai}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	Ref = btree:new("./config/ai01.xml"),
	timer:send_interval(timer:seconds(1), loop),
	{ok, #state{ai=Ref}}.

handle_call(_Request, _From, State) ->
	{reply, {error, unknown_call}, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info(loop, State) ->
	io:format("---begin loop---~n"),
	btree:run(State#state.ai),
	io:format("---end loop---~n~n"),
	{noreply, State};

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
