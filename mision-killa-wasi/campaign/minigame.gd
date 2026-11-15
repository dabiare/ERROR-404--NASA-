extends Control
signal finished(result:Dictionary)
var task:Dictionary
var ui:CanvasLayer
var kind:=''
var cursor:=0
var stage:=0
var value:=2
var progress:=0.0
var chosen:Array=[]
var result:Dictionary={}
var mistakes:=0
var completed:=false
var feedback:=''
var action_buttons:Array[Button]=[]
var instruction_label:Label
var detail:Label
var timer_label:Label
var action_texts:Array=[]
var holding:=false
var elapsed:=0.0
var beat_clock:=0.0
var rhythm_hits:=0
var pipes:Array=[1,2,3,1]
var grid_origin:=Vector2(35,145)
const Art=preload('res://campaign/art.gd')

func setup(data:Dictionary,interface:CanvasLayer)->void:
 task=data;ui=interface;kind=task.kind

func _ready()->void:
 size=Vector2(900,440)
 instruction_label=ui.label(self,task.instruction,Rect2(25,5,850,60),21)
 detail=ui.label(self,'',Rect2(25,73,850,65),18,Color('74e1c6'))
 timer_label=ui.label(self,'',Rect2(25,365,850,55),17)
 Mission.minigame_running=true
 var saved:Dictionary=Mission.optional.get('activity_state',{})
 if saved.get('id','')==task.id:
  stage=int(saved.get('stage',0));cursor=int(saved.get('cursor',0));value=int(saved.get('value',2))
  chosen=saved.get('chosen',[]).map(func(n):return int(n));result=saved.get('result',{}).duplicate(true)
  progress=float(saved.get('progress',0));mistakes=int(saved.get('mistakes',0));elapsed=float(saved.get('elapsed',0))
  rhythm_hits=int(saved.get('rhythm_hits',0));pipes=saved.get('pipes',[1,2,3,1]).map(func(n):return int(n))
 rebuild()

func _exit_tree()->void:
 Mission.minigame_running=false

func rebuild()->void:
 for b in action_buttons:
  remove_child(b);b.queue_free()
 action_buttons.clear()
 action_texts=options()
 cursor=clampi(cursor,0,maxi(0,action_texts.size()-1))
 for i in action_texts.size():
  var index:int=i
  var b:Button=ui.button(self,str(action_texts[i]),Rect2(grid_origin+Vector2((i%3)*285,(i/3)*76),Vector2(270,62)),func():choose(index))
  b.focus_mode=Control.FOCUS_NONE
  b.mouse_entered.connect(func():cursor=index)
  action_buttons.append(b)
 detail.text=feedback if feedback!='' else status_text()
 save_progress()
 queue_redraw()

