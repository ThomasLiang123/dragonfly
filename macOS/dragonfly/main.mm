//
//  main.m
//  dragonfly
//
//  Created by Thomas Liang on 1/13/22.
//

#include "Engine.h"

int main(int, char**) {
    Engine *engine = new Engine();
    
    if (engine->init() == 0) {
        engine->run();
    }
    
    delete engine;
    
    return 0;
}

