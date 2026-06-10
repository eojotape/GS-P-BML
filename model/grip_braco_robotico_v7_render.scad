/*
    GRIP / GARRA FUNCIONAL - Braço Robótico Docking & Retrieval
    Versão V7: mecanismo coerente + render seguro no OpenSCAD 2021.01

    O que mudou em relação à versão anterior:
      - Removidos os elos fixos que travavam a garra.
      - Abertura/fechamento por mecanismo real: servo -> crank/horn excêntrico -> biela -> yoke deslizante -> dois elos -> dois dedos.
      - O yoke corre entre trilhos impressos na base, evitando um mecanismo impossível/hipertravado.
      - Furos com folga realista para M3 em pivôs e M2 no horn do servo.
      - Base com padrão aproximado de montagem para micro servo tipo SG90/MG90S.
      - Dedos refeitos sem offset(), evitando mesh aberto nas pontas/serrilhas.

    Use:
      layout = "side_by_side";   // peças separadas à esquerda + montagem à direita
      layout = "print_only";     // somente peças separadas para STL
      layout = "assembly_only";  // somente montagem

    Observações práticas:
      - Para renderizar em F6/exportar STL, mantenha show_labels=false.
      - Textos 3D com acentos podem gerar mesh não fechado no OpenSCAD 2021.01.
      - Para montagem real, use parafusos M3 + porcas travantes + arruelas nos pivôs principais.
      - Use parafusos M2 no horn do servo.
      - Pinos impressos são opcionais/visuais; em FDM real, parafuso metálico é muito melhor.
      - O modelo é paramétrico. Ajuste finger_length, grip_angle, base_length, etc.
*/

// =========================
// CONFIGURAÇÃO PRINCIPAL
// =========================

layout = "side_by_side";       // "side_by_side", "print_only", "assembly_only"
show_labels = false;           // true só para preview/F5; false é seguro para render/F6
show_printed_pins = true;      // inclui pinos impressos no layout separado
show_servo_reference = true;   // mostra um servo fantasma na montagem, não é peça impressa

$fn = 56;
eps = 0.03;

// =========================
// PARÂMETROS GERAIS
// =========================

// Base
base_length      = 100;
base_width       = 48;
base_thickness   = 4;
base_radius      = 3;

// Furação realista
m3_clearance_d   = 3.35;       // folga FDM para M3
m2_clearance_d   = 2.25;       // folga FDM para M2
pivot_pin_d      = 3.0;
washer_outer_d   = 8.0;
washer_height    = 0.8;
pin_head_d       = 7.0;
pin_head_h       = 1.2;
vertical_gap     = 0.7;

// Dedo / mandíbula
finger_length       = 48;
finger_thickness    = 6;
finger_root_height  = 13;
finger_mid_height   = 10;
finger_tip_height   = 5.8;
finger_tip_nose     = 2.0;
finger_rounding     = 0.65;
finger_root_boss_d  = 13;
finger_link_boss_d  = 9.5;
finger_link_hole_x  = 14.5;

serration_count = 9;
serration_pitch = 3.1;
serration_depth = 2.0;
serration_start = 18;

// Mecanismo da garra
// 0 = mais aberta; 7 a 10 = fechada/pegando amostra pequena.
grip_angle = 8;
reference_grip_angle = 8;
reference_slider_x = -2;

p_jaw_top    = [16,  11];
p_jaw_bottom = [16, -11];

// Yoke deslizante central
slider_width          = 22;
slider_length         = 24;
slider_thickness      = 5.2;
slider_rounding       = 2;
slider_output_y       = 7.5;
slider_crank_backset  = 8;
slider_clearance      = 0.45;

// Trilhos do yoke
rail_length = 34;
rail_width  = 3.0;
rail_height = 2.4;
rail_x      = 0;

// Elos/bielas
link_width      = 7.6;
link_thickness  = 3.0;

// Servo/crank
p_servo = [-32, 0];
servo_crank_radius = 10;
servo_crank_angle  = 0;        // pose fechada/central
servo_horn_width   = 6.0;
servo_horn_thick   = 2.4;
servo_hub_d        = 12;

