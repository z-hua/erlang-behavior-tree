%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(bnode_listener).

-include("btree.hrl").

%% API
-export([forward/2]).
-export([backward/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
forward(Tree, Node) ->
    #bt{status=Status} = Tree,
    #bn{id=NodeID, props=Props, children=[ChildID]} = Node,
    Event   = get_event(Props),
    Trigger = get_trigger(Props),
    LsnKey  = {listen,Trigger,Event},
    Listen  = maps:get(LsnKey, Status, []),
    case lists:member(NodeID, Listen) of
    	true  ->
            Events = maps:get(event, Status, []),
            case lists:member(Event, Events) of
                true  ->
                    bnode_behavior:forward(Tree, ChildID);
                false ->
        			bnode_behavior:backward(Tree#bt{result=?FAILURE}, Node)
            end;
    	false ->
    		Listen2 = lists:reverse([NodeID | Listen]),
    		Tree2   = Tree#bt{
    			result = ?SUCCESS,
    			status = maps:put(LsnKey, Listen2, Status)
    		},
    		bnode_behavior:backward(Tree2, Node)
	end.

backward(Tree, Node) ->
    #bt{result=Result, status=Status} = Tree,
    #bn{id=NodeID, props=Props} = Node,
    Event   = get_event(Props),
    Trigger = get_trigger(Props),
    Cancel  = get_cancel(Props),
    LsnKey  = {listen,Trigger,Event},
    Listen  = maps:get(LsnKey, Status, []),
    if
    	(Cancel == until_succ andalso Result == ?SUCCESS);
    	(Cancel == until_fail andalso Result == ?FAILURE);
    	Cancel == always ->
    		Listen2 = lists:delete(NodeID, Listen),
    		Tree#bt{
                result = ?SUCCESS,
                status = maps:put(LsnKey, Listen2, Status)
            };
    	true ->
    		Tree#bt{result=?SUCCESS}
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_event(Props) ->
    Event = proplists:get_value(event, Props),
    ?_assertRequired(event, Event),
    Event.

get_trigger(Props) ->
    proplists:get_value(trigger, Props, postponed).

get_cancel(Props) ->
    proplists:get_value(cancel, Props, never).
