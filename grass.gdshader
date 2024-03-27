shader_type spatial;
render_mode cull_disabled; // Disable back-face culling so that both sides of the grass render

// 2 colors which make a gradient together (to color the grass depending on height)
uniform vec3 color : source_color;
uniform vec3 color2 : source_color;

uniform sampler2D noise;
uniform float noiseScale = 20.0;

varying vec3 worldPos;

void vertex() {
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; // Transition from local space to world space
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
