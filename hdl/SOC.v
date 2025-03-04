module SOC #(
    // Features configuration
    parameter   IP_AMT              = 1,    // Number of Image processor    
    // AXI4 configurati
    parameter   MST_ID_W            = 3,
    parameter   DATA_WIDTH          = 256,
    parameter   ADDR_WIDTH          = 32,
    parameter   TRANS_BURST_W       = 2,    // Width of xBURST 
    parameter   TRANS_DATA_LEN_W    = 3,    // Bus width of xLEN
    parameter   TRANS_DATA_SIZE_W   = 3,    // Bus width of xSIZE
    parameter   TRANS_WR_RESP_W     = 2,
    // Image processor configuaration
    parameter   PG_WIDTH            = 256,
    parameter   CELL_WIDTH          = 768,
    parameter   CELL_NUM            = 1200,
    parameter   FRAME_ROW_CNUM      = 30,               // 30 cells
    parameter   FRAME_COL_CNUM      = 40,               // 40 cells
    parameter   CELL_ROW_PNUM       = 8,                // 8 pixels
    parameter   CELL_COL_PNUM       = 8,                // 8 pixels

    // hog_svm parameter
    parameter   PIX_W               = 8, // pixel width
    parameter   MAG_F               = 4,// fraction part of magnitude
    parameter   TAN_I               = 4, // tan width
    parameter   TAN_F               = 16, // tan width
    parameter   BIN_I               = 16, // integer part of bin
    parameter   FEA_I               = 4, // integer part of hog feature
    parameter   FEA_F               = 16, // fractional part of hog feature
    parameter   SW_W                = 11, // slide window width
    parameter   CELL_S              = 10 // Size of cell, default 8x8 pixel and border
)(
    input clk,
    input rst
);
    
    wire [CELL_WIDTH - 1 : 0] cell_data;
    wire cell_valid;
    wire cell_ready; 
    axi4_frame_fetch #(
        // Features configuration
        .IP_AMT               (IP_AMT),
        // Number of Image processor    
        // AXI4 configurati
        .MST_ID_W             (MST_ID_W),
        .DATA_WIDTH           (DATA_WIDTH),
        .ADDR_WIDTH           (ADDR_WIDTH),
        .TRANS_BURST_W        (TRANS_BURST_W),
        // Width of xBURST 
        .TRANS_DATA_LEN_W     (TRANS_DATA_LEN_W),
        // Bus width of xLEN
        .TRANS_DATA_SIZE_W    (TRANS_DATA_SIZE_W),
        // Bus width of xSIZE
        .TRANS_WR_RESP_W      (TRANS_WR_RESP_W),
        // Image processor configuaration
        .PG_WIDTH             (PG_WIDTH),
        .CELL_WIDTH           (CELL_WIDTH),
        .CELL_NUM             (CELL_NUM),
        .FRAME_ROW_CNUM       (FRAME_ROW_CNUM),
        // 30 cells
        .FRAME_COL_CNUM       (FRAME_COL_CNUM),
        // 40 cells
        .CELL_ROW_PNUM        (CELL_ROW_PNUM),
        // 8 pixels
        .CELL_COL_PNUM        (CELL_COL_PNUM),
        // 8 pixels
        .FRAME_COL_BNUM       (FRAME_COL_CNUM/2),
        // 20 blocks
        .FRAME_COL_PGNUM      (FRAME_COL_CNUM/4)
        // 10 pixel groups
    ) u_axi4_frame_fetch (
        // Input declaration
        // -- Global signals
        .ACLK_i               (clk),
        .ARESETn_i            (rst),
        // -- To Master
        // ---- Write address channel
        .m_AWID_i             (),
        .m_AWADDR_i           (),
        .m_AWVALID_i          (),
        // ---- Write data channel
        .m_WDATA_i            (),
        .m_WLAST_i            (),
        .m_WVALID_i           (),
        // ---- Write response channel
        .m_BREADY_i           (),
        // -- To HOG
        .cell_ready_i         (cell_ready),
        // Output declaration
        // -- To Master 
        // ---- Write address channel (master)
        .m_AWREADY_o          (),
        // ---- Write data channel (master)
        .m_WREADY_o           (),
        // ---- Write response channel (master)
        .m_BID_o              (),
        .m_BRESP_o            (),
        .m_BVALID_o           (),
        // -- To HOG
        .cell_data_o          (cell_data),
        .cell_valid_o         (cell_valid)
    );
    hog_svm #(
        .PIX_W           (PIX_W),
        // pixel width
        .MAG_F           (MAG_F),
        // fraction part of magnitude
        .TAN_I           (TAN_I),
        // tan width
        .TAN_F           (TAN_F),
        // tan width
        .BIN_I           (BIN_I),
        // integer part of bin
        .FEA_I           (FEA_I),
        // integer part of hog feature
        .FEA_F           (FEA_F),
        // fractional part of hog feature
        .SW_W            (SW_W),
        // slide window width
        .CELL_S          (CELL_S)
    ) u_hog_svm (
        //// hog if
        .clk             (clk),
        .rst             (rst),
        .ready           (cell_valid_o),
        .request         (cell_ready),
        .i_data_fetch    (cell_data),
        //// svm if
        // ram interface
        .addr_a          (),
        .write_en        (),
        .i_data_a        (),
        .o_data_a        (),
        // bias
        .bias            (),
        .b_load          (),
        // svm if
        .o_valid         (o_valid),
        .is_person       (is_person),
        .sw_id           (sw_id),
        // led
        .led             (led)
    );
endmodule