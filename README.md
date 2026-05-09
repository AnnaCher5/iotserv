iotserv
=====

An OTP application

Build
-----

    $ rebar3 compile

API
-----

### Добавление устройства

iotserv:add(Id, Name, Address, Temperature, Metrics).

### Поиск устройства

iotserv:lookup(Id).

### Изменение параметров

iotserv:change(Id, Params).

### Удаление устройства

iotserv:delete(Id).

### Остановка сервера
iotserv:stop().

Пример вызова клиенсткий API
-----

anna@anna-pc:~/Документы/eltex/дз9/iotserv$ rebar3 shell
===> Verifying dependencies...
===> Analyzing applications...
===> Compiling iotserv
Erlang/OTP 25 [erts-13.2.2.5] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [jit:ns]

Eshell V13.2.2.5  (abort with ^G)
1> ===> Booted jsx
===> Booted iotserv

1> iotserv:add(1, "Temp1", "Room1", 22.5, [{temp, 22}, {mem_load, 56}]).
{ok,1}

2> iotserv:add(2, "Temp2", "Room2", 18, [{temp, 17}]).
{ok,2}

3> iotserv:lookup(1).
{ok,{iot,1,"Temp1","Room1",22.5,[{temp,22},{mem_load,56}]}}

4> iotserv:change(1, [{temperature, 24}, {address, "Room3"}]).
ok

5> iotserv:lookup(1).
{ok,{iot,1,"Temp1","Room3",24,[{temp,22},{mem_load,56}]}}

6> iotserv:delete(2).
ok

7> iotserv:lookup(2).
{error,not_found}

8> iotserv:stop().
ok

9> =SUPERVISOR REPORT==== 9-May-2026::17:08:30.337334 ===
    supervisor: {local,iotserv_sup}
    errorContext: child_terminated
    reason: normal
    offender: [{pid,<0.224.0>},
               {id,iotserver_serv},
               {mfargs,{iotserv,start_link,[]}},
               {restart_type,permanent},
               {significant,false},
               {shutdown,5000},
               {child_type,worker}]

q().
ok

10> anna@anna-pc:~/Документы/eltex/дз9/iotserv$ rebar3 shell
===> Verifying dependencies...
===> Analyzing applications...
===> Compiling iotserv
Erlang/OTP 25 [erts-13.2.2.5] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [jit:ns]

Eshell V13.2.2.5  (abort with ^G)
1> ===> Booted jsx
===> Booted iotserv

1> iotserv:lookup(1).
{ok,{iot,1,"Temp1","Room3",24,[{temp,22},{mem_load,56}]}}
