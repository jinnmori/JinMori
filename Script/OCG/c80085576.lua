--Number C82: Advanced Heartlandraco
local s,id=GetID()
function s.initial_effect(c)
    --xyz summon
    Xyz.AddProcedure(c,nil,5,3)
    c:EnableReviveLimit()
    --Destroy all Spell/Trap cards you control
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    --Protection
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,3))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCost(aux.dxmcostgen(1,1,nil))
    e2:SetOperation(s.protop)
    c:RegisterEffect(e2)
    --Direct attack
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DIRECT_ATTACK)
    e3:SetCondition(s.dircon)
    c:RegisterEffect(e3)
end
s.xyz_number=82
s.listed_names={31437713}
function s.filter(c,tp,eg,ep,ev,re,r,rp)
	local te=c:GetActivateEffect()
	if not te then return false end
	local condition=te:GetCondition()
	local cost=te:GetCost()
	local target=te:GetTarget()
	return c:IsSpellTrap() and c:IsType(TYPE_CONTINUOUS) and (not condition or condition(te,tp,eg,ep,ev,re,r,rp))
		and (not cost or cost(te,tp,eg,ep,ev,re,r,rp,0))
		and (not target or target(te,tp,eg,ep,ev,re,r,rp,0))
end
function s.xyzfilter(c,e,tp,rk)
    return c:IsType(TYPE_XYZ) and c:IsSetCard(SET_NUMBER) and c:IsRank(rk-1,rk+1)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
        Duel.BreakEffect()
        local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,tp)
        if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINT_SELECTMSG)
            local tc=sg:Select(tp,1,1,nil):GetFirst()
            if tc then
                local tpe=tc:GetType()
                local te=tc:GetActivateEffect()
                if te then
                    local con=te:GetCondition()
                    local co=te:GetCost()
                    local tg=te:GetTarget()
                    local op=te:GetOperation()
                    Duel.ClearTargetCard()
                    e:SetCategory(te:GetCategory())
                    e:SetProperty(te:GetProperty())
                    Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
                    Duel.Hint(HINT_CARD,0,tc:GetCode())
                    tc:CreateEffectRelation(te)
                    if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
                    if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
                    Duel.BreakEffect()
                    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
                    if g then
                        local etc=g:GetFirst()
                        while etc do
                            etc:CreateEffectRelation(te)
                            etc=g:GetNext()
                        end
                    end
                    if op then op(te,tp,eg,ep,ev,re,r,rp) end
                    tc:ReleaseEffectRelation(te)
                    if g then
                        etc=g:GetFirst()
                        while etc do
                            etc:ReleaseEffectRelation(te)
                            etc=g:GetNext()
                        end
                    end
                    s.add_xyz_effect(tc,tp)
                end
            end
        end
    end
end
function s.add_xyz_effect(c,tp)
    if not c:IsType(TYPE_CONTINUOUS) then return end
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.xyztg)
    e1:SetOperation(s.xyzop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsType(TYPE_XYZ) and chkc:IsSetCard(SET_NUMBER) end
    if chk==0 then return Duel.IsExistingTarget(s.xyzfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.xyzfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzfilter1(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return c:IsSetCard(SET_NUMBER) and c:IsFaceup() and c:IsType(TYPE_XYZ) and (#pg<=0 or (#pg==1 and pg:IsContains(c)))
	and Duel.IsExistingMatchingCard(s.xyzfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetRank(),c)
end
function s.xyzfilter2(c,e,tp,rk,mc,pg)
	if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then
		return false
	end
	return c:IsType(TYPE_XYZ) and c:IsSetCard(SET_NUMBER) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) 
	and c:IsRank(rk-1,rk+1) and mc:IsCanBeXyzMaterial(c,tp)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
    local g=Duel.SelectMatchingCard(tp,s.xyzfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc:GetRank(),tc,pg)
    local sc=g:GetFirst()
    if sc then
	sc:SetMaterial(Group.FromCards(tc))
        Duel.Overlay(sc,tc)
        Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
        sc:CompleteProcedure()
    end
end
function s.protop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetValue(1)
    Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetReset(RESET_PHASE+PHASE_END)
    e2:SetValue(1)
    Duel.RegisterEffect(e2,tp)
end

function s.dircon(e)
    return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,31437713)
end