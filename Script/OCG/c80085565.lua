--Infenity Fraudster
local s,id=GetID()
function s.initial_effect(c)
    --link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_DARK),2,2)
    c:EnableReviveLimit()
    --While this card is face-up on the field,ignore the condition
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.effcon)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Send "Infernity" card and Set Spell
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.tgcon)
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    c:RegisterEffect(e2)
end
s.listed_series={SET_INFERNITY}
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	return c:IsLocation(LOCATION_MZONE)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	 --Remove conditions from effects
	local c=e:GetHandler()
     c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD+RESET_DISABLE|RESETS_STANDARD_DISABLE,0,1)
end
function s.flagfilter(c)
    return c:IsFaceup() and c:GetFlagEffect(80085565)>0
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 or Duel.IsExistingMatchingCard(s.flagfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.tgfilter(c)
    return c:IsSetCard(SET_INFERNITY) and c:IsAbleToGrave()
end

function s.setfilter(c)
    return c:IsSetCard(SET_INFERNITY) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
        and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #sg>0 then
            Duel.SSet(tp,sg:GetFirst())
        end
    end
end