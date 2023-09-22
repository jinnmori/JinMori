--Infernoid Admiurge
local s,id=GetID()
function s.initial_effect(c)
	--Set 1 "Void" Spell/Trap from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.setg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Activate 1 of these effects
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE) end)
	e3:SetTarget(s.actg)
	e3:SetOperation(s.actop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_INFERNOID,SET_VOID}
s.listed_names={id}
function s.rmfilter(c)
	return c:IsSetCard(SET_INFERNOID) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.setfilter(c)
	return c:IsSpellTrap() and c:IsSetCard(SET_VOID) and c:IsSSetable()
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.setg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	Duel.SSet(tp,tc)
end
function s.contfilter(c)
	return c:IsControlerCanBeChanged() and c:IsType(TYPE_EFFECT) and c:IsMonster()
end
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	--Take control of 1 Effect Monster your opponent controls
	local b1=Duel.IsExistingMatchingCard(s.contfilter,tp,0,LOCATION_MZONE,1,nil)
	--Add 1 of your banished "Infernoid" monsters to your hand
	local b2=Duel.IsExistingMatchingCard(s.tohafilter,tp,LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_CONTROL)
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,tp,LOCATION_MZONE)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
	end
end
function s.tohafilter(c)
	return c:IsSetCard(SET_INFERNOID) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==1 then
	--Take control of 1 Effect Monster your opponent controls
	local tc=Duel.SelectMatchingCard(tp,s.contfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
		Duel.GetControl(tc,tp)
		--also its treated as an "Infernoid"
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_SETCODE)
		e1:SetValue(SET_INFERNOID)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		--its level/Rank becomes 1
		local e2=e1:Clone()
	    e2:SetCode(EFFECT_CHANGE_LEVEL)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
	    e3:SetCode(EFFECT_CHANGE_RANK)
		e3:SetValue(1)
		tc:RegisterEffect(e3)
	elseif op==2 then
	--Add 1 of your banished "Infernoid" monsters to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.tohafilter,tp,LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
