--Sky Striker Ace - Shaku
local s,id=GetID()
function s.initial_effect(c)
	--fusion summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,63288573,s.ffilter)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.fuslimit,s.contactcon,nil,nil,false)
	--Cannot be Link Material the turn it's special summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.linklimit)
	c:RegisterEffect(e1)
	--Decrease opponent's monster's ATK/DEF by 1500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(-1500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--Attack all Special Summoned monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_ATTACK_ALL)
	e4:SetValue(s.atkfilter)
	c:RegisterEffect(e4)
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
s.listed_names={63288573}
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
	return c:IsAttributeExcept(ATTRIBUTE_FIRE,fc,sumtype,tp) and c:IsSetCard(SET_SKY_STRIKER_ACE) and c:IsMonster()
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
function s.atkfilter(e,c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
