const std = @import("std");
const Io = std.Io;

const zic_zac_zoe = @import("zic_zac_zoe"); // maybe will be used

const Cell = enum { x, o };

// Mayde store move history in a file
pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var should_game_stop = false;
    var table: [3][3]?Cell = .{
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

    while (!should_game_stop) {
        try stdout_writer.print(
            \\   a b c
            \\ 1 {u}|{u}|{u}
            \\ 2 {u}|{u}|{u}
            \\ 3 {u}|{u}|{u}
            \\
        , tableToTuple(table));

        try stdout_writer.print("Your move: ", .{});
        try stdout_writer.flush();

        const move = try stdin_reader.takeDelimiter('\n') orelse unreachable;
        var column: u8 = undefined;
        var row: u8 = undefined;
        var cell: Cell = undefined;

        for (move, 0..) |char, index| {
            if (index > 2) {
                unreachable;
            }

            if (char >= 'a' and char <= 'c') {
                row = char - 'a';
            } else if (char >= '1' and char <= '3') {
                column = char - '1';
            } else if (char == 'x') {
                cell = .x;
            } else if (char == 'o') {
                cell = .o;
            } else {
                unreachable;
            }
        }

        if (table[column][row] == null) {
            table[column][row] = cell;
        } else {
            try stdout_writer.print("You can't make this move\n", .{});
            try stdout_writer.flush();
        }

        // TODO: Check the table for possible win
        should_game_stop = true;
    }
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
