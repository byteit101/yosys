/*
 *  yosys -- Yosys Open SYnthesis Suite
 *
 *  Copyright (C) 2021  Cologne Chip AG <support@colognechip.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

`define MAX(a,b) ((a) > (b) ? (a) : (b))
`define MIN(a,b) ((a) < (b) ? (a) : (b))

(* techmap_celltype = "$mul $__mul" *)
module \$__MULMXN (A, B, Y);

	parameter A_SIGNED = 0;
	parameter B_SIGNED = 0;
	parameter A_WIDTH = 1;
	parameter B_WIDTH = 1;
	parameter Y_WIDTH = 1;

	(* force_downto *)
	input [A_WIDTH-1:0] A;
	(* force_downto *)
	input [B_WIDTH-1:0] B;
	(* force_downto *)
	output [Y_WIDTH-1:0] Y;

	localparam MAXWIDTH = `MAX(A_WIDTH, B_WIDTH) + ((A_SIGNED || B_SIGNED) ? 0 : 1);

	generate
		if (A_SIGNED) begin: blkA
			wire signed [MAXWIDTH-1:0] Aext = $signed(A);
		end
		else begin: blkA
			wire [MAXWIDTH-1:0] Aext = A;
		end
		if (B_SIGNED) begin: blkB
			wire signed [MAXWIDTH-1:0] Bext = $signed(B);
		end
		else begin: blkB
			wire [MAXWIDTH-1:0] Bext = B;
		end

		if (A_WIDTH >= B_WIDTH) begin
			CC_MULT #(
				.A_WIDTH(MAXWIDTH),
				.B_WIDTH(MAXWIDTH),
				.P_WIDTH(`MIN(Y_WIDTH,MAXWIDTH+MAXWIDTH)),
			) _TECHMAP_REPLACE_ (
				.A(blkA.Aext),
				.B(blkB.Bext),
				.P(Y)
			);
		end
		else begin // swap A,B
			CC_MULT #(
				.A_WIDTH(MAXWIDTH),
				.B_WIDTH(MAXWIDTH),
				.P_WIDTH(`MIN(Y_WIDTH,MAXWIDTH+MAXWIDTH)),
			) _TECHMAP_REPLACE_ (
				.A(blkB.Bext),
				.B(blkA.Aext),
				.P(Y)
			);
		end
	endgenerate

endmodule
