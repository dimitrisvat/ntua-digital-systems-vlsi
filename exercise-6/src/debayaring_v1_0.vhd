library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debayaring_v1_0 is
    generic (
        C_S00_AXI_DATA_WIDTH    : integer := 32;
        C_S00_AXI_ADDR_WIDTH    : integer := 4;
        C_S00_AXIS_TDATA_WIDTH  : integer := 8;
        C_M00_AXIS_TDATA_WIDTH  : integer := 32;
        C_M00_AXIS_START_COUNT  : integer := 32
    );
    port (
        -- Ports of Axi Slave Bus Interface S00_AXI
        s00_axi_aclk    : in std_logic;
        s00_axi_aresetn : in std_logic;
        s00_axi_awaddr  : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
        s00_axi_awprot  : in std_logic_vector(2 downto 0);
        s00_axi_awvalid : in std_logic;
        s00_axi_awready : out std_logic;
        s00_axi_wdata   : in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        s00_axi_wstrb   : in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
        s00_axi_wvalid  : in std_logic;
        s00_axi_wready  : out std_logic;
        s00_axi_bresp   : out std_logic_vector(1 downto 0);
        s00_axi_bvalid  : out std_logic;
        s00_axi_bready  : in std_logic;
        s00_axi_araddr  : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
        s00_axi_arprot  : in std_logic_vector(2 downto 0);
        s00_axi_arvalid : in std_logic;
        s00_axi_arready : out std_logic;
        s00_axi_rdata   : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        s00_axi_rresp   : out std_logic_vector(1 downto 0);
        s00_axi_rvalid  : out std_logic;
        s00_axi_rready  : in std_logic;

        -- Ports of Axi Slave Bus Interface S00_AXIS
        s00_axis_aclk    : in std_logic;
        s00_axis_aresetn : in std_logic;
        s00_axis_tready  : out std_logic;
        s00_axis_tdata   : in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
        s00_axis_tstrb   : in std_logic_vector((C_S00_AXIS_TDATA_WIDTH/8)-1 downto 0);
        s00_axis_tlast   : in std_logic;
        s00_axis_tvalid  : in std_logic;

        -- Ports of Axi Master Bus Interface M00_AXIS
        m00_axis_aclk    : in std_logic;
        m00_axis_aresetn : in std_logic;
        m00_axis_tvalid  : out std_logic;
        m00_axis_tdata   : out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
        m00_axis_tstrb   : out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0);
        m00_axis_tlast   : out std_logic;
        m00_axis_tready  : in std_logic
    );
end debayaring_v1_0;

architecture arch_imp of debayaring_v1_0 is

    -- component declaration
    component debayaring_v1_0_S00_AXI is
        generic (
            C_S_AXI_DATA_WIDTH : integer := 32;
            C_S_AXI_ADDR_WIDTH : integer := 4
        );
        port (
            image_dim     : out std_logic_vector(15 downto 0);
            image_dim_vld : out std_logic;
            S_AXI_ACLK    : in std_logic;
            S_AXI_ARESETN : in std_logic;
            S_AXI_AWADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_AWPROT  : in std_logic_vector(2 downto 0);
            S_AXI_AWVALID : in std_logic;
            S_AXI_AWREADY : out std_logic;
            S_AXI_WDATA   : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_WSTRB   : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
            S_AXI_WVALID  : in std_logic;
            S_AXI_WREADY  : out std_logic;
            S_AXI_BRESP   : out std_logic_vector(1 downto 0);
            S_AXI_BVALID  : out std_logic;
            S_AXI_BREADY  : in std_logic;
            S_AXI_ARADDR  : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
            S_AXI_ARPROT  : in std_logic_vector(2 downto 0);
            S_AXI_ARVALID : in std_logic;
            S_AXI_ARREADY : out std_logic;
            S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
            S_AXI_RRESP   : out std_logic_vector(1 downto 0);
            S_AXI_RVALID  : out std_logic;
            S_AXI_RREADY  : in std_logic
        );
    end component debayaring_v1_0_S00_AXI;

    component debayaring_v1_0_S00_AXIS is
        generic (
            C_S_AXIS_TDATA_WIDTH : integer := 32
        );
        port (
            pixel      : out std_logic_vector(7 downto 0);
            valid_in   : out std_logic;
            new_image  : out std_logic;
            configured : in  std_logic;
            S_AXIS_ACLK    : in std_logic;
            S_AXIS_ARESETN : in std_logic;
            S_AXIS_TREADY  : out std_logic;
            S_AXIS_TDATA   : in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
            S_AXIS_TSTRB   : in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
            S_AXIS_TLAST   : in std_logic;
            S_AXIS_TVALID  : in std_logic
        );
    end component debayaring_v1_0_S00_AXIS;

    component debayaring_v1_0_M00_AXIS is
        generic (
            C_M_AXIS_TDATA_WIDTH : integer := 32;
            C_M_START_COUNT      : integer := 32
        );
        port (
            R              : in std_logic_vector(7 downto 0);
            G              : in std_logic_vector(7 downto 0);
            B              : in std_logic_vector(7 downto 0);
            valid_out      : in std_logic;
            image_finished : in std_logic;
            M_AXIS_ACLK    : in std_logic;
            M_AXIS_ARESETN : in std_logic;
            M_AXIS_TVALID  : out std_logic;
            M_AXIS_TDATA   : out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
            M_AXIS_TSTRB   : out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
            M_AXIS_TLAST   : out std_logic;
            M_AXIS_TREADY  : in std_logic
        );
    end component debayaring_v1_0_M00_AXIS;

    component debayering_filter is
        port (
            clk           : in std_logic;
            rst_n         : in std_logic;
            new_image     : in std_logic;
            valid_in      : in std_logic;
            pixel         : in std_logic_vector(7 downto 0);
            image_dim     : in std_logic_vector(15 downto 0);
            image_dim_vld : in std_logic;
            image_finished : out std_logic;
            valid_out     : out std_logic;
            R             : out std_logic_vector(7 downto 0);
            G             : out std_logic_vector(7 downto 0);
            B             : out std_logic_vector(7 downto 0)
        );
    end component debayering_filter;

    -- internal signals
    signal s_image_dim     : std_logic_vector(15 downto 0);
    signal s_image_dim_vld : std_logic;

    signal s_pixel    : std_logic_vector(7 downto 0);
    signal s_valid_in : std_logic;

    signal s_R             : std_logic_vector(7 downto 0);
    signal s_G             : std_logic_vector(7 downto 0);
    signal s_B             : std_logic_vector(7 downto 0);
    signal s_valid_out     : std_logic;
    signal s_image_finished: std_logic;

    signal s_flag      : std_logic := '1';
    signal s_new_image : std_logic;

