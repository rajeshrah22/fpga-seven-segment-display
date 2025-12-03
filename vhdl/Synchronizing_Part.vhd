library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_1deep_sync is
    generic (
        DATA_WIDTH : integer := 8
    );
    port (
        -- Write side
        wclk    : in  std_logic;
        wrst_n  : in  std_logic;
        wput    : in  std_logic;
        wrdy    : out std_logic;
        data_in : in  std_logic_vector(DATA_WIDTH-1 downto 0);

        -- Read side
        rclk    : in  std_logic;
        rrst_n  : in  std_logic;
        rget    : in  std_logic;
        rrdy    : out std_logic;
        data_out: out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end fifo_1deep_sync;



architecture rtl of fifo_1deep_sync is

    -----------------------------------------------------------------
    -- Two-register RAM (only one entry used at a time)
    -----------------------------------------------------------------
    type ram_type is array(1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal ram : ram_type;

    -----------------------------------------------------------------
    -- Pointers (1-bit each)
    -----------------------------------------------------------------
    signal wptr, rptr : std_logic;

    -----------------------------------------------------------------
    -- Cross-domain synchronized pointers
    -----------------------------------------------------------------
    signal wq1_rptr, wq2_rptr : std_logic;
    signal rq1_wptr, rq2_wptr : std_logic;
	 
	 -----------------------------------------------------------------
    -- Write-Enable
    -----------------------------------------------------------------
	 signal we : std_logic
	 
begin

    -----------------------------------------------------------------
    -- WRITE-SIDE POINTER SYNCHRONIZER  (sync2 block)
    -----------------------------------------------------------------
    process (wclk, wrst_n)
    begin
        if wrst_n = '0' then
            wq1_rptr <= '0';
            wq2_rptr <= '0';
        elsif rising_edge(wclk) then
            wq1_rptr <= rptr;       -- First stage
            wq2_rptr <= wq1_rptr;   -- Second stage
        end if;
    end process;

    -----------------------------------------------------------------
    -- READ-SIDE POINTER SYNCHRONIZER (sync2 block)
    -----------------------------------------------------------------
    process (rclk, rrst_n)
    begin
        if rrst_n = '0' then
            rq1_wptr <= '0';
            rq2_wptr <= '0';
        elsif rising_edge(rclk) then
            rq1_wptr <= wptr;
            rq2_wptr <= rq1_wptr;
        end if;
    end process;
	
	-----------------------------------------------------------------
    -- READ-SIDE rctl Logic
   -----------------------------------------------------------------
	process (rclk)
	begin
		 if rising_edge(clk) then
			  rptr <= rptr XOR (rget AND (rq2_wptr XOR rptr));
		 end if;
		 rrdy <= rq2_wptr XOR rptr;
		 
	end process;

	-----------------------------------------------------------------
    -- WRITE-SIDE rctl Logic
   -----------------------------------------------------------------
	process (wclk)
	begin
		 if rising_edge(clk) then
			  wptr <= wptr XOR (wput AND (wq2_rptr XNOR wptr));
		 end if;
		 wrdy <= wq2_rptr XNOR wptr;
		 we <= wput AND (wptr XNOR wq2_rptr);
		 
	end process;

	if (wrdy='1') AND (rrdy='1') then
		--Lost on what I am supposed to do with the data, and we signals
	end if;

end rtl;