--NEO
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE+EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
--Neos EnableNeosReturn 
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(Auxiliary.NeosReturnCondition1)
	e3:SetTarget(Auxiliary.NeosReturnTarget(c,extrainfo))
	e3:SetOperation(Auxiliary.NeosReturnOperation(c,extraop))
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(0)
	e4:SetCondition(Auxiliary.NeosReturnCondition2)
	c:RegisterEffect(e4)
	if returneff then
		e3:SetLabelObject(returneff)
		e4:SetLabelObject(returneff)
	end
end
s.listed_names={CARD_NEOS}
s.listed_series={SET_NEO_SPACIAN}
function s.filter2(c,e,tp)
	return c:IsSetCard(SET_NEO_SPACIAN) and c:IsAbleToGrave() and c:IsCanBeFusionMaterial()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local o=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoGrave(o,REASON_COST)
	local o=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	Duel.SetTargetCard(o)
end
function s.filter(c,e,tp,mc)
if Duel.GetLocationCountFromEx(tp,tp,mc,c)<=0 then return false end
	local mustg=aux.GetMustBeMaterialGroup(tp,nil,tp,c,nil,REASON_FUSION)
	return c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false)
		and Card.ListsCodeAsMaterial(c,mc:GetCode()) and (#mustg==0 or (#mustg==1 and mustg:IsContains(mc)))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeFusionMaterial() and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		local sc=sg:GetFirst()
		if sc then
			sc:SetMaterial(Group.FromCards(tc))
			Duel.SendtoGrave(tc,REASON_EFFECT+REASON_MATERIAL)
			Duel.BreakEffect()
			Duel.SpecialSummon(sc,SUMMON_TYPE_SPECIAL,tp,tp,true,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end
function Auxiliary.NeosReturnCondition1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsHasEffect(42015635)
end
function Auxiliary.NeosReturnCondition2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsHasEffect(42015635)
end
function Auxiliary.NeosReturnTarget(c,extrainfo)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
		if extrainfo then extrainfo(e,tp,eg,ep,ev,re,r,rp,chk) end
	end
end
function Auxiliary.NeosReturnSubstituteFilter1(c)
	return c:IsCode(14088859) and c:IsAbleToRemoveAsCost()
end
function Auxiliary.NeosReturnSubstituteFilter2(c)
	return c:IsCode(id) and c:IsAbleToDeckAsCost()
end
function Auxiliary.NeosReturnOperation(c,extraop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		local sc1=Duel.GetFirstMatchingCard(Auxiliary.NecroValleyFilter(Auxiliary.NeosReturnSubstituteFilter1),tp,LOCATION_GRAVE,0,nil)
		local sc2=Duel.GetFirstMatchingCard(Auxiliary.NecroValleyFilter(Auxiliary.NeosReturnSubstituteFilter2),tp,LOCATION_GRAVE,0,nil)
		if sc1 and Duel.SelectYesNo(tp,aux.Stringid(14088859,0)) then
			Duel.Remove(sc1,POS_FACEUP,REASON_COST)
		elseif c:ListsCodeAsMaterial(CARD_NEOS) and sc2 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.SendtoDeck(sc2,nil,2,REASON_COST)
		else
			Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
		end
		if c:IsLocation(LOCATION_EXTRA) then
			if extraop then
				extraop(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end