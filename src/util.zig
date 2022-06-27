const std = @import("std");
const Colour = @import("vec.zig").Colour;

var rand_impl = std.rand.DefaultPrng.init(42);

pub fn writeColour(writer: std.fs.File.Writer, pixel_colour: *const Colour, samples_per_pixel: usize) anyerror!void {
    const scale = 1.0 / @intToFloat(f32, samples_per_pixel);

    const r = scale * pixel_colour.x;
    const g = scale * pixel_colour.y;
    const b = scale * pixel_colour.z;

    const ir = @floatToInt(i32, 256.0 * clamp(r, 0.0, 0.999));
    const ig = @floatToInt(i32, 256.0 * clamp(g, 0.0, 0.999));
    const ib = @floatToInt(i32, 256.0 * clamp(b, 0.0, 0.999));

    try std.fmt.format(writer, "{} {} {}\n", .{ ir, ig, ib });
}

pub fn randomf() f32 {
    return rand_impl.random().float(f32);
}

pub fn randomfmm(min: f32, max: f32) f32 {
    return min * (max - min) * randomf();
}

pub fn clamp(x: f32, min: f32, max: f32) f32 {
    if (x < min) {
        return min;
    }
    if (x > max) {
        return max;
    }
    return x;
}
