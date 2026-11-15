extends 'res://campaign/tests/keyboard_tour.gd'
const Daily=preload('res://campaign/daily_data.gd')
var minigames:=0
func go_room(destination:String)->bool:
 for hop in 8:
  if Mission.room==destination:return true
  var next:String='corridor'
  if Mission.room=='exterior':next='airlock'
  elif Mission.room=='hygiene':next='bedroom'
  elif Mission.room=='corridor':next='airlock' if destination=='exterior' else 'bedroom' if destination=='hygiene' else destination
  elif Mission.room=='airlock' and destination=='exterior':next='exterior'
  elif Mission.room=='bedroom' and destination=='hygiene':next='hygiene'
  for door in game.world.doors:
   if door.to!=next:continue
   if not await walk_to(door.at):return false
   await press(KEY_E);await frame();await advance_lines()
   if is_instance_valid(game.ui.active_game) and game.ui.active_game.task.id=='preflight3':
    await solve()
    await press(KEY_E);await frame();await advance_lines()
   break
 fail('Room unreachable: '+destination);return false
func hold_e(seconds:float)->void:
 var event:=InputEventKey.new();event.physical_keycode=KEY_E;event.keycode=KEY_E;event.pressed=true;Input.parse_input_event(event)
 for i in int(seconds*60)+2:await frame()
 event=InputEventKey.new();event.physical_keycode=KEY_E;event.keycode=KEY_E;event.pressed=false;Input.parse_input_event(event)
 await frame()

func pick(index:int)->void:
 var activity=game.ui.active_game
 if not is_instance_valid(activity):fail('Missing activity');return
 for i in 10:
  if activity.cursor==index:break
  await press(KEY_RIGHT)
 await press(KEY_ENTER)

func solve()->void:
 var a=game.ui.active_game
 minigames+=1
 if a.kind=='pipes':
  await press(KEY_R);await advance_lines()
 match a.kind:
  'scan','field','grow':
   for i in 3:await pick(i)
  'cook':
   for i in [0,2,4]:await pick(i)
   await pick(1)
  'search':await pick(1);await pick(4);await pick(0)
  'calibrate':
   for i in 4:await press(KEY_RIGHT)
   # Right adjusts the value; confirm is the fourth control.
   await press(KEY_ENTER)
  'air':
   await pick(0)
   for i in 3:
    for j in 6:
     if a.cursor==i:break
     await press(KEY_RIGHT)
    await hold_e(0.9)
   for i in 7:await press(KEY_RIGHT)
   await hold_e(1.1)
   await pick(0)
  'clean':
   for i in 3:
    for j in 6:
     if a.cursor==i:break
     await press(KEY_RIGHT)
    await hold_e(0.9)
   await pick(0)
  'suit':
   await pick(branch)
   for i in 3:await pick(i)
  'assemble':
   for i in 3:await pick(i)
   for i in 3:await pick(i)
  'pipes':
   await pick(branch)
   for i in 4:
    for j in [3,2,1,3][i]:await pick(i)
   await pick(4);await pick(1);await pick(0)
  'rhythm':
   await press(KEY_DOWN)
   for i in 8:await press(KEY_ENTER)
  'solar':await pick(branch)
  'lock':
   for i in 3:await pick(i)
  'shelter':
   for i in 6:await pick(i)
  'chat':await pick(0)
 await advance_lines()
 if not game.ui.stack.is_empty() and not Mission.emergency.is_empty():
  if not await choose("Got it · Begin"):return

func select_card(id:String)->void:
 if game.ui.stack.is_empty():await press(KEY_T)
 var data:=Daily.find(id)
 var text:String=('◇ ' if data.optional else '★ ')+data.title+" · %d block(s) · %s"%[data.cost,game.Catalog.ROOMS[data.room]]
 if not await choose(text):return
 if id=='prepare':
  if not await choose("Storage · Find a spare dust filter" if branch==0 else "Laboratory · Check the instrument"):return

func do_current()->void:
 var t:=Mission.current()
 if not await go_room(t.room):return
 var found:Dictionary={}
 for entry in game.world.entries:
  if entry.id==t.target:found=entry;break
 if found.is_empty():fail('Missing target '+t.target);return
 if not await walk_to(found.at):return
 await press(KEY_E)
 await advance_lines()
 if not is_instance_valid(game.ui.active_game):fail('No game for '+t.id);return
 await solve()
 if t.id==Mission.selected:fail('Activity did not complete '+t.id)

func run(g:Node)->void:
 game=g
 for selected in 2:
  branch=selected;game.start_new()
  if not await choose("Skip landing"):return
  await advance_lines()
  if not await go_room('shelter'):return
  await advance_lines()
  if not await choose("Listen to the crew"):return
  if not await choose('Moony'):return
  await advance_lines()
  for day_number in 3:
   var ids:Array={0:['checkup','meal','prepare'],1:['suit_check','eva2','dust_return','chat2'],2:['water','exercise','grow3','eva3']}[day_number]
   for id in ids:
    print('DAILY TOUR ',branch,' ',id)
    await select_card(id)
    await do_current()
    while not Mission.selected.is_empty():await do_current()
    if id=='checkup':
     await press(KEY_M)
     if not await choose("Close map"):return
    if id=='water':
     await press(KEY_ESCAPE)
     if not await choose("Save and return to menu"):return
     if not await choose("Continue"):return
   await press(KEY_T)
   if not await choose("End the day · Dinner and a signal"):return
   if not await go_room('shelter'):return
   var meal:Dictionary={}
   for entry in game.world.entries:
    if entry.id=='food':meal=entry
   if not await walk_to(meal.at):return
   await press(KEY_E);await advance_lines()
   if day_number<2:
    if not await choose("Start the day"):return
    await advance_lines()
   else:game.ui.clear()
  if Mission.phase!='complete':fail('Campaign not complete');return
  if Mission.rescues.size()>0:fail('Unexpected rescue');return
  print('DAILY_BRANCH ',branch,' PASS; cards=',Mission.cards.size())
 print('DAILY_TOUR PASS; minigames=',minigames,' frames=',frames)
 if not Audio.missing_voice_lines.is_empty():fail('Missing English speech: '+str(Audio.missing_voice_lines));return
 Audio.shutdown();await get_tree().process_frame;OS.delay_msec(100);get_tree().quit()
