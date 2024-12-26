## Authorization System

module authorization_system (
    input clk,                // Saat sinyali
    input reset,              // Reset sinyali
    input [7:0] username,     // 8-bit kullanıcı adı
    input [7:0] password,     // 8-bit şifre
    output reg authorized     // Yetkilendirme sinyali (sequential olarak güncellendi)
);

    // Sabit kullanıcı adı ve şifre tanımları
    parameter [7:0] USERNAME = 8'h55;  // Kullanıcı adı: 0x55
    parameter [7:0] PASSWORD = 8'hAA;  // Şifre: 0xAA

    // Durum makinesi için durum tanımları
    typedef enum logic [1:0] {
        IDLE        = 2'b00,
        CHECK_USER  = 2'b01,
        CHECK_PASS  = 2'b10,
        AUTH_DONE   = 2'b11
    } state_t;

    state_t current_state, next_state;

    // Durum geçişleri
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Durumlara göre yetkilendirme işlemleri ve bir sonraki durumun belirlenmesi
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            authorized <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    authorized <= 1'b0;
                    next_state <= CHECK_USER;
                end

                CHECK_USER: begin
                    if (username == USERNAME) begin
                        next_state <= CHECK_PASS;
                    end else begin
                        next_state <= IDLE;
                    end
                end

                CHECK_PASS: begin
                    if (password == PASSWORD) begin
                        next_state <= AUTH_DONE;
                    end else begin
                        next_state <= IDLE;
                    end
                end

                AUTH_DONE: begin
                    authorized <= 1'b1;
                    next_state <= IDLE; // Döngüsel tekrar
                end

                default: begin
                    next_state <= IDLE;
                end
            endcase
        end
    end

endmodule


## General Management System

module general_management_system (
    input clk,                     // Saat sinyali
    input reset,                   // Reset sinyali
    input [7:0] user_id,           // 8-bit kullanıcı kimliği
    input [1:0] role,              // 2-bit rol (00: User, 01: Admin, 10: Supervisor)
    input [1:0] operation,         // 2-bit işlem türü (00: Read, 01: Write, 10: Delete)
    output reg access_granted,     // Erişim izni
    output reg operation_success   // İşlem başarısı
);

    // Önceden tanımlanmış sabitler
    parameter [7:0] VALID_USER_ID = 8'hA5; // Sabit kullanıcı kimliği
    parameter [1:0] READ = 2'b00;          // Okuma işlemi
    parameter [1:0] WRITE = 2'b01;         // Yazma işlemi
    parameter [1:0] DELETE = 2'b10;        // Silme işlemi

    // Durum makinesi için durum tanımları
    typedef enum logic [1:0] {
        IDLE        = 2'b00,
        CHECK_USER  = 2'b01,
        CHECK_ROLE  = 2'b10,
        DONE        = 2'b11
    } state_t;

    state_t current_state, next_state;

    // Durum geçişleri
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Durumlara göre işlemler ve bir sonraki durumun belirlenmesi
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            access_granted <= 1'b0;
            operation_success <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    access_granted <= 1'b0;
                    operation_success <= 1'b0;
                    next_state <= CHECK_USER;
                end

                CHECK_USER: begin
                    if (user_id == VALID_USER_ID) begin
                        access_granted <= 1'b1;
                        next_state <= CHECK_ROLE;
                    end else begin
                        access_granted <= 1'b0;
                        next_state <= IDLE;
                    end
                end

                CHECK_ROLE: begin
                    if (access_granted) begin
                        case (role)
                            2'b00: operation_success <= (operation == READ); // USER: Sadece okuma
                            2'b01: operation_success <= (operation == READ || operation == WRITE); // ADMIN: Okuma ve yazma
                            2'b10: operation_success <= 1'b1; // SUPERVISOR: Tüm işlemler
                            default: operation_success <= 1'b0;
                        endcase
                        next_state <= DONE;
                    end else begin
                        next_state <= IDLE;
                    end
                end

                DONE: begin
                    next_state <= IDLE; // Döngüsel tekrar için
                end

                default: begin
                    next_state <= IDLE;
                end
            endcase
        end
    end

