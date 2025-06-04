pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- shmup 
-- by: kaero

-- todo
-- -game flow
-- -music
-- -multiple enemies
-- -big enemies
-- -enemy bullet pattern
-- --static shot
-- --aimed shot
-- --scatter shot
-- --circ pattern shot


-- -enemy scheduler
-- -levels


function _init()
	cls(0)
	debug = false
	mode  = "start"
	blinkt= 1
	
	t = 0
end

function _update()
	
	t += 1
	blinkt+=1
	wave = 1
	
	if mode=="game" then
		update_game()
	elseif mode=="start" then
		update_start()
	elseif mode=="wavetext" then
		update_wave()
	elseif mode=="over" then
		update_over()
	end
end

function _draw()
	if mode=="game" then
		draw_game()
	elseif mode=="start" then
		draw_start()
	elseif mode=="over" then
		draw_over()
	end
end

function startgame()
	
	mode="game"
	t = 0 --reset frametime
	
	--object ship
	ship={}
	ship.x=64
	ship.y=64
	ship.sx=0
	ship.sy=0
	ship.spr=2
	--flame
	flamespr=5
	
	bultimer=0
	
	muzzle=0
	
	score=0
	lives=4
	invul=0
	
	--stars init
	stars={}
	for i=1,100 do
		local newstar={}
		newstar.x=flr(rnd(128))
		newstar.y=flr(rnd(128))
		newstar.spd=rnd(1.5)+0.5
		add(stars,newstar)
	end
	
	buls    ={}
	enemies ={}
	explods ={}
	parts   ={}
	shwaves ={}
	
	spawnen()
	
end
-->8
-- tools

function starfield()
	for i=1,#stars do
		
		local mystar=stars[i]
		local scol=6
		
		if mystar.spd<1 then
			scol=1
		elseif mystar.spd<1.5 then
			scol=13
		end
		
		pset(mystar.x,mystar.y,scol)
	end
end

function animatestars()
	for i=1,#stars do
		local mystar=stars[i]
		mystar.y=mystar.y+mystar.spd
		if mystar.y>128 then
			mystar.y=mystar.y-128
			mystar.x=rnd(127)
		end
	end
end

function blink()
	local banim={5,5,5,5,5,5,5,5,5,5,5,6,6,7,7,6,6,5}
	
	if blinkt>#banim then
		blinkt=1
	end
	
	return banim[blinkt]
end

function drwmyspr(myspr)
	spr(myspr.spr,myspr.x,myspr.y)
end

function col(a,b)
	-- lots of math
	-- only for 1 tile object
	
	-- a part
	local a_lef = a.x
	local a_top = a.y
	local a_rig = a.x+7
	local a_bot = a.y+7
	-- b part
	local b_lef = b.x
	local b_top = b.y
	local b_rig = b.x+7
	local b_bot = b.y+7
	
	if a_top>b_bot then return false end
	if b_top>a_bot then return false end
	if a_lef>b_rig then return false end
	if b_lef>a_rig then return false end
	
	return true
end

function spawnen()
	local myen={}
	myen.x     =rnd(120)
	myen.y     =-8
	myen.spr   =21
	myen.hp    = 5
	myen.flash = 0
	
	add(enemies,myen)
end

function explode(expx,expy,isblue)
	--main particle
	local myp = {}
	myp.x  = expx
	myp.y  = expy
	myp.sx = 0
	myp.sy = 0
	myp.age= 0
	myp.size = 10
	myp.maxage = 0
	
	myp.blue = isblue
	
	add(parts,myp)
	
	--scatter particle
	for i=1,30 do
		local myp = {}
		myp.x  = expx
		myp.y  = expy
		myp.sx = (rnd(2)-1)*2
		myp.sy = (rnd(2)-1)*2
		myp.age= rnd(2)
		myp.size = 1+rnd(4)
		myp.maxage = 10 + rnd(10)
		
		myp.blue = isblue
		
		add(parts,myp)
	end
	
	--spark particle
	for i=1,20 do
		local myp = {}
		myp.x  = expx
		myp.y  = expy
		myp.sx = (rnd(2)-1)*5
		myp.sy = (rnd(2)-1)*5
		myp.age= rnd(2)
		myp.size = 1+rnd(4)
		myp.maxage = 10 + rnd(10)
		myp.spark=true
		
		myp.blue = isblue
		
		add(parts,myp)
	end
	
	big_shwave(expx,expy)
end

function particle()
	
end

function page_red(page)
	local col = 7
	
	if page>5 then
		col = 10
	end
	if page>7 then
		col =  9
	end
	if page>10 then
		col =  8
	end
	if page>12 then
		col =  2
	end
	if page>15 then
		col =  5
	end
	
	return col
end

function page_blue(page)
	local col = 7
	
	if page>5 then
		col = 6
	end
	if page>7 then
		col =  12
	end
	if page>10 then
		col =  13
	end
	if page>12 then
		col =  1
	end
	if page>15 then
		col =  1
	end
	
	return col
