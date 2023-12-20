--Black Luster Soldier - Chaos Swordsman
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,s.matfilter,1,1,nil,1,99,s.exmatfilter)
	--Synchro Level
	local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(id)
    e1:SetRange(LOCATION_EXTRA)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_SYNCHRO_LEVEL)
    e2:SetValue(function(e,c)
        local lv=e:GetHandler():GetLevel()
        return c:IsHasEffect(id) and ((1<<16)|lv) or lv
    end)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetRange(LOCATION_EXTRA)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.syntg)
    e3:SetLabelObject(e2)
    c:RegisterEffect(e3)
	--Unaffected by opponent card effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(s.unval)
	c:RegisterEffect(e4)
	--Banish this card and 1 random card from opponent's hand
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e5:SetCondition(function() return Duel.IsMainPhase() end)
	e5:SetTarget(s.rmtg)
	e5:SetOperation(s.rmop)
	c:RegisterEffect(e5)
	c:RegisterFlagEffect(id,0,EFFECT_FLAG_UNCOPYABLE,0)
	--spsummon (grave)
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetCondition(aux.exccon)
	e6:SetCost(aux.bfgcost)
	e6:SetTarget(s.sptg)
	e6:SetOperation(s.spop)
	c:RegisterEffect(e6)
	--Register if a card is removed
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_REMOVE)
		ge1:SetOperation(function() Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1) end)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={SET_BLACK_LUSTER_SOLDIER,SET_CHAOS}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK,scard,sumtype,tp)
end
function s.exmatfilter(c,scard,sumtype,tp)
	local attr=c:IsMonster(scard,sumtype,tp)
	if attr then Duel.RegisterFlagEffect(tp,id+10,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1) end
	return attr
end
function s.syntg(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsMonster() and Duel.GetFlagEffect(tp,id+10)~=0
end
function s.unval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove()
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(1-tp,LOCATION_MZONE,LOCATION_MZONE)
	if #g==0 or not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
	local hg=g:Select(1-tp,1,1,nil)
	if #hg~=1 then return end
	if Duel.Remove(hg,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)==0 then return end
	local retg=c:HasFlagEffect(id) and hg
	retg:Match(Card.IsLocation,nil,LOCATION_REMOVED)
	aux.DelayedOperation(retg,PHASE_STANDBY,id+1,e,tp,s.retop,s.retcon,RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN)
	--Cannot attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3206)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function s.retop(rg,e,tp,eg,ep,ev,re,r,rp)
	for tc in rg:Iter() do
			Duel.ReturnToField(tc)
	end
end
function s.retcon(rg,e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end
function s.spfilter(c,e,tp)
	if not ((c:IsSetCard(SET_CHAOS) and c:IsType(TYPE_SYNCHRO|TYPE_RITUAL)) or (c:IsSetCard(SET_BLACK_LUSTER_SOLDIER))
		and c:IsCanBeSpecialSummoned(e,0,tp,true,true)) then return false end
	if c:IsLocation(LOCATION_GRAVE) then
		return mmz_chk
	else
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil,e,tp,mmz_chk) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil,e,tp,mmz_chk)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
	end
end