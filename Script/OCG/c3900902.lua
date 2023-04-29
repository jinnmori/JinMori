--Predaplant Cactusdraco
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_PREDAPLANT),2,2)
	c:EnableReviveLimit()
	-- Allow cards that your opponent controls as fusion materials
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTarget(s.distg)
	c:RegisterEffect(e2)
	--Halve their Atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_SET_ATTACK_FINAL)
	e3:SetTarget(s.distg)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--Place 1 Predator Counter on them
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCondition(s.prcon)
	e4:SetTarget(s.prtg)
	e4:SetOperation(s.prop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_PREDAPLANT,SET_FUSION_DRAGON}
s.counter_place_list={COUNTER_PREDATOR}

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHAIN_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.chain_target)
	e1:SetOperation(s.chain_operation)
	e1:SetValue(s.chain_value)
	Duel.RegisterEffect(e1,tp)
end
function s.filter(c,e)
	return c:IsMonster() and c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function s.chain_value(c)
	return c:IsSetCard(SET_PREDAPLANT) or c:IsSetCard(SET_FUSION_DRAGON) 
end
function s.chain_target(e,te,tp,value)
	if not value or value&SUMMON_TYPE_FUSION==0 then return Group.CreateGroup() end
	if Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,nil,te)
	else
		return Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE+LOCATION_HAND,LOCATION_MZONE,nil,te)
	end
end
function s.chain_operation(e,te,tp,tc,mat,sumtype,sg,sumpos)
	if not sumtype then sumtype=SUMMON_TYPE_FUSION end
	tc:SetMaterial(mat)
	Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	if mat:IsExists(Card.IsControler,1,nil,1-tp) then
	end
	Duel.BreakEffect()
	if sg then
		sg:AddCard(tc)
	else
		Duel.SpecialSummon(tc,sumtype,tp,tp,false,false,sumpos)
	end
end
function s.distg(e,c)
	return c:GetLevel()==1
end
function s.atkval(e,c)
	return math.ceil(c:GetAttack()/2)
end
function s.prcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.prtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,COUNTER_PREDATOR,1) end
end
function s.prop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,nil,COUNTER_PREDATOR,1)
		local tc=g:GetFirst()
	for tc in aux.Next(g) do
		tc:AddCounter(COUNTER_PREDATOR,1)
		if tc:GetLevel()>1 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(s.lvcon)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
		end
	end
end
function s.lvcon(e)
	return e:GetHandler():GetCounter(COUNTER_PREDATOR)>0
end