func options()->Array:
 match kind:
  'scan':return ['Pulse\nHow fast your heart beats','Blood oxygen\nOxygen carried in your blood','Temperature\nHow warm your body is',"Suit picture — not a reading","Boot sketch — not a reading","Blank card — not a reading"]
  'cook':
   if stage==0:return ["Rice · grain","Tortilla · grain","Beans · protein","Egg · protein","Carrot · vegetable","Spinach · vegetable"]
   return ["Mild · no extra seasoning","Herbs on the side","Spicy sauce on the side"]
  'search':
   if stage==1:return ['Store filter · AD-42','Review the labels']
   return ["Cable · power lead","FILTER BOX · AD-42\nSpare dust filter","WATER CARTRIDGE · WP-8\nFor the water unit","Bolt · B-12\nFastens equipment","SHELF TAG · AD-42\nDust-filter storage spot","EMPTY BOX · No code\nNo spare inside"]
  'calibrate':return ["− Lower reading","Reading: %d · Reference: 6"%value,"+ Raise reading","Check result"]
  'air':
   if stage==0:return ["Read airflow sensor"]
   if stage==1:return ["Vacuum left vent section","Vacuum middle vent section","Vacuum right vent section"]
   if stage==2:return ["← Aim left","Fan angle: %d°"%value,"Aim right →","Hold E to run the fan"]
   return ["Check the final sensor reading"]
  'suit':
   if stage==0:return ["Comfort suit\nLonger preparation","Higher-pressure suit\nShorter preparation · −8 power"]
   return ['Inspect suit seals\nCheck that closing edges are clean','Radio check\nSend a message and hear a reply',"Pressure preparation\nFollow the doctor's breathing protocol"]
  'field':return ["Write down the rock's texture","Log where the rock was found","Reposition the signal instrument"]
  'assemble':
   if stage==0:return ["Flexible sheet · covers the gap","Suitable tape · holds the sheet","Clamps · secure the patch","Oversized plate · rubs the wheel","Loose bag · cannot stay secure","Wrong bolt · does not fit"]
   return ["1 · Cover the gap with the sheet","2 · Hold the sheet with tape","3 · Secure and check the clamps"]
  'clean':return ["Boots · hold to vacuum","Gloves · hold to vacuum","Suit joints · hold to vacuum"] if stage==0 else ["Inspect the cleaned seals"]
  'pipes':
   if stage==0:return ["Use one water reserve\nKeep watering plants","Pause plant watering\nKeep our reserve"]
   if stage==1:return ["Pipe 1: %d°"%(pipes[0]*90),"Pipe 2: %d°"%(pipes[1]*90),"Pipe 3: %d°"%(pipes[2]*90),"Pipe 4: %d°"%(pipes[3]*90),"Test the connected pipes"]
   if stage==2:return ["Dust filter · air system only","WATER CARTRIDGE · WP-8\nFor the water unit"]
   return ["Test water quality before use"]
  'rhythm':return ["← Resistance exercise","→ Cycling exercise","Untimed practice\nSame mission card"]
  'solar':return ["Leave the optional bag\nReturn immediately","Pick up the optional bag\nUse 30 seconds"]
  'lock':return ["1 · Close the outer door","2 · Check the pressure","3 · Open the inner door"]
  'shelter':return ["Commander","Chief engineer","Botanist","Flight doctor","Lunar geologist","Read dosimeter and contact Control"]
  'chat':return ["Listen without interrupting","Offer a break","Ask the crew for support"]
  'grow':return ['Check the plant light\nLeaves need light to grow','Read the moisture sensor\nSee how damp the roots are','Check the watering system\nConfirm roots receive water']
 return ["Check result"]

func status_text()->String:
 if kind=='search':return 'Match confirmed. Store one filter, or review your label choices.' if stage==1 else 'These cards show box and shelf labels. Select the two marked AD-42.'
 if kind=='scan':return 'Select a sensor card to copy its reading to the doctor’s tablet.'
 if kind=='calibrate':return 'Our test sample should read 6. Left/right adjusts; Enter checks your instrument.'
 if kind=='suit':return 'Choose a suit; preparation is summarized in game time, not real medical minutes.' if stage==0 else 'Each check records one part of our supervised preflight checklist.'
 if kind=='field':return 'Selecting each card writes an observation or records the instrument’s new position.'
 if kind=='assemble':return 'Pick three materials that cover the gap and stay secure.' if stage==0 else 'Fit the sheet first, tape second, and clamps last. Then check wheel clearance.'
 if kind=='clean' and stage==1:return 'Dust is contained. Inspect the seals before entering the living area.'
 if kind=='pipes' and stage==0:return 'Spend one reserve to keep services running, or pause watering until repairs finish.'
 if kind=='pipes' and stage==2:return 'The pipes connect. Choose the part labeled for the water unit, not air.'
 if kind=='pipes' and stage==3:return 'A connected pipe is not enough: check water quality before restoring the supply.'
 if kind=='shelter':return 'Select each name to check that person is inside. Then read instruments and call Control.'
 if kind=='solar':return 'Both choices start your return. The bag is optional; your crew’s safety comes first.'
 if kind=='lock':return 'Each card performs the next airlock step. The outer door must close first.'
 if kind=='grow':return 'Check light and moisture, then confirm the plants are receiving water.'
 if kind=='chat':return 'Choose a kind response. Every option offers support; none is a trick answer.'
 if kind=='cook' and stage==0:return "Choose one grain, one protein, and one vegetable; then choose seasonings."
 if kind=='pipes' and stage==1:return "Rotate each pipe until all four form a horizontal line. Then test them."
 if kind=='air' and stage==1 or kind=='clean' and stage==0:return "Choose a section. Hold E, Space, or the mouse button to vacuum it."
 if kind=='air' and stage==2:return "Aim the fan at the marked 35° direction. Hold E to run it."
 if kind=='rhythm':return "Alternate left and right when the moving dot reaches the circle; or choose practice."
 return "Arrows: choose · Enter: select · R: ask for help"

