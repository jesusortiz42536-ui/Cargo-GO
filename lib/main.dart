import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/api_service.dart';

class AppTheme {
  static const bg = Color(0xFF060B18);
  static const sf = Color(0xFF0C1221);
  static const cd = Color(0xFF111D33);
  static const bd = Color(0xFF1C2D4A);
  static const ac = Color(0xFF2D7AFF);
  static const gr = Color(0xFF00D68F);
  static const rd = Color(0xFFFF4757);
  static const or = Color(0xFFFFA502);
  static const pu = Color(0xFF7C5CFC);
  static const pk = Color(0xFFFF6B9D);
  static const tl = Color(0xFF009688);
  static const cy = Color(0xFF00D2D3);
  static const yl = Color(0xFFFFD32A);
  static const tx = Color(0xFFEDF2F7);
  static const tm = Color(0xFF8899B4);
  static const td = Color(0xFF506080);
}

// Google Maps dark style JSON
const String _darkMapStyle = '''[
  {"elementType":"geometry","stylers":[{"color":"#0d1117"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8899b4"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#0d1117"}]},
  {"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#1c2d4a"}]},
  {"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#506080"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#111d33"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#8899b4"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#0c1a10"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#1c2d4a"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#111d33"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#2d7aff"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#0d47a1"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#111d33"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#060b18"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#506080"}]}
]''';

class MenuItem {
  final String n, d;
  final int p;
  final bool pop, best;
  MenuItem({required this.n, required this.d, required this.p, this.pop = false, this.best = false});
}

class FarmItem {
  final String n, lab, cat;
  final int lista, stock;
  final bool rx;
  FarmItem({required this.n, required this.lab, required this.cat, required this.lista, required this.stock, this.rx = false});
  int get oferta => (lista * 0.65).round();
}

class Negocio {
  final String id, nom, e, zona, desc, tipo;
  final double r;
  final int ped;
  final Color c;
  final String? menu;
  Negocio({required this.id, required this.nom, required this.e, required this.zona, required this.desc, required this.tipo, required this.r, required this.ped, required this.c, this.menu});
}

class Pedido {
  final String id, cl, orig, dest, est, h, city;
  final int m, prog;
  Pedido({required this.id, required this.cl, required this.orig, required this.dest, required this.est, required this.h, required this.city, required this.m, required this.prog});
}

class Ruta {
  final String nom, dist, t, est;
  final int paq;
  final Color c;
  Ruta({required this.nom, required this.dist, required this.t, required this.est, required this.paq, required this.c});
}

class CartItem {
  final String n, from;
  final int p;
  final int? oferta;
  int q;
  CartItem({required this.n, required this.from, required this.p, this.oferta, this.q = 1});
  int get price => oferta ?? p;
}

class Notif {
  final String t, d, time;
  bool read;
  Notif({required this.t, required this.d, required this.time, this.read = false});
}

class Addr {
  final String l, a;
  final bool main;
  Addr({required this.l, required this.a, this.main = false});
}

class PayMethod {
  final String l;
  final bool main;
  PayMethod({required this.l, this.main = false});
}

class OrderHist {
  final String id, dt, from;
  final List<String> items;
  final int tot;
  OrderHist({required this.id, required this.dt, required this.from, required this.items, required this.tot});
}

// ═══ MENUS ═══
final Map<String, List<MenuItem>> menuMama = {
  "🍳 Desayunos": [
    MenuItem(n: "Chilaquiles Rojos", d: "Tortilla frita, salsa roja, crema, queso, huevo", p: 65, pop: true),
    MenuItem(n: "Chilaquiles Verdes c/Pollo", d: "Salsa verde, pollo deshebrado, crema", p: 85, pop: true),
    MenuItem(n: "Huevos Rancheros", d: "2 huevos estrellados, tortilla, salsa ranchera", p: 55),
    MenuItem(n: "Huevos a la Mexicana", d: "Revueltos con jitomate, cebolla, chile", p: 50),
    MenuItem(n: "Molletes Especiales", d: "Bolillo, frijoles, queso gratinado, pico de gallo", p: 45),
    MenuItem(n: "Enchiladas de Comal", d: "4 tortillas bañadas en salsa, queso, crema", p: 60),
    MenuItem(n: "Quesadillas Huitlacoche", d: "3 quesadillas de maíz, huitlacoche, Oaxaca", p: 70),
  ],
  "🍲 Platillos": [
    MenuItem(n: "Barbacoa de Res", d: "Estilo Tulancingo, horno subterráneo. Consomé", p: 145, pop: true, best: true),
    MenuItem(n: "Pastes Hidalguenses (3)", d: "Empanadas horneadas: papa, frijol, mole", p: 55, pop: true),
    MenuItem(n: "Mole Poblano c/Pollo", d: "Pieza de pollo en mole negro, arroz, tortillas", p: 110),
    MenuItem(n: "Cecina Enchilada", d: "Cecina de res estilo Hidalgo, nopales, salsa", p: 130, pop: true),
    MenuItem(n: "Mixiotes de Pollo", d: "En penca de maguey con chiles y especias", p: 105),
    MenuItem(n: "Carnitas de Cerdo", d: "Estilo Michoacán, tortillas, cilantro, salsas", p: 160),
    MenuItem(n: "Pozole Rojo", d: "Maíz, cerdo, lechuga, rábano, orégano", p: 85),
    MenuItem(n: "Tinga de Pollo", d: "Pollo en chipotle, tostadas, crema, queso", p: 75),
    MenuItem(n: "Pambazos (2)", d: "Papa con chorizo, lechuga, crema, salsa", p: 50, pop: true),
    MenuItem(n: "Guajolotes (2)", d: "Pan en salsa guajillo estilo Tulancingo", p: 45),
    MenuItem(n: "Chiles Rellenos", d: "Chile poblano, queso/picadillo, caldillo", p: 90),
    MenuItem(n: "Escamoles (temporada)", d: "Larvas de hormiga, mantequilla, epazote", p: 220),
    MenuItem(n: "Chinicuiles al Ajillo", d: "Gusanos de maguey, guacamole, tortillas", p: 180),
  ],
  "🥣 Sopas": [
    MenuItem(n: "Consomé de Barbacoa", d: "Garbanzo, cilantro, cebolla, chile, limón", p: 45, pop: true),
    MenuItem(n: "Caldo Tlalpeño", d: "Pollo, garbanzo, chipotle, aguacate", p: 70),
    MenuItem(n: "Sopa Azteca", d: "Tortilla frita, crema, queso, aguacate", p: 65),
    MenuItem(n: "Crema de Elote", d: "Elote fresco, crema, epazote, chile poblano", p: 55),
    MenuItem(n: "Caldo de Res", d: "Chambarete, verduras, cilantro, arroz", p: 80),
  ],
  "🥤 Bebidas": [
    MenuItem(n: "Horchata (1L)", d: "Arroz, canela, vainilla, leche", p: 30),
    MenuItem(n: "Jamaica (1L)", d: "Flor de jamaica fresca", p: 30),
    MenuItem(n: "Pulque Natural", d: "De maguey regional, fresco", p: 35),
    MenuItem(n: "Café de Olla", d: "Piloncillo y canela, taza grande", p: 25),
    MenuItem(n: "Atole de Vainilla", d: "Masa de maíz, piloncillo", p: 30),
    MenuItem(n: "Michelada", d: "Cerveza, chamoy, limón, chile", p: 55),
    MenuItem(n: "Refresco", d: "Coca-Cola, Jarritos, Agua", p: 25),
  ],
};

final Map<String, List<MenuItem>> menuDulce = {
  "🎂 Pasteles": [
    MenuItem(n: "Pastel Tres Leches", d: "Bizcocho bañado en 3 leches, crema, canela", p: 95, pop: true, best: true),
    MenuItem(n: "Chocoflan", d: "Flan de vainilla sobre chocolate, cajeta", p: 90, pop: true),
    MenuItem(n: "Red Velvet", d: "Bizcocho rojo, betún de queso crema", p: 105),
    MenuItem(n: "Pastel Zanahoria", d: "Nuez, canela, betún queso crema", p: 95),
    MenuItem(n: "Chocolate Triple", d: "3 capas, ganache, frutos rojos", p: 100),
    MenuItem(n: "Pastel Pistache", d: "Pan de pistache, betún, nueces tostadas", p: 120),
    MenuItem(n: "Pay Queso c/Cajeta", d: "Base galleta, queso crema, cajeta", p: 80),
  ],
  "🍮 Postres MX": [
    MenuItem(n: "Churros c/Chocolate (6)", d: "Azúcar-canela, chocolate caliente", p: 55, pop: true),
    MenuItem(n: "Flan Napolitano", d: "Queso crema con caramelo casero", p: 50, pop: true),
    MenuItem(n: "Arroz con Leche", d: "Cremoso, canela, pasas, leche condensada", p: 40),
    MenuItem(n: "Pan de Elote", d: "Húmedo, dulce natural del maíz", p: 40),
    MenuItem(n: "Jericalla", d: "Leche, vainilla, canela, quemada", p: 45),
    MenuItem(n: "Cocadas (4)", d: "Coco rallado, leche condensada", p: 35),
    MenuItem(n: "Buñuelos c/Miel (3)", d: "Miel de piloncillo caliente", p: 40),
    MenuItem(n: "Camotes Poblanos (4)", d: "Fresa, piña, limón, guayaba", p: 35),
    MenuItem(n: "Crepa Cajeta c/Nuez", d: "Cajeta caliente, nuez, crema", p: 60),
    MenuItem(n: "Gelatina Mosaico", d: "6 sabores, leche condensada", p: 30),
  ],
  "🍦 Helados": [
    MenuItem(n: "Nieve de Garrafa", d: "Vainilla, fresa, limón, mango", p: 35, pop: true),
    MenuItem(n: "Esquite Helado", d: "Helado de elote, chile, limón, queso", p: 50),
    MenuItem(n: "Paleta Mango-Chile", d: "Mango fresco, chamoy, Tajín", p: 25),
    MenuItem(n: "Banana Split MX", d: "Cajeta, chocolate, nuez, crema", p: 70),
    MenuItem(n: "Raspado de Frutas", d: "Hielo raspado, jarabe, fruta, chamoy", p: 30),
  ],
  "☕ Bebidas": [
    MenuItem(n: "Chocolate Abuelita", d: "Chocolate caliente, canela, espumoso", p: 35, pop: true),
    MenuItem(n: "Champurrado", d: "Atole de chocolate, masa de maíz", p: 40),
    MenuItem(n: "Frappé de Cajeta", d: "Café, helado, cajeta, crema batida", p: 60),
    MenuItem(n: "Malteada Oreo", d: "Helado vainilla, galleta, leche", p: 55),
    MenuItem(n: "Smoothie Mango", d: "Mango, yogurt, miel de abeja", p: 50),
  ],
};

// ═══ FARMACIA ═══
final List<FarmItem> farmacia = [
  FarmItem(n: "Losartán 50mg", lab: "Genérico", cat: "gen", lista: 85, stock: 340, rx: true),
  FarmItem(n: "Metformina 850mg", lab: "Genérico", cat: "gen", lista: 65, stock: 520, rx: true),
  FarmItem(n: "Omeprazol 20mg", lab: "Genérico", cat: "gen", lista: 45, stock: 410),
  FarmItem(n: "Paracetamol 500mg", lab: "Genérico", cat: "gen", lista: 35, stock: 800),
  FarmItem(n: "Ibuprofeno 400mg", lab: "Genérico", cat: "gen", lista: 40, stock: 650),
  FarmItem(n: "Amoxicilina 500mg", lab: "Genérico", cat: "gen", lista: 95, stock: 280, rx: true),
  FarmItem(n: "Atorvastatina 20mg", lab: "Genérico", cat: "gen", lista: 120, stock: 190, rx: true),
  FarmItem(n: "Naproxeno 250mg", lab: "Genérico", cat: "gen", lista: 55, stock: 390),
  FarmItem(n: "Ciprofloxacino 500mg", lab: "Genérico", cat: "gen", lista: 110, stock: 200, rx: true),
  FarmItem(n: "Gabapentina 300mg", lab: "Genérico", cat: "gen", lista: 150, stock: 145, rx: true),
  FarmItem(n: "Aspirina Protect", lab: "Bayer", cat: "pat", lista: 180, stock: 220),
  FarmItem(n: "Advil 400mg", lab: "Pfizer", cat: "pat", lista: 120, stock: 300),
  FarmItem(n: "Nexium 20mg", lab: "AstraZeneca", cat: "pat", lista: 450, stock: 80, rx: true),
  FarmItem(n: "Lipitor 40mg", lab: "Pfizer", cat: "pat", lista: 680, stock: 55, rx: true),
  FarmItem(n: "Saxenda", lab: "Novo Nordisk", cat: "esp", lista: 4200, stock: 12, rx: true),
  FarmItem(n: "Ozempic 1mg", lab: "Novo Nordisk", cat: "esp", lista: 3800, stock: 8, rx: true),
  FarmItem(n: "Humira", lab: "AbbVie", cat: "bio", lista: 24500, stock: 4, rx: true),
  FarmItem(n: "Enbrel", lab: "Pfizer", cat: "bio", lista: 18900, stock: 3, rx: true),
  FarmItem(n: "Herceptin", lab: "Roche", cat: "bio", lista: 32000, stock: 2, rx: true),
  FarmItem(n: "Stelara", lab: "Janssen", cat: "bio", lista: 38000, stock: 3, rx: true),
  FarmItem(n: "Cosentyx", lab: "Novartis", cat: "bio", lista: 28000, stock: 4, rx: true),
  FarmItem(n: "Keytruda", lab: "MSD", cat: "onc", lista: 85000, stock: 2, rx: true),
  FarmItem(n: "Opdivo", lab: "BMS", cat: "onc", lista: 72000, stock: 2, rx: true),
  FarmItem(n: "Ibrance", lab: "Pfizer", cat: "onc", lista: 62000, stock: 3, rx: true),
  FarmItem(n: "Revlimid", lab: "BMS", cat: "onc", lista: 95000, stock: 2, rx: true),
];

