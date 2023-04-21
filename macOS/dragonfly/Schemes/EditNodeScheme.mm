//
//  EditNodeScheme.m
//  dragonfly
//
//  Created by Thomas Liang on 7/5/22.
//

#import <Foundation/Foundation.h>
#include "EditNodeScheme.h"

using namespace DragonflyUtils;

EditNodeScheme::EditNodeScheme() {
    type = SchemeType::EditNode;
    
    should_render.faces = false;
    should_render.edges = true;
    should_render.vertices = false;
    should_render.nodes = true;
    should_render.slices = false;
    
    CreateControlsModels();
}

EditNodeScheme::~EditNodeScheme() {
    
}

void EditNodeScheme::CreateControlsModels() {
    z_arrow = new Arrow(0);
    
    ModelUniforms z_arrow_uniform;
    z_arrow_uniform.b.pos = simd_make_float3(0, 0, 0);
    z_arrow_uniform.rotate_origin = simd_make_float3(0, 0, 0);
    
    controls_model_uniforms_.push_back(z_arrow_uniform);
    controls_model_default_bases_.push_back(z_arrow_uniform.b);
    arrow_projections[0] = simd_make_float2(0,0);
    arrow_projections[1] = simd_make_float2(0,1);
    
    controls_models_.push_back(z_arrow);
    
    x_arrow = new Arrow(1, simd_make_float4(0, 1, 0, 1));
    
    ModelUniforms x_arrow_uniform;
    x_arrow_uniform.b.pos = simd_make_float3(0, 0, 0);
    x_arrow_uniform.rotate_origin = simd_make_float3(0, 0, 0);
    //x_arrow_uniform.angle = simd_make_float3(M_PI_2, 0, 0);
    RotateBasisOnY(&x_arrow_uniform.b, M_PI_2);
    
    controls_model_uniforms_.push_back(x_arrow_uniform);
    controls_model_default_bases_.push_back(x_arrow_uniform.b);
    arrow_projections[2] = simd_make_float2(0,0);
    arrow_projections[3] = simd_make_float2(0,0);
    
    controls_models_.push_back(x_arrow);
    
    y_arrow = new Arrow(2, simd_make_float4(0, 0, 1, 1));
    
    ModelUniforms y_arrow_uniform;
    y_arrow_uniform.b.pos = simd_make_float3(0, 0, 0);
    y_arrow_uniform.rotate_origin = simd_make_float3(0, 0, 0);
//    y_arrow_uniform.angle = simd_make_float3(0, -M_PI_2, 0);
    RotateBasisOnX(&y_arrow_uniform.b, M_PI_2);
    
    controls_model_uniforms_.push_back(y_arrow_uniform);
    controls_model_default_bases_.push_back(y_arrow_uniform.b);
    arrow_projections[4] = simd_make_float2(0,0);
    arrow_projections[5] = simd_make_float2(1,0);
    
    controls_models_.push_back(y_arrow);
    
    
    z_rotator = new Rotator(3);
    z_rotator->ScaleBy(1, 1, 0.8);
    
    ModelUniforms z_rotator_uniform;
    z_rotator_uniform.b.pos = simd_make_float3(0, 0, 0);
    z_rotator_uniform.rotate_origin = simd_make_float3(0, 0, 0);
    RotateBasisOnZ(&z_rotator_uniform.b, M_PI_2);
    
    controls_model_uniforms_.push_back(z_rotator_uniform);
    controls_model_default_bases_.push_back(z_rotator_uniform.b);
    rotator_projections[0] = simd_make_float2(0,0);
    rotator_projections[1] = simd_make_float2(0,1);
    
    controls_models_.push_back(z_rotator);
    
    x_rotator = new Rotator(4, simd_make_float4(0, 1, 0, 1));
    x_rotator->ScaleBy(1, 1, 0.8);
    
    ModelUniforms x_rotator_uniform;
    x_rotator_uniform.b.pos = simd_make_float3(0, 0, 0);
    x_rotator_uniform.rotate_origin = simd_make_float3(0, 0, 0);
    //x_arrow_uniform.angle = simd_make_float3(M_PI_2, 0, 0);
    RotateBasisOnY(&x_rotator_uniform.b, M_PI_2);
    
    controls_model_uniforms_.push_back(x_rotator_uniform);
    controls_model_default_bases_.push_back(x_rotator_uniform.b);
    rotator_projections[2] = simd_make_float2(0,0);
    rotator_projections[3] = simd_make_float2(0,0);
    
    controls_models_.push_back(x_rotator);
    
    y_rotator = new Rotator(5, simd_make_float4(0, 0, 1, 1));
    y_rotator->ScaleBy(1, 1, 0.8);
    
    ModelUniforms y_rotator_uniform;
    y_rotator_uniform.b.pos = simd_make_float3(0, 0, 0);
    y_rotator_uniform.rotate_origin = simd_make_float3(0, 0, 0);
//    y_arrow_uniform.angle = simd_make_float3(0, -M_PI_2, 0);
    RotateBasisOnX(&y_rotator_uniform.b, M_PI_2);
    
    controls_model_uniforms_.push_back(y_rotator_uniform);
    controls_model_default_bases_.push_back(y_rotator_uniform.b);
    rotator_projections[4] = simd_make_float2(0,0);
    rotator_projections[5] = simd_make_float2(1,0);
    
    controls_models_.push_back(y_rotator);
}

