shader_type spatial;
render_mode cull_disabled; // Disable back-face culling so that both sides of the grass render

// 2 colors which make a gradient together (to color the grass depending on height)
uniform vec3 color : source_color;
uniform vec3 color2 : source_color;

uniform sampler2D noise;
uniform float noiseScale = 20.0;

varying vec3 worldPos;

//wind uniforms
uniform sampler2D wind_noise;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void vertex() {
	vec3 world_camera = CAMERA_POSITION_WORLD;
	vec4 a = MODEL_MATRIX * vec4(VERTEX, 1.0);
	
	float smoothness = 10.0;
	float min_dist = 50.0;
	
	if(distance(a.xz, world_camera.xz) > min_dist){
		mat4 scale_distance = mat4(1.0);
		scale_distance[1][1] /= (distance(a.xz, world_camera.xz) - min_dist + smoothness) / smoothness;
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
	vec3 wind_dir = vec3(2.0,0.1,1.);
	
	//apply the transformation in world space
	object_vertex.x += (wind_dir.x + noiseTexture.x) * UV.y;
	object_vertex.z += (wind_dir.z + noiseTexture.z) * UV.y;
	
	//inverse back to the local space
	VERTEX = (inverse(rotation_matrix) * object_vertex);
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
