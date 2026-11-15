extends RefCounted
static var cache: Dictionary = {}
const Catalog = preload("res://campaign/catalog.gd")

static func prop(index: int) -> Texture2D:
 var key := "prop_%d" % index
 if cache.has(key): return cache[key]
 var texture: Texture2D
 if index>=100:
  var names := ["01_ventilacion_vapor","02_sensor_co2","03_flujo_aire","04_panel_esclusa","05_monitor_medico","06_aspiradora","07_anillo_metalico","08_lubricante","09_mando_lunar","10_equipo_ejercicio","11_tortillas","12_curry"]
  texture = load(Catalog.ART+"items/"+names[index-100]+".png")
 else:
  var atlas := AtlasTexture.new()
  atlas.atlas = load(Catalog.ART+("props.png" if index<12 else "equipment.png"))
  var cell := atlas.atlas.get_size()/Vector2(4,3 if index<12 else 4)
  var n := index if index<12 else index-12
  atlas.region=Rect2(Vector2(n%4,n/4)*cell,cell)
  texture=atlas
 cache[key]=texture
 return texture

static func face(id: String) -> Texture2D:
 return load(Catalog.PEOPLE.get(id,Catalog.PEOPLE.commander))

static func icon(kind: String) -> Texture2D:
 if cache.has(kind): return cache[kind]
 var source: Texture2D=load(Catalog.ART+"icons/frames_items/"+kind+"/000.png")
 var atlas:=AtlasTexture.new()
 atlas.atlas=source
 atlas.region=source.get_image().get_used_rect()
 cache[kind]=atlas
 return atlas

static func english_sign(parent:Node,display_size:=Vector2.ZERO,cover:=false)->void:
 var at:=Vector2(983,329)
 var extent:=Vector2(116,22)
 if display_size!=Vector2.ZERO:
  var factor:float=maxf(display_size.x/2172.0,display_size.y/724.0) if cover else 1.0
  var offset:Vector2=(display_size-Vector2(2172,724)*factor)/2
  at=offset+at*factor;extent*=factor
 var plate:=ColorRect.new();plate.position=at;plate.size=extent;plate.color=Color('071e42');plate.mouse_filter=Control.MOUSE_FILTER_IGNORE
 parent.add_child(plate)
 var title:=Label.new();title.text='LUNAR BASE';title.position=Vector2.ZERO;title.size=extent
 title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;title.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 title.add_theme_font_size_override('font_size',12);title.add_theme_color_override('font_color',Color('63dce7'))
 title.mouse_filter=Control.MOUSE_FILTER_IGNORE;plate.add_child(title)
