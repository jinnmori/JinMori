--Morphtronic Power Tool Motor
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.lcheck,2)
	--All "Morphtronic" monsters gains the following effect based on the Attack position
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.tgoval)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(s.indval)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)  
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(function(e,c) return not c:IsDisabled() and c:IsSetCard(SET_MORPHTRONIC) and c:IsAttackPos() end)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetLabelObject(e2)
	c:RegisterEffect(e4)
	--All "Morphtronic" monsters gains the following effect based on the Defense Position
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(1000)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e6:SetValue(1)
	local e7=e3:Clone()
	e7:SetTarget(function(e,c) return not c:IsDisabled() and c:IsSetCard(SET_MORPHTRONIC) and c:IsDefensePos() end)
	e7:SetLabelObject(e5)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetLabelObject(e6)
	c:RegisterEffect(e8)
	--Special Summon when sent to the GY
	local e9=Effect.CreateEffect(c)
	e9:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e9:SetProperty(EFFECT_FLAG_DELAY)
	e9:SetCode(EVENT_TO_GRAVE)
	e9:SetCountLimit(1,id)
	e9:SetTarget(s.sptg)
	e9:SetOperation(s.spop)
	c:RegisterEffect(e9)
end
s.listed_series={SET_MORPHTRONIC,SET_POWER_TOOL}
function s.lcheck(c,lc,sumtype,tp)
	return c:IsType(TYPE_EFFECT,lc,sumtype,tp) and c:IsRace(RACE_MACHINE,lc,sumtype,tp)
end
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_POWER_TOOL) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 then
		local dg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		Duel.SpecialSummon(dg,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
	end
end