// ═══ 100 NEGOCIOS ═══
final List<Negocio> negHidalgo = [
  Negocio(id:"h01",nom:"Farmacias Madrid",e:"💊",zona:"Centro, Tulancingo",desc:"5 sucursales · 77K+ productos",r:4.8,ped:1240,c:AppTheme.gr,menu:"farmacia",tipo:"farmacia"),
  Negocio(id:"h02",nom:"Mamá Chela",e:"🍲",zona:"Centro, Tulancingo",desc:"Comida casera hidalguense",r:4.9,ped:890,c:AppTheme.or,menu:"mama",tipo:"comida"),
  Negocio(id:"h03",nom:"Dulce María",e:"🧁",zona:"La Floresta, Tulancingo",desc:"Postres artesanales mexicanos",r:4.7,ped:650,c:AppTheme.pk,menu:"dulce",tipo:"postres"),
  Negocio(id:"h04",nom:"Tacos El Güero",e:"🌮",zona:"Centro, Tulancingo",desc:"Tacos al pastor y suadero",r:4.6,ped:1100,c:AppTheme.rd,tipo:"comida"),
  Negocio(id:"h05",nom:"Carnitas Don Pepe",e:"🥩",zona:"San Antonio, Tulancingo",desc:"Carnitas estilo Michoacán",r:4.5,ped:780,c:const Color(0xFFB45309),tipo:"comida"),
  Negocio(id:"h06",nom:"Pollos El Rey",e:"🍗",zona:"Las Torres, Tulancingo",desc:"Pollo al carbón y rostizado",r:4.4,ped:920,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"h07",nom:"Café Tulancingo",e:"☕",zona:"Centro, Tulancingo",desc:"Café de altura hidalguense",r:4.6,ped:520,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"h08",nom:"Tortas La Abuela",e:"🥖",zona:"Jaltepec, Tulancingo",desc:"Tortas gigantes y cemitas",r:4.7,ped:670,c:const Color(0xFFCA8A04),tipo:"comida"),
  Negocio(id:"h09",nom:"Barbacoa Los Reyes",e:"🐑",zona:"Centro, Tulancingo",desc:"Barbacoa borrego jue y dom",r:4.8,ped:950,c:const Color(0xFF92400E),tipo:"comida"),
  Negocio(id:"h10",nom:"Pastes El Portal",e:"🥟",zona:"Centro, Tulancingo",desc:"Pastes tradicionales 1960",r:4.7,ped:1050,c:const Color(0xFFD97706),tipo:"comida"),
  Negocio(id:"h11",nom:"Panadería San José",e:"🍞",zona:"La Floresta",desc:"Pan artesanal y de fiesta",r:4.5,ped:420,c:const Color(0xFFA16207),tipo:"panaderia"),
  Negocio(id:"h12",nom:"Pulquería La Noria",e:"🍺",zona:"Santiago, Tulancingo",desc:"Pulque natural y curados",r:4.3,ped:380,c:const Color(0xFF4D7C0F),tipo:"bebidas"),
  Negocio(id:"h13",nom:"Abarrotes Doña Lupe",e:"🏪",zona:"Cuautepec",desc:"Abarrotes y productos básicos",r:4.2,ped:620,c:AppTheme.tl,tipo:"abarrotes"),
  Negocio(id:"h14",nom:"Pizzas Tulancingo",e:"🍕",zona:"Las Torres",desc:"Pizza al horno de leña",r:4.4,ped:540,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"h15",nom:"Jugos y Licuados Mary",e:"🥤",zona:"Mercado",desc:"Jugos naturales y licuados",r:4.5,ped:730,c:const Color(0xFF16A34A),tipo:"bebidas"),
  Negocio(id:"h16",nom:"Taller Bicis Rápido",e:"🚲",zona:"Centro",desc:"Reparación y refacciones",r:4.1,ped:180,c:const Color(0xFF6366F1),tipo:"servicios"),
  Negocio(id:"h17",nom:"Flores El Jardín",e:"💐",zona:"La Floresta",desc:"Arreglos florales y ramos",r:4.6,ped:290,c:const Color(0xFFE11D48),tipo:"flores"),
  Negocio(id:"h18",nom:"Carnicería Hidalgo",e:"🥩",zona:"Mercado",desc:"Carnes selectas y marinados",r:4.4,ped:810,c:const Color(0xFF991B1B),tipo:"carniceria"),
  Negocio(id:"h19",nom:"Ferretería Central",e:"🔧",zona:"Centro",desc:"Material eléctrico y plomería",r:4.3,ped:350,c:const Color(0xFF525252),tipo:"ferreteria"),
  Negocio(id:"h20",nom:"Papelería Escolar",e:"📚",zona:"Centro",desc:"Útiles, copias, impresiones",r:4.2,ped:460,c:const Color(0xFF2563EB),tipo:"papeleria"),
];

final List<Negocio> negCdmx = [
  Negocio(id:"c01",nom:"El Califa de León",e:"🌮",zona:"San Rafael",desc:"⭐Michelin · Tacos 1968",r:4.9,ped:3200,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c02",nom:"Café El Jarocho",e:"☕",zona:"Coyoacán",desc:"El café más famoso de CDMX",r:4.8,ped:2800,c:const Color(0xFF33691E),tipo:"cafe"),
  Negocio(id:"c03",nom:"Los Cocuyos",e:"🥩",zona:"Centro Histórico",desc:"Suadero y longaniza legendarios",r:4.7,ped:2100,c:const Color(0xFFB91C1C),tipo:"comida"),
  Negocio(id:"c04",nom:"Mercado Coyoacán",e:"🏪",zona:"Coyoacán",desc:"Tostadas, antojitos, quesadillas",r:4.5,ped:2400,c:AppTheme.tl,tipo:"mercado"),
  Negocio(id:"c05",nom:"Tacos Orinoco",e:"🌮",zona:"Roma Norte",desc:"Tacos chicharrón prensado",r:4.8,ped:2900,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"c06",nom:"Por Siempre Vegana",e:"🥬",zona:"Roma Sur",desc:"Tacos veganos gourmet",r:4.6,ped:1800,c:const Color(0xFF16A34A),tipo:"comida"),
  Negocio(id:"c07",nom:"Churrería El Moro",e:"🍩",zona:"Centro Histórico",desc:"Churros desde 1935",r:4.7,ped:3100,c:const Color(0xFF92400E),tipo:"postres"),
  Negocio(id:"c08",nom:"Pastelería Ideal",e:"🎂",zona:"Centro Histórico",desc:"Pan y pasteles monumentales",r:4.5,ped:2200,c:const Color(0xFFA16207),tipo:"panaderia"),
  Negocio(id:"c09",nom:"La Casa de Toño",e:"🥣",zona:"Polanco",desc:"Pozole y sopes 24hrs",r:4.6,ped:2700,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c10",nom:"Taquería Los Parados",e:"🌮",zona:"Insurgentes",desc:"Tacos bistec al carbón",r:4.5,ped:2500,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c11",nom:"Boing! Factory",e:"🥤",zona:"Xochimilco",desc:"Jugos embotellados artesanales",r:4.3,ped:1200,c:const Color(0xFFF59E0B),tipo:"bebidas"),
  Negocio(id:"c12",nom:"Birria El Texano",e:"🍖",zona:"Narvarte",desc:"Birria de res en consomé",r:4.7,ped:1900,c:const Color(0xFF991B1B),tipo:"comida"),
  Negocio(id:"c13",nom:"Mercado Jamaica",e:"💐",zona:"Jamaica",desc:"Flores, frutas y víveres",r:4.4,ped:1600,c:const Color(0xFFE11D48),tipo:"mercado"),
  Negocio(id:"c14",nom:"Helados Tepoznieves",e:"🍦",zona:"Condesa",desc:"Nieves artesanales exóticas",r:4.6,ped:2000,c:const Color(0xFF0891B2),tipo:"postres"),
  Negocio(id:"c15",nom:"Panadería Rosetta",e:"🍞",zona:"Roma Norte",desc:"Pan artesanal europeo-mx",r:4.8,ped:1700,c:const Color(0xFF78350F),tipo:"panaderia"),
  Negocio(id:"c16",nom:"Tortas Río",e:"🥖",zona:"Tlalpan",desc:"Tortas cubanas gigantes",r:4.4,ped:1400,c:const Color(0xFFCA8A04),tipo:"comida"),
  Negocio(id:"c17",nom:"Mariscos La Viga",e:"🦐",zona:"La Viga",desc:"Cocteles y ceviches frescos",r:4.5,ped:1300,c:const Color(0xFF0284C7),tipo:"mariscos"),
  Negocio(id:"c18",nom:"Tamales Doña Emi",e:"🫔",zona:"Tacubaya",desc:"Tamales de todos sabores",r:4.6,ped:2100,c:const Color(0xFF65A30D),tipo:"comida"),
  Negocio(id:"c19",nom:"Gorditas Doña Tota",e:"🫓",zona:"Centro",desc:"Gorditas rellenas al momento",r:4.5,ped:1800,c:const Color(0xFFD97706),tipo:"comida"),
  Negocio(id:"c20",nom:"Café Habana",e:"☕",zona:"Juárez",desc:"Café icónico desde 1950",r:4.7,ped:1500,c:const Color(0xFF44403C),tipo:"cafe"),
  Negocio(id:"c21",nom:"Quesadillas Doña Mary",e:"🧀",zona:"Del Valle",desc:"Quesadillas con/sin queso",r:4.4,ped:1600,c:const Color(0xFFEAB308),tipo:"comida"),
  Negocio(id:"c22",nom:"Tacos Canasta Javi",e:"🌮",zona:"Tepito",desc:"Tacos sudados a \$5",r:4.3,ped:3800,c:const Color(0xFFB91C1C),tipo:"comida"),
  Negocio(id:"c23",nom:"Mercado San Juan",e:"🏪",zona:"Centro",desc:"Productos gourmet y exóticos",r:4.6,ped:1400,c:AppTheme.pu,tipo:"mercado"),
  Negocio(id:"c24",nom:"Carnitas Don Güicho",e:"🐷",zona:"Azcapotzalco",desc:"Carnitas estilo Quiroga",r:4.5,ped:1700,c:const Color(0xFF92400E),tipo:"comida"),
  Negocio(id:"c25",nom:"Farmacia del Ahorro",e:"💊",zona:"Centro Histórico",desc:"Farmacia 24hrs",r:4.2,ped:900,c:AppTheme.gr,tipo:"farmacia"),
  Negocio(id:"c26",nom:"La Especial de París",e:"🥘",zona:"Insurgentes",desc:"Comida corrida desde 1921",r:4.4,ped:1300,c:const Color(0xFF7C2D12),tipo:"comida"),
  Negocio(id:"c27",nom:"Café de Tacuba",e:"🍽️",zona:"Centro Histórico",desc:"Restaurante histórico 1912",r:4.6,ped:1100,c:const Color(0xFF78350F),tipo:"comida"),
  Negocio(id:"c28",nom:"El Huequito",e:"🌮",zona:"Centro",desc:"Tacos al pastor pioneros",r:4.7,ped:2600,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c29",nom:"Nevería Roxy",e:"🍦",zona:"Coyoacán",desc:"Helados artesanales 1946",r:4.5,ped:1800,c:const Color(0xFFEC4899),tipo:"postres"),
  Negocio(id:"c30",nom:"Pan Bimbo Outlet",e:"🍞",zona:"Naucalpan",desc:"Pan de caja al costo",r:4.1,ped:700,c:const Color(0xFF2563EB),tipo:"panaderia"),
  Negocio(id:"c31",nom:"Mariscos El Caguamo",e:"🐟",zona:"Centro",desc:"Mariscos estilo Nayarit",r:4.6,ped:1500,c:const Color(0xFF0891B2),tipo:"mariscos"),
  Negocio(id:"c32",nom:"Tlayudas Oaxaqueñas",e:"🫓",zona:"Condesa",desc:"Tlayudas y mezcal artesanal",r:4.5,ped:1200,c:const Color(0xFF854D0E),tipo:"comida"),
  Negocio(id:"c33",nom:"Pollos Río",e:"🍗",zona:"Polanco",desc:"Pollo al horno c/papas",r:4.3,ped:1900,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"c34",nom:"Esquites Don Beto",e:"🌽",zona:"Reforma",desc:"Esquites, elotes, trolelotes",r:4.4,ped:2200,c:const Color(0xFFEAB308),tipo:"comida"),
  Negocio(id:"c35",nom:"Mezcalería",e:"🥃",zona:"Doctores",desc:"Mezcal artesanal oaxaqueño",r:4.6,ped:800,c:const Color(0xFFA16207),tipo:"bebidas"),
  Negocio(id:"c36",nom:"Sushi Itto Express",e:"🍣",zona:"Santa Fe",desc:"Sushi delivery rápido",r:4.2,ped:1600,c:const Color(0xFFBE123C),tipo:"comida"),
  Negocio(id:"c37",nom:"Pizzas Domino",e:"🍕",zona:"Nápoles",desc:"Pizza y alitas delivery",r:4.1,ped:2400,c:const Color(0xFF1D4ED8),tipo:"comida"),
  Negocio(id:"c38",nom:"Tostadas Coyoacán",e:"🥗",zona:"Coyoacán",desc:"Tostadas de pata y ceviche",r:4.5,ped:1400,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c39",nom:"Dulcería de Celaya",e:"🍬",zona:"Centro",desc:"Dulces mexicanos 1874",r:4.7,ped:900,c:const Color(0xFFF472B6),tipo:"postres"),
  Negocio(id:"c40",nom:"Fonda Margarita",e:"🍳",zona:"Condesa",desc:"Desayunos legendarios",r:4.8,ped:1300,c:const Color(0xFFF59E0B),tipo:"comida"),
  Negocio(id:"c41",nom:"La Polar",e:"🍺",zona:"San Rafael",desc:"Cervecería con botanas",r:4.4,ped:1100,c:const Color(0xFFCA8A04),tipo:"bebidas"),
  Negocio(id:"c42",nom:"Taco Inn",e:"🌮",zona:"Insurgentes Sur",desc:"Fast food mexicano",r:4.2,ped:1800,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c43",nom:"Superama Express",e:"🛒",zona:"Polanco",desc:"Súper premium delivery",r:4.3,ped:950,c:const Color(0xFF059669),tipo:"super"),
  Negocio(id:"c44",nom:"La Merced Orgánica",e:"🥕",zona:"La Merced",desc:"Frutas y verduras orgánicas",r:4.5,ped:680,c:const Color(0xFF16A34A),tipo:"mercado"),
  Negocio(id:"c45",nom:"Papelería Lumen",e:"📚",zona:"Centro",desc:"Papelería profesional",r:4.4,ped:540,c:const Color(0xFF7C3AED),tipo:"papeleria"),
  Negocio(id:"c46",nom:"Ferretería Truper",e:"🔧",zona:"Iztapalapa",desc:"Herramientas y material",r:4.2,ped:420,c:const Color(0xFF525252),tipo:"ferreteria"),
  Negocio(id:"c47",nom:"Florerías CDMX",e:"💐",zona:"Polanco",desc:"Arreglos premium",r:4.6,ped:560,c:const Color(0xFFE11D48),tipo:"flores"),
  Negocio(id:"c48",nom:"Alitas y Boneless",e:"🍗",zona:"Roma",desc:"Wings y cerveza artesanal",r:4.4,ped:1700,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"c49",nom:"VIPS Insurgentes",e:"🍽️",zona:"Insurgentes",desc:"Enchiladas y café 24hrs",r:4.1,ped:1400,c:const Color(0xFF0284C7),tipo:"comida"),
  Negocio(id:"c50",nom:"Tamal Oaxaqueño",e:"🫔",zona:"Del Valle",desc:"Tamales oaxaqueños de mole",r:4.5,ped:1100,c:const Color(0xFF854D0E),tipo:"comida"),
  Negocio(id:"c51",nom:"Ramen Shinju",e:"🍜",zona:"Roma Norte",desc:"Ramen japonés auténtico",r:4.7,ped:1200,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c52",nom:"Hamburguesas Corral",e:"🍔",zona:"Condesa",desc:"Burgers artesanales",r:4.5,ped:1500,c:const Color(0xFFB91C1C),tipo:"comida"),
  Negocio(id:"c53",nom:"Café Punta del Cielo",e:"☕",zona:"Coyoacán",desc:"Café mexicano especialidad",r:4.4,ped:1800,c:const Color(0xFF44403C),tipo:"cafe"),
  Negocio(id:"c54",nom:"Waffles & Crêpes",e:"🧇",zona:"Roma",desc:"Waffles belgas y crêpes",r:4.5,ped:900,c:const Color(0xFFD97706),tipo:"postres"),
  Negocio(id:"c55",nom:"Tortería Niza",e:"🥖",zona:"Juárez",desc:"Tortas desde 1957",r:4.6,ped:1300,c:const Color(0xFFA16207),tipo:"comida"),
  Negocio(id:"c56",nom:"Pozolería Tía Calla",e:"🥣",zona:"Roma Sur",desc:"Pozole blanco guerrerense",r:4.6,ped:1100,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c57",nom:"Lavandería Express",e:"👔",zona:"Narvarte",desc:"Lavado y planchado 2hrs",r:4.3,ped:380,c:const Color(0xFF0284C7),tipo:"servicios"),
  Negocio(id:"c58",nom:"Tintorería Premium",e:"👗",zona:"Polanco",desc:"Tintorería y costura",r:4.4,ped:290,c:const Color(0xFF7C3AED),tipo:"servicios"),
  Negocio(id:"c59",nom:"Barbería Old School",e:"💈",zona:"Roma",desc:"Cortes clásicos y barba",r:4.5,ped:420,c:const Color(0xFFB91C1C),tipo:"servicios"),
  Negocio(id:"c60",nom:"Veterinaria PetCare",e:"🐾",zona:"Del Valle",desc:"Consultas y productos pet",r:4.4,ped:560,c:const Color(0xFF16A34A),tipo:"servicios"),
  Negocio(id:"c61",nom:"Cervecería Primus",e:"🍺",zona:"Coyoacán",desc:"Cerveza artesanal local",r:4.6,ped:700,c:const Color(0xFFCA8A04),tipo:"bebidas"),
  Negocio(id:"c62",nom:"Comida China Wing's",e:"🥡",zona:"Centro",desc:"Comida china económica",r:4.2,ped:1600,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c63",nom:"Empanadas Argentinas",e:"🥟",zona:"Condesa",desc:"Empanadas al horno",r:4.5,ped:800,c:const Color(0xFF0284C7),tipo:"comida"),
  Negocio(id:"c64",nom:"Jugos Natural Express",e:"🥤",zona:"Roma",desc:"Jugos verdes y smoothies",r:4.4,ped:950,c:const Color(0xFF16A34A),tipo:"bebidas"),
  Negocio(id:"c65",nom:"El Pescadito",e:"🐟",zona:"Condesa",desc:"Fish tacos Ensenada",r:4.7,ped:1400,c:const Color(0xFF0891B2),tipo:"mariscos"),
  Negocio(id:"c66",nom:"Korean BBQ Mex",e:"🥘",zona:"Zona Rosa",desc:"BBQ coreano fusión mx",r:4.5,ped:900,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c67",nom:"Abarrotes Don Toño",e:"🏪",zona:"Tepito",desc:"Abarrotes al mayoreo",r:4.1,ped:1200,c:AppTheme.tl,tipo:"abarrotes"),
  Negocio(id:"c68",nom:"Tienda Naturista",e:"🌿",zona:"Coyoacán",desc:"Productos naturales",r:4.3,ped:450,c:const Color(0xFF16A34A),tipo:"naturista"),
  Negocio(id:"c69",nom:"Librería Gandhi",e:"📖",zona:"Miguel Ángel",desc:"Libros y envío express",r:4.5,ped:380,c:const Color(0xFFEAB308),tipo:"libreria"),
  Negocio(id:"c70",nom:"Copias Print Center",e:"🖨️",zona:"Centro",desc:"Impresiones, planos, lonas",r:4.2,ped:620,c:const Color(0xFF6366F1),tipo:"servicios"),
  Negocio(id:"c71",nom:"Bike Messenger",e:"🚴",zona:"Juárez",desc:"Mensajería en bici express",r:4.4,ped:780,c:const Color(0xFF059669),tipo:"servicios"),
  Negocio(id:"c72",nom:"Carnicería Premium",e:"🥩",zona:"Polanco",desc:"Cortes Angus y Wagyu",r:4.7,ped:540,c:const Color(0xFF991B1B),tipo:"carniceria"),
  Negocio(id:"c73",nom:"Tortillería La Güera",e:"🫓",zona:"Iztacalco",desc:"Tortillas maíz nixtamal",r:4.5,ped:2800,c:const Color(0xFFD97706),tipo:"comida"),
  Negocio(id:"c74",nom:"Mueblería Express",e:"🪑",zona:"Naucalpan",desc:"Muebles y mudanzas",r:4.1,ped:180,c:const Color(0xFF78350F),tipo:"servicios"),
  Negocio(id:"c75",nom:"Pastes Hidalguenses",e:"🥟",zona:"Roma",desc:"Pastes originales Hidalgo",r:4.6,ped:650,c:const Color(0xFFD97706),tipo:"comida"),
  Negocio(id:"c76",nom:"Cevichería Pacífico",e:"🦐",zona:"Narvarte",desc:"Ceviche y aguachile",r:4.6,ped:1100,c:const Color(0xFF0891B2),tipo:"mariscos"),
  Negocio(id:"c77",nom:"Brownies & Co.",e:"🍫",zona:"Condesa",desc:"Brownies gourmet y cookies",r:4.5,ped:780,c:const Color(0xFF78350F),tipo:"postres"),
  Negocio(id:"c78",nom:"Dona María Mole",e:"🫕",zona:"Centro",desc:"Moles artesanales",r:4.4,ped:460,c:const Color(0xFF7C2D12),tipo:"comida"),
  Negocio(id:"c79",nom:"Cochinita Express",e:"🐷",zona:"Narvarte",desc:"Cochinita, panuchos, salbutes",r:4.6,ped:1300,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"c80",nom:"Mercado Roma",e:"🏪",zona:"Roma",desc:"Food court gourmet",r:4.5,ped:1600,c:AppTheme.pu,tipo:"mercado"),
  Negocio(id:"c81",nom:"Costco",e:"🛒",zona:"Satélite · Coyoacán · Interlomas",desc:"Mayoreo · Electrónica · Alimentos",r:4.7,ped:5200,c:const Color(0xFF005DAA),tipo:"super"),
];

final List<Pedido> pedidos = [
  Pedido(id:"CGO-2601",cl:"María López",orig:"Farmacias Madrid",dest:"Centro, Tulancingo",est:"ruta",m:245,h:"14:32",prog:68,city:"hidalgo"),
  Pedido(id:"CGO-2602",cl:"Carlos Ramírez",orig:"Mamá Chela",dest:"La Floresta",est:"prep",m:310,h:"14:45",prog:30,city:"hidalgo"),
  Pedido(id:"CGO-2603",cl:"Ana García",orig:"Dulce María",dest:"Condesa, CDMX",est:"ok",m:520,h:"13:15",prog:100,city:"cdmx"),
  Pedido(id:"CGO-2604",cl:"Roberto Sánchez",orig:"Barbacoa ×2kg",dest:"Pachuca",est:"ruta",m:450,h:"12:00",prog:45,city:"hidalgo"),
  Pedido(id:"CGO-2605",cl:"Laura Méndez",orig:"Tres Leches ×3",dest:"Roma Norte",est:"ok",m:680,h:"11:30",prog:100,city:"cdmx"),
  Pedido(id:"CGO-2606",cl:"Pedro Hernández",orig:"Keytruda 200mg",dest:"Santiago Tula",est:"ruta",m:55250,h:"10:15",prog:82,city:"hidalgo"),
  Pedido(id:"CGO-2607",cl:"Sofía Reyes",orig:"Mamá Chela Combi",dest:"Cuautepec",est:"prep",m:195,h:"15:02",prog:15,city:"hidalgo"),
  Pedido(id:"CGO-2608",cl:"José Martínez",orig:"El Califa de León",dest:"Polanco",est:"ruta",m:320,h:"14:50",prog:55,city:"cdmx"),
  Pedido(id:"CGO-2609",cl:"Daniela Flores",orig:"Café Jarocho ×4",dest:"Roma Sur",est:"ok",m:180,h:"12:40",prog:100,city:"cdmx"),
  Pedido(id:"CGO-2610",cl:"Alejandro Ruiz",orig:"Tacos Orinoco ×15",dest:"Santa Fe",est:"ruta",m:285,h:"13:58",prog:40,city:"cdmx"),
  Pedido(id:"CGO-2611",cl:"Patricia Luna",orig:"Churrería El Moro",dest:"Del Valle",est:"prep",m:210,h:"15:10",prog:20,city:"cdmx"),
  Pedido(id:"CGO-2612",cl:"Fernando Díaz",orig:"Ozempic 1mg",dest:"Centro Tula",est:"ok",m:2470,h:"09:30",prog:100,city:"hidalgo"),
];

final List<Ruta> rutas = [
  Ruta(nom:"Tulancingo → CDMX",dist:"180km",t:"2h30m",est:"activa",paq:3,c:AppTheme.ac),
  Ruta(nom:"CDMX → Tulancingo",dist:"180km",t:"2h45m",est:"prog",paq:2,c:AppTheme.pu),
  Ruta(nom:"Tulancingo Local",dist:"15km",t:"25m",est:"activa",paq:5,c:AppTheme.gr),
  Ruta(nom:"CDMX Local",dist:"22km",t:"40m",est:"activa",paq:4,c:AppTheme.cy),
  Ruta(nom:"Pachuca → Tulancingo",dist:"48km",t:"40m",est:"activa",paq:2,c:AppTheme.or),
  Ruta(nom:"CDMX → Pachuca",dist:"92km",t:"1h20m",est:"prog",paq:1,c:AppTheme.pk),
];

final List<Notif> notifs = [
  Notif(t:"🚀 Pedido CGO-2608 en camino",d:"José recibe tacos en ~15min",time:"3 min"),
  Notif(t:"✅ Entrega CGO-2603",d:"Ana confirmó recepción",time:"18 min"),
  Notif(t:"💊 Stock bajo: Ozempic",d:"Solo 8 unidades",time:"42 min",read:true),
  Notif(t:"🪐 +245 pts Saturnos",d:"Fernando ganó cashback",time:"1 hr",read:true),
];

final List<Addr> addrs = [
  Addr(l:"🏠 Casa",a:"Av. Juárez 142, Centro, Tulancingo",main:true),
  Addr(l:"🏪 Farmacia Madrid",a:"Portal Hidalgo 12, Centro, Tulancingo"),
  Addr(l:"📦 Bodega CDMX",a:"Insurgentes Sur 1820, Col. Florida, CDMX"),
];

final List<PayMethod> pays = [
  PayMethod(l:"💳 Visa ****4521",main:true),
  PayMethod(l:"💳 MC ****8837"),
  PayMethod(l:"💵 Efectivo al entregar"),
  PayMethod(l:"🪐 Puntos Saturnos (2,450)"),
];

final List<OrderHist> orderHist = [
  OrderHist(id:"CGO-2590",dt:"04 Feb",items:["Barbacoa ×2","Consomé ×2"],tot:380,from:"Mamá Chela"),
  OrderHist(id:"CGO-2585",dt:"03 Feb",items:["Omeprazol","Paracetamol"],tot:52,from:"Farmacias Madrid"),
  OrderHist(id:"CGO-2578",dt:"02 Feb",items:["Tres Leches","Churros ×2"],tot:205,from:"Dulce María"),
  OrderHist(id:"CGO-2571",dt:"01 Feb",items:["Tacos Orinoco ×10"],tot:250,from:"Tacos Orinoco"),
  OrderHist(id:"CGO-2563",dt:"31 Ene",items:["Ozempic 1mg"],tot:2470,from:"Farmacias Madrid"),
];




void main() => runApp(const CargoGoApp());

class CargoGoApp extends StatelessWidget {
  const CargoGoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Cargo-GO',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: AppTheme.bg),
    home: const SplashScreen(),
  );
}

// ═══ SPLASH SCREEN ═══
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashState();
}
class _SplashState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeIn;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.easeOut)));
    _scale = Tween<double>(begin: 0.8, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.easeOutBack)));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ));
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF0A1628), Color(0xFF060B18), Color(0xFF0D0B20)])),
        child: Center(child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Opacity(opacity: _fadeIn.value, child: Transform.scale(scale: _scale.value,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Image.asset('assets/images/logo.png', width: 280),
              const SizedBox(height: 30),
              SizedBox(width: 40, height: 40, child: CircularProgressIndicator(
                strokeWidth: 2, color: AppTheme.ac.withOpacity(_fadeIn.value))),
            ]))),
        )),
      ),
    );
  }
}

