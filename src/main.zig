const std = @import("std");
const Io = std.Io;

const zic_zac_zoe = @import("zic_zac_zoe"); // maybe will be used

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;
    try stdout_writer.print("salem alem!\n", .{});
    try stdout_writer.flush();
}
