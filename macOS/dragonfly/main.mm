//
//  main.m
//  dragonfly
//
//  Created by Thomas Liang on 1/13/22.
//

#include <stdio.h>
#include <iostream>
#include <fstream>
#include <filesystem>
#include <math.h>

#include "imgui.h"
#include "imgui_impl_sdl.h"
#include "imgui_impl_metal.h"
#include <SDL.h>
#include <simd/SIMD.h>

#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>

#include "Model.h"
#include "Arrow.h"

struct Camera {
    simd_float3 pos;
    simd_float3 vector;
    simd_float3 up_vector;
    simd_float2 FOV;
};

struct Pixel {
    int x;
    int y;
};

struct ModelUniforms {
    simd_float3 position;
    simd_float3 rotate_origin;
    simd_float3 angle;
};

struct Uniforms {
    uint32 modelID;
    uint32 num_faces;
    uint32 selected_face;
    simd_float3 selected_vertex;
};

// screen variables
int window_width = 1280;
int window_height = 720;
float aspect_ratio = 1280.0/720.0;

float clear_color[4] = {0.45f, 0.55f, 0.60f, 1.00f};
bool show_main_window = true;

// imgui/sdl variables
SDL_Window* window;
SDL_Renderer* renderer;
float fps = 0;

// metal variables
MTLRenderPassDescriptor* render_pass_descriptor;

CAMetalLayer *layer;
id <MTLDevice> device;
id <MTLCommandQueue> command_queue;

std::vector<simd_float3> scene_vertices;
std::vector<Face> scene_faces;
std::vector<uint32> modelIDs;
unsigned arrows_vertex_end = 0;
unsigned arrows_face_end = 0;

id <MTLComputePipelineState> scene_compute_rotated_pipeline_state;
id <MTLComputePipelineState> scene_compute_projected_pipeline_state;

id <MTLRenderPipelineState> scene_render_pipeline_state;
id <MTLRenderPipelineState> scene_edge_render_pipeline_state;
id <MTLRenderPipelineState> scene_point_render_pipeline_state;

id <MTLDepthStencilState> depth_state;

id <MTLBuffer> scene_vertex_buffer;
id <MTLBuffer> scene_face_buffer;
id <MTLBuffer> scene_model_id_buffer;
id <MTLBuffer> scene_camera_buffer;
id <MTLBuffer> rotate_uniforms_buffer;

id <MTLTexture> depth_texture;

// scene variables
Camera *camera;
Model *cube;
Arrow *z_arrow;
Arrow *x_arrow;
Arrow *y_arrow;
std::vector<ModelUniforms> model_uniforms;

// input variables
bool left_clicked = false;
bool right_clicked = false;
// w a s d space shift
bool key_presses[6] = { 0 };
float x_sens = 0.1;
float y_sens = 0.1;

void CreateScenePipelineStates () {
    CGSize drawableSize = layer.drawableSize;
    MTLTextureDescriptor *descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float width:drawableSize.width height:drawableSize.height mipmapped:NO];
    descriptor.storageMode = MTLStorageModePrivate;
    descriptor.usage = MTLTextureUsageRenderTarget;
    depth_texture = [device newTextureWithDescriptor:descriptor];
    depth_texture.label = @"DepthStencil";
    
    MTLRenderPipelineDescriptor *render_pipeline_descriptor = [[MTLRenderPipelineDescriptor alloc] init];
    
    id <MTLLibrary> library = [device newDefaultLibrary];
    
    render_pipeline_descriptor.vertexFunction = [library newFunctionWithName:@"DefaultVertexShader"];
    render_pipeline_descriptor.fragmentFunction = [library newFunctionWithName:@"FragmentShader"];
    render_pipeline_descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    render_pipeline_descriptor.colorAttachments[0].pixelFormat = layer.pixelFormat;
    
    MTLRenderPipelineDescriptor *edge_render_pipeline_descriptor = [[MTLRenderPipelineDescriptor alloc] init];
    
    edge_render_pipeline_descriptor.vertexFunction = [library newFunctionWithName:@"VertexEdgeShader"];
    edge_render_pipeline_descriptor.fragmentFunction = [library newFunctionWithName:@"FragmentShader"];
    edge_render_pipeline_descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    edge_render_pipeline_descriptor.colorAttachments[0].pixelFormat = layer.pixelFormat;
    
    MTLRenderPipelineDescriptor *scene_point_render_pipeline_descriptor = [[MTLRenderPipelineDescriptor alloc] init];
    
    scene_point_render_pipeline_descriptor.vertexFunction = [library newFunctionWithName:@"VertexPointShader"];
    scene_point_render_pipeline_descriptor.fragmentFunction = [library newFunctionWithName:@"FragmentShader"];
    scene_point_render_pipeline_descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    scene_point_render_pipeline_descriptor.colorAttachments[0].pixelFormat = layer.pixelFormat;
    
    scene_compute_rotated_pipeline_state = [device newComputePipelineStateWithFunction:[library newFunctionWithName:@"CalculateRotatedVertices"] error:nil];
    scene_compute_projected_pipeline_state = [device newComputePipelineStateWithFunction:[library newFunctionWithName:@"CalculateProjectedVertices"] error:nil];
    scene_render_pipeline_state = [device newRenderPipelineStateWithDescriptor:render_pipeline_descriptor error:nil];
    scene_edge_render_pipeline_state = [device newRenderPipelineStateWithDescriptor:edge_render_pipeline_descriptor error:nil];
    scene_point_render_pipeline_state = [device newRenderPipelineStateWithDescriptor:scene_point_render_pipeline_descriptor error:nil];
    
    MTLDepthStencilDescriptor *depth_descriptor = [[MTLDepthStencilDescriptor alloc] init];
    [depth_descriptor setDepthCompareFunction: MTLCompareFunctionLessEqual];
    [depth_descriptor setDepthWriteEnabled: true];
    depth_state = [device newDepthStencilStateWithDescriptor: depth_descriptor];
}

