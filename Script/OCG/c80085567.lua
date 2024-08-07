--Scourge Left Arm of the Forbidden One
local s,id=GetID()
function s.initial_effect(c)
    --Name becomes "Left Arm of the Forbidden One" in hand or GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetValue(7902349)
    c:RegisterEffect(e1)
    --Add "Left Arm of the Forbidden One" or "Exxod" Spell/Trap
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    --Protection effect
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.indtg)
    e3:SetValue(1)
    c:RegisterEffect(e3)
end
s.listed_series={SET_EXODIA,SET_EXODO}
s.listed_names={7902349,83257450}
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.thfilter(c)
    return c:IsCode(7902349) and c:IsAbleToHand()
end
function s.exxodfilter(c)
    return c:IsSetCard(SET_EXODO) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.revfilter(c)
    return c:IsCode(7902349) and not c:IsPublic()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
        or (Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_HAND,0,1,nil)
        and Duel.IsExistingMatchingCard(s.exxodfilter,tp,LOCATION_DECK,0,1,nil)) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
    local g2=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_HAND,0,nil)
    local g3=Duel.GetMatchingGroup(s.exxodfilter,tp,LOCATION_DECK,0,nil)
    if #g1>0 and (#g2==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g1:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    elseif #g2>0 and #g3>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
        local sg=g2:Select(tp,1,1,nil)
        Duel.ConfirmCards(1-tp,sg)
        Duel.ShuffleHand(tp)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local tg=g3:Select(tp,1,1,nil)
        Duel.SendtoHand(tg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tg)
    end
end

function s.indtg(e,c)
    return c:IsSetCard(SET_EXODIA) or c:IsCode(83257450)
end