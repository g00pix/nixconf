{
  wayland.windowManager.sway.config = {
    input = {
      "1267:12809:ELAN067F:00_04F3:3209_Touchpad" = {
        natural_scroll = "enabled";
        tap = "enabled";
      };
    };
    output = {
      eDP-1 = {
        scale = "1.25";
      };
    };
  };

  services.kanshi.profiles = {
    normal = {
      outputs = [
        {
          criteria = "eDP-1";
          status = "enable";
        }
      ];
    };
    dockedHome = {
      outputs = [
        {
          criteria = "eDP-1";
          status = "disable";
        }
        {
          criteria = "BNQ BenQ XL2411Z 6AF01007SL0";
          position = "1080,470";
        }
        {
          criteria = "BNQ BenQ GW2480 ETV5L03568SL0";
          position = "0,0";
          transform = "90";
        }
      ];
    };
  };
}
