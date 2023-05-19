function Auxiliary.SSW(card,player,check,oper,str,...)
if card then
		if not check then check=Card.IsAbleToGrave end
		if not oper then oper=aux.thoeSend end
		if not str then str=2 end
		local b1,b2=true,true
		if type(card)=="Group" then
			for ctg in aux.Next(card) do
				if not ctg:IsAbleToDeck() then
					b1=false
				end
				if not check(ctg,...) then
					b2=false
				end
			end
		else
			b1=card:IsAbleToDeck()
			b2=check(card,...)
		end
		local opt
		if b1 and b2 then
			opt=Duel.SelectOption(player,507,str)
		elseif b1 then
			opt=Duel.SelectOption(player,507)
		else
			opt=Duel.SelectOption(player,str)+1 
		end
		if opt==0 then
			local res=Duel.SendtoDeck(card,nil,2,REASON_EFFECT)
			return res
		else
			return oper(card,...)
		end
	end
end


Duel.LoadScript("cards_specific_functions.lua")
Duel.LoadScript("proc_fusion.lua")
Duel.LoadScript("proc_fusion_spell.lua")
Duel.LoadScript("proc_ritual.lua")
Duel.LoadScript("proc_synchro.lua")
Duel.LoadScript("proc_union.lua")
Duel.LoadScript("proc_xyz.lua")
Duel.LoadScript("proc_pendulum.lua")
Duel.LoadScript("proc_link.lua")
Duel.LoadScript("proc_equip.lua")
Duel.LoadScript("proc_persistent.lua")
Duel.LoadScript("proc_workaround.lua")
Duel.LoadScript("proc_normal.lua")
Duel.LoadScript("proc_skill.lua")
Duel.LoadScript("proc_maximum.lua")
Duel.LoadScript("proc_gemini.lua")
Duel.LoadScript("proc_spirit.lua")
Duel.LoadScript("deprecated_functions.lua")
pcall(dofile,"init.lua")
