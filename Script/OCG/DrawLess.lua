--If the card have an "You draw 1 less card at the beginning of the Duel" condition
Auxiliary.Lessdraw={}
function Auxiliary.AddLessdraw(c,less)
	local typ=type(less)
	if typ=="number" or (typ=="boolean" and less) then
		Auxiliary.Lessdraw[c]=typ=="number" and less or 1
	end
end
function Auxiliary.lessdrawop(e)
	e:Reset()
	local t={}
	t[0]=0
	t[1]=0
	for c,val in pairs(aux.Lessdraw) do
		t[c:GetControler()]=t[c:GetControler()]+val
	end
	for p=0,1 do
		if t[p]~=0 then
			Debug.SetPlayerInfo(p,Duel.GetLP(p),Duel.GetDrawCount(p))
		end
	end
end
local  lesseff=Effect.GlobalEffect()
lesseff:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
lesseff:SetCode(EVENT_STARTUP)
lesseff:SetOperation(aux.lessdrawop)
Duel.RegisterEffect(lesseff,0)

