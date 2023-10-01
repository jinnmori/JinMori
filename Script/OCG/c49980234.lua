--New Shining Star
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
--Synchro Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_STARDUST}
function s.oppfilter(c,tp,self)
	return c:IsFaceup() and c:IsCanBeSynchroMaterial() and Duel.IsExistingMatchingCard(s.yourfilter,tp,LOCATION_MZONE,0,1,nil,c,tp,self)
end
function s.synfilter(c,mg,tp)
	return c:IsSynchroSummonable(nil,mg) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
function s.yourfilter(c,oppcard,tp,owner)
	if not (c:IsFaceup() and c:IsCanBeSynchroMaterial()) then return false end
	local e1=Effect.CreateEffect(owner)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL)
	oppcard:RegisterEffect(e1,true)
	local mg=Group.FromCards(c,oppcard)
	local res=Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,mg,tp)
	e1:Reset()
	return res
end
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsSetCard(SET_STARDUST) and c:IsControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(s.cfilter,1,nil,e,tp) and Duel.IsExistingMatchingCard(s.oppfilter,tp,0,LOCATION_MZONE,1,nil,tp,c)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local oppcard=Duel.GetMatchingGroup(s.oppfilter,tp,0,LOCATION_MZONE,nil,tp,c)
	local tc=oppcard:GetFirst()
	for tc in aux.Next(oppcard) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e1,true)
		local mg=g:AddCard(oppcard)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg,tp):GetFirst()
		if sc then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_SPSUMMON_SUCCESS)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			e2:SetOperation(s.regop)
			e2:SetLabelObject(e1)
			sc:RegisterEffect(e2,true)
			local e3=e2:Clone()
			e3:SetCode(EVENT_SPSUMMON_NEGATED)
			sc:RegisterEffect(e3,true)
			Duel.SynchroSummon(tp,sc,g,mg)
		else
			e1:Reset()
		end
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Reset()
	e:Reset()
end