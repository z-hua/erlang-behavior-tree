%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(bnode_inverter).

-include("btree.hrl").

%% API
-export([forward/2]).
-export([backward/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
forward(Tree, Node) ->
    #bn{children=[ChildID]} = Node,
    bnode_behavior:forward(Tree, ChildID).

backward(Tree, Node) ->
    Result = case Tree#bt.result of
        ?SUCCESS -> ?FAILURE;
        ?FAILURE -> ?SUCCESS
    end,
    bnode_behavior:backward(Tree#bt{result=Result}, Node).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
