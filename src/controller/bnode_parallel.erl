%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(bnode_parallel).

-include("btree.hrl").

%% API
-export([forward/2]).
-export([backward/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
forward(Tree, Node) ->
    #bn{id=NodeID, props=Props, children=[ChildID | Rest]} = Node,
    Type = get_type(Props),
    Result = case Type of
        one_succ -> ?FAILURE;
        one_fail -> ?SUCCESS;
        all_succ -> ?SUCCESS;
        all_fail -> ?FAILURE
    end,
    Node2 = Node#bn{status=#{result=>Result, children=>Rest}},
    Tree2 = Tree#bt{nodes=maps:put(NodeID, Node2, Tree#bt.nodes)},
    bnode_behavior:forward(Tree2, ChildID).


backward(Tree, Node) ->
    #bt{result=Result, nodes=Nodes} = Tree,
    #bn{id=NodeID, props=Props, status=Status} = Node,
    #{result:=AccResult, children:=Children} = Status,
    Type = get_type(Props),
    NewResult = case {Type, Result} of
        {one_succ, ?SUCCESS} -> ?SUCCESS;
        {one_fail, ?SUCCESS} -> AccResult;
        {all_succ, ?SUCCESS} -> AccResult;
        {all_fail, ?SUCCESS} -> ?SUCCESS;
        {one_succ, ?FAILURE} -> AccResult;
        {one_fail, ?FAILURE} -> ?FAILURE;
        {all_succ, ?FAILURE} -> ?FAILURE;
        {all_fail, ?FAILURE} -> AccResult
    end,
    case Children of
        [ChildID | Rest] ->
            Node2 = Node#bn{status=#{result=>NewResult, children=>Rest}},
            Tree2 = Tree#bt{nodes=maps:put(NodeID, Node2, Nodes)},
            bnode_behavior:forward(Tree2, ChildID);
        [] ->
            Node2 = Node#bn{status=#{}},
            Tree2 = Tree#bt{
                result = NewResult,
                nodes  = maps:put(NodeID, Node2, Nodes)
            },
            bnode_behavior:backward(Tree2, Node2)
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_type(Props) ->
    Type = proplists:get_value(type, Props),
    ?_assertRequired(type, Type),
    Type.
