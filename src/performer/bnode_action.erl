%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(bnode_action).

-include("btree.hrl").

%% API
-export([forward/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
forward(Tree, Node) ->
    Action = proplists:get_value(action, Node#bn.props),
    ?_assertRequired(action, Action),
    Result = case Action of
    	[M,F,A] ->
    		erlang:apply(M, F, A);
        [M,F] ->
            apply(M, F, []);
    	F when is_function(F, 0) ->
    		F()
    end,
	case Result == ?RUNNING of
        true  -> Tree#bt{result=Node};
        false -> bnode_behavior:backward(Tree#bt{result=Result}, Node)
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
