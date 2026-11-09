if status is-interactive
    # Commands to run in interactive sessions can go here
end

if command -q direnv
    direnv hook fish | source
end
