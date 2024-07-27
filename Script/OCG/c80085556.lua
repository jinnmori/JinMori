--Number C75: Bamboozling Gossip Umbral Horror
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER),4,3)
    --Effect change
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.condition)
	e1:SetCost(aux.dxmcostgen(2,2,nil))
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
    --Attach to another "Number" monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.attachtg)
    e2:SetOperation(s.attachop)
    c:RegisterEffect(e2)
end
s.listed_Series={SET_NUMBER}
s.listed_names={71166481}
s.xyz_number=75 -- Replace XX with the actual Number
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.ChangeChainOperation(ev,s.repop(c))
end
function s.repop(c)
    return function(e,tp,eg,ep,ev,re,r,rp)
        if c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,71166481) and Duel.IsPlayerCanDraw(1-tp,2)then
            Duel.Draw(1-tp,2,REASON_EFFECT)
        elseif Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) then
            Duel.Draw(tp,1,REASON_EFFECT)
            Duel.Draw(1-tp,1,REASON_EFFECT)
        end
    end
end
function s.attachfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_NUMBER)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.attachfilter(chkc) and chkc~=e:GetHandler() end
    if chk==0 then return e:GetHandler():IsType(TYPE_MONSTER) and Duel.IsExistingTarget(s.attachfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.attachfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or not tc:IsRelateToEffect(e) then return end
    local og=c:GetOverlayGroup()
    if #og==0 then return end
    Duel.Overlay(tc,Group.FromCards(c))
    if #og>0 then
        Duel.Overlay(tc,og)
    end
   -- Grant effects of all Xyz Materials
   if c:IsLocation(LOCATION_OVERLAY) then
        local attached_cards = tc:GetOverlayGroup()
        for oc in aux.Next(attached_cards) do
            if attached_cards:IsContains(c) then  -- Skip the original card itself
                local effs = {oc:GetCardEffect()}
                for _, eff in ipairs(effs) do
                    local e1 = eff:Clone()
                    e1:SetRange(LOCATION_MZONE)
					e1:SetDescription(aux.Stringid(id,2))
					e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
                    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                    tc:RegisterEffect(e1)
                end
            end
        end
    end
end