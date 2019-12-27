%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(bnode_random).

-include("btree.hrl").

%% API
-export([forward/2]).
-export([backward/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
forward(Tree, Node) ->
    #bn{props=Props, children=Children} = Node,
    Weighted = proplists:get_value(weight, Props, false),
    ChildID  = case Weighted of
        true  ->
            WtList = weight_list(Children, Tree),
            weight_random(WtList, 2);
        false ->
            Index  = rand:uniform( length(Children) ),
            lists:nth(Index, Children)
    end,
    bnode_behavior:forward(Tree, ChildID).

backward(Tree, Node) ->
    bnode_behavior:backward(Tree, Node).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
weight_list(Children, Tree) ->
    lists:map(fun
        (ChildID) ->
            #bn{props=Props} = maps:get(ChildID, Tree#bt.nodes),
            {ChildID, proplists:get_value(weight, Props)}
    end, Children).

random(Min, Max)->
    Min2 = Min - 1,
    rand:uniform(Max - Min2) + Min2.

weight_random(List, Index) ->
    Sum = lists:sum([element(Index, Elem) || Elem <- List]),
    {_, Elem} = weight_hit(List, Index, random(1, Sum), 1, 0),
    element(Index, Elem).

weight_hit([Elem | T], Index, Random, Nth, SumWt) ->
    SumWt2 = element(Index, Elem) + SumWt,
    case Random =< SumWt2 of
        true  -> {Nth, Elem};
        false -> weight_hit(T, Index, Random, Nth+1, SumWt2)
    end.
