--Sky Striker Ace - Hagane
local s,id=GetID()
function s.initial_effect(c)
	--fusion summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,12421694,s.ffilter)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.fuslimit,s.contactcon,nil,nil,false)
	--Cannot be Link Material the turn it's special summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.linklimit)
	c:RegisterEffect(e1)
	--Use the Original ATK/DEF for the opponent's monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	--disable that monster effect
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMING_BATTLE_PHASE)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetCondition(s.negcon)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	--Global check when registering Sky Striker Spell Card
	aux.GlobalCheck(s,function()
	local ge1=Effect.GlobalEffect()
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_CHAINING)
	ge1:SetOperation(s.checkop)
	Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={SET_SKY_STRIKER,SET_SKY_STRIKER_ACE}
s.listed_names={12421694}
function s.cfilter(c,tp,re)
	if tp==1-tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	local rc=re:GetHandler()
	return rc:IsSpell() and rc:IsSetCard(SET_SKY_STRIKER)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tp=re:GetHandlerPlayer()
	local g=eg:Filter(s.cfilter,nil,tp,re)
	for tc in g:Iter() do
		Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttributeExcept(ATTRIBUTE_EARTH,fc,sumtype,tp) and c:IsSetCard(SET_SKY_STRIKER_ACE) and c:IsMonster()
end
function s.contactfil(tp)
	local loc=LOCATION_ONFIELD|LOCATION_GRAVE
	if Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then loc=LOCATION_ONFIELD end
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,loc,0,nil)
end
function s.contactcon(tp)
	return Duel.HasFlagEffect(tp,id)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
end
function s.fuslimit(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION or e:GetHandler():GetLocation()~=LOCATION_EXTRA 
end
function s.lkcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.linklimit(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
function s.damcon(e)
	local c=e:GetHandler()		
	return c:GetBattleTarget()~=nil
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsFaceup() then
		local ba=bc:GetTextAttack()
		local bd=bc:GetTextDefense()
		if bc:IsImmuneToEffect(e) then
			ba=bc:GetBaseAttack()
			bd=bc:GetBaseDefense() end
		if ba<0 then ba=0 end
		if bd<0 then bd=0 end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		e1:SetValue(ba)
		bc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		e2:SetValue(bd)
		bc:RegisterEffect(e2,true)
	end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetAttackTarget()~=nil then
		return (Duel.GetAttacker():IsControler(tp) and Duel.GetAttacker():IsSetCard(SET_SKY_STRIKER))
		or (Duel.GetAttackTarget() and Duel.GetAttackTarget():IsControler(tp) and Duel.GetAttackTarget():IsSetCard(SET_SKY_STRIKER))
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=Duel.GetAttacker()
	if bc:IsControler(tp) then bc=Duel.GetAttackTarget() end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
	bc:RegisterEffect(e1,true)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
	bc:RegisterEffect(e2,true)
	--banish it when it's destroyed by battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
	e3:SetCondition(s.recon)
	e3:SetValue(LOCATION_REMOVED)
	bc:RegisterEffect(e3,true)
end
function s.recon(e)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
end