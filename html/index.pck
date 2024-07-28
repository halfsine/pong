GDPC                 p                                                                         P   res://.godot/exported/133200997/export-609f762188a68253d349ec58c4f3a8d3-game.scn .      �      ~�ؽ�x�M�`�v     ,   res://.godot/global_script_class_cache.cfg  �]             ��Р�8���8~$}P�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex�H            ：Qt�E�cO���       res://.godot/uid_cache.bin   b      g       5�pP��݃Q��b�       res://aiDumbness.gd.remap   �\      %       S�Q��=@\��-��V       res://aiDumbness.gdc        Y       \�Ry���NX��<*       res://ball.gd.remap �\             ��b�Heh7܉�	w       res://ball.gdc  `       b      d�9Ɗ�پ,z��+�       res://crt.gdshader  �      |)      �� *��w3M�Po$       res://game.gd.remap  ]             &=F�k'b�Зz��ع       res://game.gdc  P+      �      �Y�r|�`��o�I�k       res://game.tscn.remap    ]      a       �?��� �ު��y�       res://icon.svg  ^      �      �W|��/�\�pF[       res://icon.svg.import   �U      �       ��g�yY�ʖ���4       res://paddle1.gd.remap  �]      "       y�YC��Q��5�_�6       res://paddle1.gdc   �V      �      �����@���-n�7�       res://paddle2.gd.remap  �]      "       s�O`qe�4p���6��       res://paddle2.gdc   0Y      {      .$������mh*8��       res://project.binarypb      �      �%C*��O��YZL    GDSCd   D   (�/� D!            e         බ�嶶�ڶ��߶��Ҷ��Ӷ��Ķ���      �             GDSCd   L  (�/�`Le
 �%*�K�\��)�_nZ6��A�fI�Bz?�EE�b� �/l!���d�*S�D1n���E�Ӭ��<�'�4#�����6��<*�� �z ]�e�.*U�������X*4������e]�ӯ�
T8@��P���'���㗨~��B�A}�Fen��R��T�1����xA��F�^��0�c"	`���m��ntb2sY&j�0� �4u꟭�:�n�8���eN��x��m%�w��vat�?�n�pnzɚ`H��N=�\�[���˞g^��5-����}l�\.�5��n���9��>�'f�ߙR��&"�gɎ�b�꿟�^              /*
Shader from Godot Shaders - the free shader library.
godotshaders.com/shader/VHS-and-CRT-monitor-effect

This shader is under CC0 license. Feel free to use, improve and 
change this shader according to your needs and consider sharing 
the modified result to godotshaders.com.
*/

shader_type canvas_item;

//*** IMPORTANT! ***/ 
// - If you are using this shader to affect the node it is applied to set 'overlay' to false (unchecked in the instepctor).
// - If you are using this shader as an overlay, and want the shader to affect the nodes below in the Scene hierarchy,
//   set 'overlay' to true (checked in the inspector).
// On Mac there is potentially a bug causing this to not work properly. If that is the case and you want to use the shader as an overlay
// change all "overlay ? SCREEN_TEXTURE : TEXTURE" to only "SCREEN_TEXTURE" on lines 129-140, and "vec2 uv = overlay ? warp(SCREEN_UV) : warp(UV);"
// to "vec2 uv = warp(SCREEN_UV);" on line 98.
uniform bool overlay = false;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear;

uniform float scanlines_opacity : hint_range(0.0, 1.0) = 0.4;
uniform float scanlines_width : hint_range(0.0, 0.5) = 0.25;
uniform float grille_opacity : hint_range(0.0, 1.0) = 0.3;
uniform vec2 resolution = vec2(640.0, 480.0); // Set the number of rows and columns the texture will be divided in. Scanlines and grille will make a square based on these values

uniform bool pixelate = true; // Fill each square ("pixel") with a sampled color, creating a pixel look and a more accurate representation of how a CRT monitor would work.

uniform bool roll = true;
uniform float roll_speed = 8.0; // Positive values are down, negative are up
uniform float roll_size : hint_range(0.0, 100.0) = 15.0;
uniform float roll_variation : hint_range(0.1, 5.0) = 1.8; // This valie is not an exact science. You have to play around with the value to find a look you like. How this works is explained in the code below.
uniform float distort_intensity : hint_range(0.0, 0.2) = 0.05; // The distortion created by the rolling effect.

