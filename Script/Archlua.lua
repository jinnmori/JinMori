--Custom Archtype
if not CustomArchetype then
	CustomArchetype = {}
	
	local MakeCheck=function(setcodes,archtable,extrafuncs)
		return function(c,sc,sumtype,playerid)
			sumtype=sumtype or 0
			playerid=playerid or PLAYER_NONE
			if extrafuncs then
				for _,func in pairs(extrafuncs) do
					if Card[func](c,sc,sumtype,playerid) then return true end
				end
			end
			if setcodes then
				for _,setcode in pairs(setcodes) do
					if c:IsSetCard(setcode,sc,sumtype,playerid) then return true end
				end
			end
			if archtable then
				if c:IsSummonCode(sc,sumtype,playerid,table.unpack(archtable)) then return true end
			end
			return false
		end
	end

	-- Number S
	-- ＳＮｏ.
	-- シャイニングナンバーズ
	-- Number S39: Utopia the Lightning/Number S39: Utopia the Lightning/Number S0: Utopic ZEXAL
	CustomArchetype.OCGNumberS={
		52653092,56832966,86532744,1000908
	}
	Card.IsNumberS=MakeCheck({0x2048},CustomArchetype.OCGNumberS)
	-- Contact Cards
	CustomArchetype.OCGContact={
		16616620,16616620,10493654,10925955,14517422,16169772,35255456,41933425,41933425,82639107,100000551,69270537,810000061,75047173
	}
	Card.IsContact=MakeCheck({0xfde},CustomArchetype.OCGContact)
		-- "Shooting" Synchro monster 
	CustomArchetype.OCGShooting={
		35952884,40939228,24696097,24697845,63180841,68431965
	}
	Card.IsShooting=MakeCheck({0xfee5},CustomArchetype.OCGShooting)
end

