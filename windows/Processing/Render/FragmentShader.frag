// #version 430 core

out vec4 out_color;

in vec3 pass_color;

void main()
{
    out_color = vec4(pass_color, 1.0f);
}