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

#include <simd/SIMD.h>
#include <fstream>

#include "../Utils.h"

typedef simd_float3 Vertex;

class Animation;
class Model;

// vertex locations relative to joints
// node 0 is the default joint - at the center of the model
// node locations relative to model's uniform

struct Face {
    uint32_t vertices[3];
    simd_float4 color;
};

struct Node {
    simd_float3 pos;
    simd_float3 angle; // euler angles zyx
};

struct NodeVertexLink {
    int nid = -1;
    simd_float3 vector;
    float weight;
};

struct NodeKeyFrame {
    uint32_t nid;
    float time;
    simd_float3 pos;
    simd_float3 angle;
};

class Animation {
private:
    float length = 0.0;
    Model *model_;
    std::vector<std::vector<NodeKeyFrame *> *> node_animations;

    std::pair<int, int> FindFrameIdx(uint32_t nid, float time);
public:
    Animation(Model *model);
    ~Animation();
    
    float GetLength();

    void SetKeyFrame(uint32_t nid, float time, simd_float3 pos, simd_float3 angle);
    void RemoveKeyFrame(uint32_t nid, uint32_t kfid);

    void SetAtTime(float time);
    
    void FromFile(std::ifstream &file);
    void AddToFile(std::ofstream &file);
};

class Model {
private:
    std::vector<Face *> faces;
    std::vector<Node *> nodes;
    std::vector<Animation *> animations;
    
    // two links per vertex - index = vertex index * 2 (+ 1)
    std::vector<NodeVertexLink *> nvlinks;
    
    uint32_t modelID;
    
    unsigned long face_start = 0;
    unsigned long vertex_start = 0;
    
    unsigned long num_vertices = 0;
    
    unsigned long node_start = 0;
    
    long curr_aid = -1;
    float curr_anim_time = 0;
protected:
    std::string name_;
public:
    Model(uint32_t mid);
    // to default node
    unsigned MakeVertex(float x, float y, float z);
    // to specified node
    unsigned MakeVertex(float x, float y, float z, unsigned nid);
    unsigned MakeFace(unsigned v0, unsigned v1, unsigned v2, simd_float4 color);
    
    unsigned MakeNode(float x, float y, float z);
    void LinkNodeAndVertex(unsigned long vid, unsigned long nid);
    void UnlinkNodeAndVertex(unsigned long vid, unsigned long nid);
    
    void DetermineLinkWeights(Vertex loc, unsigned long vid);
    
    void MakeCube();
    
    void FromFile(std::string path);
    
    void InsertVertex(float x, float y, float z, int vid);
    void InsertFace(Face *face, int fid);
    
    void MoveVertex(unsigned vid, float dx, float dy, float dz);
    
    void RemoveVertex(int vid);
    void RemoveFace(int fid);
    
    unsigned MakeAnimation();
    void StartAnimation(int aid);
    void SetKeyFrame(int aid, int nid, float time);
    void UpdateAnimation(float dt);
    unsigned NumAnimations();
    
    Vertex GetVertex(unsigned long vid);
    Face *GetFace(unsigned long fid);
    std::vector<unsigned long> GetEdgeFaces(unsigned long vid1, unsigned long vid2);
    
    std::vector<unsigned long> GetLinkedNodes(unsigned long vid);
    std::vector<unsigned long> GetLinkedVertices(unsigned long nid);
    
    Node *GetNode(unsigned long nid);
    
    //std::vector<Vertex> &GetVertices();
    std::vector<Face*> &GetFaces();
    
    std::vector<Node*> &GetNodes();
    
    void AddToBuffers(std::vector<Face> &faceBuffer, std::vector<Node> &nodeBuffer, std::vector<NodeVertexLink> &nvlinkBuffer, std::vector<uint32_t> &node_modelIDs, unsigned &total_vertices);
    void UpdateNodeBuffers(std::vector<Node> &nodeBuffer);
    uint32_t ModelID();
    
    unsigned long FaceStart();
    unsigned long VertexStart();
    
    unsigned long NodeStart();
    
    unsigned long NumFaces();
    unsigned long NumVertices();
    
    unsigned long NumNodes();
    
    void SetName(std::string name);
    std::string GetName();
    void SaveToFile(std::string path);
    
    ~Model();
};

#endif /* Model_h */