// Montagem aproximada SG90/MG90S
servo_body_length = 23.5;
servo_body_width  = 12.5;
servo_frame_wall  = 2.2;
servo_frame_h     = 3.0;
servo_screw_spacing = 27.5;
servo_shaft_clearance_d = 6.2;

// Alturas de montagem
z_jaw        = base_thickness + vertical_gap;
z_slider     = base_thickness + vertical_gap;
z_horn       = base_thickness + vertical_gap;
z_crank_link = z_horn + servo_horn_thick + vertical_gap;
z_jaw_link   = z_jaw + finger_thickness + vertical_gap;

// Cores apenas para visualização
part_grey      = [0.45, 0.45, 0.45, 1];
dark_grey      = [0.16, 0.16, 0.16, 1];
link_grey      = [0.36, 0.36, 0.36, 1];
print_orange   = [0.75, 0.42, 0.15, 1];
servo_blue     = [0.10, 0.18, 0.45, 0.32];

// =========================
// FUNÇÕES
// =========================

function dist2d(a, b) = sqrt(pow(b[0]-a[0], 2) + pow(b[1]-a[1], 2));
function angle2d(a, b) = atan2(b[1]-a[1], b[0]-a[0]);
function rot2d(v, a) = [v[0]*cos(a) - v[1]*sin(a), v[0]*sin(a) + v[1]*cos(a)];
function add2(a, b) = [a[0]+b[0], a[1]+b[1]];

function jaw_top_drive_at(a) = add2(p_jaw_top, rot2d([finger_link_hole_x, 0], -a));
function jaw_bottom_drive_at(a) = add2(p_jaw_bottom, rot2d([finger_link_hole_x, 0], a));

p_top_ref = jaw_top_drive_at(reference_grip_angle);
jaw_link_len = dist2d([reference_slider_x, slider_output_y], p_top_ref);

p_top_drive = jaw_top_drive_at(grip_angle);
p_bottom_drive = jaw_bottom_drive_at(grip_angle);

slider_dx = sqrt(max(0.01, pow(jaw_link_len, 2) - pow(p_top_drive[1] - slider_output_y, 2)));
p_slider_center = [p_top_drive[0] - slider_dx, 0];
p_slider_top    = add2(p_slider_center, [0,  slider_output_y]);
p_slider_bottom = add2(p_slider_center, [0, -slider_output_y]);
p_slider_crank  = add2(p_slider_center, [-slider_crank_backset, 0]);

p_crank_pin = add2(p_servo, rot2d([servo_crank_radius, 0], servo_crank_angle));
crank_link_len = dist2d(p_crank_pin, p_slider_crank);

// =========================
// HELPERS DE GEOMETRIA
// =========================

module rounded_rect_2d(size=[10,10], r=1) {
    hull() {
        for (x = [-size[0]/2 + r, size[0]/2 - r])
            for (y = [-size[1]/2 + r, size[1]/2 - r])
                translate([x, y]) circle(r=r);
    }
}

module rounded_box(size=[10,10,5], r=1) {
    linear_extrude(height=size[2])
        rounded_rect_2d([size[0], size[1]], r);
}

module hole_z(pos=[0,0], d=3, h=10, z=-eps) {
    translate([pos[0], pos[1], z])
        cylinder(h=h, d=d);
}

module label_text(txt, size=4) {
    if (show_labels)
        color([0.08, 0.08, 0.08, 1])
            linear_extrude(height=0.35)
                text(txt, size=size, halign="center", valign="center", font="Liberation Sans");
}

// =========================
// BASE + TRILHOS + MONTAGEM DO SERVO
// =========================

module base_plate_solid() {
    rounded_box([base_length, base_width, base_thickness], base_radius);
}

module jaw_pivot_bosses() {
    for (p = [p_jaw_top, p_jaw_bottom])
        translate([p[0], p[1], base_thickness])
            cylinder(h=1.4, d=12);
}

module slider_rails() {
    rail_gap = slider_width + 2*slider_clearance;

    // Trilhos laterais: deixam o yoke deslizar no eixo X.
    for (y = [rail_gap/2 + rail_width/2, -rail_gap/2 - rail_width/2])
        translate([rail_x, y, base_thickness])
            rounded_box([rail_length, rail_width, rail_height], 0.8);