void EditNodeScheme::HandleMouseMovement(float x, float y, float dx, float dy) {
    Scheme::HandleMouseMovement(x, y, dx, dy);
    
    if (input_enabled) {
        if (selected_arrow != -1) {
            // find the projected location of the tip and the base
            simd_float2 top = arrow_projections[selected_arrow*2];
            simd_float2 bot = arrow_projections[selected_arrow*2+1];
            
            // find direction to move
            float xDiff = top.x-bot.x;
            float yDiff = top.y-bot.y;
            
            float mag = sqrt(pow(xDiff, 2) + pow(yDiff, 2));
            xDiff /= mag;
            yDiff /= mag;
            
            float mvmt = xDiff * dx + yDiff * (-dy);
            
            // move
            ModelUniforms arrow_uniform = controls_model_uniforms_[selected_arrow];
            float x_vec = arrow_uniform.b.z.x; // 0;
            float y_vec = arrow_uniform.b.z.y;// 0;
            float z_vec = arrow_uniform.b.z.z;// 1;
            
            x_vec *= 0.01*mvmt;
            y_vec *= 0.01*mvmt;
            z_vec *= 0.01*mvmt;
            Vertex mvmt_vec = simd_make_float3(x_vec, y_vec, z_vec);
            mvmt_vec = TranslatePointToBasis(&scene_->GetModelUniforms(selected_model_)->b, mvmt_vec);
            
            if (selected_node_ != -1) {
                Model *model = scene_->GetModel(selected_model_);
                unsigned long modelNodeId = selected_node_ - model->NodeStart();
                if (modelNodeId > 0) {
                    model->MoveNodeBy(modelNodeId, mvmt_vec.x, mvmt_vec.y, mvmt_vec.z);
                }
            }
        } else if (selected_rotator != -1) {
            // find the projected location of the tip and the base
            simd_float2 top = rotator_projections[selected_rotator*2];
            simd_float2 bot = rotator_projections[selected_rotator*2+1];
            
            // find direction to move
            float xDiff = top.x-bot.x;
            float yDiff = top.y-bot.y;
            
            float mag = sqrt(pow(xDiff, 2) + pow(yDiff, 2));
            xDiff /= mag;
            yDiff /= mag;
            
            float mvmt = xDiff * dx + yDiff * (-dy);
            
            Model *model = scene_->GetModel(selected_model_);
            Node *n = model->GetNode(selected_node_ - model->NodeStart());
            if (selected_rotator == 0) {
                model->RotateNodeOnY(selected_node_ - model->NodeStart(), -mvmt / 100);
            } else if (selected_rotator == 1) {
                model->RotateNodeOnZ(selected_node_ - model->NodeStart(), -mvmt / 100);
            } else {
                model->RotateNodeOnX(selected_node_ - model->NodeStart(), -mvmt / 100);
            }
        }
    }
}

