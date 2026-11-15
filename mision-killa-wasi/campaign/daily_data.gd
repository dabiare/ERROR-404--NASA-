extends RefCounted
const ARRIVAL=[['control','Alunizaje confirmado. Nuestra misión durará treinta días.'],['commander','Cuidaremos al equipo y exploraremos juntos.']]
const MEETING=[['engineer','Cuido las máquinas. ¡Hasta sus estornudos tienen explicación!'],['botanist','Investigo plantas. Mi jardín está lleno de preguntas.'],['doctor','Cuido la salud. Descansar también cuenta como trabajo espacial.'],['geologist','Leo historias en las rocas. ¡Busquemos pistas!'],['commander','Escucharé sus ideas antes de decidir.']]
const NIGHT={1:[['botanist','Cena lista. Dejé los condimentos por separado.'],['robot','Detecto un pulso extraño. ¿Quién estará llamando?']],2:[['geologist','El pulso cambió cuando movimos el instrumento.'],['robot','¡Una pista! Mañana compararemos las señales.']],3:[['control','Equipo a salvo. Tienen luz verde para continuar la misión.'],['robot','La señal parece venir de una sonda antigua. ¡Seguiremos investigando!']]}
const DAWN={1:'Primero cuidaremos al equipo y prepararemos la base.',2:'Hoy salimos juntos. Preparar y regresar también son parte de explorar.',3:'Revisemos el agua y entrenemos antes de salir.'}
const CHATS={
 'engineer':['Si una máquina estornuda, miro el filtro. ¡No necesita pañuelos!','Mi herramienta favorita es una etiqueta. ¿Esperabas una llave gigante?','Una reparación termina cuando comprobamos que funciona.'],
 'botanist':['Mis plantas no hablan, pero sus hojas cuentan historias.','¿Una hoja nueva? ¡Necesito mi cuaderno de descubrimientos!','El huerto investiga. Nuestra despensa sigue siendo la fuente principal de comida.'],
 'doctor':['¿Cómo te sientes? Escucharte también es parte de mi trabajo.','Hasta una comandante necesita descansar. ¡Los bostezos también dan pistas!','Si algo molesta, paramos y lo revisamos juntos.'],
 'geologist':['Cada roca guarda pistas. Sus etiquetas cuentan dónde las encontramos.','Mi lupa dice que esta roca merece otra mirada.','No todas las rocas brillantes son tesoros. ¡Investigar también es divertido!']}
static func task(id:String,day:int,room:String,target:String,title:String,kind:String,cost:int,needs:Array,speaker:String,verb:String,instruction:String,science:String,optional:=false)->Dictionary:
 return {'id':id,'day':day,'room':room,'target':target,'title':title,'kind':kind,'cost':cost,'needs':needs,'speaker':speaker,'verb':verb,'intro':instruction,'instruction':instruction,'science':science,'concept':science,'optional':optional,'choices':['Comenzar'],'correct':0,'success':science}
