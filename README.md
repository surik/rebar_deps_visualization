# Rebar Dependencies Visualization Plugin

## Installation (rebar.config):

    %% Plugin dependency
    {deps, [
    	{rebar_deps_visualization, ".*", {git, "https://github.com/surik/rebar_deps_visualization.git", "master"}}
    ]}.

    %% Plugin usage
    {rebar_plugins, [rebar_deps_visualization]}.

## Usage:

    $ ./rebar visualize-deps   # generate deps_network.html 
