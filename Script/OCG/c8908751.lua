--Sky Striker Maneuver - Final Slash!
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 2 monsters with the same name from the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.cfilter(c)
	return c:GetSequence()<5
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.costfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER_ACE) and c:IsLinkMonster() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetTextAttack())
end
function s.tgfilter(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsMonster() and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,e) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,e)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,0)
end
function s.lnkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SKY_STRIKER_ACE) and c:IsLinkMonster()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)	
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	--its atk decreased by the ATK of the monster sent to GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-e:GetLabel())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local lc=Duel.GetMatchingGroup(s.lnkfilter,0,LOCATION_MZONE,0,nil)
	lg=lc:Select(tp,1,1,nil)
	local oppzone=tc:GetToBeLinkedZone(lg:GetFirst(),tp)
	local zone=aux.GetMMZonesPointedTo(tp,s.lnkfilter,LOCATION_MZONE,0,1-tp)
	--1st checkpoint
	local b1=tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_COUNT,zone)>0
	--2nd checkpoint
	local b2=tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_COUNT,oppzone)>0
	local op=Duel.SelectEffect(tp,
	{b1,aux.Stringid(id,1)},
	{b2,aux.Stringid(id,2)})
	--Move it to the zone where a "Sky Striker Ace" monster points to
	if op==1 then
	if zone==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,~zone<<16)>>16,2))
	--Move the targeted monster to a zone where the targeted monster points to a "Sky Striker Ace' link monster 
	elseif op==2 then
	if oppzone==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,~oppzone<<16)>>16,1))
		end
	end