static func tasks()->Array:
 return [
 task('checkup',1,'medical','vitals','Revisión después del viaje','scan',1,[],'doctor','buscar','Busca los tres indicadores señalados. Yo interpretaré las lecturas.','El viaje cambia cómo nos sentimos. Escuchar al cuerpo ayuda.'),
 task('meal',1,'shelter','food','Cocina para todos','cook',1,[],'botanist','combinar','Combina un cereal, una proteína y una verdura. El condimento es opcional.','Una comida variada cuida al equipo. Los gustos pueden ser distintos.'),
 task('prepare',1,'engineering','spares','Almacén o laboratorio','search',1,[],'engineer','explorar','Localiza las dos etiquetas compatibles y registra el filtro.','Una etiqueta correcta ayuda más que adivinar por el color.'),
 task('air',1,'bedroom','vent','Recupera la ventilación','air',0,[],'engineer','apuntar','Consulta el sensor, despeja la rejilla y dirige el flujo.','El ventilador mueve aire. El depurador retira el gas que exhalamos.'),
 task('suit_check',2,'airlock','suits','Prepara la salida','suit',1,[],'engineer','elegir','Compara trajes; comprueba sellos, radio y preparación de presión.','Prepararnos reduce riesgos al cambiar de presión. Seguimos el protocolo del médico.'),
 task('eva2',2,'exterior','rock','Explora con el geólogo','field',2,['suit_check'],'geologist','explorar','Documenta tres pistas y reubica el instrumento.','Las etiquetas conservan el lugar y las pistas de cada muestra.'),
 task('rover',2,'exterior','rover','Repara el guardabarros','assemble',0,[],'engineer','armar','Elige lámina, cinta y abrazaderas. Comprueba que nada roce la rueda.','En Apollo diecisiete repararon un guardabarros usando mapas y sujeciones.'),
 task('dust_return',2,'airlock','dust','Regresa sin repartir polvo','clean',1,['eva2','rover'],'engineer','aspirar','Limpia las tres zonas y después comprueba los sellos.','El polvo lunar desgasta los equipos. Contenerlo protege también el aire.'),
 task('water',3,'engineering','water','Repara el circuito de agua','pipes',1,[],'engineer','conectar','Consulta reservas, conecta el circuito e instala el cartucho de agua.','Tratamos el agua usada y comprobamos su calidad antes de beber.'),
 task('exercise',3,'gym','exercise','Entrena con el equipo','rhythm',1,[],'doctor','ritmo','Alterna las teclas indicadas. Puedes practicar sin prisa.','La resistencia ayuda a cuidar músculos y huesos cuando pesamos menos.'),
 task('eva3',3,'exterior','rock','Compara las señales','field',2,['water','exercise'],'geologist','explorar','Registra tres observaciones antes de comparar la señal.','Registrar de la misma manera permite comparar las observaciones.'),
 task('solar_choice',3,'exterior','rock','Decide cómo regresar','solar',0,[],'control','decidir','Vuelve al refugio. Recoger la bolsa consume treinta segundos del reloj.','Las personas tienen prioridad. Las muestras pueden esperar.'),
 task('solar_lock',3,'airlock','lock','Comprueba la esclusa','lock',0,['solar_choice'],'engineer','comprobar','Cierra la puerta exterior, comprueba presión y abre la interior.','La urgencia cambia prioridades. Seguimos conservando el aire de la base.'),
 task('shelter_all',3,'shelter','shield','Reúne a cinco personas','shelter',0,['solar_lock'],'commander','reunir','Cuenta al equipo, comprueba el dosímetro y confirma comunicación.','El refugio reduce exposición. El dosímetro registra; no actúa como escudo.'),
 task('chat2',2,'shelter','food','Escucha al equipo','chat',1,['dust_return'],'doctor','escuchar','Escoge cómo acompañar a quien necesita una pausa.','Escuchar también es una forma de cuidar.' ,true),
 task('grow2',2,'crops','grow','Cuida los brotes','grow',1,['dust_return'],'botanist','observar','Compara luz y humedad antes de cuidar los brotes.','El cultivo necesita condiciones adecuadas. La despensa sigue sosteniendo la misión.',true),
 task('lab2',2,'minerals','analyzer','Analiza la muestra','calibrate',1,['dust_return'],'geologist','ajustar','Ajusta el instrumento hasta coincidir con la referencia.','Una referencia conocida permite comprobar una medición.',true),
 task('chat3',3,'shelter','food','Una pausa en equipo','chat',1,[],'doctor','escuchar','Escoge cómo acompañar a quien necesita una pausa.','Pedir una pausa ayuda al bienestar del equipo.',true),
 task('grow3',3,'crops','irrigation','Comprueba el riego','grow',1,['water'],'botanist','observar','Comprueba el riego después de reparar el circuito.','También revisamos los equipos que dependen del sistema reparado.',true)
 ]
static func find(id:String,priority:String='')->Dictionary:
 for entry in tasks():
  if entry.id!=id: continue
  var t:Dictionary=entry.duplicate(true)
  if id=='prepare' and priority=='lab':
   t.room='minerals';t.target='analyzer';t.title='Calibra el laboratorio';t.kind='calibrate';t.verb='ajustar'
   t.instruction='Ajusta el instrumento hasta coincidir con la referencia.';t.intro=t.instruction;t.speaker='geologist'
  return t
 return {}
static func essentials(d:int)->Array:
 return {1:['checkup','meal','prepare'],2:['suit_check','eva2','rover','dust_return'],3:['water','exercise','eva3','shelter_all']}[d]

static func audit()->Array:
 var issues:Array=[]
 var entries:Array=[]
 for t in tasks():
  entries.append([t.id+' instrucción',t.instruction]);entries.append([t.id+' ciencia',t.science])
 for line in ARRIVAL+MEETING:entries.append(['presentación',line[1]])
 for day in NIGHT:
  for line in NIGHT[day]:entries.append(['noche',line[1]])
 for role in CHATS:
  for line in CHATS[role]:entries.append([role,line])
 for entry in entries:
  if entry[1].split(' ',false).size()>15:issues.append(entry[0]+': más de quince palabras')
  for term in ['psia','torr','efusión','krytox','eclss','ars','nitrógeno venoso']:
   var regex:=RegEx.new();regex.compile('(?i)\\b'+term+'\\b')
   if regex.search(entry[1]):issues.append(entry[0]+': '+term)
 return issues
