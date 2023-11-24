--for additional registers
REGISTER_FLAG_DWORLD=  9
Card.RegisterEffect=(function()
	local oldf=Card.RegisterEffect
	local function map_to_effect_code(val)
		if val==9 then return 67985556 end -- access to Dark World effects that activate when Sent to GY as its discarded
		return nil
	end
	return function(c,e,forced,...)
		local reg_e=oldf(c,e,forced)
		if not reg_e or reg_e<=0 then return reg_e end
		local resetflag,resetcount=e:GetReset()
		for _,val in ipairs{...} do
			local code=map_to_effect_code(val)
			if code then
				local prop=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE
				if e:IsHasProperty(EFFECT_FLAG_UNCOPYABLE) then prop=prop|EFFECT_FLAG_UNCOPYABLE end
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(prop,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
				e2:SetCode(code)
				e2:SetLabelObject(e)
				e2:SetLabel(c:GetOriginalCode())
				if resetflag and resetcount then
					e2:SetReset(resetflag,resetcount)
				elseif resetflag then
					e2:SetReset(resetflag)
				end
				c:RegisterEffect(e2)
			end
		end
		return reg_e
	end
end)()