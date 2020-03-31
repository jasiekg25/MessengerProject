%%%-------------------------------------------------------------------
%%% @author jasiek
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. Mar 2020 22:30
%%%-------------------------------------------------------------------
-module(basic_protocol).
-author("jasiek").
-behaviour(ranch_protocol).

%% API
-export([start_link/3]).
-export([init/3]).

start_link(Ref, Transport, Opts) ->
  Pid = spawn_link(?MODULE, init, [Ref, Transport, Opts]),
  {ok, Pid}.

init(Ref, Transport, _Opts) ->
  {ok, Socket} = ranch:handshake(Ref),
  loop(Socket, Transport).

loop(Socket, Transport) ->
  case Transport:recv(Socket, 0, 60000) of
    {ok, Data} when Data =/= <<4>> ->
      Transport:send(Socket, Data),
      loop(Socket, Transport);
    _ ->
      ok = Transport:close(Socket)
  end.
