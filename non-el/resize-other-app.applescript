on run argv
    set appName to item 1 of argv
    set x to item 2 of argv
    set y to item 3 of argv
    set w to item 4 of argv
    set h to item 5 of argv
    tell application appName
        set bounds of front window to {x, y, w, h}
    end tell
end run