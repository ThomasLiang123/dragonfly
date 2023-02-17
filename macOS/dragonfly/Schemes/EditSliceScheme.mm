//
//  SliceEditScheme.mm
//  dragonfly
//
//  Created by Thomas Liang on 1/31/23.
//

#include "EditSliceScheme.h"

using namespace DragonflyUtils;

EditSliceScheme::EditSliceScheme() {
    type = SchemeType::EditSlice;
    
    should_render.faces = false;
    should_render.edges = false;
    should_render.vertices = false;
    should_render.nodes = false;
    should_render.slices = true;
    
    button_size_ = ImVec2(100, 30);
}

EditSliceScheme::~EditSliceScheme() {
    
}

void EditSliceScheme::CreateDotAtClick(simd_float2 click_loc) {
    Slice *s = scene_->GetSlice(slice_id);
    
    SliceAttributes *attr = &slice_attr_vector.at(slice_id);
    float scale = attr->height / 2;
    if (attr->height > attr->width) {
        scale = attr->width / 2;
    }
    
    float x,y;
    
    if (vertex_render_uniforms.screen_ratio < 1) {
        x = click_loc.x * scale;
        y = scale * click_loc.y / vertex_render_uniforms.screen_ratio;
    } else {
        x = click_loc.x * scale * vertex_render_uniforms.screen_ratio;
        y =  click_loc.y * scale;
    }
    
    s->MakeDot(x, y);
    
    if (first_dot == -1) {
        first_dot = s->NumDots()-1;
    }
    
    if (last_dot != -1) {
        s->MakeLine(last_dot, s->NumDots()-1);
    }
    last_dot = s->NumDots()-1;
    
    
    CalculateNumSceneDots();
    CalculateNumSceneLines();
    should_reset_empty_buffers = true;
    should_reset_static_buffers = true;
}

int EditSliceScheme::DotClicked(simd_float2 loc) {
    Slice *s = scene_->GetSlice(slice_id);
    
    for (int i = 0; i < s->NumDots(); i++) {
        Dot *d = s->GetDot(i);
        
        float x,y;
        
        SliceAttributes *attr = &slice_attr_vector.at(slice_id);
        float scale = attr->height / 2;
        if (attr->height > attr->width) {
            scale = attr->width / 2;
        }
        
        if (vertex_render_uniforms.screen_ratio < 1) {
            x = d->x / scale;
            y = vertex_render_uniforms.screen_ratio * d->y / scale;
        } else {
            x = (d->x / scale) / vertex_render_uniforms.screen_ratio;
            y =  d->y / scale;
        }
        
        float x_min = x-0.007;
        float x_max = x+0.007;
        float y_min = y-0.007 * aspect_ratio_;
        float y_max = y+0.007 * aspect_ratio_;
        
        if (loc.x <= x_max && loc.x >= x_min && loc.y <= y_max && loc.y >= y_min) {
            return i;
        }
    }
    
    return -1;
}

int EditSliceScheme::LineClicked(simd_float2 loc) {
    Slice *s = scene_->GetSlice(slice_id);
    
    for (int i = 0; i < s->NumLines(); i++) {
        Line *l = s->GetLine(i);
        
        Dot *d1 = s->GetDot(l->d1);
        Dot *d2 = s->GetDot(l->d2);
        
        float x1,y1,x2,y2;
        
        SliceAttributes *attr = &slice_attr_vector.at(slice_id);
        float scale = attr->height / 2;
        if (attr->height > attr->width) {
            scale = attr->width / 2;
        }
        
        if (vertex_render_uniforms.screen_ratio < 1) {
            x1 = d1->x / scale;
            y1 = vertex_render_uniforms.screen_ratio * d1->y / scale;
            x2 = d2->x / scale;
            y2 = vertex_render_uniforms.screen_ratio * d2->y / scale;
        } else {
            x1 = (d1->x / scale) / vertex_render_uniforms.screen_ratio;
            y1 = d1->y / scale;
            x2 = (d2->x / scale) / vertex_render_uniforms.screen_ratio;
            y2 = d2->y / scale;
        }
        
        simd_float2 edgeVec = simd_make_float2(x1-x2, y1-y2);
        float mag = sqrt(pow(edgeVec.x, 2) + pow(edgeVec.y, 2));
        if (mag == 0) {
            continue;
        }
        edgeVec.x /= mag;
        edgeVec.y /= mag;
        
        edgeVec.x *= 0.01;
        edgeVec.y *= 0.01;
        
        Dot d1plus = simd_make_float2(x1+edgeVec.y, y1-edgeVec.x);
        Dot d1sub = simd_make_float2(x1-edgeVec.y, y1+edgeVec.x);
        Dot d2plus = simd_make_float2(x2+edgeVec.y, y1-edgeVec.x);
        Dot d2sub = simd_make_float2(x2-edgeVec.y, y2+edgeVec.x);
        
        if (InTriangle2D(loc, d1plus, d1sub, d2plus) || InTriangle2D(loc, d1sub, d2sub, d2plus)) {
            return i;
        }
    }
    
    return -1;
}

