--Predaplant Hydrafflesia
local s,id=GetID()
function s.initial_effect(c)
	--Send 1 "Fusion" spell/trap to the grave
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
		--draw 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,id+1)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_FUSION}
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(Card.IsAttribute,tp,LOCATION_MZONE,0,nil,ATTRIBUTE_DARK)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,ct+1) end
end
function s.sumfilter(c)
	return c:IsAbleToGrave() and c:IsSpellTrap() and c:IsSetCard(SET_FUSION)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local ct=math.min(Duel.GetMatchingGroupCount(Card.IsAttribute,tp,LOCATION_MZONE,0,nil,ATTRIBUTE_DARK))+1
	local break_chk=false
	--Excavate cards from your Deck, send 1 spell/Trap to GY and Shuffle the others back to the Deck
	if ct>0 then
		break_chk=true
		local ac=Duel.AnnounceNumberRange(tp,1,ct)
		Duel.ConfirmDecktop(tp,ac)
		local g=Duel.GetDecktopGroup(tp,ac)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=g:FilterSelect(tp,s.sumfilter,1,1,nil)
		if #sg>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT)
			g:RemoveCard(sg:GetFirst())
		if #g>0 then
			Duel.SendtoDeck(g,nil,2,REASON_EFFECT|REASON_REVEAL)
			--Check to Activate the Card sent by this effect
			local tc=sg:GetFirst()
			local ae=tc:GetActivateEffect()
		if tc:GetLocation()==LOCATION_GRAVE and ae then
			local e1=Effect.CreateEffect(tc)
			e1:SetDescription(ae:GetDescription())
			e1:SetType(EFFECT_TYPE_IGNITION)
			e1:SetCountLimit(1)
			e1:SetRange(LOCATION_GRAVE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL-RESET_TOFIELD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
			e1:SetCondition(s.spellcon)
			e1:SetTarget(s.spelltg)
			e1:SetOperation(s.spellop)
			tc:RegisterEffect(e1)
				end
			end
		end
	end
end
function s.spellcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.spelltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ae=e:GetHandler():GetActivateEffect()
	local ftg=ae:GetTarget()
	if chk==0 then
		return not ftg or ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
	if ae:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	else e:SetProperty(0) end
	if ftg then
		ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
function s.spellop(e,tp,eg,ep,ev,re,r,rp)
	local ae=e:GetHandler():GetActivateEffect()
	local fop=ae:GetOperation()
	fop(e,tp,eg,ep,ev,re,r,rp)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_FUSION 
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