void EditNodeScheme::HandleMouseDown(simd_float2 loc, bool left) {
    Scheme::HandleMouseDown(loc, left);
    
    loc.x = ((float) loc.x / (float) window_width_)*2 - 1;
    loc.y = -(((float) loc.y / (float) window_height_)*2 - 1);
    
    if (!left) {
        if (selected_node_ != -1) {
            rightclick_popup_loc_ = loc;
            rightclick_popup_size_ = simd_make_float2(90/(float)(window_width_/2), 20/(float)(window_height_/2));
            render_rightclick_popup_ = true;
        } else {
            render_rightclick_popup_ = false;
        }
    }
}

void EditNodeScheme::HandleMouseUp(simd_float2 loc, bool left) {
    Scheme::HandleMouseUp(loc, left);
    
    loc.x = ((float) loc.x / (float) window_width_)*2 - 1;
    loc.y = -(((float) loc.y / (float) window_height_)*2 - 1);
    
    if (left) {
        selected_arrow = -1;
        selected_rotator = -1;
        
        if (!(render_rightclick_popup_ && InRectangle(rightclick_popup_loc_, rightclick_popup_size_, loc))) {
            render_rightclick_popup_ = false;
        }
    }
}

std::pair<std::pair<int, int>, float> EditNodeScheme::NodeClicked(simd_float2 loc) {
    float minZ = -1;
    int clickedNid = -1;
    int clickedMid = -1;
    
    int nid = 0;
    for (int mid = 0; mid < scene_->NumModels(); mid++) {
        Model *m = scene_->GetModel(mid);
        int nid_end = nid + m->NumNodes();
        
        for (; nid < nid_end; nid++) {
            float radius = (1/scene_models_projected_nodes_[nid].z) / 500;
            radius = radius * window_width_;
            
            simd_float2 scaled_click = simd_make_float2(loc.x * window_width_, loc.y * window_height_);
            simd_float3 scaled_node = simd_make_float3(scene_models_projected_nodes_[nid].x * window_width_, scene_models_projected_nodes_[nid].y * window_height_, scene_models_projected_nodes_[nid].z);
            
            float d = dist2to3(scaled_click, scaled_node);
            
            if (d <= radius) {
                if (minZ == -1 || scene_models_projected_nodes_[nid].z < minZ) {
                    clickedNid = nid;
                    clickedMid = mid;
                    minZ = scene_models_projected_nodes_[nid].z;
                }
            }
        }
    }
    
    return std::make_pair(std::make_pair(clickedNid, clickedMid), minZ);
}

bool EditNodeScheme::ClickOnScene(simd_float2 loc) {
    if (render_rightclick_popup_ && InRectangle(rightclick_popup_loc_, rightclick_popup_size_, loc)) {
        return false;
    }
    
    int pixelX = window_width_ * (loc.x+1)/2;
    int pixelY = window_height_ * (loc.y+1)/2;
    
    if (pixelX < UI_start_.x || pixelX > UI_start_.x + window_width_ - right_menu_width_) {
        return false;
    }
    
    if (pixelY < 0 || pixelY > window_height_ - UI_start_.y) {
        return false;
    }
    
    return true;
}

void EditNodeScheme::HandleSelection(simd_float2 loc) {
    std::pair<int, float> controls_selection = ControlModelClicked(loc);
    std::pair<std::pair<int, int>, float> node_selection = NodeClicked(loc);
    
    if (node_selection.first.first != -1 && controls_selection.first != -1) {
        if (node_selection.second > controls_selection.second) {
            if (controls_selection.first < 3) {
                selected_arrow = controls_selection.first;
            }
        } else {
            selected_node_ = node_selection.first.first;
            selected_model_ = node_selection.first.second;
            
            node_render_uniforms_.selected_node = selected_node_;
        }
    } else if (node_selection.first.first != -1 ) {
        selected_node_ = node_selection.first.first;
        selected_model_ = node_selection.first.second;
        
        node_render_uniforms_.selected_node = selected_node_;
    } else if (controls_selection.first != -1) {
        if (controls_selection.first < 3) {
            selected_arrow = controls_selection.first;
        } else if (controls_selection.first < 6) {
            selected_rotator = controls_selection.first - 3;
        }
    } else {
        selected_node_ = -1;
        selected_model_ = -1;
        selected_arrow = -1;
        selected_rotator = -1;
        
        node_render_uniforms_.selected_node = -1;
    }
}

