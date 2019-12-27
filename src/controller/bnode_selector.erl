%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(bnode_selector).

-include("btree.hrl").

%% API
-export([forward/2]).
-export([backward/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
forward(Tree, Node) ->
    #bn{id=NodeID, children=[ChildID | Rest]} = Node,
    Node2 = Node#bn{status=#{children=>Rest}},
    Tree2 = Tree#bt{nodes=maps:put(NodeID, Node2, Tree#bt.nodes)},
    bnode_behavior:forward(Tree2, ChildID).


backward(Tree, Node) when Tree#bt.result == ?SUCCESS ->
    Node2 = Node#bn{status=#{}},
    Tree2 = Tree#bt{
        result = ?SUCCESS,
        nodes  = maps:put(Node#bn.id, Node2, Tree#bt.nodes)
    },
    bnode_behavior:backward(Tree2, Node2);
backward(Tree, Node) when Tree#bt.result == ?FAILURE ->
    #bn{id=NodeID, status=Status} = Node,
    case maps:get(children, Status) of
        [ChildID | Rest] ->
            Node2 = Node#bn{status=#{children=>Rest}},
            Tree2 = Tree#bt{nodes=maps:put(NodeID, Node2, Tree#bt.nodes)},
            bnode_behavior:forward(Tree2, ChildID);
        [] ->
            Node2 = Node#bn{status=#{}},
            Tree2 = Tree#bt{
                result = ?FAILURE,
                nodes  = maps:put(NodeID, Node2, Tree#bt.nodes)
            },
            bnode_behavior:backward(Tree2, Node2)
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
