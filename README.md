# DIAL
DIagonal ALternating blur implementation for RetroArch(slang). A high performance alternative to conventional blurs like Gaussian blur. Every shader pass increases the effective radius of the shader by one. The shader includes a weight parameter that controls the intensity of the blur. Note: this shader can create artifacts under (very) unstable frame rates. 
