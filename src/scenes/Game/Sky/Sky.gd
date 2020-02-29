extends Sprite


func cov_scb(value):
	self.material.set("shader_param/COVERAGE",float(value)/100)

func absb_scb(value):
	self.material.set("shader_param/ABSORPTION",float(value)/10)

func thick_scb(value):
	self.material.set("shader_param/THICKNESS",value)

func step_scb(value):
	self.material.set("shader_param/STEPS",value)
