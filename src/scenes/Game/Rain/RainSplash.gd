extends Spatial

# TODO See https://www.alanzucconi.com/2018/08/10/shader-showcase-saturday-5/
# And https://seblagarde.wordpress.com/2012/12/27/water-drop-2a-dynamic-rain-and-its-effects/

func play():
	$AnimationPlayer.play("splash")