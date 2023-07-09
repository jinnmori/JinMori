	--Effect Synchro Level 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
	e2:SetOperation(s.synop)
	c:RegisterEffect(e2)
end
function s.synlevel(c,lc,sc,bool)
	if c:GetCode()==lc:GetCode() then
	if bool then
		return 2
	elseif bool then
		return 3
	elseif bool then
		return 4
	else
		return 5
	end
	else 
		return c:GetSynchroLevel(sc)
	end
end
function s.synop(e,tg,ntg,sg,lv,sc,tp)
	local res=sg:CheckWithSumEqual(Card.GetSynchroLevel,lv,#sg,#sg,sc) 
	or sg:CheckWithSumEqual(s.synlevel,lv,#sg,#sg,e:GetHandler(),sc,true)
	or sg:CheckWithSumEqual(s.synlevel,lv,#sg,#sg,e:GetHandler(),sc,false)
	return res,true
end