%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(bnode_sequence).

-include("btree.hrl").

%% API
-export([forward/2]).
-export([backward/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
forward(Tree, Node) ->
    #bt{status=Status} = Tree,
    #bn{id=NodeID, children=[ChildID | Rest]} = Node,
    Tree2 = Tree#bt{status=maps:put(NodeID, Rest, Status)},
    bnode_behavior:forward(Tree2, ChildID).


backward(Tree, Node) when Tree#bt.result == ?FAILURE ->
    #bt{status=Status} = Tree,
    Tree2 = Tree#bt{
        status = maps:remove(Node#bn.id, Status),
        result = ?FAILURE
    },
    bnode_behavior:backward(Tree2, Node);
backward(Tree, Node) when Tree#bt.result == ?SUCCESS ->
    #bt{status=Status} = Tree,
    #bn{id=NodeID} = Node,
    case maps:get(NodeID, Status) of
        [ChildID | Rest] ->
            Tree2 = Tree#bt{status=maps:put(NodeID, Rest, Status)},
            bnode_behavior:forward(Tree2, ChildID);
        [] ->
            Tree2 = Tree#bt{
                status = maps:remove(NodeID, Status),
                result = ?SUCCESS
            },
            bnode_behavior:backward(Tree2, Node)
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
