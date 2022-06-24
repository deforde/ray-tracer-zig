const std = @import("std");

pub fn main() anyerror!void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};

    var list = std.ArrayList(u8).init(alloc.allocator());

    std.debug.print("list = {any}\n", .{list.items});

    try list.append(1);

    std.debug.print("list = {any}\n", .{list.items});

    _ = list;
}