// ═══ LOGIN ═══
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginState();
}
class _LoginState extends State<LoginScreen> {
  int step = 0; // 0=login, 1=code
  String phone = '';
  List<String> code = ['','','','','',''];
  bool loading = false;

  void _sendCode() {
    if (phone.length < 10) return;
    setState(() => loading = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() { loading = false; step = 1; });
    });
  }

  void _verify() {
    setState(() => loading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainApp()));
    });
  }

  void _goMain() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainApp()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A1628), Color(0xFF060B18), Color(0xFF0D0B20)])),
        child: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16), child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 24),
          // ═══ LOGO CARGO-GO (imagen real) ═══
          Transform.scale(scale: 1.4, child: Image.asset('assets/images/logo.png', width: double.infinity, fit: BoxFit.contain)),
          const SizedBox(height: 40),

          if (step == 0) ...[
            // ═══ INICIAR SESION ═══
            const Align(alignment: Alignment.centerLeft, child: Text('Iniciar Sesion', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white))),
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerLeft, child: Text('Numero de telefono', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFFFFA502)))),
            const SizedBox(height: 10),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(color: const Color(0xFF111D33), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1C2D4A))),
                child: const Text('+52', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              const SizedBox(width: 10),
              Expanded(child: TextField(
                onChanged: (v) => setState(() => phone = v.replaceAll(RegExp(r'\D'), '')),
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 1),
                decoration: InputDecoration(
                  hintText: '10 digitos', hintStyle: const TextStyle(color: Color(0xFF506080), fontSize: 14),
                  filled: true, fillColor: const Color(0xFF111D33),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1C2D4A))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1C2D4A))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFA502))),
                ),
              )),
            ]),
            const SizedBox(height: 20),
            // Enviar Codigo - amarillo
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: loading ? null : _sendCode,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107), foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
              child: Text(loading ? 'Enviando...' : 'Enviar Codigo', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            )),
            const SizedBox(height: 20),
            const Text('o continua con', style: TextStyle(fontSize: 12, color: Color(0xFF506080))),
            const SizedBox(height: 14),
            // Facebook - azul
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Text('f', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'serif')),
              label: const Text('Continuar con Facebook', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1877F2), foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
            )),
            const SizedBox(height: 10),
            // Instagram - blanco
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Text('ig', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFFE4405F))),
              label: const Text('Continuar con Instagram', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.black87, backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), side: BorderSide.none),
            )),
            const SizedBox(height: 10),
            // Entrar como invitado - outlined
            SizedBox(width: double.infinity, child: OutlinedButton(
              onPressed: _goMain,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), side: const BorderSide(color: Color(0xFF1C2D4A))),
              child: const Text('Entrar como invitado', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            )),
            const SizedBox(height: 20),
            const Text('Al continuar, aceptas nuestros Términos y Condiciones', style: TextStyle(fontSize: 10, color: Color(0xFF506080))),
          ],

          if (step == 1) ...[
            Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: () => setState(() => step = 0), icon: const Icon(Icons.arrow_back, size: 14, color: Color(0xFF8899B4)), label: const Text('Volver', style: TextStyle(color: Color(0xFF8899B4), fontSize: 11)))),
            const SizedBox(height: 8),
            const Align(alignment: Alignment.centerLeft, child: Text('Código de verificación', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white))),
            const SizedBox(height: 4),
            Text('Enviado a +52 $phone', style: const TextStyle(fontSize: 12, color: Color(0xFF8899B4))),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(6, (i) => Container(width: 44, height: 52, margin: const EdgeInsets.symmetric(horizontal: 3),
              child: TextField(onChanged: (v) { setState(() => code[i] = v); if (v.isNotEmpty && i < 5) FocusScope.of(context).nextFocus(); if (i == 5 && v.isNotEmpty) _verify(); },
                maxLength: 1, textAlign: TextAlign.center, keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                decoration: InputDecoration(counterText: '', filled: true, fillColor: const Color(0xFF111D33),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: code[i].isNotEmpty ? const Color(0xFFFFA502) : const Color(0xFF1C2D4A), width: 2)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: code[i].isNotEmpty ? const Color(0xFFFFA502) : const Color(0xFF1C2D4A), width: 2)),
                ))))),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: loading ? null : _verify,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D68F), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
              child: Text(loading ? 'Verificando...' : 'Verificar', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            )),
          ],

          const SizedBox(height: 16),
        ]))),
      )),
    );
  }
}