void EditNodeScheme::SetControlsBasis() {
    if (selected_node_ != -1) {
        Model *model = scene_->GetModel(selected_model_);
        unsigned long modelNodeId = selected_node_ - model->NodeStart();
        if (modelNodeId > 0) {
            controls_basis_ = scene_models_nodes_[selected_node_].b;
        }
    } else {
        simd_float3 behind_camera;
        behind_camera.x = camera_->pos.x - camera_->vector.x*10;
        behind_camera.y = camera_->pos.y - camera_->vector.y*10;
        behind_camera.z = camera_->pos.z - camera_->vector.z*10;
        controls_basis_.pos = behind_camera;
    }
}

void EditNodeScheme::SetArrowProjections() {
    arrow_projections[0].x = control_models_projected_vertices_[4].x;
    arrow_projections[0].y = control_models_projected_vertices_[4].y;
    arrow_projections[1].x = control_models_projected_vertices_[9].x;
    arrow_projections[1].y = control_models_projected_vertices_[9].y;
    
    arrow_projections[2].x = control_models_projected_vertices_[ARROW_VERTEX_SIZE+4].x;
    arrow_projections[2].y = control_models_projected_vertices_[ARROW_VERTEX_SIZE+4].y;
    arrow_projections[3].x = control_models_projected_vertices_[ARROW_VERTEX_SIZE+9].x;
    arrow_projections[3].y = control_models_projected_vertices_[ARROW_VERTEX_SIZE+9].y;
    
    arrow_projections[4].x = control_models_projected_vertices_[ARROW_VERTEX_SIZE*2+4].x;
    arrow_projections[4].y = control_models_projected_vertices_[ARROW_VERTEX_SIZE*2+4].y;
    arrow_projections[5].x = control_models_projected_vertices_[ARROW_VERTEX_SIZE*2+9].x;
    arrow_projections[5].y = control_models_projected_vertices_[ARROW_VERTEX_SIZE*2+9].y;
    
    
    rotator_projections[0].x = control_models_projected_vertices_[ARROW_VERTEX_SIZE*3+6].x;
    rotator_projections[0].y = control_models_projected_vertices_[ARROW_VERTEX_SIZE*3+6].y;
    rotator_projections[1].x = control_models_projected_vertices_[ARROW_VERTEX_SIZE*3+9].x;
    rotator_projections[1].y = control_models_projected_vertices_[ARROW_VERTEX_SIZE*3+9].y;
    
    rotator_projections[2].x = control_models_projected_vertices_[ARROW_VERTEX_SIZE*3+ROTATOR_VERTEX_SIZE+6].x;
    rotator_projections[2].y = control_models_projected_vertices_[ARROW_VERTEX_SIZE*3+ROTATOR_VERTEX_SIZE+6].y;
    rotator_projections[3].x = control_models_projected_vertices_[ARROW_VERTEX_SIZE*3+ROTATOR_VERTEX_SIZE+9].x;
    rotator_projections[3].y = control_models_projected_vertices_[ARROW_VERTEX_SIZE*3+ROTATOR_VERTEX_SIZE+9].y;
    
    rotator_projections[4].x = control_models_projected_vertices_[ARROW_VERTEX_SIZE*3+ROTATOR_VERTEX_SIZE*2+6].x;
    rotator_projections[4].y = control_models_projected_vertices_[ARROW_VERTEX_SIZE*3+ROTATOR_VERTEX_SIZE*2+6].y;
    rotator_projections[5].x = control_models_projected_vertices_[ARROW_VERTEX_SIZE*3+ROTATOR_VERTEX_SIZE*2+9].x;
    rotator_projections[5].y = control_models_projected_vertices_[ARROW_VERTEX_SIZE*3+ROTATOR_VERTEX_SIZE*2+9].y;
}