    // Batentes simples para o yoke não sair pelo curso.
    for (x = [rail_x - rail_length/2, rail_x + rail_length/2])
        translate([x, 0, base_thickness])
            rounded_box([2.8, rail_gap + 2*rail_width, rail_height], 0.7);
}

module servo_mount_frame() {
    // Moldura baixa para posicionar um micro servo tipo SG90/MG90S sob/sobre a placa.
    frame_l = servo_body_length + 2*servo_frame_wall;
    frame_w = servo_body_width  + 2*servo_frame_wall;

    translate([p_servo[0], p_servo[1], base_thickness]) {
        // laterais da cavidade
        for (y = [frame_w/2 - servo_frame_wall/2, -frame_w/2 + servo_frame_wall/2])
            translate([0, y, 0])
                rounded_box([frame_l, servo_frame_wall, servo_frame_h], 0.6);

        // paredes frontal/traseira
        for (x = [frame_l/2 - servo_frame_wall/2, -frame_l/2 + servo_frame_wall/2])
            translate([x, 0, 0])
                rounded_box([servo_frame_wall, frame_w, servo_frame_h], 0.6);
    }
}

module base_structural_raw() {
    union() {
        base_plate_solid();
        jaw_pivot_bosses();
        slider_rails();
        servo_mount_frame();
    }
}

module base_servo_frame() {
    color(part_grey)
    difference() {
        base_structural_raw();

        // Furos de fixação da base na bancada/elo maior do braço.
        for (x = [-base_length/2 + 8, base_length/2 - 8])
            for (y = [-base_width/2 + 7, base_width/2 - 7])
                hole_z([x, y], m3_clearance_d, base_thickness + 5);

        // Pivôs principais dos dedos.
        hole_z(p_jaw_top,    m3_clearance_d, base_thickness + rail_height + 4);
        hole_z(p_jaw_bottom, m3_clearance_d, base_thickness + rail_height + 4);

        // Saída do eixo do servo e parafusos de fixação do servo.
        hole_z(p_servo, servo_shaft_clearance_d, base_thickness + servo_frame_h + 2);

        for (x = [-servo_screw_spacing/2, servo_screw_spacing/2])
            hole_z(add2(p_servo, [x, 0]), m2_clearance_d, base_thickness + servo_frame_h + 2);
    }
}

// Servo só como referência visual, não como peça imprimível.
module servo_reference() {
    if (show_servo_reference)
        color(servo_blue)
            translate([p_servo[0], p_servo[1], -18])
                rounded_box([servo_body_length, servo_body_width, 18], 1.2);
}

// =========================
// DEDOS / GARRA TIPO ALICATE
// =========================

module finger_profile_2d() {
    // Perfil refeito sem offset() para evitar malha aberta no CGAL/F6.
    // O offset em pontas agudas + serrilhas pode gerar contornos 2D inválidos
    // no OpenSCAD 2021.01. Este polígono simples é bem mais robusto.
    difference() {
        polygon(points=[
            [-4.0, -finger_root_height/2 + 0.6],
            [-3.0,  finger_root_height/2 - 0.6],
            [ 7.0,  finger_root_height/2],
            [18.0,  finger_mid_height/2 + 0.8],
            [32.0,  finger_mid_height/2 - 0.1],
            [finger_length - 5.0,  finger_tip_height/2 + 0.5],
            [finger_length + finger_tip_nose,  1.0],
            [finger_length + finger_tip_nose, -1.0],
            [finger_length - 5.0,             -finger_tip_height/2 - 0.5],
            [32.0,                            -finger_mid_height/2 + 0.1],
            [18.0,                            -finger_mid_height/2 - 0.8],
            [ 7.0,                            -finger_root_height/2]
        ], paths=[[0,1,2,3,4,5,6,7,8,9,10,11]]);

        // Serrilhas cortando de fora para dentro, sem coincidir exatamente
        // com a borda. Isso evita arestas coplanares problemáticas.
        for (i = [0:serration_count-1]) {
            x0 = serration_start + i * serration_pitch;
            polygon(points=[
                [x0,                     -finger_mid_height/2 - serration_depth - 1.0],
                [x0 + serration_pitch/2, -finger_mid_height/2 + 0.85],
                [x0 + serration_pitch,   -finger_mid_height/2 - serration_depth - 1.0]
            ]);
        }
    }
}