endmodule


## Smart Lighting System

module smart_lighting_system (
    input clk,                     // Saat sinyali
    input reset,                   // Reset sinyali
    input light_sensor,            // Ortam ışık sensörü (1: karanlık, 0: aydınlık)
    input motion_sensor,           // Hareket sensörü (1: hareket var, 0: hareket yok)
    input manual_switch,           // Manuel açma-kapama düğmesi (1: açık, 0: kapalı)
    input [3:0] hour,              // Saat bilgisi (0-23 arası)
    output reg light               // Işık durumu (1: açık, 0: kapalı)
);

    // Belirli saatler için zamanlayıcı sınırları
    parameter NIGHT_START = 4'd18; // Akşam 18:00
    parameter NIGHT_END = 4'd6;    // Sabah 6:00

    // Durum makinesi için durum tanımları
    typedef enum logic [1:0] {
        IDLE        = 2'b00,
        CHECK_LIGHT = 2'b01,
        CHECK_MOTION = 2'b10,
        DONE        = 2'b11
    } state_t;

    state_t current_state, next_state;

    // Durum geçişleri
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Durumlara göre işlemler ve bir sonraki durumun belirlenmesi
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            light <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    light <= 1'b0;
                    next_state <= CHECK_LIGHT;
                end

                CHECK_LIGHT: begin
                    if (manual_switch) begin
                        light <= 1'b1;
                        next_state <= DONE;
                    end else if (light_sensor) begin
                        next_state <= CHECK_MOTION;
                    end else begin
                        next_state <= IDLE;
                    end
                end

                CHECK_MOTION: begin
                    if (motion_sensor || (hour >= NIGHT_START || hour < NIGHT_END)) begin
                        light <= 1'b1;
                    end else begin
                        light <= 1'b0;
                    end
                    next_state <= DONE;
                end

                DONE: begin
                    next_state <= IDLE; // Döngüsel tekrar için
                end

                default: begin
                    next_state <= IDLE;
                end
            endcase
        end
    end

endmodule


## White Goods Control

module white_goods_control (
    input clk,                     // Saat sinyali
    input reset,                   // Reset sinyali
    input manual_laundry,          // Çamaşır makinesi manuel açma (1: açık, 0: kapalı)
    input manual_dishwasher,       // Bulaşık makinesi manuel açma (1: açık, 0: kapalı)
    input manual_oven,             // Fırın manuel açma (1: açık, 0: kapalı)
    input [3:0] hour,              // Günün saat bilgisi (0-23)
    output reg laundry_on,         // Çamaşır makinesi durumu
    output reg dishwasher_on,      // Bulaşık makinesi durumu
    output reg oven_on             // Fırın durumu
);

    // Otomatik başlatma saatleri
    parameter LAUNDRY_AUTO_START = 4'd7;     // Çamaşır makinesi için otomatik başlatma saati (7:00)
    parameter DISHWASHER_AUTO_START = 4'd22; // Bulaşık makinesi için otomatik başlatma saati (22:00)
    parameter OVEN_AUTO_START = 4'd18;       // Fırın için otomatik başlatma saati (18:00)

    // Durum makinesi için durum tanımları
    typedef enum logic [1:0] {
        IDLE         = 2'b00,
        CHECK_LAUNDRY = 2'b01,
        CHECK_DISHWASHER = 2'b10,
        CHECK_OVEN   = 2'b11
    } state_t;

    state_t current_state, next_state;

    // Durum geçişleri
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Durumlara göre işlemler ve bir sonraki durumun belirlenmesi
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            laundry_on <= 1'b0;
            dishwasher_on <= 1'b0;
            oven_on <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    laundry_on <= 1'b0;
                    dishwasher_on <= 1'b0;
                    oven_on <= 1'b0;
                    next_state <= CHECK_LAUNDRY;
                end

                CHECK_LAUNDRY: begin
                    if (manual_laundry || (hour == LAUNDRY_AUTO_START)) begin
                        laundry_on <= 1'b1;
                    end
                    next_state <= CHECK_DISHWASHER;
                end

                CHECK_DISHWASHER: begin
                    if (manual_dishwasher || (hour == DISHWASHER_AUTO_START)) begin
                        dishwasher_on <= 1'b1;
                    end
                    next_state <= CHECK_OVEN;
                end

                CHECK_OVEN: begin
                    if (manual_oven || (hour == OVEN_AUTO_START)) begin
                        oven_on <= 1'b1;
                    end
                    next_state <= IDLE; // Döngüsel tekrar için
                end

                default: begin
                    next_state <= IDLE;
                end
            endcase
        end
    end