func hint(level:int)->String:
 if level==0:return task.science
 if level==1:return status_text()
 match kind:
  'scan':return "Select the three measurement cards: pulse, blood oxygen, and temperature. I interpret them."
  'cook':return "Each pair belongs to one food group. Pick one per group, then offer seasonings."
  'search':return "Select the AD-42 filter box and AD-42 shelf tag. Then choose Store filter."
  'calibrate':return "Use left or right until the reading is six, then select Check result."
  'air':return ["Select Read airflow sensor to see what needs fixing.","Select each vent section and hold E until its dust is cleared.","Aim at 35° with left and right, then hold E to move air.","Select the final sensor reading to check that airflow improved."][stage]
  'assemble':return "Choose sheet, tape, and clamps. Fit them in that order; nothing should rub the wheel."
  'pipes':return "Choose a water plan, straighten pipes, select the water cartridge, and test quality."
  'shelter':return "Select all five crew members first. Then check the dosimeter and radio."
  'rhythm':return "Untimed practice earns the same card. Use down and Enter, or click Practice."
 return "Complete each marked action before checking the result."

func wrong(text:String)->void:
 mistakes+=1;feedback=text;rebuild()
 if Mission.rank=="Cadet" and mistakes==2:ui.toast("Want a hint? Press R whenever you like.")

func choose(index:int)->void:
 if completed or Mission.locks!=1 or not Mission.focused:return
 feedback='';cursor=index
 match kind:
  'scan','field','grow':
   if index>2:wrong("That is a picture, not a measurement. Look for the three sensor cards.");return
   if not index in chosen:
    chosen.append(index);Audio.confirm()
    feedback={'scan':['Pulse reading sent to the doctor.','Blood-oxygen reading sent to the doctor.','Temperature reading sent to the doctor.'],'field':['Texture recorded: rough, with small grains.','Location recorded: our marked observation site.','Instrument repositioned; the signal reading is recorded.'],'grow':['Light checked. The plant lamp is working.','Moisture reading recorded for the botanist.','Watering checked and recorded.']}[kind][index]
   if chosen.size()==3:finish();return
  'cook':
   if stage==1:result.season=index;finish();return
   var group:int=index/2
   chosen=chosen.filter(func(i):return int(i)/2!=group)
   chosen.append(index)
   if chosen.size()==3:stage=1;chosen.clear();cursor=0
  'search':
   if stage==1:
    if index==0:result.storage_code='AD-42';finish();return
    stage=0;chosen.clear();cursor=0;rebuild();return
   if not index in [1,4]:wrong("Different code, different job! Find the box and shelf tag that both say AD-42.");return
   if not index in chosen:chosen.append(index)
   feedback='Filter box checked. Now find the AD-42 shelf tag.' if index==1 else 'Shelf tag checked. Now find the AD-42 filter box.'
   if chosen.size()==2:stage=1;cursor=0;feedback='Both codes say AD-42. Store the box to log one spare filter.'
  'calibrate':
   if index==0:value=maxi(0,value-1)
   elif index==2:value=mini(10,value+1)
   elif index==3:
    if value==6:finish();return
    wrong("Our known reference reads six. Adjust until this reading matches it.");return
  'air':
   if stage==0:stage=1;chosen.clear();cursor=0
   elif stage==1:return
   elif stage==2:
    if index==0:value=maxi(0,value-5)
    elif index==2:value=mini(90,value+5)
    rebuild()
    return
   else:finish();return
  'clean':
   if stage==0:return
   finish();return
  'suit':
   if stage==0:result.suit=index;stage=1;cursor=0
   else:
    if not index in chosen:chosen.append(index)
    if chosen.size()==3:finish();return
  'assemble','lock':
   if kind=='assemble' and stage==0:
    if index>2:wrong("That part might come loose or rub the wheel. Choose secure, well-fitting materials.");return
    if not index in chosen:chosen.append(index)
    if chosen.size()==3:stage=1;chosen.clear();cursor=0
   else:
    if index!=chosen.size():wrong("First finish the previous step. We need to secure each part in order.");return
    chosen.append(index)
    if chosen.size()==3:finish();return
  'pipes':
   if stage==0:result.water=index;stage=1;cursor=0
   elif stage==1:
    if index<4:pipes[index]=(int(pipes[index])+1)%4
    elif pipes.all(func(p):return p==0):stage=2;cursor=0
    else:wrong("One pipe is still turned. Rotate the pipes until their paths line up horizontally.");return
   elif stage==2:
    if index==0:wrong("This catches dust in air. Our water unit needs its matching water cartridge.");return
    stage=3;cursor=0
   else:finish();return
  'rhythm':
   if index==2:result.practice=true;rhythm_hits+=1
   elif index!=rhythm_hits%2:wrong("Alternate sides. We can practice without a timer, too!");return
   elif absf(fmod(beat_clock,1.6)-0.8)<0.45:rhythm_hits+=1
   else:wrong("Wait until the moving dot reaches the circle, then press the next side.");return
   if rhythm_hits>=8:finish();return
  'solar':result.solar=index;finish();return
  'shelter':
   if index==5:
    if chosen.size()<5:wrong("Someone has not been counted. Check off all five crew members first.");return
    finish();return
   if not index in chosen:chosen.append(index)
  'chat':result.support=index;finish();return
  _:finish();return
 rebuild()

