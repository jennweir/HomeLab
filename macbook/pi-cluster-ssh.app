tell application "iTerm2"
    -- Create a new window and SSH into the first machine
    set newWindow to (create window with default profile)
    tell current session of newWindow
        write text "ssh pi-1@raspberry-pi-1.local"
    end tell

    delay 2 -- Brief delay to ensure the SSH command executes properly

    -- Split the window vertically and SSH into the second machine
    tell current session of newWindow
        set secondPane to (split vertically with default profile)
        delay 2 -- Brief delay to ensure the split completes
        tell the secondPane
            write text "ssh pi-2@raspberry-pi-2.local"
        end tell
    end tell

    delay 2 -- Brief delay to ensure the SSH command executes properly

    -- Split the second pane vertically and SSH into the third machine
    tell secondPane
        set thirdPane to (split vertically with default profile)
        delay 2 -- Brief delay to ensure the split completes
        tell the thirdPane
            write text "ssh pi-3@raspberry-pi-3.local"
        end tell
    end tell
end tell
