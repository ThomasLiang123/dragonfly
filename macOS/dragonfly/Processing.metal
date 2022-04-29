//
//  Processing.metal
//  dragonfly
//
//  Created by Thomas Liang on 5/27/21.
//

#include <metal_stdlib>
using namespace metal;

constant float pi = 3.14159265358979;
constant float render_dist = 50;

struct Camera {
    vector_float3 pos;
    vector_float3 vector;
    vector_float3 upVector;
    vector_float2 FOV;
};

struct Face {
    unsigned int vertices[3];
    vector_float4 color;
};

struct VertexOut {
    vector_float4 pos [[position]];
    vector_float4 color;
};

struct ModelUniforms {
    vector_float3 position;
    vector_float3 rotate_origin;
    vector_float3 angle;
};

struct Uniforms {
    unsigned int numFaces;
    unsigned int selectedFace;
};

//convert a 3d point to a pixel (vertex) value
vector_float3 PointToPixel (vector_float3 point, constant Camera &camera)  {
    //vector from camera position to object position
    vector_float4 toObject;
    toObject.x = (point.x-camera.pos.x);
    toObject.y = (point.y-camera.pos.y);
    toObject.z = (point.z-camera.pos.z);
    toObject.w = (sqrt(pow(toObject.x, 2)+pow(toObject.y, 2)+pow(toObject.z, 2)));
    
    //project camera vector onto object vector
    float dotProduct = (toObject.x*camera.vector.x)+(toObject.y*camera.vector.y)+(toObject.z*camera.vector.z);
    vector_float4 proj;
    proj.x = dotProduct*camera.vector.x;
    proj.y = dotProduct*camera.vector.y;
    proj.z = dotProduct*camera.vector.z;
    proj.w = sqrt(pow(proj.x, 2)+pow(proj.y, 2)+pow(proj.z, 2));
    
    //subtract projected vector from the object vector to get the "on screen" vector
    vector_float4 distTo;
    distTo.x = toObject.x-proj.x;
    distTo.y = toObject.y-proj.y;
    distTo.z = toObject.z-proj.z;
    distTo.w = sqrt(pow(distTo.x, 2)+pow(distTo.y, 2)+pow(distTo.z, 2));
    
    //angle from vertical on screen - 0 is straight up - counterclockwise
    //use the plane of the camera with normal vector being where the camera is pointing
    //some method to find the angle between 2 vectors in 2pi radians
    //https://stackoverflow.com/questions/14066933/direct-way-of-computing-clockwise-angle-between-2-vectors/16544330#16544330
    
    float dotProductDistToAndCamUp = (distTo.x*camera.upVector.x)+(distTo.y*camera.upVector.y)+(distTo.z*camera.upVector.z);
    float det = (camera.upVector.x*distTo.y*camera.vector.z) + (distTo.x*camera.vector.y*camera.upVector.z) + (camera.vector.x*camera.upVector.y*distTo.z) - (camera.upVector.z*distTo.y*camera.vector.x) - (distTo.z*camera.vector.y*camera.upVector.x) - (camera.vector.z*camera.upVector.y*distTo.x);
    float angleBetween = atan2(det, dotProductDistToAndCamUp);
    //TODO: add twist
    angleBetween = angleBetween/*-camera.vector.z*/;
    
    //find dimensions of the "screen rectangle" at the location of the object
    //FOV is the angle of the field of view - the whole screen
    float halfWidth = abs(proj.w*tan(camera.FOV.x/2));
    float halfHeight = abs(proj.w*tan(camera.FOV.y/2));
    
    //screen location of object
    float xLoc = -distTo.w*sin(angleBetween);
    float yLoc = distTo.w*cos(angleBetween);
    
    //get screen coordinates
    float screenX = 0;
    float screenY = 0;
    if (halfWidth != 0 && halfHeight != 0) {
        screenX = (xLoc)/(halfWidth);
        screenY = (yLoc)/(halfHeight);
    }
    
    // if dot product is negative then the vertex is behind
    if (dotProduct < 0) {
        return vector_float3(screenX, screenY, -proj.w/render_dist);
    }
    
    return vector_float3(screenX, screenY, proj.w/render_dist);
}

vector_float3 RotateAround (vector_float3 point, vector_float3 origin, vector_float3 angle) {
    vector_float3 vec;
    vec.x = point.x-origin.x;
    vec.y = point.y-origin.y;
    vec.z = point.z-origin.z;
    
    vector_float3 newvec;
    
    // gimbal locked
    
    // around z axis
    newvec.x = vec.x*cos(angle.z)-vec.y*sin(angle.z);
    newvec.y = vec.x*sin(angle.z)+vec.y*cos(angle.z);
    
    vec.x = newvec.x;
    vec.y = newvec.y;
    
    // around y axis
    newvec.x = vec.x*cos(angle.y)+vec.z*sin(angle.y);
    newvec.z = -vec.x*sin(angle.y)+vec.z*cos(angle.y);
    
    vec.x = newvec.x;
    vec.z = newvec.z;
    
    // around x axis
    newvec.y = vec.y*cos(angle.x)-vec.z*sin(angle.x);
    newvec.z = vec.y*sin(angle.x)+vec.z*cos(angle.x);
    
    vec.y = newvec.y;
    vec.z = newvec.z;
    
    point.x = origin.x+vec.x;
    point.y = origin.y+vec.y;
    point.z = origin.z+vec.z;
    
    return point;
}

