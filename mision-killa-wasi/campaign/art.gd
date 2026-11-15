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
