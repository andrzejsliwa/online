%% See LICENSE for licensing information.
-module(cowboy_debug).

-include_lib("cowboy/include/http.hrl").

-export([onrequest_hook/1,
         onresponse_hook/3]).

%% +-----------------------------------------------------------------+
%% | INTERFACE FUNCTIONS                                             |
%% +-----------------------------------------------------------------+

onrequest_hook(Req) ->
    Method = to_string(Req#http_req.method),
    Path = to_string(Req#http_req.raw_path),
    Params = params_to_string(Req#http_req.qs_vals),
    Host = to_string(Req#http_req.host, "."),
    Port = port_to_string(Req#http_req.port),
    lager:info("~n~nStarted " ++ Method ++ " " ++ Path ++ Params ++ " for " ++ Host ++ Port ++ "~n"
               "  qs_vals  : " ++ to_native_string(Req#http_req.qs_vals) ++ "~n"
               "  raw_qs   : " ++ to_native_string(Req#http_req.raw_qs) ++ "~n"
               "  bindings : " ++ to_native_string(Req#http_req.bindings) ++ "~n"
               "  cookies  : " ++ to_native_string(Req#http_req.cookies) ++ "~n"
               "  headers  : " ++ to_native_string(Req#http_req.headers)),
    Req.

onresponse_hook(Code, Headers, Req) ->
    Method = to_string(Req#http_req.method),
    Path = to_string(Req#http_req.raw_path),
    Params = params_to_string(Req#http_req.qs_vals),
    Host = to_string(Req#http_req.host, "."),
    Port = port_to_string(Req#http_req.port),
    lager:info(
      "~n~nCompleted " ++ to_string(Code) ++ " " ++ Method ++ " " ++ Path ++ Params ++ " for " ++ Host ++ Port ++ "~n"
      "  cookies  : " ++ to_native_string(Req#http_req.cookies) ++ "~n"
      "  headers  : " ++ to_native_string(Headers)),
    Req.

%% +-----------------------------------------------------------------+
%% | PRIVATE FUNCTIONS                                               |
%% +-----------------------------------------------------------------+

params_to_string(Params) ->
    case to_string(Params) of
        "" -> "";
        OtherParams -> "?" ++ OtherParams
    end.

port_to_string(Port) ->
    case to_string(Port) of
        "80" -> "";
        OtherPort -> ":" ++ OtherPort
    end.

%% print value as standard format
to_native_string(Value) ->
    io_lib:format("~p", [Value]).

%% convert everything to string
to_string(undefined) ->
    "";
to_string(Atom) when is_atom(Atom) ->
    atom_to_list(Atom);
to_string(Binary) when is_binary(Binary) ->
    binary_to_list(Binary);
to_string(Integer) when is_integer(Integer) ->
    integer_to_list(Integer);
to_string([])
-> "";
to_string(List) when is_list(List) ->
    to_string(List, "").

%% convert lists to string
to_string(List, Separator) when is_list(List) ->
    string:join(list_to_string(List, []), Separator).

list_to_string([], Result) ->
    lists:reverse(Result);
list_to_string([Head| Rest], Result) ->
    list_to_string(Rest, [to_string(Head)|Result]).
