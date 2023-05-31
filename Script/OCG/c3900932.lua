--Amatersu Hand
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Target 5 monsters in your GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.cfilter(c)
	return ((c:IsFaceup() and c:IsLocation(LOCATION_MZONE)) or c:IsLocation(LOCATION_HAND)) and c:GetLevel() % 2 == 0 and c:IsAbleToGraveAsCost() and c:IsMonster()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
		g:KeepAlive()
		e:SetLabelObject(g:GetFirst())
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local draw=tc:GetLevel()/2
	Duel.Draw(tp,draw,REASON_EFFECT)
	if tc:IsAttribute(ATTRIBUTE_DIVINE) and Duel.IsPlayerCanDraw(tp,1) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function s.filter(c,e)
    return c:IsMonster() and c:IsCanBeEffectTarget(e)
		and (c:IsAbleToDeck() or c:IsAbleToHand())
end
function s.rescon(sg,e,tp,mg)
    return sg:IsExists(Card.IsAbleToHand,2,nil) and sg:IsExists(Card.IsAbleToDeck,3,nil)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
local rg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e)
 if chk==0 then return aux.SelectUnselectGroup(rg,e,tp,5,5,s.rescon,0) end
	 local g=aux.SelectUnselectGroup(rg,e,tp,5,5,s.rescon,1,tp,HINTMSG_TARGET)
	 Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,tp,0)
end
function s.selectcond(resg)
	return function (sg,e,tp,mg)
		return sg:IsExists(Card.IsAbleToHand,2,nil) and sg:IsExists(Card.IsAbleToDeck,3,nil)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g<5 then return end
	local tdg=aux.SelectUnselectGroup(g,e,tp,3,3,s.selectcond(g),1,tp,HINTMSG_TODECK)
	g:RemoveCard(tdg)
	if Duel.SendtoDeck(tdg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
	Duel.BreakEffect()
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
	end
end