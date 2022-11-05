-- Addon created by =VF= Vertical Ray
hook.Add("OnGamemodeLoaded", "RestoreStuffAddon", function()
	print("CrashSave BY: =VF= Vertical Ray");
	-- Creating Data folder
	if !file.Exists("crashsave", "DATA") then
		file.CreateDir("crashsave")
	end
	timer.Create( "VCS_OnlinePlayers", vcs_DeleteData, 0, function() 
		--print("CRASHSAVE: CHECKING ONLINE PLAYERS")
		local VCS_Player = player.GetAll()
		local VCS_PlayerUID = {}
		local VCS_PDList = file.Find("crashsave/*", "DATA")
		for k, v in pairs(VCS_Player) do
			table.insert(VCS_PlayerUID, v:UniqueID()..".txt")
		end
		for k, v in pairs(VCS_PDList) do
			if !(table.HasValue( VCS_PlayerUID, v )) then
				--print("CRASHSAVE: FOUND ONE")
				local VCS_JFileData = file.Read( "crashsave/"..v.."", "DATA" )
				local VCS_CFileData = util.JSONToTable( VCS_JFileData )
				if vcs_DeletePData <= (os.time() - VCS_CFileData[5]) or file.Read( "crashsave/"..v.."", "DATA" ) == "[]" then 
					--print("CRASHSAVE: DELETE SAVE DATA")
					file.Delete("crashsave/"..v.."")
				end
			end
		end
	end )
end)

hook.Add( "PlayerInitialSpawn", "RestoreStuffInit", function( ply )
	local VCS_UserDataPath = "crashsave/"..ply:UniqueID()..".txt"
	if file.Exists( VCS_UserDataPath, "DATA") and (file.Read( VCS_UserDataPath, "DATA" ) != "[]") then
		--Start Restore of them Items yea :)?
		--print("CRASHSAVE: PLAYER FILE EXISTS")
		local VCS_UJSTableData = file.Read( VCS_UserDataPath, "DATA" )
		local VCS_UTableData = util.JSONToTable( VCS_UJSTableData )
		local VCS_GEnt = ents.GetAll()
		--Restores Props !
		if (vcs_Props) then
			--print("CRASHSAVE: PROPS GIVE BACK IS TRUE")
			ply:ChatPrint( "CrashSave: Your props are being respawned!" )
			for k, v in pairs(VCS_UTableData[1]) do
				--print("CRASHSAVE: PROP")
				local VCS_Prop = ents.Create("prop_physics")
						
				if ( !IsValid( VCS_Prop ) ) then return end
						
				VCS_Prop:SetModel(v[3])
				VCS_Prop:SetPos(Vector(v[1][1], v[1][2], v[1][3]))
				VCS_Prop:SetAngles(Angle(v[2][1], v[2][2], v[2][3]))
				VCS_Prop:Spawn()
						
				local VCS_Phys = VCS_Prop:GetPhysicsObject()
				if ( !IsValid( VCS_Phys ) ) then
					VCS_Prop:Remove()
					return
				end
						
				VCS_Phys:EnableMotion(false)
					
				VCS_Prop:CPPISetOwner(ply)
						
				cleanup.Add( ply, "prop", VCS_Prop )
						
				undo.Create("props")
					undo.AddEntity(VCS_Prop)
					undo.SetPlayer(ply)
				undo.Finish()
				--print("CRASHSAVE: GIVING BACK A PROP")
			end	
			--print("CRASHSAVE: PROP GIVEBACK END")
		end
		if (vcs_Doors) then
			--print("CRASHSAVE: DOOR START")
			ply:ChatPrint( "CrashSave: Your doors are going to be given back to you!" )
			for i, e in pairs(VCS_GEnt) do
				if (table.HasValue( VCS_UTableData[2], tostring( e ))) then
					if e:getDoorOwner() == nil then
						timer.Simple( 8, function()
							--print("CRASHSAVE: GIVING BACK A DOOR")
							e:keysOwn( ply )
						end )
					end
				end
			end
			--print("CRASHSAVE: DOOR END")
		end
		if (vcs_Jobs) then
			--print("CRASHSAVE: GIVE JOB BACK")
			timer.Simple( 8, function()
				ply:changeTeam(VCS_UTableData[3], true)
				--print("CRASHSAVE: GIVE JOB END")
			end )
		end
		if (vcs_Weapons) then
			ply:ChatPrint( "CrashSave: Your weapons will be restored in a few seconds!!" )
			timer.Simple( 15, function()
				for k, v in pairs(VCS_UTableData[4]) do
					ply:Give( k )
					if k[1] == 0 and k[2] == -1 then
						ply:SetAmmo( k[1], k[2] ) 
					end
				end
			end )
		end
	else
		file.Write( VCS_UserDataPath, "[]" )
	end
