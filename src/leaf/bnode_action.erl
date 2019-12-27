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
    Result = case proplists:get_value(action, Node#bn.props) of
    	{M,F,A} ->
    		apply(M, F, A);
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
