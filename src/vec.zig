const std = @import("std");

pub const Vec = struct {
    x: f32 = 0.0,
    y: f32 = 0.0,
    z: f32 = 0.0,

    pub fn len(self: *const Vec) f32 {
        return std.math.sqrt(self.lenSqrd());
    }

    pub fn lenSqrd(self: *const Vec) f32 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub fn unit(self: *const Vec) Vec {
        return self.divf(self.len());
    }

    pub fn dot(self: *const Vec, other: *const Vec) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    // pub fn cross(self: *Vec, other: *Vec) Vec {
    // }
    //
    // pub fn rand_mm(min: f32, max: f32) Vec {
    // }
    //
    // pub fn rand() Vec {
    // }
    //
    // pub fn rand_unit_sphere() Vec {
    // }
    //
    // pub fn rand_unit() Vec {
    // }
    //
    // pub fn rand_hemi() Vec {
    // }
    //
    // pub fn rand_unit_disk() Vec {
    // }
    //
    // pub fn is_near_zero(self: *Vec) bool {
    // }
    //
    // pub fn reflect(self: *Vec, normal: *Vec) Vec {
    // }
    //
    // pub fn refract(self: *Vec, normal: *Vec, coeff: f32) Vec {
    // }

    pub fn addv(vecs: []const Vec) Vec {
        var v = vecs[0];
        for (vecs[1..]) |vec| {
            v.x += vec.x;
            v.y += vec.y;
            v.z += vec.z;
        }
        return v;
    }

    pub fn subv(vecs: []const Vec) Vec {
        var v = vecs[0];
        for (vecs[1..]) |vec| {
            v.x -= vec.x;
            v.y -= vec.y;
            v.z -= vec.z;
        }
        return v;
    }

    pub fn mulv(vecs: []const Vec) Vec {
        var v = vecs[0];
        for (vecs[1..]) |vec| {
            v.x *= vec.x;
            v.y *= vec.y;
            v.z *= vec.z;
        }
        return v;
    }

    pub fn divv(vecs: []const Vec) Vec {
        var v = vecs[0];
        for (vecs[1..]) |vec| {
            v.x /= vec.x;
            v.y /= vec.y;
            v.z /= vec.z;
        }
        return v;
    }

    pub fn addf(self: *const Vec, val: f32) Vec {
        var v: Vec = self.*;
        v.x += val;
        v.y += val;
        v.z += val;
        return v;
    }

    pub fn subf(self: *const Vec, val: f32) Vec {
        var v: Vec = self.*;
        v.x -= val;
        v.y -= val;
        v.z -= val;
        return v;
    }

    pub fn mulf(self: *const Vec, val: f32) Vec {
        var v: Vec = self.*;
        v.x *= val;
        v.y *= val;
        v.z *= val;
        return v;
    }

    pub fn divf(self: *const Vec, val: f32) Vec {
        var v: Vec = self.*;
        v.x /= val;
        v.y /= val;
        v.z /= val;
        return v;
    }
};

pub const Point = Vec;
pub const Colour = Vec;
