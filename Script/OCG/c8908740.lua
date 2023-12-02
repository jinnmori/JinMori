--Book of Polar Night
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetLabel(0)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--Activate it from your hand during opponent's turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.acthcon)
	e2:SetValue(function(e,c) e:SetLabel(1) end)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
function s.spfilter(c,e,tp,race,attr)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and c:IsMonster() and c:IsRace(race) and c:IsAttribute(attr)
end
function s.cfilter(c,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE,0,nil,e,tp,c:GetRace(),c:GetAttribute())
	if ft<=0 or #tg==0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and #tg>0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,e,tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tp=e:GetHandlerPlayer()
	if chk==0 then return Duel.CheckLPCost(tp,800) and not e:GetLabelObject():SetLabel(0) end
	if e:GetLabelObject():GetLabel()>0 then
	e:GetLabelObject():SetLabel(0)
	Duel.PayLPCost(tp,800)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg and eg:IsExists(s.cfilter,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:Filter(s.cfilter,nil,e,tp):GetFirst()
	if not ec then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE,0,nil,e,tp,ec:GetRace(),ec:GetAttribute())
	if ft<=0 or #tg==0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=tg:Select(tp,ft,ft,nil)
	for tc in aux.Next(g) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		--Cannot activate their effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3302)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetValue(POS_FACEDOWN_DEFENSE+NO_FLIP_EFFECT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
function s.acthcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetLP(tp)>2000
end