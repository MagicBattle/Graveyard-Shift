extends RigidBody3D

func set_mesh_and_collision(mesh : Mesh, scale : Vector3):
	var mesh_instance = $MeshInstance3D
	mesh_instance.mesh = mesh
	mesh_instance.scale = scale
	
	var verts = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var scaled_verts = []
	var convex := ConvexPolygonShape3D.new()
	for v in verts:
		scaled_verts.append(Vector3(v.x * scale.x, v.y * scale.y, v.z * scale.z))
	convex.points = scaled_verts
	$CollisionShape3D.shape = convex
	
