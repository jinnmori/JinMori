--Standard target and operation functions for the "Meklord" effects that Trigger on Normal/Special Summon (also see "Meklord World")
Meklord={}
EFFECT_MEKLORD_STARCORE = EVENT_CUSTOM+200
function Meklord.EquipFilter(f)
	return	function(c,tp)
				return c:CheckUniqueOnField(tp) and not c:IsForbidden() and (not f or f(c))
			end
end
function Meklord.EquipTarget(f,targets,mandatory)
	f=Meklord.EquipFilter(f)
	if targets then
		return Meklord.EquipTarget_TG(f,mandatory)
	else
		return Meklord.EquipTarget_NTG(f,mandatory)
	end
end
function Meklord.EquipOperation(f,op,targets)
	f=Meklord.EquipFilter(f)
	if targets then
		return Meklord.EquipOperation_TG(f,op)
	else
		return Meklord.EquipOperation_NTG(f,op)
	end
end
function starcorefilter(c)
	return c:IsCode(8908766)
end
function Meklord.EquipTarget_TG(f,mandatory)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		local starcore=e:GetHandler()
		local wc=Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_MEKLORD_STARCORE)
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and (wc or chkc:IsControler(1-tp)) and f(chkc,1-tp) end
		if chk==0 then return mandatory end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		if (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(f,tp,0,LOCATION_MZONE,1,nil,tp)) then
		local g=Duel.SelectTarget(tp,f,tp,0,LOCATION_MZONE,1,1,nil,tp)
		elseif wc and Duel.IsExistingMatchingCard(starcorefilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,LOCATION_MZONE,1,nil,tp) then
		local g=Duel.SelectMatchingCard(tp,starcorefilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,LOCATION_MZONE,1,1,nil,tp)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
		end
	end
end
function Meklord.EquipTarget_NTG(f,mandatory)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
		local wc=Duel.IsPlayerAffectedByEffect(tp,EFFECT_Meklord_WORLD)
		local loc,player=0,tp
		if wc then
			loc=LOCATION_GRAVE
			player=PLAYER_ALL
		end
		if chk==0 then return mandatory or (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE,loc,1,nil,tp)) end
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,player,0)
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,player,LOCATION_GRAVE)
	end
end
function Meklord.EquipOperation_TG(f,op)
	return	function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		local c=e:GetHandler()
		if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and f(tc,tp) then
			op(c,e,tp,tc)
		end
	end
end
function Meklord.EquipOperation_NTG(f,op)
	return	function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		local c=e:GetHandler()
		if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
		local wc=Duel.IsPlayerAffectedByEffect(tp,EFFECT_Meklord_WORLD)
		local loc=0
		if wc then loc=LOCATION_GRAVE end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(f),tp,LOCATION_GRAVE,loc,1,1,nil,tp)
		local tc=g:GetFirst()
		if tc then
			op(c,e,tp,tc)
		end
	end
end