void CreateBuffers() {
    z_arrow->AddToBuffers(scene_vertices, scene_faces, modelIDs, 0);
    x_arrow->AddToBuffers(scene_vertices, scene_faces, modelIDs, scene_vertices.size());
    y_arrow->AddToBuffers(scene_vertices, scene_faces, modelIDs, scene_vertices.size());
    arrows_vertex_end = scene_vertices.size();
    arrows_face_end = scene_faces.size();
    cube->AddToBuffers(scene_vertices, scene_faces, modelIDs, scene_vertices.size());
    //scene_vertices = up_arrow->GetVertices();//cube->GetVertices();
    //scene_faces = up_arrow->GetFaces();//cube->GetFaces();
    
    scene_vertex_buffer = [device newBufferWithBytes:scene_vertices.data() length:(scene_vertices.size() * sizeof(simd_float3)) options:MTLResourceStorageModeShared];
    scene_face_buffer = [device newBufferWithBytes:scene_faces.data() length:(scene_faces.size() * sizeof(Face)) options:MTLResourceStorageModeShared];
    scene_model_id_buffer = [device newBufferWithBytes:modelIDs.data() length:(modelIDs.size() * sizeof(uint32)) options:MTLResourceStorageModeShared];
    scene_camera_buffer = [device newBufferWithBytes:camera length:sizeof(Camera) options:{}];
    rotate_uniforms_buffer = [device newBufferWithBytes: model_uniforms.data() length:(model_uniforms.size() * sizeof(ModelUniforms)) options:{}];
}

int SetupImGui () {
    // Setup ImGui context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;

    // Setup IO
    io.WantCaptureKeyboard = true;

    // Setup style
    ImGui::StyleColorsDark();

    // Setup SDL
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_GAMECONTROLLER) != 0)
    {
        printf("Error: %s\n", SDL_GetError());
        return -1;
    }

    // Inform SDL that we will be using metal for rendering. Without this hint initialization of metal renderer may fail.
    SDL_SetHint(SDL_HINT_RENDER_DRIVER, "metal");
    
    // get screen size
    SDL_DisplayMode DM;
    SDL_GetCurrentDisplayMode(0, &DM);
    auto width = DM.w;
    auto height = DM.h;
    
    window = SDL_CreateWindow("dragonfly", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI);
    if (window == NULL)
    {
        printf("Error creating window: %s\n", SDL_GetError());
        return -2;
    }

    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (renderer == NULL)
    {
        printf("Error creating renderer: %s\n", SDL_GetError());
        return -3;
    }

    // Setup Platform/Renderer backends
    layer = (__bridge CAMetalLayer*)SDL_RenderGetMetalLayer(renderer);
    layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    ImGui_ImplMetal_Init(layer.device);
    ImGui_ImplSDL2_InitForMetal(window);
    
    device = layer.device;

    command_queue = [layer.device newCommandQueue];
    render_pass_descriptor = [MTLRenderPassDescriptor new];
    
    return 0;
}