module finger_raw() {
    difference() {
        union() {
            linear_extrude(height=finger_thickness)
                finger_profile_2d();

            translate([0, 0, 0])
                cylinder(h=finger_thickness, d=finger_root_boss_d);

            translate([finger_link_hole_x, 0, 0])
                cylinder(h=finger_thickness, d=finger_link_boss_d);
        }

        translate([0, 0, -eps])
            cylinder(h=finger_thickness + 2*eps, d=m3_clearance_d);

        translate([finger_link_hole_x, 0, -eps])
            cylinder(h=finger_thickness + 2*eps, d=m3_clearance_d);
    }
}

module finger_top() {
    color(print_orange)
        finger_raw();
}

module finger_bottom() {
    color(print_orange)
        mirror([0,1,0]) finger_raw();
}

// =========================
// YOKE DESLIZANTE
// =========================

module slider_yoke() {
    color(dark_grey)
    difference() {
        linear_extrude(height=slider_thickness)
            rounded_rect_2d([slider_length, slider_width], slider_rounding);

        // Furos para os dois elos das mandíbulas.
        for (y = [slider_output_y, -slider_output_y])
            translate([0, y, -eps])
                cylinder(h=slider_thickness + 2*eps, d=m3_clearance_d);

        // Furo de entrada da biela do servo.
        translate([-slider_crank_backset, 0, -eps])
            cylinder(h=slider_thickness + 2*eps, d=m3_clearance_d);
    }
}

// =========================
// ELOS / BIELAS
// =========================

module straight_link(L=25, width=7, thick=3, hole_d=3.35) {
    difference() {
        linear_extrude(height=thick)
            hull() {
                translate([0, 0]) circle(d=width);
                translate([L, 0]) circle(d=width);
            }

        translate([0, 0, -eps])
            cylinder(h=thick + 2*eps, d=hole_d);

        translate([L, 0, -eps])
            cylinder(h=thick + 2*eps, d=hole_d);
    }
}

module straight_link_asym(L=25, width=7, thick=3, hole_1_d=2.25, hole_2_d=3.35) {
    difference() {
        linear_extrude(height=thick)
            hull() {
                translate([0, 0]) circle(d=width);
                translate([L, 0]) circle(d=width);
            }

        translate([0, 0, -eps])
            cylinder(h=thick + 2*eps, d=hole_1_d);

        translate([L, 0, -eps])
            cylinder(h=thick + 2*eps, d=hole_2_d);
    }
}

module link_between(p1, p2, z=0, col=link_grey, width=link_width, thick=link_thickness, hole_d=m3_clearance_d) {
    L = dist2d(p1, p2);
    A = angle2d(p1, p2);

    color(col)
        translate([p1[0], p1[1], z])
            rotate([0,0,A])
                straight_link(L, width, thick, hole_d);
}

module link_between_asym(p1, p2, z=0, col=link_grey, width=link_width, thick=link_thickness, hole_1_d=m2_clearance_d, hole_2_d=m3_clearance_d) {
    L = dist2d(p1, p2);
    A = angle2d(p1, p2);

    color(col)
        translate([p1[0], p1[1], z])
            rotate([0,0,A])
                straight_link_asym(L, width, thick, hole_1_d, hole_2_d);
}

// =========================
// SERVO HORN / CRANK EXCÊNTRICO
// =========================

module servo_crank_horn() {
    difference() {
        linear_extrude(height=servo_horn_thick)
            union() {
                circle(d=servo_hub_d);
                hull() {
                    circle(d=servo_horn_width);
                    translate([servo_crank_radius + 4, 0])
                        circle(d=servo_horn_width);
                }
            }

        translate([0,0,-eps])
            cylinder(h=servo_horn_thick + 2*eps, d=m2_clearance_d);

        translate([servo_crank_radius,0,-eps])
            cylinder(h=servo_horn_thick + 2*eps, d=m2_clearance_d);

        // Furo auxiliar para ajuste fino de curso.
        translate([servo_crank_radius - 4,0,-eps])
            cylinder(h=servo_horn_thick + 2*eps, d=m2_clearance_d);
    }
}

