--Magician Girl of Dark Burning
local s,id=GetID()
function s.initial_effect(c)
	--Set 1 "Eternal Soul"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Banish 1 Random Card in your opponent hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(s.remcon)
	e3:SetTarget(s.remtg)
	e3:SetOperation(s.remop)
	c:RegisterEffect(e3)
end
s.listed_names={id,48680970,CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL}

function s.setfilter(c)
	return c:IsCode(48680970) and c:IsSSetable()
end
function s.darkgirlchk(tp,self)
	return Duel.IsExistingMatchingCard(s.contfilter,tp,LOCATION_ONFIELD,0,1,self)
end
function s.contfilter(c)
	return c:IsCode(CARD_DARK_MAGICIAN) or (c:IsRace(RACE_SPELLCASTER) and c:IsLevel(6) and c:IsMonster())
end
function s.thfilter(c)
	return c:IsCode(CARD_DARK_MAGICIAN) or ((c:ListsCode(CARD_DARK_MAGICIAN) or c:ListsCode(CARD_DARK_MAGICIAN_GIRL)) and c:IsMonster()) and c:IsAbleToHand()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)) or (s.darkgirlchk(tp,c) 
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil))
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local darkcircle=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	local th=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if (#th>0 and s.darkgirlchk(tp,c)) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and (s.darkgirlchk(tp,c)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=th:Select(tp,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif #darkcircle>0 then
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g2=darkcircle:Select(tp,1,1,nil):GetFirst()
	if g2 and g2:IsSSetable() then
		Duel.SSet(tp,g2)
		--Can be activated this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		g2:RegisterEffect(e1)
		end
	end
end
function s.remcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil,tp,POS_FACEDOWN) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
function s.remop(e,tp,eg,ep,ev,re,r,rp)
local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	local rs=g:RandomSelect(1-tp,1)
	local card=rs:GetFirst()
	if card==nil then return end
	if Duel.Remove(card,POS_FACEDOWN,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetRange(LOCATION_REMOVED)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,3)
		e1:SetCondition(s.thcon)
		e1:SetOperation(s.thop)
		e1:SetLabel(0)
		card:RegisterEffect(e1)
		card:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		local descnum=tp==c:GetOwner() and 0 or 1
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetDescription(aux.Stringid(id,descnum))
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e3:SetCode(1082946)
		e3:SetLabelObject(e1)
		e3:SetOwnerPlayer(tp)
		e3:SetOperation(s.reset)
		e3:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		c:RegisterEffect(e3)
	end
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabelObject() then e:Reset() return end
	s.thop(e:GetLabelObject(),tp,eg,ep,ev,e,r,rp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and e:GetHandler():GetFlagEffect(id)==0
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()+1
	e:GetOwner():SetTurnCounter(ct)
	e:SetLabel(ct)
	if ct==2 then
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		if re then 
			re:Reset()
		end
	end
end
