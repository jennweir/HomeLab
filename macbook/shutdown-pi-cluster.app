tell application "iTerm2"
    -- Get the list of windows
    set windowList to windows

    -- Check if there are any windows open
    if (count of windowList) is greater than 0 then
        -- Select the first window
        set firstWindow to item 1 of windowList
        
        -- Get the list of sessions in the first window
        set sessionList to sessions of firstWindow
        
        -- Check if there are at least three sessions
        if (count of sessionList) is greater than 2 then
            -- Select the sessions
            set firstSession to item 1 of sessionList
            set secondSession to item 2 of sessionList
            set thirdSession to item 3 of sessionList

            -- Run shutdown command in the first session
            tell firstSession
                write text "sudo shutdown -h now"
            end tell

            -- Run shutdown command in the second session
            tell secondSession
                write text "sudo shutdown -h now"
            end tell

            -- Run shutdown command in the third session
            tell thirdSession
                write text "sudo shutdown -h now"
            end tell
        else
            display dialog "Not enough sessions found in the first window." buttons {"OK"} default button "OK"
        end if
    else
        display dialog "No windows found." buttons {"OK"} default button "OK"
    end if
end tell
