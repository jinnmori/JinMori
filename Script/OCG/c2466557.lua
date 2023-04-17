--Eternity Photon Stream
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_GALAXY_EYES}
s.listed_names={31801517,48348921}
function s.condfilter1(c)
	return c:IsSetCard(SET_GALAXY_EYES) and c:IsType(TYPE_XYZ) and c:IsFaceup() and not c:IsCode(31801517)
end
function s.condfilter2(c)
	return c:IsSetCard(SET_GALAXY_EYES) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,31801517),tp,LOCATION_ONFIELD,0,1,nil) 
		and Duel.IsExistingMatchingCard(s.condfilter1,tp,LOCATION_ONFIELD,0,1,nil) then
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
	else  
 return Duel.IsExistingMatchingCard(s.condfilter2,tp,LOCATION_ONFIELD,0,1,nil) and (Duel.GetTurnPlayer()~=tp or Duel.GetTurnPlayer()==tp)
		end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
	if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,31801517),tp,LOCATION_ONFIELD,0,1,nil) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		if #mg>0 then
		Duel.Remove(mg,POS_FACEUP,REASON_EFFECT)
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,31801517,48348921),tp,LOCATION_ONFIELD,0,1,nil) then
		Duel.BreakEffect()
		local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_SZONE,nil)
		if #sg>0 then
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
			end
		end
	if e:GetLabel()==1 then
	--Cannot conduct your Battle Phase this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
				end
		end
end
