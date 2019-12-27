%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(btree).

-include("btree.hrl").

%% API
-export([new/2]).
-export([run/1]).
-export([event/2]).

-export_type([nodeid/0]).
-export_type([btree/0]).
-export_type([bnode/0]).
-export_type([bresult/0]).

-type nodeid() :: any().
-type btree() :: #bt{}.
-type bnode() :: #bn{}.
-type bresult() :: ?SUCCESS | ?FAILURE | ?RUNNING.

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
-spec new(nodeid(), #{nodeid()=>bnode()}) ->
    reference().
new(Entry, Nodes0) ->
    Nodes = maps:map(fun(_, Node) -> Node#bn{status=#{}} end, Nodes0),
    Tree  = #bt{
        ref    = erlang:make_ref(),
        entry  = Entry,
        nodes  = Nodes,
        result = ?FAILURE,
        status = #{}
    },
    set_tree(Tree#bt.ref, Tree),
    Tree#bt.ref.

run(Ref) ->
	Tree  = get_tree(Ref),
	Tree2 = case is_record(Tree#bt.result, bn) of
		true  -> bnode_behavior:forward(Tree, Tree#bt.result);
		false -> bnode_behavior:forward(Tree, Tree#bt.entry)
	end,
    set_tree(Ref, Tree2).

event(Ref, Event) ->
    Tree   = get_tree(Ref),
    Listen = maps:get({event,Event}, Tree#bt.status, []),
    Tree2  = run_event(Listen, Tree),
    set_tree(Ref, Tree2).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
-define(k_tree, {btree, Ref}).
get_tree(Ref) ->
    Tree = get(?k_tree),
    Tree == undefined andalso throw({error, btree_not_found}),
    Tree.

set_tree(Ref, Tree) ->
    put(?k_tree, Tree).

run_event([NodeID | T], Tree) ->
    Tree2 = bnode_behavior:forward(Tree, NodeID),
    run_event(T, Tree2);
run_event([], Tree) ->
    Tree.
