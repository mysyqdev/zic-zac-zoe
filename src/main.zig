const std = @import("std");
const Io = std.Io;

const zic_zac_zoe = @import("zic_zac_zoe");

const Cell = enum { x, o };

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var should_game_stop = false;
    const error_msg = "Invalid move, please try again.";
    var table: [3][3]?Cell = @splat(@splat(null));

    var stdin_buffer: [1024]u8 = undefined;
    var stdin_file_reader: Io.File.Reader = .init(.stdin(), io, &stdin_buffer);
    const stdin_reader = &stdin_file_reader.interface;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    outer: while (!should_game_stop) {
        try stdout_writer.flush(); // for error messages

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
                try stdout_writer.print("{s}\n", .{error_msg});
                continue :outer;
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
                try stdout_writer.print("{s}\n", .{error_msg});
                continue :outer;
            }
        }

        if (table[column][row] == null) {
            table[column][row] = cell;
        } else {
            try stdout_writer.print("{s}\n", .{error_msg});
            continue :outer;
        }

        const winner = checkForWin(table);

        if (winner != null) {
            var char: u8 = undefined;
            switch (winner.?) {
                .x => {
                    char = 'X';
                },
                .o => {
                    char = 'O';
                },
            }
            try stdout_writer.print("{c} is winner!\n", .{char});
            should_game_stop = true;
        } else {
            if (!areThereEmptyCells(table)) {
                try stdout_writer.print("Draw!\n", .{});
                should_game_stop = true;
            }
        }
    }

    try stdout_writer.print(
        \\   a b c
        \\ 1 {u}|{u}|{u}
        \\ 2 {u}|{u}|{u}
        \\ 3 {u}|{u}|{u}
        \\
    , tableToTuple(table));
    try stdout_writer.flush();
}

fn areThereEmptyCells(table: [3][3]?Cell) bool {
    for (table) |row| {
        for (row) |cell| {
            if (cell == null) return true;
        }
    }

    return false;
}

fn checkForWin(table: [3][3]?Cell) ?Cell {
    // Check for vertical match
    for (0..3) |i| {
        if (table[i][0] == table[i][1] and table[i][1] == table[i][2] and table[i][0] != null) {
            return table[i][0];
        }
    }

    // Check for horizontal match
    for (0..3) |i| {
        if (table[0][i] == table[1][i] and table[1][i] == table[2][i] and table[0][i] != null) {
            return table[0][i];
        }
    }

    // Check for diagonal match
    if (table[0][0] == table[1][1] and table[1][1] == table[2][2] and table[0][0] != null) {
        return table[0][0];
    }
    if (table[0][2] == table[1][1] and table[1][1] == table[2][0] and table[0][2] != null) {
        return table[0][2];
    }

    return null;
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
