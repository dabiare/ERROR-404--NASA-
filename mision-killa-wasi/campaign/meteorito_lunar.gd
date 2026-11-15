extends Node2D
## Adapted from the team's meteorito.gd: flight, impact and ballistic ejecta.
## Lunar presentation intentionally omits atmospheric ablation, drag and damage.
signal finished
var elapsed:=0.0
var running:=false
var impacted:=false
var fragments: Array[Dictionary]=[]
var from:=Vector2(2020,160)
var impact:=Vector2(2070,265)

func start() -> void:
 if running: return
 running=true
 visible=true
 for i in 18:
  fragments.append({"v":Vector2(randf_range(-100,100),randf_range(-100,-30)),"r":randf_range(1,3)})

func _process(delta: float) -> void:
 if not running or not Mission.movable(): return
 elapsed+=delta
 if elapsed>=0.85 and not impacted: impacted=true
 if elapsed>3.8:
  running=false
  visible=false
  finished.emit()
 queue_redraw()

func _draw() -> void:
 if not running: return
 if elapsed<0.85:
  draw_circle(from.lerp(impact,elapsed/0.85),5,Color("8c8795"))
 else:
  var t:=elapsed-0.85
  if t<0.18: draw_circle(impact,14*(1-t/0.18),Color("ffe6ba"))
  if not Mission.reduced_motion:
   for f in fragments:
    var p: Vector2=impact+f.v*t+Vector2(0,30*t*t)
    draw_circle(p,f.r,Color(0.7,0.65,0.6,maxf(0,1-t/3)))
