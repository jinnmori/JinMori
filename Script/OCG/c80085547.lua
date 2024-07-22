--Neo Galaxy-Eyes Tachyon Dragon
local s,id=GetID()
function s.initial_effect(c)
    --Xyz Summon
	Xyz.AddProcedure(c,nil,8,3,s.ovfilter,aux.Stringid(id,0),2)
    c:EnableReviveLimit()
    --ATK gain and protection
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetCondition(s.atkcon)
    e1:SetValue(1000)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetCondition(s.atkcon)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    --Negate Special Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_SPSUMMON)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.discon)
    e3:SetCost(aux.dxmcostgen(1,1,nil))
    e3:SetTarget(s.distg)
    e3:SetOperation(s.disop)
    c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
    --Second attack
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.atktg)
    e4:SetOperation(s.atkop)
    c:RegisterEffect(e4)
end
s.listed_series={SET_GALAXY_EYES}
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:GetOverlayCount()==0 and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsRace(RACE_DRAGON,xyzc,SUMMON_TYPE_XYZ,tp)
end
function s.atkcon(e)
    return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,SET_GALAXY_EYES)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    return tp~=ep and Duel.GetCurrentChain()==0
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
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,-1000)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3201)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
	c:RegisterEffect(e1)
	end
end
