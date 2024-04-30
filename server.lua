
-- vrp_skills - @highestop

local uSkills = {}
local MinExperience = 100
local MaxSkillLevel = 3

function SkillLevelUp(user_id, skill)
    if user_id and uSkills[user_id] and uSkills[user_id][skill] then
        local UserLevel = uSkills[user_id][skill].Nivel
        if UserLevel < MaxSkillLevel then
            uSkills[user_id][skill].xp = 0
            uSkills[user_id][skill].Nivel = UserLevel + 1
        end
    end
end

function vRP.GiveSkillExperience(user_id, skill, exp)
    if user_id and uSkills[user_id] and uSkills[user_id][skill] then
        local level = uSkills[user_id][skill].Nivel
        if level < MaxSkillLevel then
            uSkills[user_id][skill].xp = uSkills[user_id][skill].xp + exp
            if uSkills[user_id][skill].xp >= MinExperience then
                SkillLevelUp(user_id, skill)
            end
        end
    end
end

function vRP.GetPlayerSkill(user_id, skill)
    if user_id and uSkills[user_id] and uSkills[user_id][skill] then
        return uSkills[user_id][skill].Nivel
    end
    return 0
end

AddEventHandler('vRP:playerSpawn', function(user_id, source, first_spawn)
    if first_spawn then
        uSkills[user_id] = {}
        exports.oxmysql:fetch('SELECT PlayerSkills FROM vrp_users WHERE id = ?', {user_id}, function(result)
            if result and result[1] and result[1].PlayerSkills then
                uSkills[user_id] = json.decode(result[1].PlayerSkills) or {}
            end
        end)
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id, source)
    if uSkills[user_id] then
        exports.oxmysql:execute("UPDATE vrp_users SET PlayerSkills = ? WHERE id = ?", {json.encode(uSkills[user_id]), user_id})
        uSkills[user_id] = nil
    end
end)
