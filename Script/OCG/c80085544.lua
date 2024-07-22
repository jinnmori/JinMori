--Number C101: Full Armor Silent Honor DARK
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),6,4,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	c:EnableReviveLimit()
     --Protection
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetCondition(s.protcon)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(aux.indoval)
    c:RegisterEffect(e2)
    --Equip
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_EQUIP)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
	e3:SetCost(aux.dxmcostgen(1,1,nil))
    e3:SetTarget(s.eqtg)
    e3:SetOperation(s.eqop)
    c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
    --End Phase effect
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.destg)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)
end
s.xyz_number=101
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER,lc,SUMMON_TYPE_XYZ,tp) and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp) 
	and c:IsRank(5)
end
function s.xyzop(e,tp,chk,mc)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_EXTRA,0,c):SelectUnselect(Group.CreateGroup(),tp,false,Xyz.ProcCancellable)
	if tc then
		Duel.SendtoGrave(tc,REASON_COST)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
		return true
	else return false end
end
function s.protfilter(c,tp,lc)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ)
end
function s.protcon(e)
    return Duel.IsExistingMatchingCard(s.protfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
function s.eqfilter(c,tp)
	return c:IsFaceup() and (c:IsAbleToChangeControler() or c:IsControler(tp))
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=e:GetHandler() end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),tp)
        and e:GetHandler():GetOverlayCount()>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler(),tp)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
        return
    end
    if not Duel.Equip(tp,tc,c,true) then return end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EQUIP_LIMIT)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(s.eqlimit)
    e1:SetLabelObject(c)
    tc:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(1200)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e2)
end
function s.eqlimit(e,c)
    return c==e:GetLabelObject()
end
function s.filter(c,ec)
	return c:GetEquipTarget()==ec
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e:GetHandler()) end
    local g=e:GetHandler():GetEquipGroup()
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local g=c:GetEquipGroup()
    if #g>0 then
        Duel.Overlay(c,g)
        local ct=Duel.GetOperatedGroup():GetCount()
        local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
        if ct>0 and #dg>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local sg=dg:Select(tp,1,ct,nil)
            Duel.Destroy(sg,REASON_EFFECT)
        end
    end
end