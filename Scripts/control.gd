extends Control

func update_coins_text(coins_collected):
	$CoinsLabel.text = "x " + str(coins_collected)
