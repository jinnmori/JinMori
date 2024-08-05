--Infernity Priest Archfiend
Duel.LoadScript("SP_CARDS.lua") 
local s,id=GetID()
function s.initial_effect(c)
    --Synchro Summon
   Synchro.AddProcedure(c,s.tunerfilter,1,1,Synchro.NonTunerEx(s.matfilter),1,99)
    c:EnableReviveLimit()
	c:EnableCounterPermit(COUNTER_INFERNO)
    --Send "Infernity" card to GY and negate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_NEGATE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.negcost)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
    local e1b=e1:Clone()
    e1b:SetType(EFFECT_TYPE_QUICK_O)
    e1b:SetCode(EVENT_FREE_CHAIN)
    e1b:SetCondition(s.quickcon)
    c:RegisterEffect(e1b)
    --Add counter when cards are discarded
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCondition(s.ctcon)
    e2:SetOperation(s.ctop)
    c:RegisterEffect(e2)
    --Tribute and banish
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
	e3:SetCountLimit(1,{id,2})
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCost(s.rmcost)
    e3:SetTarget(s.rmtg)
    e3:SetOperation(s.rmop)
    c:RegisterEffect(e3)
	--Battle boost effect
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
	e4:SetCountLimit(1,{id,3})
    e4:SetCategory(CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCondition(s.atkcon)
    e4:SetCost(s.atkcost)
    e4:SetOperation(s.atkop)
    c:RegisterEffect(e4)
	--Store counter value
    if not s.global_check then
        s.global_check=true
        s.counter_value=0
       s.stored_effects = {}
        s.negated_monsters = {}
    end
end
s.synchro_nt_required=1
s.lised_series={SET_INFERNITY}
function s.tunerfilter(c,sc,sumtype,tp)
    return c:IsAttribute(ATTRIBUTE_DARK,sc,sumtype,tp) and c:IsType(TYPE_TUNER,sc,sumtype,tp)
end
function s.matfilter(c,sc,sumtype,tp)
    return c:IsAttribute(ATTRIBUTE_DARK,sc,sumtype,tp) and c:IsType(TYPE_SYNCHRO,sc,sumtype,tp)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return true
end
function s.flagfilter(c)
    return c:IsFaceup() and c:GetFlagEffect(80085565)>0 and not c:IsDisabled()
end
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 or Duel.IsExistingMatchingCard(s.flagfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.costfilter(c)
	return c:ListsArchetype(SET_INFERNITY) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.negfilter(c)
	return c:IsFaceup() and not s.negated_monsters[c]
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() and not s.negated_monsters[chkc] end
    if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
    
    local effs={tc:GetCardEffect()}
    local sel={}
    local desc={}
    for _,eff in ipairs(effs) do
        if eff:GetType()&(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_IGNITION+EFFECT_TYPE_QUICK_O+EFFECT_TYPE_QUICK_F)>0 
           and eff:GetCode()~=EFFECT_IMMUNE_EFFECT 
           and (not s.stored_effects[tc] or not s.stored_effects[tc][eff]) then
            table.insert(sel,eff)
            local d = eff:GetDescription()
            if d and d > 0 then
                table.insert(desc,d)
            else
                table.insert(desc,aux.Stringid(id,1))
            end
        end
    end
    if #sel==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
    local choice=Duel.SelectOption(tp,table.unpack(desc))+1
    local chosen_effect = sel[choice]
    
    -- Store the chosen effect
    s.stored_effects[tc] = s.stored_effects[tc] or {}
    s.stored_effects[tc][chosen_effect] = true
    
    -- Gain the chosen effect
    s.gain_effect(c,tp,chosen_effect)
    
    -- Check if all effects are stored, if so, negate the monster
    local total_effects = 0
    local stored_effects = 0
    for _,eff in ipairs(effs) do
        if eff:GetType()&(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_IGNITION+EFFECT_TYPE_QUICK_O+EFFECT_TYPE_QUICK_F)>0 
           and eff:GetCode()~=EFFECT_IMMUNE_EFFECT then
            total_effects = total_effects + 1
            if s.stored_effects[tc][eff] then
                stored_effects = stored_effects + 1
            end
        end
    end
    
    if stored_effects == total_effects then
        s.negate_monster(c,tc)
        s.negated_monsters[tc] = true
        Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id,2)) -- "Monster negated" message
    end
