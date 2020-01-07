%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(bnode_repeater).

-include("btree.hrl").

%% API
-export([forward/2]).
-export([backward/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
forward(Tree, Node) ->
    #bn{id=NodeID, props=Props, children=[ChildID]} = Node,
    Loop = get_loop(Props),
    case is_integer(Loop) of
        true  ->
            Node2 = Node#bn{status=#{times=>Loop}},
            Tree2 = Tree#bt{nodes=maps:put(NodeID, Node2, Tree#bt.nodes)},
            bnode_behavior:forward(Tree2, Node);
        false ->
            bnode_behavior:forward(Tree, ChildID)
    end.


backward(Tree, Node) ->
    #bt{nodes=Nodes, result=Result} = Tree,
    #bn{id=NodeID, props=Props, status=Status} = Node,
    Loop = get_loop(Props),
    if
        (Loop == until_succ andalso Result == ?SUCCESS);
        (Loop == until_fail andalso Result == ?FAILURE) ->
            bnode_behavior:backward(Tree, Node);
        Loop == until_succ;
        Loop == until_fail;
        Loop == infinity ->
            Tree#bt{result=Node};
        true ->
            CurTimes = maps:get(times, Status),
            case CurTimes - 1 of
                0 ->
                    Node2 = Node#bn{status=#{}},
                    Tree2 = Tree#bt{nodes=maps:put(NodeID, Node2, Nodes)},
                    bnode_behavior:backward(Tree2, Node2);
                N ->
                    Node2 = Node#bn{status=#{times=>N}},
                    Tree#bt{
                        result = Node2,
                        nodes  = maps:put(NodeID, Node2, Nodes)
                    }
            end
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_loop(Props) ->
    proplists:get_value(loop, Props, infinity).
