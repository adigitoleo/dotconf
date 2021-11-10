# Reduce color space of most REPL components from 16 to 8.
# Line numbers is stacktraces are still unreadable in dark themes...
Base.text_colors[:white] = Base.text_colors[:yellow]
Base.text_colors[:light_cyan] = Base.text_colors[:cyan]
Base.text_colors[:light_red] = Base.text_colors[:red]
Base.text_colors[:light_magenta] = Base.text_colors[:magenta]
Base.text_colors[:light_yellow] = Base.text_colors[:yellow]
Base.text_colors[:light_black] = Base.text_colors[:normal]
Base.text_colors[:light_blue] = Base.text_colors[:blue]
Base.text_colors[:light_green] = Base.text_colors[:green]

"""List available named colors from Base.colors."""
function colornames()
    for key in keys(Base.text_colors)
        if isa(key, Symbol)
            println(key)
        end
    end
end


"""List modules loaded into m with the `using` keyword."""
function modules(m::Module)
    return ccall(:jl_module_usings, Any, (Any,), m)
end


"""Get a dictionary of dependencies of a package and their UUIDs."""
function dependencies(package)
    return Pkg.dependencies()[Pkg.project().dependencies[package]].dependencies
end
