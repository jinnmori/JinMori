--暗黒界の狩人 ブラウ
--Broww, Huntsman of Dark World 
Duel.LoadScript("utopia.lua")
local s,id=GetID()
function s.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DWORLD)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	if rp==1-tp and c:IsPreviousControler(tp) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	return (c:IsPreviousLocation(LOCATION_HAND) and (r&REASON_EFFECT+REASON_DISCARD)==REASON_EFFECT+REASON_DISCARD) or e:GetHandler():GetFlagEffect(67985556)~=0
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	local opp_chk=e:GetLabel()
	if opp_chk==1 then
		Duel.SetTargetParam(2)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	else
		Duel.SetTargetParam(1)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local opp_chk=e:GetLabel()
	if opp_chk==1 then
	Duel.Draw(tp,2,REASON_EFFECT)
	else
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
