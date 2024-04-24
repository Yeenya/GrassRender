shader_type spatial;
render_mode cull_disabled; // Disable back-face culling so that both sides of the grass render

// 2 colors which make a gradient together (to color the grass depending on height)
uniform vec3 color : source_color;
uniform vec3 color2 : source_color;

uniform sampler2D noise;
uniform float noiseScale = 20.0;

uniform vec3 character_position;
uniform float character_radius = 3.0;
uniform sampler2D character_distance_falloff_curve : hint_default_black;
uniform float character_push_strength = 1.0;

varying vec3 worldPos;

void vertex() {
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; // Transition from local space to world space
	
	vec3 dir_to_character = character_position - MODEL_MATRIX[3].xyz;
	//dir_to_character.y = 0.0; for horizontal push only
	
	float distance_to_character = length(dir_to_character);
	if (distance_to_character <= character_radius)
	{
		float falloff = 1.0 - smoothstep(0.0, 1.0, distance_to_character/character_radius);
		dir_to_character = (inverse(MODEL_MATRIX) * vec4(dir_to_character, 0.0)).xyz;
		dir_to_character = normalize(dir_to_character);
		float falloff_curve = texture(character_distance_falloff_curve, vec2(falloff)).x;
		VERTEX += normalize(-dir_to_character) * falloff_curve * character_push_strength * UV.y;
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