kernel void CalculateRotatedVertices(device vector_float3 *vertices [[buffer(0)]], unsigned int vid [[thread_position_in_grid]], const constant unsigned int *modelIDs [[buffer(1)]], const constant ModelUniforms *uniforms [[buffer(2)]]) {
    ModelUniforms uniform = uniforms[modelIDs[vid]];
    vector_float3 offset_vertex = vertices[vid];
    offset_vertex.x += uniform.position.x;
    offset_vertex.y += uniform.position.y;
    offset_vertex.z += uniform.position.z;
    vertices[vid] = RotateAround(offset_vertex, uniform.rotate_origin, uniform.angle);
}

kernel void CalculateProjectedVertices(device vector_float3 *vertices [[buffer(0)]], unsigned int vid [[thread_position_in_grid]], constant Camera &camera [[buffer(1)]]) {
    vertices[vid] = PointToPixel(vertices[vid], camera);
}


// UNUSED
/*float sign (vector_float2 p1, vector_float3 p2, vector_float3 p3) {
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

float dist (vector_float2 p1, vector_float3 p2) {
    return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
}

float WeightedZ (vector_float2 click, vector_float3 p1, vector_float3 p2, vector_float3 p3) {
    float dist1 = dist(click, p1);
    float dist2 = dist(click, p2);
    float dist3 = dist(click, p3);
    
    float total_dist = dist1 + dist2 + dist3;
    float weightedZ = p1.z*(dist1/total_dist);
    weightedZ += p2.z*(dist2/total_dist);
    weightedZ += p3.z*(dist3/total_dist);
    return weightedZ;
}

kernel void FaceClicked(device int &clickedIdx [[buffer(0)]], device float &minZ [[buffer(1)]], unsigned int fid [[thread_position_in_grid]], constant vector_float2 &clickLoc [[buffer(2)]], const constant vector_float3 *vertices [[buffer(3)]], device Face *face_array[[buffer(4)]]) {
    float d1, d2, d3;
    bool has_neg, has_pos;
    
    Face face = face_array[fid];
    vector_float3 v1 = vertices[face.vertices[0]];
    vector_float3 v2 = vertices[face.vertices[1]];
    vector_float3 v3 = vertices[face.vertices[2]];

    d1 = sign(clickLoc, v1, v2);
    d2 = sign(clickLoc, v2, v3);
    d3 = sign(clickLoc, v3, v1);

    has_neg = (d1 < 0) || (d2 < 0) || (d3 < 0);
    has_pos = (d1 > 0) || (d2 > 0) || (d3 > 0);

    if (!(has_neg && has_pos)) {
        float z = WeightedZ(clickLoc, v1, v2, v3);
        if (minZ == -1) {
            minZ = z;
            clickedIdx = fid;
        } else if (z < minZ) {
            minZ = z;
            clickedIdx = fid;
        }
    }
}*/

vertex VertexOut DefaultVertexShader (const constant vector_float3 *vertex_array [[buffer(0)]], const constant Face *face_array[[buffer(1)]], unsigned int vid [[vertex_id]]) {
    Face currentFace = face_array[vid/3];
    vector_float3 currentVertex = vertex_array[currentFace.vertices[vid%3]];
    VertexOut output;
    output.pos = vector_float4(currentVertex.x, currentVertex.y, currentVertex.z, 1);
    output.color = currentFace.color;
    return output;
}

vertex VertexOut VertexEdgeShader (const constant vector_float3 *vertex_array [[buffer(0)]], const constant Face *face_array[[buffer(1)]], unsigned int vid [[vertex_id]]) {
    Face currentFace = face_array[vid/4];
    vector_float3 currentVertex = vertex_array[currentFace.vertices[vid%4]];
    VertexOut output;
    output.pos = vector_float4(currentVertex.x, currentVertex.y, currentVertex.z-0.0001, 1);
    output.color = vector_float4(0, 0, 1, 1);
    return output;
}

vertex VertexOut VertexPointShader (const constant vector_float3 *vertex_array [[buffer(0)]], unsigned int vid [[vertex_id]]) {
    vector_float3 currentVertex = vertex_array[vid/4];
    VertexOut output;
    if (vid % 4 == 0) {
        output.pos = vector_float4(currentVertex.x-0.007, currentVertex.y-0.007, currentVertex.z-0.001, 1);
    } else if (vid % 4 == 1) {
        output.pos = vector_float4(currentVertex.x-0.007, currentVertex.y+0.007, currentVertex.z-0.001, 1);
    } else if (vid % 4 == 2) {
        output.pos = vector_float4(currentVertex.x+0.007, currentVertex.y-0.007, currentVertex.z-0.001, 1);
    } else {
        output.pos = vector_float4(currentVertex.x+0.007, currentVertex.y+0.007, currentVertex.z-0.001, 1);
    }
    output.color = vector_float4(0, 1, 0, 1);
    return output;
}

fragment vector_float4 FragmentShader(VertexOut interpolated [[stage_in]]){
    return interpolated.color;
}

/*vertex VertexOut ProjectionCalculationVertexShader (const constant vector_float3 *vertex_array [[buffer(0)]], unsigned int vid [[vertex_id]], const constant vector_float4 *color_array [[buffer(1)]], constant Camera &camera [[buffer(2)]]) {
    vector_float3 currentVertex = vertex_array[vid];
    VertexOut output;
    
    vector_float3 pixel = PointToPixel(currentVertex, camera);
    
    output.pos = vector_float4(pixel.x, pixel.y, pixel.z, 1.0);
    
    output.color = color_array[vid/4];
    
    return output;
}*/
