//
//  PhysicsEngine.m
//  LearnOpenGLESWithGPUImage
//
//  Created by sensetimesunjian on 2018/3/29.
//  Copyright © 2018年 林伟池. All rights reserved.
//

#import "PhysicsEngine.h"
#include "Bullet/btBulletDynamicsCommon.h"
#include "Bullet/btBulletCollisionCommon.h"
#import "RigidBody.h"
#import "BulletUtils.mm"

@interface PhysicsEngine(){
    btDefaultCollisionConfiguration *configration;//碰撞检测
    btCollisionDispatcher *dispatcher;
    btSequentialImpulseConstraintSolver *solver;//受力，约束
    btDbvtBroadphase *broadphase;
    
    btDiscreteDynamicsWorld *world;//物理世界
    NSMutableSet *rigidBodies;
}
@end


@implementation PhysicsEngine

- (instancetype)init
{
    self = [super init];
    if (self) {
        configration = new btDefaultCollisionConfiguration();
        dispatcher = new btCollisionDispatcher(configration);
        solver = new btSequentialImpulseConstraintSolver;
        broadphase = new btDbvtBroadphase();
        world = new btDiscreteDynamicsWorld(dispatcher, broadphase, solver, configration);
        world->setGravity(btVector3(0, -9.8, 0));
        rigidBodies = [NSMutableSet new];
    }
    return self;
}

- (void)dealloc
{
    delete configration;
    delete dispatcher;
    delete solver;
    delete broadphase;
    delete world;
    for (RigidBody * rigidBody in rigidBodies) {
        btRigidBody *btrigidBody = (btRigidBody *)rigidBody.rawBtRigidBodyPointer;
        if (btrigidBody) {
            delete btrigidBody;
        }
    }
}

- (void)update:(NSTimeInterval)deltaTime
{
    world->stepSimulation((btScalar)deltaTime);
    [self syncRigidBodies];
}

- (void)addRigidBody:(RigidBody *)rigidBody
{
    btTransform defaultTransform = btTransformFromGLK(rigidBody.rigidBodyTransform);
    btDefaultMotionState *motionState = new btDefaultMotionState(defaultTransform);
    btVector3 fallInertia(0,0,0);
    btCollisionShape *collisionShape = [self buildCollisionShape: rigidBody];
    collisionShape->calculateLocalInertia(rigidBody.mass, fallInertia);
    btRigidBody *btrigidBody = new btRigidBody(rigidBody.mass, motionState, collisionShape, fallInertia);
    btrigidBody->setRestitution(rigidBody.restitution);
    btrigidBody->setFriction(rigidBody.friction);
    
    world->addRigidBody(btrigidBody);
    btrigidBody->setUserPointer((__bridge void *)rigidBody);
    rigidBody.rawBtRigidBodyPointer = btrigidBody;
    [rigidBodies addObject:rigidBody]; // 保证对rigidBody的持有
}

- (void)syncRigidBodies {
    for (RigidBody * rigidBody in rigidBodies) {
        btRigidBody *btrigidBody = (btRigidBody *)rigidBody.rawBtRigidBodyPointer;
        rigidBody.rigidBodyTransform = glkTransformFromBT(btrigidBody->getWorldTransform());
    }
}

- (btCollisionShape *)buildCollisionShape:(RigidBody *)rigidBody {
    if (rigidBody.rigidBodyShape.type == RigidBodyShapeTypeBox) {
        GLKVector3 boxSize = rigidBody.rigidBodyShape.shapes.box.size;
        return new btBoxShape(btVector3(boxSize.x / 2.0, boxSize.y / 2.0, boxSize.z / 2.0));
    }
    return new btSphereShape(1.0);
}


@end
