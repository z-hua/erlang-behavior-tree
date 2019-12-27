%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(btree_tests).

-include_lib("eunit/include/eunit.hrl").
-include("btree.hrl").

%% API
-export([]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
bnode_sequence_test_() ->
	[
		?_assertEqual(
			{?SUCCESS,[?SUCCESS,?SUCCESS,?SUCCESS]},
			run(bt(bnode_sequence, [], succ(), succ(), succ()))
		),
		?_assertEqual(
			{?FAILURE,[?FAILURE]},
			run(bt(bnode_sequence, [], fail(), succ(), succ()))
		),
		?_assertEqual(
			{?FAILURE,[?SUCCESS,?FAILURE]},
			run(bt(bnode_sequence, [], succ(), fail(), succ()))
		),
		?_assertEqual(
			{?FAILURE,[?SUCCESS,?SUCCESS,?FAILURE]},
			run(bt(bnode_sequence, [], succ(), succ(), fail()))
		),
		?_assertEqual(
			{?FAILURE,[?FAILURE]},
			run(bt(bnode_sequence, [], fail(), fail(), succ()))
		),
		?_assertEqual(
			{?FAILURE,[?FAILURE]},
			run(bt(bnode_sequence, [], fail(), succ(), fail()))
		),
		?_assertEqual(
			{?FAILURE,[?SUCCESS,?FAILURE]},
			run(bt(bnode_sequence, [], succ(), fail(), fail()))
		),
		?_assertEqual(
			{?FAILURE,[?FAILURE]},
			run(bt(bnode_sequence, [], fail(), fail(), fail()))
		)
	].

bnode_selector_test_() ->
	[
		?_assertEqual(
			{?SUCCESS,[?SUCCESS]},
			run(bt(bnode_selector, [], succ(), succ(), succ()))
		),
		?_assertEqual(
			{?SUCCESS,[?FAILURE,?SUCCESS]},
			run(bt(bnode_selector, [], fail(), succ(), succ()))
		),
		?_assertEqual(
			{?SUCCESS,[?SUCCESS]},
			run(bt(bnode_selector, [], succ(), fail(), succ()))
		),
		?_assertEqual(
			{?SUCCESS,[?SUCCESS]},
			run(bt(bnode_selector, [], succ(), succ(), fail()))
		),
		?_assertEqual(
			{?SUCCESS,[?FAILURE,?FAILURE,?SUCCESS]},
			run(bt(bnode_selector, [], fail(), fail(), succ()))
		),
		?_assertEqual(
			{?SUCCESS,[?FAILURE,?SUCCESS]},
			run(bt(bnode_selector, [], fail(), succ(), fail()))
		),
		?_assertEqual(
			{?SUCCESS,[?SUCCESS]},
			run(bt(bnode_selector, [], succ(), fail(), fail()))
		),
		?_assertEqual(
			{?FAILURE,[?FAILURE,?FAILURE,?FAILURE]},
			run(bt(bnode_selector, [], fail(), fail(), fail()))
		)
	].

bnode_parallel_test_() ->
	[
		% one_succ
		?_assertEqual(
			{?SUCCESS,[?SUCCESS,?SUCCESS,?SUCCESS]},
			run(bt(bnode_parallel, [{type,one_succ}], succ(), succ(), succ()))
		),
		?_assertEqual(
			{?SUCCESS,[?FAILURE,?SUCCESS,?SUCCESS]},
			run(bt(bnode_parallel, [{type,one_succ}], fail(), succ(), succ()))
		),
		?_assertEqual(
			{?SUCCESS,[?SUCCESS,?FAILURE,?SUCCESS]},
			run(bt(bnode_parallel, [{type,one_succ}], succ(), fail(), succ()))
		),
		?_assertEqual(
			{?SUCCESS,[?SUCCESS,?SUCCESS,?FAILURE]},
			run(bt(bnode_parallel, [{type,one_succ}], succ(), succ(), fail()))
		),
		?_assertEqual(
			{?SUCCESS,[?FAILURE,?FAILURE,?SUCCESS]},
			run(bt(bnode_parallel, [{type,one_succ}], fail(), fail(), succ()))
		),
		?_assertEqual(
			{?SUCCESS,[?FAILURE,?SUCCESS,?FAILURE]},
			run(bt(bnode_parallel, [{type,one_succ}], fail(), succ(), fail()))
		),
		?_assertEqual(
			{?SUCCESS,[?SUCCESS,?FAILURE,?FAILURE]},
			run(bt(bnode_parallel, [{type,one_succ}], succ(), fail(), fail()))
		),
		?_assertEqual(
			{?FAILURE,[?FAILURE,?FAILURE,?FAILURE]},
			run(bt(bnode_parallel, [{type,one_succ}], fail(), fail(), fail()))
		),
		% one_fail
		?_assertEqual(
			{?SUCCESS,[?SUCCESS,?SUCCESS,?SUCCESS]},
			run(bt(bnode_parallel, [{type,one_fail}], succ(), succ(), succ()))
		),
		?_assertEqual(
			{?FAILURE,[?FAILURE,?SUCCESS,?SUCCESS]},
			run(bt(bnode_parallel, [{type,one_fail}], fail(), succ(), succ()))
		),
		?_assertEqual(
			{?FAILURE,[?SUCCESS,?FAILURE,?SUCCESS]},
			run(bt(bnode_parallel, [{type,one_fail}], succ(), fail(), succ()))
		),
		?_assertEqual(
			{?FAILURE,[?SUCCESS,?SUCCESS,?FAILURE]},
			run(bt(bnode_parallel, [{type,one_fail}], succ(), succ(), fail()))
		),
		?_assertEqual(
			{?FAILURE,[?FAILURE,?FAILURE,?SUCCESS]},
			run(bt(bnode_parallel, [{type,one_fail}], fail(), fail(), succ()))
		),
		?_assertEqual(
			{?FAILURE,[?FAILURE,?SUCCESS,?FAILURE]},
			run(bt(bnode_parallel, [{type,one_fail}], fail(), succ(), fail()))
		),
		?_assertEqual(
			{?FAILURE,[?SUCCESS,?FAILURE,?FAILURE]},
			run(bt(bnode_parallel, [{type,one_fail}], succ(), fail(), fail()))
		),
		?_assertEqual(
			{?FAILURE,[?FAILURE,?FAILURE,?FAILURE]},
			run(bt(bnode_parallel, [{type,one_fail}], fail(), fail(), fail()))
		),
		% all_succ
		?_assertEqual(
			{?SUCCESS,[?SUCCESS,?SUCCESS,?SUCCESS]},
			run(bt(bnode_parallel, [{type,all_succ}], succ(), succ(), succ()))
		),
		?_assertEqual(
			{?FAILURE,[?FAILURE,?SUCCESS,?SUCCESS]},
			run(bt(bnode_parallel, [{type,all_succ}], fail(), succ(), succ()))
		),
		?_assertEqual(
			{?FAILURE,[?SUCCESS,?FAILURE,?SUCCESS]},
			run(bt(bnode_parallel, [{type,all_succ}], succ(), fail(), succ()))
		),
		?_assertEqual(
			{?FAILURE,[?SUCCESS,?SUCCESS,?FAILURE]},
			run(bt(bnode_parallel, [{type,all_succ}], succ(), succ(), fail()))
		),
		?_assertEqual(
			{?FAILURE,[?FAILURE,?FAILURE,?SUCCESS]},
			run(bt(bnode_parallel, [{type,all_succ}], fail(), fail(), succ()))
		),
		?_assertEqual(
			{?FAILURE,[?FAILURE,?SUCCESS,?FAILURE]},
			run(bt(bnode_parallel, [{type,all_succ}], fail(), succ(), fail()))
		),
		?_assertEqual(
			{?FAILURE,[?SUCCESS,?FAILURE,?FAILURE]},
			run(bt(bnode_parallel, [{type,all_succ}], succ(), fail(), fail()))
		),
		?_assertEqual(
			{?FAILURE,[?FAILURE,?FAILURE,?FAILURE]},
			run(bt(bnode_parallel, [{type,all_succ}], fail(), fail(), fail()))
		),
		% all_fail
		?_assertEqual(
			{?SUCCESS,[?SUCCESS,?SUCCESS,?SUCCESS]},
			run(bt(bnode_parallel, [{type,all_fail}], succ(), succ(), succ()))
		),
		?_assertEqual(
			{?SUCCESS,[?FAILURE,?SUCCESS,?SUCCESS]},
			run(bt(bnode_parallel, [{type,all_fail}], fail(), succ(), succ()))
		),
		?_assertEqual(
			{?SUCCESS,[?SUCCESS,?FAILURE,?SUCCESS]},
			run(bt(bnode_parallel, [{type,all_fail}], succ(), fail(), succ()))
		),
		?_assertEqual(
			{?SUCCESS,[?SUCCESS,?SUCCESS,?FAILURE]},
			run(bt(bnode_parallel, [{type,all_fail}], succ(), succ(), fail()))
		),
		?_assertEqual(
			{?SUCCESS,[?FAILURE,?FAILURE,?SUCCESS]},
			run(bt(bnode_parallel, [{type,all_fail}], fail(), fail(), succ()))
		),
		?_assertEqual(
			{?SUCCESS,[?FAILURE,?SUCCESS,?FAILURE]},
			run(bt(bnode_parallel, [{type,all_fail}], fail(), succ(), fail()))
		),
		?_assertEqual(
			{?SUCCESS,[?SUCCESS,?FAILURE,?FAILURE]},
			run(bt(bnode_parallel, [{type,all_fail}], succ(), fail(), fail()))
		),
		?_assertEqual(
			{?FAILURE,[?FAILURE,?FAILURE,?FAILURE]},
			run(bt(bnode_parallel, [{type,all_fail}], fail(), fail(), fail()))
		)
	].

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
bt(Type, Props, Act1, Act2, Act3) ->
	#{
		1 => bn(1, 0, Type, Props, [2,3,4]),
		2 => bn(2, 1, bnode_action, [Act1], []),
		3 => bn(3, 1, bnode_action, [Act2], []),
		4 => bn(4, 1, bnode_action, [Act3], [])
	}.

bn(NodeID, Parent, Handler, Props, Children) ->
	#bn{
		id       = NodeID,
		parent   = Parent,
		handler  = Handler,
		props    = Props,
		children = Children
	}.

run(Nodes) ->
	set_output([]),
	Ref  = btree:new(1, Nodes),
	Tree = btree:run(Ref),
	{Tree#bt.result, lists:reverse(get_output())}.

succ() ->
	{action, fun() -> add_output(?SUCCESS), ?SUCCESS end}.

fail() ->
	{action, fun() -> add_output(?FAILURE), ?FAILURE end}.

% running() ->
% 	{action, fun() -> add_output(?RUNNING), ?RUNNING end}.

-define(k_output, k_output).
get_output() ->
	get(?k_output).

set_output(Output) ->
	put(?k_output, Output).

add_output(Output) ->
	put(?k_output, [Output | get_output()]).