end)
timer.Create( "VCS_SaveData", vcs_SaveData, 0, function() 
	--print("CRASHSAVE: SAVE DATA START")
	local VCS_Player = player.GetAll()
	local VCS_GProps = ents.GetAll()
	local VCS_GEnt = ents.GetAll()
	for k, v in pairs(VCS_Player) do
		local VCS_DataArray = {}
		VCS_DataArray[1] = {}
		VCS_DataArray[2] = {}
		VCS_DataArray[4] = {}
		file.Delete("crashsave/"..v:UniqueID()..".txt")
		local VCS_PropIndex = 1
		if (vcs_Props) then
			--print("CRASHSAVE: GOING THROUGH PROPS")
			for i, e in pairs(VCS_GEnt) do
				if e:CPPIGetOwner() == v then
					VCS_DataArray[1][VCS_PropIndex] = {}
					VCS_DataArray[1][VCS_PropIndex][1] = {}
					VCS_DataArray[1][VCS_PropIndex][2] = {}
					VCS_DataArray[1][VCS_PropIndex][3] = e:GetModel()
					VCS_DataArray[1][VCS_PropIndex][1][1] = e:GetPos().x
					VCS_DataArray[1][VCS_PropIndex][1][2] = e:GetPos().y
					VCS_DataArray[1][VCS_PropIndex][1][3] = e:GetPos().z
					VCS_DataArray[1][VCS_PropIndex][2][1] = e:GetAngles().p
					VCS_DataArray[1][VCS_PropIndex][2][2] = e:GetAngles().y
					VCS_DataArray[1][VCS_PropIndex][2][3] = e:GetAngles().r
					VCS_PropIndex = VCS_PropIndex + 1
				end
			end
		end
		if (vcs_Doors) then
			--print("CRASHSAVE: GOING THROUGH DOORS")
			for i, e in pairs(VCS_GEnt) do
				if ((e:GetClass() == "func_door") or (e:GetClass() == "prop_door_rotating")) and e:getDoorOwner() == v then
					--print("CRASHSAVE: ENT:".. tostring( e ))
					table.insert(VCS_DataArray[2], tostring( e ))
				end
			end
		end
		if (vcs_Jobs) then
			--print("CRASHSAVE: GOING THROUGH JOBS")
			VCS_DataArray[3] = v:Team()
		end
		if (vcs_Weapons) then
			for i, e in pairs(v:GetWeapons()) do
				VCS_DataArray[4][e:GetClass()] = { v:GetAmmoCount( e:GetPrimaryAmmoType() ), e:GetPrimaryAmmoType()}
				e:GetClass()
			end
		end
		VCS_DataArray[5] = os.time()
		--print("CRASHSAVE: SAVING FILE")
		local VCS_TableToJson = util.TableToJSON( VCS_DataArray )
		file.Write( "crashsave/"..v:UniqueID()..".txt", VCS_TableToJson )
		--PrintTable(VCS_DataArray)
		--print("CRASHSAVE: SAVE FILE END")
	end
end )