begin

    -- Instantiation of Axi Bus Interface S00_AXI
    debayaring_v1_0_S00_AXI_inst : debayaring_v1_0_S00_AXI
        generic map (
            C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
            C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH
        )
        port map (
            image_dim     => s_image_dim,
            image_dim_vld => s_image_dim_vld,
            S_AXI_ACLK    => s00_axi_aclk,
            S_AXI_ARESETN => s00_axi_aresetn,
            S_AXI_AWADDR  => s00_axi_awaddr,
            S_AXI_AWPROT  => s00_axi_awprot,
            S_AXI_AWVALID => s00_axi_awvalid,
            S_AXI_AWREADY => s00_axi_awready,
            S_AXI_WDATA   => s00_axi_wdata,
            S_AXI_WSTRB   => s00_axi_wstrb,
            S_AXI_WVALID  => s00_axi_wvalid,
            S_AXI_WREADY  => s00_axi_wready,
            S_AXI_BRESP   => s00_axi_bresp,
            S_AXI_BVALID  => s00_axi_bvalid,
            S_AXI_BREADY  => s00_axi_bready,
            S_AXI_ARADDR  => s00_axi_araddr,
            S_AXI_ARPROT  => s00_axi_arprot,
            S_AXI_ARVALID => s00_axi_arvalid,
            S_AXI_ARREADY => s00_axi_arready,
            S_AXI_RDATA   => s00_axi_rdata,
            S_AXI_RRESP   => s00_axi_rresp,
            S_AXI_RVALID  => s00_axi_rvalid,
            S_AXI_RREADY  => s00_axi_rready
        );

    -- Instantiation of Axi Bus Interface S00_AXIS
    debayaring_v1_0_S00_AXIS_inst : debayaring_v1_0_S00_AXIS
        generic map (
            C_S_AXIS_TDATA_WIDTH => C_S00_AXIS_TDATA_WIDTH
        )
        port map (
            pixel      => s_pixel,
            valid_in   => s_valid_in,
            new_image  => open,         -- not used, FLAG logic is implemented in this top module
            configured => s_image_dim_vld,
            S_AXIS_ACLK    => s00_axis_aclk,
            S_AXIS_ARESETN => s00_axis_aresetn,
            S_AXIS_TREADY  => s00_axis_tready,
            S_AXIS_TDATA   => s00_axis_tdata,
            S_AXIS_TSTRB   => s00_axis_tstrb,
            S_AXIS_TLAST   => s00_axis_tlast,
            S_AXIS_TVALID  => s00_axis_tvalid
        );

    -- Instantiation of Axi Bus Interface M00_AXIS
    debayaring_v1_0_M00_AXIS_inst : debayaring_v1_0_M00_AXIS
        generic map (
            C_M_AXIS_TDATA_WIDTH => C_M00_AXIS_TDATA_WIDTH,
            C_M_START_COUNT      => C_M00_AXIS_START_COUNT
        )
        port map (
            R              => s_R,
            G              => s_G,
            B              => s_B,
            valid_out      => s_valid_out,
            image_finished => s_image_finished,
            M_AXIS_ACLK    => m00_axis_aclk,
            M_AXIS_ARESETN => m00_axis_aresetn,
            M_AXIS_TVALID  => m00_axis_tvalid,
            M_AXIS_TDATA   => m00_axis_tdata,
            M_AXIS_TSTRB   => m00_axis_tstrb,
            M_AXIS_TLAST   => m00_axis_tlast,
            M_AXIS_TREADY  => m00_axis_tready
        );

    -- Instantiation of debayering_filter
    DEBAYER : debayering_filter
        port map (
            clk            => s00_axis_aclk,
            rst_n          => s00_axis_aresetn,
            new_image      => s_new_image,
            valid_in       => s_valid_in,
            pixel          => s_pixel,
            image_dim      => s_image_dim,
            image_dim_vld  => s_image_dim_vld,
            image_finished => s_image_finished,
            valid_out      => s_valid_out,
            R              => s_R,
            G              => s_G,
            B              => s_B
        );

    -- Add user logic here

    s_new_image <= s_flag and s_valid_in;

    FLAG: process(s00_axis_aclk, s00_axis_aresetn)
    begin
        if s00_axis_aresetn = '0' then
            s_flag <= '1';
        elsif rising_edge(s00_axis_aclk) then
            if s_valid_in = '1' then
                s_flag <= '0';
            elsif s_image_finished = '1' then
                s_flag <= '1';
            end if;
        end if;
    end process;

    -- User logic ends

end arch_imp;