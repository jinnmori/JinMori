--Sky Striker Ace - Chikara
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SKY_STRIKER),4,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
	--Excavate the top card of your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--A Sky Striker Ace Monster Link Summoned using this card cannot be destroyed by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return r&REASON_LINK>0 and e:GetHandler():GetReasonCard():IsSetCard(SET_SKY_STRIKER_ACE) end)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
	end
s.listed_series={SET_SKY_STRIKER,SET_SKY_STRIKER_ACE}
s.listed_names={id}
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsType(TYPE_LINK,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsSetCard(SET_SKY_STRIKER_ACE,xyzc,SUMMON_TYPE_XYZ,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return false end
		local g=Duel.GetDecktopGroup(tp,3)
		local result=g:FilterCount(Card.IsAbleToHand,nil)>0
		return result and Duel.IsPlayerCanDiscardDeck(tp,3)
	end
end
function s.sumfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(SET_SKY_STRIKER)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanDiscardDeck(tp,3) then return end
	Duel.ConfirmDecktop(tp,3)
	local g=Duel.GetDecktopGroup(tp,3)
	if #g>0 then
		Duel.DisableShuffleCheck()
		if g:IsExists(s.sumfilter,1,nil) then
		if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:FilterSelect(tp,s.sumfilter,1,1,nil)
			if sg:GetFirst():IsAbleToHand() then
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,sg)
				Duel.ShuffleHand(tp)
				g:Sub(sg)
				Duel.SendtoGrave(g,REASON_EFFECT|REASON_EXCAVATE)
			else
				Duel.SendtoGrave(g,REASON_EFFECT|REASON_EXCAVATE)
			end
		else
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_EXCAVATE)
			Duel.ShuffleDeck(tp)
			end
		end
	end
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--Cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3000)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1)
end