void RenderUI() {
    // scene window
    ImGui::SetNextWindowPos(ImVec2(0, 0));
    ImGui::SetNextWindowSize(ImVec2(window_width, window_height));
    ImGui::PushStyleColor(ImGuiCol_WindowBg, ImVec4(0.0f, 0.0f, 0.0f, 0.0f));
    ImGui::Begin("main", &show_main_window, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoResize);

    // Display FPS
    ImGui::SetCursorPos(ImVec2(window_width - 80, 10));
    ImGui::Text("%.1f FPS", ImGui::GetIO().Framerate);
    ImGui::PopStyleColor();
    ImGui::End();
}

void HandleKeyboardEvents(SDL_Event event) {
    if (event.type == SDL_KEYDOWN) {
        SDL_Keysym keysym = event.key.keysym;
        switch (keysym.sym) {
            case 119:
                // w
                key_presses[0] = true;
                break;
            case 97:
                // a
                key_presses[1] = true;
                break;
            case 115:
                // s
                key_presses[2] = true;
                break;
            case 100:
                // d
                key_presses[3] = true;
                break;
            case 32:
                // spacebar
                key_presses[4] = true;
                break;
            case 1073742049:
                // shift
                key_presses[5] = true;
                break;
        }
    } else if (event.type == SDL_KEYUP) {
        SDL_Keysym keysym = event.key.keysym;
        switch (keysym.sym) {
            case 119:
                key_presses[0] = false;
                break;
            case 97:
                key_presses[1] = false;
                break;
            case 115:
                key_presses[2] = false;
                break;
            case 100:
                key_presses[3] = false;
                break;
            case 32:
                key_presses[4] = false;
                break;
            case 1073742049:
                key_presses[5] = false;
                break;
            default:
                break;
        }
    }
}

/*void SetSelectedVertex(int click_x, int click_y) {
    for (int i = 0; i < scene_point_vertices.size(); i+=4) {
        float normal_x = ((float) click_x)/((float) window_width);
        float normal_y = ((float) click_y)/((float) window_height);
        
        float min_x = scene_point_vertices.at(i).x;
        float min_y = scene_point_vertices.at(i).y;
        float max_x = scene_point_vertices.at(i+3).x;
        float max_y = scene_point_vertices.at(i+3).y;
        
        if (normal_x > min_x && normal_x < max_x && normal_y > min_y && normal_y < max_y) {
            
        }
    }
}*/

void HandleMouseEvents(SDL_Event event) {
    if (event.type == SDL_MOUSEBUTTONDOWN) {
        switch (event.button.button) {
            case SDL_BUTTON_LEFT:
                left_clicked = true;
                break;
            case SDL_BUTTON_RIGHT:
                right_clicked = true;
                break;
            default:
                break;
        }
    } else if (event.type == SDL_MOUSEBUTTONUP) {
        switch (event.button.button) {
            case SDL_BUTTON_LEFT:
                left_clicked = false;
                break;
            case SDL_BUTTON_RIGHT:
                right_clicked = false;
                break;
            default:
                break;
        }
    }
    
    if (event.type == SDL_MOUSEMOTION) {
        if (left_clicked) {
            //get current camera angles (phi is vertical and theta is horizontal)
            //get the new change based on the amount the mouse moved
            float curr_phi = atan2(camera->vector.y, camera->vector.x);
            float phi_change = x_sens*event.motion.xrel*(M_PI/180);
            
            float curr_theta = acos(camera->vector.z);
            float theta_change = y_sens*event.motion.yrel*(M_PI/180);
            
            //get new phi and theta angles
            float new_phi = curr_phi + phi_change;
            float new_theta = curr_theta + theta_change;
            //set the camera "pointing" vector to spherical -> cartesian
            camera->vector.x = sin(new_theta)*cos(new_phi);
            camera->vector.y = sin(new_theta)*sin(new_phi);
            camera->vector.z = cos(new_theta);
            //set the camera perpendicular "up" vector the same way but adding pi/2 to theta
            camera->up_vector.x = sin(new_theta-M_PI_2)*cos(new_phi);
            camera->up_vector.y = sin(new_theta-M_PI_2)*sin(new_phi);
            camera->up_vector.z = cos(new_theta-M_PI_2);
        }
    }
}

