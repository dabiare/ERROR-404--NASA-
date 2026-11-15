extends RefCounted
const ARRIVAL=[['control','Landing confirmed. Our planned mission lasts thirty days.'],['commander','We will look after our crew and explore together.']]
const MEETING=[['engineer','I look after machines. Even their sneezes have explanations!'],['botanist','I study plants. My garden is full of questions.'],['doctor','I look after everyone. Resting counts as space work, too.'],['geologist','I read stories in rocks. Let us find clues!'],['commander','I will listen to everyone before choosing our priorities.']]
const NIGHT={1:[['botanist','Dinner is ready. Everyone can choose their own seasoning.'],['robot','I hear a strange pulse. Who could be calling?']],2:[['geologist','The pulse changed when we moved our measuring instrument.'],['robot','A clue! Tomorrow we will compare the signals.']],3:[['control','Everyone is safe. You have the green light to continue.'],['robot','The signal seems to come from an old probe. Let us investigate tomorrow!']]}
const DAWN={1:'First, let us care for the crew and prepare our base.',2:'Today we explore together. Getting ready and returning safely matter, too.',3:'Let us check our water and exercise before going outside.'}
const CHATS={
 'engineer':['When a machine sneezes, I check its filter. No tissues needed!','My favorite tool is a label. Were you expecting a giant wrench?','A repair is finished when we check that it works.'],
 'botanist':['My plants cannot talk, but their leaves tell stories.','A new leaf? Time for my discovery notebook!','Our garden is an experiment. Supplies from Earth still provide most of our food.'],
 'doctor':['How do you feel? Listening is part of my job.','Even a commander needs rest. Yawns can be clues!','If something hurts, stop and tell me. We will check together.'],
 'geologist':['Every rock holds clues. Labels tell us where we found them.','My magnifying glass says this rock deserves another look.','Not every shiny rock is treasure. Finding out is part of the fun!']}
const WHY={
 'scan':'Our bodies feel different after traveling. These readings help me check how you are doing.',
 'cook':'Grains give energy, proteins help us grow, and vegetables bring useful nutrients. Let’s mix them!',
 'search':'Filters catch dust like tiny nets. Matching codes helps us find the right spare quickly.',
 'calibrate':'Imagine a ruler with mixed-up marks! Checking our instrument first helps us trust its measurements.',
 'air':'Stuffy air needs to circulate. Clearing the vent lets the fan move it again.',
 'suit':'Your suit is a tiny spacecraft. We check it before leaving our safe base.',
 'field':'A rock without notes loses its story. Record its clues before we move anything.',
 'assemble':'A broken wheel guard lets dust fly everywhere. Our patch will help keep equipment clean.',
 'clean':'Moon dust scratches like tiny rough grains. Let us keep it outside our living space.',
 'pipes':'A water cartridge helps clean used water. Think of a strainer that needs replacing.',
 'rhythm':'On the Moon we weigh less. Exercise still helps keep our muscles and bones strong.',
 'solar':'Solar particles can harm our crew. People come first; rock samples can wait.',
 'lock':'The airlock is our air-saving doorway. Opening both doors together could let our air escape.',
 'shelter':'Shelter reduces radiation, like a thick umbrella. A dosimeter measures radiation; it cannot block particles.',
 'chat':'A friendly pause can help a tired teammate. Listening is a useful space skill.',
 'grow':'Leaves cannot ask for help. Light and moisture readings help us understand what plants need.'}
static func task(id:String,day:int,room:String,target:String,title:String,kind:String,cost:int,needs:Array,speaker:String,verb:String,instruction:String,science:String,optional:=false)->Dictionary:
 return {'id':id,'day':day,'room':room,'target':target,'title':title,'kind':kind,'cost':cost,'needs':needs,'speaker':speaker,'verb':verb,'intro':instruction,'instruction':instruction,'why':WHY[kind],'science':science,'concept':science,'optional':optional,'choices':['Begin'],'correct':0,'success':science}
