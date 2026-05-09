-module(iotserv_db).

-include("iot.hrl").

-export([create_tables/1, close_tables/0, add_iot/1, delete_iot/1,
update_iot/1, lookup_id/1, restore_from_dets/0]).

create_tables(FileName) ->
  ets:new(iotRam, [named_table, {keypos, #iot.id}]),
  dets:open_file(iotDisk, [{file, FileName}, {keypos, #iot.id}]).

close_tables() ->
  ets:delete(iotRam),
  dets:close(iotDisk).

add_iot(#iot{id = Id} = Device) ->
  ets:insert(iotRam, Device),
  dets:insert(iotDisk, Device),
  {ok, Id}.

delete_iot(Id) ->
  ets:delete(iotRam, Id),
  dets:delete(iotDisk, Id),
  ok.

update_iot(Device) ->
  ets:insert(iotRam, Device),
  dets:insert(iotDisk, Device),
  ok.

lookup_id(Id) ->
  case ets:lookup(iotRam, Id) of
    [Device] ->
      {ok, Device};
    [] ->
      {error, not_found}
  end.

restore_from_dets() ->
  Insert = fun(Device) ->
    ets:insert(iotRam, Device),
    continue
  end,
  dets:traverse(iotDisk, Insert).