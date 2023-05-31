--Number S39: Golden Leo Utopia Ray
Duel.LoadScript("Archlua.lua")
Duel.LoadCardScript("c56840427.lua")
Duel.LoadScript("Archetypes.lua")
local s,id=GetID()
function s.initial_effect(c)
    --Regular Xyz procedure (3 Level 6 monsters)
    Xyz.AddProcedure(c,nil,6,2,s.xyzfilter,aux.Stringid(id,0),2,s.xyzcheck)
    	c:EnableReviveLimit()
    	--cannot be Xyz material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Mulitple Attacks
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	--Negate the activation of card/effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.eqcon)
	e3:SetCost(s.eqcost)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
end
	s.listed_series={SET_ZW,SET_NUMBER,SET_NUMBER_S}
	s.listed_names={id}
	s.xyz_number=39
function s.xyzfilter(c,xyz,sumtype,tp)
    return c:IsSummonCode(xyz,SUMMON_TYPE_XYZ,tp,56840427)
end
function s.cfilter(c)
	return c:IsNumberS() and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.xyzcheck(e,tp,chk,mc)
	local c=e:GetHandler()
   if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local tc=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil):SelectUnselect(Group.CreateGroup(),tp,false,Xyz.ProcCancellable)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	if tc then
		c:SetMaterial(tc)
		Duel.Overlay(c,tc)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
		return true
	else return false end
end
function s.value(e,c)
	return c:GetEquipCount()
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e:GetHandler(),tp)end
   end
function s.eqfilter(c,tc,tp)
	if not (c:IsSetCard(SET_ZW) and not c:IsForbidden()) then return false end
	local effs={c:GetCardEffect(75402014)}
	for _,te in ipairs(effs) do
		if te:GetValue()(tc,c,tp) then return true end
	end
	return false
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,c,tp)
	local tc=g:GetFirst()
		Duel.Equip(tp,tc,c)
		Duel.ConfirmCards(1-tp,tc) 
		local eff=tc:GetCardEffect(75402014)
		eff:GetOperation()(tc,eff:GetLabelObject(),tp,c)
			--Unaffected by other card effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3100)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
end
function s.efilter(e,te)
	local tp=e:GetHandlerPlayer()
	return te:GetOwnerPlayer()==1-tp
end