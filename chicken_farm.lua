local remote = game.ReplicatedStorage.Paper.Remotes.__remoteevent

UI.AddTab("Nigga", function(tab)
    local section = tab:Section("Main", "Left")
    section:Toggle("Auto collect eggs", "Auto collect eggs")

end)


task.spawn(function()

    while true do

        if not UI.GetValue("Auto collect eggs") then
            task.wait(1)
            continue
        
        end

        for _, egg in ipairs(game.Workspace.Eggs:GetChildren()) do
            remote:FireServer("Collect Egg", egg.Name)
        --egg:Destroy();
        end

        print("collected")

        task.wait(1)
    end
end)
