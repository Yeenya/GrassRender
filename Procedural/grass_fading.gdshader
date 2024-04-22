shader_type spatial;
render_mode cull_disabled; // Disable back-face culling so that both sides of the grass render

// 2 colors which make a gradient together (to color the grass depending on height)
uniform vec3 color : source_color;
uniform vec3 color2 : source_color;

uniform sampler2D noise;
uniform float noiseScale = 20.0;

//wind uniforms
uniform float time_x_speed = 1.25;
uniform float time_y_speed = 0.4;
uniform float x_scale = 0.3;
uniform float y_scale = 0.2;

varying vec3 worldPos;

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
	
	//simple wind
	VERTEX.x += sin(NODE_POSITION_WORLD.x + TIME * time_x_speed + UV.y) * (UV.y) * x_scale;
	VERTEX.z += cos(NODE_POSITION_WORLD.z + TIME * time_y_speed + UV.y) * (UV.y) * y_scale;
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
