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
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_STARDUST}
function s.rescon(player)
	return function(sg,e,tp,mg)
    return sg:FilterCount(Card.IsControler,nil,player)>=1
    end
end
function s.spfilter2(c,e,tp,step)
	local mg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,REASON_SYNCHRO)
	return aux.SelectUnselectGroup(mg,e,tp,1,#mg,s.rescon(tp),0) and Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_SYNCHRO)>0
		and Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
end
function s.synfilter(c,sg,tp)
	return aux.SelectUnselectGroup(sg,e,tp,1,#sg,s.rescon(tp),0) and Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil,sg) and c:IsCanBeSynchroMaterial()
end
function s.scfilter(c,mg)
	return c:IsSynchroSummonable(nil,mg)
end
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsSetCard(SET_STARDUST) and c:IsControler(tp)
	and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,true)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,e,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,0,0,1)
	local sg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		local mg=Duel.GetMatchingGroup(s.synfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,sg,tp)
		local tc=mg:GetFirst()
	for tc in aux.Next(mg) do
			if tc:IsControler(1-tp) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e1,true)
	end
		local eg=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA,0,nil,mg)
		if #eg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=eg:Select(tp,1,1,nil):GetFirst()
			if sc then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_SPSUMMON_SUCCESS)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
			e3:SetOperation(s.regop)
			e3:SetLabelObject(e1)
			sc:RegisterEffect(e3,true)
			local e4=e3:Clone()
			e4:SetCode(EVENT_SPSUMMON_NEGATED)
			sc:RegisterEffect(e4,true)
			Duel.SynchroSummon(tp,sc,nil,sg)
		else
			c:ResetFlagEffect(id)
			e1:Reset()
			end
		end
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetOwner()
	local c=e:GetHandler()
	rc:ResetFlagEffect(id)
	e:GetLabelObject():Reset()
	e:Reset()
end