bool EditSliceScheme::ClickOnScene(simd_float2 loc) {
    if (render_rightclick_popup_ && InRectangle(rightclick_popup_loc_, rightclick_popup_size_, loc)) {
        return false;
    }
    
    int pixelX = window_width_ * (loc.x+1)/2;
    int pixelY = window_height_ * (loc.y+1)/2;
    
    if (pixelX < UI_start_.x || pixelX > UI_start_.x + window_width_ - right_menu_width_) {
        return false;
    }
    
    if (pixelY < UI_start_.y || pixelY > UI_start_.y + window_height_) {
        return false;
    }
    
    return true;
}

void EditSliceScheme::HandleSelection(simd_float2 loc) {
    if (mode == Editing) {
        Slice *s = scene_->GetSlice(slice_id);
        int dot_selection = DotClicked(loc);
        int line_selection = LineClicked(loc);
        
        if (dot_selection >= 0) {
            vertex_render_uniforms.selected_vertices.clear();
            vertex_render_uniforms.selected_vertices.push_back(dot_selection + s->DotStart());
            held_dot = dot_selection;
        } else if (line_selection >= 0) {
            selected_line = line_selection;
            vertex_render_uniforms.selected_vertices.clear();
            vertex_render_uniforms.selected_vertices.push_back(s->GetLine(selected_line-s->LineStart())->d1 + s->DotStart());
            vertex_render_uniforms.selected_vertices.push_back(s->GetLine(selected_line-s->LineStart())->d2 + s->DotStart());
        } else {
            selected_line = -1;
            vertex_render_uniforms.selected_vertices.clear();
        }
        
        vertex_render_uniforms.num_selected_vertices = vertex_render_uniforms.selected_vertices.size();
    }
}

void EditSliceScheme::SelectDotsInDrag() {
    
}

void EditSliceScheme::RightClickPopup() {
    ImVec2 pixel_loc = ImVec2(window_width_ * (rightclick_popup_loc_.x+1)/2 - UI_start_.x, window_height_ * (2-(rightclick_popup_loc_.y+1))/2 - UI_start_.y);
    ImGui::SetCursorPos(pixel_loc);
    
    num_right_click_buttons_ = 0;
    
    
    rightclick_popup_size_ = simd_make_float2((button_size_.x)/(float)(window_width_/2), (button_size_.y * num_right_click_buttons_)/(float)(window_height_/2));
}

void EditSliceScheme::RightMenu() {
    ImGui::SetNextWindowPos(ImVec2(window_width_ - right_menu_width_, UI_start_.y));
    ImGui::SetNextWindowSize(ImVec2(right_menu_width_, window_height_ - UI_start_.y));
    ImGui::PushStyleColor(ImGuiCol_WindowBg, ImVec4(0.0f, 0.0f, 0.0f, 255.0f));
    ImGui::Begin("side", &show_UI, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoResize);
    
    ImGui::SetCursorPos(ImVec2(20, 10));
    if (mode == Drawing) {
        ImGui::Text("Drawing");
        ImGui::SetCursorPos(ImVec2(20, 30));
        
        if (ImGui::Button("Finish")) {
            Slice *s = scene_->GetSlice(slice_id);
            
            if (first_dot != -1 && first_dot != last_dot) {
                s->MakeLine(first_dot, last_dot);
            }
            
            CalculateNumSceneLines();
            should_reset_static_buffers = true;
            
            mode = Editing;
        }
    } else if (mode == Editing) {
        if (vertex_render_uniforms.num_selected_vertices == 1) {
            DotEditMenu();
        } else if (selected_line != -1) {
            LineEditMenu();
        } else {
            ImGui::Text("Editing");
            ImGui::SetCursorPos(ImVec2(20, 30));
            ImGui::Text("Nothing Selected");
        }
    }
    
    ImGui::PopStyleColor();
    
    ImGui::End();
}

