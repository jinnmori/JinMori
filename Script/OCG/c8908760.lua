--Malefic Reality Dragon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Special Summon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--to grave
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.descon)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
	--cannot remove
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetCode(EFFECT_CANNOT_REMOVE)
	e7:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e7)
	--self effect
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCode(EFFECT_CANNOT_ATTACK)
	e9:SetCondition(s.selfcon)
	c:RegisterEffect(e9)
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_SINGLE)
	e10:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e10:SetCode(EFFECT_DISABLE)
	e10:SetRange(LOCATION_MZONE)
	e10:SetCondition(s.selfcon)
	c:RegisterEffect(e10)
	local e11=e10:Clone()
	e11:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e11)
	end
s.listed_names={27564031}
s.listed_series={SET_MALEFIC}
function s.tgfilter(c)
	return c:IsSetCard(SET_MALEFIC) and c:IsAbleToGraveAsCost()
	end
function s.envfilter(c)
	return c:IsFaceup() and c:IsCode(27564031)
	end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsLocation,2,nil,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE)
		or (sg:IsExists(aux.SpElimFilter,1,nil,true))
end
function s.spfilter(c,ft)
	return c:IsSetCard(SET_MALEFIC) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
		and (c:IsLocation(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE) or (aux.SpElimFilter(c,true) and (ft>0 or (aux.MZFilter(c,c:GetControler()) and ft>-1))))
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,e:GetHandler(),ft)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and #rg>0
		and aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,e:GetHandler(),Duel.GetLocationCount(tp,LOCATION_MZONE))
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	g:DeleteGroup()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return g1:GetClassCount(Card.GetCode)>=2 and #g2>0 end
	local sg=aux.SelectUnselectGroup(g1,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	Duel.SendtoGrave(sg,REASON_COST+REASON_EFFECT)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)		
	return Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil) and e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end                   
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
    Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,#g,1-tp,LOCATION_MZONE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.retfilter(c)
	return c:IsSetCard(SET_MALEFIC) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.Destroy(g,REASON_EFFECT)
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.retfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		if #sg>0 and Duel.IsEnvironment(27564031) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=sg:Select(tp,1,1,nil)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g) 
	end
end
function s.selfcon(e)
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
        