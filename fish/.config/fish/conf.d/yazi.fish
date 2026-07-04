function yy
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi --cwd-file="$tmp"
    if set cwd (cat "$tmp")
        and test -n "$cwd"
        cd "$cwd"
    end
    rm -f "$tmp"
end