endmodule


## Smart Home Control

module smart_home_control (
    input clk,                     // Saat sinyali
    input reset,                   // Reset sinyali
    input sunlight_sensor,         // Güneş ışığı sensörü (1: güneş var, 0: güneş yok)
    input temp_sensor,             // Sıcaklık sensörü (1: sıcak, 0: soğuk)
    input air_quality_sensor,      // Hava kalitesi sensörü (1: iyi, 0: kötü)
    input manual_curtain,          // Perde manuel açma-kapama (1: açık, 0: kapalı)
    input manual_window,           // Pencere manuel açma-kapama (1: açık, 0: kapalı)
    input manual_door_lock,        // Kapı manuel kilitleme (1: kilitle, 0: aç)
    output reg curtain_open,       // Perde durumu (1: açık, 0: kapalı)
    output reg window_open,        // Pencere durumu (1: açık, 0: kapalı)
    output reg door_locked         // Kapı durumu (1: kilitli, 0: açık)
);

    // Durum makinesi için durum tanımları
    typedef enum logic [1:0] {
        IDLE          = 2'b00,
        CHECK_CURTAIN = 2'b01,
        CHECK_WINDOW  = 2'b10,
        CHECK_DOOR    = 2'b11
    } state_t;

    state_t current_state, next_state;

    // Durum geçişleri
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Durumlara göre işlemler ve bir sonraki durumun belirlenmesi
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            curtain_open <= 1'b0;
            window_open <= 1'b0;
            door_locked <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    curtain_open <= 1'b0;
                    window_open <= 1'b0;
                    door_locked <= 1'b0;
                    next_state <= CHECK_CURTAIN;
                end

                CHECK_CURTAIN: begin
                    if (manual_curtain) begin
                        curtain_open <= 1'b1;
                    end else if (!sunlight_sensor) begin
                        curtain_open <= 1'b1; // Güneş yok, perdeyi aç
                    end else begin
                        curtain_open <= 1'b0; // Güneş var, perdeyi kapat
                    end
                    next_state <= CHECK_WINDOW;
                end

                CHECK_WINDOW: begin
                    if (manual_window) begin
                        window_open <= 1'b1;
                    end else if (temp_sensor && air_quality_sensor) begin
                        window_open <= 1'b1; // Sıcak ve hava iyi, pencereyi aç
                    end else begin
                        window_open <= 1'b0; // Diğer durumlarda pencereyi kapat
                    end
                    next_state <= CHECK_DOOR;
                end

                CHECK_DOOR: begin
                    if (manual_door_lock) begin
                        door_locked <= 1'b1; // Kapıyı kilitle
                    end else begin
                        door_locked <= 1'b0; // Kapıyı aç
                    end
                    next_state <= IDLE; // Döngüsel tekrar için
                end

                default: begin
                    next_state <= IDLE;
                end
            endcase
        end
    end

endmodule


## Climate Control System

