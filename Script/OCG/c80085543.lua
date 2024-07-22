--Chaos Seventh
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --Draw
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_PREDRAW)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(1,0)
    e2:SetCondition(s.drcon)
	e2:SetOperation(s.drop)
    e2:SetValue(s.drval)
    c:RegisterEffect(e2)
    --Xyz Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.xyztg)
    e3:SetOperation(s.xyzop)
    c:RegisterEffect(e3)
    --Special Summon
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_SZONE)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCountLimit(1,id)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end
s.listed_series={SET_NUMBER,SET_NUMBER_C)
function s.drconfilter(c)
	local m=c:GetMetatable(true)
	if not m then return false end
	local no=m.xyz_number
    return c:IsFaceup() and c:IsSetCard(SET_NUMBER_C) and no and no>=101 and no<=107
end
function s.drcon(e)
	local tp=e:GetHandlerPlayer()
    return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)==0 and tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.GetDrawCount(tp)>0 and Duel.IsExistingTarget(s.drconfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
end
function s.drcon2(e)
    return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)==0
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		e1:SetCondition(s.drcon2)
		e1:SetValue(s.drval)
		Duel.RegisterEffect(e1,tp)
end
function s.cfilter(c)
	local m=c:GetMetatable(true)
	if not m then return false end
	local no=m.xyz_number
    return c:IsFaceup() and c:IsSetCard(SET_NUMBER_C) and no and no>=101 and no<=107
end
function s.drval(e)
    local g=Duel.GetMatchingGroup(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	  local ct=g:GetClassCount(function(c)
        local m=c:GetMetatable(true)
        if not m then return false end
        return m.xyz_number
    end)+1
    Duel.RegisterFlagEffect(e:GetHandlerPlayer(),id,RESET_PHASE+PHASE_END,0,1)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,e:GetHandlerPlayer())
    return ct
end
function s.xyzfilter(c,e,tp)
    local m=c:GetMetatable(true)
	if not m then return false end
	local no=m.xyz_number
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and no and no>=101 and no<=107 and c:IsSetCard(SET_NUMBER)
	and Duel.IsExistingMatchingCard(s.xyzfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,no,pg)
end
function s.xyzfilter2(c,e,tp,mc,no,pg)
    return c.xyz_number==no and c:IsSetCard(SET_NUMBER_C) and mc:IsCanBeXyzMaterial(c,tp) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.xyzfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or #pg>1 or (#pg==1 and not pg:IsContains(tc)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local m=tc:GetMetatable(true)
	if not m then return end
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,m.xyz_number,pg)
	local sc=g:GetFirst()
	if sc then
		sc:SetMaterial(tc)
		Duel.Overlay(sc,tc)
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
		local g1=Duel.GetOverlayGroup(tp,0,1)
		if #g1>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
			local mg2=g1:Select(tp,1,1,nil)
			local oc=mg2:GetFirst():GetOverlayTarget()
			Duel.Overlay(sc,mg2)
			Duel.RaiseSingleEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
		end
	end
end
function s.spfilter(c,e,tp)
   local m=c:GetMetatable(true)
	if not m then return false end
	local no=m.xyz_number
	return no and no>=101 and no<=107 and c:IsSetCard(SET_NUMBER_C)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,tp,c,no)
end
function s.matfilter(c,tp,mc,no)
   return c.xyz_number==no and c:IsSetCard(SET_NUMBER) and c:IsCanBeXyzMaterial(mc,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
     if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	 local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		 local m=tc:GetMetatable(true)
		if not m then return false end
		local no=m.xyz_number
		local oc=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,tp,tc,m.xyz_number):GetFirst()
			Duel.HintSelection(oc,true)
			Duel.Overlay(tc,oc)
			Duel.SpecialSummonComplete()
		end
	end