// ═══ MAIN APP ═══
class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override State<MainApp> createState() => _MainAppState();
}
class _MainAppState extends State<MainApp> {
  int _tab = 0;
  String? _menuScreen; // mama, dulce, farmacia
  final List<CartItem> _cart = [];
  final Set<String> _favs = {'h01','h02','h03'};
  int _addrIdx = 0, _payIdx = 0;
  String _pedFilter = 'all', _negCity = 'hidalgo', _negTipo = 'all';
  String _negSearch = '';

  // ═══ API STATE ═══
  bool _online = false;
  bool _onlineRep = false; // Repartidores API
  bool _loadingApi = false;
  Map<String, dynamic> _apiStats = {};
  List<Map<String, dynamic>> _apiNegocios = [];
  List<Map<String, dynamic>> _apiFarmProductos = [];
  List<Map<String, dynamic>> _apiOfertas = [];
  List<Map<String, dynamic>> _apiPedidos = [];
  List<Map<String, dynamic>> _apiHistorial = [];
  List<Map<String, dynamic>> _apiEntregas = []; // Repartidores API
  Map<String, dynamic> _apiPedidosStats = {};

  // ═══ GOOGLE MAPS ═══
  GoogleMapController? _mapController;
  LatLng _mapCenter = const LatLng(20.0833, -98.3833); // Tulancingo default
  final Set<Marker> _markers = {};
  Position? _currentPos;
  bool _mapReady = false;
  String _trackFolio = '';
  bool _showFullMap = false;
  Map<String, dynamic>? _selectedMapPlace;
  String _mapFilter = 'all';
  bool _navModeCar = true;
  bool _avoidTolls = false;

  // ═══ NOTIFICACIONES ═══
  final List<Notif> _notifs = [
    Notif(t: 'Pedido CGO-2601 en ruta', d: 'Tu pedido salió de Farmacias Madrid', time: 'Hace 5 min'),
    Notif(t: 'Oferta Farmacia', d: '-35% en medicamentos genéricos hoy', time: 'Hace 30 min'),
    Notif(t: 'Nuevo negocio', d: 'Tacos Don Pepe se unió a Cargo-GO', time: 'Hace 1h'),
  ];
  int get _unreadNotifs => _notifs.where((n) => !n.read).length;

  @override
  void initState() {
    super.initState();
    _loadCache(); // 8. Cargar cache al iniciar
  }

