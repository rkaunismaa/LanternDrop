extends SceneTree
## Balance simulation: bots play the real game (real physics) headless, faster than real time.
##   godot --headless --fixed-fps 60 --path game --script res://tools/balance_sim.gd -- \
##     [--bot careful|random] [--runs 20] [--seed 1] [--pace 1.0] [--balance res://data/balance.json]
## --fixed-fps 60 makes every frame exactly 1/60 s of game time, so results don't depend on the machine.
## Prints one "RESULT {json}" line with the summary.

const MAX_DROPS := 400  ## a run that survives this long counts as "never ends" (also caps run time)

var args := {"bot": "careful", "runs": "20", "seed": "1", "pace": "1.0", "balance": "res://data/balance.json"}


func _initialize() -> void:
	var argv := OS.get_cmdline_user_args()
	for i in range(0, argv.size() - 1, 2):
		args[argv[i].trim_prefix("--")] = argv[i + 1]
	_run.call_deferred()


func _run() -> void:
	var main: Node2D = load("res://scenes/main.tscn").instantiate()
	main.balance_path = args.balance
	main.best_path = "user://sim_best.cfg"
	main.settings_path = "user://sim_settings.cfg"
	root.add_child(main)
	await process_frame
	main.sfx.muted = true  # not saved: just silence for the run
	var rng := RandomNumberGenerator.new()
	var pace := float(args.pace)
	var drops_list: Array[int] = []
	var scores: Array[int] = []
	var biggest: Array[int] = []
	var sun_runs := 0
	var capped := 0
	for run in int(args.runs):
		var seed := int(args.seed) + run
		main.start(seed)
		rng.seed = seed * 7919
		var drops := 0
		var wait := pace
		while not main.is_over and drops < MAX_DROPS:
			await process_frame
			wait -= 1.0 / 60.0
			if wait <= 0.0:
				var x: float = SimBots.careful_x(main) if args.bot == "careful" else SimBots.random_x(main, rng)
				main.aim(x)
				if main.drop_at(main.aim_x) != null:
					drops += 1
					wait = pace
		if drops >= MAX_DROPS:
			capped += 1
		drops_list.append(drops)
		scores.append(main.score)
		biggest.append(main.biggest_kind)
		if main.suns > 0:
			sun_runs += 1
	drops_list.sort()
	scores.sort()
	biggest.sort()
	var n := drops_list.size()
	var result := {
		"bot": args.bot, "runs": n, "pace": pace, "balance": args.balance,
		"drops_p10": drops_list[int(n * 0.1)], "drops_median": drops_list[n / 2], "drops_p90": drops_list[mini(n - 1, int(n * 0.9))],
		"score_median": scores[n / 2], "biggest_median": biggest[n / 2], "biggest_max": biggest[n - 1],
		"sun_rate": float(sun_runs) / n, "capped": capped,
	}
	print("RESULT ", JSON.stringify(result))
	for f in ["user://sim_best.cfg", "user://sim_settings.cfg"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(f))
	quit()