void EditNodeScheme::RightClickPopup() {
    ImVec2 pixel_loc = ImVec2(window_width_ * (rightclick_popup_loc_.x+1)/2 - UI_start_.x, window_height_ * (2-(rightclick_popup_loc_.y+1))/2 - UI_start_.y);
    ImGui::SetCursorPos(pixel_loc);
    
    ImVec2 button_size = ImVec2(window_width_ * rightclick_popup_size_.x/2, window_height_ * rightclick_popup_size_.y/2);
    
    if (selected_model_ != -1) {
        if (ImGui::Button("Add Node", ImVec2(button_size.x, button_size.y))) {
            render_rightclick_popup_ = false;
            Model* m = scene_->GetModel(selected_model_);
            m->MakeNode(1, 0, 0);
            
            scene_node_length_++;
            should_reset_static_buffers = true;
        }
    }
}

void EditNodeScheme::NodeEditMenu() {
    ImGui::Text("Selected Model ID: %i", selected_model_);
    ImGui::SetCursorPos(ImVec2(20, 30));
    ImGui::Text("Selected Node ID: %lu", selected_node_ - scene_->GetModel(selected_model_)->NodeStart());
    
    Model *model = scene_->GetModel(selected_model_);
    Node *node = model->GetNode(selected_node_ - model->NodeStart());
    
    ImGui::SetCursorPos(ImVec2(30, 50));
    ImGui::Text("Position");
    
    ImGui::SetCursorPos(ImVec2(50, 80));
    ImGui::Text("x: ");
    ImGui::SetCursorPos(ImVec2(70, 80));
    std::string x_input = TextField(std::to_string(node->b.pos.x), "##nodex");
    if (isFloat(x_input) && selected_node_ != model->NodeStart()) {
        float new_x = std::stof(x_input);
        model->MoveNodeTo(selected_node_ - model->NodeStart(), new_x, node->b.pos.y, node->b.pos.z);
    }
    
    ImGui::SetCursorPos(ImVec2(50, 110));
    ImGui::Text("y: ");
    ImGui::SetCursorPos(ImVec2(70, 110));
    std::string y_input = TextField(std::to_string(node->b.pos.y), "##nodey");
    if (isFloat(y_input) && selected_node_ != model->NodeStart()) {
        float new_y = std::stof(y_input);
        model->MoveNodeTo(selected_node_ - model->NodeStart(), node->b.pos.x, new_y, node->b.pos.z);
    }
    
    ImGui::SetCursorPos(ImVec2(50, 140));
    ImGui::Text("z: ");
    ImGui::SetCursorPos(ImVec2(70, 140));
    std::string z_input = TextField(std::to_string(node->b.pos.z), "##nodez");
    if (isFloat(z_input) && selected_node_ != model->NodeStart()) {
        float new_z = std::stof(z_input);
        model->MoveNodeTo(selected_node_ - model->NodeStart(), node->b.pos.x, node->b.pos.y, new_z);
    }
    
    
    ImGui::SetCursorPos(ImVec2(30, 170));
    ImGui::Text("Rotate By");

    ImGui::SetCursorPos(ImVec2(50, 200));
    ImGui::Text("x: ");
    ImGui::SetCursorPos(ImVec2(70, 200));
    angle_input_x = TextField(angle_input_x, "##nodeax");

    ImGui::SetCursorPos(ImVec2(50, 230));
    ImGui::Text("y: ");
    ImGui::SetCursorPos(ImVec2(70, 230));
    angle_input_y = TextField(angle_input_y, "##nodeay");

    ImGui::SetCursorPos(ImVec2(50, 260));
    ImGui::Text("z: ");
    ImGui::SetCursorPos(ImVec2(70, 260));
    angle_input_z = TextField(angle_input_z, "##nodeaz");
    
    ImGui::SetCursorPos(ImVec2(50, 280));
    if (ImGui::Button("Rotate", ImVec2(80,30))) {
        if (isFloat(angle_input_x) && selected_node_ != model->NodeStart()) {
            float new_x = std::stof(angle_input_x);
            //RotateBasisOnX(&node->b, new_x * M_PI / 180);
            model->RotateNodeOnX(selected_node_ - model->NodeStart(), new_x * M_PI / 180);
            //node->angle.x = new_x * M_PI / 180;
        }
        if (isFloat(angle_input_y) && selected_node_ != model->NodeStart()) {
            float new_y = std::stof(angle_input_y);
            //RotateBasisOnY(&node->b, new_y * M_PI / 180);
            model->RotateNodeOnY(selected_node_ - model->NodeStart(), new_y * M_PI / 180);
            //node->angle.y = new_y * M_PI / 180;
        }
        if (isFloat(angle_input_z) && selected_node_ != model->NodeStart()) {
            float new_z = std::stof(angle_input_z);
            //RotateBasisOnZ(&node->b, new_z * M_PI / 180);
            model->RotateNodeOnZ(selected_node_ - model->NodeStart(), new_z * M_PI / 180);
            //node->angle.z = new_z * M_PI / 180;
        }
        
        angle_input_x = "0";
        angle_input_y = "0";
        angle_input_z = "0";
    }
    
    ImGui::SetCursorPos(ImVec2(30, 320));
    ImGui::Text("Scale By");

    ImGui::SetCursorPos(ImVec2(50, 350));
    ImGui::Text("x: ");
    ImGui::SetCursorPos(ImVec2(70, 350));
    scale_input_x = TextField(scale_input_x, "##modelsx");

    ImGui::SetCursorPos(ImVec2(50, 370));
    ImGui::Text("y: ");
    ImGui::SetCursorPos(ImVec2(70, 370));
    scale_input_y = TextField(scale_input_y, "##modelsy");

    ImGui::SetCursorPos(ImVec2(50, 400));
    ImGui::Text("z: ");
    ImGui::SetCursorPos(ImVec2(70, 400));
    scale_input_z = TextField(scale_input_z, "##modelsz");
    
    ImGui::SetCursorPos(ImVec2(50, 430));
    if (ImGui::Button("Scale", ImVec2(80,30))) {
        float new_x = 1;
        float new_y = 1;
        float new_z = 1;
        if (isFloat(scale_input_x)) {
            new_x = std::stof(scale_input_x);
        }
        if (isFloat(scale_input_y)) {
            new_y = std::stof(scale_input_y);
        }
        if (isFloat(scale_input_z)) {
            new_z = std::stof(scale_input_z);
        }
        
        // x
        float currmagx = Magnitude(node->b.x);
        node->b.x.x *= new_x/currmagx;
        node->b.x.y *= new_x/currmagx;
        node->b.x.z *= new_x/currmagx;
        // y
        float currmagy = Magnitude(node->b.y);
        node->b.y.x *= new_y/currmagy;
        node->b.y.y *= new_y/currmagy;
        node->b.y.z *= new_y/currmagy;
        // z
        float currmagz = Magnitude(node->b.z);
        node->b.z.x *= new_z/currmagz;
        node->b.z.y *= new_z/currmagz;
        node->b.z.z *= new_z/currmagz;
    }
    
    ImGui::SetCursorPos(ImVec2(150, 430));
    if (ImGui::Button("Set Default", ImVec2(120,30))) {
        float currmagx = Magnitude(node->b.x);
        float currmagy = Magnitude(node->b.y);
        float currmagz = Magnitude(node->b.z);
        
        model->ScaleOnNodeBy(currmagx, currmagy, currmagz, selected_node_-model->NodeStart());
        // x
        node->b.x.x *= 1/currmagx;
        node->b.x.y *= 1/currmagx;
        node->b.x.z *= 1/currmagx;
        // y
        node->b.y.x *= 1/currmagy;
        node->b.y.y *= 1/currmagy;
        node->b.y.z *= 1/currmagy;
        // z
        node->b.z.x *= 1/currmagz;
        node->b.z.y *= 1/currmagz;
        node->b.z.z *= 1/currmagz;
        
        scale_input_x = "1";
        scale_input_y = "1";
        scale_input_z = "1";
        
        should_reset_static_buffers = true;
    }
    
    ImGui::SetCursorPos(ImVec2(50, 460));
    ImGui::Text("lock to: ");
    ImGui::SetCursorPos(ImVec2(90, 460));
    std::string locked_to = TextField(std::to_string(node->locked_to), "##nodelock");
    if (isUnsignedLong(locked_to) && selected_node_ != model->NodeStart()) {
        unsigned long new_lock = std::stoul(locked_to);
        model->LockNodeToNode(selected_node_ - model->NodeStart(), new_lock);
    }
    
    ImGui::SetCursorPos(ImVec2(50, 480));
    ImGui::Text("keyframe: ");
    ImGui::SetCursorPos(ImVec2(70, 510));
    ImGui::Text("animation id: ");
    ImGui::SetCursorPos(ImVec2(120, 510));
    std::string aidin = TextField(std::to_string(wanted_aid), "##naid");
    ImGui::SetCursorPos(ImVec2(70, 540));
    ImGui::Text("time: ");
    ImGui::SetCursorPos(ImVec2(100, 540));
    std::string timein = TextField(std::to_string(wanted_time), "##natime");
    ImGui::SetCursorPos(ImVec2(70, 570));
    if (isUnsignedLong(aidin) && isFloat(timein)) {
        wanted_aid = std::stoul(aidin);
        wanted_time = std::stof(timein);
    }
    
    if (ImGui::Button("Add", ImVec2(40,30))) {
        model->SetKeyFrame(wanted_aid, selected_node_ - model->NodeStart(), wanted_time);
    }
}

