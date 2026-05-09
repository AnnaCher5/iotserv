-module(iotserv).

-behavior(gen_server).

-include("iot.hrl").

-export([start_link/0, start_link/1, stop/0, add/5, delete/1, change/2, lookup/1]).
-export([init/1, terminate/2, handle_call/3, handle_cast/2, read_config/1, update_device/2]).

-spec start_link() -> {ok, pid()}.
start_link() ->
    case application:get_env(iotserv, config_file) of
        {ok, ConfigName} ->
            PrivDir = code:priv_dir(iotserv),
            ConfigPath = filename:join(PrivDir, ConfigName),
            start_link(ConfigPath);
        _ ->
            {error, config_read_error}
    end.

-spec start_link(string()) -> {ok, pid()}.
start_link(ConfigFile) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, ConfigFile, []).

stop() ->
    gen_server:cast(?MODULE, stop).

-spec add(integer(), string(), string(), number(), [{atom(), term()}]) -> {ok, integer()}.
add(Id, Name, Address, Temperature, Metrics) ->
    Device = #iot{
        id = Id,
        name = Name,
        address = Address,
        temperature = Temperature,
        metrics = Metrics
    },
    gen_server:call(?MODULE, {add, Device}).

-spec delete(integer()) -> ok.
delete(Id) ->
    gen_server:call(?MODULE, {delete, Id}).

-spec change(integer(), [{atom(), term()}]) -> ok | {error, not_found}.
change(Id, Params) ->
    gen_server:call(?MODULE, {change, Id, Params}).

-spec lookup(integer()) -> {ok, list()} | {error, not_found}.
lookup(Id) ->
    gen_server:call(?MODULE, {lookup, Id}).

init(ConfigFile) ->
    PrivDir = code:priv_dir(iotserv),
    case read_config(ConfigFile) of
        {ok, ConfigName} ->
            DetsPath = filename:join(PrivDir, ConfigName),
            iotserv_db:create_tables(DetsPath),
            iotserv_db:restore_from_dets(),
            {ok, null};
        {error, read_error} ->
            {error, read_error}
    end.

terminate(_Reason, _LoopData) ->
  iotserv_db:close_tables().

handle_call({add, Device}, _From, LoopData) ->
    Reply = iotserv_db:add_iot(Device),
    {reply, Reply, LoopData};

handle_call({delete, Id}, _From, LoopData) ->
    Reply = iotserv_db:delete_iot(Id),
    {reply, Reply, LoopData};

handle_call({change, Id, Params}, _From, LoopData) ->
    Reply = case iotserv_db:lookup_id(Id) of
        {ok, Device} ->
            NewDevice = update_device(Device, Params),
            iotserv_db:update_iot(NewDevice);
        {error, not_found} ->
            {error, not_found}
    end,
    {reply, Reply, LoopData};

handle_call({lookup, Id}, _From, LoopData) ->
    Reply = iotserv_db:lookup_id(Id),
    {reply, Reply, LoopData}.

handle_cast(stop, LoopData) ->
  {stop, normal, LoopData}.

read_config(ConfigFile) ->
    case file:read_file(ConfigFile) of
        {ok, Bin} ->
            case jsx:decode(Bin, [return_maps]) of
                Map when is_map(Map) ->
                    case maps:find(<<"dets_file">>, Map) of
                        {ok, PathBin} when is_binary(PathBin) ->
                            {ok, binary_to_list(PathBin)};
                        _ ->
                            {error, read_error}
                    end;
                _ ->
                    {error, read_error}
            end;
        {error, _} ->
            {error, read_error}
    end.

update_device(Device, [{Param, Value} | Params]) ->
    NewDevice = case Param of
        name -> Device#iot{name = Value};
        address -> Device#iot{address = Value};
        temperature -> Device#iot{temperature = Value};
        metrics -> Device#iot{metrics = Value};
        metric ->
            {Key, Val} = Value,
            Device#iot{metrics = lists:keystore(Key, 1, Device#iot.metrics, {Key, Val})}
    end,
    update_device(NewDevice, Params);

update_device(Device, []) ->
    Device.