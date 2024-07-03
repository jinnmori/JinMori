--Firewall Dragon Pyrosoul
local s,id=GetID()
function s.initial_effect(c)
    --Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,2,nil,s.matcheck)
    c:SetUniqueOnField(1,0,id)
    --Gains 500 ATK for each monster special summoned from the GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)
    --Destroy all opponent's monsters
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
    --Special Summon when another Cyberse is destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.matfilter(c,lc,sumtype,tp)
    return c:IsRace(RACE_CYBERSE,lc,sumtype,tp)
end
function s.matcheck(g,lc,sumtype,tp)
    return g:GetClassCount(Card.GetAttribute)==#g
end
function s.atkval(e,c)
    local g=Duel.GetMatchingGroup(function(c)
        return c:IsRace(RACE_CYBERSE) and c:IsSummonLocation(LOCATION_GRAVE)
    end,0,LOCATION_MZONE,LOCATION_MZONE,nil)
    return #g*500
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return eg:IsExists(function(tc)
        return c:GetMutualLinkedGroup():IsContains(tc) and c:IsLinkMonster() and c:IsSummonType(SUMMON_TYPE_LINK)
    end,1,nil)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) end
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
    Duel.Destroy(g,REASON_EFFECT)
end
function s.spcfilter(c,tp)
    return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsRace(RACE_CYBERSE) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
        and c:GetReasonPlayer()==1-tp
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.spcfilter,1,nil,tp)
end
function s.spfilter(c,e,tp,eg)
    return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and not eg:IsExists(Card.IsCode,1,nil,c:GetCode())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,eg) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,eg)
    if #g>0 then
        local tc=g:GetFirst()
        if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
            e1:SetValue(LOCATION_DECK)
            tc:RegisterEffect(e1,true)
        end
    end
end