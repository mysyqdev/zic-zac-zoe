const std = @import("std");
const Io = std.Io;

const zic_zac_zoe = @import("zic_zac_zoe"); // maybe will be used

const Cell = enum { x, o };

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const table: [3][3]?Cell = .{
        .{ null, null, null },
        .{ null, .x, null },
        .{ null, null, null },
    };

    var stdin_buffer: [1024]u8 = undefined;
    var stdin_file_reader: Io.File.Reader = .init(.stdin(), io, &stdin_buffer);
    const stdin_reader = &stdin_file_reader.interface;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    try stdout_writer.print(
        \\   a b c
        \\ 1 {u}|{u}|{u}
        \\ 2 {u}|{u}|{u}
        \\ 3 {u}|{u}|{u}
        \\
    , tableToTuple(table));
    try stdout_writer.flush();

    const prompt = try stdin_reader.takeDelimiterExclusive('\n');

    try stdout_writer.print("buffer: {s}\n", .{stdin_buffer});
    try stdout_writer.print("out: {s}\n", .{prompt});
    try stdout_writer.flush();

    // Doesn't work. Seek point stays on a new line
    const prompt_new = try stdin_reader.takeDelimiterExclusive('\n');
    try stdout_writer.print("buffer: {s}\n", .{stdin_buffer});
    try stdout_writer.print("out: {s}\n", .{prompt_new});
    try stdout_writer.flush();
}

fn tableToTuple(table: [3][3]?Cell) struct { u8, u8, u8, u8, u8, u8, u8, u8, u8 } {
    var letters: [9]u8 = @splat(0);

    for (table, 0..) |row, y| {
        for (row, 0..) |letter, i| {
            const index = i + (y * 3);
            if (letter) |l| {
                switch (l) {
                    .x => letters[index] = 'x',
                    .o => letters[index] = 'o',
                }
            } else {
                letters[index] = ' ';
            }
        }
    }

    return .{
        letters[0],
        letters[1],
        letters[2],
        letters[3],
        letters[4],
        letters[5],
        letters[6],
        letters[7],
        letters[8],
    };
}
