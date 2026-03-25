local _ENV = (getgenv or getrenv or getfenv)()

local StarterGui = game:GetService("StarterGui")
local Players = game:GetService('Players')

local LocalPlayer = Players.LocalPlayer

local function IsAlive(Character)
    return Character and Character:FindFirstChild("Humanoid") and Character:FindFirstChild("HumanoidRootPart") and Character.Humanoid.Health > 0
end

local function Distance(Position)
    return Position and ((typeof(Position) == 'CFrame' and LocalPlayer:DistanceFromCharacter(Position.Position)) or LocalPlayer:DistanceFromCharacter(Position))
end

local function GetZombie()
    local Nearest, Distancer = nil, math.huge

    for _, v in workspace:GetChildren() do
        if not v:GetAttribute('Zombie') then continue end

        if not IsAlive(v) then continue end

        local Head = v:FindFirstChild('Head')

        if not Head then continue end

        local Magnitude = Distance(Head.Position)

        if Magnitude < Distancer then
            Nearest, Distancer = Head, Magnitude
        end
    end

    return Nearest
end

task.defer(function()
    for _, func in getgc(true) do
        if typeof(func) == "function" then
            local Source = debug.info(func, 's')

            if not Source or not Source:find('RaycastModule') then
                continue
            end

            local Constants = getconstants(func)

            if table.find(Constants, "MaxIterations") then
                local old

                old = hookfunction(func, function(Origin, Direction, Params)
                    local Target = GetZombie()

                    if Target then
                        local Current = (Target.Position - Origin)

                        if Current.Magnitude > 0 then
                            Direction = Current.Unit * Direction.Magnitude
                        end
                    end

                    return old(Origin, Direction, Params)
                end)

                StarterGui:SetCore("SendNotification", {
                    Title = "Hooked !",
                    Text = "By vita6it",
                    Duration = 3
                })

                break
            end
        end
    end
end)
