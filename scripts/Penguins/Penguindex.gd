extends Reference

const AdeliePenguin = preload("res://scenes/Penguins/AdeliePenguin.tscn")
const ChinstrapPenguin = preload("res://scenes/Penguins/ChinstrapPenguin.tscn")
const EmperorPenguin = preload("res://scenes/Penguins/EmperorPenguin.tscn")
const GentooPenguin = preload("res://scenes/Penguins/GentooPenguin.tscn")
const KingPenguin = preload("res://scenes/Penguins/KingPenguin.tscn")
const SPECIES = ["Adelie", "Chinstrap", "Emperor", "Gentoo", "King"]


static func get_penguin(species: String):
	match species:
		"Adelie":
			return AdeliePenguin.instance()
		"Chinstrap":
			return ChinstrapPenguin.instance()
		"Emperor":
			return EmperorPenguin.instance()
		"Gentoo":
			return GentooPenguin.instance()
		"King":
			return KingPenguin.instance()

	print('"%s" is not a known Penguin species; returning EmperorPenguin instead.' % species)
	return EmperorPenguin.instance()


static func get_random_species():
	randomize()
	return SPECIES[randi() % SPECIES.size()]


static func get_random_penguin():
	return get_penguin(get_random_species())
