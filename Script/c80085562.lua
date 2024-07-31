--Belcanto the Melodious Songstress
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),1,99,s.mfilter)
    --Must be Fusion Summoned
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(aux.fuslimit)
    c:RegisterEffect(e1)
    --Cannot be used as Fusion Material
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    --Shuffle and draw on Special Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.shcon)
    e3:SetTarget(s.shtg)
    e3:SetOperation(s.shop)
    c:RegisterEffect(e3)
    --Add Melodious Pendulum Monster
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,{id,1})
    e4:SetCost(s.thcost)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
end
s.listed_series={SET_MELODIOUS}
s.material_setcode={SET_MELODIOUS}
function s.mfilter(c,fc,sumtype,tp)
	return c:IsSetCard(SET_MELODIOUS,fc,sumtype,tp)
end
function s.shfilter(c)
    return c:IsSetCard(SET_MELODIOUS) and c:IsAbleToDeck()
end
function s.shcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
function s.shtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.shfilter(chkc) end
    local c=e:GetHandler()
    local ct=c:GetMaterialCount()
    local monster_ct=c:GetMaterial():FilterCount(Card.IsMonster,nil)
    if chk==0 then return monster_ct>0 and Duel.IsPlayerCanDraw(tp,1)
        and Duel.IsExistingTarget(s.shfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.shfilter,tp,LOCATION_GRAVE,0,1,monster_ct,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,math.floor(#g/2))
end
function s.shop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetTargetCards(e)
    if #tg==0 then return end
    Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)
    local og=Duel.GetOperatedGroup()
    local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
    if ct>0 then
        Duel.ShuffleDeck(tp)
        Duel.BreakEffect()
        Duel.Draw(tp,math.floor(ct/2),REASON_EFFECT)
    end
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.thfilter(c)
    return c:IsSetCard(SET_MELODIOUS) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end