module climate_control_system (
    input clk,                     // Saat sinyali
    input reset,                   // Reset sinyali
    input [7:0] temp,              // Sıcaklık değeri (8-bit, örneğin 0-255 arasında)
    input [7:0] humidity,          // Nem değeri (8-bit, örneğin 0-255 arasında)
    input manual_heater,           // Manuel ısıtıcı kontrolü (1: açık, 0: kapalı)
    input manual_ac,               // Manuel klima kontrolü (1: açık, 0: kapalı)
    input manual_humidifier,       // Manuel nemlendirici kontrolü (1: açık, 0: kapalı)
    input manual_dehumidifier,     // Manuel nem giderici kontrolü (1: açık, 0: kapalı)
    output reg heater_on,          // Isıtıcı durumu (1: açık, 0: kapalı)
    output reg ac_on,              // Klima durumu (1: açık, 0: kapalı)
    output reg humidifier_on,      // Nemlendirici durumu (1: açık, 0: kapalı)
    output reg dehumidifier_on     // Nem giderici durumu (1: açık, 0: kapalı)
);

    // Sıcaklık ve nem için ideal aralıklar
    parameter [7:0] TEMP_LOW_THRESHOLD = 8'd18;      // Minimum sıcaklık (örn: 18°C)
    parameter [7:0] TEMP_HIGH_THRESHOLD = 8'd26;     // Maksimum sıcaklık (örn: 26°C)
    parameter [7:0] HUMIDITY_LOW_THRESHOLD = 8'd30;  // Minimum nem (%30)
    parameter [7:0] HUMIDITY_HIGH_THRESHOLD = 8'd70; // Maksimum nem (%70)

    // Durum makinesi için durum tanımları
    typedef enum logic [2:0] {
        IDLE               = 3'b000,
        CHECK_HEATER       = 3'b001,
        CHECK_AC           = 3'b010,
        CHECK_HUMIDIFIER   = 3'b011,
        CHECK_DEHUMIDIFIER = 3'b100
    } state_t;

    state_t current_state, next_state;

    // Durum geçişleri
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Durumlara göre işlemler ve bir sonraki durumun belirlenmesi
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            heater_on <= 1'b0;
            ac_on <= 1'b0;
            humidifier_on <= 1'b0;
            dehumidifier_on <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    heater_on <= 1'b0;
                    ac_on <= 1'b0;
                    humidifier_on <= 1'b0;
                    dehumidifier_on <= 1'b0;
                    next_state <= CHECK_HEATER;
                end

                CHECK_HEATER: begin
                    if (manual_heater || (temp < TEMP_LOW_THRESHOLD)) begin
                        heater_on <= 1'b1;
                    end else begin
                        heater_on <= 1'b0;
                    end
                    next_state <= CHECK_AC;
                end

                CHECK_AC: begin
                    if (manual_ac || (temp > TEMP_HIGH_THRESHOLD)) begin
                        ac_on <= 1'b1;
                    end else begin
                        ac_on <= 1'b0;
                    end
                    next_state <= CHECK_HUMIDIFIER;
                end

                CHECK_HUMIDIFIER: begin
                    if (manual_humidifier || (humidity < HUMIDITY_LOW_THRESHOLD)) begin
                        humidifier_on <= 1'b1;
                    end else begin
                        humidifier_on <= 1'b0;
                    end
                    next_state <= CHECK_DEHUMIDIFIER;
                end

                CHECK_DEHUMIDIFIER: begin
                    if (manual_dehumidifier || (humidity > HUMIDITY_HIGH_THRESHOLD)) begin
                        dehumidifier_on <= 1'b1;
                    end else begin
                        dehumidifier_on <= 1'b0;
                    end
                    next_state <= IDLE; // Döngüsel tekrar için
                end

                default: begin
                    next_state <= IDLE;
                end
            endcase
        end
    end

endmodule


## AC Control System

