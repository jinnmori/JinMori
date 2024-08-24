--Dark Armed Dragon LV3
local s,id=GetID()
function s.initial_effect(c)
    --Special Summon itself
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --Add "Armed Dragon" card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    --Return from banished and draw
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCost(s.rtdcost)
    e3:SetTarget(s.rtdtg)
    e3:SetOperation(s.rtdop)
    c:RegisterEffect(e3)
	--Register the fact it was sent to GY
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.regcon)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
    --Special Summon during End Phase
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,{id,3})
	e5:SetCondition(s.spcon2)
	e5:SetTarget(s.sptg2)
	e5:SetOperation(s.spop2)
	c:RegisterEffect(e5)
end
s.listed_series={SET_ARMED_DRAGON}
s.LVnum=3
function s.spfilter(c)
    return c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE))
end
function s.armedfilter(c)
    return c:IsSetCard(SET_ARMED_DRAGON) and c:IsMonster() and c:IsAbleToRemoveAsCost()
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,c)
    return g:IsExists(s.armedfilter,1,nil) and g:GetClassCount(Card.GetCode)>=3
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,c)
    local rg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_REMOVE,nil,nil,true)
    if #rg>0 then
        rg:KeepAlive()
        e:SetLabelObject(rg)
        return true
    end
    return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local rg=e:GetLabelObject()
    if not rg then return end
    Duel.Remove(rg,POS_FACEUP,REASON_COST)
    rg:DeleteGroup()
end
function s.thfilter(c)
    return c:IsSetCard(SET_ARMED_DRAGON) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function s.rtdcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.rtdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) and Duel.IsPlayerCanDraw(tp,1) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.rtdop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
        Duel.ShuffleDeck(tc:GetOwner())
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
 if not (e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsMonsterEffect()) then return false end
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and rc:IsFaceup() then
		return rc:IsRace(RACE_DRAGON)
	else
		return Duel.GetChainInfo(0,CHAININFO_TRIGGERING_RACE)&RACE_DRAGON>0
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.spfilter2(c,e,tp)
    return c:IsSetCard(SET_ARMED_DRAGON) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
    end
end