--Morphtronic Walkie-Talkie
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Synchro Monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.cona)
	e1:SetTarget(s.tga)
	e1:SetOperation(s.opa)
	c:RegisterEffect(e1)
	--Special Summon Any number of non tuner and 1 tuner
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.cond)
	e2:SetTarget(s.tgd)
	e2:SetOperation(s.opd)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MORPHTRONIC}
function s.cona(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsAttackPos()
end
function s.syfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:GetLevel()<9 and (Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 or Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),69832741))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.IsExistingMatchingCard(s.tfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end
function s.tfilter(c,e,tp,sc)
local rg=Duel.GetMatchingGroup(s.ntfilter,tp,LOCATION_GRAVE,0,c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsSetCard(SET_MORPHTRONIC) and c:IsAbleToRemove() and aux.SpElimFilter(c,true) 
		and aux.SelectUnselectGroup(rg,e,tp,nil,nil,s.rescon(c,sc),0)
end
function s.ntfilter(c,e,tp)
	return c:HasLevel() and c:IsSetCard(SET_MORPHTRONIC) and not c:IsType(TYPE_TUNER) and c:IsAbleToRemove() and aux.SpElimFilter(c,true)
end
function s.rescon(tuner,scard)
	return	function(sg,e,tp,mg)
		sg:AddCard(tuner)
		local res=Duel.GetLocationCountFromEx(tp,tp,sg,scard)>0 and sg:CheckWithSumEqual(Card.GetLevel,scard:GetLevel(),#sg,#sg)
		sg:RemoveCard(tuner)
		return res
	end
end
function s.tga(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.syfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and #pg<=0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.opa(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,s.syfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local sc=g1:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectMatchingCard(tp,s.tfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,sc)
	local tuner=g2:GetFirst()
	local rg=Duel.GetMatchingGroup(s.ntfilter,tp,LOCATION_GRAVE,0,tuner,e,tp)
	local sg=aux.SelectUnselectGroup(rg,e,tp,nil,nil,s.rescon(tuner,sc),1,tp,HINTMSG_REMOVE,s.rescon(tuner,sc))
	sg:AddCard(tuner)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
	sc:CompleteProcedure()
end
function s.cond(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsDefensePos()
end
function s.syfilter2(c,e,tp)
	return c:IsType(TYPE_SYNCHRO)
		and Duel.IsExistingMatchingCard(s.tfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp,c) and c:IsAbleToRemove() and aux.SpElimFilter(c,true) 
end
function s.tfilter2(c,e,tp,sc)
local rg=Duel.GetMatchingGroup(s.ntfilter2,tp,LOCATION_GRAVE,0,c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsSetCard(SET_MORPHTRONIC) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) 
	and aux.SelectUnselectGroup(rg,e,tp,nil,nil,s.rescon2(c,sc),0)
end
function s.ntfilter2(c,e,tp)
	return c:HasLevel() and not c:IsType(TYPE_TUNER) and c:IsSetCard(SET_MORPHTRONIC) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) 
end
function s.rescon2(tuner,scard)
	return	function(sg,e,tp,mg)
		sg:AddCard(tuner)
		local res=sg:CheckWithSumEqual(Card.GetLevel,scard:GetLevel(),#sg,#sg)
		sg:RemoveCard(tuner)
		return res and aux.ChkfMMZ(1)(sg,e,tp,mg)
	end
end
function s.tgd(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.syfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) 
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
function s.opd(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,s.syfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local syc=g1:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.Remove(syc,POS_FACEUP,REASON_EFFECT)
	local g2=Duel.SelectMatchingCard(tp,s.tfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,syc)
	local tuner=g2:GetFirst()
	local rg=Duel.GetMatchingGroup(s.ntfilter2,tp,LOCATION_GRAVE,0,tuner,e,tp)
	local sg=aux.SelectUnselectGroup(rg,e,tp,nil,ft,s.rescon2(tuner,syc),1,tp,HINTMSG_SPSUMMON,s.rescon(tuner,syc))
	sg:AddCard(tuner)
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	for tc in aux.Next(sg) do
		--Negate effect(s)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
end