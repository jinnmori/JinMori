--Borreload Punish Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum atributes
	Pendulum.AddProcedure(c)
	--Actlimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
	--This card gains Atk equl to the targeted Link Monster 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local pe1=Effect.CreateEffect(c)
	pe1:SetDescription(aux.Stringid(id,1))
	pe1:SetType(EFFECT_TYPE_FIELD)
	pe1:SetCode(EFFECT_SPSUMMON_PROC_G)
	pe1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	pe1:SetRange(LOCATION_PZONE)
	pe1:SetCondition(s.pencon)
	pe1:SetOperation(s.penop)
	pe1:SetValue(SUMMON_TYPE_PENDULUM)
	c:RegisterEffect(pe1)
end
s.listed_series={SET_ROKKET,SET_BORREL}
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_LINK) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_GRAVE,0,1,1,nil,TYPE_LINK)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,c,1,0,0)
	Duel.SetChainLimit(s.chainlm)
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
   local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,tp,1,REASON_EFFECT)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function s.penfilter(c,e,tp)
	return c:IsSetCard({SET_ROKKET,SET_BORREL}) and c:IsLevelBelow(9)
	and ((c:IsLocation(LOCATION_HAND) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,true,true)) or 
	(c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_PENDULUM,tp,false,false)))
	and not c:IsForbidden()
end
function s.pencon(e,c,inchain,re,rp)
	local self=e:GetHandler()
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)~=0 
	and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_PZONE,0,1,self) or (not inchain and Duel.GetFlagEffect(tp,10000000)>0) then return false end
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
	if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)>0 then loc=loc+LOCATION_EXTRA end
	if loc==0 then return false end
	local g=Duel.GetFieldGroup(tp,loc,0)
	return g:IsExists(s.penfilter,1,nil,e,tp)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp,c,sg,inchain)
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	local ft=Duel.GetUsableMZoneCount(tp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		ft=1
	end
	local loc=0
	if ft1>0 then loc=loc+LOCATION_HAND end
	if ft2>0 then loc=loc+LOCATION_EXTRA end
	local tg=Duel.GetMatchingGroup(s.penfilter,tp,loc,0,nil,e,tp)
	ft1=math.min(ft1,tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND))
	ft2=math.min(ft2,tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA))
	ft2=math.min(ft2,aux.CheckSummonGate(tp) or ft2)
	while true do
		local ct1=tg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
		local ct2=tg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
		local ct=ft
		if ct1>ft1 then ct=math.min(ct,ft1) end
		if ct2>ft2 then ct=math.min(ct,ft2) end
		local loc=0
		if ft1>0 then loc=loc+LOCATION_HAND end
		if ft2>0 then loc=loc+LOCATION_EXTRA end
		local g=tg:Filter(Card.IsLocation,sg,loc)
		if #g==0 or ft==0 then break end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Group.SelectUnselect(g,sg,tp,#sg>0,Duel.IsSummonCancelable())
		if not tc then break end
		if sg:IsContains(tc) then
			sg:RemoveCard(tc)
			if tc:IsLocation(LOCATION_HAND) then
				ft1=ft1+1
			else
				ft2=ft2+1
			end
			ft=ft+1
		else
			sg:AddCard(tc)
			if tc:IsLocation(LOCATION_HAND) then
				ft1=ft1-1
			else
				ft2=ft2-1
			end
			ft=ft-1
		end
	end
	if #sg>0 then
		if not inchain then
			Duel.RegisterFlagEffect(tp,10000000,RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,1)
		end
		Duel.HintSelection(Group.FromCards(c),true)
		sg:KeepAlive()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetCountLimit(1,id)
		e1:SetLabelObject(sg)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_SPSUMMON_NEGATED)
		e2:SetOperation(s.op(true,e1))
		e1:SetOperation(s.op(false,e2))
		Duel.RegisterEffect(e2,tp)
	end
end
function s.op(reset,ee)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local g=e:GetLabelObject()
				if reset then
					g:DeleteGroup()
					e:Reset()
					ee:Reset()
					return
				end
				Duel.Damage(tp,500*#g,REASON_EFFECT)
				Duel.RegisterFlagEffect(tp,id,0,0,0)
				g:DeleteGroup()
				e:Reset()
				ee:Reset()
			end
end
