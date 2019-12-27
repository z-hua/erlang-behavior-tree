-ifndef(BTREE_HRL).
-define(BTREE_HRL, ok).

%% node run result
-define(SUCCESS, success).
-define(FAILURE, failure).
-define(RUNNING, running).

%% behavior tree
-record(bt, {
      ref    :: reference()
    , entry  :: btree:nodeid()
    , nodes  :: map() % #{btree:nodeid()=>btree:bnode()},
    , result :: btree:bresult() | btree:bnode()
    , status :: map() % #{btree:nodeid()=>any()}
}).

%% behavior node
-record(bn, {
      id       :: btree:nodeid()
    , parent   :: btree:nodeid()
    , handler  :: module()
    , props    :: list()
    , children :: [btree:nodeid()]
}).

-endif.