static func tasks()->Array:
 return [
 task('checkup',1,'medical','vitals','Check how you feel','scan',1,[],'doctor','find','Select Pulse, Blood oxygen, and Temperature. I will explain the readings.','Travel changes how we feel. Listening to our bodies helps.'),
 task('meal',1,'shelter','food','Build a crew meal','cook',1,[],'botanist','combine','Choose one grain, one protein, and one vegetable. Then choose optional seasonings.','Different foods help nourish our crew. Everyone can have different tastes.'),
 task('prepare',1,'engineering','spares','Store a spare dust filter','search',1,[],'engineer','match','Match the AD-42 filter box to its shelf tag, then select Store filter.','A matching code helps us store and find the right spare.'),
 task('air',1,'bedroom','vent','Get the air moving','air',0,[],'engineer','aim','Read the sensor. Vacuum three vent sections. Aim the fan, then check airflow.','Fans move air. A separate scrubber removes the carbon dioxide we breathe out.'),
 task('suit_check',2,'airlock','suits','Get ready to go outside','suit',1,[],'engineer','choose','Choose a suit. Check seals, test the radio, and follow our pressure-preparation protocol.','Preparing carefully reduces risks when pressure changes. We follow the doctor’s protocol.'),
 task('eva2',2,'exterior','rock','Explore with the geologist','field',2,['suit_check'],'geologist','explore','Record the rock’s texture and location. Then move our measuring instrument.','Notes preserve where a sample came from and the clues surrounding it.'),
 task('rover',2,'exterior','rover','Repair the rover dust guard','assemble',0,[],'engineer','build','Choose a sheet, tape, and clamps. Fit them without touching the wheel.','Apollo seventeen astronauts repaired a rover guard using maps and fasteners.'),
 task('dust_return',2,'airlock','dust','Keep Moon dust outside','clean',1,['eva2','rover'],'engineer','vacuum','Vacuum boots, gloves, and suit joints. Then inspect the clean seals.','Containing dust protects our equipment and the air inside our base.'),
 task('water',3,'engineering','water','Repair the water loop','pipes',1,[],'engineer','connect','Choose a water plan. Connect the pipes, replace the water cartridge, and test quality.','We treat used water and check its quality before drinking it.'),
 task('exercise',3,'gym','exercise','Exercise with the crew','rhythm',1,[],'doctor','rhythm','Alternate left and right with the pulse. You can also choose untimed practice.','Resistance helps care for muscles and bones when we weigh less.'),
 task('eva3',3,'exterior','rock','Compare our science clues','field',2,['water','exercise'],'geologist','explore','Record the new texture and location. Adjust our instrument to compare the signal.','Careful, consistent records help us compare our observations.'),
 task('solar_choice',3,'exterior','rock','Choose your return plan','solar',0,[],'control','decide','Return to shelter. Picking up the optional bag uses thirty seconds of game time.','People come first. Samples can wait.'),
 task('solar_lock',3,'airlock','lock','Come through the airlock','lock',0,['solar_choice'],'engineer','check','Close the outer door, check pressure, then open the inner door.','An emergency changes priorities. We still need to keep our air inside.'),
 task('shelter_all',3,'shelter','shield','Gather all five crew members','shelter',0,['solar_lock'],'commander','gather','Check off every crew member. Then read the dosimeter and contact Mission Control.','The shelter reduces exposure. A dosimeter measures radiation; it is not a shield.'),
 task('chat2',2,'shelter','food','Listen to a teammate','chat',1,['dust_return'],'doctor','listen','Choose a friendly way to support a teammate who needs a break.','Listening is another way to care for each other.',true),
 task('grow2',2,'crops','grow','Care for the seedlings','grow',1,['dust_return'],'botanist','observe','Check the light, moisture, and watering before caring for our seedlings.','Plants need suitable conditions. Supplies from Earth still feed our mission.',true),
 task('lab2',2,'minerals','analyzer','Check the rock instrument','calibrate',1,['dust_return'],'geologist','adjust','Use left and right to match the known reading: six. Then select Check.','A known reference helps us check whether an instrument measures correctly.',true),
 task('chat3',3,'shelter','food','Take a crew break','chat',1,[],'doctor','listen','Choose a friendly way to support a teammate who needs a break.','Asking for a break can help everyone feel better.',true),
 task('grow3',3,'crops','irrigation','Check the plant watering','grow',1,['water'],'botanist','observe','Check the plant watering after our water-loop repair.','After repairing a system, we also check the equipment that depends on it.',true)
 ]
static func find(id:String,priority:String='')->Dictionary:
 for entry in tasks():
  if entry.id!=id:continue
  var t:Dictionary=entry.duplicate(true)
  if id=='prepare' and priority=='lab':
   t.room='minerals';t.target='analyzer';t.title='Check the laboratory instrument';t.kind='calibrate';t.verb='adjust';t.speaker='geologist'
   t.instruction='Use left and right to match the known reading: six. Then select Check.'
   t.intro=t.instruction;t.why=WHY.calibrate
   t.science='A known reference helps us check whether an instrument measures correctly.'
  return t
 return {}
static func essentials(d:int)->Array:
 return {1:['checkup','meal','prepare'],2:['suit_check','eva2','rover','dust_return'],3:['water','exercise','eva3','shelter_all']}[d]
static func audit()->Array:
 var issues:Array=[];var entries:Array=[]
 for t in tasks():
  for key in ['instruction','science','why']:entries.append([t.id+' '+key,t[key]])
 for line in ARRIVAL+MEETING:entries.append(['introduction',line[1]])
 for day in NIGHT:
  for line in NIGHT[day]:entries.append(['night',line[1]])
 for role in CHATS:
  for line in CHATS[role]:entries.append([role,line])
 for entry in entries:
  if entry[1].split(' ',false).size()>15:issues.append(entry[0]+': more than fifteen words')
  for term in ['psia','torr','effusion','krytox','eclss','ars','venous nitrogen']:
   var regex:=RegEx.new();regex.compile('(?i)\\b'+term+'\\b')
   if regex.search(entry[1]):issues.append(entry[0]+': '+term)
 return issues
