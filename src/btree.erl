%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(btree).

-include_lib("xmerl/include/xmerl.hrl").

-include("btree.hrl").

%% API
-export([new/1, new/2]).
-export([run/1]).
-export([event/2]).
-export([node/5]).

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
-spec new(string()) ->
    reference().
new(File) ->
    case filelib:is_file(File) of
        true  ->
            Tree = xml2tree(File),
            io:format("tree: ~p~n", [Tree]),
            set_tree(Tree),
            Tree#bt.ref;
        false ->
            throw({error, file_not_found})
    end.

-spec new(nodeid(), #{nodeid()=>bnode()}) ->
    reference().
new(Entry, Nodes) ->
    Tree = btree(Entry, Nodes),
    set_tree(Tree),
    Tree#bt.ref.

run(Ref) ->
	Tree   = #bt{status=Status} = get_tree(Ref),

    io:format("run event~n"),
    Events = maps:get(event, Status, []),
    Tree1  = lists:foldl(fun
        (Event, AccTree) ->
            Listen = maps:get({listen,postponed,Event}, Status, []),
            run_event(Listen, AccTree)
    end, Tree, Events),

    io:format("run tree~n"),
    Tree2 = Tree1#bt{status=maps:remove(event, Status)},

	Tree3 = case is_record(Tree2#bt.result, bn) of
		true  -> bnode_behavior:forward(Tree2, Tree2#bt.result);
		false -> bnode_behavior:forward(Tree2, Tree2#bt.entry)
	end,
    set_tree(Tree3).

event(Ref, Event) ->
    Tree    = #bt{status=Status} = get_tree(Ref),

    Events  = maps:get(event, Status, []),
    Events2 = lists:reverse([Event | Events]),
    Status2 = maps:put(event, Events2, Status),
    Tree1   = Tree#bt{status=Status2},

    Listen  = maps:get({listen,immediate,Event}, Status, []),
    Tree2   = run_event(Listen, Tree1),
    set_tree(Tree2).

node(NodeID, Parent, Handler, Props, Children) ->
    bnode(NodeID, Parent, Handler, Props, Children, #{}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
-define(k_tree, {btree, Ref}).
get_tree(Ref) ->
    Tree = get(?k_tree),
    Tree == undefined andalso throw({error, btree_not_found}),
    Tree.

set_tree(Tree = #bt{ref=Ref}) ->
    put(?k_tree, Tree).

run_event([NodeID | T], Tree) ->
    io:format("run event: ~p~n", [{NodeID}]),
    Tree2 = bnode_behavior:forward(Tree, NodeID),
    run_event(T, Tree2);
run_event([], Tree) ->
    Tree.

btree(Entry, Nodes) ->
    #bt{
        ref    = erlang:make_ref(),
        entry  = Entry,
        nodes  = Nodes,
        result = ?FAILURE,
        status = #{}
    }.

bnode(NodeID, Parent, Handler, Props, Children, Status) ->
    #bn{
        id       = NodeID,
        parent   = Parent,
        handler  = Handler,
        props    = Props,
        children = Children,
        status   = Status
    }.


xml2tree(File) ->
    {Elem, _} = xmerl_scan:file(File),
    Root  = get_root(Elem),
    Queue = queue:in({Root, undefined}, queue:new()),
    Entry = get_nodeid(Root),
    Nodes = get_nodes(Queue, #{}),
    btree(Entry, Nodes).

get_nodes(Queue, Nodes) ->
    case queue:out(Queue) of
        {empty, _} ->
            Nodes;
        {{value,{Elem,Parent}}, Queue1} ->
            Node   = make_node(Elem, Parent),
            Nodes2 = maps:put(Node#bn.id, Node, Nodes),
            Queue2 = lists:foldl(fun
                (E, AccQ) ->
                    case is_node(E) of
                        true  -> queue:in({E,get_nodeid(Elem)}, AccQ);
                        false -> AccQ
                    end
            end, Queue1, Elem#xmlElement.content),
            get_nodes(Queue2, Nodes2)
    end.

make_node(Elem, Parent) ->
    NodeID   = get_nodeid(Elem),
    Handler  = get_handler(Elem),
    Props    = get_props(Elem),
    Children = get_children(Elem),
    bnode(NodeID, Parent, Handler, Props, Children, #{}).


get_nodeid(Elem) ->
    get_attribute(Elem, 'ID').


get_root(Elem) ->
    get_root2(Elem#xmlElement.content).

get_root2([Elem | T]) ->
    case is_node(Elem) of
        true  -> Elem;
        false -> get_root2(T)
    end;
get_root2([]) ->
    throw({error, entry_not_found}).


get_handler(Elem) ->
    ID   = get_attribute(Elem, 'ID'),
    Name = get_attribute(Elem, 'TEXT'),
    case Name of
        <<"序列节点"/utf8>> -> bnode_sequence;
        <<"选择节点"/utf8>> -> bnode_selector;
        <<"并行节点"/utf8>> -> bnode_parallel;
        <<"循环节点"/utf8>> -> bnode_repeater;
        <<"计数节点"/utf8>> -> bnode_counter;
        <<"随机节点"/utf8>> -> bnode_random;
        <<"事件节点"/utf8>> -> bnode_listener;

        <<"成功节点"/utf8>> -> bnode_success;
        <<"失败节点"/utf8>> -> bnode_failure;
        <<"取反节点"/utf8>> -> bnode_inverter;

        <<"动作节点"/utf8>> -> bnode_action;
        <<"条件节点"/utf8>> -> bnode_condition;
        _ -> throw({error, invalid_node, {ID, Name}})
    end.


get_props(Elem) ->
    get_props2(Elem#xmlElement.content, []).

get_props2([Elem | T], Props) ->
    case is_attr(Elem) of
        true  ->
            [A1, A2] = Elem#xmlElement.attributes,
            Name = convert_prop(A1#xmlAttribute.value),
            Val  = convert_prop(A2#xmlAttribute.value),
            get_props2(T, [{Name,Val} | Props]);
        false ->
            get_props2(T, Props)
    end;
get_props2([], Props) ->
    lists:reverse(Props).

convert_prop(Str) ->
    List  = string:split(Str, ",", all),
    List2 = [convert_prop2(string:trim(E)) || E <- List],
    case length(List2) == 1 of
        true  -> hd(List2);
        false -> List2
    end.

convert_prop2(Str) ->
    case string:split(Str, "|", all) of
        ["int", Val] ->
            list_to_integer(Val);
        ["str", Val] ->
            Val;
        [Val] ->
            try
                list_to_existing_atom(Val)
            catch _:_ ->
                list_to_atom(Val)
            end
    end.

get_children(Elem) ->
    get_children2(Elem#xmlElement.content, []).

get_children2([Elem | T], Children) ->
    case is_node(Elem) of
        true  ->
            NodeID = get_nodeid(Elem),
            get_children2(T, [NodeID | Children]);
        false ->
            get_children2(T, Children)
    end;
get_children2([], Children) ->
    lists:reverse(Children).


get_attribute(Elem, Name) ->
    Attr = lists:keyfind(Name, #xmlAttribute.name, Elem#xmlElement.attributes),
    unicode:characters_to_binary(Attr#xmlAttribute.value, utf8, utf8).

is_node(Elem) ->
    is_record(Elem, xmlElement) andalso Elem#xmlElement.name == node.

is_attr(Elem) ->
    is_record(Elem, xmlElement) andalso Elem#xmlElement.name == attribute.
