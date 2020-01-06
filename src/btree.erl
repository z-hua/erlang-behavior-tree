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
	Tree  = get_tree(Ref),
	Tree2 = case is_record(Tree#bt.result, bn) of
		true  -> bnode_behavior:forward(Tree, Tree#bt.result);
		false -> bnode_behavior:forward(Tree, Tree#bt.entry)
	end,
    set_tree(Tree2).

event(Ref, Event) ->
    Tree   = get_tree(Ref),
    Listen = maps:get({event,Event}, Tree#bt.status, []),
    Tree2  = run_event(Listen, Tree),
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
    Queue = queue:in(Root, queue:new()),
    Entry = get_nodeid(Root),
    Nodes = get_nodes(Queue, #{}, #{}),
    btree(Entry, Nodes).

get_nodes(Queue, Nodes, IDs) ->
    case queue:out(Queue) of
        {empty, _} ->
            Nodes;
        {{value,Elem}, Queue1} ->
            #xmlElement{name=Name, pos=Pos, content=Content} = Elem,
            Node   = make_node(Elem, IDs),
            Nodes2 = maps:put(Node#bn.id, Node, Nodes),
            Queue2 = lists:foldl(fun
                (E, AccQ) ->
                    case is_node(E) of
                        true  -> queue:in(E, AccQ);
                        false -> AccQ
                    end
            end, Queue1, Content),
            IDs2 = maps:put({Name,Pos}, Node#bn.id, IDs),
            get_nodes(Queue2, Nodes2, IDs2)
    end.

make_node(Elem, IDs) ->
    NodeID   = get_nodeid(Elem),
    Parent   = get_parent(Elem, IDs),
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


get_parent(Elem, IDs) ->
    Key = get_parent2(Elem#xmlElement.parents),
    maps:get(Key, IDs, undefined).

get_parent2([{node,Pos} | _]) ->
    {node,Pos};
get_parent2([_ | T]) ->
    get_parent2(T);
get_parent2([]) ->
    undefined.


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
    List2 = [list_to_atom(string:trim(E)) || E <- List],
    case length(List2) == 1 of
        true  -> hd(List2);
        false -> List2
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
