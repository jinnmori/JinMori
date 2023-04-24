--Berserk Zombie Dragon 
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterSummonCode(33420078),1,1,s.nonfilter,1,99)
	c:EnableReviveLimit()
	--Move 1 Monster to it's adjacent occupied zone 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.seqcost)
	e1:SetTarget(s.seqtg)
	e1:SetOperation(s.seqop)
	c:RegisterEffect(e1)
	-- Multiple attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end
s.listed_names={33420078}
s.material={33420078}
--the condition where it used by any material except Zombie 
function s.nonfilter(c,scard,sumtype,tp)
	return c:IsRace(RACE_ZOMBIE,scard,sumtype,tp) or (Duel.GetMatchingGroupCount(nil,tp,LOCATION_EMZONE,0,nil)==0) 
end
function s.seqcost(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end
function s.seqfilter(c)
	local tp=c:GetControler()
	return c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>0
end
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_EMZONE) and s.seqfilter(chkc) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.seqfilter,tp,LOCATION_EMZONE,LOCATION_EMZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local tc=Duel.SelectTarget(tp,s.seqfilter,tp,LOCATION_EMZONE,LOCATION_EMZONE,1,1,nil)
end
function s.seqop(e,tp,eg,ep,ev,re,r,rp)
local tc=Duel.GetFirstTarget()
	local ttp=tc:GetControler()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or Duel.GetLocationCount(ttp,LOCATION_MZONE,ttp,LOCATION_REASON_CONTROL)<=0 then return end
	local p1,p2,i
	if tc:IsControler(tp) then
		i=0
		p1=LOCATION_MZONE
		p2=0
	else
		i=16
		p2=LOCATION_MZONE
		p1=0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,p1,p2,0),2)-i)
end
function s.atkval(e)
	local tp=e:GetHandlerPlayer()
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,RACE_ZOMBIE),tp,LOCATION_MZONE,0,nil)
	return ct-1
end