void EditSliceScheme::DotEditMenu() {
    Slice *s = scene_->GetSlice(slice_id);
    ImGui::Text("Selected Dot: ", vertex_render_uniforms.selected_vertices[0]);
    
    ImGui::SetCursorPos(ImVec2(20, 30));
    
    if (ImGui::Button("Delete")) {
        s->RemoveDotAndMergeLines(vertex_render_uniforms.selected_vertices[0] - s->DotStart());
        
        CalculateNumSceneDots();
        CalculateNumSceneLines();
        should_reset_static_buffers = true;
        
        vertex_render_uniforms.selected_vertices.clear();
        vertex_render_uniforms.num_selected_vertices = 0;
    }
}

void EditSliceScheme::LineEditMenu() {
    Slice *s = scene_->GetSlice(slice_id);
    ImGui::Text("Selected Line: ", selected_line);
    
    ImGui::SetCursorPos(ImVec2(20, 30));
    
    if (ImGui::Button("Add Dot To Edge")) {
        s->AddDotToLine(selected_line);
        
        Line *e = s->GetLine(selected_line);
        
        vertex_render_uniforms.selected_vertices.clear();
        vertex_render_uniforms.selected_vertices.push_back(e->d1 + s->DotStart());
        vertex_render_uniforms.selected_vertices.push_back(e->d2 + s->DotStart());
        vertex_render_uniforms.num_selected_vertices = vertex_render_uniforms.selected_vertices.size();
        
        CalculateNumSceneDots();
        CalculateNumSceneLines();
        should_reset_static_buffers = true;
    }
}

void EditSliceScheme::MainWindow() {
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

void EditSliceScheme::HandleMouseMovement(float x, float y, float dx, float dy) {
    if (held_dot != -1) {
        x = ((float) x / (float) window_width_)*2 - 1;
        y = -(((float) y / (float) window_height_)*2 - 1);
        
        Slice *s = scene_->GetSlice(slice_id);
        Dot *d = s->GetDot(held_dot);
        
        SliceAttributes *attr = &slice_attr_vector.at(slice_id);
        float scale = attr->height / 2;
        if (attr->height > attr->width) {
            scale = attr->width / 2;
        }
        
        if (vertex_render_uniforms.screen_ratio < 1) {
            d->x = x * scale;
            d->y = scale * y / vertex_render_uniforms.screen_ratio;
        } else {
            d->x = x * scale * vertex_render_uniforms.screen_ratio;
            d->y =  y * scale;
        }
        
        should_reset_static_buffers = true;
    }
}

void EditSliceScheme::BuildUI() {
    MainWindow();
    
    RightMenu();
}

void EditSliceScheme::HandleMouseDown(simd_float2 loc, bool left) {
    Scheme::HandleMouseDown(loc, left);
    
    loc.x = ((float) loc.x / (float) window_width_)*2 - 1;
    loc.y = -(((float) loc.y / (float) window_height_)*2 - 1);
    
    drag_size.x = 0;
    drag_size.y = 0;
    
    if (!left) {
        if (vertex_render_uniforms.selected_vertices.size() > 0) {
            rightclick_popup_loc_ = loc;
            render_rightclick_popup_ = true;
        } else {
            render_rightclick_popup_ = false;
        }
    } else {
        if (mode == Drawing && ClickOnScene(loc)) {
            CreateDotAtClick(loc);
        }
    }
}

void EditSliceScheme::HandleMouseUp(simd_float2 loc, bool left) {
    Scheme::HandleMouseUp(loc, left);
    
    loc.x = ((float) loc.x / (float) window_width_)*2 - 1;
    loc.y = -(((float) loc.y / (float) window_height_)*2 - 1);
    
    if (left) {
        if (!(render_rightclick_popup_ && InRectangle(rightclick_popup_loc_, rightclick_popup_size_, loc))) {
            render_rightclick_popup_ = false;
        }
        
        if (dist2to3(drag_size, simd_make_float3(0, 0, 0)) > 0.05) {
            SelectDotsInDrag();
        }
        
        held_dot = -1;
    }
    
    drag_size.x = 0;
    drag_size.y = 0;
}

void EditSliceScheme::SetSliceID(int sid) {
    slice_id = sid;
    
    Slice *s = scene_->GetSlice(sid);
    scene_dot_length_ = s->NumDots();
    scene_line_length_ = s->NumLines();
    slice_vector.clear();
    slice_vector.push_back(s);
    
    slice_attr_vector.clear();
    slice_attr_vector.push_back(s->GetAttributes());
    should_reset_static_buffers = true;
    should_reset_empty_buffers = true;
}

int EditSliceScheme::GetSliceID() {
    return slice_id;
}

std::vector<Slice *> *EditSliceScheme::GetSlices() {
    return &slice_vector;
}

std::vector<SliceAttributes> EditSliceScheme::GetSliceAttributes() {
    return slice_attr_vector;
}
