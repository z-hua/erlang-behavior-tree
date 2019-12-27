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
    #bn{id=NodeID, props=Props} = Node,
	Event  = proplists:get_value(event, Props),
    Listen = maps:get({event,Event}, Status, []),
    case lists:member(NodeID, Listen) of
    	true  ->
			bnode_behavior:backward(Tree#bt{result=?FAILURE}, Node);
    	false ->
    		Listen2 = [NodeID | Listen],
    		Tree2   = Tree#bt{
    			result = ?SUCCESS,
    			status = maps:put({event,Event}, Listen2, Status)
    		},
    		bnode_behavior:backward(Tree2, Node)
	end.

backward(Tree, Node) ->
    #bt{result=Result, status=Status} = Tree,
    #bn{id=NodeID, props=Props} = Node,
    Event  = proplists:get_value(event, Props),
    Cancel = proplists:get_value(cancel, Props, never),
    Listen = maps:get({event,Event}, Status, []),
    if
    	(Cancel == until_succ andalso Result == ?SUCCESS);
    	(Cancel == until_fail andalso Result == ?FAILURE);
    	Cancel == always ->
    		Listen2 = lists:delete(NodeID, Listen),
    		Tree2   = Tree#bt{status=maps:put({event,Event}, Listen2, Status)},
    		bnode_behavior:backward(Tree2, Node);
    	Cancel == until_succ;
    	Cancel == until_fail;
    	Cancel == never ->
    		bnode_behavior:backward(Tree, Node)
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
