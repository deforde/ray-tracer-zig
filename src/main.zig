const std = @import("std");
const Colour = @import("vec.zig").Colour;
const Point = @import("vec.zig").Point;
const Vec = @import("vec.zig").Vec;
const Ray = @import("ray.zig").Ray;
const Hittable = @import("hittable.zig").Hittable;
const HitRecord = @import("hittable.zig").HitRecord;
const HittableList = @import("hittable_list.zig").HittableList;
const Sphere = @import("sphere.zig").Sphere;
const Camera = @import("camera.zig").Camera;
const Material = @import("material.zig").Material;
const Lambertian = @import("lambertian.zig").Lambertian;
const Metal = @import("metal.zig").Metal;
const Dielectric = @import("dielectric.zig").Dielectric;
const randf = @import("util.zig").randf;
const writeColour = @import("util.zig").writeColour;

fn rayColour(r: *const Ray, world: *const HittableList, depth: i32) anyerror!Colour {
    if (depth <= 0) {
        return Colour{};
    }

    var rec = HitRecord{};
    if (world.hit(r, 0.001, std.math.floatMax(f32), &rec)) {
        var scattered = Ray{};
        var att = Colour{};
        if (rec.m.?.scatter(r, &rec, &att, &scattered)) {
            return Vec.mulv(&[_]Vec{ att, try rayColour(&scattered, world, depth - 1) });
        }
        return Colour{};
    }
    const unit_dir = r.dir.unit();
    const t = 0.5 * (unit_dir.y + 1.0);
    const a = Colour{
        .x = 1.0,
        .y = 1.0,
        .z = 1.0,
    };
    const b = Colour{
        .x = 0.5,
        .y = 0.7,
        .z = 1.0,
    };
    return Vec.addv(&[_]Vec{
        a.mulf(1.0 - t),
        b.mulf(t),
    });
}

fn hitSphere(centre: *const Point, radius: f32, r: *const Ray) f32 {
    const oc = Vec.subv(&[_]Vec{ r.orig, centre.* });
    const a = r.dir.lenSqrd();
    const half_b = oc.dot(&r.dir);
    const c = oc.lenSqrd() - radius * radius;
    const discriminant = half_b * half_b - a * c;
    if (discriminant < 0.0) {
        return -1.0;
    }
    return (-half_b - std.math.sqrt(discriminant)) / a;
}

pub fn main() anyerror!void {
    // Image
    const aspect_ratio = 16.0 / 9.0;
    const image_width = 400;
    const image_height = @floatToInt(i32, @intToFloat(f32, image_width) / aspect_ratio);
    const samples_per_pixel = 100;
    const max_depth = 50;
    const vfov = 20.0;
    const lookfrom = Point{ .x = 3, .y = 3, .z = 2 };
    const lookat = Point{ .z = -1 };
    const vup = Vec{ .y = 1 };
    const dist_to_focus = Vec.subv(&[_]Vec{ lookfrom, lookat }).len();
    const aperture = 2.0;

    // World
    var world = HittableList{};
    const mat_gnd = Material{ .lambertian = Lambertian{ .albedo = Colour{ .x = 0.8, .y = 0.8 } } };
    const mat_centre = Material{ .lambertian = Lambertian{ .albedo = Colour{ .x = 0.1, .y = 0.2, .z = 0.5 } } };
    const mat_left = Material{ .dielectric = Dielectric{ .refr_idx = 1.5 } };
    const mat_right = Material{ .metal = Metal{ .albedo = Colour{ .x = 0.8, .y = 0.6, .z = 0.2 }, .fuzz = 0.0 } };
    const sphere_gnd = Hittable{ .sphere = Sphere{ .centre = Point{ .y = -100.5, .z = -1 }, .radius = 100, .mat = &mat_gnd } };
    const sphere_centre = Hittable{ .sphere = Sphere{ .centre = Point{ .z = -1 }, .radius = 0.5, .mat = &mat_centre } };
    const sphere_left = Hittable{ .sphere = Sphere{ .centre = Point{ .x = -1, .z = -1 }, .radius = 0.5, .mat = &mat_left } };
    const inner_sphere_left = Hittable{ .sphere = Sphere{ .centre = Point{ .x = -1, .z = -1 }, .radius = -0.45, .mat = &mat_left } };
    const sphere_right = Hittable{ .sphere = Sphere{ .centre = Point{ .x = 1, .z = -1 }, .radius = 0.5, .mat = &mat_right } };
    world.add(&sphere_gnd);
    world.add(&sphere_centre);
    world.add(&sphere_left);
    world.add(&inner_sphere_left);
    world.add(&sphere_right);

    // Camera
    var cam = Camera{};
    cam.init(&lookfrom, &lookat, &vup, vfov, aspect_ratio, aperture, dist_to_focus);

    var file = try std.fs.cwd().createFile("img.ppm", .{});
    defer file.close();

    var writer = file.writer();

    try std.fmt.format(writer, "P3\n{} {}\n255\n", .{ image_width, image_height });

    var j: i32 = image_height - 1;
    while (j >= 0) : (j -= 1) {
        std.debug.print("{}/{}\r", .{ image_height - j, image_height });
        var i: i32 = 0;
        while (i != image_width) : (i += 1) {
            var pixel_colour = Colour{};
            var s: usize = 0;
            while (s < samples_per_pixel) : (s += 1) {
                const u = (@intToFloat(f32, i) + randf()) / @intToFloat(f32, image_width - 1);
                const v = (@intToFloat(f32, j) + randf()) / @intToFloat(f32, image_height - 1);
                const r = cam.getRay(u, v);
                pixel_colour = Vec.addv(&[_]Vec{
                    pixel_colour,
                    try rayColour(&r, &world, max_depth),
                });
            }

            try writeColour(writer, &pixel_colour, samples_per_pixel);
        }
    }
    std.debug.print("\ndone\n", .{});
}
