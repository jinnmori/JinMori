--D/D/D Last King Revelation
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Attributes
    Pendulum.AddProcedure(c)
	--Pendulum Effect
    local pe1=Effect.CreateEffect(c)
    pe1:SetDescription(aux.Stringid(id,1))
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1,{id,1})
    pe1:SetTarget(s.pentg)
    pe1:SetOperation(s.penop)
    c:RegisterEffect(pe1)
   --Effect Synchro Level 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e1:SetOperation(s.synop)
	c:RegisterEffect(e1)
	 --Destroy
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
end
s.listed_series={SET_DD,SET_DARK_CONTRACT}
function s.penfilter(c)
	local darkcontract=c:IsSetCard(SET_DARK_CONTRACT) and c:IsContinuousSpell()
    return c:IsAbleToGraveAsCost() and darkcontract
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_DECK,0,1,nil) end
    local g=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 or not Duel.SendtoGrave(g,REASON_COST) then return end
    local tc=g:GetFirst()
    e:SetLabelObject(tc)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local tc=e:GetLabelObject()
    if tc and tc:IsLocation(LOCATION_GRAVE) then
        local effs={tc:GetCardEffect()}
        for _,eff in ipairs(effs) do
            if eff:GetCode()~=id then  -- Prevent infinite loop
                local e1=eff:Clone()
                e1:SetRange(LOCATION_PZONE)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                c:RegisterEffect(e1)
                if eff:IsHasType(EFFECT_TYPE_FIELD) then
                    local e2=e1:Clone()
                    e2:SetType(EFFECT_TYPE_FIELD)
                    e2:SetCode(eff:GetCode())
                    e2:SetCondition(s.effcon(eff))
                    e2:SetTarget(s.efftg(eff))
                    e2:SetOperation(s.effop(eff))
                    c:RegisterEffect(e2)
                elseif eff:IsHasType(EFFECT_TYPE_CONTINUOUS) then
                    local e3=e1:Clone()
                    e3:SetType(EFFECT_TYPE_CONTINUOUS)
                    e3:SetCode(eff:GetCode())
                    e3:SetCondition(s.effcon(eff))
                    e3:SetOperation(s.effop(eff))
                    c:RegisterEffect(e3)
                elseif eff:IsHasType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_TRIGGER_O) then
                    local e4=e1:Clone()
                    e4:SetType(EFFECT_TYPE_FIELD+eff:GetType())
                    e4:SetCode(eff:GetCode())
                    e4:SetCondition(s.effcon(eff))
                    e4:SetTarget(s.efftg(eff))
                    e4:SetOperation(s.effop(eff))
                    c:RegisterEffect(e4)
                end
            end
        end
        --Change Code Name
        local e5=Effect.CreateEffect(c)
        e5:SetType(EFFECT_TYPE_SINGLE)
        e5:SetCode(EFFECT_CHANGE_CODE)
        e5:SetValue(tc:GetCode())
        e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e5)
        Duel.Damage(tp,1500,REASON_EFFECT)
    end
end
function s.effcon(baseeff)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local basecon=baseeff:GetCondition()
        return not basecon or basecon(e,tp,eg,ep,ev,re,r,rp)
    end
end
function s.efftg(baseeff)
    return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
        local basetg=baseeff:GetTarget()
        if chk==0 then return not basetg or basetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
        if basetg then basetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
    end
end
function s.effop(baseeff)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local baseop=baseeff:GetOperation()
        if baseop then baseop(e,tp,eg,ep,ev,re,r,rp) end
    end
end
function s.synlevel(c,lc,sc,bool)
	if c:GetCode()==lc:GetCode() and sc:IsSetCard(SET_DD) then
	if bool then
		return 1
	else
		return 2
	end
	else 
		return c:GetSynchroLevel(sc)
	end
end
function s.synlevel2(c,lc,sc,bool)
	if c:GetCode()==lc:GetCode() and sc:IsSetCard(SET_DD) then
	if bool then
		return 3
	else
		return 4
	end
	else 
		return c:GetSynchroLevel(sc)
	end
end
function s.synlevel3(c,lc,sc,bool)
	if c:GetCode()==lc:GetCode() and sc:IsSetCard(SET_DD) then
	if bool then
		return 5
	else
		return 6
	end
	else 
		return c:GetSynchroLevel(sc)
	end
end
function s.synlevel4(c,lc,sc,bool)
	if c:GetCode()==lc:GetCode() and sc:IsSetCard(SET_DD) then
	if bool then
		return 7
	else
		return 8
	end
	else 
		return c:GetSynchroLevel(sc)
	end
end
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	local res=sg:CheckWithSumEqual(Card.GetSynchroLevel,lv,#sg,#sg,sc) 
	or sg:CheckWithSumEqual(s.synlevel,lv,#sg,#sg,e:GetHandler(),sc,true) or sg:CheckWithSumEqual(s.synlevel,lv,#sg,#sg,e:GetHandler(),sc,false) 
	or sg:CheckWithSumEqual(s.synlevel2,lv,#sg,#sg,e:GetHandler(),sc,true) or sg:CheckWithSumEqual(s.synlevel2,lv,#sg,#sg,e:GetHandler(),sc,false)
	or sg:CheckWithSumEqual(s.synlevel3,lv,#sg,#sg,e:GetHandler(),sc,true) or sg:CheckWithSumEqual(s.synlevel3,lv,#sg,#sg,e:GetHandler(),sc,false)
	or sg:CheckWithSumEqual(s.synlevel4,lv,#sg,#sg,e:GetHandler(),sc,true) or sg:CheckWithSumEqual(s.synlevel4,lv,#sg,#sg,e:GetHandler(),sc,false) 	 	
	return res,true
end
function s.desfilter(c,e)
    return (c:IsSetCard(SET_DD) or c:IsSetCard(SET_DARK_CONTRACT)) and c:IsFaceup() and c:IsDestructable() and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
    return sg:FilterCount(Card.IsControler,nil,tp)==1
        and sg:FilterCount(Card.IsControler,nil,1-tp)==1
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g1=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,0,e:GetHandler(),e)
    local g2=Duel.GetMatchingGroup(aux.AND(Card.IsDestructable,Card.IsCanBeEffectTarget),tp,0,LOCATION_MZONE,nil,e)
    local g=g1:Clone()
    g:Merge(g2)
    if chkc then return false end
    if chk==0 then return #g1>0 and #g2>0 end
    local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_DESTROY,s.rescon)
    Duel.SetTargetCard(sg)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,2,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local tg=g:Filter(Card.IsRelateToEffect,nil,e)
    if #tg>0 then
        Duel.Destroy(tg,REASON_EFFECT)
    end
end
