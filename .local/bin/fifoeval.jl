#!/bin/julia

# TODO: some CLI help with --help/-h.
isempty(ARGS) && error("Please supply a FIFO path")
Base.exit_on_sigint(false)
while true
    try
        # TODO: check if it's really a fifo.
        include(joinpath(pwd(), ARGS[1]))
    catch e
        if e isa InterruptException
            break
        else
            @warn e
        end
    end
end
