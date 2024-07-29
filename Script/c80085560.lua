--The Phantom Knights of Sharp Spear
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_WARRIOR),2)
	c:EnableReviveLimit()
	--Monsters this card points to gain 1000 ATK
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.atktg)
    e1:SetValue(1000)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e2)
	--Send opponent's card to GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.gycon1)
    e3:SetTarget(s.gytg)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_REMOVE)
    e4:SetCondition(s.gycon2)
    c:RegisterEffect(e4)
  --Special Summon Xyz from Extra Deck
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetRange(LOCATION_GRAVE)
    e5:SetCountLimit(1,{id,1})
    e5:SetTarget(s.sptg)
    e5:SetOperation(s.spop)
    c:RegisterEffect(e5)
end
s.listed_series={SET_PHANTOM_KNIGHTS,SET_THE_PHANTOM_KNIGHTS}
function s.atktg(e,c)
    return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsRace(RACE_WARRIOR)
end
function s.gyconfilter(c)
	return c:IsSetCard(SET_THE_PHANTOM_KNIGHTS) and c:IsType(TYPE_XYZ) 
end
function s.gyconfilter2(c)
	return c:IsSetCard(SET_PHANTOM_KNIGHTS) and c:IsSpellTrap() 
end
function s.gycon1(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.gyconfilter,1,nil)
end
function s.gycon2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(gyconfilter2,1,nil)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0 end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
        local sg=g:Select(1-tp,1,1,nil)
        Duel.SendtoGrave(sg,REASON_RULE)
    end
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_THE_PHANTOM_KNIGHTS) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsSetCard(SET_THE_PHANTOM_KNIGHTS) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
        and Duel.IsExistingTarget(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,SET_THE_PHANTOM_KNIGHTS)
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
        and e:GetHandler():IsAbleToExtra() end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,Card.IsSetCard,tp,LOCATION_MZONE,0,1,1,nil,SET_THE_PHANTOM_KNIGHTS)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
    if Duel.SendtoDeck(c,nil,0,REASON_EFFECT)==0 then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    if #g>0 then
        local sc=g:GetFirst()
        if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 then
            sc:CompleteProcedure()
            if tc:IsRelateToEffect(e) then
                Duel.Overlay(sc,tc)
            end
        end
    end
end
