--Vice Mudragon
local s,id=GetID()
function s.initial_effect(c)
    --link summon
  	Link.AddProcedure(c,s.linkfilter,2,nil,s.spcheck)
    c:EnableReviveLimit()
    --can be used as substitute for Fusion Material
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
    e1:SetCondition(s.subcon)
    c:RegisterEffect(e1)
    --add "Fusion" or "Polymerization" to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end
function s.linkfilter(c,lc,sumtype,tp)
	return not c:IsType(TYPE_TOKEN,lc,sumtype,tp)
end
function s.spcheck(g,lc,tp)
	return g:CheckSameProperty(Card.GetAttribute,lc,SUMMON_TYPE_LINK,tp) and not g:CheckSameProperty(Card.GetRace,lc,SUMMON_TYPE_LINK,tp)
end
function s.subcon(e)
    return e:GetHandler():IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE)
end
function s.thfilter1(c,lg)
	return c:IsFaceup() and lg:IsContains(c) and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
end
function s.thfilter2(c)
    return c:IsNormalSpell() and (c:IsCode(CARD_POLYMERIZATION) or c:ListsCode(CARD_POLYMERIZATION)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
   local lg=e:GetHandler():GetLinkedGroup()
	local zone=e:GetHandler():GetLinkedZone(tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.thfilter1(chkc,lg) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
		and Duel.IsExistingTarget(s.thfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.thfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,lg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        --register effect to take damage
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetCondition(s.damcon)
        e1:SetOperation(s.damop)
        e1:SetReset(RESET_PHASE+PHASE_END)
        e1:SetLabelObject(tc)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    return not tc:IsReason(REASON_FUSION)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(tp,2000,REASON_EFFECT)
end