func finish()->void:
 if completed:return
 completed=true;Mission.minigame_running=false
 Mission.optional.erase('activity_state')
 result.grade='perfecto' if mistakes==0 else 'bien'
 result.mistakes=mistakes
 result.seconds=elapsed
 finished.emit(result)

func _input(event:InputEvent)->void:
 if not event is InputEventKey or not event.pressed or event.echo or Mission.locks!=1 or completed:return
 var key:int=event.keycode if event.keycode!=0 else event.physical_keycode
 var viewport:=get_viewport()
 if key in [KEY_R,KEY_ESCAPE,KEY_M,KEY_T,KEY_J]:return
 if key in [KEY_LEFT,KEY_A]:
  if kind=='rhythm':choose(0)
  elif kind=='air' and stage==2:choose(0)
  elif kind=='calibrate':choose(0)
  else:cursor=(cursor-1+action_texts.size())%action_texts.size()
 elif key in [KEY_RIGHT,KEY_D]:
  if kind=='rhythm':choose(1)
  elif kind=='air' and stage==2:choose(2)
  elif kind=='calibrate':choose(2)
  else:cursor=(cursor+1)%action_texts.size()
 elif key in [KEY_UP,KEY_W]:cursor=0 if kind=='rhythm' else posmod(cursor-3,action_texts.size())
 elif key in [KEY_DOWN,KEY_S]:cursor=2 if kind=='rhythm' else (cursor+3)%action_texts.size()
 elif key in [KEY_ENTER,KEY_SPACE,KEY_E]:choose(3 if kind=='calibrate' else cursor)
 else:return
 viewport.set_input_as_handled()
 if is_inside_tree():queue_redraw()

