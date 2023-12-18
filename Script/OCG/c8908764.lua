--Meklord Emperor Natas
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--special summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(0)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Equip
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
	aux.AddEREquipLimit(c,nil,s.eqval,s.equiop,e3)
	--Destruction replacement for "Meklord" monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.reptg)
	e4:SetValue(s.repval)
	e4:SetOperation(s.repop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_MEKLORD}
function s.eqval(ec,c,tp)
	return ec:IsControler(1-tp) and ec:IsType(TYPE_SYNCHRO)
end
function s.filter(c,tp)
	return c:IsMonster() and (c:GetReason()&0x41)==0x41 and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
function s.eqfilter(c,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsMonster() and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.eqfilter,tp,0,LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_GRAVE,nil,tp)
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,0,LOCATION_EXTRA+LOCATION_MZONE+LOCATION_GRAVE,1,nil,tp)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
		Duel.ConfirmCards(tp,Duel.GetFieldGroup(tp,0,LOCATION_EXTRA+LOCATION_MZONE+LOCATION_GRAVE))
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local sg=g:Select(tp,1,1,nil):GetFirst()
		Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,sg,1,0,LOCATION_EXTRA+LOCATION_MZONE+LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	local tc=tg:GetFirst()
	if c:IsRelateToEffect(e) then
		s.equiop(c,e,tp,tc)
	end
end
function s.equiop(c,e,tp,sg)
	local atk=sg:GetTextAttack()
	if atk<0 then atk=0 end
	if not c:EquipByEffectAndLimitRegister(e,tp,sg,nil,true) then return end
	if atk>0 then
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(c)
	sg:RegisterEffect(e1)
	sg:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	Duel.ShuffleExtra(1-tp)
	--gives 500 ATK 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	e2:SetValue(500)
	sg:RegisterEffect(e2)
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard(SET_MEKLORD)
		and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.desfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsDestructable(e)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED|STATUS_BATTLE_DESTROYED)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,e) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local tc=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e):GetFirst()
		Duel.HintSelection(tc,true)
		e:SetLabelObject(tc)
		tc:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT|REASON_REPLACE)
end