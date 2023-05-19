--Accel Tuning
local s,id=GetID()
function s.initial_effect(c)
	--Activate 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE+EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	end
	function s.cfilter(c,e,tp,tuner,ntuner)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	local result=c:IsSynchroSummonable(nil,Group.FromCards(tuner,ntuner))
	Duel.AssumeReset()
	return result
end
function s.spfilter(c,e,tp,ntuner)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeSynchroMaterial() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,ntuner,e,tp,c,ntuner)
end
function s.mfilter(c,e,tp)
	return not c:IsType(TYPE_TUNER) and c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
       and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,c)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(e:GetHandler(),nil,tp,1,0,aux.Stringid(id,2),nil)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.mfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end 
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,tp,LOCATION_EXTRA)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
	if #pg>0 then return end
	local m=Duel.SelectTarget(tp,s.mfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local sc=Duel.GetFirstTarget()
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,sc)
	local tc=g:GetFirst()
      Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonComplete()
		local mg=Group.FromCards(sc,tc)
		local sync=Duel.GetMatchingGroup(function(sp) return sp:IsType(TYPE_SYNCHRO) and sp:IsSynchroSummonable(nil,mg) end,tp,LOCATION_EXTRA,0,nil)
	if #sync>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sp=sync:Select(tp,1,1,nil):GetFirst()
		Duel.SynchroSummon(tp,sp,nil,mg)
		end
	end
 