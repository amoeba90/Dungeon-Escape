# fade_overlay.gd
extends ColorRect

# Fades out from black to transparent
func fade_out(duration: float = 1.0) -> void:
	self.color = Color(0, 0, 0, 255)  # Start fully black
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, duration)  # Exactly 4 arguments
	tween.finished.connect(self._on_fade_out_finished)  # Connect to the finished signal

func _on_fade_out_finished() -> void:
	print("Fade-out complete!")

# Fades in from transparent to black
func fade_in(duration: float = 1.0) -> void:
	self.color = Color(0, 0, 0, 0)  # Start fully transparent (alpha = 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 255, duration)  # Exactly 4 arguments
	tween.finished.connect(self._on_fade_in_finished)  # Connect to the finished signal

func _on_fade_in_finished() -> void:
	print("Fade-in complete!")
