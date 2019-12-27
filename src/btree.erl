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
new(Entry, Nodes) ->
    Tree = #bt{
        ref    = erlang:make_ref(),
        entry  = Entry,
        nodes  = Nodes,
        result = ?FAILURE,
        status = #{}
    },
    set_tree(Tree#bt.ref, Tree),
    Tree#bt.ref.

run(Ref) ->
	Tree = get_tree(Ref),
	Tree == undefined andalso throw({error, btree_not_found}),
	case is_record(Tree#bt.result, bn) of
		true  -> bnode_behavior:forward(Tree, Tree#bt.result);
		false -> bnode_behavior:forward(Tree, Tree#bt.entry)
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
-define(k_tree, {btree, Ref}).
get_tree(Ref) ->
    get(?k_tree).

set_tree(Ref, Tree) ->
    put(?k_tree, Tree).
