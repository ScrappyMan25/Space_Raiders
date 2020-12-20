-- space raider
-- by scrappyman25
-- Note: this is not the Source - That can be found of the Pico-8 website or by using the cartrdige. This is just the Code segment in a Lua File for code formated readability.

 --initialization
 function _init()
     hi = 0 -- high score variable
     gamestate = {{init_menu, update_menu, draw_menu}, {initgame, updategame, drawgame},{init_end, update_end, draw_end}}
     state = 1
     gamestate[state][1]()
     counter = 0 -- frame counter
 end

 function _update60()
     gamestate[state][2]()
     counter += 1
 end

 function _draw()
     cls()
     gamestate[state][3]()
 end
 -->8
 --game
 function initgame()
     --game objects
     stars_init()
     ship_init()
     bullets_init()
     orb_init()
     asteroid_init()
     enemies_init()

     function collision( hb1, hb2 )
         -- collision of two hitboxes
         if hb1.x + hb1.w < hb2.x then 
             return false
         end
        
         if hb1.y + hb1.h < hb2.y then
             return false
         end
        
         if hb2.x + hb2.w < hb1.x then
             return false
         end
        
         if hb2.y + hb2.h < hb1.y then
             return false
         end
        
         return true
     end
 end

 function updategame()
     -- update game objects
     anim_counter()
     ship.update()
     stars.update()
     bullets.update()
     asteroid.update()
     enemies.update()
     collision_check()
    
     --end game coundition
     if ship.lives == 0 then 
         sfx(6)
         state = 3
         gamestate[state][1]()
     end
 end


 function collision_check()
     bullets.collision()
     asteroid.collision()
     enemies.bullets.collision()
     if orb.type > 0 then orb.collision() end
 end

 function drawgame()
     map(0,0,0,0,16,16)
     print ("score:"..flr(ship.score), 45, 2, 7)

     --draw game objects
     ship.draw()
     stars.draw()
     bullets.draw()
     ship.heart()
     asteroid.draw()
     enemies.draw()

     --orb draw and decay timer setups
     if orb.type > 0 then orb.draw() end
     if bullets.type == 1 then orb.bullet_decay() end
     if ship.shield == 1 then orb.shield_decay() end
 end

 function anim_counter()
     --gives 0,1 every 5 frames; shield animation counter
     two_counter = (flr(counter/5)%2)

     --gives 0-14 every 60 frames(1second); spl. eff. spawn counter.
     orb.counter = (flr(counter/60)%15)
     --orb spawn counditions
     if state < 3 then
         if orb.counter == 2 then orb.type = 0 end
         if orb.counter == 14 then 
             counter += 60
             orb.spawn()
         end
    
         if (flr(enemies.counter/60)%30) == 29 then 
             enemies.counter = 0
             enemies.spawn()
         end
     end
 end
 -->8
 --game objects

 function ship_init()
     --ship initialization
     ship = {x=55,y=55,cooldown=10,direction=1,shield=0,f ={ {1,3,5,7}, {64,68,72,76}}, lives = 3, score = 0}

         --ship movement and shooting
         function ship.update()
             if ship.lives > 0 then ship.score += 0.01 end
             if ship.score > hi then hi = ship.score end
             ship.cooldown -=1
             if ship.lives > 0 then
                 if btn(4) then
                     ship.fire(ship.x+4, ship.y+4, ship.direction)
                 end

                 if btn(0) and ship.x > 0 then
                     ship.x -= 1
                     ship.direction = 2
                 end
                  
                 if btn(1) and ship.x < 112 then
                     ship.x += 1
                     ship.direction = 4
                 end

                 if btn(2) and ship.y > 8 then
                     ship.y -= 1
                     ship.direction = 1
                 end

                 if btn(3) and ship.y < 112 then
                     ship.y += 1
                     ship.direction = 3
                 end
             end
         end

         --draw ship
         function ship.draw()
             if ship.lives > 0 then
                 spr(ship.f[ship.shield+1][ship.direction] +ship.shield*two_counter*2, ship.x,ship.y,2 ,2 )
                 else spr(46,ship.x,ship.y, 2,2)
             end
         end

         function ship.fire(x,y,d)
             if ship.cooldown > 0 then
                 return
             end
             add (bullets.shoot, {x=x, y=y, d=d})
             sfx(3)
             ship.cooldown = 15
         end

         --hearts of ship
         function ship.heart()
             local temp = ship.lives
             while temp > 0 do
                 spr (12,(temp-1)*8,0)
                 temp -=1
             end
         end
 end

 --stars initialisation
 function stars_init()
     -- body
     stars={color = {13,6,7}, spawn = {}}
    
     --t is total no. of stars; needs to be initialised only once.
     local t = 25

     --adds 25 stars and initiates them with a color, speed and random x and y coords
     for i = 1, t do
         local a = flr(rnd(3)+1)
         local color = stars.color[a]
         add(stars.spawn,{ x = rnd(128), y = rnd(128), speed = a, color = color})
     end


     function stars.draw()
         for s in all(stars.spawn) do
             pset(s.x, s.y, s.color)
         end
     end


     function stars.update()
         for s in all(stars.spawn) do
             s.y += s.speed

             if(s.y >= 128) then
              s.y = 0
              s.speed =rnd(3)+1
             end
         end       
     end
 end


 function bullets_init()
     --bullet table initialization
      bullets = {shoot = {}, type = 0, f = {11,41}}
          --type 0 is normal; 1 is pink; f is for sprites
          function bullets.update()
             for b in all(bullets.shoot) do
                 if b.d == 1 then
                     b.y -= 1
                     if b.y < 8 then
                         del (bullets.shoot,b)
                     end
                 end
                 if b.d == 3 then
                     b.y += 1
                     if b.y > 120 then
                         del (bullets.shoot,b)
                     end
                 end
                 if b.d == 2 then
                     b.x -= 1
                     if b.x < 0 then
                         del (bullets.shoot,b)
                     end
                 end
                 if b.d == 4 then
                     b.x += 1
                     if b.x > 120 then
                         del (bullets.shoot,b)
                     end
                 end
             end
         end

         function bullets.draw()
             for b in all(bullets.shoot) do
                 spr(bullets.f[bullets.type + 1],b.x,b.y)
             end
         end


          function bullets.collision()
             --bullet hitting asteroid
             for b in all(bullets.shoot) do
                     local hb1 = {x= b.x + 2,y=b.y+2,w=2,h=2}
                
                 --asteroids
                 for a in all(asteroid.spawns) do
                     local hb2 = {x=a.x,y=a.y,w=a.ss*8,h=a.ss*8}
                    
                     if collision(hb1, hb2) then
                         sfx(2)
                         a.health -= (1 + bullets.type*2) 
                         ship.score += (1 + bullets.type*2)
                         del(bullets.shoot,b)
                     end
                 end

                 --enemies
                 for e in all(enemies.spawns) do
                     local hb2 = {x = e.x, y = e.y, w = 12, h = 12}
                     if collision(hb1, hb2) then
                         sfx(2)
                         e.lives -= (1+ bullets.type*2)
                         ship.score += (1 + bullets.type*2)
                         del(bullets.shoot,b)
                     end
                 end
                
                 --enemies bullets
                 for eb in all (enemies.bullets) do
                     local hb2 = {x = eb.x+2, y = eb.y+2, w = 2, h = 2}
                     if collision(hb1,hb2) then
                         ship.score += 3
                         del(bullets.shoot,b)
                         del(enemies.bullets,eb)
                     end
                 end

             end
         end
 end

 function orb_init()
     --special effect orb initialization
     orb = {x=0 , y=0, type=0, counter= 0, f = {25,9,12}, shield_count = 0, bullets_count = 0}
    
         --spawn orb (run under anim_counter spawns every 15 seconds)
         function orb.spawn()
             orb.x = rnd (110)
             orb.y = rnd (100) + 8
            
             --spawn rate deciding variable
             local t = rnd()
            
             --40% chance for shield 
             if t < 0.4 then 
                 orb.type = 1
            
             --40% chance for heart 
             elseif t < 0.8 then
                 orb.type = 3
            
             --20% for bullets type 1 
             else 
                 orb.type = 2
             end
         end

         --draw orb
         function orb.draw()
             spr(orb.f[orb.type] + two_counter, orb.x, orb.y)
         end

         --orb collision
         function orb.collision()
             local hb1 = {x=orb.x, y=orb.y, w=4, h=4}
             local hb2 = {x=ship.x,y=ship.y,w=16,h=16}
                 if collision(hb1, hb2) then

                     sfx(1)
                     if orb.type == 1 then 
                         --looped shield sfx
                         sfx(7)
                         ship.shield = 1 

                         --reset decay counter to zero
                         orb.shield_count = 0
                     end
                     if orb.type == 2 then 
                         bullets.type = 1

                         --reset decay counter to zero
                         orb.bullets_count = 0 
                     end
                     if orb.type == 3 then ship.lives += 1 end 
                    
                     orb.type=0
                 end
         end

         --bullet effect decay timer
         function orb.bullet_decay()
             --setup incrementing counter 
             --since its in _draw() it runs 30 times per seconds
             orb.bullets_count += 1

                 --sets up duration and sprite since there are 8 sprites.
                 if orb.bullets_count < 120*8 then
                     spr(127 - flr(orb.bullets_count/120), 8*15, 0)
                 else
                     bullets.type = 0
                     orb.bullets_count = 0
                     sfx(0)
                 end
         end
        
         --shield effect decay timer
         function orb.shield_decay()
             --setup incrementing counter 
             --since its in _draw() it runs 30 times per seconds
             orb.shield_count += 1

                 --sets up duration and sprite since there are 8 sprites.
                 if orb.shield_count < 60*8 then
                     spr(111 - flr(orb.shield_count/60), 8*14, 0)
                 else
                     ship.shield = 0
                     sfx(-1, -1)
                     orb.shield_count = 0
                     sfx(0)
                 end
         end


 end

 function asteroid_init()
     --asteroid 
     asteroid = {sprites = {96,98,100,102}, spawns = {}}
        
         function asteroid.collision()
             for a in all(asteroid.spawns) do
                 local hb1 = {x=ship.x,y=ship.y,w=12,h=12}
                 local hb2 = {x=a.x,y=a.y,w=a.ss*8,h=a.ss*8}
                    
                 if collision(hb1, hb2) then
                     del(asteroid.spawns,a)
                     --invulnerability if shield
                     if ship.shield == 1 then sfx(18)
                         else 
                             ship.lives -= 1 
                             sfx(4)
                     end

                 end
             end
         end

         --constructor for asteroid spawning
         function asteroid.setup()
             local t, random, across, shift, s = rnd(), rnd(128), 0.2+rnd(0.5), -0.5+rnd(1.0),  asteroid.sprites[flr(rnd(4)+1)]   

             if t <= 0.25 then
                 return {x = -16, y = random, xspeed = across, yspeed = shift, sprite = s, ss= 2, health = 3}
            

             elseif t <= 0.50 then
                 return {x = random, y = -16, xspeed = shift, yspeed= across, sprite = s, ss= 2, health = 3}
            
            
             elseif t <= 0.75 then
                 return {x= 128+16, y= random, xspeed = -across, yspeed = shift, sprite = s, ss= 2, health = 3}
            
            
             elseif t <= 1.00 then
                 return {x= random, y= 128+16, xspeed= shift, yspeed= -across, sprite = s, ss= 2, health = 3}
             end
         end

         function asteroid.update()
             --makes asteroid spawn rate a function of the score
             local spawnrate = (flr(ship.score))/10000 + 0.01
             if rnd() < spawnrate then
                 add (asteroid.spawns, asteroid.setup())
             end

             --asteroid.spawn()
             for a in all (asteroid.spawns) do
                 a.x += a.xspeed
                 a.y += a.yspeed
                 --
                 -- if asteroids destroyed
                 if a.health <= 0 then 
                     ship.score += 5
                     del(asteroid.spawns, a)
                 end

                 -- despawn radius larger than spawn radius
                 if a.x > 128+16+8 or a.x < 0-16-8 or a.y > 128+16+8 or a.y < 0-16-8 then
                     del(asteroid.spawns, a)
                 end
             end
         end

         function asteroid.draw()
             for a in all (asteroid.spawns) do
                 spr (a.sprite, a.x, a.y, a.ss, a.ss)
             end
         end
 end

 function enemies_init()
     enemies = {spawns = {}, f = {33, 35, 37, 39}, counter = 0, bullets = {}}
        

         function enemies.spawn()
             add (enemies.spawns, enemies.setup())
         end


         function enemies.movement()
             --0 , 1, l, r; 2,3,u,d
             for e in all(enemies.spawns) do
                 if e.m == 0 then e.x -= e.speed end
                 if e.m == 1 then e.x += e.speed end
                 if e.m == 2 then e.y -= e.speed end
                 if e.m == 3 then e.y += e.speed end
             end
         end

         function enemies.update()
             enemies.counter += 1
             enemies.movement()
             enemies.bullets.update()

             for e in all(enemies.spawns) do
                 e.cooldown -= 1
                 if e.lives <= 0 then del(enemies.spawns, e) end
                 if e.direction%2 == 1 then 
                     if e.x >= 126 then e.m = 0 end
                     if e.x <= 2 then e.m = 1 end
                     if ship.x + 8 < e.x + 16 and ship.x + 8 > e.x and e.cooldown <= 0 then 
                         enemies.fire(e.x+4, e.y+4, e.direction) 
                         e.cooldown = 20
                     end
                 else 
                     if e.y >= 126 then e.m = 2 end
                     if e.y <= 10 then e.m = 3 end
                     if ship.y + 8 < e.y + 16 and ship.y + 8 > e.y and e.cooldown <= 0 then 
                         enemies.fire(e.x+4, e.y+4, e.direction) 
                         e.cooldown = 20
                     end
                 end

             end
         end

         function enemies.draw()
             --body           
             enemies.bullets.draw()
             for e in all(enemies.spawns) do
                 spr(e.f, e.x, e.y, e.ss, e.ss)
             end
         end

         function enemies.setup()
             -- body
             local t = rnd()
             local function spd() return (rnd(0.5) + 0.3) end
             local function life() return (flr(rnd(7) + 3)) end

             --top
             if t <= 0.25 then 
                 return 
                 {
                     x = 10,
                     y = 126-16,
                     f = enemies.f[1],
                     ss = 2,
                     speed = spd(),
                     direction = 1,
                     lives = life(),
                     m=1,
                     cooldown=20
                 }
            
            
             --bottom           
             elseif t <= 0.50 then 
                 return 
                 {
                     x = 10,
                     y = 10,
                     f= enemies.f[3],
                     ss = 2,
                     speed = spd(),
                     direction = 3,
                     lives = life(),
                     m=1,
                     cooldown=20
                 }

             --left           
             elseif t <= 0.75 then 
                 return 
                 {
                     x = 126-16,
                     y = 126,
                     f = enemies.f[2],
                     ss = 2,
                     speed = spd(),
                     direction = 2,
                     lives = life(),
                     m=2,
                     cooldown=20
                 }
            
             else 
                 return 
                 {
                     x = 2,
                     y = 126,
                     f = enemies.f[4],
                     ss = 2,
                     speed = spd(),
                     direction = 4,
                     lives = life(),
                     m=2,
                     cooldown=20
                 }
             end
         end
        
         function enemies.fire(x, y, d)
             -- body
             add (enemies.bullets, {x=x, y=y, d=d})
             sfx(3)
         end

             --enemies.bullets.update
             function enemies.bullets.update()
                 -- body
                 for b in all(enemies.bullets) do
                     if b.d==1 then
                         b.y -= 1
                         if b.y < 8 then del(enemies.bullets, b) end
                     end
                    
                     if b.d==2 then
                         b.x -= 1
                         if b.x < 0 then del(enemies.bullets, b) end
                     end
                    
                     if b.d==3 then
                         b.y += 1
                         if b.y > 128 then del(enemies.bullets, b) end
                     end
                    
                     if b.d==4 then
                         b.x += 1
                         if b.x > 128 then del(enemies.bullets, b) end 
                     end
                 end
             end
            
             --enemies.bullets.draw
             function enemies.bullets.draw()
                 -- body
                 for b in all(enemies.bullets) do
                     spr (27, b.x, b.y)
                 end
             end

             --enemies.bullets.collision
             function enemies.bullets.collision()
                 for eb in all(enemies.bullets) do
                     local hb1 = {x = eb.x + 2, y= eb.y + 2, w = 2, h = 2}
                     local hb2 = {x = ship.x, y = ship.y, w = 12, h = 12 }
                     if collision(hb1,hb2) then 
                             del(enemies.bullets, eb)
                         if ship.shield == 1 then 
                             sfx(18)  
                         else 
                             ship.lives -=1
                             sfx(2)
                         end
                     end
                 end
             end


 end
 -->8
 --menu
 function init_menu()
     -- body
     ship_init()
     orb_init()
     asteroid_init()
     enemies_init()
     music(1)
     --for asteroids to spawn in the home screen
     ship.score = 1
 end

 function update_menu()
     -- body
     anim_counter()
     asteroid.update()
    
     --z to play game
     if btn(4) then
         music(-1)
         state = 2
         sfx(5)
         music(7)
         gamestate[state][1]() 
         --delete all asteroids in spawn screen
         for a in all (asteroid.spawns) do
             del (asteroid.spawns, a)
         end
     end
 end

 function draw_menu()
     -- body
     map(16,0,0,0,16,16)
     print("high score:"..flr(hi), 30, 10, 7)
     print("game: scrappyman25", 10, 112, 7)
     print("music: gruber", 10, 120, 7)
    
     --blinking play prompt
     if two_counter == 1 then 
         print("press z to play!!", 32, 80, 7) 
         print("good luck", 45, 90, 7)
     end
    
     asteroid.draw()
     if orb.type > 0 then orb.draw() end
 end

 -->8
 --end
 function init_end()
     -- body
 end
 function update_end()
     -- body
     anim_counter()
     if btn(5) then
         state = 1
         sfx(5)
         gamestate[state][1]() 
     end

 end

 function draw_end()
     map(32,0,0,0,16,16)
     print("press x to return \n to the main menu", 32, 108, 7)
     print("high score:"..flr(hi), 32, 80, 7) 
     print("score:"..flr(ship.score), 32, 90, 7) 

     --"new" rainbow banner
     if flr(hi) == flr(ship.score) then
         if two_counter == 1 then
             print("new", 28, 75, flr(rnd(16)))
         end
     end
 end
