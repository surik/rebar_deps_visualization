-module(rebar_deps_visualization).

-export(['visualize-deps'/2]).

'visualize-deps'(Config, _AppFile) ->
    Current = rebar_utils:get_cwd(),
    CurrentAppName = app_name(Current),
    Network = uflatten(traversal(Current)),
    {ok, Html} = network_view:render([{title, title(CurrentAppName)},
                                      {network, network(Network)}]),
    ok = file:write_file("deps_network.html", lists:flatten(Html)),
    {ok, Config}.


traversal(Current) ->
    ConfigFile = filename:join([Current, "rebar.config"]),
    {Config, Deps} = case file:read_file_info(ConfigFile) of
        {ok, _} -> 
            C = rebar_config:new(ConfigFile),
            {C, rebar_config:get_local(C, deps, [])};
        _ -> {[], []}
    end,
    [begin
        DepAppName = app_name(Dep),
        [{app_name(Current), DepAppName}] ++ traversal(deps_dir(Config, DepAppName)) 
     end || Dep <- Deps].

app_name(App) when is_list(App) -> list_to_atom(lists:last(filename:split(App)));
app_name(App) when is_atom(App) -> App;
app_name({App, _}) when is_atom(App) -> App;
app_name({App, _, _}) when is_atom(App) -> App.

deps_dir(Config, App) ->
    DepsDir = rebar_config:get_xconf(Config, deps_dir, "deps"),
    BaseDir = try
        rebar_utils:base_dir(Config)
    catch
        _:_ -> rebar_utils:get_cwd()
    end,
    filename:join([BaseDir, DepsDir, App]).

uflatten(List) ->
    lists:usort(lists:flatten(List)).

title(App) -> 
    <<(atom_to_binary(App, latin1))/binary, "'s dependencies network">>.

network(Network) ->
    Apps = uflatten([[To, From] || {To, From} <- Network]),
    Nodes = [io_lib:format("{id: '~s'},", [App]) || App <- Apps],
    Edges = [io_lib:format("{from: '~s', to: '~s'},", [From, To]) || {From, To} <- Network],
    <<"var nodes = [", (list_to_binary(Nodes))/binary, "];",
      "var edges = [", (list_to_binary(Edges))/binary, "];">>.
