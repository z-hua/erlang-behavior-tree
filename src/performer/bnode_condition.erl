%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(bnode_condition).

-include("btree.hrl").

%% API
-export([forward/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
forward(Tree, Node) ->
    Action  = proplists:get_value(action, Node#bn.props),
    ?_assertRequired(action, Action),
    Boolean = case Action of
    	[M,F,A] ->
    		apply(M, F, A);
    	[M,F] ->
    		apply(M, F, []);
    	F when is_function(F, 0) ->
    		F()
	end,
	Result = case Boolean of
	    true  -> ?SUCCESS;
	    false -> ?FAILURE
	end,
	bnode_behavior:backward(Tree#bt{result=Result}, Node).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
