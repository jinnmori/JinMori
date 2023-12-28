--Gladiator Beast Effect Return Condition
function Auxiliary.EnableGBReturn(c,extracat,extrainfo,extraop,returneff)
	if not extracat then extracat=0 end
	--return
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK | extracat)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(Auxiliary.GBReturnCondition1)
	e1:SetTarget(Auxiliary.GBReturnTarget(c,extrainfo))
	e1:SetOperation(Auxiliary.GBReturnOperation(c,extraop))
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(0)
	e2:SetCondition(Auxiliary.GBReturnCondition2)
	c:RegisterEffect(e2)
	if returneff then
		e1:SetLabelObject(returneff)
		e2:SetLabelObject(returneff)
	end
end
function Auxiliary.GBReturnCondition1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsHasEffect(8908781)
end
function Auxiliary.GBReturnCondition2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsHasEffect(8908781)
end
function Auxiliary.GBReturnTarget(c,extrainfo)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
		if extrainfo then extrainfo(e,tp,eg,ep,ev,re,r,rp,chk) end
	end
end
function Auxiliary.GBReturnOperation(c,extraop)
	return function(e,tp,eg,ep,ev,re,r,rp)
			if extraop then
				extraop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end