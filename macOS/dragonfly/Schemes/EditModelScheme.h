//
//  EditModelScheme.h
//  dragonfly
//
//  Created by Thomas Liang on 7/5/22.
//

#ifndef EditModelScheme_h
#define EditModelScheme_h

#include "Scheme.h"
#include "../UserActions/ModelMoveAction.h"
#include "../Utils/Normals.h"

class EditModelScheme : public Scheme {
private:
    int right_menu_width_ = 300;
    
    bool render_rightclick_popup_ = false;
    simd_float2 rightclick_popup_loc_;
    int num_right_click_buttons_ = 0;
    ImVec2 button_size_;
    simd_float2 rightclick_popup_size_;
    bool rightclick_popup_clicked_ = false;
    
    Arrow *z_arrow;
    Arrow *x_arrow;
    Arrow *y_arrow;
    // z base, z tip, x base, x tip, y base, y tip
    simd_float2 arrow_projections [6];
    // z, x, y
    int selected_arrow = -1;
    int ARROW_VERTEX_SIZE = 18;
    int ARROW_FACE_SIZE = 22;
    
    int selected_model = -1;
    
    unsigned long wanted_aid = 0;
    
    std::string angle_input_x = "0";
    std::string angle_input_y = "0";
    std::string angle_input_z = "0";
    
    void CreateControlsModels();
    
    std::pair<int, float> ModelClicked(simd_float2 loc);
    
    bool ClickOnScene(simd_float2 loc);
    
    void HandleSelection(simd_float2 loc);
    
    void ModelEditMenu();
    
    void SetControlsBasis();
    
    void SetArrowProjections();
    
    void RightClickPopup();
    
    void RightMenu();
    void MainWindow();
public:
    EditModelScheme();
    
    ~EditModelScheme();
    
    void HandleMouseDown(simd_float2 loc, bool left);
    void HandleMouseUp(simd_float2 loc, bool left);
    
    void SetBufferContents(Vertex *smv, Vertex *smpv, Face *smf, Node *smn, Vertex *smpn, Vertex *cmv, Vertex *cmpv, Face *cmf, Vertex *ssp);
    void BuildUI();
    
    void SaveSelectedModelToFile(std::string path);
    
    void HandleMouseMovement(float x, float y, float dx, float dy);
    
    virtual void Update();
};

#endif /* EditModelScheme_h */