--Number S39: Utopia ZEXAL
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_ZW),5,2)
	c:EnableReviveLimit()
	--xyz summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.xyzcon)
	e1:SetTarget(s.xyztg)
	e1:SetOperation(s.xyzop)
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)
	--multi attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	--Equip 1 "ZW" monster from your attached materials
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
	--Disable attack
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCost(aux.dxmcostgen(1,1,nil))
	e4:SetOperation(function() Duel.NegateAttack() end)
	c:RegisterEffect(e4,false,REGISTER_FLAG_DETACH_XMAT)
end
s.xyz_number=39
s.listed_series={SET_UTOPIA,SET_ZW}
function s.xyzfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsRank(4) and c:IsSetCard(SET_UTOPIA) and c:GetEquipCount()>0 and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp) 
	and Duel.GetLocationCountFromEx(tp,tp,c,xyzc)>0
end
function s.xyzcon(e,c)
	if c==nil then return true end
	if og then return false end
	local tp=c:GetControler()
	local mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local mustg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,mg,REASON_XYZ)
	if #mustg>0 or (min and min>1) then return false end
	local xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil,tp,c)
	return #xg>0
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local rg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,0,nil,tp,c)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_SPSUMMON,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	local ov=g:GetFirst():GetOverlayGroup()
	local eqg=g:GetFirst():GetEquipGroup()
	eqg:AddCard(ov)
	eqg:AddCard(g:GetFirst())
	e:GetHandler():SetMaterial(eqg)
	Duel.Overlay(e:GetHandler(),eqg)
	g:DeleteGroup()
 end
 function s.val(e,c)
	return c:GetOverlayGroup():FilterCount(Card.IsSetCard,nil,SET_ZW)
end

function s.zwcfilter(c)
	return c:IsSetCard(SET_ZW) and c:GetOriginalType() & TYPE_MONSTER ~= 0
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetOverlayGroup():IsExists(s.zwcfilter,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,1)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=c:GetOverlayGroup():FilterSelect(tp,s.zwcfilter,1,1,nil)
	local tc=g:GetFirst()
	if #g>0 then
		Duel.Equip(tp,g:GetFirst(),c)
		Duel.ConfirmCards(1-tp,g) end
	local tc=g:GetFirst()
	if tc then
	local eff=tc:GetCardEffect(75402014)
	eff:GetOperation()(tc,eff:GetLabelObject(),tp,c)
	end
end