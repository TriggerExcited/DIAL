#version 450

/*
   Diagonal Alternating Blur for RetroArch slang.
   
   Copyright (C) 2023 TriggerExcited - TriggerExcited@gmail.com

   Permission is hereby granted, free of charge, to any person obtaining a copy
   of this software and associated documentation files (the "Software"), to deal
   in the Software without restriction, including without limitation the rights
   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
   copies of the Software, and to permit persons to whom the Software is
   furnished to do so, subject to the following conditions:

   The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
   THE SOFTWARE.
*/

#pragma parameter DIAL_BLUR_WEIGHT "Dial Blur Weight:" 0.0 0.0 0.9 0.01

layout(push_constant) uniform Push{
	vec4 SourceSize;
	vec4 OriginalSize;
	vec4 OutputSize;
	uint FrameCount;
	float DIAL_BLUR_WEIGHT;
} params;

layout(std140, set = 0, binding = 0) uniform UBO{
	mat4 MVP;
} global;

#pragma stage vertex
layout(location = 0) in vec4 Position;
layout(location = 1) in vec2 TexCoord;
layout(location = 0) out vec2 vTexCoord;

void main(){
	gl_Position = global.MVP * Position;
	vTexCoord = TexCoord;
}

#pragma stage fragment
layout(location = 0) in vec2 vTexCoord;
layout(location = 0) out vec4 FragColor;
layout(set = 0, binding = 2) uniform sampler2D Source;

// Stolen from fsr-pass1.slang
// prng: A simple but effective pseudo-random number generator [0;1[
float prng(vec2 uv, float time) {
    return fract(sin(dot(uv + fract(time), vec2(12.9898, 78.233))) * 43758.5453);
}

void main(){
	vec4 center_tap = texture(Source, vTexCoord);
	vec3 center = center_tap.rgb;
	float alt = mod(params.FrameCount + floor(center_tap.a * 10.0), 2.0) * 2.0 - 1.0;
	vec2 offset = vec2(0.5, 0.5 * alt);
	vec3 out0 = texture(Source, vTexCoord + offset * params.SourceSize.zw).rgb;
	vec3 out1 = texture(Source, vTexCoord - offset * params.SourceSize.zw).rgb;
	vec3 outp = mix(out0, out1, 0.5);
	float noise = prng(vTexCoord, params.FrameCount * 0.11 + center_tap.a) - 0.5;
	FragColor = vec4(mix(center, outp, params.DIAL_BLUR_WEIGHT + noise * clamp(params.DIAL_BLUR_WEIGHT, 0.0, 0.1)), center_tap.a + 0.1);
}
