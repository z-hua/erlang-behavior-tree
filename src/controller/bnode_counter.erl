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
    #bn{id=NodeID, props=Props, children=[ChildID], status=Status} = Node,
    MaxTimes = proplists:get_value(times, Props),
    case maps:find(times, Status) of
    	{ok, 0} ->
            bnode_behavior:backward(Tree#bt{result=?FAILURE}, Node);
        {ok, _} ->
            bnode_behavior:forward(Tree, ChildID);
        error ->
            Node2 = Node#bn{status=#{times=>MaxTimes}},
    		Tree2 = Tree#bt{nodes=maps:put(NodeID, Node2, Tree#bt.nodes)},
		    bnode_behavior:forward(Tree2, ChildID)
    end.


backward(Tree, Node) ->
    #bt{result=Result, nodes=Nodes} = Tree,
    #bn{id=NodeID, props=Props, status=Status} = Node,
    CurTimes = maps:get(times, Status),
    Increase = proplists:get_value(increase, Props, always),
    NewTimes = if
        (Increase == until_succ andalso Result == ?SUCCESS);
        (Increase == until_fail andalso Result == ?FAILURE);
        Increase == always ->
            CurTimes + 1;
        Increase == until_succ;
        Increase == until_fail ->
            CurTimes
    end,
    Node2 = Node#bn{status=#{times=>NewTimes}},
    Tree2 = Tree#bt{nodes=maps:put(NodeID, Node2, Nodes)},
    bnode_behavior:backward(Tree2, Node2).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