// =========================
// PINOS, ESPAÇADORES E ARRUELAS
// =========================

module washer() {
    difference() {
        cylinder(h=washer_height, d=washer_outer_d);
        translate([0,0,-eps])
            cylinder(h=washer_height + 2*eps, d=m3_clearance_d);
    }
}

module washer_m2() {
    difference() {
        cylinder(h=washer_height, d=6.0);
        translate([0,0,-eps])
            cylinder(h=washer_height + 2*eps, d=m2_clearance_d);
    }
}

module spacer(h=5.5) {
    difference() {
        cylinder(h=h, d=washer_outer_d * 0.82);
        translate([0,0,-eps])
            cylinder(h=h + 2*eps, d=m3_clearance_d);
    }
}

module printed_pin(h=18) {
    union() {
        cylinder(h=h, d=pivot_pin_d);
        translate([0,0,h])
            cylinder(h=pin_head_h, d=pin_head_d);
    }
}

module printed_pin_m2(h=12) {
    union() {
        cylinder(h=h, d=2.0);
        translate([0,0,h])
            cylinder(h=1.0, d=5.0);
    }
}

module assembly_pin_at(p=[0,0], z=base_thickness, h=18) {
    color(dark_grey)
        translate([p[0], p[1], z])
            printed_pin(h);
}

module assembly_pin_at_m2(p=[0,0], z=base_thickness, h=12) {
    color(dark_grey)
        translate([p[0], p[1], z])
            printed_pin_m2(h);
}

module assembly_washer_at(p=[0,0], z=0) {
    color(dark_grey)
        translate([p[0], p[1], z])
            washer();
}

module assembly_washer_at_m2(p=[0,0], z=0) {
    color(dark_grey)
        translate([p[0], p[1], z])
            washer_m2();
}

// =========================
// MODELO MONTADO
// =========================

module assembly_model() {
    servo_reference();
    base_servo_frame();

    // Horn do servo: ponto excêntrico real, não no centro.
    color(dark_grey)
        translate([p_servo[0], p_servo[1], z_horn])
            rotate([0,0,servo_crank_angle])
                servo_crank_horn();

    // Yoke que desliza entre os trilhos.
    translate([p_slider_center[0], p_slider_center[1], z_slider])
        slider_yoke();

    // Dedos rotacionados ao redor dos pivôs reais.
    translate([p_jaw_top[0], p_jaw_top[1], z_jaw])
        rotate([0,0,-grip_angle])
            finger_top();

    translate([p_jaw_bottom[0], p_jaw_bottom[1], z_jaw])
        rotate([0,0,grip_angle])
            finger_bottom();

    // Biela do servo para o yoke.
    // Biela com furo M2 no horn e M3 no yoke.
    link_between_asym(p_crank_pin, p_slider_crank, z_crank_link, dark_grey, link_width, link_thickness, m2_clearance_d, m3_clearance_d);

    // Dois elos simétricos: yoke -> mandíbula superior/inferior.
    link_between(p_slider_top,    p_top_drive,    z_jaw_link, link_grey, link_width, link_thickness, m3_clearance_d);
    link_between(p_slider_bottom, p_bottom_drive, z_jaw_link, link_grey, link_width, link_thickness, m3_clearance_d);

    // Arruelas visuais entre camadas móveis.
    assembly_washer_at(p_jaw_top,       z_jaw - washer_height - 0.05);
    assembly_washer_at(p_jaw_bottom,    z_jaw - washer_height - 0.05);
    assembly_washer_at(p_top_drive,     z_jaw_link - washer_height - 0.05);
    assembly_washer_at(p_bottom_drive,  z_jaw_link - washer_height - 0.05);
    assembly_washer_at(p_slider_top,    z_jaw_link - washer_height - 0.05);
    assembly_washer_at(p_slider_bottom, z_jaw_link - washer_height - 0.05);
    assembly_washer_at(p_slider_crank,  z_crank_link - washer_height - 0.05);
    assembly_washer_at_m2(p_crank_pin,  z_crank_link - washer_height - 0.05);

