--Odd-Eyes Crystal Dragon 
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,nil,3,3,s.lcheck)
	c:EnableReviveLimit()
		-- Place in Pendulum Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.pencon)
	e1:SetTarget(s.pentg)
	e1:SetOperation(s.penop)
	c:RegisterEffect(e1)
		--Gain Effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.matcheck)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ODD_EYES,SET_PERFORMAPAL,SET_MAGICIAN}
s.listed_names={id}

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsType,2,nil,TYPE_PENDULUM,lc,sumtype,tp)
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
function s.penfilter(c)
	return (c:IsSetCard(SET_ODD_EYES) or c:IsSetCard(SET_PERFORMAPAL) or c:IsSetCard(SET_MAGICIAN)) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) and Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local pg=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if pg then
		Duel.MoveToField(pg,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.filter(c)
	return c:IsMonster() and c:IsSetCard(SET_ODD_EYES) 
end
function s.matcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.filter,1,nil) then
		--Your opponent cannot target with card effects.
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(s.indcon) 
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e1)
		--Your opponent cannot destroy with card effects.
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE)
		e2:SetValue(s.indval)
		c:RegisterEffect(e2)
	--Send 1 monster to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	e3:SetCountLimit(1)
	e3:SetTarget(s.sendtg)
	e3:SetOperation(s.sendop)
	c:RegisterEffect(e3)
	end
end
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.TRUE,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,nil)
end
function s.indval(e,re,tp)
	return tp~=e:GetHandlerPlayer()
end
function s.tgfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_ODD_EYES) and not c:IsCode(id) and c:IsAbleToGrave() 
end
function s.sendtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.sendop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
		local code=g:GetFirst():GetOriginalCodeRule()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		if not g:GetFirst():IsType(TYPE_TRAPMONSTER) then
			c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		end
	end
end
