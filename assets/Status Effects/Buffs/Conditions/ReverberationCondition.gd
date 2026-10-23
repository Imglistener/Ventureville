class_name ReverberationCondition
extends VoiceCondition
## Psychic damage deals 75% to SAN instead of 50%. Read by AttackEffect._apply_psychic_sanity.

@export_range(0.5, 1.0) var san_ratio: float = 0.75


func modify_psychic_san_ratio(ratio: float) -> float:
	return maxf(ratio, san_ratio)
