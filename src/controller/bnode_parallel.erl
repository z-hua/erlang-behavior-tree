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
    #bt{status=Status} = Tree,
    #bn{id=NodeID, props=Props, children=[ChildID | Rest]} = Node,
    Result = case proplists:get_value(type, Props) of
        one_succ -> ?FAILURE;
        one_fail -> ?SUCCESS;
        all_succ -> ?SUCCESS;
        all_fail -> ?FAILURE
    end,
    Tree2 = Tree#bt{status=maps:put(NodeID, {Result,Rest}, Status)},
    bnode_behavior:forward(Tree2, ChildID).


backward(Tree, Node) ->
    #bt{result=Result, status=Status} = Tree,
    #bn{id=NodeID, props=Props} = Node,
    {AccResult, Children} = maps:get(NodeID, Status),
    Type = proplists:get_value(type, Props),
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
            Tree2 = Tree#bt{status=maps:put(NodeID, {NewResult,Rest}, Status)},
            bnode_behavior:forward(Tree2, ChildID);
        [] ->
            Tree2 = Tree#bt{
                status = maps:remove(NodeID, Status),
                result = NewResult
            },
            bnode_behavior:backward(Tree2, Node)
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