end

function smol_shwave(shx,shy)
	local mysw = {}
	mysw.x  = shx
	mysw.y  = shy
	mysw.r  = 3
	mysw.tr = 6
	mysw.col= 9
	mysw.spd= 1
	add(shwaves,mysw)
end

function big_shwave(shx,shy)
	local mysw = {}
	mysw.x  = shx
	mysw.y  = shy
	mysw.r  = 3
	mysw.tr = 25
	mysw.col= 7
	mysw.spd= 3.5
	add(shwaves,mysw)
end

function smol_spark(sx,sy)
	--for i=1,2 do
	local myp = {}
	myp.x  = sx
	myp.y  = sy
	myp.sx = (rnd()-.5)*8
	myp.sy = (rnd()- 1)*3
	myp.age= rnd(2)
	myp.size = 1+rnd(4)
	myp.maxage = 10 + rnd(10)
	myp.spark=true
	
	myp.blue = isblue
	
	add(parts,myp)
	--end
end
-->8
--update

function update_game()
	--controls
	ship.sx=0
	ship.sy=0
	ship.spr=2
	if btn(0) then
		ship.sx=-2
		ship.spr=1
	end
	if btn(1) then
		ship.sx=2
		ship.spr=3
	end
	if btn(2) then
		ship.sy=-2
	end
	if btn(3) then
		ship.sy=2
	end
	if btnp(4) then
		--temp
	end
	
	if btn(5) then
		if bultimer <= 0 then
			local newbul={}
			newbul.x   = ship.x
			newbul.y   = ship.y - 3
			newbul.spr = 16
			add(buls,newbul)
			sfx(0)
			muzzle=6
			bultimer=4
		end
	end
	bultimer-=1
	
	--moving the ship
	ship.x+=ship.sx
	ship.y+=ship.sy
	
	--checking if we hit the edge
	if ship.x>120 then
		ship.x=120
	end
	if ship.x<0 then
		ship.x=0
	end
	-- custom clipping
	ship.y = mid(0,ship.y,120)
	
	--move the bullets
	for i=#buls,1,-1 do
		local mybul=buls[i]
		mybul.y=mybul.y-4
		if mybul.y<-8 then
			del(buls,mybul)
		end
	end
	
	--moving enemies
	for myen in all(enemies) do
		myen.y+=1
		myen.spr+=0.4
		if myen.spr>=25 then
			myen.spr=21
		end
		if myen.y>128 then
			del(enemies,myen)
			spawnen()
		end
	end
	
	--collision bul x enemies
	for myen in all(enemies) do
		for mybul in all(buls) do
			if col(myen,mybul) then
				
				del(buls,mybul)
				
				smol_shwave(
					mybul.x+4,
					mybul.y+4
				)
				smol_spark(
					mybul.x+4,
					mybul.y+4
				)
				myen.hp -= 1
				sfx(3)
				myen.flash = 2
				-- hit score
				score+=10
				
				-- on death
				if myen.hp <= 0 then
					del(enemies,myen)
					sfx(2)
					score+=100
					spawnen()
					explode(myen.x+4,myen.y+4)
				end
			end
		end
	end
	
	--collision ship x enemies
	
	if invul <= 0 then
		for myen in all(enemies) do
			if col(myen,ship) then
				explode(ship.x+4,ship.y+4,true)
				lives-=1
				sfx(1)
				invul=60
			end
		end
	else
		invul -= 1
	end
	
	--game over
	if lives <= 0 then
		mode = "over"
		return --kill function
	end
	
	--animate flame
	flamespr=flamespr+1
	if flamespr>9 then
		flamespr=5
	end
	
	--animate mullze flash
	if muzzle>0 then
		muzzle=muzzle-1
	end
	
	
	animatestars()
end

function update_start()
	
	if btnp(4) or btnp(5) then
		startgame()
	end
end

function update_over()
	if btnp(4) or btnp(5) then
		mode="start"
	end
end
-->8
-- draw

function draw_game()
	cls(0)
	starfield()
	
	--drawing ship
	if invul<=0 then
		drwmyspr(ship)
		spr(flamespr,ship.x,ship.y+8)
	else
		--invul state
		if sin(t/5) < 0.1 then
			drwmyspr(ship)
			spr(flamespr,ship.x,ship.y+8)
		end
	end
	
	--drawing enemies
	for myen in all(enemies) do
		--flash condition
		if myen.flash > 0 then
			myen.flash -= 1
			--set all color white
