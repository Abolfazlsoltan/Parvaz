extends SceneTree

func _initialize() -> void:
 call_deferred("_run")

func _count_buttons(node: Node) -> int:
 var count := 1 if node is Button else 0
 for child in node.get_children():
  count += _count_buttons(child)
 return count

func _run() -> void:
 var packed := load("res://main.tscn") as PackedScene
 assert(packed != null,"Main scene failed to load.")
 var game := packed.instantiate()
 root.add_child(game)
 await process_frame
 assert(game.state=="menu","Game should start at main menu.")
 assert(game.ui_root is Control,"Native UI root was not created.")
 assert(_count_buttons(game.ui_root)>=5,"Main menu is missing native buttons.")
 game._ui_open_settings()
 await process_frame
 assert(game.state=="settings","Settings screen did not open.")
 assert(_count_buttons(game.ui_root)>=7,"Settings screen is missing controls.")
 game._ui_set_language("en")
 await process_frame
 assert(game.language=="en","English language toggle failed.")
 assert(game.ui_root.layout_direction==Control.LAYOUT_DIRECTION_LTR,"English layout direction is not LTR.")
 game._ui_set_language("fa")
 await process_frame
 assert(game.language=="fa","Persian language toggle failed.")
 assert(game.ui_root.layout_direction==Control.LAYOUT_DIRECTION_RTL,"Persian layout direction is not RTL.")
 game._ui_open_stages()
 await process_frame
 assert(game.state=="stages","Mission selection did not open.")
 assert(_count_buttons(game.ui_root)>=12,"Mission selection is missing stage buttons.")
 game._ui_open_hangar()
 await process_frame
 assert(_count_buttons(game.ui_root)>=8,"Hangar is missing aircraft buttons.")
 game._ui_open_help()
 await process_frame
 assert(_count_buttons(game.ui_root)>=1,"Flight School back button was not created.")
 print("PASS: menu, settings, bilingual layout, mission select, hangar and help screens.")
 game.queue_free()
 await process_frame
 quit(0)
