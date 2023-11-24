--Noble Resonator
local s,id=GetID()
function s.initial_effect(c)
	--synchro limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.synlimit)
	c:RegisterEffect(e1)
	--Opponent Cannot Activate effects when you normal or special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetTarget(s.noactivtg)
	e2:SetOperation(s.noactivop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Special Summon this card from GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
function s.synlimit(e,c)
	if not c then return false end
	return not (c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(6) and c:IsMonster())
end
function s.noactivtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetChainLimit(s.chainlm)
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
function s.noactivop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
-- Opponent cannot activate cards or effects on Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.sucop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.sucop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(Card.IsSummonPlayer,1,nil,tp) then
		Duel.SetChainLimitTillChainEnd(function(_,rp,tp) return rp==tp end)
	end
end
function s.spfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(6)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:GetLevel()<2 then return end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-1)
	tc:RegisterEffect(e1)
	if c:IsRelateToEffect(e) then
	Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
	--Cannot be used as material for a Fusion,Xyz,or Link Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	--Cannot be Tributed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e3)
	Duel.SpecialSummonComplete()
	end
end
