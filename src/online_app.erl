-module(online_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

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
                          cowboy_http_protocol, [{dispatch, Dispatch}]
                         ),
    online_sup:start_link().

stop(_State) ->
    cowboy:stop_listener(online).