module ac_control (
    input clk,                     // Saat sinyali
    input reset,                   // Reset sinyali
    input [7:0] temp,              // Sıcaklık değeri (8-bit, örneğin 0-255 arasında)
    input [7:0] target_temp_low,   // Hedef sıcaklık alt sınırı
    input [7:0] target_temp_high,  // Hedef sıcaklık üst sınırı
    input manual_ac,               // Manuel klima kontrolü (1: açık, 0: kapalı)
    output reg ac_on               // Klima durumu (1: açık, 0: kapalı)
);

    // Durum makinesi için durum tanımları
    typedef enum logic [1:0] {
        IDLE          = 2'b00,
        CHECK_TEMP    = 2'b01,
        DONE          = 2'b10
    } state_t;

    state_t current_state, next_state;

    // Durum geçişleri
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Durumlara göre işlemler ve bir sonraki durumun belirlenmesi
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ac_on <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    ac_on <= 1'b0;
                    next_state <= CHECK_TEMP;
                end

                CHECK_TEMP: begin
                    if (manual_ac || (temp > target_temp_high)) begin
                        ac_on <= 1'b1;
                    end else begin
                        ac_on <= 1'b0;
                    end
                    next_state <= DONE;
                end

                DONE: begin
                    next_state <= IDLE; // Döngüsel tekrar için
                end

                default: begin
                    next_state <= IDLE;
                end
            endcase
        end
    end

endmodule


## Heating System Control

module heating_system_control (
    input clk,                     // Saat sinyali
    input reset,                   // Reset sinyali
    input [7:0] temp,              // Mevcut sıcaklık (8-bit)
    input [7:0] target_temp_low,   // Hedef sıcaklık alt sınırı
    input [7:0] target_temp_high,  // Hedef sıcaklık üst sınırı
    input manual_heater,           // Manuel ısıtıcı kontrolü (1: aç, 0: kapat)
    output reg heater_on           // Isıtıcı durumu (1: açık, 0: kapalı)
);

    // Durum makinesi için durum tanımları
    typedef enum logic [1:0] {
        IDLE          = 2'b00,
        CHECK_TEMP    = 2'b01,
        DONE          = 2'b10
    } state_t;

    state_t current_state, next_state;

    // Durum geçişleri
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Durumlara göre işlemler ve bir sonraki durumun belirlenmesi
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            heater_on <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    heater_on <= 1'b0;
                    next_state <= CHECK_TEMP;
                end

                CHECK_TEMP: begin
                    if (manual_heater || (temp < target_temp_low)) begin
                        heater_on <= 1'b1;
                    end else begin
                        heater_on <= 1'b0;
                    end
                    next_state <= DONE;
                end

                DONE: begin
                    next_state <= IDLE; // Döngüsel tekrar için
                end

                default: begin
                    next_state <= IDLE;
                end
            endcase
        end
    end

endmodule


## Safety System

module SafetySystem (
    input clk,                     // Saat sinyali
    input reset,                   // Reset sinyali
    input wire motion_sensor,      // Hareket algılayıcı sinyali (1: hareket var, 0: hareket yok)
    input wire arm_system,         // Güvenlik sistemi aktiflik sinyali (1: aktif, 0: pasif)
    output reg alarm               // Alarm sinyali (1: alarm çalıyor, 0: alarm kapalı)
);

    // Durum makinesi için durum tanımları
    typedef enum logic [1:0] {
        IDLE         = 2'b00,
        CHECK_ALARM  = 2'b01,
        DONE         = 2'b10
    } state_t;

    state_t current_state, next_state;

    // Durum geçişleri
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Durumlara göre işlemler ve bir sonraki durumun belirlenmesi
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alarm <= 1'b0;
        end else begin
            case (current_state)
                IDLE: begin
                    alarm <= 1'b0;
                    next_state <= CHECK_ALARM;
                end

                CHECK_ALARM: begin
                    if (arm_system && motion_sensor) begin
                        alarm <= 1'b1;
                    end else begin
                        alarm <= 1'b0;
                    end
                    next_state <= DONE;
                end

                DONE: begin
                    next_state <= IDLE; // Döngüsel tekrar için
                end

                default: begin
                    next_state <= IDLE;
                end
            endcase
        end
    end

endmodule



