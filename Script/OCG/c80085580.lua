--Evil HERO Link Monster
Duel.GetFusionMaterial=(function()
    local oldfunc=Duel.GetFusionMaterial
    return function(tp)
        local res=oldfunc(tp)
        local g=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_ALL,LOCATION_ALL,nil,EFFECT_EXTRA_FUSION_MATERIAL)
        if #g>0 then
            res:Merge(g)
        end
        return res
    end
end)()
local s,id=GetID()
Duel.LoadScript("DARK_FUSION.lua")
function s.initial_effect(c)
    c:EnableReviveLimit()
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_HERO),2,nil,s.matcheck)
    --Treat as "Elemental HERO"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_ADD_SETCODE)
	e1:SetRange(LOCATION_ALL)
    e1:SetValue(SET_ELEMENTAL_HERO)
    c:RegisterEffect(e1)
    --Treat as FIRE
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_ADD_ATTRIBUTE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(ATTRIBUTE_FIRE)
    c:RegisterEffect(e2)
    --Search
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_HERO,SET_ELEMENTAL_HERO,SET_EVIL_HERO}
s.listed_names={CARD_DARK_FUSION,12071500}
function s.matcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsSetCard,1,nil,SET_HERO,lc,sumtype,tp)
end
function s.thfilter(c)
    return c:IsCode(CARD_DARK_FUSION,12071500) and c:IsAbleToHand()
end
function s.revfilter(c)
 return c:IsSetCard(SET_EVIL_HERO) and c:IsType(TYPE_FUSION) and not c:IsPublic()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_EXTRA,0,1,nil)
        and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    if #g>0 then
        Duel.ConfirmCards(1-tp,g)
        local rc=g:GetFirst()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #sg>0 then
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
            local tc=sg:GetFirst()
            if tc:IsCode(CARD_DARK_FUSION,12071500) then
                --Add additional effect
                         local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_FIELD)
                e1:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
                e1:SetTargetRange(LOCATION_DECK,0)
                e1:SetTarget(s.mttg)
                e1:SetValue(function(_,c) return c:IsSetCard(SET_HERO) end )
                e1:SetLabel(rc:GetAttribute())
				e1:SetLabelObject(rc)
                e1:SetReset(RESET_PHASE+PHASE_END)
                Duel.RegisterEffect(e1,tp)
            end
        end
    end
end
function s.mttg(e,c)
    return c:IsSetCard(0x8) and c:IsAttribute(e:GetLabel())
end

function s.mtval(e,c)
    if not c then return false end
    return c:IsCode(CARD_DARK_FUSION,CARD_DARK_CALLING)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=e:GetLabelObject()
    return eg:IsContains(rc) and (r&REASON_FUSION)~=0
        and re and re:GetHandler():IsCode(CARD_DARK_FUSION,12071500)
end