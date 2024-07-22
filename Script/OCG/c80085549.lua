--D/D/D Awakening King Genesis
local s,id=GetID()
function s.initial_effect(c)
    --Must be Special Summoned
    c:EnableReviveLimit()
	--Pendulum Attributes
    Pendulum.AddProcedure(c)
    --Special Summon procedure
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --Unaffected by opponent's monster effects
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetValue(s.efilter)
    c:RegisterEffect(e2)
    --Negate Extra Deck summon
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_SPSUMMON)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e3:SetCondition(s.discon)
    e3:SetTarget(s.distg)
    e3:SetOperation(s.disop)
    c:RegisterEffect(e3)
    --Destroy and apply effect
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_OATH)
    e4:SetTarget(s.destg)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)
    --Add Dark Contract
    local pel=Effect.CreateEffect(c)
    pel:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    pel:SetType(EFFECT_TYPE_IGNITION)
    pel:SetRange(LOCATION_PZONE)
    pel:SetCountLimit(1,id)
    pel:SetCost(s.thcost)
    pel:SetTarget(s.thtg)
    pel:SetOperation(s.thop)
    c:RegisterEffect(pel)
end
s.listed_series={SET_DD,SET_DARK_CONTRACT}
function s.spfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_DARK_CONTRACT) and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
    return #g>=3 and Duel.GetLocationCountFromEx(tp,tp,g,c)>0 and c:IsFaceup()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local sg=g:Select(tp,3,3,nil)
    if sg then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    else
        return false
    end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local sg=e:GetLabelObject()
    Duel.SendtoGrave(sg,REASON_COST)
    sg:DeleteGroup()
end
function s.efilter(e,te)
    return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    return tp~=ep and eg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_EXTRA)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateSummon(eg)
    Duel.Destroy(eg,REASON_EFFECT)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,SET_DD),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,SET_DD),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if Duel.Destroy(tc,REASON_EFFECT)~=0 then
        local op=Duel.SelectOption(1-tp,aux.Stringid(id,0),aux.Stringid(id,1))
        if op==0 then
            Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
        else
            Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
            local rg=Duel.SelectMatchingCard(1-tp,aux.FaceupFilter(Card.IsLevelAbove,tc:GetOriginalLevel()+1),1-tp,LOCATION_MZONE,0,1,1,nil)
            if #rg>0 then
                Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
            end
        end
    end
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end

function s.thfilter1(c)
	local table1000={44539080,45974017,46372010,73360025,9030160,9765723,37209439}
    return c:IsSetCard(SET_DARK_CONTRACT) and c:IsCode(table1000) and c:IsAbleToHand()
end

function s.thfilter2(c)
	local table2000={10833828,60168186}
    return c:IsSetCard(SET_DARK_CONTRACT) and c:IsCode(table2000) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,2,nil)
        or Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetMatchingGroup(s.thfilter1,tp,LOCATION_DECK,0,nil)
    local g2=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_DECK,0,nil)
    local op=0
    if #g1>=2 and #g2>0 then
        op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    elseif #g1>=2 then
        op=0
    elseif #g2>0 then
        op=1
    else
        return
    end
    if op==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g1:Select(tp,2,2,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g2:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    end
end