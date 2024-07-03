--Gagagatopia
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,nil,4,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
	--Check if Summoned this Way
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	--This cards gains 500 ATK + Gains the Effect of the "Utopia" Xyz Monster + Draw 1 Card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.gagagatopiacon)
	e1:SetOperation(s.gagagatopiaop)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(aux.dxmcostgen(1,1,nil))
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	--LP Gain
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(s.effcon)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_GAGAGA,SET_UTOPIA}
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_UTOPIA) and c:GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,SET_GAGAGA)
	and c:IsCanBeXyzMaterial(xyzc,tp)
end
function s.xyzop(e,tp,chk,mc)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD,0,1)
	return true
end
function s.matfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(SET_UTOPIA) and c:GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,SET_GAGAGA)
end
function s.valcheck(e,c)
local g=c:GetMaterial()
local mat=g:Filter(s.matfilter,nil)
	local code=0
	code=mat:GetFirst():GetCode()
	e:SetLabel(code)
end
function s.gagagatopiacon(e,tp,eg,ep,ev,re,r,rp)
 local c=e:GetHandler()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and c:GetFlagEffect(id)~=0
end
function s.gagagatopiaop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_TOFIELD)
		c:RegisterEffect(e1)
		--Treated as "Utopia"
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_SETCODE)
		e2:SetValue(SET_UTOPIA)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_TOFIELD)
		c:RegisterEffect(e2)
		--Copy effects
		local code=e:GetLabelObject():GetLabel()
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_TOFIELD,1)
		--Draw 1 card
		Duel.Draw(tp,1,REASON_EFFECT)
	end
function s.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local tc=g:GetFirst()
		if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			local op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(op==0 and 1 or -1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local c= e:GetHandler()
    return (r&REASON_XYZ)==REASON_XYZ and c:GetReasonCard():IsAttribute(ATTRIBUTE_LIGHT) and c:GetReasonCard():IsRace(RACE_WARRIOR) and c:IsLocation(LOCATION_OVERLAY)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(id,5))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.reccon)
	e1:SetOperation(s.recop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
    Duel.Recover(tp,ct*800,REASON_EFFECT)
end