    if (show_printed_pins) {
        // Pinos são visuais. Em montagem real, substitua por parafuso M3/M2.
        assembly_pin_at(p_jaw_top,       base_thickness, z_jaw_link + link_thickness - base_thickness + 2.0);
        assembly_pin_at(p_jaw_bottom,    base_thickness, z_jaw_link + link_thickness - base_thickness + 2.0);
        assembly_pin_at(p_top_drive,     z_jaw,          z_jaw_link + link_thickness - z_jaw + 1.5);
        assembly_pin_at(p_bottom_drive,  z_jaw,          z_jaw_link + link_thickness - z_jaw + 1.5);
        assembly_pin_at(p_slider_top,    z_slider,       z_jaw_link + link_thickness - z_slider + 1.5);
        assembly_pin_at(p_slider_bottom, z_slider,       z_jaw_link + link_thickness - z_slider + 1.5);
        assembly_pin_at(p_slider_crank,  z_slider,       z_crank_link + link_thickness - z_slider + 1.5);
        assembly_pin_at_m2(p_crank_pin,  z_horn,         z_crank_link + link_thickness - z_horn + 1.5);
    }
}

// =========================
// LAYOUT DE PEÇAS SEPARADAS
// =========================

module print_layout(include_labels=false) {
    // Base estrutural única: placa + trilhos + moldura do servo.
    translate([-30, 0, 0])
        base_servo_frame();

    // Dedos separados, espelhados e afastados.
    translate([-92, 72, 0])
        finger_top();

    translate([-92, 100, 0])
        finger_bottom();

    // Yoke deslizante.
    translate([58, 72, 0])
        slider_yoke();

    // Dois elos iguais do yoke para os dedos.
    color(link_grey) {
        translate([12, 108, 0])
            straight_link(jaw_link_len, link_width, link_thickness, m3_clearance_d);

        translate([12, 124, 0])
            straight_link(jaw_link_len, link_width, link_thickness, m3_clearance_d);
    }

    // Biela curta do servo para o yoke.
    color(dark_grey)
        translate([12, 142, 0])
            straight_link_asym(crank_link_len, link_width, link_thickness, m2_clearance_d, m3_clearance_d);

    // Horn/crank excêntrico do servo.
    color(dark_grey)
        translate([112, 72, 0])
            servo_crank_horn();

    // Arruelas e espaçadores.
    color(dark_grey) {
        // Arruelas bem espaçadas para não se encostarem no layout de impressão.
        for (i = [0:9])
            translate([38 + i*13, 162, 0])
                washer();

        // Espaçadores em linha própria, com folga lateral.
        for (i = [0:5])
            translate([48 + i*18, 180, 0])
                spacer(5.5);
    }

    // Pinos impressos separados, opcionais.
    if (show_printed_pins) {
        color(dark_grey)
            for (i = [0:7])
                translate([42 + i*15, 202, 0])
                    printed_pin(17);
    }

    if (include_labels) {
        translate([10, -46, 0])
            label_text("PECAS SEPARADAS PARA IMPRESSAO", 4.2);

        translate([58, 54, 0])
            label_text("YOKE DESLIZANTE", 2.8);

        translate([112, 54, 0])
            label_text("HORN EXCENTRICO", 2.8);

        translate([100, 151, 0])
            label_text("ARRUELAS / ESPACADORES", 2.7);

        translate([96, 216, 0])
            label_text("PINOS VISUAIS", 2.7);
    }
}

// =========================
// CENA FINAL
// =========================

if (layout == "assembly_only") {
    assembly_model();
}
else if (layout == "print_only") {
    print_layout(false);
}
else {
    // À esquerda: peças imprimíveis separadas.
    translate([-180, -72, 0])
        print_layout(true);

    // À direita: montagem usando os mesmos módulos e dimensões.
    translate([150, 0, 0])
        assembly_model();

    translate([150, -44, 0])
        label_text("MODELO MONTADO - MESMAS PROPORCOES", 4.2);
}
