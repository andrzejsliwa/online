-module(online_app).
-behaviour(application).

-include_lib("cowboy/include/http.hrl").

%% Application callbacks
-export([start/2, stop/1]).

-define(REC_INFO(T,R), lists:zip(record_info(fields, T), tl(tuple_to_list(R)))).

%% +-----------------------------------------------------------------+
%% | CALLBACKS FUNCTIONS                                             |
%% +-----------------------------------------------------------------+
start(_StartType, _StartArgs) ->
    Dispatch =
        [{'_', [{[], cowboy_http_static,
                 [{directory, {priv_dir, online, [<<"www">>]}},
                  {file, <<"index.html">>},
                  {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
                 ]},
                {['...'], cowboy_http_static,
                 [{directory, {priv_dir, online, [<<"www">>]}},
                  {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
                 ]}
               ]}
        ],
    lager:info("start cowboy http://localhost:8080"),
    cowboy:start_listener(online, 16,
                          cowboy_tcp_transport, [{port, 8080}],
                          cowboy_http_protocol, [{dispatch, Dispatch},
                                                 {onrequest, fun cowboy_debug:onrequest_hook/1},
                                                 {onresponse, fun  cowboy_debug:onresponse_hook/3}]
                         ),
    online_sup:start_link().

stop(_State) ->
    cowboy:stop_listener(online).