void EditNodeScheme::RightMenu() {
    ImGui::SetNextWindowPos(ImVec2(window_width_ - right_menu_width_, UI_start_.y));
    ImGui::SetNextWindowSize(ImVec2(right_menu_width_, window_height_ - UI_start_.y));
    ImGui::PushStyleColor(ImGuiCol_WindowBg, ImVec4(0.0f, 0.0f, 0.0f, 255.0f));
    ImGui::Begin("side", &show_UI, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoResize);
    
    ImGui::SetCursorPos(ImVec2(20, 10));
    if (selected_node_ != -1) {
        NodeEditMenu();
    } else {
        ImGui::Text("Nothing Selected");
    }
    
    ImGui::PopStyleColor();
    
    ImGui::End();
}

void EditNodeScheme::MainWindow() {
    ImGui::SetNextWindowPos(ImVec2(UI_start_.x, UI_start_.y));
    ImGui::SetNextWindowSize(ImVec2(window_width_ - right_menu_width_, window_height_));
    ImGui::PushStyleColor(ImGuiCol_WindowBg, ImVec4(0.0f, 0.0f, 0.0f, 0.0f));
    ImGui::Begin("main", &show_UI, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoResize);
    
    // Display FPS
    ImGui::SetCursorPos(ImVec2(5, 10));
    ImGui::Text("%.1f FPS", ImGui::GetIO().Framerate);
    ImGui::PopStyleColor();
    
    if (render_rightclick_popup_) {
        RightClickPopup();
    }
    
    ImGui::End();
}

void EditNodeScheme::BuildUI() {
    MainWindow();
    
    RightMenu();
}

void EditNodeScheme::SetBufferContents(Vertex *smv, Vertex *smpv, Face *smf, Node *smn, Vertex *smpn, Vertex *cmv, Vertex *cmpv, Face *cmf, Vertex *ssp) {
    Scheme::SetBufferContents(smv, smpv, smf, smn, smpn, cmv, cmpv, cmf, ssp);
    SetArrowProjections();
}