--			for i=1,15 do
--			 pal(i,7)
--			end
			--custom color
			pal(11,7)
			pal(3,10)
			pal(1,9)
		end
		--draw normal
		drwmyspr(myen)
		--reset color
		pal()
	end
	  
	--drawing bullets
	for mybul in all(buls) do
		drwmyspr(mybul)
	end
	 
	if muzzle>0 then
		circfill(ship.x+3,ship.y-2,muzzle,7)
	end
	
	-- drawing shockwaves
	for mysw in all(shwaves) do
		circ(mysw.x,mysw.y,mysw.r,mysw.col)
		mysw.r+=mysw.spd
		if mysw.r>mysw.tr then
			del(shwaves,mysw)
		end
	end
	
	-- drawing particles
	for myp in all(parts) do
		local pc = 7
		
		if myp.blue then
			pc = page_blue(myp.age)
		else
			pc = page_red(myp.age)
		end
		
		if myp.spark then
			pset(myp.x,myp.y,7)
		else
			circfill(
				myp.x,myp.y,
				myp.size,pc
			)
		end
		--particle movement
		myp.x+=myp.sx
		myp.y+=myp.sy
		
		myp.sx*=0.85
		myp.sy*=0.85
		
		--decay logic
		myp.age+=1
		if myp.age > myp.maxage then
			myp.size-=0.5
			if myp.size<0 then
				del(parts,myp)
			end
		end
	end
	
	
	print("score:"..score,40,1,8)
	
	for i=1,4 do
		if lives>=i then
			spr(13,i*9-8,1)
		else
			spr(14,i*9-8,1)
		end 
	end
	
	if debug == true then
		print("bul c:"..#buls,1,10,7)
	end
end

function draw_start()
	--print(blink())
	cls(1)
	 
	print("my awesome shmup",34,40,12) 
	print("press any key to start",20,80,blink())
end

function draw_over()
	cls(8)
	print("game over",48,40,2) 
	print("press any key to continue",16,80,blink())
end
__gfx__
00000000000550000005500000055000000000000000000000000000000000000000000000000000000000000000000000000000022002200220022000000000
0000000000577500005775000057750000000000000770000007700000077000028778200007700000000000000000000000000028e228822002200200000000
007007000057750000577500005775000000000000877800008778000287782008888880008778000000000000000000000000002e7e88822000000200000000
0007700000577650016776100567750000000000002882000028820000888800002222000088880000000000000000000000000028e888822000000200000000
0007700005e87750567e87650577e850000000000002200000088000002882000000000000288200000000000000000000000000028888200200002000000000
00700700058277505778277505778250000000000000000000088000000220000000000000088000000000000000000000000000002882000020020000000000
0000000001d57d100175571001d75d10000000000000000000000000000000000000000000022000000000000000000000000000000220000002200000000000
00000000001dd100001dd100001dd100000000000000000000088000000000000000000000000000000000000000000000000000000000000000000000000000
009999000000000000000000000000007ab31000030000300b3003b00b3003b00300003000000000000000000000000000000000000000000000000000000000
09aaaa9000000000000000000000000000000000b303303b0303303003033030b303303b00000000000000000000000000000000000000000000000000000000
9aa77aa900000000000000000000000000000000003ab300003ab300003ab300003ab30000000000000000000000000000000000000000000000000000000000
9a7777a900000000000000000000000000000000003b1300003b1300003b1300003b130000000000000000000000000000000000000000000000000000000000
9a7777a900000000000000000000000000000000b303303bb303303bb303303bb303303b00000000000000000000000000000000000000000000000000000000
9aa77aa90000000000000000000000000000000003000030b300003b030000300300003000000000000000000000000000000000000000000000000000000000
09aaaa9000000000000000000000000000000000b300003b30000003b300003b0b3003b000000000000000000000000000000000000000000000000000000000
00999900000000000000000000000000000000000030030030000003003003000003300000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000003300000033000000330000003300000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000003bb300003bb300003bb300003bb30000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000003babb3003babb3003babb3003babb3000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000003bbb13003bbb13003bbb13003bbb13000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000303b1303003b1300003b1300003b130000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000b303303b03333330003333000333333000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003b3003b33bb33bb303bbbb303bb33bb300000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000300003003300330033333300330033000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000011110000111100001111000011110000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000001bbbb1001bbbb100133331001bbbb1000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000001b7abb311b7abb3113ab33111b7abb3100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000001baab3b11baab3b113bb31311baab3b100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000001bbbb3b11bbbb3b1133331311bbbb3b100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000001bbb33b11bbb33b1133311311bbb33b100000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000133bb100133bb10011133100133bb1000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000011110000111100001111000011110000000000000000000000000000000000000000000000000000000000
__sfx__
010100003452032520305202e5202b520285202552022520205201b52018520165201352011520010000f5200c5200a5200852006520055200452003520015200052000000000000000000000000000100000000
01010000376373063729637276371f6371d637186371663713637116370f6370f6370c6370c6370c6370a6370a6370c6370c6370f637116371163700007000070000700007000070000700007000070000700007
000200001c63338633166330e63315533276331753308733077330673300603006030765307653036530360300603006530365305653076030760305653036030360303653006530265306653036030865304653
010100000f61712617286370060706607006070060700607006070060700607006070060700607006070060700607006070060700607006070060700607006070060700607006070060700607006070060700607
