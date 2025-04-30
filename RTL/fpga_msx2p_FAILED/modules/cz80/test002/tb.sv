// -----------------------------------------------------------------------------
//	Test
// -----------------------------------------------------------------------------

module tb ();
	reg				clk;

	reg				f;

	// --------------------------------------------------------------------
	//	clock
	// --------------------------------------------------------------------
	always #10 begin
		clk <= ~clk;
	end

	// --------------------------------------------------------------------
	//	Test bench
	// --------------------------------------------------------------------
	initial begin
		clk			= 0;
		f			= 1'bX;

		@( posedge clk );

		if( f == 1'b0 ) begin
			$display( "f == 1'b0 : true" );
		end
		else begin
			$display( "f == 1'b0 : false" );
		end

		if( f == 1'b1 ) begin
			$display( "f == 1'b1 : true" );
		end
		else begin
			$display( "f == 1'b1 : false" );
		end

		if( f == 1'bX ) begin
			$display( "f == 1'bX : true" );
		end
		else begin
			$display( "f == 1'bX : false" );
		end

		if( f != 1'b0 ) begin
			$display( "f != 1'b0 : true" );
		end
		else begin
			$display( "f != 1'b0 : false" );
		end

		if( f != 1'b1 ) begin
			$display( "f != 1'b1 : true" );
		end
		else begin
			$display( "f != 1'b1 : false" );
		end

		if( f != 1'bX ) begin
			$display( "f != 1'bX : true" );
		end
		else begin
			$display( "f != 1'bX : false" );
		end

		if( f === 1'bX ) begin
			$display( "f === 1'bX : true" );
		end
		else begin
			$display( "f === 1'bX : false" );
		end
		$finish;
	end
endmodule
