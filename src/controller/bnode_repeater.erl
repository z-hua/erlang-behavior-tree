%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(bnode_repeater).

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
    Loop = proplists:get_value(loop, Props),
    case is_integer(Loop) of
        true  ->
            Tree2 = maps:put(NodeID, Loop, Status),
            bnode_behavior:forward(Tree2, Node);
        false ->
            bnode_behavior:forward(Tree, ChildID)
    end.

backward(Tree, Node) ->
    #bt{status=Status, result=Result} = Tree,
    #bn{id=NodeID, props=Props} = Node,
    Loop = proplists:get_value(loop, Props),
    case Loop of
        until_succ when Result == ?SUCCESS ->
            bnode_behavior:backward(Tree#bt{result=?SUCCESS}, Node);
        until_succ ->
            Tree#bt{result=Node};
        until_fail when Result == ?FAILURE ->
            bnode_behavior:backward(Tree#bt{result=?FAILURE}, Node);
        until_fail ->
            Tree#bt{result=Node};
        infinity ->
            Tree#bt{result=Node};
        _ ->
            Count = maps:get(NodeID, Status),
            case Count - 1 of
                0 ->
                    Tree2 = Tree#bt{status=maps:remove(NodeID, Status)},
                    bnode_behavior:backward(Tree2, Node);
                N ->
                    Tree#bt{
                        result = Node,
                        status = maps:put(NodeID, N, Status)
                    }
            end
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
