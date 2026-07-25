extends Node3D

const SPEED := 260.0
const FLUCTUATION_SECONDS := 0.5
const FLUCTUATION_AMOUNT := 8.0
const TUBE_RADIUS := 9.0
const PATH_POINTS := 150
const PATH_STEP := 28.0
const TUBE_RINGS := 900
const RING_SIDES := 20

@onready var camera: Camera3D = $Camera
@onready var tunnel: MeshInstance3D = $Tunnel
@onready var status: Label = $HUD/Status
@onready var progress_bar: ProgressBar = $HUD/Progress

var path := Curve3D.new()
var distance := 0.0
var elapsed := 0.0
var fluctuation_elapsed := 0.0
var velocity_offset := 0.0
var displayed_velocity := 0.0
var charge_tween: Tween
var random := RandomNumberGenerator.new()


func _ready() -> void:
	_make_path()
	_make_tunnel()
	random.randomize()


func _process(delta: float) -> void:
	elapsed += delta
	distance = fmod(distance + SPEED * delta, path.get_baked_length() - 8.0)
	fluctuation_elapsed += delta
	if fluctuation_elapsed >= FLUCTUATION_SECONDS:
		fluctuation_elapsed = fmod(fluctuation_elapsed, FLUCTUATION_SECONDS)
		velocity_offset = random.randf_range(-FLUCTUATION_AMOUNT, FLUCTUATION_AMOUNT)

	var charge_ratio := progress_bar.value / progress_bar.max_value
	var target_velocity := maxf(0.0, (SPEED + velocity_offset) * charge_ratio)
	displayed_velocity = lerpf(displayed_velocity, target_velocity, 1.0 - exp(-8.0 * delta))
	status.text = "TEMPORAL VELOCITY  //  %.1fc" % displayed_velocity

	var position := path.sample_baked(distance)
	var target := path.sample_baked(distance + 8.0)
	var flight_transform := Transform3D(Basis.IDENTITY, position).looking_at(target, Vector3.UP)
	flight_transform.basis = flight_transform.basis.rotated(
		flight_transform.basis.z.normalized(),
		sin(elapsed * 2.4) * 0.1
	)
	camera.global_transform = flight_transform
	camera.fov = 106.0 + sin(elapsed * 7.0) * 3.0


func charge_to(value: float, seconds := 0.25) -> Signal:
	if charge_tween:
		charge_tween.kill()
	charge_tween = create_tween()
	charge_tween.tween_property(progress_bar, "value", value, seconds).set_trans(Tween.TRANS_SINE)
	return charge_tween.finished


func _make_path() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = Time.get_ticks_usec()
	var points: Array[Vector3] = [Vector3.ZERO]
	var heading := Vector2.ZERO
	var target_heading := Vector2.ZERO

	for index in range(1, PATH_POINTS):
		if index % 3 == 1:
			target_heading = Vector2(
				random.randf_range(-1.35, 1.35),
				random.randf_range(-0.85, 0.85)
			)
		heading = heading.lerp(target_heading, 0.38)
		points.append(points[-1] + Vector3(heading.x * PATH_STEP, heading.y * PATH_STEP, -PATH_STEP))

	for index in points.size():
		var previous: Vector3 = points[maxi(index - 1, 0)]
		var following: Vector3 = points[mini(index + 1, points.size() - 1)]
		var handle := (following - previous) * 0.18
		path.add_point(points[index], -handle, handle)
	path.bake_interval = 1.0


func _make_tunnel() -> void:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	var length := path.get_baked_length()
	var previous_right := Vector3.RIGHT

	for ring in range(TUBE_RINGS):
		var path_distance := length * ring / (TUBE_RINGS - 1.0)
		var center := path.sample_baked(path_distance)
		var tangent := (
			path.sample_baked(minf(path_distance + 1.0, length))
			- path.sample_baked(maxf(path_distance - 1.0, 0.0))
		).normalized()
		var right := previous_right.slide(tangent).normalized()
		if right.length_squared() < 0.5:
			right = Vector3.UP.cross(tangent).normalized()
		var up := tangent.cross(right).normalized()
		previous_right = right

		for side in range(RING_SIDES):
			var angle := TAU * side / RING_SIDES
			var radial := right * cos(angle) + up * sin(angle)
			vertices.append(center + radial * TUBE_RADIUS)
			normals.append(-radial)
			uvs.append(Vector2(float(side) / RING_SIDES, float(ring) / TUBE_RINGS))

	for ring in range(TUBE_RINGS - 1):
		for side in range(RING_SIDES):
			var next_side := (side + 1) % RING_SIDES
			var current := ring * RING_SIDES + side
			var next_ring := current + RING_SIDES
			var next_ring_side := (ring + 1) * RING_SIDES + next_side
			indices.append_array([
				current, next_ring, ring * RING_SIDES + next_side,
				ring * RING_SIDES + next_side, next_ring, next_ring_side,
			])

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	tunnel.mesh = mesh
	assert(vertices.size() == TUBE_RINGS * RING_SIDES)
