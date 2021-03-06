library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sync is
   port (
      clk_i    : in  std_logic;

      pix_x_o  : out std_logic_vector(9 downto 0);
      pix_y_o  : out std_logic_vector(9 downto 0);
      vga_hs_o : out std_logic;
      vga_vs_o : out std_logic
   );
end sync;

architecture Structural of sync is

   -- Define constants used for 640x480 @ 60 Hz.
   -- Requires a clock of 25.175 MHz.
   -- See page 17 in "VESA MONITOR TIMING STANDARD"
   -- http://caxapa.ru/thumbs/361638/DMTv1r11.pdf
   constant H_PIXELS : integer := 640;
   constant V_PIXELS : integer := 480;
   --
   constant H_TOTAL  : integer := 800;
   constant HS_START : integer := 656;
   constant HS_TIME  : integer := 96;
   --
   constant V_TOTAL  : integer := 525;
   constant VS_START : integer := 490;
   constant VS_TIME  : integer := 2;

   -- Pixel counters
   signal pix_x  : std_logic_vector(9 downto 0);
   signal pix_y  : std_logic_vector(9 downto 0);

   -- Synchronization
   signal vga_hs : std_logic;
   signal vga_vs : std_logic;

begin
   
   --------------------------------------------------
   -- Generate horizontal and vertical pixel counters
   --------------------------------------------------

   p_pix_x : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if pix_x = H_TOTAL-1 then
            pix_x <= (others => '0');
         else
            pix_x <= pix_x + 1;
         end if;
      end if;
   end process p_pix_x;

   p_pix_y : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if pix_x = H_TOTAL-1  then
            if pix_y = V_TOTAL-1 then
               pix_y <= (others => '0');
            else
               pix_y <= pix_y + 1;
            end if;
         end if;
      end if;
   end process p_pix_y;

   
   --------------------------------------------------
   -- Generate horizontal and vertical sync signals
   --------------------------------------------------

   p_vga_hs : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if pix_x >= HS_START and pix_x < HS_START+HS_TIME then
            vga_hs <= '0';
         else
            vga_hs <= '1';
         end if;
      end if;
   end process p_vga_hs;

   p_vga_vs : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if pix_y >= VS_START and pix_y < VS_START+VS_TIME then
            vga_vs <= '0';
         else
            vga_vs <= '1';
         end if;
      end if;
   end process p_vga_vs;

   
   --------------------------------------------------
   -- Drive output signals
   --------------------------------------------------

   vga_hs_o <= vga_hs;
   vga_vs_o <= vga_vs;
   pix_x_o  <= pix_x;
   pix_y_o  <= pix_y;

end architecture Structural;

