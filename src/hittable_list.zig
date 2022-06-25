const std = @import("std");
const Hittable = @import("hittable.zig").Hittable;
const HitRecord = @import("hittable.zig").HitRecord;
const Ray = @import("ray.zig").Ray;

const MAX_NUM_HITTABLE_OBJECTS = 4096;

pub const HittableList = struct {
    objects: [MAX_NUM_HITTABLE_OBJECTS]Hittable = undefined,
    n: usize = 0,

    pub fn add(self: *HittableList, obj: *const Hittable) void {
        self.objects[self.n] = obj.*;
        self.n += 1;
    }

    pub fn clear(self: *HittableList) void {
        self.n = 0;
    }

    pub fn hit(self: *const HittableList, r: *const Ray, t_min: f32, t_max: f32, rec: *HitRecord) bool {
        var temp_rec = HitRecord{};
        var hit_anything = false;
        var closest_so_far = t_max;

        for (self.objects[0..self.n]) |obj| {
            if (obj.hit(r, t_min, closest_so_far, &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }

        return hit_anything;
    }
};
