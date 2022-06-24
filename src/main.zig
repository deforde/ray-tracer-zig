const std = @import("std");
const Colour = @import("vec.zig").Colour;
const Point = @import("vec.zig").Point;
const Vec = @import("vec.zig").Vec;
const Ray = @import("ray.zig").Ray;
const writeColour = @import("util.zig").writeColour;

fn rayColour(r: *const Ray) Colour {
    if (hitSphere(&Point{ .z = -1.0 }, 0.5, r)) {
        return Colour{ .x = 1.0 };
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

fn hitSphere(centre: *const Point, radius: f32, r: *const Ray) bool {
    const oc = Vec.subv(&[_]Vec{ r.orig, centre.* });
    const a = r.dir.dot(&r.dir);
    const b = oc.dot(&r.dir) * 2.0;
    const c = oc.dot(&oc) - radius * radius;
    const discriminant = b * b - 4 * a * c;
    return discriminant > 0.0;
}

pub fn main() anyerror!void {
    // Image
    const aspect_ratio = 16.0 / 9.0;
    const image_width = 400;
    const image_height = @floatToInt(i32, @intToFloat(f32, image_width) / aspect_ratio);

    // Camera
    const viewport_height = 2.0;
    const viewport_width = aspect_ratio * viewport_height;
    const focal_length = 1.0;

    const origin = Point{};
    const horizontal = Vec{ .x = viewport_width };
    const vertical = Vec{ .y = viewport_height };
    const lower_left_corner = Vec.subv(&[_]Vec{
        origin,
        horizontal.divf(2.0),
        vertical.divf(2.0),
        Vec{ .z = focal_length },
    });

    var file = try std.fs.cwd().createFile("img.ppm", .{});
    defer file.close();

    var writer = file.writer();

    try std.fmt.format(writer, "P3\n{} {}\n255\n", .{ image_width, image_height });

    var j: i32 = image_height - 1;
    while (j >= 0) : (j -= 1) {
        std.debug.print("{}/{}\r", .{ image_height - j, image_height });
        var i: i32 = 0;
        while (i != image_width) : (i += 1) {
            const u = @intToFloat(f32, i) / @intToFloat(f32, image_width - 1);
            const v = @intToFloat(f32, j) / @intToFloat(f32, image_height - 1);

            const dir = Vec.addv(&[_]Vec{
                lower_left_corner,
                horizontal.mulf(u),
                vertical.mulf(v),
                origin.mulf(-1.0),
            });

            const ray = Ray{
                .orig = origin,
                .dir = dir,
            };

            const pixel_colour = rayColour(&ray);

            try writeColour(writer, &pixel_colour);
        }
    }
    std.debug.print("\ndone\n", .{});
}