void HandleCameraInput() {
    // find unit vector of xy camera vector
    float magnitude = sqrt(pow(camera->vector.x, 2)+pow(camera->vector.y, 2));
    float unit_x = camera->vector.x/magnitude;
    float unit_y = camera->vector.y/magnitude;
    
    if (key_presses[0]) {
        camera->pos.x += (3.0/fps)*unit_x;
        camera->pos.y += (3.0/fps)*unit_y;
    }
    if (key_presses[1]) {
        camera->pos.y -= (3.0/fps)*unit_x;
        camera->pos.x += (3.0/fps)*unit_y;
    }
    if (key_presses[2]) {
        camera->pos.x -= (3.0/fps)*unit_x;
        camera->pos.y -= (3.0/fps)*unit_y;
    }
    if (key_presses[3]) {
        camera->pos.y += (3.0/fps)*unit_x;
        camera->pos.x -= (3.0/fps)*unit_y;
    }
    if (key_presses[4]) {
        camera->pos.z += (3.0/fps);
    }
    if (key_presses[5]) {
        camera->pos.z -= (3.0/fps);
    }
}

int main(int, char**) {
    if (SetupImGui() != 0) {
        return -1;
    }
    
    z_arrow = new Arrow(0);
    
    ModelUniforms z_arrow_uniform;
    z_arrow_uniform.position = simd_make_float3(0, 0, 1);
    z_arrow_uniform.rotate_origin = simd_make_float3(0, 0, 1);
    z_arrow_uniform.angle = simd_make_float3(0, 0, 0);
    
    model_uniforms.push_back(z_arrow_uniform);
    
    x_arrow = new Arrow(1, simd_make_float4(0, 1, 0, 1));
    
    ModelUniforms x_arrow_uniform;
    x_arrow_uniform.position = simd_make_float3(0, 0, 1);
    x_arrow_uniform.rotate_origin = simd_make_float3(0, 0, 1);
    x_arrow_uniform.angle = simd_make_float3(M_PI_2, 0, 0);
    
    model_uniforms.push_back(x_arrow_uniform);
    
    y_arrow = new Arrow(2, simd_make_float4(0, 0, 1, 1));
    
    ModelUniforms y_arrow_uniform;
    y_arrow_uniform.position = simd_make_float3(0, 0, 1);
    y_arrow_uniform.rotate_origin = simd_make_float3(0, 0, 1);
    y_arrow_uniform.angle = simd_make_float3(0, -M_PI_2, 0);
    
    model_uniforms.push_back(y_arrow_uniform);
    
    cube = new Model(3);
    cube->MakeCube();
    
    ModelUniforms cube_uniform;
    cube_uniform.position = simd_make_float3(0, 0, 0);
    cube_uniform.rotate_origin = simd_make_float3(0, 0, 0);
    cube_uniform.angle = simd_make_float3(0, 0, 0);
    
    model_uniforms.push_back(cube_uniform);
    
    camera = new Camera();
    camera->pos = {-2, 0, 0};
    camera->vector = {1, 0, 0};
    camera->up_vector = {0, 0, 1};
    camera->FOV = {M_PI_2, M_PI_2};

    CreateScenePipelineStates();
    
    // workaround for weird resizing bug
    SDL_SetWindowSize(window, window_width, window_height);
    
    // Main loop
    bool done = false;
    while (!done)
    {
        @autoreleasepool
        {
            SDL_Event event;
            while (SDL_PollEvent(&event))
            {
                ImGui_ImplSDL2_ProcessEvent(&event);
                if (event.type == SDL_QUIT)
                    done = true;
                if (event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_CLOSE && event.window.windowID == SDL_GetWindowID(window))
                    done = true;
                HandleKeyboardEvents(event);
                HandleMouseEvents(event);
            }
            
            HandleCameraInput();
            CreateBuffers();
            
            SDL_GetRendererOutputSize(renderer, &window_width, &window_height);
            aspect_ratio = ((float) window_width)/((float) window_height);
            //SDL_GetWindowSize(window, &window_width, &window_height);
            
            layer.drawableSize = CGSizeMake(window_width, window_height);
            id<CAMetalDrawable> drawable = [layer nextDrawable];

            id<MTLCommandBuffer> compute_command_buffer = [command_queue commandBuffer];
            
            // calculate rotated vertices
            id<MTLComputeCommandEncoder> compute_encoder = [compute_command_buffer computeCommandEncoder];
            [compute_encoder setComputePipelineState: scene_compute_rotated_pipeline_state];
            [compute_encoder setBuffer: scene_vertex_buffer offset:0 atIndex:0];
            [compute_encoder setBuffer: scene_model_id_buffer offset:0 atIndex:1];
            [compute_encoder setBuffer: rotate_uniforms_buffer offset:0 atIndex:2];
            int vertices_length = (int) scene_vertices.size();
            MTLSize gridSize = MTLSizeMake(vertices_length, 1, 1);
            NSUInteger threadGroupSize = scene_compute_projected_pipeline_state.maxTotalThreadsPerThreadgroup;
            if (threadGroupSize > vertices_length) threadGroupSize = vertices_length;
            MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
            [compute_encoder dispatchThreads:gridSize threadsPerThreadgroup:threadgroupSize];
            
            // calculate projected vertex in kernel function
            [compute_encoder setComputePipelineState: scene_compute_projected_pipeline_state];
            [compute_encoder setBuffer: scene_vertex_buffer offset:0 atIndex:0];
            [compute_encoder setBuffer: scene_camera_buffer offset:0 atIndex:1];
            if (threadGroupSize > vertices_length) threadGroupSize = vertices_length;
            [compute_encoder dispatchThreads:gridSize threadsPerThreadgroup:threadgroupSize];
            [compute_encoder endEncoding];
            [compute_command_buffer commit];
            [compute_command_buffer waitUntilCompleted];
            
            id<MTLCommandBuffer> render_command_buffer = [command_queue commandBuffer];
            render_pass_descriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.6, 0.6, 0.6, 1);
            render_pass_descriptor.colorAttachments[0].texture = drawable.texture;
            render_pass_descriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
            render_pass_descriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
            
            render_pass_descriptor.depthAttachment.texture = depth_texture;
            render_pass_descriptor.depthAttachment.clearDepth = 1.0;
            render_pass_descriptor.depthAttachment.loadAction = MTLLoadActionClear;
            render_pass_descriptor.depthAttachment.storeAction = MTLStoreActionStore;
            
            //render_pass_descriptor.renderTargetWidth = window_width;
            //render_pass_descriptor.renderTargetHeight = window_height;
            id <MTLRenderCommandEncoder> render_encoder = [render_command_buffer renderCommandEncoderWithDescriptor:render_pass_descriptor];
            [render_encoder pushDebugGroup:@"dragonfly"];
            
            
            // rendering scene - the faces
            [render_encoder setRenderPipelineState:scene_render_pipeline_state];
            [render_encoder setDepthStencilState: depth_state];
            [render_encoder setVertexBuffer:scene_vertex_buffer offset:0 atIndex:0];
            [render_encoder setVertexBuffer:scene_face_buffer offset:0 atIndex:1];
            [render_encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:scene_faces.size()*3];
            
            // rendering the edges
            [render_encoder setRenderPipelineState:scene_edge_render_pipeline_state];
            [render_encoder setVertexBuffer:scene_vertex_buffer offset:0 atIndex:0];
            [render_encoder setVertexBuffer:scene_face_buffer offset:0 atIndex:1];
            for (int i = arrows_face_end*4; i < scene_faces.size()*4; i+=4) {
                [render_encoder drawPrimitives:MTLPrimitiveTypeLineStrip vertexStart:i vertexCount:4];
            }
            
            // rendering the vertex points
            [render_encoder setRenderPipelineState:scene_point_render_pipeline_state];
            [render_encoder setVertexBuffer:scene_vertex_buffer offset:0 atIndex:0];
            [render_encoder setVertexBuffer:scene_face_buffer offset:0 atIndex:1];
            [render_encoder setVertexBuffer:scene_vertex_buffer offset:0 atIndex:0];
            for (int i = arrows_vertex_end*4; i < scene_vertices.size()*4; i+=4) {
                [render_encoder drawPrimitives:MTLPrimitiveTypeTriangleStrip vertexStart:i vertexCount:4];
            }
            
            // Start the Dear ImGui frame
            ImGui_ImplMetal_NewFrame(render_pass_descriptor);
            ImGui_ImplSDL2_NewFrame();
            ImGui::NewFrame();
            
            window_width = ImGui::GetIO().DisplaySize.x;
            window_height = ImGui::GetIO().DisplaySize.y;
            aspect_ratio = ((float) window_width)/((float) window_height);
            
            camera->FOV = {M_PI_2, 2*(atanf((float)window_height/(float)window_width))};
            
            // Rendering UI
            RenderUI();
            
            ImGui::Render();
            ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), render_command_buffer, render_encoder); // ImGui changes the encoders pipeline here to use its shaders and buffers
             
            // End rendering and display
            [render_encoder popDebugGroup];
            [render_encoder endEncoding];
            
            [render_command_buffer presentDrawable:drawable];
            [render_command_buffer commit];
            
            fps = ImGui::GetIO().Framerate;
            
            scene_vertices.clear();
            scene_faces.clear();
            modelIDs.clear();
        }
    }

    // Cleanup
    ImGui_ImplMetal_Shutdown();
    ImGui_ImplSDL2_Shutdown();
    ImGui::DestroyContext();

    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    
    delete camera;
    delete cube;
    delete z_arrow;
    delete x_arrow;
    delete y_arrow;

    return 0;
}

