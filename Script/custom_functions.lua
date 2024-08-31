-- custom_functions.lua

Card = Card or {}

function Card.InitializationCards()
    -- This function would typically initialize card data
    -- For EDOPro, this might not be necessary, but we'll keep it as a placeholder
end

function Card.GetCardText(code)
    -- In EDOPro, you can use the Database API to get card text
    local card = Duel.GetCardFromCardID(code)
    if card then
        return card.desc
    end
    return ""
end

-- New function to get cards based on text
function GetCardsWithText(tp, location, text_to_match)
    local g = Duel.GetMatchingGroup(function(c)
        local card_text = Card.GetCardText(c:GetCode())
        return card_text:find(text_to_match)
    end, tp, location, 0, nil)
    return g
end