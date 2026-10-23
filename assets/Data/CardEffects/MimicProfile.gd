class_name MimicProfile extends RefCounted
## A snapshot of one enemy action, recorded when it finishes.
## Numbers are the enemy's FINAL values (DamageBonus and attack bonus already applied).

var source_name := ""
var is_fallback := false         # Rehearsed Line
var damage := 0                  # per hit
var hits := 1
var damage_type: DamageType
var block := 0
var san_damage := 0
var status: StatusEffect         # template, e.g. Burning.tres
var status_stacks := 0
var status_needs_damage := false # Savage Lunge: only if the hit got through
var sound: AudioStream
