--Seduction Magi ☆ Magician Gal
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER),8,2,s.ovfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	--Take Control of thd targated monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.dxmcostgen(2,2))
	e1:SetTarget(s.ctrltg)
	e1:SetOperation(s.ctrlop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--change battle target
	local e2=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+1)
	e2:SetCondition(s.cbcon)
	e2:SetTarget(s.cbtg)
	e2:SetOperation(s.cbop)
	c:RegisterEffect(e2)
	--change effect target
	local e3=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))	
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id+2)
	e3:SetCondition(s.cecon)
	e3:SetTarget(s.cetg)
	e3:SetOperation(s.ceop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER,lc,SUMMON_TYPE_XYZ,tp) and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp) and (c:GetRank()==6 or c:GetRank()==7)
end
function s.ctrlfilter(c)
	return c:IsControlerCanBeChanged() and not c:IsRace(RACE_SPELLCASTER) 
end
function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctrlfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.ctrlfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.ctrlfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
function s.cbcon(e,tp,eg,ep,ev,re,r,rp)
	return r~=REASON_REPLACE
end
function s.cbfilter(c,at)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
function s.cbtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ac=Duel.GetAttacker()
	local at=Duel.GetAttacker():GetAttackableTarget()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.cbfilter(chkc,at) end
	if chk==0 then return Duel.IsExistingTarget(s.cbfilter,tp,0,LOCATION_MZONE,1,ac,at) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.cbfilter,tp,0,LOCATION_MZONE,1,1,ac,at)
end
function s.cbop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		Duel.GetControl(tc,tp,nil,1)
		Duel.ChangeAttackTarget(tc)
	end
end
function s.cecon(e,tp,eg,ep,ev,re,r,rp)
	if e==re or rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and #g==1 and g:GetFirst()==e:GetHandler()
end
function s.cefilter(c,ct)
	return c:IsFaceup() and Duel.CheckChainTarget(ct,c) and c:IsControlerCanBeChanged()
end
function s.cetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.cefilter(chkc,ev) end
	if chk==0 then return Duel.IsExistingTarget(s.cefilter,tp,0,LOCATION_MZONE,1,nil,ev) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.cefilter,tp,0,LOCATION_MZONE,1,1,nil,ev)
end
function s.ceop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp,nil,1)
		Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	end
end