  // ═══ 8. CACHE OFFLINE ═══
  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('api_cache');
      if (cached != null) {
        final data = json.decode(cached) as Map<String, dynamic>;
        if (!mounted) return;
        setState(() {
          _apiStats = (data['stats'] as Map<String, dynamic>?) ?? {};
          _apiNegocios = List<Map<String, dynamic>>.from(data['negocios'] ?? []);
          _apiFarmProductos = List<Map<String, dynamic>>.from(data['productos'] ?? []);
          _apiOfertas = List<Map<String, dynamic>>.from(data['ofertas'] ?? []);
          _apiHistorial = List<Map<String, dynamic>>.from(data['historial'] ?? []);
          _apiEntregas = List<Map<String, dynamic>>.from(data['entregas'] ?? []);
          _apiPedidosStats = (data['pedidos_stats'] as Map<String, dynamic>?) ?? {};
        });
        debugPrint('[CGO] Cache loaded');
      }
    } catch (e) { debugPrint('[CGO] Cache load error: $e'); }
  }

  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_cache', json.encode({
        'stats': _apiStats, 'negocios': _apiNegocios,
        'productos': _apiFarmProductos, 'ofertas': _apiOfertas,
        'historial': _apiHistorial, 'entregas': _apiEntregas,
        'pedidos_stats': _apiPedidosStats,
      }));
      debugPrint('[CGO] Cache saved');
    } catch (e) { debugPrint('[CGO] Cache save error: $e'); }
  }

  Future<void> _loadApiData() async {
    try {
      if (!mounted) return;
      setState(() => _loadingApi = true);

      // Check ambas APIs en paralelo
      final services = await ApiService.checkAllServices();
      if (!mounted) return;
      setState(() {
        _online = services['cargo_go'] ?? false;
        _onlineRep = services['repartidores'] ?? false;
      });

      if (_online || _onlineRep) {
        // Cargar datos en paralelo de ambas APIs
        final futures = await Future.wait([
          _online ? ApiService.getStats() : Future.value(null),
          _online ? ApiService.getNegocios() : Future.value(<Map<String, dynamic>>[]),
          _online ? ApiService.getFarmaciaProductos(limite: 100) : Future.value(<Map<String, dynamic>>[]),
          _online ? ApiService.getOfertas() : Future.value(<Map<String, dynamic>>[]),
          _online ? ApiService.getHistorial() : Future.value(<Map<String, dynamic>>[]),
          _onlineRep ? ApiService.getEntregas() : Future.value(<Map<String, dynamic>>[]),
          _online ? ApiService.getPedidosStats() : Future.value(null),
          _online ? ApiService.getPedidos() : Future.value(<Map<String, dynamic>>[]),
        ]);

        if (!mounted) return;
        setState(() {
          _apiStats = (futures[0] as Map<String, dynamic>?) ?? _apiStats;
          _apiNegocios = futures[1] as List<Map<String, dynamic>>;
          _apiFarmProductos = futures[2] as List<Map<String, dynamic>>;
          _apiOfertas = futures[3] as List<Map<String, dynamic>>;
          _apiHistorial = futures[4] as List<Map<String, dynamic>>;
          _apiEntregas = futures[5] as List<Map<String, dynamic>>;
          _apiPedidosStats = (futures[6] as Map<String, dynamic>?) ?? _apiPedidosStats;
          _apiPedidos = futures[7] as List<Map<String, dynamic>>;
          _loadingApi = false;
        });

        // Actualizar marcadores del mapa
        _updateMapMarkers();
        _saveCache();
      } else {
        if (!mounted) return;
        setState(() => _loadingApi = false);
      }
    } catch (e) {
      debugPrint('[CGO] Error loading API: $e');
      if (!mounted) return;
      setState(() { _online = false; _onlineRep = false; _loadingApi = false; });
    }
  }

  // ═══ GPS LOCATION ═══
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        debugPrint('[GPS] Permiso denegado');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      setState(() {
        _currentPos = pos;
        _mapCenter = LatLng(pos.latitude, pos.longitude);
        _markers.add(Marker(
          markerId: const MarkerId('mi_ubicacion'),
          position: LatLng(pos.latitude, pos.longitude),
          infoWindow: const InfoWindow(title: 'Mi Ubicación'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ));
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(_mapCenter));
    } catch (e) {
      debugPrint('[GPS] Error: $e');
    }
  }

  // ═══ NEGOCIOS MAP DATA (con coordenadas reales) ═══
  static final List<Map<String, dynamic>> _mapPlaces = [
    {'id': 'farm', 'nom': 'Farmacias Madrid', 'dir': 'Av. Juárez 123, Centro, Tulancingo', 'tipo': 'farmacia', 'e': '💊', 'lat': 20.0844, 'lng': -98.3815, 'r': 5.0, 'tel': '+527751234567', 'h': 'Lun-Sáb 8:00-21:00', 'dist': '0.5 km', 'tiempo': '3 min'},
    {'id': 'rest', 'nom': 'El Restaurante de mi Mamá', 'dir': 'Calle Hidalgo 45, Centro, Tulancingo', 'tipo': 'comida', 'e': '🍲', 'lat': 20.0830, 'lng': -98.3790, 'r': 4.9, 'tel': '+527751234568', 'h': 'Lun-Dom 8:00-20:00', 'dist': '0.8 km', 'tiempo': '5 min'},
    {'id': 'regalo', 'nom': 'Regalos Sorpresa de mi Hermana', 'dir': 'Blvd. Felipe Ángeles 78, Tulancingo', 'tipo': 'regalos', 'e': '🎁', 'lat': 20.0860, 'lng': -98.3850, 'r': 4.8, 'tel': '+527751234569', 'h': 'Lun-Sáb 10:00-19:00', 'dist': '1.2 km', 'tiempo': '8 min'},
    {'id': 'hq', 'nom': 'Cargo-GO HQ', 'dir': 'Centro, Tulancingo, Hidalgo', 'tipo': 'oficina', 'e': '📦', 'lat': 20.0833, 'lng': -98.3833, 'r': 5.0, 'tel': '+527751234560', 'h': '24/7', 'dist': '0 km', 'tiempo': '0 min'},
    {'id': 'cdmx', 'nom': 'Hub CDMX', 'dir': 'Col. Centro, Ciudad de México', 'tipo': 'oficina', 'e': '🏙️', 'lat': 19.4326, 'lng': -99.1332, 'r': 4.7, 'tel': '+525512345678', 'h': 'Lun-Vie 7:00-22:00', 'dist': '180 km', 'tiempo': '2h 30min'},
    {'id': 'costco_sat', 'nom': 'Costco Satélite', 'dir': 'Blvd. Manuel Ávila Camacho, Satélite', 'tipo': 'super', 'e': '🛒', 'lat': 19.5098, 'lng': -99.2338, 'r': 4.7, 'tel': '+525598765432', 'h': 'Lun-Dom 9:00-21:00', 'dist': '165 km', 'tiempo': '2h 15min'},
    {'id': 'costco_coy', 'nom': 'Costco Coyoacán', 'dir': 'Av. División del Norte, Coyoacán', 'tipo': 'super', 'e': '🛒', 'lat': 19.3437, 'lng': -99.1574, 'r': 4.6, 'tel': '+525598765433', 'h': 'Lun-Dom 9:00-21:00', 'dist': '195 km', 'tiempo': '2h 45min'},
  ];

  // ═══ MAP MARKERS ═══
  void _updateMapMarkers() {
    _markers.clear();
    final places = _mapFilter == 'all' ? _mapPlaces :
      _mapPlaces.where((p) => p['tipo'] == _mapFilter).toList();

    for (final p in places) {
      final lat = p['lat'] as double;
      final lng = p['lng'] as double;
      double hue;
      switch (p['tipo']) {
        case 'farmacia': hue = BitmapDescriptor.hueGreen; break;
        case 'comida': hue = BitmapDescriptor.hueOrange; break;
        case 'super': hue = BitmapDescriptor.hueBlue; break;
        case 'regalos': hue = BitmapDescriptor.hueRose; break;
        case 'oficina': hue = BitmapDescriptor.hueViolet; break;
        default: hue = BitmapDescriptor.hueRed;
      }
      _markers.add(Marker(
        markerId: MarkerId(p['id']),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: p['nom'], snippet: p['dir']),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        onTap: () => setState(() => _selectedMapPlace = p),
      ));
    }

    // Entregas en ruta (de API real)
    for (int i = 0; i < _apiEntregas.length && i < 20; i++) {
      final e = _apiEntregas[i];
      final lat = e['lat'] as double?;
      final lng = e['lng'] as double?;
      if (lat != null && lng != null) {
        _markers.add(Marker(
          markerId: MarkerId('entrega_$i'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: 'Entrega #${e['id'] ?? i}', snippet: e['estado'] ?? ''),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          onTap: () => setState(() => _selectedMapPlace = {
            'nom': 'Entrega #${e['id']}', 'dir': e['direccion_destino'] ?? '', 'e': '📦',
            'lat': lat, 'lng': lng, 'tipo': 'entrega', 'estado': e['estado'],
          }),
        ));
      }
    }

    // Mi ubicación
    if (_currentPos != null) {
      _markers.add(Marker(
        markerId: const MarkerId('mi_ubicacion'),
        position: LatLng(_currentPos!.latitude, _currentPos!.longitude),
        infoWindow: const InfoWindow(title: 'Mi Ubicación'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }
  }

  // ═══ TRACKING ═══
  Future<void> _rastrearPedido(String folio) async {
    if (folio.isEmpty) return;
    final result = await ApiService.rastrear(folio);
    if (result != null && !result.containsKey('error') && mounted) {
      final estado = result['estado'] ?? 'desconocido';
      final lat = result['lat'] as double?;
      final lng = result['lng'] as double?;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('📦 $folio: $estado', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.ac,
      ));
      if (lat != null && lng != null) {
        setState(() {
          _markers.add(Marker(
            markerId: MarkerId('track_$folio'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: folio, snippet: estado),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ));
        });
        _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No se encontró el pedido', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ═══ OPEN NAVIGATION ═══
  Future<void> _openNavigation(double lat, double lng, String label) async {
    final uri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    final webUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  // ═══ TOP BAR (aparece en todas las pantallas) ═══
  Widget _topBar() => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(children: [
      // Perfil + título + iconos
      Row(children: [
        GestureDetector(onTap: () => setState(() => _tab = 4),
          child: Container(width: 40, height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.cd, border: Border.all(color: AppTheme.bd)),
            child: const Icon(Icons.person, size: 22, color: AppTheme.tm))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('¡Listo para entregar!', style: TextStyle(fontSize: 11, color: AppTheme.tm)),
          const Text('Cargo-GO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
        ])),
        GestureDetector(onTap: _loadApiData,
          child: Container(width: 36, height: 36, decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(10)),
            child: Stack(children: [
              Center(child: Icon(_online || _onlineRep ? Icons.cloud_done : Icons.cloud_off, size: 18,
                color: _online && _onlineRep ? AppTheme.gr : _online || _onlineRep ? AppTheme.or : AppTheme.rd)),
              if (_loadingApi) const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.ac))),
            ]))),
        const SizedBox(width: 8),
        GestureDetector(onTap: _showNotifs,
          child: Container(width: 36, height: 36, decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(10)),
            child: Stack(children: [
              const Center(child: Icon(Icons.notifications_outlined, size: 18, color: AppTheme.tm)),
              if (_unreadNotifs > 0) Positioned(right: 4, top: 4, child: Container(width: 8, height: 8,
                decoration: const BoxDecoration(color: AppTheme.ac, shape: BoxShape.circle))),
            ]))),
      ]),
      const SizedBox(height: 12),
      // Buscador neón
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00B4FF), width: 1.2),
          boxShadow: [BoxShadow(color: const Color(0xFF00B4FF).withOpacity(0.15), blurRadius: 8, spreadRadius: 0)],
        ),
        child: Row(children: [
          const Icon(Icons.search, size: 20, color: Color(0xFFFFD600)),
          const SizedBox(width: 10),
          const Expanded(child: Text('Buscar...', style: TextStyle(fontSize: 14, color: Color(0xFF00B4FF)))),
          Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFF00B4FF).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.tune, size: 16, color: Color(0xFF00B4FF))),
        ]),
      ),
    ]),
  );

  void _showNotifs() {
    showModalBottomSheet(context: context, backgroundColor: AppTheme.sf,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Notificaciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx)),
          TextButton(onPressed: () { setState(() { for (var n in _notifs) n.read = true; }); Navigator.pop(context); },
            child: const Text('Marcar leídas', style: TextStyle(fontSize: 10, color: AppTheme.ac))),
        ]),
        const SizedBox(height: 8),
        ..._notifs.map((n) => Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: n.read ? AppTheme.cd : AppTheme.ac.withOpacity(0.06), borderRadius: BorderRadius.circular(10),
            border: Border.all(color: n.read ? AppTheme.bd : AppTheme.ac.withOpacity(0.2))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              if (!n.read) Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 6), decoration: const BoxDecoration(color: AppTheme.ac, shape: BoxShape.circle)),
              Expanded(child: Text(n.t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tx))),
              Text(n.time, style: const TextStyle(fontSize: 8, color: AppTheme.td)),
            ]),
            Text(n.d, style: const TextStyle(fontSize: 9, color: AppTheme.tm)),
          ]))),
      ])));
  }

  int get _cartQty => _cart.fold(0, (s, x) => s + x.q);
  int get _cartTotal => _cart.fold(0, (s, x) => s + x.price * x.q);

  void _addToCart(String name, int price, String from, {int? oferta}) {
    setState(() {
      final idx = _cart.indexWhere((c) => c.n == name && c.from == from);
      if (idx >= 0) { _cart[idx].q++; } else { _cart.add(CartItem(n: name, from: from, p: price, oferta: oferta)); }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('✓ $name agregado', style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: AppTheme.gr, duration: const Duration(milliseconds: 1200),
      behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _openCart() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppTheme.sf,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) => _buildCart(ctx, setS)));
  }

  Widget _buildCart(BuildContext ctx, StateSetter setS) {
    final groups = <String, List<CartItem>>{};
    for (var it in _cart) { groups.putIfAbsent(it.from, () => []).add(it); }
    final envios = groups.keys.length * 35;
    final pts = (_cartTotal * 0.09).round();

    return DraggableScrollableSheet(initialChildSize: 0.85, maxChildSize: 0.95, minChildSize: 0.5,
      builder: (_, sc) => Container(padding: const EdgeInsets.all(16), child: ListView(controller: sc, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('🛒 Carrito ($_cartQty)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx)),
          IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: AppTheme.tm)),
        ]),
        if (_cart.isEmpty) Padding(padding: const EdgeInsets.all(40), child: Text('Tu carrito está vacío', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.td))),
        ...groups.entries.map((e) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 12, bottom: 6), child: Text('📍 ${e.key}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.ac))),
          ...e.value.map((it) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(it.n, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.tx)),
              Text('\$${it.price}', style: TextStyle(fontSize: 9, color: AppTheme.tm)),
            ])),
            IconButton(icon: const Icon(Icons.remove, size: 16), color: AppTheme.tm, onPressed: () { setS(() { setState(() { if (it.q > 1) it.q--; else _cart.remove(it); }); }); }),
            Text('${it.q}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.tx)),
            IconButton(icon: const Icon(Icons.add, size: 16), color: AppTheme.tm, onPressed: () { setS(() { setState(() => it.q++); }); }),
            SizedBox(width: 50, child: Text('\$${(it.price * it.q)}', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.gr, fontFamily: 'monospace'))),
            IconButton(icon: const Icon(Icons.close, size: 14), color: AppTheme.rd, onPressed: () { setS(() { setState(() => _cart.remove(it)); }); }),
          ]))),
          Text('+ \$35 envío', style: TextStyle(fontSize: 9, color: AppTheme.td)),
        ])),
        if (_cart.isNotEmpty) ...[
          const SizedBox(height: 12),
          // Address
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.bd)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('📍 Entregar en:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.tx)),
              const SizedBox(height: 6),
              ...List.generate(addrs.length, (i) => GestureDetector(onTap: () => setS(() => setState(() => _addrIdx = i)),
                child: Container(margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: _addrIdx == i ? AppTheme.ac.withOpacity(0.5) : Colors.transparent),
                    color: _addrIdx == i ? AppTheme.ac.withOpacity(0.06) : Colors.transparent),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(addrs[i].l, style: TextStyle(fontSize: 10, fontWeight: _addrIdx == i ? FontWeight.w700 : FontWeight.w400, color: _addrIdx == i ? AppTheme.ac : AppTheme.tm)),
                    Text(addrs[i].a, style: TextStyle(fontSize: 8, color: AppTheme.td)),
                  ])))),
            ])),
          const SizedBox(height: 8),
          // Payment
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.bd)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💳 Pagar con:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.tx)),
              const SizedBox(height: 6),
              ...List.generate(pays.length, (i) => GestureDetector(onTap: () => setS(() => setState(() => _payIdx = i)),
                child: Container(margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: _payIdx == i ? AppTheme.gr.withOpacity(0.5) : Colors.transparent),
                    color: _payIdx == i ? AppTheme.gr.withOpacity(0.06) : Colors.transparent),
                  child: Row(children: [
                    Icon(_payIdx == i ? Icons.radio_button_checked : Icons.radio_button_off, size: 14, color: _payIdx == i ? AppTheme.gr : AppTheme.td),
                    const SizedBox(width: 6),
                    Text(pays[i].l, style: TextStyle(fontSize: 10, color: _payIdx == i ? AppTheme.gr : AppTheme.tm)),
                  ])))),
            ])),
          const SizedBox(height: 16),
          _row('Subtotal', '\$$_cartTotal'),
          _row('Envíos (${groups.keys.length})', '\$$envios'),
          _row('🪐 Saturnos', '+$pts pts', c: AppTheme.tl),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.tx)),
            Text('\$${_cartTotal + envios}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.tx, fontFamily: 'monospace')),
          ]),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () { Navigator.pop(ctx); setState(() => _cart.clear()); _showCheckout(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gr, padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('🚀 Confirmar Pedido', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
          )),
          const SizedBox(height: 8),
          Center(child: TextButton(onPressed: () { setS(() { setState(() => _cart.clear()); }); Navigator.pop(ctx); }, child: Text('Vaciar carrito', style: TextStyle(color: AppTheme.rd, fontSize: 10)))),
        ],
      ])));
  }

  Widget _row(String l, String r, {Color c = AppTheme.tm}) => Padding(padding: const EdgeInsets.only(bottom: 2),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontSize: 10, color: c)), Text(r, style: TextStyle(fontSize: 10, color: c))]));

  void _showCheckout() async {
    String folio = '';
    // Send order to API when online
    if (_online) {
      final groups = <String, List<CartItem>>{};
      for (var it in _cart) { groups.putIfAbsent(it.from, () => []).add(it); }
      final envios = groups.keys.length * 35;
      final addr = addrs[_addrIdx];

      final res = await ApiService.crearPedidoFarmacia(
        clienteNombre: 'Chule',
        clienteTelefono: '7711234567',
        clienteDireccion: addr.a,
        clienteCp: '43600',
        subtotal: _cartTotal.toDouble(),
        costoEnvio: envios.toDouble(),
        total: (_cartTotal + envios).toDouble(),
        items: _cart.map((c) => {
          'producto_id': 0,
          'cantidad': c.q,
          'precio': c.price.toDouble(),
        }).toList(),
      );
      folio = res?['folio'] ?? '';
    }

    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: AppTheme.sf, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('🚀', style: TextStyle(fontSize: 50)),
        const SizedBox(height: 12),
        const Text('¡Pedido Confirmado!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.tx)),
        const SizedBox(height: 8),
        if (folio.isNotEmpty) Text('Folio: $folio', style: TextStyle(color: AppTheme.ac, fontSize: 13, fontWeight: FontWeight.w700)),
        Text(folio.isNotEmpty ? 'Enviado a la API' : 'Tu pedido está siendo preparado', style: TextStyle(color: AppTheme.tm, fontSize: 11)),
        const SizedBox(height: 12),
        Text('Tiempo estimado: 25-45 min', style: TextStyle(color: AppTheme.tm, fontSize: 10)),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: () { Navigator.pop(context); setState(() => _tab = 0); _loadApiData(); },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.ac, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('← Volver al inicio', style: TextStyle(color: Colors.white)),
        )),
      ])));
  }

  @override
  Widget build(BuildContext context) {
    // Full screen map view
    if (_showFullMap) return _fullMapScreen();
    return Scaffold(
      body: SafeArea(child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _menuScreen != null ? _buildMenuScreen() : _buildScreen(),
      )),
      bottomNavigationBar: _menuScreen != null ? null : _buildNav(),
      floatingActionButton: _cartQty > 0 ? FloatingActionButton.extended(
        onPressed: _openCart, backgroundColor: AppTheme.gr,
        icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
        label: Text('$_cartQty · \$$_cartTotal', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
      ) : null,
    );
  }

  Widget _buildNav() => Container(
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
    decoration: BoxDecoration(
      color: AppTheme.cd,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppTheme.bd, width: 0.5),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, -4)),
        BoxShadow(color: AppTheme.ac.withOpacity(0.08), blurRadius: 30, spreadRadius: -5),
      ],
    ),
    child: Row(children: [
      _navBtn(0, Icons.home_filled, 'Inicio'),
      _navBtn(1, Icons.store_rounded, 'Negocios'),
      // Botón central flotante con rayo
      Expanded(child: GestureDetector(
        onTap: () => setState(() => _tab = 2),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Transform.translate(offset: const Offset(0, -22), child: Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF2D7AFF), Color(0xFF00B4FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: Border.all(color: AppTheme.cd, width: 4),
              boxShadow: [
                BoxShadow(color: const Color(0xFF2D7AFF).withOpacity(0.5), blurRadius: 16, spreadRadius: 2, offset: const Offset(0, 4)),
                BoxShadow(color: const Color(0xFF00B4FF).withOpacity(0.3), blurRadius: 24, spreadRadius: -2),
              ],
            ),
            child: const Icon(Icons.bolt_rounded, size: 30, color: Colors.white),
          )),
          Transform.translate(offset: const Offset(0, -14), child: Text('Pedidos', style: TextStyle(fontSize: 9, color: _tab == 2 ? AppTheme.ac : AppTheme.td, fontWeight: _tab == 2 ? FontWeight.w700 : FontWeight.w400))),
        ]),
      )),
      _navBtn(3, Icons.local_shipping_rounded, 'Mudanzas'),
      _navBtn(4, Icons.person_outline_rounded, 'Perfil'),
    ]),
  );

  Widget _navBtn(int i, IconData ic, String l) {
    final bool active = _tab == i;
    return Expanded(child: InkWell(
      onTap: () => setState(() => _tab = i),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: active ? AppTheme.ac.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(ic, size: 22, color: active ? AppTheme.ac : AppTheme.td),
        ),
        const SizedBox(height: 3),
        Text(l, style: TextStyle(fontSize: 9, color: active ? AppTheme.ac : AppTheme.td, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
      ]))));
  }

  Widget _buildScreen() {
    Widget screen;
    switch (_tab) {
      case 0: screen = _dashScreen(); break;
      case 1: screen = _negScreen(); break;
      case 2: screen = _pedScreen(); break;
      case 3: screen = _mudScreen(); break;
      case 4: screen = _perfScreen(); break;
      default: screen = _dashScreen();
    }
    return KeyedSubtree(key: ValueKey(_tab), child: screen);
  }

  Widget _buildMenuScreen() {
    final Map<String, List<MenuItem>> menu;
    final String title, from;
    final Color color;
    if (_menuScreen == 'mama') { menu = menuMama; title = '🍲 Mamá Chela'; from = 'Mamá Chela'; color = AppTheme.or; }
    else if (_menuScreen == 'dulce') { menu = menuDulce; title = '🧁 Dulce María'; from = 'Dulce María'; color = AppTheme.pk; }
    else { return _farmScreen(); }
    return _menuView(title, menu, color, from);
  }

  // ═══ FULL MAP SCREEN ═══
  Widget _fullMapScreen() {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        // ── Google Map (full screen) ──
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _mapCenter, zoom: 12),
          markers: _markers,
          onMapCreated: (controller) {
            _mapController = controller;
            _mapReady = true;
            controller.setMapStyle(_darkMapStyle);
            _getCurrentLocation();
            _updateMapMarkers();
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          onTap: (_) => setState(() => _selectedMapPlace = null),
        ),

        // ── Top overlay: Search bar + filters ──
        SafeArea(child: Column(children: [
          // Search bar like the screenshot
          Padding(padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.cd.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.bd, width: 0.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(children: [
                // Back button
                GestureDetector(
                  onTap: () => setState(() { _showFullMap = false; _selectedMapPlace = null; }),
                  child: Container(width: 32, height: 32, decoration: BoxDecoration(
                    color: AppTheme.ac.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back, size: 16, color: AppTheme.ac)),
                ),
                const SizedBox(width: 8),
                // Google pin icon
                const Icon(Icons.location_on, size: 18, color: Color(0xFF34A853)),
                const SizedBox(width: 8),
                // Search field
                Expanded(child: TextField(
                  style: const TextStyle(color: AppTheme.tx, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Buscar ubicación...', hintStyle: TextStyle(color: AppTheme.tm, fontSize: 13),
                    border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 10)),
                  onSubmitted: (v) {},
                )),
                // Mic icon
                Container(width: 32, height: 32, decoration: BoxDecoration(
                  color: AppTheme.ac.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.mic, size: 16, color: AppTheme.ac)),
                const SizedBox(width: 6),
                // Profile avatar
                GestureDetector(
                  onTap: () => setState(() { _showFullMap = false; _tab = 4; }),
                  child: Container(width: 32, height: 32, decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF2D7AFF), Color(0xFF00B4FF)])),
                    child: const Center(child: Text('J', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)))),
                ),
              ]),
            )),
          // Category filter pills
          const SizedBox(height: 8),
          SingleChildScrollView(scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              _mapFilterPill('all', '📍 Todos', true),
              _mapFilterPill('farmacia', '💊 Farmacia', false),
              _mapFilterPill('comida', '🍲 Comida', false),
              _mapFilterPill('super', '🛒 Super', false),
              _mapFilterPill('regalos', '🎁 Regalos', false),
              _mapFilterPill('oficina', '📦 Oficinas', false),
            ])),
        ])),

        // ── Floating location button ──
        Positioned(right: 14, bottom: _selectedMapPlace != null ? 340 : 90,
          child: Column(children: [
            GestureDetector(onTap: _getCurrentLocation,
              child: Container(width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.cd.withOpacity(0.95), shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.bd, width: 0.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]),
                child: const Icon(Icons.my_location, size: 20, color: AppTheme.ac))),
            const SizedBox(height: 8),
            GestureDetector(onTap: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
              child: Container(width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.cd.withOpacity(0.95), shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.bd, width: 0.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]),
                child: const Icon(Icons.add, size: 20, color: AppTheme.tx))),
            const SizedBox(height: 8),
            GestureDetector(onTap: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
              child: Container(width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.cd.withOpacity(0.95), shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.bd, width: 0.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]),
                child: const Icon(Icons.remove, size: 20, color: AppTheme.tx))),
          ])),

        // ── Bottom Sheet: Business info + navigation ──
        if (_selectedMapPlace != null)
          Positioned(left: 0, right: 0, bottom: 0,
            child: _mapBottomSheet(_selectedMapPlace!)),
      ]),
    );
  }

  Widget _mapFilterPill(String tipo, String label, bool isAdd) {
    final active = _mapFilter == tipo;
    return Padding(padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () => setState(() { _mapFilter = tipo; _updateMapMarkers(); }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppTheme.ac : AppTheme.cd.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? AppTheme.ac : AppTheme.bd, width: 0.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6)],
          ),
          child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppTheme.tx)),
        )));
  }

  Widget _mapBottomSheet(Map<String, dynamic> place) {
    final lat = place['lat'] as double? ?? 0;
    final lng = place['lng'] as double? ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cd,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        border: Border.all(color: AppTheme.bd, width: 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Handle bar
        Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(color: AppTheme.bd, borderRadius: BorderRadius.circular(2)))),
        // Name + close
        Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(
            color: AppTheme.ac.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(place['e'] ?? '📍', style: const TextStyle(fontSize: 22)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(place['nom'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx)),
            Text(place['dir'] ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.tm)),
          ])),
          GestureDetector(
            onTap: () => setState(() => _selectedMapPlace = null),
            child: Container(width: 32, height: 32, decoration: BoxDecoration(
              color: AppTheme.bg, shape: BoxShape.circle, border: Border.all(color: AppTheme.bd)),
              child: const Icon(Icons.close, size: 16, color: AppTheme.tm))),
        ]),
        if (place['h'] != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.access_time, size: 12, color: AppTheme.tm),
            const SizedBox(width: 4),
            Text(place['h'], style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
            if (place['r'] != null) ...[
              const SizedBox(width: 12),
              Text('⭐ ${place['r']}', style: const TextStyle(fontSize: 10, color: AppTheme.or)),
            ],
          ]),
        ],
        const SizedBox(height: 14),
        // Car / Bike toggle
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _navModeCar = true),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _navModeCar ? AppTheme.ac : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _navModeCar ? AppTheme.ac : AppTheme.bd)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.directions_car, size: 16, color: _navModeCar ? Colors.white : AppTheme.tm),
                const SizedBox(width: 6),
                Text('Auto', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: _navModeCar ? Colors.white : AppTheme.tm)),
              ])))),
          const SizedBox(width: 8),
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _navModeCar = false),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: !_navModeCar ? AppTheme.ac : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: !_navModeCar ? AppTheme.ac : AppTheme.bd)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.two_wheeler, size: 16, color: !_navModeCar ? Colors.white : AppTheme.tm),
                const SizedBox(width: 6),
                Text('Moto', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: !_navModeCar ? Colors.white : AppTheme.tm)),
              ])))),
        ]),
        const SizedBox(height: 10),
        // Avoid options
        Row(children: [
          GestureDetector(
            onTap: () => setState(() => _avoidTolls = !_avoidTolls),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _avoidTolls ? AppTheme.ac.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _avoidTolls ? AppTheme.ac : AppTheme.bd)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (_avoidTolls) const Icon(Icons.check, size: 12, color: AppTheme.ac),
                if (_avoidTolls) const SizedBox(width: 4),
                Text('Evitar casetas', style: TextStyle(fontSize: 10, color: _avoidTolls ? AppTheme.ac : AppTheme.tm)),
              ]))),
          const SizedBox(width: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.transparent, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.bd)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check, size: 12, color: AppTheme.gr),
              const SizedBox(width: 4),
              const Text('Ruta más rápida', style: TextStyle(fontSize: 10, color: AppTheme.gr)),
            ])),
        ]),
        const SizedBox(height: 12),
        // Distance + Time
        Row(children: [
          Text(place['tiempo'] ?? '-- min', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.ac)),
          const SizedBox(width: 8),
          Text('(${place['dist'] ?? '-- km'})', style: const TextStyle(fontSize: 14, color: AppTheme.tm)),
        ]),
        const Text('Mejor ruta disponible', style: TextStyle(fontSize: 10, color: AppTheme.tm)),
        const SizedBox(height: 14),
        // Action buttons: Start, Call, Share, Bookmark
        Row(children: [
          // START button - blue
          Expanded(child: GestureDetector(
            onTap: () => _openNavigation(lat, lng, place['nom'] ?? ''),
            child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2D7AFF), Color(0xFF00B4FF)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: AppTheme.ac.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.navigation, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text('Iniciar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ])))),
          const SizedBox(width: 8),
          // CALL
          GestureDetector(
            onTap: () async {
              final tel = place['tel'] as String?;
              if (tel != null) {
                final uri = Uri.parse('tel:$tel');
                if (await canLaunchUrl(uri)) launchUrl(uri);
              }
            },
            child: Container(width: 44, height: 44, decoration: BoxDecoration(
              color: AppTheme.bg, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.bd)),
              child: const Icon(Icons.phone, size: 18, color: AppTheme.tm))),
          const SizedBox(width: 8),
          // SHARE
          GestureDetector(
            onTap: () {},
            child: Container(width: 44, height: 44, decoration: BoxDecoration(
              color: AppTheme.bg, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.bd)),
              child: const Icon(Icons.share, size: 18, color: AppTheme.tm))),
          const SizedBox(width: 8),
          // BOOKMARK
          GestureDetector(
            onTap: () {},
            child: Container(width: 44, height: 44, decoration: BoxDecoration(
              color: AppTheme.bg, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.bd)),
              child: const Icon(Icons.bookmark_border, size: 18, color: AppTheme.tm))),
        ]),
      ]),
    );
  }

  // ═══ DASHBOARD ═══
  Widget _dashScreen() {
    final allNegs = [...negHidalgo, ...negCdmx];
    final hasApiStats = _online && _apiStats.isNotEmpty;
    final sEntregas = hasApiStats ? '${_apiStats['envios_hoy'] ?? _apiEntregas.length}' : '${_apiEntregas.isNotEmpty ? _apiEntregas.length : 47}';
    final sIngresos = hasApiStats ? '\$${((_apiStats['ingresos_hoy'] ?? 0) / 1000).toStringAsFixed(1)}k' : '\$98.2k';
    final sProductos = hasApiStats ? '${_apiFarmProductos.isNotEmpty ? _apiFarmProductos.length : 77000}+' : '77K+';
    final sNegocios = hasApiStats ? '${_apiNegocios.isNotEmpty ? _apiNegocios.length : allNegs.length}' : '${allNegs.length}';
    final sMandados = hasApiStats ? '${_apiPedidosStats['mandados'] ?? _apiPedidos.length}' : '24';
    final sPaquetes = hasApiStats ? '${_apiStats['paquetes_hoy'] ?? 156}' : '156';
    final sMudanzas = hasApiStats ? '${_apiStats['mudanzas_hoy'] ?? 8}' : '8';

    // Entregas recientes: API real si hay, sino mock
    final bool useApiEntregas = _apiEntregas.isNotEmpty;

    return RefreshIndicator(onRefresh: _loadApiData, color: AppTheme.ac,
      child: ListView(padding: const EdgeInsets.all(14), children: [
      _topBar(),
      // ── API Status indicators ──
      if (_loadingApi) ...[
        Container(padding: const EdgeInsets.all(8), margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: AppTheme.ac.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.ac)),
            SizedBox(width: 8),
            Text('Conectando con servidores...', style: TextStyle(fontSize: 10, color: AppTheme.ac)),
          ])),
      ],
      if (_online || _onlineRep) ...[
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(color: AppTheme.gr.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.gr.withOpacity(0.2))),
          child: Row(children: [
            const Icon(Icons.cloud_done, size: 14, color: AppTheme.gr),
            const SizedBox(width: 6),
            Text('API Cargo-GO: ${_online ? "✓" : "✗"} · Repartidores: ${_onlineRep ? "✓" : "✗"}', style: const TextStyle(fontSize: 9, color: AppTheme.gr)),
            const Spacer(),
            Text('Datos en vivo', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: AppTheme.gr)),
          ])),
      ],
      // ── Servicios (cuadros grandes) ──
      Row(children: [
        _dashCard('📦', 'Pedidos\nCDMX - Hidalgo', sEntregas, Icons.arrow_outward, const Color(0xFF0D47A1), null, tabIdx: 2),
        const SizedBox(width: 10),
        _dashCard('🛒', 'Mandados\nLocal', sMandados, Icons.arrow_outward, AppTheme.cd, null, tabIdx: 1),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _dashCard('📮', 'Paquetería', sPaquetes, Icons.arrow_outward, AppTheme.cd, null, tabIdx: 2),
        const SizedBox(width: 10),
        _dashCard('🚚', 'Mini\nMudanzas', sMudanzas, Icons.arrow_outward, AppTheme.cd, null, tabIdx: 3),
      ]),
      const SizedBox(height: 16),
      // ── Stats entregas ──
      const Text('Resumen de Entregas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.tx)),
      const SizedBox(height: 8),
      Row(children: [
        _statCardBlue('Entregas Hoy', sEntregas, Icons.local_shipping),
        const SizedBox(width: 8),
        _statCard('Ingresos', sIngresos, Icons.trending_up, AppTheme.gr),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        _statCard('Productos', sProductos, Icons.medication, AppTheme.tl),
        const SizedBox(width: 8),
        _statCard('Negocios', sNegocios, Icons.store, AppTheme.or),
      ]),
      const SizedBox(height: 16),
      // ── Nuestros Negocios ──
      const Text('Nuestros Negocios', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.tx)),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () => setState(() => _menuScreen = 'farmacia'),
        child: Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('💊', style: TextStyle(fontSize: 24)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Farmacias Madrid', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 2),
              const Text('Medicamentos · Lun-Sáb 8:00-21:00', style: TextStyle(fontSize: 10, color: Colors.white70)),
            ])),
            Column(children: [
              const Text('⭐ 5.0', style: TextStyle(fontSize: 10, color: Colors.white70)),
              const SizedBox(height: 4),
              const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white70),
            ]),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      _negCard('🍲', 'El Restaurante de mi Mamá', 'Comida casera · Antojitos mexicanos', '⭐ 4.9', const Color(0xFFE65100), 'mama'),
      const SizedBox(height: 8),
      _negCard('🎁', 'Regalos Sorpresa de mi Hermana', 'Detalles · Regalos personalizados', '⭐ 4.8', const Color(0xFFC2185B), 'dulce'),
      // ── API Negocios del marketplace ──
      if (_apiNegocios.isNotEmpty) ...[
        const SizedBox(height: 8),
        ...(_apiNegocios.take(3).map((n) => Padding(padding: const EdgeInsets.only(bottom: 8),
          child: _negCard(
            n['tipo'] == 'farmacia' ? '💊' : n['tipo'] == 'comida' ? '🍲' : '🏪',
            n['nombre'] ?? 'Negocio',
            n['descripcion'] ?? '',
            '⭐ ${n['calificacion'] ?? 4.5}',
            AppTheme.tl,
            null,
          )))),
      ],
      const SizedBox(height: 16),
      // ── Entregas recientes (API real o mock) ──
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Entregas Recientes${useApiEntregas ? ' (API)' : ''}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.tx)),
        TextButton(onPressed: () => setState(() => _tab = 2), child: const Text('Ver todos', style: TextStyle(fontSize: 11, color: AppTheme.ac))),
      ]),
      if (useApiEntregas)
        ..._apiEntregas.take(5).map((e) {
          final idx = _apiEntregas.indexOf(e);
          return _apiEntregaCard(e, isFirst: idx == 0);
        })
      else
        ...pedidos.where((p) => p.est != 'ok').take(4).map((p) {
          final idx = pedidos.where((p) => p.est != 'ok').toList().indexOf(p);
          return idx == 0 ? _pedCardBlue(p) : _pedCard(p);
        }),
    ]));
  }

  // ═══ API ENTREGA CARD (real data) ═══
  Widget _apiEntregaCard(Map<String, dynamic> e, {bool isFirst = false}) {
    final estado = (e['estado'] ?? 'pendiente').toString();
    final ec = {'en_transito': AppTheme.ac, 'pendiente': AppTheme.or, 'completada': AppTheme.gr, 'cancelada': AppTheme.rd};
    final el = {'en_transito': 'En Ruta', 'pendiente': 'Pendiente', 'completada': 'Entregado', 'cancelada': 'Cancelado'};
    final ei = {'en_transito': Icons.local_shipping, 'pendiente': Icons.access_time, 'completada': Icons.check_circle, 'cancelada': Icons.cancel};
    final c = ec[estado] ?? AppTheme.tm;
    final ic = ei[estado] ?? Icons.help;
    final lb = el[estado] ?? estado;

    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isFirst ? null : Colors.transparent,
        gradient: isFirst ? const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)]) : null,
        borderRadius: BorderRadius.circular(20),
        border: isFirst ? null : Border.all(color: c.withOpacity(0.25), width: 1.2),
      ),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(
          color: isFirst ? Colors.white.withOpacity(0.2) : c.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(ic, size: 20, color: isFirst ? Colors.white : c)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Entrega #${e['id'] ?? ''}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isFirst ? Colors.white : AppTheme.tx)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: isFirst ? Colors.white.withOpacity(0.2) : c.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(lb, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: isFirst ? Colors.white : c))),
          ]),
          const SizedBox(height: 4),
          Text('${e['direccion_origen'] ?? 'Origen'} → ${e['direccion_destino'] ?? 'Destino'}',
            style: TextStyle(fontSize: 10, color: isFirst ? Colors.white70 : AppTheme.tm), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${e['cliente_nombre'] ?? ''} · ${e['fecha'] ?? ''}', style: TextStyle(fontSize: 9, color: isFirst ? Colors.white54 : AppTheme.td)),
            if (e['total'] != null) Text('\$${e['total']}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
              color: isFirst ? Colors.white : AppTheme.gr, fontFamily: 'monospace')),
          ]),
          // Botones de acción para entregas en_transito o pendiente
          if (estado == 'pendiente' || estado == 'en_transito') ...[
            const SizedBox(height: 6),
            Row(children: [
              if (estado == 'pendiente')
                _entregaAction('Iniciar', Icons.play_arrow, AppTheme.ac, () async {
                  final id = e['id'] as int?;
                  if (id != null) { await ApiService.iniciarEntrega(id); _loadApiData(); }
                }),
              if (estado == 'en_transito') ...[
                _entregaAction('Completar', Icons.check, AppTheme.gr, () async {
                  final id = e['id'] as int?;
                  if (id != null) { await ApiService.completarEntrega(id); _loadApiData(); }
                }),
                const SizedBox(width: 8),
                _entregaAction('Navegar', Icons.navigation, AppTheme.cy, () {
                  final lat = e['lat'] as double?;
                  final lng = e['lng'] as double?;
                  if (lat != null && lng != null) _openNavigation(lat, lng, 'Entrega #${e['id']}');
                }),
              ],
            ]),
          ],
        ])),
      ]));
  }

  Widget _entregaAction(String label, IconData icon, Color c, VoidCallback onTap) =>
    GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: c.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: c),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: c)),
      ])));

  Widget _dashCard(String emoji, String label, String value, IconData arrow, Color bgColor, String? menuKey, {int? tabIdx}) {
    final bool isBlue = bgColor == const Color(0xFF0D47A1);
    return Expanded(child: GestureDetector(
      onTap: () { if (tabIdx != null) { setState(() => _tab = tabIdx); } else if (menuKey != null) setState(() => _menuScreen = menuKey); },
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: isBlue ? null : Border.all(color: AppTheme.bd),
          gradient: isBlue ? const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            Container(width: 30, height: 30, decoration: BoxDecoration(
              color: isBlue ? Colors.white.withOpacity(0.2) : AppTheme.sf, borderRadius: BorderRadius.circular(8)),
              child: Icon(arrow, size: 16, color: isBlue ? Colors.white : AppTheme.tm)),
          ]),
          const Spacer(),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isBlue ? Colors.white70 : AppTheme.tm)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: isBlue ? Colors.white : AppTheme.tx)),
        ]),
      ),
    ));
  }

  Widget _negCard(String emoji, String title, String sub, String rating, Color c, String key) {
    final bool selected = _menuScreen == key;
    final Color bc = selected ? const Color(0xFF0D47A1) : c;
    return GestureDetector(
      onTap: () => setState(() => _menuScreen = key),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0D47A1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? const Color(0xFF0D47A1) : c.withOpacity(0.25), width: 1.2),
        ),
        child: Row(children: [
          Container(width: 48, height: 48,
            decoration: BoxDecoration(color: selected ? Colors.white.withOpacity(0.2) : c.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppTheme.tx)),
            const SizedBox(height: 2),
            Text(sub, style: TextStyle(fontSize: 10, color: selected ? Colors.white70 : AppTheme.tm)),
          ])),
          Column(children: [
            Text(rating, style: TextStyle(fontSize: 10, color: selected ? Colors.white70 : AppTheme.or)),
            const SizedBox(height: 4),
            Icon(Icons.arrow_forward_ios, size: 12, color: selected ? Colors.white70 : AppTheme.td),
          ]),
      ]),
    ),
  ); }

  Widget _statCardBlue(String label, String value, IconData ic) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
        child: Icon(ic, size: 20, color: Colors.white)),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'monospace')),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70)),
      ]),
    ]),
  ));

  Widget _statCard(String label, String value, IconData ic, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.bd, width: 1.2)),
    child: Row(children: [
      Container(width: 40, height: 40, decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(ic, size: 20, color: c)),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.tx, fontFamily: 'monospace')),
        Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.tm)),
      ]),
    ]),
  ));

  Widget _overviewItem(String emoji, String label, String value, Color c) => Column(children: [
    Text(emoji, style: const TextStyle(fontSize: 16)),
    Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.tm)),
    const SizedBox(height: 2),
    Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c)),
  ]);

  // ═══ NEGOCIOS ═══
  Widget _negScreen() {
    final all = _negCity == 'all' ? [...negHidalgo, ...negCdmx] : _negCity == 'hidalgo' ? negHidalgo : negCdmx;
    final filtered = all.where((n) {
      final mq = _negSearch.isEmpty || n.nom.toLowerCase().contains(_negSearch.toLowerCase()) || n.desc.toLowerCase().contains(_negSearch.toLowerCase());
      final mt = _negTipo == 'all' || n.tipo == _negTipo;
      return mq && mt;
    }).toList();
    // API negocios filtrados
    final apiFiltered = _apiNegocios.where((n) {
      final mq = _negSearch.isEmpty || (n['nombre'] ?? '').toString().toLowerCase().contains(_negSearch.toLowerCase());
      return mq;
    }).toList();
    final totalLocal = negHidalgo.length + negCdmx.length;
    final totalApi = _apiNegocios.length;
    final totalAll = totalLocal + totalApi;

    return RefreshIndicator(onRefresh: _loadApiData, color: AppTheme.ac,
      child: ListView(padding: const EdgeInsets.all(14), children: [
      _topBar(),
      // City filter - outlined rounded
      Row(children: [
        _cityBtn('all', '🗺️ Todos ($totalAll)'),
        _cityBtn('hidalgo', '🏔️ Hidalgo (${negHidalgo.length})'),
        _cityBtn('cdmx', '🏙️ CDMX (${negCdmx.length})'),
      ]),
      const SizedBox(height: 10),
      // Search - neon style
      TextField(onChanged: (v) => setState(() => _negSearch = v), style: const TextStyle(color: Color(0xFF00B4FF), fontSize: 12),
        decoration: InputDecoration(hintText: 'Buscar negocio...', hintStyle: const TextStyle(color: Color(0xFF00B4FF)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD600), size: 18),
          filled: false, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF00B4FF), width: 1.2)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Color(0xFF00B4FF), width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(vertical: 10))),
      const SizedBox(height: 10),
      // Type filter - outlined rounded
      Wrap(spacing: 4, runSpacing: 4, children: [
        for (var t in [['all','🏪 Todos'],['comida','🍲'],['cafe','☕'],['postres','🧁'],['mariscos','🦐'],['bebidas','🍺'],['farmacia','💊'],['super','🛒'],['servicios','🔧']])
          GestureDetector(onTap: () => setState(() => _negTipo = t[0]),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _negTipo == t[0] ? AppTheme.ac : AppTheme.bd, width: 1.2),
              color: _negTipo == t[0] ? AppTheme.ac.withOpacity(0.08) : Colors.transparent),
              child: Text(t[1], style: TextStyle(fontSize: 10, color: _negTipo == t[0] ? AppTheme.ac : AppTheme.tm)))),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Text('${filtered.length + apiFiltered.length} resultados', style: const TextStyle(fontSize: 10, color: AppTheme.td)),
        if (_apiNegocios.isNotEmpty) ...[
          const Text(' · ', style: TextStyle(fontSize: 10, color: AppTheme.td)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppTheme.gr.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('${apiFiltered.length} del API', style: const TextStyle(fontSize: 8, color: AppTheme.gr))),
        ],
      ]),
      const SizedBox(height: 10),
      // ── API Marketplace negocios ──
      if (apiFiltered.isNotEmpty) ...[
        const Text('📡 Marketplace (API)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.ac)),
        const SizedBox(height: 6),
        ...apiFiltered.take(5).map((n) => Container(
          margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.ac.withOpacity(0.25), width: 1.2)),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(
              color: AppTheme.ac.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(n['tipo'] == 'farmacia' ? '💊' : n['tipo'] == 'comida' ? '🍲' : '🏪', style: const TextStyle(fontSize: 22)))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n['nombre'] ?? 'Negocio', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tx)),
              Text(n['descripcion'] ?? '', style: const TextStyle(fontSize: 9, color: AppTheme.tm), maxLines: 1, overflow: TextOverflow.ellipsis),
              Row(children: [
                const Icon(Icons.location_on, size: 10, color: AppTheme.td),
                const SizedBox(width: 2),
                Text(n['direccion'] ?? n['zona'] ?? '', style: const TextStyle(fontSize: 8, color: AppTheme.td), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ])),
            Column(children: [
              Text('⭐ ${n['calificacion'] ?? 4.5}', style: const TextStyle(fontSize: 9, color: AppTheme.or)),
              const Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.td),
            ]),
          ]))),
        const SizedBox(height: 12),
        const Text('🏪 Negocios Locales', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tx)),
        const SizedBox(height: 6),
      ],
      // Costco special card si está en lista
      if (filtered.any((n) => n.id == 'c81')) ...[
        GestureDetector(onTap: () {},
          child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF005DAA), Color(0xFF0073CF)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF005DAA).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                child: const Center(child: Text('🛒', style: TextStyle(fontSize: 30)))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Costco', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                SizedBox(height: 2),
                Text('Mayoreo · Electrónica · Alimentos', style: TextStyle(fontSize: 11, color: Colors.white70)),
                SizedBox(height: 4),
                Text('📍 Satélite · Coyoacán · Interlomas', style: TextStyle(fontSize: 10, color: Colors.white54)),
                Text('⭐ 4.7 · 5,200+ pedidos', style: TextStyle(fontSize: 10, color: Colors.white54)),
              ])),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white70),
            ]),
          ),
        ),
      ],
      // Grid - cards con foto y ubicación
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.78),
        itemCount: filtered.where((n) => n.id != 'c81').length, itemBuilder: (_, i) {
          final n = filtered.where((n) => n.id != 'c81').toList()[i];
          return GestureDetector(onTap: () { if (n.menu != null) setState(() => _menuScreen = n.menu); },
            child: Container(decoration: BoxDecoration(
              color: Colors.transparent, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: n.c.withOpacity(0.25), width: 1.2)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Foto placeholder con color
                Container(height: 70, decoration: BoxDecoration(
                  color: n.c.withOpacity(0.15),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(19), topRight: Radius.circular(19))),
                  child: Stack(children: [
                    Center(child: Text(n.e, style: const TextStyle(fontSize: 34))),
                    Positioned(top: 6, right: 6, child: GestureDetector(onTap: () => setState(() => _favs.contains(n.id) ? _favs.remove(n.id) : _favs.add(n.id)),
                      child: Container(width: 26, height: 26, decoration: BoxDecoration(color: AppTheme.bg.withOpacity(0.6), shape: BoxShape.circle),
                        child: Center(child: Text(_favs.contains(n.id) ? '❤️' : '🤍', style: const TextStyle(fontSize: 12)))))),
                  ])),
                // Info
                Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(n.nom, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tx), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(n.desc, style: const TextStyle(fontSize: 9, color: AppTheme.tm), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on, size: 10, color: AppTheme.td),
                    const SizedBox(width: 2),
                    Expanded(child: Text(n.zona, style: const TextStyle(fontSize: 8, color: AppTheme.td), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 3),
                  Row(children: [
                    Text('⭐${n.r}', style: const TextStyle(fontSize: 8, color: AppTheme.or)),
                    const SizedBox(width: 6),
                    Text('📦${n.ped}', style: const TextStyle(fontSize: 8, color: AppTheme.tm)),
                  ]),
                  if (n.menu != null) ...[
                    const SizedBox(height: 3),
                    Text('Ver menú →', style: TextStyle(fontSize: 8, color: n.c, fontWeight: FontWeight.w600)),
                  ],
                ])),
              ])));
        }),
    ]));
  }

  Widget _cityBtn(String k, String l) => Expanded(child: GestureDetector(onTap: () => setState(() => _negCity = k),
    child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20), border: Border.all(color: _negCity == k ? AppTheme.ac : AppTheme.bd, width: 1.2),
      color: _negCity == k ? AppTheme.ac.withOpacity(0.08) : Colors.transparent),
      child: Text(l, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _negCity == k ? AppTheme.ac : AppTheme.tm)))));

  // ═══ MENU VIEW ═══
  Widget _menuView(String title, Map<String, List<MenuItem>> menu, Color color, String from) {
    final cats = menu.keys.toList();
    return DefaultTabController(length: cats.length, child: Scaffold(backgroundColor: AppTheme.bg,
      appBar: AppBar(backgroundColor: AppTheme.sf, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _menuScreen = null)),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        bottom: TabBar(isScrollable: true, indicatorColor: color, labelColor: color, unselectedLabelColor: AppTheme.tm, labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          tabs: cats.map((c) => Tab(text: c)).toList())),
      body: TabBarView(children: cats.map((cat) => ListView(padding: const EdgeInsets.all(12), children: menu[cat]!.map((it) =>
        Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.bd)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(it.n, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.tx))),
              if (it.pop) Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: AppTheme.or.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                child: const Text('🔥', style: TextStyle(fontSize: 8))),
              if (it.best) Container(margin: const EdgeInsets.only(left: 4), padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: AppTheme.yl.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                child: const Text('⭐BEST', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: AppTheme.yl))),
            ]),
            Text(it.d, style: TextStyle(fontSize: 9, color: AppTheme.tm)),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('\$${it.p}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.gr, fontFamily: 'monospace')),
              ElevatedButton(onPressed: () => _addToCart(it.n, it.p, from), style: ElevatedButton.styleFrom(backgroundColor: color.withOpacity(0.12), foregroundColor: color,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0),
                child: const Text('+ Agregar', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600))),
            ]),
          ]))).toList())).toList()),
      floatingActionButton: _cartQty > 0 ? FloatingActionButton.extended(onPressed: _openCart, backgroundColor: AppTheme.gr,
        icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
        label: Text('$_cartQty · \$$_cartTotal', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white))) : null,
    ));
  }

  // ═══ FARMACIA ═══
  String _farmSearch = '';
  List<Map<String, dynamic>> _farmSearchResults = [];
  bool _farmSearching = false;

  void _searchFarmacia(String q) async {
    setState(() { _farmSearch = q; _farmSearching = true; });
    if (_online && q.length >= 2) {
      final results = await ApiService.buscarFarmacia(q);
      if (!mounted) return;
      setState(() { _farmSearchResults = results; _farmSearching = false; });
    } else {
      setState(() => _farmSearching = false);
    }
  }

  Widget _farmScreen() {
    final useApi = _online && _apiFarmProductos.isNotEmpty;

    return Scaffold(backgroundColor: AppTheme.bg,
      appBar: AppBar(backgroundColor: AppTheme.sf, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _menuScreen = null)),
        title: Row(children: [
          Image.asset('assets/images/logo.png', height: 24),
          const SizedBox(width: 8),
          Text(useApi ? '💊 Farmacia (${_apiFarmProductos.length})' : '💊 Farmacia', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        actions: [
          if (_online) Padding(padding: const EdgeInsets.only(right: 8),
            child: Icon(Icons.cloud_done, size: 16, color: AppTheme.gr)),
        ]),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        // 3. Barra de búsqueda
        TextField(onChanged: _searchFarmacia, style: const TextStyle(color: AppTheme.tx, fontSize: 12),
          decoration: InputDecoration(hintText: 'Buscar medicamento...', hintStyle: const TextStyle(color: AppTheme.td),
            prefixIcon: const Icon(Icons.search, color: AppTheme.td, size: 18),
            suffixIcon: _farmSearching ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.ac))) : null,
            filled: true, fillColor: AppTheme.cd, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.bd)),
            contentPadding: const EdgeInsets.symmetric(vertical: 10))),
        if (_farmSearch.isNotEmpty && _farmSearchResults.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('${_farmSearchResults.length} resultados para "$_farmSearch"', style: const TextStyle(fontSize: 9, color: AppTheme.tm)),
          const SizedBox(height: 4),
          ..._farmSearchResults.take(20).map((p) => Container(margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.ac.withOpacity(0.2))),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p['nombre'] ?? '', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.tx), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${p['laboratorio'] ?? ''} · Stock: ${p['stock'] ?? 0}', style: const TextStyle(fontSize: 8, color: AppTheme.tm)),
              ])),
              Text('\$${p['precio'] ?? 0}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.gr, fontFamily: 'monospace')),
            ]))),
          const Divider(color: AppTheme.bd, height: 20),
        ],
        const SizedBox(height: 8),
        // Saturnos banner
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(colors: [AppTheme.tl, Color(0xFF004D40)])),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('🪐 Tarjeta Saturnos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('8% patente · 10% genérico', style: TextStyle(fontSize: 9, color: Colors.white70)),
            ]),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
              child: const Text('-35%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))),
          ])),
        const SizedBox(height: 10),
        ...farmacia.map((p) {
          final cc = {'bio': AppTheme.pu, 'onc': const Color(0xFFE91E63), 'esp': AppTheme.cy, 'gen': AppTheme.gr, 'pat': AppTheme.ac}[p.cat] ?? AppTheme.gr;
          final ce = {'bio': '🧬', 'onc': '🎗️', 'esp': '⚡', 'gen': '💊', 'pat': '🏷️'}[p.cat] ?? '💊';
          return Container(margin: const EdgeInsets.only(bottom: 5), padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.bd),
              boxShadow: [BoxShadow(color: cc.withOpacity(0.05), blurRadius: 4, offset: const Offset(-3, 0))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(ce, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Expanded(child: Text(p.n, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tx))),
                if (p.rx) Text('℞', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.or)),
              ]),
              Text('${p.lab} · Stock: ${p.stock}', style: TextStyle(fontSize: 9, color: AppTheme.tm)),
              const SizedBox(height: 4),
              Row(children: [
                Text('\$${p.lista}', style: TextStyle(fontSize: 10, color: AppTheme.td, decoration: TextDecoration.lineThrough, fontFamily: 'monospace')),
                const SizedBox(width: 8),
                Text('\$${p.oferta}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.gr, fontFamily: 'monospace')),
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: AppTheme.gr.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                  child: const Text('-35%', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: AppTheme.gr))),
                const Spacer(),
                ElevatedButton(onPressed: () => _addToCart(p.n, p.lista, 'Farmacias Madrid', oferta: p.oferta),
                  style: ElevatedButton.styleFrom(backgroundColor: cc.withOpacity(0.12), foregroundColor: cc, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0, minimumSize: Size.zero),
                  child: const Text('+Agregar', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600))),
              ]),
            ]));
        }),
      ]),
      floatingActionButton: _cartQty > 0 ? FloatingActionButton.extended(onPressed: _openCart, backgroundColor: AppTheme.gr,
        icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
        label: Text('$_cartQty · \$$_cartTotal', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white))) : null,
    );
  }

  // ═══ PEDIDOS ═══
  Widget _pedScreen() {
    final fp = _pedFilter == 'all' ? pedidos : pedidos.where((p) => p.city == _pedFilter).toList();
    final bool useApi = _apiEntregas.isNotEmpty;
    // Stats API reales
    final enRuta = useApi ? _apiEntregas.where((e) => e['estado'] == 'en_transito').length : fp.where((p) => p.est == 'ruta').length;
    final pendientes = useApi ? _apiEntregas.where((e) => e['estado'] == 'pendiente').length : fp.where((p) => p.est == 'prep').length;
    final completadas = useApi ? _apiEntregas.where((e) => e['estado'] == 'completada').length : fp.where((p) => p.est == 'ok').length;

    return RefreshIndicator(onRefresh: _loadApiData, color: AppTheme.ac,
      child: ListView(padding: const EdgeInsets.all(14), children: [
      _topBar(),
      // ── Rastrear pedido ──
      Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00B4FF), width: 1.2)),
        child: Row(children: [
          const Icon(Icons.search, color: Color(0xFFFFD600), size: 18),
          const SizedBox(width: 8),
          Expanded(child: TextField(
            onChanged: (v) => _trackFolio = v,
            style: const TextStyle(color: Color(0xFF00B4FF), fontSize: 12),
            decoration: const InputDecoration(
              hintText: 'Rastrear folio CGO-XXXXX...', hintStyle: TextStyle(color: Color(0xFF00B4FF), fontSize: 11),
              border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
          )),
          GestureDetector(onTap: () => _rastrearPedido(_trackFolio),
            child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppTheme.ac.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.send, size: 16, color: AppTheme.ac))),
        ])),
      // ── Filter pills ──
      Row(children: [for (var f in [['all','Todos'],['hidalgo','Hidalgo'],['cdmx','CDMX']])
        Expanded(child: GestureDetector(onTap: () => setState(() => _pedFilter = f[0]),
          child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _pedFilter == f[0] ? AppTheme.ac : AppTheme.bd, width: 1.2),
              gradient: _pedFilter == f[0] ? const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)]) : null,
              color: _pedFilter == f[0] ? null : Colors.transparent),
            child: Text(f[1], textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _pedFilter == f[0] ? Colors.white : AppTheme.tm)))))]),
      const SizedBox(height: 12),
      // ── Stats ──
      Row(children: [
        _pedStatNew('En Ruta', enRuta, AppTheme.ac),
        const SizedBox(width: 8),
        _pedStatNew('Pendientes', pendientes, AppTheme.or),
        const SizedBox(width: 8),
        _pedStatNew('Entregados', completadas, AppTheme.gr),
      ]),
      const SizedBox(height: 10),
      // ── Entregas (API real o mock) ──
      if (useApi)
        ..._apiEntregas.take(10).map((e) {
          final idx = _apiEntregas.indexOf(e);
          return _apiEntregaCard(e, isFirst: idx == 0);
        })
      else
        ...fp.map(_pedCard),
      const SizedBox(height: 16),
      // ═══ MAPA - tap para pantalla completa ═══
      GestureDetector(
        onTap: () => setState(() { _showFullMap = true; _updateMapMarkers(); }),
        child: Container(height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: [BoxShadow(color: AppTheme.ac.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Stack(children: [
            // Grid decoration
            Positioned.fill(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: CustomPaint(painter: _MapGridPainter()))),
            // Content
            Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.map, size: 22, color: Colors.white)),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('🗺️ Mapa de Entregas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text('Toca para ver mapa completo', style: TextStyle(fontSize: 10, color: Colors.white70)),
                ])),
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.fullscreen, size: 20, color: Colors.white)),
              ]),
              const Spacer(),
              // Mini indicators
              Row(children: [
                _mapPreviewChip('📍 Tulancingo', '${negHidalgo.length}'),
                const SizedBox(width: 8),
                _mapPreviewChip('🏙️ CDMX', '${negCdmx.length}'),
                const SizedBox(width: 8),
                _mapPreviewChip('📦 En ruta', '${useApi ? enRuta : pedidos.where((p) => p.est == "ruta").length}'),
              ]),
            ])),
          ]))),
      const SizedBox(height: 8),
      Row(children: [
        _pedStat('Rutas Activas', useApi ? enRuta : rutas.where((r) => r.est == 'activa').length, AppTheme.ac),
        _pedStat('Paquetes', useApi ? _apiEntregas.length : rutas.fold(0, (s, r) => s + r.paq), AppTheme.or),
      ]),
      const SizedBox(height: 16),
      // ── Historial (API o mock) ──
      const Text('📋 Historial', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.tx)),
      const SizedBox(height: 8),
      if (_apiHistorial.isNotEmpty)
        ..._apiHistorial.take(10).map((h) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.bd, width: 1.2)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${h['folio'] ?? h['id'] ?? ''}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.tx)),
                Text('${h['fecha'] ?? ''}', style: const TextStyle(fontSize: 9, color: AppTheme.tm))]),
              Text('${h['origen'] ?? ''} → ${h['destino'] ?? ''}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.ac)),
              Text('${h['estado'] ?? ''}', style: const TextStyle(fontSize: 8, color: AppTheme.tm)),
            ])),
            if (h['total'] != null) Text('\$${h['total']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.gr, fontFamily: 'monospace')),
          ])))
      else
        ...orderHist.map((o) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.bd, width: 1.2)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(o.id, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.tx)), Text(o.dt, style: const TextStyle(fontSize: 9, color: AppTheme.tm))]),
              Text(o.from, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.ac)),
              Text(o.items.join(', '), style: const TextStyle(fontSize: 8, color: AppTheme.tm)),
            ])),
            Text('\$${o.tot}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.gr, fontFamily: 'monospace')),
          ]))),
    ]));
  }

  Widget _mapPreviewChip(String label, String count) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70)),
      const SizedBox(width: 4),
      Text(count, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
    ]));

  Widget _pedStat(String l, int v, Color c) => Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.bd)),
    child: Column(children: [Text('$v', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c)), Text(l, style: TextStyle(fontSize: 8, color: AppTheme.tm))])));

  Widget _pedStatNew(String l, int v, Color c) => Expanded(child: Container(padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withOpacity(0.25), width: 1.2)),
    child: Column(children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text('$v', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: c)))),
      const SizedBox(height: 4),
      Text(l, style: const TextStyle(fontSize: 9, color: AppTheme.tm)),
    ])));

  Widget _pedCard(Pedido p) {
    final ec = {'ruta': AppTheme.ac, 'prep': AppTheme.or, 'ok': AppTheme.gr};
    final el = {'ruta': 'En Ruta', 'prep': 'Preparando', 'ok': 'Entregado'};
    final ei = {'ruta': Icons.local_shipping, 'prep': Icons.access_time, 'ok': Icons.check_circle};
    final c = ec[p.est]!;
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.25), width: 1.2),
      ),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(ei[p.est], size: 20, color: c)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(p.id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tx)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(el[p.est]!, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: c))),
          ]),
          const SizedBox(height: 4),
          Text('${p.orig} → ${p.dest}', style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
          if (p.prog > 0 && p.prog < 100) ...[
            const SizedBox(height: 5),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: p.prog / 100, backgroundColor: c.withOpacity(0.08), color: c, minHeight: 3)),
          ],
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${p.cl} · ${p.h}', style: const TextStyle(fontSize: 9, color: AppTheme.td)),
            Text('\$${p.m}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.gr, fontFamily: 'monospace')),
          ]),
        ])),
      ]));
  }

  Widget _pedCardBlue(Pedido p) {
    final el = {'ruta': 'En Ruta', 'prep': 'Preparando', 'ok': 'Entregado'};
    final ei = {'ruta': Icons.local_shipping, 'prep': Icons.access_time, 'ok': Icons.check_circle};
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: Icon(ei[p.est], size: 20, color: Colors.white)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(p.id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Text(el[p.est]!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white))),
          ]),
          const SizedBox(height: 4),
          Text('${p.orig} → ${p.dest}', style: const TextStyle(fontSize: 10, color: Colors.white70)),
          if (p.prog > 0 && p.prog < 100) ...[
            const SizedBox(height: 5),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: p.prog / 100, backgroundColor: Colors.white.withOpacity(0.15), color: Colors.white, minHeight: 3)),
          ],
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${p.cl} · ${p.h}', style: const TextStyle(fontSize: 9, color: Colors.white54)),
            Text('\$${p.m}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'monospace')),
          ]),
        ])),
      ]));
  }

  // ═══ MAPA ═══
  // ═══ MINI MUDANZAS ═══
  Widget _mudScreen() => ListView(padding: const EdgeInsets.all(14), children: [
    _topBar(),
    Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color(0xFF6A1B9A).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        const Icon(Icons.fire_truck, size: 48, color: Colors.white),
        const SizedBox(height: 8),
        const Text('Mini Mudanzas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Servicio de mudanzas locales en Tulancingo y CDMX', style: TextStyle(fontSize: 12, color: Colors.white70), textAlign: TextAlign.center),
      ]),
    ),
    const SizedBox(height: 14),
    // Tipos de servicio
    const Text('Selecciona tu servicio', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
    const SizedBox(height: 8),
    _mudOption(Icons.chair, 'Mudanza Express', 'Muebles pequeños, cajas, electrodomésticos', '\$350', const Color(0xFF00897B)),
    const SizedBox(height: 8),
    _mudOption(Icons.king_bed, 'Mudanza Mediana', 'Recámaras, salas, comedores completos', '\$750', const Color(0xFFEF6C00)),
    const SizedBox(height: 8),
    _mudOption(Icons.house, 'Mudanza Completa', 'Casa o departamento completo', '\$1,500', const Color(0xFFC62828)),
    const SizedBox(height: 8),
    _mudOption(Icons.business, 'Mudanza Oficina', 'Escritorios, archiveros, equipo', '\$900', const Color(0xFF1565C0)),
    const SizedBox(height: 16),
    // Cómo funciona
    const Text('¿Cómo funciona?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
    const SizedBox(height: 8),
    _mudStep('1', 'Elige tu servicio', 'Selecciona el tipo de mudanza que necesitas'),
    _mudStep('2', 'Agenda tu fecha', 'Escoge el día y hora que te convenga'),
    _mudStep('3', 'Recogemos todo', 'Nuestro equipo llega y carga con cuidado'),
    _mudStep('4', 'Entrega segura', 'Llevamos tus cosas al destino'),
    const SizedBox(height: 14),
    // Cobertura
    Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.bd, width: 1.2)),
      child: Row(children: [
        const Icon(Icons.location_on, size: 20, color: AppTheme.ac),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Cobertura', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          Text('Tulancingo · Pachuca · CDMX · Zona Metropolitana', style: TextStyle(fontSize: 10, color: AppTheme.tm)),
        ])),
      ]),
    ),
    const SizedBox(height: 8),
    Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.bd, width: 1.2)),
      child: Row(children: [
        const Icon(Icons.phone, size: 20, color: AppTheme.gr),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Cotiza ahora', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          Text('Llámanos o envía WhatsApp para agendar', style: TextStyle(fontSize: 10, color: AppTheme.tm)),
        ])),
      ]),
    ),
  ]);

  Widget _mudOption(IconData ic, String title, String desc, String price, Color c) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20),
      border: Border.all(color: c.withOpacity(0.25), width: 1.2)),
    child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(ic, size: 24, color: c)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c)),
        Text(desc, style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
      ])),
      Column(children: [
        const Text('Desde', style: TextStyle(fontSize: 8, color: AppTheme.td)),
        Text(price, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c)),
      ]),
    ]),
  );

  Widget _mudStep(String num, String title, String desc) => Container(
    margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.bd, width: 1.2)),
    child: Row(children: [
      Container(width: 28, height: 28, decoration: BoxDecoration(color: const Color(0xFF6A1B9A), borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text(num, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tx)),
        Text(desc, style: TextStyle(fontSize: 9, color: AppTheme.tm)),
      ])),
    ]),
  );

  Widget _mapCity(String n, String count, Color c) => Column(children: [
    Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, color: c,
      boxShadow: [BoxShadow(color: c.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)])),
    const SizedBox(height: 4),
    Text(n, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tx)),
    Text('$count negocios', style: const TextStyle(fontSize: 8, color: AppTheme.tm)),
  ]);

  // ═══ PERFIL ═══
  Widget _perfScreen() => ListView(padding: const EdgeInsets.all(14), children: [
    _topBar(),
    // Profile card - blue gradient
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)])),
      child: Column(children: [
        Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.3), width: 3)),
          child: CircleAvatar(radius: 32, backgroundColor: Colors.white.withOpacity(0.2), child: const Text('CH', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)))),
        const SizedBox(height: 10),
        const Text('Chule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
        const Text('Farmacias Madrid · Cargo-GO', style: TextStyle(fontSize: 11, color: Colors.white70)),
      ])),
    const SizedBox(height: 16),
    const Text('📍 Direcciones', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.tx)),
    const SizedBox(height: 8),
    ...addrs.map((a) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: a.main ? AppTheme.ac.withOpacity(0.4) : AppTheme.bd, width: 1.2)),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: (a.main ? AppTheme.ac : AppTheme.tm).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.location_on, size: 18, color: a.main ? AppTheme.ac : AppTheme.tm)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text(a.l, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.tx)), if (a.main) const Text(' Principal', style: TextStyle(fontSize: 8, color: AppTheme.ac))]),
          Text(a.a, style: const TextStyle(fontSize: 9, color: AppTheme.tm)),
        ])),
      ]))),
    const SizedBox(height: 12),
    const Text('💳 Métodos de Pago', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.tx)),
    const SizedBox(height: 8),
    ...pays.map((p) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.main ? AppTheme.gr.withOpacity(0.4) : AppTheme.bd, width: 1.2)),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: (p.main ? AppTheme.gr : AppTheme.tm).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.credit_card, size: 18, color: p.main ? AppTheme.gr : AppTheme.tm)),
        const SizedBox(width: 10),
        Text(p.l, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.tx)),
        if (p.main) const Text(' Principal', style: TextStyle(fontSize: 8, color: AppTheme.gr)),
      ]))),
    const SizedBox(height: 12),
    const Text('⚙️ Cuenta', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.tx)),
    const SizedBox(height: 8),
    for (var it in ['Editar perfil','Notificaciones','Seguridad','Soporte','Cerrar sesión'])
      Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: it == 'Cerrar sesión' ? AppTheme.rd.withOpacity(0.25) : AppTheme.bd, width: 1.2)),
        child: Row(children: [
          Icon(it == 'Editar perfil' ? Icons.edit : it == 'Notificaciones' ? Icons.notifications : it == 'Seguridad' ? Icons.shield : it == 'Soporte' ? Icons.help : Icons.logout,
            size: 18, color: it == 'Cerrar sesión' ? AppTheme.rd : AppTheme.tm),
          const SizedBox(width: 10),
          Text(it, style: TextStyle(fontSize: 11, color: it == 'Cerrar sesión' ? AppTheme.rd : AppTheme.tx)),
        ])),
  ]);
}

// ═══ Map Grid Painter (decorative lines for map preview card) ═══
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;
    // Horizontal lines
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Diagonal route line
    final routePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.3, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.7, size.height * 0.7, size.width * 0.9, size.height * 0.2);
    canvas.drawPath(path, routePaint);
    // Dots at endpoints
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.2);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.7), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.2), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
