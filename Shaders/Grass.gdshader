shader_type spatial;
render_mode cull_disabled; // Disable back-face culling so that both sides of the grass render

// 2 colors which make a gradient together (to color the grass depending on height)
uniform vec3 color : source_color;
uniform vec3 color2 : source_color;

uniform sampler2D noise;
uniform float noiseScale = 20.0;

uniform vec3 right_foot_position;
uniform vec3 left_foot_position;
uniform float character_radius = 0.5;
uniform sampler2D character_distance_falloff_curve : hint_default_black;
uniform float character_push_strength = 1.0;

//wind uniforms
uniform sampler2D wind_noise;

varying vec3 worldPos;

void vertex() {
	vec3 world_camera = CAMERA_POSITION_WORLD;
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; // Transition from local space to world space
	
	float smoothness = 10.0;
	float min_dist = 100.0;
	
	if(distance(worldPos.xz, world_camera.xz) > min_dist){
		mat4 scale_distance = mat4(1.0);
		scale_distance[1][1] /= (distance(worldPos.xz, world_camera.xz) - min_dist + smoothness) / smoothness;
		MODELVIEW_MATRIX *= scale_distance;
	}
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; // Transition from local space to world space
	
	//wind - globally same wind direction movement of each vertex
	//save local rotation of the vertex
	mat3 rotation_matrix = mat3(MODEL_MATRIX);
	vec3 object_vertex = rotation_matrix * VERTEX;
	float speed = 1.0;
	vec2 VectorOp = NODE_POSITION_WORLD.xz + TIME * speed / 100.0;
	vec3 noiseTexture = texture(wind_noise,VectorOp).rgb;
	vec3 wind_dir = vec3(0.0,0.1,0.0);
	
	//apply the transformation in world space
	object_vertex.x += (wind_dir.x + noiseTexture.x) * UV.y;
	object_vertex.z += (wind_dir.z + noiseTexture.z) * UV.y;
	
	//inverse back to the local space
	VERTEX = (inverse(rotation_matrix) * object_vertex);

	vec3 dir_to_left_foot = left_foot_position - MODEL_MATRIX[3].xyz;
	vec3 dir_to_right_foot = right_foot_position - MODEL_MATRIX[3].xyz;
	vec3 dir_to_foot;
	if (length(dir_to_left_foot) < length(dir_to_right_foot))
		dir_to_foot = dir_to_left_foot;
	else
		dir_to_foot = dir_to_right_foot;
	
	float distance_to_foot = length(dir_to_foot);
	if (distance_to_foot <= character_radius)
	{
		float falloff = 1.0 - smoothstep(0.0, 1.0, distance_to_foot/character_radius);
		dir_to_foot = (inverse(MODEL_MATRIX) * vec4(dir_to_foot, 0.0)).xyz;
		dir_to_foot = normalize(dir_to_foot);
		float falloff_curve = texture(character_distance_falloff_curve, vec2(falloff)).x;
		VERTEX += normalize(-dir_to_foot) * falloff_curve * character_push_strength * UV.y;
	}
}

void fragment() {
	vec3 noiseLevel = texture(noise, worldPos.xz / noiseScale).rgb; // Sample from noise texture according to coords
	ALBEDO = mix(color, color2, UV.y)* mix(color, color2, noiseLevel.r); //First mix is the gradient mentioned above, second is adding the noise
	if (!FRONT_FACING) {
		NORMAL = -NORMAL; // When back-face culling is disabled, this turns the back-facing normals correctly
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
