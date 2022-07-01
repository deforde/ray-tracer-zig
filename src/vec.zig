const std = @import("std");
const randf = @import("util.zig").randf;
const randfmm = @import("util.zig").randfmm;

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

    pub fn randmm(min: f32, max: f32) Vec {
        return Vec{
            .x = randfmm(min, max),
            .y = randfmm(min, max),
            .z = randfmm(min, max),
        };
    }

    pub fn rand() Vec {
        return Vec{
            .x = randf(),
            .y = randf(),
            .z = randf(),
        };
    }

    pub fn randUnitSphere() Vec {
        while (true) {
            const p = Vec.randmm(-1.0, 1.0);
            if (p.lenSqrd() < 1.0) {
                return p;
            }
        }
    }

    pub fn randUnit() Vec {
        // return randUnitSphere().unit();
        return Vec.randmm(-1.0, 1.0).unit(); // TODO: Check this
    }

    pub fn randHemi(n: *const Vec) Vec {
        const v = randUnitSphere();
        if (v.dot(n) > 0.0) {
            return v;
        }
        return v.mulf(-1.0);
    }

    // pub fn rand_unit_disk() Vec {
    // }

    pub fn isNearZero(self: *const Vec) bool {
        const s = 1e-8;
        return (@fabs(self.x) < s) and (@fabs(self.y) < s) and (@fabs(self.z) < s);
    }

    pub fn reflect(self: *const Vec, n: *const Vec) Vec {
        const u = n.mulf(-2.0 * self.dot(n));
        return Vec.addv(&[_]Vec{ self.*, u });
    }

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
