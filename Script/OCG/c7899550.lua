--Obelisk's Disciple
local s,id=GetID()
function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	--Decrease 1 tribute for the added monster name 
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCountLimit(1)
	e1:SetLabelObject(g:GetFirst())
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	e1:SetCondition(s.ntcon)
	e1:SetTarget(s.nttg2)
	e1:SetOperation(s.sumop)
	Duel.RegisterEffect(e1,tp)
	end
end
function s.ntcon(e,c)
	if c==nil then return true end
	local _,max=c:GetTributeRequirement()
	return max>0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	local tc=e:GetLabelObject()
	return c:IsLevelAbove(5) and c:IsCode(tc:GetCode())
end
function s.nttg2(e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
	local tc=e:GetLabelObject()
	local mg=Duel.GetTributeGroup(tc)
	mg=mg:Filter(aux.IsZone,nil,relzone,tp)
	local tributes=maplevel(tc:GetLevel())
	local g=Duel.SelectTribute(tp,tc,1,1,mg,tp,zone,Duel.GetCurrentChain()==0)
	if g and #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
