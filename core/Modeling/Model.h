//
//  Model.h
//  dragonfly
//
//  Created by Thomas Liang on 1/15/22.
//

#ifndef Model_h
#define Model_h
#include <stdio.h>
#include <vector>
#include <string>
#include <stdint.h>
#include <cmath>

#include "Utils/Vec.h"
using namespace Vec;
#include <fstream>

#include "../Utils/Utils.h"
#include "../Utils/Basis.h"

using namespace DragonflyUtils;

typedef Vec::vec_float3 Vertex;

class Animation;
class Model;

// vertex locations relative to joints
// node 0 is the default joint - at the center of the model
// node locations relative to model's uniform

struct Face {
    uint32_t vertices[3];
    vec_float4 color;
    
    uint32_t normal_reversed = 0;
    vec_float3 lighting_offset; // if there were a light source directly in front of the face, this is the rotation to get to its brightest orientation
    float shading_multiplier = 1;
};

struct Node {
    int locked_to = -1;
    Basis b;
};

struct NodeVertexLink {
    int nid = -1;
    vec_float3 vector;
    float weight;
};

struct NodeKeyFrame {
    uint32_t nid;
    float time;
    Basis b;
};

class Animation {
private:
    float length = 0.0;
    Model *model_;
    std::vector<Basis> b0s;
    // a vector of vectors of frames for each node
    std::vector<std::vector<NodeKeyFrame *> *> node_animations;
    std::vector<int> node_ordering;

    std::pair<int, int> FindFrameIdx(uint32_t nid, float time);
public:
    Animation(Model *model);
    ~Animation();
    
    void SetB0(int i, Basis b);
    void SetOrdering();
    float GetLength();

    void AddNode();
    void SetKeyFrame(uint32_t nid, float time, Basis basis);
    void RemoveKeyFrame(uint32_t nid, uint32_t kfid);

    void SetAtTime(float time);
    
    void FromFile(std::ifstream &file);
    void AddToFile(std::ofstream &file);
    
    std::vector<std::vector<NodeKeyFrame *> *> *GetAnimations();
};

class Model {
private:
    std::vector<Face *> faces;
    std::vector<Node *> nodes;
    std::vector<Animation *> animations;
    
    // two links per vertex - index = vertex index * 2 (+ 1)
    std::vector<NodeVertexLink *> nvlinks;
    
    unsigned long num_vertices = 0;
    
    long curr_aid = -1;
    float curr_anim_time = 0;
protected:
    std::string name_;
public:
    Model();
    // to default node
    unsigned MakeVertex(float x, float y, float z);
    // to specified node
    unsigned MakeVertex(float x, float y, float z, unsigned nid);
    unsigned MakeFace(unsigned v0, unsigned v1, unsigned v2, vec_float4 color);
    unsigned MakeFaceWithLighting(unsigned v0, unsigned v1, unsigned v2, vec_float4 color, uint32_t normal_reversed, vec_float3 lighting_offset, float shading_multiplier);
    
    unsigned MakeNode(float x, float y, float z);
    void LinkNodeAndVertex(unsigned long vid, unsigned long nid);
    void UnlinkNodeAndVertex(unsigned long vid, unsigned long nid);
    
    void DetermineLinkWeights(Vertex loc, unsigned long vid);
    
    void LockNodeToNode(unsigned nid1, unsigned nid2);
    
    void MakeCube();
    
    void FromFile(std::string path);
    
    void InsertVertex(float x, float y, float z, int vid);
    void InsertFace(Face *face, int fid);
    
    void MoveVertexBy(unsigned vid, float dx, float dy, float dz);
    void MoveNodeBy(unsigned nid, float dx, float dy, float dz);
    
    void MoveVertexTo(unsigned vid, float x, float y, float z);
    void MoveNodeTo(unsigned nid, float x, float y, float z);
    
    void RotateNodeOnX(unsigned nid, float angle);
    void RotateNodeOnY(unsigned nid, float angle);
    void RotateNodeOnZ(unsigned nid, float angle);
    void RotateNodeToBasis(unsigned nid, Basis *b);
    
    void RemoveVertex(int vid);
    void RemoveFace(int fid);
    void RemoveNode(int nid);
    
    void ScaleBy(float x, float y, float z);
    void ScaleOnNodeBy(float x, float y, float z, int nid);
    
    bool PointIn(vec_float3 p);
    
    Animation *GetAnimation(int aid);
    unsigned MakeAnimation();
    void StartAnimation(int aid);
    void SetKeyFrame(int aid, int nid, float time);
    void RemoveKeyFrame(int aid, int nid, int kfid);
    void UpdateAnimation(float dt);
    void SetAnimationTime(float t);
    bool InAnimation();
    int CurrAid();
    float CurrAnimationTime();
    unsigned NumAnimations();
    
    NodeVertexLink *GetNodeVertexLink(unsigned long nvlid);
    Vertex GetVertex(unsigned long vid);
    Face *GetFace(unsigned long fid);
    bool FaceExists(unsigned long vid1, unsigned long vid2, unsigned long vid3);
    std::vector<unsigned long> GetEdgeFaces(unsigned long vid1, unsigned long vid2);
    bool HasFaceWith(std::vector<int> &vids);
    
    std::vector<unsigned long> GetLinkedNodes(unsigned long vid);
    std::vector<unsigned long> GetLinkedVertices(unsigned long nid);
    
    Node *GetNode(unsigned long nid);
    
    std::vector<Face*> &GetFaces();
    std::vector<Node*> &GetNodes();
    
    unsigned long NumFaces();
    unsigned long NumVertices();
    
    unsigned long NumNodes();
    
    void SetId(uint32_t mid);
    
    void SetName(std::string name);
    std::string GetName();
    void SaveToFile(std::string path);
    
    ~Model();
};

#endif /* Model_h */
