const std = @import("std");
const Colour = @import("vec.zig").Colour;

pub fn writeColour(writer: std.fs.File.Writer, pixel_colour: *const Colour) anyerror!void {
    const ir = @floatToInt(i32, 255.999 * pixel_colour.x);
    const ig = @floatToInt(i32, 255.999 * pixel_colour.y);
    const ib = @floatToInt(i32, 255.999 * pixel_colour.z);

    try std.fmt.format(writer, "{} {} {}\n", .{ ir, ig, ib });
}
