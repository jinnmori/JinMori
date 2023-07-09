--Master of The Dark Magical Circle
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,s.fusfilter,1,99,CARD_DARK_MAGICIAN,47222536)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--Activate "Dark Magical Circle" from your GY 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.actcon)
	e2:SetTarget(s.acttg)
	e2:SetOperation(s.actop)
	c:RegisterEffect(e2)
	--destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetLabelObject(e2)
	e3:SetValue(s.repval)
	e3:SetTarget(s.reptg)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
	--self destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ADD_COUNTER+COUNTER_SPELL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetLabelObject(e2) 
	e4:SetCondition(s.descon)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	--Effect gain
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCountLimit(1)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	--Gains 200 Atk for each
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,4))
	e6:SetCategory(CATEGORY_ATKCHANGE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_REMOVE)
	e6:SetLabelObject(c) 
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(s.atkcon)
	e6:SetTarget(s.atktg)
	e6:SetOperation(s.atkop)
	--Make "Dark Magical Circle" gains Additional effects 
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(LOCATION_SZONE,0)
	e7:SetTarget(s.eftg)
	e7:SetLabelObject(e5)
	c:RegisterEffect(e7)
	--Chack again for Dark Magical Circle 
	local e8=e7:Clone()
	e7:SetLabelObject(e6)
	c:RegisterEffect(e8)
	--Check for the Dark Magical Circle to used as a fusion material
	aux.GlobalCheck(s,function()
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD)
		ge2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		ge2:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
		ge2:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
		ge2:SetTarget(s.mttg)
		ge2:SetValue(s.mtval)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.material={CARD_DARK_MAGICIAN,47222536}
s.listed_names={CARD_DARK_MAGICIAN,47222536}
s.counter_place_list={COUNTER_SPELL}
function s.fusfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:GetAttack()>=2000
end
function s.mttg(e,c)
	return c:IsCode(47222536) and not c:IsMonster()
end
function s.mtval(e,c)
	if not c then return false end
	return c:IsOriginalCode(id)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	return (c:GetSummonType()&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function s.actfilter(c,tp)
	return c:IsCode(47222536) and c:GetActivateEffect():IsActivatable(tp,true)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.actfilter(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.actfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectTarget(tp,s.actfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local te=tc:GetActivateEffect()
			local tep=tc:GetControler()
			local tg=te:GetTarget()
			local op=te:GetOperation()
			if tg then tg(te,tep,eg,ep,ev,re,r,rp,1) end
			if op and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then op(e,tp,eg,ep,ev,re,r,rp) end
			Duel.RaiseEvent(tc,id,te,0,tp,tp,Duel.GetCurrentChain())
			e:SetLabelObject(tc)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
		--nothing here
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(id,2)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		--Make the effect that banish 1 card on the field 
			local effs={tc:GetCardEffect()}
			if not effs then return false end
			for _, eff in ipairs(effs) do
			if eff:GetType()==EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_ACTIONS then
			eff:SetCondition(aux.OR(s.rmcon,eff:GetCondition()))
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
		end
		end
	end
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsRace(RACE_SPELLCASTER)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and e:GetHandler():HasFlagEffect(id)
end
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_SPELLCASTER) and (c:IsReason(REASON_BATTLE) 
		or (c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)))
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject():GetLabelObject()
	tc:EnableCounterPermit(COUNTER_SPELL)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and tc and tc:GetFlagEffect(id)~=0 and tc:IsLocation(LOCATION_SZONE) and not tc:IsStatus(STATUS_DESTROY_CONFIRMED) end
	return tc:IsCanAddCounter(COUNTER_SPELL,1)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject():GetLabelObject()
	tc:EnableCounterPermit(COUNTER_SPELL)
	local ct=tc:GetCounter(COUNTER_SPELL)
	tc:AddCounter(COUNTER_SPELL,1)
	if tc:GetCounter(COUNTER_SPELL)>ct then
	Duel.RaiseEvent(tc,EVENT_ADD_COUNTER+COUNTER_SPELL,e,REASON_EFFECT,tp,tp,1)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	return tc:GetCounter(COUNTER_SPELL)>=2
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	Duel.Destroy(tc,REASON_EFFECT)
end
function s.eftg(e,c)
	return c and c:IsCode(47222536)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.atkfilter(c)
	return not c:IsType(TYPE_TOKEN)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.atkfilter,1,nil)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	local ct=eg:FilterCount(s.atkfilter,nil)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct*200)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,0,0,tp,ct*200)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local self=e:GetLabelObject()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local atk=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		Duel.HintSelection(self)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(atk)
		self:RegisterEffect(e1)
	end
end