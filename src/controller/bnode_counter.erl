%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(bnode_counter).

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
    MaxTimes = proplists:get_value(times, Props),
    CurTimes = maps:get(NodeID, Status, MaxTimes),
    case CurTimes > 0 of
    	true  ->
    		Tree2 = Tree#bt{status=maps:put(NodeID, CurTimes, Status)},
		    bnode_behavior:forward(Tree2, ChildID);
		false ->
			bnode_behavior:backward(Tree#bt{result=?FAILURE}, Node)
    end.


backward(Tree, Node) ->
    #bt{result=Result, status=Status} = Tree,
    #bn{id=NodeID, props=Props} = Node,
    CurTimes = maps:get(NodeID, Status),
    NewTimes = case proplists:get_value(count, Props, always) of
    	'when_succ' when Result == ?SUCCESS ->
    		CurTimes + 1;
    	'when_succ' ->
    		CurTimes;
    	'when_fail' when Result == ?FAILURE ->
    		CurTimes + 1;
    	'when_fail' ->
    		CurTimes;
    	'always' ->
    		CurTimes + 1
    end,
    Tree2 = Tree#bt{status=maps:put(NodeID, NewTimes, Status)},
    bnode_behavior:backward(Tree2, Node).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
