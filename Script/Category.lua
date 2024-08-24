-- Define the new category constant
CATEGORY_SET = 0x8000000000000000

-- Function to check if a card has a set effect
local function HasSetEffect(c)
    local effs={c:GetCardEffect()}
    for _, eff in ipairs(effs) do
        local prop = eff:GetProperty()
        if (prop & EFFECT_FLAG_CARD_TARGET)~=0 and eff:GetOperation() then
            local op = eff:GetOperation()
            local opstr = tostring(op)
            if opstr:match("POS_FACEDOWN") and opstr:match("c:SetStatus") then
                return true
            end
        end
    end
    return false
end

-- Function to add the CATEGORY_SET to a card
function Card.AddSetCategory(c)
    if not c:IsHasCategory(CATEGORY_SET) then
        c:RegisterFlagEffect(CATEGORY_SET, 0, 0, 0)
    end
end

-- Function to check if a card has the CATEGORY_SET
function Card.IsSetCategory(c)
    return HasSetEffect(c) or c:GetFlagEffect(CATEGORY_SET)>0
end

-- Function to initialize the category for all cards
local function InitializeSetCategory()
    local g=Duel.GetFieldGroup(0,0xff,0xff)
    for tc in aux.Next(g) do
        if HasSetEffect(tc) then
            tc:AddSetCategory()
        end
    end
end

-- Run the initialization when the script is loaded
InitializeSetCategory()