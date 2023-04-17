--Neo Cyber End Dragon
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,false,false,CARD_CYBER_DRAGON,3)
	--Inflict pierce Damage To Your Opponent 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	--this card gains attacks up tho the banished monsters you banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.multicost)
	e2:SetTarget(s.multitg)
	e2:SetOperation(s.multiop)
	c:RegisterEffect(e2)
	--Add 1 "Cyber" Spell/Trap Card from deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.addtg)
	e3:SetOperation(s.addop)
	c:RegisterEffect(e3)
end
s.material_setcode={SET_CYBER_DRAGON}

function s.discfilter(c)
	return c:IsCode(CARD_CYBER_DRAGON) and c:IsAbleToRemoveAsCost()
end
function s.multicost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.discfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.discfilter,tp,LOCATION_GRAVE,0,1,2,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
	e:SetLabel(ct)
end
function s.multitg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.multiop(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local ct=e:GetLabel()
		--Gains Additional Attacks up to the removed monsters
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
end
function s.addfilter(c)
	return c:IsSetCard(SET_CYBER) and c:IsSpellTrap()
end 	
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
	Duel.SendtoHand(g,tp,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
	end
end