func _process(delta:float)->void:
 if not Mission.minigame_running or not Mission.clock_running():return
 elapsed+=delta;beat_clock+=delta
 save_progress()
 var vacuum:bool=kind=='air' and stage==1 or kind=='clean' and stage==0
 var fan:bool=kind=='air' and stage==2
 var held:bool=Input.is_physical_key_pressed(KEY_E) or Input.is_physical_key_pressed(KEY_SPACE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and get_global_rect().has_point(get_global_mouse_position())
 if vacuum and held and not cursor in chosen:
  progress+=delta
  if progress>=0.8:
   chosen.append(cursor);progress=0;Audio.confirm()
   if chosen.size()==3:
    stage+=1;chosen.clear();cursor=0
    if kind=='air':value=0
   rebuild()
 elif fan and held and absi(value-35)<=5:
  progress+=delta
  if progress>=1.0:stage=3;progress=0;cursor=0;rebuild()
 else:progress=maxf(0,progress-delta*0.5)
 timer_label.text=progress_text()
 for i in action_buttons.size():
  action_buttons[i].modulate=Color('74e1c6') if i in chosen else Color.WHITE
 queue_redraw()

func progress_text()->String:
 if kind=='search':return 'Matching labels: %d / 2 · One spare filter will be registered.'%chosen.size()
 if kind=='scan':return 'Readings copied: %d / 3 · The doctor interprets the results.'%chosen.size()
 if kind=='cook':return 'Food groups chosen: %d / 3'%chosen.size() if stage==0 else 'Balanced plate ready. Choose seasoning on the side.'
 if kind=='rhythm':return 'Movements practiced: %d / 8 · Rest and support are always available.'%rhythm_hits
 if kind=='shelter':return 'Crew members counted inside: %d / 5'%chosen.size()
 if kind=='air':return ['Sensor: airflow low · Vent inspection needed.','Vent sections cleared: %d / 3'%chosen.size(),'Match the 35° marker to direct airflow.','Airflow restored · The separate scrubber removes CO₂.'][stage]
 if kind=='clean':return 'Suit zones cleaned: %d / 3'%chosen.size() if stage==0 else 'Dust contained · Ready to inspect the seals.'
 return 'Steps recorded: %d'%chosen.size()

func save_progress()->void:
 if completed:return
 Mission.optional.activity_state={'id':task.id,'stage':stage,'cursor':cursor,'value':value,'chosen':chosen.duplicate(),'result':result.duplicate(true),'progress':progress,'mistakes':mistakes,'elapsed':elapsed,'rhythm_hits':rhythm_hits,'pipes':pipes.duplicate()}

func _draw()->void:
 if cursor<action_buttons.size():draw_style_box(ui.style(Color(0,0,0,0),Color('f6ca68')),Rect2(action_buttons[cursor].position-Vector2(3,3),action_buttons[cursor].size+Vector2(6,6)))
 if kind=='air' or kind=='clean':
  draw_rect(Rect2(35,325,820,15),Color('213e54'))
  draw_rect(Rect2(35,325,820*minf(progress,1),15),Color('74e1c6'))
 if kind=='air' and stage==2:
  var center:=Vector2(600,310)
  draw_line(center,center+Vector2.from_angle(deg_to_rad(-value))*90,Color('73d9e5'),5)
  draw_string(ThemeDB.fallback_font,Vector2(35,310),"SENSOR VIEW: airflow display. Carbon dioxide itself is invisible.",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color('ffce88'))
 if kind=='pipes' and stage==1:
  for i in 4:
   var center:=Vector2(310+i*115,325)
   var dir:=Vector2.from_angle(deg_to_rad(pipes[i]*90))*45
   draw_line(center-dir,center+dir,Color('73d9e5'),8)
 if kind=='rhythm':
  draw_arc(Vector2(460,325),20,0,TAU,24,Color('f6ca68'),3)
  draw_circle(Vector2(300+fmod(beat_clock,1.6)/1.6*320,325),8,Color('74e1c6'))
 if kind=='calibrate':
  draw_line(Vector2(110,330),Vector2(660,330),Color('557087'),4)
  for i in 11:draw_line(Vector2(110+i*55,320),Vector2(110+i*55,340),Color('a6ccdf'),2)
  draw_circle(Vector2(110+value*55,330),9,Color('74e1c6'))
  draw_line(Vector2(440,310),Vector2(440,350),Color('f6ca68'),3)
 var preview:Dictionary={'scan':104,'cook':110,'search':25,'suit':16,'field':26,'assemble':23,'shelter':18,'chat':27,'grow':2}
 if preview.has(kind):draw_texture_rect(Art.prop(preview[kind]),Rect2(745,290,100,70),false)
 if kind=='scan':
  for n in 3:
   var x:float=70+n*195
   draw_rect(Rect2(x,305,160,45),Color('102234'))
   var points:=PackedVector2Array()
   for i in 40:points.append(Vector2(x+i*4,330+sin(i*0.8+elapsed*3)*8))
   draw_polyline(points,Color('74e1c6') if n in chosen else Color('557087'),2)
 if kind=='field':
  for i in 3:
   var at:=Vector2(160+i*190,325)
   draw_circle(at,11,Color('74e1c6') if i in chosen else Color('557087'))
   if i<2:draw_line(at+Vector2(15,0),at+Vector2(175,0),Color('a6ccdf'),2)
 if kind=='cook':
  for i in 3:
   draw_circle(Vector2(250+i*130,325),24,[Color('dbb86c'),Color('b2816c'),Color('82c965')][i])
 if kind=='assemble':
  for i in chosen:draw_rect(Rect2(180+i*100,315,75,20),Color('74e1c6'))
