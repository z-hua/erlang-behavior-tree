%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(bnode_behavior).

-include("btree.hrl").

-callback forward() -> btree:btree().
-callback backward() -> btree:btree().

%% API
-export([forward/2]).
-export([backward/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
forward(Tree, Node) when is_record(Node, bn) ->
    Handler = Node#bn.handler,
    Handler:forward(Tree, Node);
forward(Tree, NodeID) ->
    Node = maps:get(NodeID, Tree#bt.nodes),
    forward(Tree, Node).

backward(Tree, Node) ->
    case maps:find(Node#bn.parent, Tree#bt.nodes) of
        {ok, Parent} ->
            Handler = Parent#bn.handler,
            Handler:backward(Tree, Parent);
        error ->
            Tree
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