uniform float noise_opacity : hint_range(0.0, 1.0) = 0.4;
uniform float noise_speed = 5.0; // There is a movement in the noise pattern that can be hard to see first. This sets the speed of that movement.

uniform float static_noise_intensity : hint_range(0.0, 1.0) = 0.06;

uniform float aberration : hint_range(-1.0, 1.0) = 0.03; // Chromatic aberration, a distortion on each color channel.
uniform float brightness = 1.4; // When adding scanline gaps and grille the image can get very dark. Brightness tries to compensate for that.
uniform bool discolor = true; // Add a discolor effect simulating a VHS

uniform float warp_amount :hint_range(0.0, 5.0) = 1.0; // Warp the texture edges simulating the curved glass of a CRT monitor or old TV.
uniform bool clip_warp = false;

uniform float vignette_intensity = 0.4; // Size of the vignette, how far towards the middle it should go.
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;

// Used by the noise functin to generate a pseudo random value between 0.0 and 1.0
vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

// Generate a Perlin noise used by the distortion effects
float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) * 0.5 + 0.5;
}

// Takes in the UV and warps the edges, creating the spherized effect
vec2 warp(vec2 uv){
	vec2 delta = uv - 0.5;
	float delta2 = dot(delta.xy, delta.xy);
	float delta4 = delta2 * delta2;
	float delta_offset = delta4 * warp_amount;
	
	return uv + delta * delta_offset;
}

// Adds a black border to hide stretched pixel created by the warp effect
float border (vec2 uv){
	float radius = min(warp_amount, 0.08);
	radius = max(min(min(abs(radius * 2.0), abs(1.0)), abs(1.0)), 1e-5);
	vec2 abs_uv = abs(uv * 2.0 - 1.0) - vec2(1.0, 1.0) + radius;
	float dist = length(max(vec2(0.0), abs_uv)) / radius;
	float square = smoothstep(0.96, 1.0, dist);
	return clamp(1.0 - square, 0.0, 1.0);
}

// Adds a vignette shadow to the edges of the image
float vignette(vec2 uv){
	uv *= 1.0 - uv.xy;
	float vignette = uv.x * uv.y * 15.0;
	return pow(vignette, vignette_intensity * vignette_opacity);
}

