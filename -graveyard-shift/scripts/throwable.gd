extends RigidBody3D

func set_mesh_and_collision(mesh : Mesh, scale : Vector3):
	var mesh_instance = $MeshInstance3D
	mesh_instance.mesh = mesh
	mesh_instance.scale = scale
	
	var verts = mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var convex := ConvexPolygonShape3D.new()
	convex.points = verts
	$CollisionShape3D.shape = convex
	