-- Disable the chosen effect
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
e1:SetCode(EVENT_CHAIN_SOLVING)
e1:SetReset(RESET_EVENT+RESETS_STANDARD)
e1:SetLabelObject(chosen_effect)
e1:SetCondition(s.discon)
e1:SetOperation(s.disop)
Duel.RegisterEffect(e1,tp)

-- Gain the negated effect
s.gain_effect(c,tp,chosen_effect)
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
    local te=e:GetLabelObject()
    return re==te or (re:GetHandler()==te:GetHandler() and re:GetDescription()==te:GetDescription())
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateEffect(ev)
end

function s.gain_effect(c,tp,chosen_effect)
    if not chosen_effect then return end
    local new_e = Effect.CreateEffect(c)
    new_e:SetType(chosen_effect:GetType()&~(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_TRIGGER_F))
    new_e:SetCode(chosen_effect:GetCode())
    new_e:SetProperty(chosen_effect:GetProperty())
    new_e:SetRange(LOCATION_MZONE)
    new_e:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    -- Copy all parts of the effect, ignoring conditions like Synchro Summon
    if chosen_effect:GetCondition() then
        new_e:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
            return true
        end)
    end
    if chosen_effect:GetCost() then
        new_e:SetCost(chosen_effect:GetCost())
    end
    if chosen_effect:GetTarget() then
        new_e:SetTarget(chosen_effect:GetTarget())
    end
    if chosen_effect:GetOperation() then
        new_e:SetOperation(chosen_effect:GetOperation())
    end
    if chosen_effect:GetValue() then
        new_e:SetValue(chosen_effect:GetValue())
    end
    -- Copy description if available
    local d = chosen_effect:GetDescription()
    if d and d > 0 then
        new_e:SetDescription(d)
    end
    -- Handle trigger effects
    if chosen_effect:GetType()&(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_TRIGGER_F)>0 then
        new_e:SetType(EFFECT_TYPE_QUICK_O)
        new_e:SetCode(EVENT_FREE_CHAIN)
        new_e:SetRange(LOCATION_MZONE)
        new_e:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
            return true
        end)
        new_e:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
            if chk==0 then return true end
            if chosen_effect:GetTarget() then
                return chosen_effect:GetTarget()(e,tp,eg,ep,ev,re,r,rp,chk)
            end
        end)
        new_e:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
            Duel.Hint(HINT_CARD,0,c:GetCode())
            if chosen_effect:GetOperation() then
                chosen_effect:GetOperation()(e,tp,eg,ep,ev,re,r,rp)
            end
        end)
    end
    -- Register the gained effect
    c:RegisterEffect(new_e)
end
function s.negate_monster(c,tc)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_DISABLE_EFFECT)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e2)
end

function s.reset_stored_effects(e,tp,eg,ep,ev,re,r,rp)
    s.stored_effects = {}
end
function s.cfilter(c,tp,r)
    return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_HAND) and (r&REASON_EFFECT~=0 or r&REASON_COST~=0)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp,r)
end
-- Counter addition operation
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():AddCounter(COUNTER_INFERNO,1)
end
-- Tribute cost
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    local ct=e:GetHandler():GetCounter(COUNTER_INFERNO)
    s.counter_value=ct
    Duel.Release(e:GetHandler(),REASON_COST)
end
-- Banish target
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil,tp,POS_FACEDOWN) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- Banish operation
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local ct=s.counter_value
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil,tp,POS_FACEDOWN)
    if #g==0 then return end
    local rg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.dncheck,1,tp,HINTMSG_REMOVE)
    if #rg>0 then
        Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
    end
end
-- Battle boost condition
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    if not d then return false end
    if a:IsControler(1-tp) then a,d=d,a end
    return a:IsSetCard(SET_INFERNITY) and a:IsLevelAbove(5) and a:IsRelateToBattle()
        and d:IsControler(1-tp) and d:IsRelateToBattle()
end
-- Battle boost cost
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- Battle boost operation
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    if a:IsControler(1-tp) then a=Duel.GetAttackTarget() end
    if a:IsFaceup() and a:IsRelateToBattle() then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
        e1:SetValue(3500 + s.counter_value * 500)
        a:RegisterEffect(e1)
    end
end