void fragment()
{
	vec2 uv = overlay ? warp(SCREEN_UV) : warp(UV); // Warp the uv. uv will be used in most cases instead of UV to keep the warping
	vec2 text_uv = uv;
	vec2 roll_uv = vec2(0.0);
	float time = roll ? TIME : 0.0;
	

	// Pixelate the texture based on the given resolution.
	if (pixelate)
	{
		text_uv = ceil(uv * resolution) / resolution;
	}
	
	// Create the rolling effect. We need roll_line a bit later to make the noise effect.
	// That is why this runs if roll is true OR noise_opacity is over 0.
	float roll_line = 0.0;
	if (roll || noise_opacity > 0.0)
	{
		// Create the areas/lines where the texture will be distorted.
		roll_line = smoothstep(0.3, 0.9, sin(uv.y * roll_size - (time * roll_speed) ) );
		// Create more lines of a different size and apply to the first set of lines. This creates a bit of variation.
		roll_line *= roll_line * smoothstep(0.3, 0.9, sin(uv.y * roll_size * roll_variation - (time * roll_speed * roll_variation) ) );
		// Distort the UV where where the lines are
		roll_uv = vec2(( roll_line * distort_intensity * (1.-UV.x)), 0.0);
	}
	
	vec4 text;
	if (roll)
	{
		// If roll is true distort the texture with roll_uv. The texture is split up into RGB to 
		// make some chromatic aberration. We apply the aberration to the red and green channels accorging to the aberration parameter
		// and intensify it a bit in the roll distortion.
		text.r = texture(SCREEN_TEXTURE, text_uv + roll_uv * 0.8 + vec2(aberration, 0.0) * .1).r;
		text.g = texture(SCREEN_TEXTURE, text_uv + roll_uv * 1.2 - vec2(aberration, 0.0) * .1 ).g;
		text.b = texture(SCREEN_TEXTURE, text_uv + roll_uv).b;
		text.a = 1.0;
	}
	else
	{
		// If roll is false only apply the aberration without any distorion. The aberration values are very small so the .1 is only 
		// to make the slider in the Inspector less sensitive.
		text.r = texture(SCREEN_TEXTURE, text_uv + vec2(aberration, 0.0) * .1).r;
		text.g = texture(SCREEN_TEXTURE, text_uv - vec2(aberration, 0.0) * .1).g;
		text.b = texture(SCREEN_TEXTURE, text_uv).b;
		text.a = 1.0;
	}
	
	float r = text.r;
	float g = text.g;
	float b = text.b;
	
	uv = warp(UV);
	
	// CRT monitors don't have pixels but groups of red, green and blue dots or lines, called grille. We isolate the texture's color channels 
	// and divide it up in 3 offsetted lines to show the red, green and blue colors next to each other, with a small black gap between.
	if (grille_opacity > 0.0){
		
		float g_r = smoothstep(0.85, 0.95, abs(sin(uv.x * (resolution.x * 3.14159265))));
		r = mix(r, r * g_r, grille_opacity);
		
		float g_g = smoothstep(0.85, 0.95, abs(sin(1.05 + uv.x * (resolution.x * 3.14159265))));
		g = mix(g, g * g_g, grille_opacity);
		
		float b_b = smoothstep(0.85, 0.95, abs(sin(2.1 + uv.x * (resolution.x * 3.14159265))));
		b = mix(b, b * b_b, grille_opacity);
		
	}
	
	// Apply the grille to the texture's color channels and apply Brightness. Since the grille and the scanlines (below) make the image very dark you
	// can compensate by increasing the brightness.
	text.r = clamp(r * brightness, 0.0, 1.0);
	text.g = clamp(g * brightness, 0.0, 1.0);
	text.b = clamp(b * brightness, 0.0, 1.0);
	
	// Scanlines are the horizontal lines that make up the image on a CRT monitor. 
	// Here we are actual setting the black gap between each line, which I guess is not the right definition of the word, but you get the idea  
	float scanlines = 0.5;
	if (scanlines_opacity > 0.0)
	{
		// Same technique as above, create lines with sine and applying it to the texture. Smoothstep to allow setting the line size.
		scanlines = smoothstep(scanlines_width, scanlines_width + 0.5, abs(sin(uv.y * (resolution.y * 3.14159265))));
		text.rgb = mix(text.rgb, text.rgb * vec3(scanlines), scanlines_opacity);
	}
	
	// Apply the banded noise.
	if (noise_opacity > 0.0)
	{
		// Generate a noise pattern that is very stretched horizontally, and animate it with noise_speed
		float noise = smoothstep(0.4, 0.5, noise(uv * vec2(2.0, 200.0) + vec2(10.0, (TIME * (noise_speed))) ) );
		
		// We use roll_line (set above) to define how big the noise should be vertically (multiplying cuts off all black parts).
		// We also add in some basic noise with random() to break up the noise pattern above. The noise is sized according to 
		// the resolution value set in the inspector. If you don't like this look you can 
		// change "ceil(uv * resolution) / resolution" to only "uv" to make it less pixelated. Or multiply resolution with som value
		// greater than 1.0 to make them smaller.
		roll_line *= noise * scanlines * clamp(random((ceil(uv * resolution) / resolution) + vec2(TIME * 0.8, 0.0)).x + 0.8, 0.0, 1.0);
		// Add it to the texture based on noise_opacity
		text.rgb = clamp(mix(text.rgb, text.rgb + roll_line, noise_opacity), vec3(0.0), vec3(1.0));
	}
	
	// Apply static noise by generating it over the whole screen in the same way as above
	if (static_noise_intensity > 0.0)
	{
		text.rgb += clamp(random((ceil(uv * resolution) / resolution) + fract(TIME)).x, 0.0, 1.0) * static_noise_intensity;
	}
	
	// Apply a black border to hide imperfections caused by the warping.
	// Also apply the vignette
	text.rgb *= border(uv);
	text.rgb *= vignette(uv);
	// Hides the black border and make that area transparent. Good if you want to add the the texture on top an image of a TV or monitor.
	if (clip_warp)
	{
		text.a = border(uv);
	}
	
	// Apply discoloration to get a VHS look (lower saturation and higher contrast)
	// You can play with the values below or expose them in the Inspector.
	float saturation = 0.5;
	float contrast = 1.2;
	if (discolor)
	{
		// Saturation
		vec3 greyscale = vec3(text.r + text.g + text.b) / 3.;
		text.rgb = mix(text.rgb, greyscale, saturation);
		
		// Contrast
		float midpoint = pow(0.5, 2.2);
		text.rgb = (text.rgb - vec3(midpoint)) * contrast + midpoint;
	}
	
	COLOR = text;
}    GDSCd   �  (�/�`�� �E=P�(�(��|U9�b]�V�`��[�b.�b4����Bm'�X$C�h�p�X�Fq���Ēi��$* ; 1 =�1�����k;jK2���Z�m1چmEڎ�E�[~���g�ʏj��T$��)I����e	�+� �
�Q�� �?3i�� �D��m�֣B l�j`�}�fG%�L�u19����ʲ+�.�K���~����{?����
���t�O����RJ)c�1F������4�P@��	~2�]�S9Sc35��u.�qZ��0 �e\&J��ˠP6���i������!&�z��3+U�����6�Ŋ\y�{�3�43��c�q�O�x=�l��n7B�W�0�:���A���C1�~����	�y��oz��ܝ�uY�}�VR샽=��G{Y����4�ڰ����HQ@9�}��J���� � }>�9���S�ai�F���g���n
��|´C�~����/���ὺ�}��"�?���~J娞�J�S�����������Yq�
���Ml�g�L.����8o���E�B�\zی���2j����jm�.�]�����߅3�;���Ċ�2t�.��`��y3o�8�u����V����_�p�n�K&�a^=&�N���{737>��<L�?���_�/U      RSRC                    PackedScene            ��������                                            !      Ball    resource_local_to_scene    resource_name 	   friction    rough    bounce 
   absorbent    script    custom_solver_bias    size    shader    shader_parameter/overlay #   shader_parameter/scanlines_opacity !   shader_parameter/scanlines_width     shader_parameter/grille_opacity    shader_parameter/resolution    shader_parameter/pixelate    shader_parameter/roll    shader_parameter/roll_speed    shader_parameter/roll_size     shader_parameter/roll_variation #   shader_parameter/distort_intensity    shader_parameter/noise_opacity    shader_parameter/noise_speed (   shader_parameter/static_noise_intensity    shader_parameter/aberration    shader_parameter/brightness    shader_parameter/discolor    shader_parameter/warp_amount    shader_parameter/clip_warp $   shader_parameter/vignette_intensity "   shader_parameter/vignette_opacity 	   _bundled       Script    res://game.gd ��������   Script    res://ball.gd ��������   Script    res://paddle1.gd ��������   Script    res://paddle2.gd ��������   Shader    res://crt.gdshader ��������
      local://PhysicsMaterial_w7222 S         local://RectangleShape2D_kno4b �         local://RectangleShape2D_pdwrb �         local://RectangleShape2D_s10b8 �         local://RectangleShape2D_yili1          local://RectangleShape2D_ynd0s O         local://RectangleShape2D_w64ea �         local://RectangleShape2D_a02c8 �         local://ShaderMaterial_2u148 �         local://PackedScene_wty1u 1	         PhysicsMaterial                       A         RectangleShape2D    	   
      B   B         RectangleShape2D    	   
     �?  �C         RectangleShape2D    	   
    `�D  �C         RectangleShape2D    	   
    ��C  �D         RectangleShape2D    	   
      B  HC         RectangleShape2D    	   
     �C  �C         RectangleShape2D    	   
     �A  aD         ShaderMaterial    
                        )   �� �rh�?        �>        �>   
      D  �C                           A        pA   )   �������?   )   {�G�zt?   )   ;�O��n�?        �@   )   ���Q��?   )   ���Q��?        �?                 �?             )   �������?   )   q=
ףp�?         PackedScene           	         names "   G      Game    process_mode    script    ball    Node2D    Ball    collision_layer    physics_material_override    gravity_scale 
   can_sleep    lock_rotation    linear_velocity    linear_damp    RigidBody2D    ColorRect2    anchors_preset    anchor_left    anchor_top    anchor_right    anchor_bottom    offset_left    offset_top    offset_right    offset_bottom    grow_horizontal    grow_vertical 
   ColorRect    CollisionShape2D    shape    Area2D    StaticBody2D 	   position    CollisionShape2D2    CollisionShape2D3    CollisionShape2D4    Paddle1    CharacterBody2D    metadata/_edit_use_anchors_    Paddle2    Below    Above    PaddleZone1    PaddleZone2    Score1    texture_filter    scale    text    horizontal_alignment    vertical_alignment    Label    Score2 	   Camera2D    zoom    Control    layout_mode    size_flags_horizontal    size_flags_vertical    Panel    VSlider 
   max_value    step    value    rounded    visibility_layer 	   material    mouse_filter    _on_paddle_zone_1_area_entered    area_entered    _on_paddle_zone_2_area_entered    _on_v_slider_value_changed    value_changed    	   variants    H                                                                        
     H�  HB   ��L�                     ?     ��     �A                        
         D         
         �
    `=D             
     >�  ��
    ��                  ��     �B         
    �D             
     ��  �C         
     ��  ��
    ��    
     `�  ��         
    @D               ��     ��     X�    ���
     @@  @@      0      C     0C
   {?{?     �     ��     D     �C           �?   ����   u�>   /��     8�   ���A     HC    ��D     HB     C   +�     �   ��     ��   �O1�
   ��!@��!@      AI smartness                node_count    !         nodes     &  ��������       ����                  @                     ����	                           	      
         	      
                          ����                                                                                      ����                          ����                       ����                           ����                          ����                                 ����                             !   ����                             "   ����                           $   #   ����                                      ����                                                                     %                       ����                     $   &   ����                                      ����                                                                     %                       ����                       '   ����                           ����      !                 (   ����      "                    ����      !                  )   ����            #                    ����      $      %                  *   ����            &                    ����      $      %               1   +   ����   ,         '                  (      )      *      +         -   ,   .   -   /      0                  1   2   ����   ,                                       .      )      /      +               -   ,   .   -   /      0                  3   3   ����   4   0              5   5   ����   6                1      2      3      4   7       8                  9   9   ����   6         5      6      6               %                 :   :   ����   6         7      8            8            9      :      ;      <   ;   =   <   >   =   ?   >                 1   1   ����   ,      6         7            @            @      A      B      C      D   -   E   .   F                    ����	   ?      @   G   6         5      6      6               A                conn_count             conns              C   B                    C   D                     F   E                    node_paths              editable_instances              version             RSRC       GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�m�m۬�}�p,��5xi�d�M���)3��$�V������3���$G�$2#�Z��v{Z�lێ=W�~� �����d�vF���h���ڋ��F����1��ڶ�i�엵���bVff3/���Vff���Ҿ%���qd���m�J�}����t�"<�,���`B �m���]ILb�����Cp�F�D�=���c*��XA6���$
2#�E.@$���A.T�p )��#L��;Ev9	Б )��D)�f(qA�r�3A�,#ѐA6��npy:<ƨ�Ӱ����dK���|��m�v�N�>��n�e�(�	>����ٍ!x��y�:��9��4�C���#�Ka���9�i]9m��h�{Bb�k@�t��:s����¼@>&�r� ��w�GA����ը>�l�;��:�
�wT���]�i]zݥ~@o��>l�|�2�Ż}�:�S�;5�-�¸ߥW�vi�OA�x��Wwk�f��{�+�h�i�
4�˰^91��z�8�(��yޔ7֛�;0����^en2�2i�s�)3�E�f��Lt�YZ���f-�[u2}��^q����P��r��v��
�Dd��ݷ@��&���F2�%�XZ!�5�.s�:�!�Њ�Ǝ��(��e!m��E$IQ�=VX'�E1oܪì�v��47�Fы�K챂D�Z�#[1-�7�Js��!�W.3׹p���R�R�Ctb������y��lT ��Z�4�729f�Ј)w��T0Ĕ�ix�\�b�9�<%�#Ɩs�Z�O�mjX �qZ0W����E�Y�ڨD!�$G�v����BJ�f|pq8��5�g�o��9�l�?���Q˝+U�	>�7�K��z�t����n�H�+��FbQ9���3g-UCv���-�n�*���E��A�҂
�Dʶ� ��WA�d�j��+�5�Ȓ���"���n�U��^�����$G��WX+\^�"�h.���M�3�e.
����MX�K,�Jfѕ*N�^�o2��:ՙ�#o�e.
��p�"<W22ENd�4B�V4x0=حZ�y����\^�J��dg��_4�oW�d�ĭ:Q��7c�ڡ��
A>��E�q�e-��2�=Ϲkh���*���jh�?4�QK��y@'�����zu;<-��|�����Y٠m|�+ۡII+^���L5j+�QK]����I �y��[�����(}�*>+���$��A3�EPg�K{��_;�v�K@���U��� gO��g��F� ���gW� �#J$��U~��-��u���������N�@���2@1��Vs���Ŷ`����Dd$R�":$ x��@�t���+D�}� \F�|��h��>�B�����B#�*6��  ��:���< ���=�P!���G@0��a��N�D�'hX�׀ "5#�l"j߸��n������w@ K�@A3�c s`\���J2�@#�_ 8�����I1�&��EN � 3T�����MEp9N�@�B���?ϓb�C��� � ��+�����N-s�M�  ��k���yA 7 �%@��&��c��� �4�{� � �����"(�ԗ�� �t�!"��TJN�2�O~� fB�R3?�������`��@�f!zD��%|��Z��ʈX��Ǐ�^�b��#5� }ى`�u�S6�F�"'U�JB/!5�>ԫ�������/��;	��O�!z����@�/�'�F�D"#��h�a �׆\-������ Xf  @ �q�`��鎊��M��T�� ���0���}�x^�����.�s�l�>�.�O��J�d/F�ě|+^�3�BS����>2S����L�2ޣm�=�Έ���[��6>���TъÞ.<m�3^iжC���D5�抺�����wO"F�Qv�ږ�Po͕ʾ��"��B��כS�p�
��E1e�������*c�������v���%'ž��&=�Y�ް>1�/E������}�_��#��|������ФT7׉����u������>����0����緗?47�j�b^�7�ě�5�7�����|t�H�Ե�1#�~��>�̮�|/y�,ol�|o.��QJ rmϘO���:��n�ϯ�1�Z��ը�u9�A������Yg��a�\���x���l���(����L��a��q��%`�O6~1�9���d�O{�Vd��	��r\�՜Yd$�,�P'�~�|Z!�v{�N�`���T����3?DwD��X3l �����*����7l�h����	;�ߚ�;h���i�0�6	>��-�/�&}% %��8���=+��N�1�Ye��宠p�kb_����$P�i�5�]��:��Wb�����������ě|��[3l����`��# -���KQ�W�O��eǛ�"�7�Ƭ�љ�WZ�:|���є9�Y5�m7�����o������F^ߋ������������������Р��Ze�>�������������?H^����&=����~�?ڭ�>���Np�3��~���J�5jk�5!ˀ�"�aM��Z%�-,�QU⃳����m����:�#��������<�o�����ۇ���ˇ/�u�S9��������ٲG}��?~<�]��?>��u��9��_7=}�����~����jN���2�%>�K�C�T���"������Ģ~$�Cc�J�I�s�? wڻU���ə��KJ7����+U%��$x�6
�$0�T����E45������G���U7�3��Z��󴘶�L�������^	dW{q����d�lQ-��u.�:{�������Q��_'�X*�e�:�7��.1�#���(� �k����E�Q��=�	�:e[����u��	�*�PF%*"+B��QKc˪�:Y��ـĘ��ʴ�b�1�������\w����n���l镲��l��i#����!WĶ��L}rեm|�{�\�<mۇ�B�HQ���m�����x�a�j9.�cRD�@��fi9O�.e�@�+�4�<�������v4�[���#bD�j��W����֢4�[>.�c�1-�R�����N�v��[�O�>��v�e�66$����P
�HQ��9���r�	5FO� �<���1f����kH���e�;����ˆB�1C���j@��qdK|
����4ŧ�f�Q��+�     [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://bow2patyqpu38"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
                GDSCd   0  (�/�`0� 6TD>0�8�0n��Ч7؋�C��g�>�Ha�Z�����z�Hab�0�́�V{��AOH�m)) 7 / ��V~�m����������/�-J[�Jۖ�/m������=��7 ��~��	C��1�$3�8ݟ�%�՘pr����
hk�-ן���	��. Ti�4�Q���4L�4��'���C8�����/�
?�#�QF�B��`�QE��}�O�B�6A2?R3E0�f�=��x`fS�ậ�8$�27�&�`�*lj�&�M��S���U�Q���r�D)'!Љ�La*�����>woƗn�r4��/�����Uu��Q�7�^ޔ�Ύ�U=8��n�^$.V�J��vtL��%p��6��e'.�j�[�V���]O�L�>�TF��Yc�Wu�DP"��%$�(7�N opLǬ�~�_��UY:�Aa?;][K��K��Vzm.�����)���(�yߠ��"���AۡO��8�U�z;���\���p���qQ'�Px�O}��	�T�ܹG{S�4��9�jÉ��O���h��2:�Yj���ɡƎ#��n�P6�p��]�/����W�!�؄�Y��Vw�ɡpޛs����k빿�/��G�P��&x�f�9����qYC��ǖ��W�1榬<u�\     GDSCd   8
  (�/�`8	- f�XBq���@2ʋ�j���v`��KQ�� W�
W�%�x`�4�ƈ�`=���E �i���n���.i��; M = �H�+TT�e������іƏ��_[m=�=�������kˢm���.mg���{����ÿ~�oR������_1E���@��1����7UЀ�d!�ur��f}�`>P`���;my���6G����&�2�,*�
�o���L��D>��|���,�/�������O��O�K?���/H��~��$MӴmSD3�"��!�d�\�$�LP�y�p��ÕH)BvF���;ar�p 1d��|����`���Kn��l���9MdYE&�(!_��t��Y��$u
��)�y���LaQ*fh�/,���Ԓ̘߂a߀���ׂA6���>�cSc�ח�$��A����a4V( �-r"��8�x�-%�Ő���QZ�_T0AN�]dOݘ���I�� ���o+����,�����Z�o������ /R6H��{>�g6��U�z�X
���) ���Τ������Z��ڪ΢��W�מ��Y|J�`e0�`P�	</��]̭�6��)�P�b�5��|nQ�����b�_�Rq��<�7�q�n�;ɧ��8�뛜Sl3y���f��d�^��۪N����"�����	D���x0=�Ϳ�#9�ã|�ݰ_=&���k�V���S�Pr=̔m����C��g~���4������<"ofȗ�N(ޛ?���:�������j߻=�r��n�Rל��-y�rD3��\�|~l̸�k������.V�q4����愜���N�e�����y���Kv�����ꐌ�k��Y�W�     [remap]

path="res://aiDumbness.gdc"
           [remap]

path="res://ball.gdc"
 [remap]

path="res://game.gdc"
 [remap]

path="res://.godot/exported/133200997/export-609f762188a68253d349ec58c4f3a8d3-game.scn"
               [remap]

path="res://paddle1.gdc"
              [remap]

path="res://paddle2.gdc"
              list=Array[Dictionary]([])
     <svg xmlns="http://www.w3.org/2000/svg" width="128" height="128"><rect width="124" height="124" x="2" y="2" fill="#363d52" stroke="#212532" stroke-width="4" rx="14"/><g fill="#fff" transform="translate(12.322 12.322)scale(.101)"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 814 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H446l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c0 34 58 34 58 0v-86c0-34-58-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042" transform="translate(12.322 12.322)scale(.101)"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></svg>                 �b~��h/   res://icon.svg�{]x�q   res://game.tscnew\�H$"   res://html/overcomplicatedpong.png         ECFG      application/config/name         Overcomplicated Pong   application/run/main_scene         res://game.tscn    application/config/features$   "         4.3    Forward Plus    "   application/boot_splash/show_image             application/config/icon         res://icon.svg  "   display/window/size/viewport_width      �  #   display/window/size/viewport_height      �     display/window/stretch/mode         viewport   global_group/ball          	   input/up1�              events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   W   	   key_label             unicode    w      location          echo          script            deadzone      ?   input/down1�              events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   S   	   key_label             unicode    s      location          echo          script            deadzone      ?
   input/menu�              events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode    @ 	   key_label             unicode           location          echo          script            deadzone      ?2   rendering/environment/defaults/default_clear_color                    �?              