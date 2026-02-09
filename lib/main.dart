import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/mercadopago_service.dart';
import 'services/places_photo_service.dart';
import 'services/whatsapp_service.dart';
import 'services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';

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

// Dark map tiles: CartoDB Dark Matter (no API key needed)

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
  final String? menu, horario, tel;
  Negocio({required this.id, required this.nom, required this.e, required this.zona, required this.desc, required this.tipo, required this.r, required this.ped, required this.c, this.menu, this.horario, this.tel});
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
  Negocio(id:"h01",nom:"Farmacias Madrid - Matriz",e:"💊",zona:"Av. Juárez 102, Centro, Tulancingo",desc:"Sucursal principal · 77K+ productos",r:4.8,ped:1240,c:AppTheme.gr,menu:"farmacia",tipo:"farmacia",horario:"7:00–23:00",tel:"7751234567"),
  Negocio(id:"h01b",nom:"Farmacias Madrid - Suc. Catedral",e:"💊",zona:"21 de Marzo 45, Centro, Tulancingo",desc:"Frente a la Catedral · medicamentos 24hrs",r:4.7,ped:980,c:AppTheme.gr,menu:"farmacia",tipo:"farmacia",horario:"24 horas",tel:"7751234568"),
  Negocio(id:"h01c",nom:"Farmacias Madrid - Suc. Floresta",e:"💊",zona:"Blvd. La Floresta 210, Tulancingo",desc:"Zona La Floresta · servicio a domicilio",r:4.6,ped:720,c:AppTheme.gr,menu:"farmacia",tipo:"farmacia",horario:"8:00–22:00",tel:"7751234569"),
  Negocio(id:"h01d",nom:"Farmacias Madrid - Suc. Torres",e:"💊",zona:"Av. Las Torres 88, Tulancingo",desc:"Junto a plaza comercial · laboratorio",r:4.7,ped:860,c:AppTheme.gr,menu:"farmacia",tipo:"farmacia",horario:"8:00–22:00",tel:"7751234570"),
  Negocio(id:"h02",nom:"Mamá Chela",e:"🍲",zona:"Centro, Tulancingo",desc:"Comida casera hidalguense",r:4.9,ped:890,c:AppTheme.or,menu:"mama",tipo:"comida",horario:"9:00–18:00",tel:"7759876543"),
  Negocio(id:"h03",nom:"Dulce María",e:"🧁",zona:"La Floresta, Tulancingo",desc:"Postres artesanales mexicanos",r:4.7,ped:650,c:AppTheme.pk,menu:"dulce",tipo:"postres",horario:"10:00–20:00",tel:"7751112233"),
  Negocio(id:"h04",nom:"Tacos El Güero",e:"🌮",zona:"Centro, Tulancingo",desc:"Tacos al pastor y suadero",r:4.6,ped:1100,c:AppTheme.rd,tipo:"comida",horario:"18:00–02:00",tel:"7754445566"),
  Negocio(id:"h05",nom:"Carnitas Don Pepe",e:"🥩",zona:"San Antonio, Tulancingo",desc:"Carnitas estilo Michoacán",r:4.5,ped:780,c:const Color(0xFFB45309),tipo:"comida",horario:"8:00–16:00",tel:"7753334455"),
  Negocio(id:"h06",nom:"Pollos El Rey",e:"🍗",zona:"Las Torres, Tulancingo",desc:"Pollo al carbón y rostizado",r:4.4,ped:920,c:const Color(0xFFEA580C),tipo:"comida",horario:"10:00–21:00",tel:"7756667788"),
  Negocio(id:"h07",nom:"Café Tulancingo",e:"☕",zona:"Centro, Tulancingo",desc:"Café de altura hidalguense",r:4.6,ped:520,c:const Color(0xFF78350F),tipo:"cafe",horario:"7:00–21:00",tel:"7752223344"),
  Negocio(id:"h08",nom:"Tortas La Abuela",e:"🥖",zona:"Jaltepec, Tulancingo",desc:"Tortas gigantes y cemitas",r:4.7,ped:670,c:const Color(0xFFCA8A04),tipo:"comida",horario:"9:00–20:00",tel:"7758889900"),
  Negocio(id:"h09",nom:"Barbacoa Los Reyes",e:"🐑",zona:"Centro, Tulancingo",desc:"Barbacoa borrego jue y dom",r:4.8,ped:950,c:const Color(0xFF92400E),tipo:"comida",horario:"Jue-Dom 7:00–15:00",tel:"7755556677"),
  Negocio(id:"h10",nom:"Pastes El Portal",e:"🥟",zona:"Centro, Tulancingo",desc:"Pastes tradicionales 1960",r:4.7,ped:1050,c:const Color(0xFFD97706),tipo:"comida",horario:"8:00–20:00",tel:"7751239876"),
  Negocio(id:"h11",nom:"Panadería San José",e:"🍞",zona:"La Floresta",desc:"Pan artesanal y de fiesta",r:4.5,ped:420,c:const Color(0xFFA16207),tipo:"panaderia",horario:"6:00–21:00",tel:"7754561234"),
  Negocio(id:"h12",nom:"Pulquería La Noria",e:"🍺",zona:"Santiago, Tulancingo",desc:"Pulque natural y curados",r:4.3,ped:380,c:const Color(0xFF4D7C0F),tipo:"bebidas",horario:"12:00–22:00",tel:"7757891234"),
  Negocio(id:"h13",nom:"Abarrotes Doña Lupe",e:"🏪",zona:"Cuautepec",desc:"Abarrotes y productos básicos",r:4.2,ped:620,c:AppTheme.tl,tipo:"abarrotes",horario:"7:00–22:00",tel:"7753216549"),
  Negocio(id:"h14",nom:"Pizzas Tulancingo",e:"🍕",zona:"Las Torres",desc:"Pizza al horno de leña",r:4.4,ped:540,c:const Color(0xFFDC2626),tipo:"comida",horario:"14:00–23:00",tel:"7756543210"),
  Negocio(id:"h15",nom:"Jugos y Licuados Mary",e:"🥤",zona:"Mercado",desc:"Jugos naturales y licuados",r:4.5,ped:730,c:const Color(0xFF16A34A),tipo:"bebidas",horario:"7:00–18:00",tel:"7759871234"),
  Negocio(id:"h16",nom:"Taller Bicis Rápido",e:"🚲",zona:"Centro",desc:"Reparación y refacciones",r:4.1,ped:180,c:const Color(0xFF6366F1),tipo:"servicios",horario:"9:00–19:00",tel:"7751472583"),
  Negocio(id:"h17",nom:"Flores El Jardín",e:"💐",zona:"La Floresta",desc:"Arreglos florales y ramos",r:4.6,ped:290,c:const Color(0xFFE11D48),tipo:"flores",horario:"8:00–20:00",tel:"7752583691"),
  Negocio(id:"h18",nom:"Carnicería Hidalgo",e:"🥩",zona:"Mercado",desc:"Carnes selectas y marinados",r:4.4,ped:810,c:const Color(0xFF991B1B),tipo:"carniceria",horario:"7:00–17:00",tel:"7753691472"),
  Negocio(id:"h19",nom:"Ferretería Central",e:"🔧",zona:"Centro",desc:"Material eléctrico y plomería",r:4.3,ped:350,c:const Color(0xFF525252),tipo:"ferreteria",horario:"8:00–19:00",tel:"7754567890"),
  Negocio(id:"h20",nom:"Papelería Escolar",e:"📚",zona:"Centro",desc:"Útiles, copias, impresiones",r:4.2,ped:460,c:const Color(0xFF2563EB),tipo:"papeleria",horario:"8:00–20:00",tel:"7757890123"),
  Negocio(id:"h21",nom:"Tortillería La Esperanza",e:"🫓",zona:"Centro, Tulancingo",desc:"Tortillas de maíz y harina recién hechas",r:4.6,ped:1800,c:const Color(0xFFD97706),tipo:"comida",horario:"6:00–14:00",tel:"7751234890"),
  Negocio(id:"h22",nom:"Pollería Hermanos García",e:"🐔",zona:"Las Torres, Tulancingo",desc:"Pollo fresco, huevo y embutidos",r:4.3,ped:950,c:const Color(0xFFEA580C),tipo:"comida",horario:"7:00–18:00",tel:"7754321098"),
  Negocio(id:"h23",nom:"Abarrotes El Ahorro",e:"🛒",zona:"Jaltepec, Tulancingo",desc:"Todo para tu despensa a buen precio",r:4.1,ped:720,c:AppTheme.tl,tipo:"super",horario:"7:00–23:00",tel:"7756789012"),
  Negocio(id:"h24",nom:"Taquería Los Compadres",e:"🌮",zona:"La Floresta, Tulancingo",desc:"Tacos de suadero, tripa y cabeza",r:4.7,ped:1350,c:const Color(0xFFDC2626),tipo:"comida",horario:"19:00–03:00",tel:"7758901234"),
  Negocio(id:"h25",nom:"Tlapalería Don Manuel",e:"🔩",zona:"Centro, Tulancingo",desc:"Pinturas, herramientas y material",r:4.2,ped:280,c:const Color(0xFF525252),tipo:"ferreteria",horario:"8:00–19:00",tel:"7750123456"),
  Negocio(id:"h26",nom:"Estética Lupita",e:"💇",zona:"La Floresta, Tulancingo",desc:"Cortes, tintes, peinados y uñas",r:4.5,ped:410,c:const Color(0xFFEC4899),tipo:"servicios",horario:"9:00–20:00",tel:"7752345678"),
  Negocio(id:"h27",nom:"Veterinaria San Francisco",e:"🐾",zona:"Centro, Tulancingo",desc:"Consultas, vacunas y accesorios",r:4.4,ped:320,c:const Color(0xFF16A34A),tipo:"servicios",horario:"9:00–19:00",tel:"7753456789"),
  Negocio(id:"h28",nom:"Recaudería Doña Carmen",e:"🥕",zona:"Mercado, Tulancingo",desc:"Frutas, verduras y legumbres frescas",r:4.3,ped:1100,c:const Color(0xFF15803D),tipo:"mercado",horario:"6:00–16:00",tel:"7754567891"),
  Negocio(id:"h29",nom:"Lavandería Clean Express",e:"👔",zona:"Las Torres, Tulancingo",desc:"Lavado, secado y planchado rápido",r:4.1,ped:190,c:const Color(0xFF0284C7),tipo:"servicios",horario:"8:00–20:00",tel:"7755678901"),
  Negocio(id:"h30",nom:"Cremería La Vaquita",e:"🧀",zona:"Mercado, Tulancingo",desc:"Quesos, crema y lácteos de rancho",r:4.6,ped:680,c:const Color(0xFFEAB308),tipo:"comida",horario:"7:00–17:00",tel:"7756789013"),
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

// ═══ COORDENADAS REALES DE TODOS LOS NEGOCIOS ═══
const _negCoords = <String, List<double>>{
  // ── Hidalgo (Tulancingo ~20.08, -98.38) ──
  'h01': [20.0841, -98.3619], // Farmacias Madrid Matriz - Av. Juárez, Centro
  'h01b': [20.0833, -98.3601], // Farmacias Madrid Suc. Catedral - 21 de Marzo
  'h01c': [20.0785, -98.3560], // Farmacias Madrid Suc. Floresta
  'h01d': [20.0910, -98.3700], // Farmacias Madrid Suc. Torres
  'h02': [20.0838, -98.3808], // Mamá Chela - Centro
  'h03': [20.0780, -98.3730], // Dulce María - La Floresta
  'h04': [20.0850, -98.3825], // Tacos El Güero - Centro
  'h05': [20.0890, -98.3770], // Carnitas Don Pepe - San Antonio
  'h06': [20.0760, -98.3880], // Pollos El Rey - Las Torres
  'h07': [20.0842, -98.3820], // Café Tulancingo - Centro
  'h08': [20.0920, -98.3760], // Tortas La Abuela - Jaltepec
  'h09': [20.0835, -98.3830], // Barbacoa Los Reyes - Centro
  'h10': [20.0840, -98.3810], // Pastes El Portal - Centro
  'h11': [20.0775, -98.3740], // Panadería San José - La Floresta
  'h12': [20.0810, -98.3900], // Pulquería La Noria - Santiago
  'h13': [20.0670, -98.3650], // Abarrotes Doña Lupe - Cuautepec
  'h14': [20.0765, -98.3875], // Pizzas Tulancingo - Las Torres
  'h15': [20.0845, -98.3800], // Jugos Mary - Mercado
  'h16': [20.0848, -98.3818], // Taller Bicis - Centro
  'h17': [20.0785, -98.3735], // Flores El Jardín - La Floresta
  'h18': [20.0843, -98.3805], // Carnicería Hidalgo - Mercado
  'h19': [20.0847, -98.3822], // Ferretería Central - Centro
  'h20': [20.0836, -98.3812], // Papelería Escolar - Centro
  'h21': [20.0852, -98.3622], // Tortillería La Esperanza - Centro
  'h22': [20.0910, -98.3705], // Pollería Hermanos García - Las Torres
  'h23': [20.0920, -98.3755], // Abarrotes El Ahorro - Jaltepec
  'h24': [20.0778, -98.3738], // Taquería Los Compadres - La Floresta
  'h25': [20.0846, -98.3628], // Tlapalería Don Manuel - Centro
  'h26': [20.0782, -98.3565], // Estética Lupita - La Floresta
  'h27': [20.0839, -98.3610], // Veterinaria San Francisco - Centro
  'h28': [20.0848, -98.3605], // Recaudería Doña Carmen - Mercado
  'h29': [20.0915, -98.3710], // Lavandería Clean Express - Las Torres
  'h30': [20.0845, -98.3615], // Cremería La Vaquita - Mercado
  // ── CDMX (~19.43, -99.13) ──
  'c01': [19.4407, -99.1567], // El Califa de León - San Rafael
  'c02': [19.3500, -99.1625], // Café El Jarocho - Coyoacán
  'c03': [19.4326, -99.1332], // Los Cocuyos - Centro Histórico
  'c04': [19.3505, -99.1630], // Mercado Coyoacán
  'c05': [19.4186, -99.1619], // Tacos Orinoco - Roma Norte
  'c06': [19.4100, -99.1610], // Por Siempre Vegana - Roma Sur
  'c07': [19.4330, -99.1340], // Churrería El Moro - Centro
  'c08': [19.4335, -99.1345], // Pastelería Ideal - Centro
  'c09': [19.4340, -99.1950], // La Casa de Toño - Polanco
  'c10': [19.4000, -99.1700], // Taquería Los Parados - Insurgentes
  'c11': [19.2636, -99.1044], // Boing! Factory - Xochimilco
  'c12': [19.3980, -99.1600], // Birria El Texano - Narvarte
  'c13': [19.4130, -99.1250], // Mercado Jamaica
  'c14': [19.4130, -99.1720], // Helados Tepoznieves - Condesa
  'c15': [19.4190, -99.1625], // Panadería Rosetta - Roma Norte
  'c16': [19.2900, -99.1700], // Tortas Río - Tlalpan
  'c17': [19.3870, -99.1200], // Mariscos La Viga
  'c18': [19.4020, -99.1880], // Tamales Doña Emi - Tacubaya
  'c19': [19.4320, -99.1325], // Gorditas Doña Tota - Centro
  'c20': [19.4290, -99.1560], // Café Habana - Juárez
  'c21': [19.3900, -99.1720], // Quesadillas Doña Mary - Del Valle
  'c22': [19.4400, -99.1250], // Tacos Canasta Javi - Tepito
  'c23': [19.4315, -99.1360], // Mercado San Juan - Centro
  'c24': [19.4870, -99.1860], // Carnitas Don Güicho - Azcapotzalco
  'c25': [19.4328, -99.1335], // Farmacia del Ahorro - Centro
  'c26': [19.4010, -99.1690], // La Especial de París - Insurgentes
  'c27': [19.4340, -99.1350], // Café de Tacuba - Centro
  'c28': [19.4322, -99.1338], // El Huequito - Centro
  'c29': [19.3510, -99.1620], // Nevería Roxy - Coyoacán
  'c30': [19.4780, -99.2380], // Pan Bimbo Outlet - Naucalpan
  'c31': [19.4318, -99.1330], // Mariscos El Caguamo - Centro
  'c32': [19.4135, -99.1715], // Tlayudas Oaxaqueñas - Condesa
  'c33': [19.4345, -99.1955], // Pollos Río - Polanco
  'c34': [19.4260, -99.1640], // Esquites Don Beto - Reforma
  'c35': [19.4200, -99.1450], // Mezcalería - Doctores
  'c36': [19.3650, -99.2710], // Sushi Itto Express - Santa Fe
  'c37': [19.3900, -99.1800], // Pizzas Domino - Nápoles
  'c38': [19.3508, -99.1628], // Tostadas Coyoacán
  'c39': [19.4325, -99.1342], // Dulcería de Celaya - Centro
  'c40': [19.4128, -99.1718], // Fonda Margarita - Condesa
  'c41': [19.4405, -99.1570], // La Polar - San Rafael
  'c42': [19.3950, -99.1710], // Taco Inn - Insurgentes Sur
  'c43': [19.4350, -99.1960], // Superama Express - Polanco
  'c44': [19.4280, -99.1255], // La Merced Orgánica
  'c45': [19.4310, -99.1348], // Papelería Lumen - Centro
  'c46': [19.3600, -99.0900], // Ferretería Truper - Iztapalapa
  'c47': [19.4355, -99.1965], // Florerías CDMX - Polanco
  'c48': [19.4185, -99.1615], // Alitas y Boneless - Roma
  'c49': [19.4005, -99.1695], // VIPS Insurgentes
  'c50': [19.3905, -99.1725], // Tamal Oaxaqueño - Del Valle
  'c51': [19.4192, -99.1622], // Ramen Shinju - Roma Norte
  'c52': [19.4132, -99.1722], // Hamburguesas Corral - Condesa
  'c53': [19.3515, -99.1618], // Café Punta del Cielo - Coyoacán
  'c54': [19.4180, -99.1612], // Waffles & Crêpes - Roma
  'c55': [19.4285, -99.1555], // Tortería Niza - Juárez
  'c56': [19.4105, -99.1608], // Pozolería Tía Calla - Roma Sur
  'c57': [19.3985, -99.1605], // Lavandería Express - Narvarte
  'c58': [19.4348, -99.1958], // Tintorería Premium - Polanco
  'c59': [19.4188, -99.1618], // Barbería Old School - Roma
  'c60': [19.3908, -99.1728], // Veterinaria PetCare - Del Valle
  'c61': [19.3520, -99.1615], // Cervecería Primus - Coyoacán
  'c62': [19.4332, -99.1328], // Comida China Wing's - Centro
  'c63': [19.4138, -99.1725], // Empanadas Argentinas - Condesa
  'c64': [19.4183, -99.1616], // Jugos Natural Express - Roma
  'c65': [19.4140, -99.1728], // El Pescadito - Condesa
  'c66': [19.4270, -99.1530], // Korean BBQ Mex - Zona Rosa
  'c67': [19.4405, -99.1248], // Abarrotes Don Toño - Tepito
  'c68': [19.3525, -99.1612], // Tienda Naturista - Coyoacán
  'c69': [19.4312, -99.1582], // Librería Gandhi - Miguel Ángel
  'c70': [19.4335, -99.1355], // Copias Print Center - Centro
  'c71': [19.4295, -99.1565], // Bike Messenger - Juárez
  'c72': [19.4360, -99.1970], // Carnicería Premium - Polanco
  'c73': [19.3950, -99.0955], // Tortillería La Güera - Iztacalco
  'c74': [19.4785, -99.2385], // Mueblería Express - Naucalpan
  'c75': [19.4195, -99.1628], // Pastes Hidalguenses - Roma
  'c76': [19.3988, -99.1608], // Cevichería Pacífico - Narvarte
  'c77': [19.4145, -99.1730], // Brownies & Co. - Condesa
  'c78': [19.4338, -99.1358], // Dona María Mole - Centro
  'c79': [19.3992, -99.1612], // Cochinita Express - Narvarte
  'c80': [19.4178, -99.1608], // Mercado Roma
  'c81': [19.5098, -99.2338], // Costco Satélite
};

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




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase init - esperar antes de arrancar para que login funcione
  try {
    await AuthService.initialize();
  } catch (e) {
    debugPrint('[CGO] Firebase init error: $e');
  }
  runApp(const CargoGoApp());
}

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

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13)),
      backgroundColor: const Color(0xFFFF4757),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _sendCode() async {
    if (phone.length < 10) return;
    setState(() => loading = true);

    if (!AuthService.isAvailable) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() { loading = false; step = 1; });
      _showError('Modo demo: Firebase no configurado. Ingresa cualquier codigo.');
      return;
    }

    final error = await AuthService.sendCode(
      phone,
      onCodeSent: (id) {
        if (!mounted) return;
        setState(() { loading = false; step = 1; });
      },
      onError: (msg) {
        if (!mounted) return;
        setState(() => loading = false);
        _showError(msg);
      },
    );

    if (error != null && mounted) {
      setState(() => loading = false);
      _showError(error);
    }
  }

  void _verify() async {
    final smsCode = code.join();
    if (smsCode.length < 6) return;
    setState(() => loading = true);

    if (!AuthService.isAvailable) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainApp()));
      return;
    }

    final error = await AuthService.verifyCode(smsCode);
    if (!mounted) return;

    if (error == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainApp()));
    } else {
      setState(() => loading = false);
      _showError(error);
    }
  }

  void _signInGoogle() async {
    setState(() => loading = true);
    final error = await AuthService.signInWithGoogle();
    if (!mounted) return;
    if (error == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainApp()));
    } else {
      setState(() => loading = false);
      _showError(error);
    }
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
            SizedBox(width: double.infinity, height: 58, child: ElevatedButton(
              onPressed: loading ? null : _sendCode,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107), foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
              child: Text(loading ? 'Enviando...' : 'Enviar Código', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
            )),
            const SizedBox(height: 20),
            const Text('o continúa con', style: TextStyle(fontSize: 12, color: Color(0xFF506080))),
            const SizedBox(height: 14),
            // Google - colores oficiales
            SizedBox(width: double.infinity, height: 58, child: ElevatedButton(
              onPressed: loading ? null : _signInGoogle,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 2, shadowColor: Colors.black26,
                side: const BorderSide(color: Color(0xFFDADCE0), width: 1)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                // Logo Google multicolor
                SizedBox(width: 24, height: 24, child: Stack(alignment: Alignment.center, children: const [
                  Text('G', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF4285F4),
                    shadows: [Shadow(offset: Offset(0.5, 0.5), color: Color(0x33000000))])),
                ])),
                const SizedBox(width: 10),
                const Text('Continuar con ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF3C4043))),
                const Text('G', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF4285F4))),
                const Text('o', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFFEA4335))),
                const Text('o', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFFFBBC05))),
                const Text('g', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF4285F4))),
                const Text('l', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF34A853))),
                const Text('e', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFFEA4335))),
              ]),
            )),
            const SizedBox(height: 10),
            // Entrar como invitado - outlined grande
            SizedBox(width: double.infinity, height: 58, child: OutlinedButton(
              onPressed: _goMain,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), side: const BorderSide(color: Color(0xFF1C2D4A), width: 1.5)),
              child: const Text('Entrar como invitado', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
  String? _menuScreen; // mama, dulce, farmacia, compras
  String? _comprasTienda; // selected store id for Compras en Tienda
  final _comprasLista = TextEditingController();
  final _comprasTel = TextEditingController();
  final _comprasDir = TextEditingController();
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

  // ═══ FIRESTORE NEGOCIOS ═══
  List<Map<String, dynamic>> _firestoreNegocios = [];
  bool _loadingFirestore = false;

  // ═══ FLUTTER MAP ═══
  final MapController _mapController = MapController();
  LatLng _mapCenter = const LatLng(20.0833, -98.3833); // Tulancingo default
  final List<Map<String, dynamic>> _markerData = [];
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
    _updateMapMarkers(); // Llenar markers desde el inicio
    _loadFirestoreNegocios(); // Cargar negocios desde Firestore
  }

  Future<void> _loadFirestoreNegocios() async {
    setState(() => _loadingFirestore = true);
    try {
      final data = await FirestoreService.getNegocios();
      if (!mounted) return;
      setState(() { _firestoreNegocios = data; _loadingFirestore = false; });
      _updateMapMarkers(); // Refresh map with Firestore negocios
      debugPrint('[CGO] Firestore: ${data.length} negocios cargados');
    } catch (e) {
      debugPrint('[CGO] Firestore error: $e');
      if (!mounted) return;
      setState(() => _loadingFirestore = false);
    }
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
      });
      _mapController.move(_mapCenter, _mapController.camera.zoom);
    } catch (e) {
      debugPrint('[GPS] Error: $e');
    }
  }

  // ═══ NEGOCIOS MAP DATA (con coordenadas reales) ═══
  static final List<Map<String, dynamic>> _mapPlaces = [
    // ── Farmacias Madrid - Sucursales reales Tulancingo ──
    {'id': 'farm_centro', 'nom': 'Farmacias Madrid - Centro', 'dir': 'Av. Juárez 123, Centro, Tulancingo', 'tipo': 'farmacia', 'e': '💊', 'lat': 20.0844, 'lng': -98.3815, 'r': 5.0, 'tel': '+527751234567', 'h': 'Lun-Sáb 8:00-21:00', 'dist': '0.5 km', 'tiempo': '3 min', 'suc': 'matriz', 'color': 0xFF00E676},
    {'id': 'farm_santa_maria', 'nom': 'Farmacias Madrid - Suc. Santa María', 'dir': 'Col. Santa María, Tulancingo', 'tipo': 'farmacia', 'e': '💊', 'lat': 20.0790, 'lng': -98.3755, 'r': 4.9, 'tel': '+527751234570', 'h': 'Lun-Sáb 8:00-21:00', 'dist': '1.0 km', 'tiempo': '5 min', 'suc': 'santa maría', 'color': 0xFF00B0FF},
    {'id': 'farm_panteon', 'nom': 'Farmacias Madrid - Suc. Panteón', 'dir': 'Cerca del Panteón Municipal, Tulancingo', 'tipo': 'farmacia', 'e': '💊', 'lat': 20.0870, 'lng': -98.3870, 'r': 4.8, 'tel': '+527751234571', 'h': 'Lun-Sáb 8:00-21:00', 'dist': '1.2 km', 'tiempo': '6 min', 'suc': 'panteón', 'color': 0xFFFF6D00},
    {'id': 'farm_caballito', 'nom': 'Farmacias Madrid - Suc. Caballito', 'dir': 'Zona del Caballito, Tulancingo', 'tipo': 'farmacia', 'e': '💊', 'lat': 20.0810, 'lng': -98.3900, 'r': 4.9, 'tel': '+527751234572', 'h': 'Lun-Sáb 8:00-21:00', 'dist': '1.3 km', 'tiempo': '6 min', 'suc': 'caballito', 'color': 0xFFE040FB},
    {'id': 'farm_lazaro', 'nom': 'Farmacias Madrid - Suc. Lázaro Cárdenas', 'dir': 'Av. Lázaro Cárdenas, Tulancingo', 'tipo': 'farmacia', 'e': '💊', 'lat': 20.0900, 'lng': -98.3780, 'r': 4.8, 'tel': '+527751234573', 'h': 'Lun-Sáb 8:00-21:00', 'dist': '1.5 km', 'tiempo': '7 min', 'suc': 'lázaro cárdenas', 'color': 0xFFFFD740},
    {'id': 'rest', 'nom': 'El Restaurante de mi Mamá', 'dir': 'Calle Hidalgo 45, Centro, Tulancingo', 'tipo': 'comida', 'e': '🍲', 'lat': 20.0830, 'lng': -98.3790, 'r': 4.9, 'tel': '+527751234568', 'h': 'Lun-Dom 8:00-20:00', 'dist': '0.8 km', 'tiempo': '5 min'},
    {'id': 'regalo', 'nom': 'Regalos Sorpresa de mi Hermana', 'dir': 'Blvd. Felipe Ángeles 78, Tulancingo', 'tipo': 'regalos', 'e': '🎁', 'lat': 20.0860, 'lng': -98.3850, 'r': 4.8, 'tel': '+527751234569', 'h': 'Lun-Sáb 10:00-19:00', 'dist': '1.2 km', 'tiempo': '8 min'},
    {'id': 'hq', 'nom': 'Cargo-GO HQ', 'dir': 'Centro, Tulancingo, Hidalgo', 'tipo': 'oficina', 'e': '📦', 'lat': 20.0833, 'lng': -98.3833, 'r': 5.0, 'tel': '+527751234560', 'h': '24/7', 'dist': '0 km', 'tiempo': '0 min'},
    {'id': 'cdmx', 'nom': 'Hub CDMX', 'dir': 'Col. Centro, Ciudad de México', 'tipo': 'oficina', 'e': '🏙️', 'lat': 19.4326, 'lng': -99.1332, 'r': 4.7, 'tel': '+525512345678', 'h': 'Lun-Vie 7:00-22:00', 'dist': '180 km', 'tiempo': '2h 30min'},
    {'id': 'costco_sat', 'nom': 'Costco Satélite', 'dir': 'Blvd. Manuel Ávila Camacho, Satélite', 'tipo': 'super', 'e': '🛒', 'lat': 19.5098, 'lng': -99.2338, 'r': 4.7, 'tel': '+525598765432', 'h': 'Lun-Dom 9:00-21:00', 'dist': '165 km', 'tiempo': '2h 15min'},
    {'id': 'costco_coy', 'nom': 'Costco Coyoacán', 'dir': 'Av. División del Norte, Coyoacán', 'tipo': 'super', 'e': '🛒', 'lat': 19.3437, 'lng': -99.1574, 'r': 4.6, 'tel': '+525598765433', 'h': 'Lun-Dom 9:00-21:00', 'dist': '195 km', 'tiempo': '2h 45min'},
  ];

  // ═══ MAP MARKER COLOR BY TYPE ═══
  Color _markerColor(String tipo) {
    switch (tipo) {
      case 'farmacia': return const Color(0xFF0D6B4F);
      case 'comida': return const Color(0xFF8B5A00);
      case 'cafe': return const Color(0xFF5C3D1E);
      case 'postres': return const Color(0xFF8B3A62);
      case 'bebidas': return const Color(0xFF7A6B00);
      case 'super': case 'mercado': return const Color(0xFF1A5096);
      case 'mariscos': return const Color(0xFF0A6B6B);
      case 'servicios': return const Color(0xFF4A3580);
      case 'panaderia': return const Color(0xFF6B4A10);
      case 'carniceria': return const Color(0xFF8B2030);
      case 'flores': return const Color(0xFF8B1040);
      case 'regalos': return const Color(0xFF7A3060);
      case 'oficina': return const Color(0xFF3A3080);
      case 'entrega': return const Color(0xFF6B5A00);
      default: return const Color(0xFF6B3030);
    }
  }

  // ═══ MAP MARKERS ═══
  void _updateMapMarkers() {
    _markerData.clear();
    final places = _mapFilter == 'all' ? _mapPlaces :
      _mapPlaces.where((p) => p['tipo'] == _mapFilter).toList();

    // Sucursales y lugares fijos
    for (final p in places) {
      _markerData.add(p);
    }

    // Entregas en ruta (de API real)
    for (int i = 0; i < _apiEntregas.length && i < 20; i++) {
      final e = _apiEntregas[i];
      final lat = e['lat'] as double?;
      final lng = e['lng'] as double?;
      if (lat != null && lng != null) {
        _markerData.add({
          'id': 'entrega_$i', 'nom': 'Entrega #${e['id'] ?? i}', 'dir': e['direccion_destino'] ?? '',
          'e': '📦', 'lat': lat, 'lng': lng, 'tipo': 'entrega', 'estado': e['estado'],
        });
      }
    }

    // Negocios hardcoded (todos con coordenadas)
    final existingIds = _markerData.map((d) => d['id']).toSet();
    for (final n in [...negHidalgo, ...negCdmx]) {
      final coords = _negCoords[n.id];
      if (coords == null || existingIds.contains(n.id)) continue;
      _markerData.add({
        'id': 'neg_${n.id}', 'nom': n.nom, 'dir': n.zona, 'e': n.e,
        'lat': coords[0], 'lng': coords[1], 'tipo': n.tipo, 'r': n.r,
        'plan': 'gratis',
      });
    }

    // Firestore negocios (con coordenadas) — añadir gratis/basico primero, VIP al final para que se dibujen encima
    final fsNonVip = <Map<String, dynamic>>[];
    final fsVip = <Map<String, dynamic>>[];
    for (final n in _firestoreNegocios) {
      final lat = (n['lat'] as num?)?.toDouble();
      final lng = (n['lng'] as num?)?.toDouble();
      if (lat == null || lng == null || lat == 0.0 || lng == 0.0) continue;
      final fid = 'fs_${n['id']}';
      if (existingIds.contains(fid)) continue;
      final plan = (n['plan'] ?? 'gratis').toString();
      final entry = {
        'id': fid, 'nom': n['nombre'] ?? '', 'dir': n['direccion'] ?? n['zona'] ?? '',
        'e': n['emoji'] ?? '🏪', 'lat': lat, 'lng': lng,
        'tipo': n['categoria'] ?? '', 'r': n['rating'] ?? 4.5,
        'plan': plan, 'foto_url': n['foto_url'] ?? '', 'fs_data': n,
      };
      if (plan == 'vip') { fsVip.add(entry); } else { fsNonVip.add(entry); }
    }
    _markerData.addAll(fsNonVip);
    _markerData.addAll(fsVip); // VIP last = drawn on top

    if (mounted) setState(() {});
  }

  // Build flutter_map marker widgets from data
  List<Marker> _buildMapMarkers() {
    final markers = <Marker>[];
    for (final d in _markerData) {
      final lat = d['lat'] as double?;
      final lng = d['lng'] as double?;
      if (lat == null || lng == null) continue;
      final plan = (d['plan'] ?? '').toString();
      final emoji = d['e'] ?? '📍';

      // Plan-based sizing and colors
      double size; Color pinColor; double fontSize; double borderW; bool showLabel; List<BoxShadow> shadows;
      switch (plan) {
        case 'vip':
          size = 52; pinColor = const Color(0xFFFFD700); fontSize = 22; borderW = 2.5;
          showLabel = true;
          shadows = [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.6), blurRadius: 14, spreadRadius: 2), BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.3), blurRadius: 24, spreadRadius: 4)];
        case 'premium':
          size = 40; pinColor = const Color(0xFFFFA502); fontSize = 18; borderW = 2;
          showLabel = true;
          shadows = [BoxShadow(color: const Color(0xFFFFA502).withOpacity(0.4), blurRadius: 10)];
        case 'basico':
          size = 32; pinColor = const Color(0xFFFF4757); fontSize = 15; borderW = 1.5;
          showLabel = false;
          shadows = [BoxShadow(color: const Color(0xFFFF4757).withOpacity(0.3), blurRadius: 6)];
        default: // gratis or unset
          size = 24; pinColor = const Color(0xFF506080); fontSize = 12; borderW = 1;
          showLabel = false;
          shadows = [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)];
      }

      final markerH = showLabel ? size + 16 : size;
      markers.add(Marker(
        point: LatLng(lat, lng), width: size, height: markerH,
        child: GestureDetector(
          onTap: () => setState(() => _selectedMapPlace = d),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: size, height: size,
              decoration: BoxDecoration(
                color: pinColor, shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.8), width: borderW),
                boxShadow: shadows),
              child: Center(child: Text(emoji, style: TextStyle(fontSize: fontSize)))),
            if (showLabel)
              Container(margin: const EdgeInsets.only(top: 2), padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                child: Text(d['nom'] ?? '', style: const TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ])),
      ));
    }
    // Mi ubicación
    if (_currentPos != null) {
      markers.add(Marker(
        point: LatLng(_currentPos!.latitude, _currentPos!.longitude), width: 40, height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.ac, shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: AppTheme.ac.withOpacity(0.6), blurRadius: 12)]),
          child: const Icon(Icons.person, size: 20, color: Colors.white)),
      ));
    }
    return markers;
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
          _markerData.add({
            'id': 'track_$folio', 'nom': folio, 'dir': estado,
            'e': '📦', 'lat': lat, 'lng': lng, 'tipo': 'entrega',
          });
        });
        _mapController.move(LatLng(lat, lng), _mapController.camera.zoom);
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
    final mode = _navModeCar ? 'd' : '2w';
    final travelmode = _navModeCar ? 'driving' : 'two-wheeler';
    final avoid = _avoidTolls ? '&avoid=tolls' : '';
    final uri = Uri.parse('google.navigation:q=$lat,$lng&mode=$mode');
    final webUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=$travelmode$avoid');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  // ═══ TOP BAR (aparece en todas las pantallas) ═══
  Widget _topBar({Widget? bottom}) => Padding(
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
      // Bottom widget o buscador neón por default
      bottom ?? GestureDetector(
        onTap: _showGlobalSearch,
        child: Container(
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
      ),
    ]),
  );

  void _showGlobalSearch() {
    final ctrl = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppTheme.sf,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        final q = ctrl.text.toLowerCase();
        final allNegs = [...negHidalgo, ...negCdmx];
        final negResults = q.length >= 2 ? allNegs.where((n) => n.nom.toLowerCase().contains(q) || n.tipo.toLowerCase().contains(q) || n.zona.toLowerCase().contains(q)).take(8).toList() : <Negocio>[];
        final farmResults = q.length >= 2 ? farmacia.where((f) => f.n.toLowerCase().contains(q) || f.lab.toLowerCase().contains(q)).take(6).toList() : <FarmItem>[];
        final pedResults = q.length >= 2 ? pedidos.where((p) => p.id.toLowerCase().contains(q) || p.cl.toLowerCase().contains(q)).take(4).toList() : <Pedido>[];
        return Padding(padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: ctrl, autofocus: true,
              onChanged: (_) => setS(() {}),
              style: const TextStyle(color: AppTheme.tx, fontSize: 14),
              decoration: InputDecoration(hintText: 'Buscar negocios, medicamentos, pedidos...', hintStyle: const TextStyle(color: AppTheme.td, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppTheme.ac),
                filled: true, fillColor: AppTheme.cd,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12))),
            if (q.length >= 2) ...[
              const SizedBox(height: 12),
              SizedBox(height: MediaQuery.of(ctx).size.height * 0.5, child: ListView(children: [
                if (negResults.isNotEmpty) ...[
                  const Text('🏪 Negocios', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.ac)),
                  const SizedBox(height: 4),
                  ...negResults.map((n) => ListTile(dense: true, contentPadding: EdgeInsets.zero,
                    leading: Text(n.e, style: const TextStyle(fontSize: 20)),
                    title: Text(n.nom, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.tx)),
                    subtitle: Text('${n.tipo} · ${n.zona}', style: const TextStyle(fontSize: 9, color: AppTheme.tm)),
                    onTap: () { Navigator.pop(ctx); setState(() { _tab = 1; _negSearch = n.nom; }); })),
                  const Divider(color: AppTheme.bd, height: 16),
                ],
                if (farmResults.isNotEmpty) ...[
                  const Text('💊 Farmacia', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.gr)),
                  const SizedBox(height: 4),
                  ...farmResults.map((f) => ListTile(dense: true, contentPadding: EdgeInsets.zero,
                    title: Text(f.n, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.tx)),
                    subtitle: Text('${f.lab} · \$${f.oferta}', style: const TextStyle(fontSize: 9, color: AppTheme.tm)),
                    trailing: ElevatedButton(onPressed: () { Navigator.pop(ctx); _addToCart(f.n, f.lista, 'Farmacias Madrid', oferta: f.oferta); },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gr.withOpacity(0.15), foregroundColor: AppTheme.gr,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0),
                      child: const Text('+Agregar', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600))),
                    onTap: () { Navigator.pop(ctx); _addToCart(f.n, f.lista, 'Farmacias Madrid', oferta: f.oferta); })),
                  const Divider(color: AppTheme.bd, height: 16),
                ],
                if (pedResults.isNotEmpty) ...[
                  const Text('📦 Pedidos', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.or)),
                  const SizedBox(height: 4),
                  ...pedResults.map((p) => ListTile(dense: true, contentPadding: EdgeInsets.zero,
                    title: Text(p.id, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.tx)),
                    subtitle: Text('${p.cl} · ${p.orig} → ${p.dest}', style: const TextStyle(fontSize: 9, color: AppTheme.tm)),
                    onTap: () { Navigator.pop(ctx); _rastrearPedido(p.id); })),
                ],
                if (negResults.isEmpty && farmResults.isEmpty && pedResults.isEmpty)
                  const Padding(padding: EdgeInsets.all(20), child: Text('Sin resultados', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.td))),
              ])),
            ],
          ]));
      }));
  }

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

  void _showQuickOrder(Negocio n) {
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    int? selectedPrice;
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppTheme.sf,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(n.e, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(n.nom, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.tx)),
                Text(n.tipo, style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
              ])),
              IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: AppTheme.tm)),
            ]),
            const SizedBox(height: 14),
            TextField(controller: descCtrl, style: const TextStyle(color: AppTheme.tx, fontSize: 13),
              decoration: InputDecoration(hintText: '¿Qué quieres pedir?', hintStyle: const TextStyle(color: AppTheme.td, fontSize: 13),
                prefixIcon: const Icon(Icons.edit_note, color: AppTheme.ac, size: 20),
                filled: true, fillColor: AppTheme.cd,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.ac)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
            const SizedBox(height: 14),
            const Text('Precio estimado', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tm)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [50, 100, 200, 500, 0].map((p) {
              final label = p == 0 ? 'Otro' : '\$$p';
              final sel = selectedPrice == p;
              return GestureDetector(onTap: () => setS(() { selectedPrice = p; if (p > 0) priceCtrl.clear(); }),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: sel ? AppTheme.ac.withOpacity(0.15) : AppTheme.cd,
                    borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppTheme.ac : AppTheme.bd, width: 1.2)),
                  child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? AppTheme.ac : AppTheme.tm))));
            }).toList()),
            if (selectedPrice == 0) ...[
              const SizedBox(height: 10),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: AppTheme.tx, fontSize: 13),
                decoration: InputDecoration(hintText: 'Escribe el precio', hintStyle: const TextStyle(color: AppTheme.td, fontSize: 13),
                  prefixIcon: const Icon(Icons.attach_money, color: AppTheme.gr, size: 20),
                  filled: true, fillColor: AppTheme.cd,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.gr)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
            ],
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 44, child: ElevatedButton(
              onPressed: () {
                final desc = descCtrl.text.trim();
                if (desc.isEmpty) return;
                int? price = selectedPrice;
                if (price == 0) price = int.tryParse(priceCtrl.text.trim());
                if (price == null || price <= 0) return;
                Navigator.pop(ctx);
                _addToCart(desc, price, n.nom);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gr, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
              child: const Text('Agregar al carrito 🛒', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)))),
          ]));
      }));
  }

  Widget _fsFallback(String emoji, Color c) {
    return Container(color: c.withOpacity(0.10),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 40))));
  }

  void _showPhotoPickerDialog(String negocioId, String negocioName) {
    showModalBottomSheet(context: context, backgroundColor: AppTheme.sf,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Foto de $negocioName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          const SizedBox(height: 16),
          ListTile(leading: const Icon(Icons.camera_alt, color: AppTheme.ac), title: const Text('Cámara', style: TextStyle(color: AppTheme.tx)),
            onTap: () { Navigator.pop(context); _pickAndUploadPhoto(negocioId, ImageSource.camera); }),
          ListTile(leading: const Icon(Icons.photo_library, color: AppTheme.gr), title: const Text('Galería', style: TextStyle(color: AppTheme.tx)),
            onTap: () { Navigator.pop(context); _pickAndUploadPhoto(negocioId, ImageSource.gallery); }),
        ])));
  }

  Future<void> _pickAndUploadPhoto(String negocioId, ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(source: source, maxWidth: 1200, imageQuality: 80);
      if (picked == null) return;
      if (!mounted) return;
      showDialog(context: context, barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: AppTheme.ac)));
      final bytes = await picked.readAsBytes();
      await FirestoreService.uploadNegocioPhoto(negocioId, bytes);
      if (!mounted) return;
      Navigator.pop(context); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto actualizada'), backgroundColor: AppTheme.gr));
      _loadFirestoreNegocios(); // refresh list
    } catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.rd));
    }
  }

  void _showQuickOrderFs(Map<String, dynamic> n) {
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    int? selectedPrice;
    final nombre = (n['nombre'] ?? 'Negocio').toString();
    final emoji = (n['emoji'] ?? '🏪').toString();
    final cat = (n['categoria'] ?? '').toString();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppTheme.sf,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(nombre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.tx)),
                Text(cat, style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
              ])),
              IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, color: AppTheme.tm)),
            ]),
            const SizedBox(height: 14),
            TextField(controller: descCtrl, style: const TextStyle(color: AppTheme.tx, fontSize: 13),
              decoration: InputDecoration(hintText: '¿Qué quieres pedir?', hintStyle: const TextStyle(color: AppTheme.td, fontSize: 13),
                prefixIcon: const Icon(Icons.edit_note, color: AppTheme.ac, size: 20),
                filled: true, fillColor: AppTheme.cd,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.ac)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
            const SizedBox(height: 14),
            const Text('Precio estimado', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tm)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [50, 100, 200, 500, 0].map((p) {
              final label = p == 0 ? 'Otro' : '\$$p';
              final sel = selectedPrice == p;
              return GestureDetector(onTap: () => setS(() { selectedPrice = p; if (p > 0) priceCtrl.clear(); }),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: sel ? AppTheme.ac.withOpacity(0.15) : AppTheme.cd,
                    borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppTheme.ac : AppTheme.bd, width: 1.2)),
                  child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? AppTheme.ac : AppTheme.tm))));
            }).toList()),
            if (selectedPrice == 0) ...[
              const SizedBox(height: 10),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: AppTheme.tx, fontSize: 13),
                decoration: InputDecoration(hintText: 'Escribe el precio', hintStyle: const TextStyle(color: AppTheme.td, fontSize: 13),
                  prefixIcon: const Icon(Icons.attach_money, color: AppTheme.gr, size: 20),
                  filled: true, fillColor: AppTheme.cd,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.gr)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
            ],
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 44, child: ElevatedButton(
              onPressed: () {
                final desc = descCtrl.text.trim();
                if (desc.isEmpty) return;
                int? price = selectedPrice;
                if (price == 0) price = int.tryParse(priceCtrl.text.trim());
                if (price == null || price <= 0) return;
                Navigator.pop(ctx);
                _addToCart(desc, price, nombre);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gr, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
              child: const Text('Agregar al carrito 🛒', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)))),
          ]));
      }));
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
          // Resumen de pago
          const SizedBox(height: 12),
          _row('Subtotal', '\$$_cartTotal'),
          _row('Envíos (${groups.keys.length})', '\$$envios'),
          _row('🪐 Saturnos', '+$pts pts', c: AppTheme.tl),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.tx)),
            Text('\$${_cartTotal + envios}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.tx, fontFamily: 'monospace')),
          ]),
          const SizedBox(height: 6),
          // Métodos de pago info
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF00B2E8).withOpacity(0.08), borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF00B2E8).withOpacity(0.3))),
            child: const Row(children: [
              Icon(Icons.info_outline, size: 14, color: Color(0xFF00B2E8)),
              SizedBox(width: 6),
              Expanded(child: Text('Paga con tarjeta, OXXO, SPEI o saldo MercadoPago', style: TextStyle(fontSize: 9, color: Color(0xFF00B2E8)))),
            ])),
          const SizedBox(height: 12),
          // Botón MercadoPago
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () async {
              final total = (_cartTotal + envios).toDouble();
              Navigator.pop(ctx);
              final ok = await MercadoPagoService.pagarCarrito(
                subtotal: _cartTotal.toDouble(), envio: envios.toDouble(), items: _cart.length);
              if (ok) { setState(() => _cart.clear()); _showCheckout(); }
              else { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Error al conectar con MercadoPago', style: TextStyle(color: Colors.white)),
                backgroundColor: Color(0xFFFF4757))); }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B2E8), padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.payment, size: 18, color: Colors.white),
              SizedBox(width: 8),
              Text('Pagar con MercadoPago', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
            ]),
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
        heroTag: 'mainCart',
        icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
        label: Text('🛒 $_cartQty · \$$_cartTotal', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
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
      onTap: () { setState(() => _tab = i); if (i == 2 && _markerData.isEmpty) _updateMapMarkers(); },
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
    else if (_menuScreen == 'compras') { return _comprasScreen(); }
    else if (_menuScreen != null && _menuScreen!.startsWith('vip_')) { return _vipScreen(_menuScreen!.substring(4)); }
    else { return _farmScreen(); }
    return _menuView(title, menu, color, from);
  }

  // ═══ FULL MAP SCREEN ═══
  Widget _fullMapScreen() {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        // ── Flutter Map (full screen) ──
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _mapCenter, initialZoom: 12,
            onTap: (_, __) => setState(() => _selectedMapPlace = null),
            onMapReady: () {
              _mapReady = true;
              _getCurrentLocation();
              _updateMapMarkers();
            },
          ),
          children: [
            TileLayer(urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd']),
            MarkerLayer(markers: _buildMapMarkers()),
          ],
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
                  onSubmitted: (v) {
                    if (v.trim().isEmpty) return;
                    final q = v.toLowerCase();
                    final match = _markerData.where((d) => (d['nom'] ?? '').toString().toLowerCase().contains(q) || (d['dir'] ?? '').toString().toLowerCase().contains(q)).toList();
                    if (match.isNotEmpty) {
                      final d = match.first;
                      final lat = d['lat'] as double?;
                      final lng = d['lng'] as double?;
                      if (lat != null && lng != null) {
                        _mapController.move(LatLng(lat, lng), 15);
                        setState(() => _selectedMapPlace = d);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('No encontrado', style: TextStyle(color: Colors.white)),
                        backgroundColor: AppTheme.rd, duration: Duration(seconds: 2)));
                    }
                  },
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
                child: const Icon(Icons.my_location, size: 20, color: Color(0xFF34A853)))),
            const SizedBox(height: 8),
            GestureDetector(onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
              child: Container(width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.cd.withOpacity(0.95), shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.bd, width: 0.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]),
                child: const Icon(Icons.add, size: 20, color: AppTheme.tx))),
            const SizedBox(height: 8),
            GestureDetector(onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1),
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
          if (place['suc'] != null)
            Container(width: 44, height: 44, decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(place['color'] as int), Color.lerp(Color(place['color'] as int), Colors.black, 0.3)!]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Color(place['color'] as int).withOpacity(0.4), blurRadius: 8)]),
              child: const Center(child: Text('✚', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w900))))
          else
            Container(width: 44, height: 44, decoration: BoxDecoration(
              color: AppTheme.ac.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(place['e'] ?? '📍', style: const TextStyle(fontSize: 22)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(place['nom'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx)),
            if (place['suc'] != null)
              Text('Sucursal ${(place['suc'] as String)[0].toUpperCase()}${(place['suc'] as String).substring(1)}${place['suc'] == 'matriz' ? ' (Principal)' : ''}',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(place['color'] as int))),
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
            onTap: () {
              final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
            child: Container(width: 44, height: 44, decoration: BoxDecoration(
              color: AppTheme.bg, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.bd)),
              child: const Icon(Icons.share, size: 18, color: AppTheme.tm))),
          const SizedBox(width: 8),
          // BOOKMARK
          Builder(builder: (ctx) {
            final placeId = place['id'] as String? ?? '';
            final isFav = _favs.contains(placeId);
            return GestureDetector(
              onTap: () {
                setState(() { if (isFav) _favs.remove(placeId); else _favs.add(placeId); });
              },
              child: Container(width: 44, height: 44, decoration: BoxDecoration(
                color: isFav ? AppTheme.yl.withOpacity(0.15) : AppTheme.bg, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isFav ? AppTheme.yl : AppTheme.bd)),
                child: Icon(isFav ? Icons.bookmark : Icons.bookmark_border, size: 18, color: isFav ? AppTheme.yl : AppTheme.tm)));
          }),
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
        _dashCard('🛒', 'Mandados\nLocal', sMandados, Icons.arrow_outward, AppTheme.cd, 'compras'),
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
            ClipRRect(borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/images/farmacia_madrid_logo.png', width: 48, height: 48, fit: BoxFit.cover)),
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
            n['id']?.toString() ?? 'api',
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
                _entregaAction('Navegar', Icons.navigation, const Color(0xFF34A853), () {
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
    final useFirestore = _firestoreNegocios.isNotEmpty;
    // Firestore negocios filtrados
    final fsAll = useFirestore
        ? (_negCity == 'all' ? _firestoreNegocios
           : _firestoreNegocios.where((n) => _negCity == 'hidalgo' ? n['ciudad'] == 'tulancingo' : n['ciudad'] == 'cdmx').toList())
        : <Map<String, dynamic>>[];
    final fsFiltered = fsAll.where((n) {
      final nom = (n['nombre'] ?? '').toString().toLowerCase();
      final desc = (n['desc'] ?? '').toString().toLowerCase();
      final mq = _negSearch.isEmpty || nom.contains(_negSearch.toLowerCase()) || desc.contains(_negSearch.toLowerCase());
      final mt = _negTipo == 'all' || n['categoria'] == _negTipo;
      return mq && mt;
    }).toList();
    final fsTulancingo = useFirestore ? _firestoreNegocios.where((n) => n['ciudad'] == 'tulancingo').length : negHidalgo.length;
    final fsCdmx = useFirestore ? _firestoreNegocios.where((n) => n['ciudad'] == 'cdmx').length : negCdmx.length;

    // Fallback: hardcoded negocios
    final all = _negCity == 'all' ? [...negHidalgo, ...negCdmx] : _negCity == 'hidalgo' ? negHidalgo : negCdmx;
    final filtered = useFirestore ? <Negocio>[] : all.where((n) {
      final mq = _negSearch.isEmpty || n.nom.toLowerCase().contains(_negSearch.toLowerCase()) || n.desc.toLowerCase().contains(_negSearch.toLowerCase());
      final mt = _negTipo == 'all' || n.tipo == _negTipo;
      return mq && mt;
    }).toList();
    // API negocios filtrados
    final apiFiltered = _apiNegocios.where((n) {
      final mq = _negSearch.isEmpty || (n['nombre'] ?? '').toString().toLowerCase().contains(_negSearch.toLowerCase());
      return mq;
    }).toList();
    final totalLocal = useFirestore ? _firestoreNegocios.length : negHidalgo.length + negCdmx.length;
    final totalApi = _apiNegocios.length;
    final totalAll = useFirestore ? totalLocal : totalLocal + totalApi;

    return RefreshIndicator(onRefresh: () async { await _loadApiData(); await _loadFirestoreNegocios(); }, color: AppTheme.ac,
      child: ListView(padding: const EdgeInsets.all(14), children: [
      _topBar(bottom: const SizedBox.shrink()),
      // City filter - outlined rounded
      Row(children: [
        _cityBtn('all', '🗺️ Todos ($totalAll)'),
        _cityBtn('hidalgo', '🏔️ Hidalgo ($fsTulancingo)'),
        _cityBtn('cdmx', '🏙️ CDMX ($fsCdmx)'),
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
      // Banner suscripción de negocios
      GestureDetector(
        onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
          backgroundColor: AppTheme.sf, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🏪', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 10),
            const Text('Suscripción Marketplace', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.tx)),
            const SizedBox(height: 6),
            const Text('Registra tu negocio en Cargo-GO y recibe pedidos de toda la ciudad.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppTheme.tm)),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(12)),
              child: Column(children: const [
                Text('\$500 MXN/mes', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.tx)),
                SizedBox(height: 6),
                Text('✅ Perfil en el marketplace\n✅ Recibe pedidos ilimitados\n✅ Mapa con tu ubicación\n✅ Pagos con MercadoPago\n✅ Soporte prioritario',
                  style: TextStyle(fontSize: 11, color: AppTheme.tm, height: 1.6)),
              ])),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final ok = await MercadoPagoService.pagarSuscripcion(nombreNegocio: 'Mi Negocio');
                if (!ok && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Error al conectar con MercadoPago'), backgroundColor: Color(0xFFFF4757)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B2E8), padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.payment, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text('Suscribirse · \$500/mes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
              ]))),
          ]))),
        child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00B2E8), Color(0xFF009EE3)]),
            borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Text('🏪', style: TextStyle(fontSize: 22)))),
            const SizedBox(width: 10),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('¿Tienes un negocio?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
              Text('Regístrate en el Marketplace · \$500/mes', style: TextStyle(fontSize: 10, color: Colors.white70)),
            ])),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white70),
          ])),
      ),
      Row(children: [
        Text('${useFirestore ? fsFiltered.length : filtered.length + apiFiltered.length} resultados', style: const TextStyle(fontSize: 10, color: AppTheme.td)),
        if (useFirestore) ...[
          const Text(' · ', style: TextStyle(fontSize: 10, color: AppTheme.td)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppTheme.gr.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Text('🔥 Firestore', style: TextStyle(fontSize: 8, color: AppTheme.gr))),
        ] else if (_apiNegocios.isNotEmpty) ...[
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
                const Icon(Icons.location_on, size: 10, color: Color(0xFF34A853)),
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
      // Loading indicator
      if (_loadingFirestore) ...[
        const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppTheme.ac, strokeWidth: 2))),
      ],
      // ── Firestore Grid (cuando hay datos) ──
      if (useFirestore) ...[
        // Costco special card from Firestore
        if (fsFiltered.any((n) => n['id'] == 'c81')) ...[
          Builder(builder: (_) {
            final costco = fsFiltered.firstWhere((n) => n['id'] == 'c81');
            return GestureDetector(onTap: () => _showQuickOrderFs(costco),
              child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF005DAA), Color(0xFF0073CF)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: const Color(0xFF005DAA).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]),
                child: Row(children: [
                  Container(width: 56, height: 56, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text(costco['emoji'] ?? '🛒', style: const TextStyle(fontSize: 30)))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(costco['nombre'] ?? 'Costco', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(costco['desc'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text('📍 ${costco['direccion'] ?? costco['zona'] ?? ''}', style: const TextStyle(fontSize: 10, color: Colors.white54)),
                    Text('⭐ ${costco['rating'] ?? 4.7} · ${costco['pedidos'] ?? 0}+ pedidos', style: const TextStyle(fontSize: 10, color: Colors.white54)),
                  ])),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white70),
                ])));
          }),
        ],
        LayoutBuilder(builder: (context, constraints) {
          final w = constraints.maxWidth;
          final cols = w > 900 ? 4 : w > 600 ? 3 : 2;
          final cards = fsFiltered.where((n) => n['id'] != 'c81').toList();
          // Sort: VIP first, then premium, basico, gratis
          const planOrder = {'vip': 0, 'premium': 1, 'basico': 2, 'gratis': 3};
          cards.sort((a, b) => (planOrder[a['plan'] ?? 'gratis'] ?? 3).compareTo(planOrder[b['plan'] ?? 'gratis'] ?? 3));
          return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.42),
            itemCount: cards.length, itemBuilder: (_, i) {
              final n = cards[i];
              final lat = (n['lat'] as num?)?.toDouble() ?? 0.0;
              final lng = (n['lng'] as num?)?.toDouble() ?? 0.0;
              final hasCoords = lat != 0.0 && lng != 0.0;
              final fotoUrl = (n['foto_url'] ?? '').toString();
              final hasFoto = fotoUrl.isNotEmpty;
              final emoji = (n['emoji'] ?? '🏪').toString();
              final colorHex = (n['color_hex'] ?? '#FFA502').toString();
              final c = Color(int.parse('FF${colorHex.replaceAll('#', '')}', radix: 16));
              final nombre = (n['nombre'] ?? '').toString();
              final desc = (n['desc'] ?? '').toString();
              final rating = n['rating'] ?? 4.5;
              final cat = (n['categoria'] ?? '').toString();
              final zona = (n['direccion'] ?? n['zona'] ?? '').toString();
              final horario = (n['horario'] ?? '').toString();
              final tel = (n['telefono'] ?? '').toString();
              final pedidos = n['pedidos'] ?? 0;
              final plan = (n['plan'] ?? 'gratis').toString();
              // Plan-based card styling
              final Color borderColor; final double borderWidth; final String? badge;
              final List<BoxShadow> cardShadows;
              switch (plan) {
                case 'vip':
                  borderColor = const Color(0xFFFFD700); borderWidth = 2.0; badge = 'VIP';
                  cardShadows = [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.2), blurRadius: 12, spreadRadius: 1)];
                case 'premium':
                  borderColor = const Color(0xFFFFA502); borderWidth = 1.5; badge = 'PREMIUM';
                  cardShadows = [BoxShadow(color: const Color(0xFFFFA502).withOpacity(0.15), blurRadius: 8)];
                case 'basico':
                  borderColor = c; borderWidth = 1.2; badge = null;
                  cardShadows = [];
                default:
                  borderColor = const Color(0xFF506080); borderWidth = 0.8; badge = null;
                  cardShadows = [];
              }
              final previewItems = (plan == 'vip' && n['productos_preview'] is List) ? (n['productos_preview'] as List).take(3).toList() : [];
              return GestureDetector(
                onTap: plan == 'vip' ? () => setState(() => _menuScreen = 'vip_${n['id']}') : null,
                child: Container(decoration: BoxDecoration(
                color: Colors.transparent, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor.withOpacity(plan == 'gratis' ? 0.2 : 0.5), width: borderWidth),
                boxShadow: cardShadows),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Foto + badge + edit button
                  Stack(children: [
                    ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(19), topRight: Radius.circular(19)),
                      child: SizedBox(height: 110, width: double.infinity,
                        child: hasFoto
                          ? Image.network(fotoUrl, fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) => progress == null ? child : _fsFallback(emoji, c),
                              errorBuilder: (_, __, ___) => _fsFallback(emoji, c))
                          : _fsFallback(emoji, c))),
                    Positioned(top: 4, right: 4, child: GestureDetector(
                      onTap: () => _showPhotoPickerDialog(n['id'].toString(), nombre),
                      child: Container(padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white)))),
                    if (badge != null) Positioned(top: 6, left: 6, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: plan == 'vip'
                          ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)])
                          : const LinearGradient(colors: [Color(0xFFFFA502), Color(0xFFFF8C00)]),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: borderColor.withOpacity(0.4), blurRadius: 6)]),
                      child: Text(badge, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)))),
                  ]),
                  // Info
                  Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(10, 8, 10, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(nombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.tx), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: AppTheme.or.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: Text('⭐ $rating', style: const TextStyle(fontSize: 9, color: AppTheme.or, fontWeight: FontWeight.w700))),
                    ]),
                    const SizedBox(height: 2),
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: Text('$emoji $cat', style: TextStyle(fontSize: 8, color: c, fontWeight: FontWeight.w600))),
                      const SizedBox(width: 4),
                      Expanded(child: Text(desc, style: const TextStyle(fontSize: 9, color: AppTheme.tm), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ]),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: hasCoords ? () => launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'), mode: LaunchMode.externalApplication) : null,
                      child: Row(children: [
                        const Icon(Icons.location_on, size: 12, color: Color(0xFF34A853)),
                        const SizedBox(width: 3),
                        Expanded(child: Text(zona, style: TextStyle(fontSize: 10, color: hasCoords ? const Color(0xFF34A853) : AppTheme.td, decoration: hasCoords ? TextDecoration.underline : null), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ])),
                    const SizedBox(height: 3),
                    if (horario.isNotEmpty) Row(children: [
                      const Icon(Icons.access_time, size: 11, color: AppTheme.cy),
                      const SizedBox(width: 3),
                      Text(horario, style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
                    ]),
                    const SizedBox(height: 3),
                    if (tel.isNotEmpty) GestureDetector(
                      onTap: () => launchUrl(Uri.parse('tel:$tel')),
                      child: Row(children: [
                        const Icon(Icons.phone, size: 11, color: AppTheme.ac),
                        const SizedBox(width: 3),
                        Text(tel, style: const TextStyle(fontSize: 10, color: AppTheme.ac, decoration: TextDecoration.underline)),
                      ])),
                    // VIP preview items
                    if (previewItems.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      const Divider(color: AppTheme.bd, height: 1),
                      const SizedBox(height: 4),
                      for (final item in previewItems)
                        Padding(padding: const EdgeInsets.only(bottom: 3), child: Row(children: [
                          Text((item['foto_url'] ?? '📦').toString().isNotEmpty && (item['foto_url'] ?? '').toString().startsWith('http') ? '📦' : '📦', style: const TextStyle(fontSize: 10)),
                          const SizedBox(width: 4),
                          Expanded(child: Text((item['nombre'] ?? '').toString(), style: const TextStyle(fontSize: 9, color: AppTheme.tx), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          Text('\$${item['precio'] ?? 0}', style: const TextStyle(fontSize: 9, color: AppTheme.gr, fontWeight: FontWeight.w700)),
                        ])),
                    ],
                    const Spacer(),
                    Text('$pedidos pedidos', style: TextStyle(fontSize: 9, color: plan == 'gratis' ? AppTheme.td.withOpacity(0.5) : AppTheme.td)),
                    const SizedBox(height: 6),
                    if (hasCoords) Padding(padding: const EdgeInsets.only(bottom: 4), child:
                      SizedBox(width: double.infinity, height: 30, child: OutlinedButton.icon(
                        onPressed: () => _openNavigation(lat, lng, nombre),
                        icon: const Icon(Icons.directions, size: 14),
                        label: const Text('Cómo llegar', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF34A853),
                          side: const BorderSide(color: Color(0xFF34A853), width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.zero)))),
                    SizedBox(width: double.infinity, height: 32, child: ElevatedButton(
                      onPressed: plan == 'vip' ? () => setState(() => _menuScreen = 'vip_${n['id']}') : () => _showQuickOrderFs(n),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: plan == 'vip' ? const Color(0xFFFFD700) : const Color(0xFF34A853),
                        foregroundColor: plan == 'vip' ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.zero, elevation: 0),
                      child: Text(plan == 'vip' ? 'Ver Tienda' : 'Pedir Ahora', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)))),
                  ]))),
                ])));
            });
        }),
      ] else ...[
      // ── Fallback: Costco + hardcoded grid ──
      if (filtered.any((n) => n.id == 'c81')) ...[
        GestureDetector(onTap: () { final costco = filtered.firstWhere((n) => n.id == 'c81'); _showQuickOrder(costco); },
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
      LayoutBuilder(builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w > 900 ? 4 : w > 600 ? 3 : 2;
        final cards = filtered.where((n) => n.id != 'c81').toList();
        return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.42),
          itemCount: cards.length, itemBuilder: (_, i) {
            final n = cards[i];
            final coords = _negCoords[n.id];
            final hasCoords = coords != null;
            final lat = hasCoords ? coords[0] : 0.0;
            final lng = hasCoords ? coords[1] : 0.0;
            return Container(decoration: BoxDecoration(
              color: Colors.transparent, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: n.c.withOpacity(0.3), width: 1.2)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(19), topRight: Radius.circular(19)),
                  child: SizedBox(height: 110, width: double.infinity,
                    child: hasCoords
                      ? Image.network(
                          PlacesPhotoService.satelliteUrl(lat, lng),
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) => progress == null ? child : _negCardFallback(n),
                          errorBuilder: (_, __, ___) => _negCardFallback(n))
                      : _negCardFallback(n))),
                Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(10, 8, 10, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(n.nom, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.tx), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: AppTheme.or.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text('⭐ ${n.r}', style: const TextStyle(fontSize: 9, color: AppTheme.or, fontWeight: FontWeight.w700))),
                  ]),
                  const SizedBox(height: 2),
                  Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: n.c.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text('${n.e} ${n.tipo}', style: TextStyle(fontSize: 8, color: n.c, fontWeight: FontWeight.w600))),
                    const SizedBox(width: 4),
                    Expanded(child: Text(n.desc, style: const TextStyle(fontSize: 9, color: AppTheme.tm), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: hasCoords ? () => launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'), mode: LaunchMode.externalApplication) : null,
                    child: Row(children: [
                      const Icon(Icons.location_on, size: 12, color: Color(0xFF34A853)),
                      const SizedBox(width: 3),
                      Expanded(child: Text(n.zona, style: TextStyle(fontSize: 10, color: hasCoords ? const Color(0xFF34A853) : AppTheme.td, decoration: hasCoords ? TextDecoration.underline : null), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ])),
                  const SizedBox(height: 3),
                  if (n.horario != null) Row(children: [
                    const Icon(Icons.access_time, size: 11, color: AppTheme.cy),
                    const SizedBox(width: 3),
                    Text(n.horario!, style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
                  ]),
                  const SizedBox(height: 3),
                  if (n.tel != null) GestureDetector(
                    onTap: () => launchUrl(Uri.parse('tel:${n.tel}')),
                    child: Row(children: [
                      const Icon(Icons.phone, size: 11, color: AppTheme.ac),
                      const SizedBox(width: 3),
                      Text(n.tel!, style: const TextStyle(fontSize: 10, color: AppTheme.ac, decoration: TextDecoration.underline)),
                    ])),
                  const Spacer(),
                  Text('${n.ped} pedidos', style: const TextStyle(fontSize: 9, color: AppTheme.td)),
                  const SizedBox(height: 6),
                  if (hasCoords) Padding(padding: const EdgeInsets.only(bottom: 4), child:
                    SizedBox(width: double.infinity, height: 30, child: OutlinedButton.icon(
                      onPressed: () => _openNavigation(lat, lng, n.nom),
                      icon: const Icon(Icons.directions, size: 14),
                      label: const Text('Cómo llegar', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF34A853),
                        side: const BorderSide(color: Color(0xFF34A853), width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.zero)))),
                  SizedBox(width: double.infinity, height: 32, child: ElevatedButton(
                    onPressed: () { if (n.menu != null) setState(() => _menuScreen = n.menu); else _showQuickOrder(n); },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF34A853), foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero, elevation: 0),
                    child: const Text('Pedir Ahora', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)))),
                ]))),
              ]));
          });
      }),
      ],
    ]));
  }

  // Fallback visual para tarjeta de negocio (sin foto real)
  Widget _negCardFallback(Negocio n) => Container(
    decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [n.c.withOpacity(0.3), n.c.withOpacity(0.08)])),
    child: Center(child: Text(n.e, style: const TextStyle(fontSize: 44))));

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
        heroTag: 'menuCart',
        icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
        label: Text('🛒 $_cartQty · \$$_cartTotal', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white))) : null,
    ));
  }

  // ═══ COMPRAS EN TIENDA ═══
  static const _tiendas = [
    {'id': 'costco', 'nom': 'Costco', 'icon': '🏪', 'url': 'https://www.costco.com.mx', 'color': 0xFF005DAA},
    {'id': 'walmart', 'nom': 'Walmart', 'icon': '🛒', 'url': 'https://www.walmart.com.mx', 'color': 0xFF0071CE},
    {'id': 'sams', 'nom': "Sam's Club", 'icon': '🏬', 'url': 'https://www.sams.com.mx', 'color': 0xFF0060A9},
    {'id': 'soriana', 'nom': 'Soriana', 'icon': '🛍️', 'url': 'https://www.soriana.com', 'color': 0xFFE31837},
    {'id': 'chedraui', 'nom': 'Chedraui', 'icon': '🏪', 'url': 'https://www.chedraui.com.mx', 'color': 0xFF00843D},
    {'id': 'aurrera', 'nom': 'Bodega Aurrera', 'icon': '💛', 'url': 'https://www.bodegaaurrera.com.mx', 'color': 0xFFFFD700},
    {'id': 'lacomer', 'nom': 'La Comer', 'icon': '🛒', 'url': 'https://www.lacomer.com.mx', 'color': 0xFFD32F2F},
    {'id': 'homedepot', 'nom': 'Home Depot', 'icon': '🔨', 'url': 'https://www.homedepot.com.mx', 'color': 0xFFF96302},
    {'id': 'liverpool', 'nom': 'Liverpool', 'icon': '🎀', 'url': 'https://www.liverpool.com.mx', 'color': 0xFFE91E8C},
    {'id': 'farmagdl', 'nom': 'Farmacias Guadalajara', 'icon': '💊', 'url': 'https://www.farmaciasguadalajara.com', 'color': 0xFF00A651},
  ];

  // ═══ VIP DETAIL SCREEN ═══
  Widget _vipScreen(String negocioId) {
    final n = _firestoreNegocios.firstWhere((x) => x['id'] == negocioId, orElse: () => <String, dynamic>{});
    if (n.isEmpty) {
      return Scaffold(backgroundColor: AppTheme.bg,
        appBar: AppBar(backgroundColor: AppTheme.sf, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _menuScreen = null)),
          title: const Text('Negocio no encontrado')),
        body: const Center(child: Text('Este negocio no está disponible', style: TextStyle(color: AppTheme.tm))));
    }
    final nombre = (n['nombre'] ?? '').toString();
    final emoji = (n['emoji'] ?? '🏪').toString();
    final desc = (n['desc'] ?? '').toString();
    final rating = (n['rating'] ?? 4.5);
    final cat = (n['categoria'] ?? '').toString();
    final zona = (n['direccion'] ?? n['zona'] ?? '').toString();
    final horario = (n['horario'] ?? '').toString();
    final tel = (n['telefono'] ?? '').toString();
    final colorHex = (n['color_hex'] ?? '#FFD700').toString();
    final c = Color(int.parse('FF${colorHex.replaceAll('#', '')}', radix: 16));
    final fotoUrl = (n['foto_url'] ?? '').toString();
    final bannerUrl = (n['banner_url'] ?? fotoUrl).toString();
    final galeria = n['galeria'] is List ? (n['galeria'] as List).cast<String>() : <String>[];
    final productosPreview = n['productos_preview'] is List ? (n['productos_preview'] as List) : [];
    final lat = (n['lat'] as num?)?.toDouble() ?? 0.0;
    final lng = (n['lng'] as num?)?.toDouble() ?? 0.0;
    final hasCoords = lat != 0.0 && lng != 0.0;

    return Scaffold(backgroundColor: AppTheme.bg,
      body: Stack(children: [
        CustomScrollView(slivers: [
          // ── Collapsing AppBar with banner ──
          SliverAppBar(expandedHeight: 200, pinned: true, backgroundColor: AppTheme.sf,
            leading: IconButton(icon: Container(padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back, size: 20, color: Colors.white)),
              onPressed: () => setState(() => _menuScreen = null)),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(nombre, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, shadows: [Shadow(color: Colors.black, blurRadius: 8)])),
              background: Stack(fit: StackFit.expand, children: [
                bannerUrl.isNotEmpty
                  ? Image.network(bannerUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: c.withOpacity(0.3), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 60)))))
                  : Container(color: c.withOpacity(0.3), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 60)))),
                const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87]))),
              ]),
            ),
            actions: [
              Container(margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)]),
                  borderRadius: BorderRadius.circular(12)),
                child: const Text('VIP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1))),
            ]),

          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ── Rating + Category ──
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text('$emoji $cat', style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600))),
              const SizedBox(width: 8),
              Row(children: List.generate(5, (i) => Icon(
                i < rating.round() ? Icons.star : Icons.star_border, size: 16,
                color: const Color(0xFFFFD700)))),
              const SizedBox(width: 4),
              Text('$rating', style: const TextStyle(fontSize: 12, color: AppTheme.or, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 10),

            // ── Description ──
            if (desc.isNotEmpty) ...[
              Text(desc, style: const TextStyle(fontSize: 13, color: AppTheme.tm, height: 1.4)),
              const SizedBox(height: 14),
            ],

            // ── Info Row ──
            Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2))),
              child: Column(children: [
                if (horario.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
                  const Icon(Icons.access_time, size: 16, color: AppTheme.cy),
                  const SizedBox(width: 8),
                  Text(horario, style: const TextStyle(fontSize: 12, color: AppTheme.tx)),
                ])),
                if (tel.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 8), child: GestureDetector(
                  onTap: () => launchUrl(Uri.parse('tel:$tel')),
                  child: Row(children: [
                    const Icon(Icons.phone, size: 16, color: AppTheme.ac),
                    const SizedBox(width: 8),
                    Text(tel, style: const TextStyle(fontSize: 12, color: AppTheme.ac, decoration: TextDecoration.underline)),
                  ]))),
                if (zona.isNotEmpty) GestureDetector(
                  onTap: hasCoords ? () => launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'), mode: LaunchMode.externalApplication) : null,
                  child: Row(children: [
                    const Icon(Icons.location_on, size: 16, color: Color(0xFF34A853)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(zona, style: TextStyle(fontSize: 12, color: hasCoords ? const Color(0xFF34A853) : AppTheme.tx,
                      decoration: hasCoords ? TextDecoration.underline : null))),
                  ])),
              ])),
            const SizedBox(height: 18),

            // ── Galería ──
            if (galeria.isNotEmpty) ...[
              const Text('Galería', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.tx)),
              const SizedBox(height: 8),
              SizedBox(height: 120, child: ListView.separated(scrollDirection: Axis.horizontal,
                itemCount: galeria.length, separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => ClipRRect(borderRadius: BorderRadius.circular(12),
                  child: Image.network(galeria[i], width: 160, height: 120, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 160, height: 120, color: AppTheme.cd,
                      child: const Center(child: Icon(Icons.image_not_supported, color: AppTheme.td))))))),
              const SizedBox(height: 18),
            ],

            // ── Productos / Menú ──
            if (productosPreview.isNotEmpty) ...[
              const Text('Menú / Productos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.tx)),
              const SizedBox(height: 10),
              ...productosPreview.map((item) {
                final itemName = (item['nombre'] ?? '').toString();
                final itemPrice = item['precio'] ?? 0;
                final itemFoto = (item['foto_url'] ?? '').toString();
                return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.bd)),
                  child: Row(children: [
                    if (itemFoto.isNotEmpty)
                      ClipRRect(borderRadius: BorderRadius.circular(8),
                        child: Image.network(itemFoto, width: 50, height: 50, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: AppTheme.sf,
                            child: const Center(child: Text('📦', style: TextStyle(fontSize: 20))))))
                    else
                      Container(width: 50, height: 50, decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Center(child: Text('📦', style: TextStyle(fontSize: 20)))),
                    const SizedBox(width: 12),
                    Expanded(child: Text(itemName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.tx))),
                    Text('\$$itemPrice', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.gr)),
                  ]));
              }),
            ] else ...[
              // Placeholder when no products configured
              Container(padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.bd)),
                child: Column(children: [
                  Text(emoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.tx)),
                  const SizedBox(height: 4),
                  const Text('Próximamente: menú y productos disponibles', style: TextStyle(fontSize: 11, color: AppTheme.tm)),
                ])),
            ],
            const SizedBox(height: 80), // space for sticky button
          ]))),
        ]),

        // ── Sticky bottom button ──
        Positioned(left: 16, right: 16, bottom: 16, child:
          SizedBox(height: 50, child: ElevatedButton.icon(
            onPressed: () => _showQuickOrderFs(n),
            icon: const Icon(Icons.shopping_bag, size: 20),
            label: const Text('Pedir Ahora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 8,
              shadowColor: const Color(0xFFFFD700).withOpacity(0.4))))),
      ]));
  }

  bool _comprasEnviando = false;

  Widget _comprasScreen() {
    return Scaffold(backgroundColor: AppTheme.bg,
      appBar: AppBar(backgroundColor: AppTheme.sf,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() { _menuScreen = null; _comprasTienda = null; })),
        title: const Text('🛒 Compras en Tienda', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
      body: ListView(padding: const EdgeInsets.all(14), children: [
        // ── Instrucciones ──
        Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(color: AppTheme.ac.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.ac.withOpacity(0.2))),
          child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.info_outline, size: 18, color: AppTheme.ac),
            SizedBox(width: 8),
            Expanded(child: Text('Elige una tienda, ve sus productos y precios, y escribe tu lista de compras. Nosotros compramos y te lo llevamos.',
              style: TextStyle(fontSize: 11, color: AppTheme.ac))),
          ])),
        // ── Grid de tiendas ──
        const Text('Elige tu tienda', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 1.6,
          children: _tiendas.map((t) {
            final sel = _comprasTienda == t['id'];
            final c = Color(t['color'] as int);
            return GestureDetector(
              onTap: () => setState(() => _comprasTienda = t['id'] as String),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: sel ? c.withOpacity(0.15) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: sel ? c : AppTheme.bd, width: sel ? 1.5 : 1)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(t['icon'] as String, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(t['nom'] as String, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sel ? c : AppTheme.tx)),
                ]),
              ),
            );
          }).toList(),
        ),
        // ── Tienda seleccionada ──
        if (_comprasTienda != null) ...[
          const SizedBox(height: 16),
          Builder(builder: (ctx) {
            final t = _tiendas.firstWhere((t) => t['id'] == _comprasTienda);
            final c = Color(t['color'] as int);
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Botón abrir tienda
              GestureDetector(
                onTap: () => launchUrl(Uri.parse(t['url'] as String), mode: LaunchMode.externalApplication),
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(14)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.open_in_new, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('Abrir ${t['nom']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
                ),
              ),
              const SizedBox(height: 6),
              Text('Ve los productos y precios, luego regresa aquí y escribe tu lista.', style: TextStyle(fontSize: 9, color: AppTheme.tm)),
              const SizedBox(height: 14),
              // ── Formulario de pedido ──
              const Text('Tu lista de compras', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
              const SizedBox(height: 8),
              TextField(
                controller: _comprasLista, maxLines: 5,
                style: const TextStyle(color: AppTheme.tx, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Ej:\n- 2 litros de leche\n- 1 kg de manzanas\n- Detergente Ariel 3kg',
                  hintStyle: const TextStyle(color: AppTheme.td, fontSize: 11),
                  prefixIcon: const Padding(padding: EdgeInsets.only(bottom: 60), child: Icon(Icons.shopping_bag, size: 18, color: AppTheme.td)),
                  filled: false,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.bd)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12))),
              const SizedBox(height: 10),
              TextField(
                controller: _comprasTel,
                style: const TextStyle(color: AppTheme.tx, fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'Tu teléfono', labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 11),
                  prefixIcon: const Icon(Icons.phone, size: 18, color: AppTheme.td),
                  filled: false,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.bd)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12))),
              const SizedBox(height: 10),
              TextField(
                controller: _comprasDir,
                style: const TextStyle(color: AppTheme.tx, fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'Dirección de entrega', labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 11),
                  prefixIcon: const Icon(Icons.location_on, size: 18, color: Color(0xFF34A853)),
                  filled: false,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.bd)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12))),
              const SizedBox(height: 14),
              // Info de cobro
              Container(padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.yl.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.yl.withOpacity(0.2))),
                child: const Row(children: [
                  Icon(Icons.payments, size: 16, color: AppTheme.yl),
                  SizedBox(width: 8),
                  Expanded(child: Text('Se cobra: costo de productos + envío', style: TextStyle(fontSize: 10, color: AppTheme.yl))),
                ])),
              const SizedBox(height: 14),
              // Botón enviar
              GestureDetector(
                onTap: _comprasEnviando ? null : () => _enviarCompra(t),
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [c, c.withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(14)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (_comprasEnviando) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    else const Icon(Icons.send, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(_comprasEnviando ? 'Enviando...' : 'Enviar pedido por WhatsApp', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
                ),
              ),
              const SizedBox(height: 20),
            ]);
          }),
        ],
      ]),
    );
  }

  void _enviarCompra(Map<String, dynamic> tienda) async {
    if (_comprasLista.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escribe tu lista de compras'), backgroundColor: AppTheme.rd));
      return;
    }
    if (_comprasTel.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega tu teléfono'), backgroundColor: AppTheme.rd));
      return;
    }
    if (_comprasDir.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega tu dirección de entrega'), backgroundColor: AppTheme.rd));
      return;
    }
    setState(() => _comprasEnviando = true);
    final msg = '🛒 *COMPRA EN TIENDA*\n\n'
      '🏪 Tienda: ${tienda['nom']}\n'
      '📋 Lista:\n${_comprasLista.text.trim()}\n\n'
      '📱 Tel: ${_comprasTel.text.trim()}\n'
      '📍 Entregar en: ${_comprasDir.text.trim()}\n\n'
      'Enviado desde Cargo-GO';
    final url = 'https://wa.me/527753200224?text=${Uri.encodeComponent(msg)}';
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Pedido enviado a ${tienda['nom']}'), backgroundColor: AppTheme.gr));
      _comprasLista.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.rd));
    }
    setState(() => _comprasEnviando = false);
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
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () => _addToCart(p['nombre'] ?? '', (p['precio'] as num?)?.toInt() ?? 0, 'Farmacias Madrid'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.gr.withOpacity(0.15), foregroundColor: AppTheme.gr,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0),
                child: const Text('+Agregar', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600))),
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
        heroTag: 'farmCart',
        icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
        label: Text('🛒 $_cartQty · \$$_cartTotal', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white))) : null,
    );
  }

  // ═══ PEDIDO RÁPIDO FORM ═══
  void _showPedidoRapido() {
    String? _prTipo;
    final _prOrigen = TextEditingController();
    final _prDestino = TextEditingController();
    final _prTel = TextEditingController();
    final _prNotas = TextEditingController();
    // Tipo-specific controllers
    final _prRestaurante = TextEditingController();
    final _prMedicamento = TextEditingController();
    final _prSucursal = TextEditingController();
    final _prDimensiones = TextEditingController();
    final _prMuebles = TextEditingController();
    final _prCajas = TextEditingController();
    final _prPiso = TextEditingController();
    bool _prReceta = false;
    bool _prFragil = false;

    final tipos = [
      {'id': 'comida', 'icon': '🍲', 'nom': 'Delivery Comida', 'desc': 'Restaurantes y comida', 'color': AppTheme.or},
      {'id': 'farmacia', 'icon': '💊', 'nom': 'Farmacia', 'desc': 'Medicamentos y salud', 'color': AppTheme.gr},
      {'id': 'mandado', 'icon': '🛒', 'nom': 'Mandado Local', 'desc': 'Compras y encargos', 'color': AppTheme.ac},
      {'id': 'paqueteria', 'icon': '📦', 'nom': 'Paquetería CDMX-Hidalgo', 'desc': 'Envíos entre ciudades', 'color': AppTheme.pu},
      {'id': 'mudanza', 'icon': '🚛', 'nom': 'Mini Mudanza', 'desc': 'Muebles y cajas', 'color': AppTheme.yl},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) {
        Widget _field(String label, TextEditingController ctrl, {IconData icon = Icons.edit, int lines = 1, Color? iconColor}) =>
          Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(
            controller: ctrl, maxLines: lines,
            style: const TextStyle(color: AppTheme.tx, fontSize: 13),
            decoration: InputDecoration(
              labelText: label, labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 12),
              prefixIcon: Icon(icon, size: 18, color: iconColor ?? AppTheme.td),
              filled: false,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.bd, width: 1)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.ac, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12)),
          ));

        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.92),
          decoration: const BoxDecoration(
            color: AppTheme.sf,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Handle
            Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(color: AppTheme.bd, borderRadius: BorderRadius.circular(2))),
            // Título
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
              const Icon(Icons.flash_on, size: 20, color: AppTheme.rd),
              const SizedBox(width: 8),
              const Expanded(child: Text('Pedido Rápido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx))),
              GestureDetector(onTap: () => Navigator.pop(ctx),
                child: Container(width: 32, height: 32, decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.close, size: 16, color: AppTheme.tm))),
            ])),
            const SizedBox(height: 12),
            // Contenido scrollable
            Flexible(child: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), shrinkWrap: true, children: [
              // ── Paso 1: Seleccionar tipo ──
              if (_prTipo == null) ...[
                const Text('¿Qué tipo de pedido?', style: TextStyle(fontSize: 12, color: AppTheme.tm)),
                const SizedBox(height: 10),
                ...tipos.map((t) => GestureDetector(
                  onTap: () => setModalState(() => _prTipo = t['id'] as String),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.transparent, borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: (t['color'] as Color).withOpacity(0.4), width: 1.2)),
                    child: Row(children: [
                      Container(width: 44, height: 44,
                        decoration: BoxDecoration(color: (t['color'] as Color).withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: Center(child: Text(t['icon'] as String, style: const TextStyle(fontSize: 22)))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(t['nom'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t['color'] as Color)),
                        Text(t['desc'] as String, style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
                      ])),
                      Icon(Icons.arrow_forward_ios, size: 14, color: t['color'] as Color),
                    ]),
                  ),
                )),
              ],
              // ── Paso 2: Formulario según tipo ──
              if (_prTipo != null) ...[
                // Back to type selection
                GestureDetector(
                  onTap: () => setModalState(() => _prTipo = null),
                  child: Row(children: [
                    const Icon(Icons.arrow_back_ios, size: 14, color: AppTheme.ac),
                    Text('${tipos.firstWhere((t) => t['id'] == _prTipo)['icon']} ${tipos.firstWhere((t) => t['id'] == _prTipo)['nom']}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.ac)),
                  ]),
                ),
                const SizedBox(height: 14),
                // Campos comunes
                _field('Teléfono del cliente', _prTel, icon: Icons.phone),
                _field('Dirección origen', _prOrigen, icon: Icons.location_on, iconColor: const Color(0xFF34A853)),
                _field('Dirección destino', _prDestino, icon: Icons.flag),
                // Campos específicos por tipo
                if (_prTipo == 'comida') ...[
                  _field('¿De qué restaurante?', _prRestaurante, icon: Icons.restaurant),
                  _field('¿Qué llevar? (platillos, cantidad)', _prNotas, icon: Icons.fastfood, lines: 2),
                ],
                if (_prTipo == 'farmacia') ...[
                  _field('¿Qué medicamento(s)?', _prMedicamento, icon: Icons.medication, lines: 2),
                  _field('Sucursal preferida', _prSucursal, icon: Icons.store),
                  Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(
                    onTap: () => setModalState(() => _prReceta = !_prReceta),
                    child: Container(padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _prReceta ? AppTheme.gr : AppTheme.bd)),
                      child: Row(children: [
                        Icon(_prReceta ? Icons.check_box : Icons.check_box_outline_blank, size: 20,
                          color: _prReceta ? AppTheme.gr : AppTheme.td),
                        const SizedBox(width: 8),
                        const Text('Requiere receta médica', style: TextStyle(fontSize: 12, color: AppTheme.tx)),
                      ])))),
                ],
                if (_prTipo == 'mandado') ...[
                  _field('¿Qué necesita? (lista de compras)', _prNotas, icon: Icons.shopping_bag, lines: 3),
                ],
                if (_prTipo == 'paqueteria') ...[
                  _field('Descripción del paquete', _prNotas, icon: Icons.inventory_2, lines: 2),
                  _field('Dimensiones / peso aprox.', _prDimensiones, icon: Icons.straighten),
                  Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(
                    onTap: () => setModalState(() => _prFragil = !_prFragil),
                    child: Container(padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _prFragil ? AppTheme.or : AppTheme.bd)),
                      child: Row(children: [
                        Icon(_prFragil ? Icons.check_box : Icons.check_box_outline_blank, size: 20,
                          color: _prFragil ? AppTheme.or : AppTheme.td),
                        const SizedBox(width: 8),
                        const Text('Paquete frágil', style: TextStyle(fontSize: 12, color: AppTheme.tx)),
                      ])))),
                ],
                if (_prTipo == 'mudanza') ...[
                  _field('¿Qué muebles/artículos?', _prMuebles, icon: Icons.weekend, lines: 2),
                  _field('¿Cuántas cajas aprox.?', _prCajas, icon: Icons.inventory),
                  _field('¿Piso? (ej: 3er piso sin elevador)', _prPiso, icon: Icons.apartment),
                  _field('Notas adicionales', _prNotas, icon: Icons.note, lines: 2),
                ],
                const SizedBox(height: 8),
                // Precio estimado
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.bd)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Costo estimado:', style: TextStyle(fontSize: 12, color: AppTheme.tm)),
                    Text(_prTipo == 'mudanza' ? '\$1,500' : _prTipo == 'paqueteria' ? '\$250' : _prTipo == 'comida' ? '\$65' : _prTipo == 'farmacia' ? '\$45' : '\$85',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.tx, fontFamily: 'monospace')),
                  ])),
                const SizedBox(height: 6),
                // Info MercadoPago
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF00B2E8).withOpacity(0.08), borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00B2E8).withOpacity(0.3))),
                  child: const Row(children: [
                    Icon(Icons.info_outline, size: 14, color: Color(0xFF00B2E8)),
                    SizedBox(width: 6),
                    Expanded(child: Text('Paga con tarjeta, OXXO, SPEI o MercadoPago', style: TextStyle(fontSize: 9, color: Color(0xFF00B2E8)))),
                  ])),
                const SizedBox(height: 12),
                // Botón Pagar con MercadoPago
                GestureDetector(
                  onTap: () async {
                    if (_prTel.text.isEmpty || _prDestino.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Completa teléfono y destino', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.red));
                      return;
                    }
                    final tipoInfo = tipos.firstWhere((t) => t['id'] == _prTipo);
                    final folio = 'CGO-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
                    String desc = '';
                    if (_prTipo == 'comida') desc = '${_prRestaurante.text}: ${_prNotas.text}';
                    if (_prTipo == 'farmacia') desc = '${_prMedicamento.text}${_prReceta ? ' (c/receta)' : ''}';
                    if (_prTipo == 'mandado') desc = _prNotas.text;
                    if (_prTipo == 'paqueteria') desc = '${_prNotas.text} · ${_prDimensiones.text}${_prFragil ? ' ⚠️FRÁGIL' : ''}';
                    if (_prTipo == 'mudanza') desc = '${_prMuebles.text} · ${_prCajas.text} cajas · Piso: ${_prPiso.text}';
                    final precio = _prTipo == 'mudanza' ? 1500.0 : _prTipo == 'paqueteria' ? 250.0 : _prTipo == 'comida' ? 65.0 : _prTipo == 'farmacia' ? 45.0 : 85.0;
                    // Crear pedido local
                    setState(() {
                      pedidos.insert(0, Pedido(
                        id: folio, cl: _prTel.text,
                        orig: _prOrigen.text.isNotEmpty ? _prOrigen.text : tipoInfo['nom'] as String,
                        dest: _prDestino.text,
                        est: 'prep', m: 0,
                        h: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                        prog: 5, city: 'hidalgo',
                      ));
                    });
                    Navigator.pop(ctx);
                    // Enviar al API si está online
                    if (_online) {
                      ApiService.crearEnvio({
                        'origen': _prOrigen.text.isNotEmpty ? _prOrigen.text : tipoInfo['nom'] as String,
                        'destino': _prDestino.text,
                        'telefono': _prTel.text,
                        'tipo': _prTipo,
                        'descripcion': desc,
                        'total': precio,
                        'folio': folio,
                      });
                    }
                    // Abrir MercadoPago Checkout Pro
                    final ok = await MercadoPagoService.pagarPedido(folio: folio, tipo: _prTipo ?? 'mandado', total: precio, descripcion: desc);
                    if (ok) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${tipoInfo['icon']} Pedido $folio · Redirigiendo a MercadoPago...', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: AppTheme.gr, duration: const Duration(seconds: 4)));
                    } else {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${tipoInfo['icon']} Pedido $folio creado · Pago pendiente', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: AppTheme.or, duration: const Duration(seconds: 4)));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF00B2E8), Color(0xFF009EE3)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFF00B2E8).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                      Icon(Icons.payment, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Pagar con MercadoPago', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                    ]),
                  ),
                ),
              ],
            ])),
          ]),
        );
      }),
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
      _topBar(bottom: GestureDetector(
        onTap: _showPedidoRapido,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: AppTheme.bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.rd, width: 1.5),
            boxShadow: [BoxShadow(color: AppTheme.rd.withOpacity(0.2), blurRadius: 10, spreadRadius: 0)],
          ),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.yl, width: 2),
              boxShadow: [BoxShadow(color: AppTheme.yl.withOpacity(0.3), blurRadius: 6)]),
              child: const Center(child: Text('⚡', style: TextStyle(fontSize: 20)))),
            const SizedBox(width: 10),
            const Expanded(child: Text('Agregar Pedido Rápido', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.rd))),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.rd),
          ]),
        ),
      )),
      // ── Rastreo por folio ──
      Container(margin: const EdgeInsets.only(bottom: 10),
        child: TextField(
          style: const TextStyle(color: AppTheme.tx, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Rastrear folio CGO-...', hintStyle: const TextStyle(color: AppTheme.td, fontSize: 12),
            prefixIcon: const Icon(Icons.search, color: AppTheme.or, size: 18),
            suffixIcon: IconButton(icon: const Icon(Icons.send, size: 16, color: AppTheme.ac),
              onPressed: () { if (_trackFolio.isNotEmpty) _rastrearPedido(_trackFolio); }),
            filled: true, fillColor: AppTheme.cd,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppTheme.bd)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppTheme.bd)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.or)),
            contentPadding: const EdgeInsets.symmetric(vertical: 10)),
          onChanged: (v) => _trackFolio = v.trim(),
          onSubmitted: (v) { if (v.trim().isNotEmpty) _rastrearPedido(v.trim()); },
        )),
      // ── Filter pills (arriba del mapa) ──
      Row(children: [for (var f in [['all','Todos'],['hidalgo','Hidalgo'],['cdmx','CDMX']])
        Expanded(child: GestureDetector(onTap: () => setState(() => _pedFilter = f[0]),
          child: Container(margin: const EdgeInsets.symmetric(horizontal: 3), padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _pedFilter == f[0] ? AppTheme.ac : AppTheme.bd, width: 1.2),
              gradient: _pedFilter == f[0] ? const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)]) : null,
              color: _pedFilter == f[0] ? null : Colors.transparent),
            child: Text(f[1], textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _pedFilter == f[0] ? Colors.white : AppTheme.tm)))))]),
      const SizedBox(height: 10),
      // ═══ MAPA REAL - doble tamaño ═══
      Container(height: 440, margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.yl, width: 2),
          boxShadow: [BoxShadow(color: AppTheme.yl.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(20),
          child: Stack(children: [
            // Flutter Map preview embebido
            FlutterMap(
              options: MapOptions(
                initialCenter: _mapCenter, initialZoom: 12,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                onTap: (_, __) => setState(() { _showFullMap = true; _updateMapMarkers(); }),
                onMapReady: () { if (_markerData.isEmpty) _updateMapMarkers(); },
              ),
              children: [
                TileLayer(urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd']),
                MarkerLayer(markers: _buildMapMarkers()),
              ],
            ),
            // Gradient overlay arriba
            Positioned(top: 0, left: 0, right: 0, height: 60,
              child: IgnorePointer(child: Container(decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [AppTheme.bg.withOpacity(0.7), Colors.transparent]))))),
            // Gradient overlay abajo
            Positioned(bottom: 0, left: 0, right: 0, height: 70,
              child: IgnorePointer(child: Container(decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [AppTheme.bg.withOpacity(0.8), Colors.transparent]))))),
            // Top row: titulo + fullscreen
            Positioned(top: 10, left: 14, right: 14,
              child: IgnorePointer(child: Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppTheme.cd.withOpacity(0.85), borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.ac.withOpacity(0.3), width: 0.5)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.map, size: 14, color: Color(0xFF34A853)),
                    SizedBox(width: 6),
                    Text('Mapa de Entregas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tx)),
                  ])),
                const Spacer(),
                Container(padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppTheme.cd.withOpacity(0.85), borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.ac.withOpacity(0.3), width: 0.5)),
                  child: const Icon(Icons.fullscreen, size: 18, color: AppTheme.ac)),
              ]))),
            // Bottom chips: stats
            Positioned(bottom: 10, left: 14, right: 14,
              child: IgnorePointer(child: Row(children: [
                _mapPreviewChip('📍 Tulancingo', '${negHidalgo.length}'),
                const SizedBox(width: 8),
                _mapPreviewChip('🏙️ CDMX', '${negCdmx.length}'),
                const SizedBox(width: 8),
                _mapPreviewChip('📦 En ruta', '${useApi ? enRuta : pedidos.where((p) => p.est == "ruta").length}'),
              ]))),
          ]))),
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
        const Icon(Icons.location_on, size: 20, color: Color(0xFF34A853)),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Cobertura', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          Text('Tulancingo · Pachuca · CDMX · Zona Metropolitana', style: TextStyle(fontSize: 10, color: AppTheme.tm)),
        ])),
      ]),
    ),
    const SizedBox(height: 8),
    GestureDetector(onTap: () => WhatsappService.cotizarMudanza(tipo: 'mudanza'),
      child: Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.bd, width: 1.2)),
        child: Row(children: [
          const Icon(Icons.phone, size: 20, color: AppTheme.gr),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Cotiza ahora', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tx)),
            Text('Llámanos o envía WhatsApp para agendar', style: TextStyle(fontSize: 10, color: AppTheme.tm)),
          ])),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.gr),
        ]),
      )),
  ]);

  Widget _mudOption(IconData ic, String title, String desc, String price, Color c) => GestureDetector(
    onTap: () => WhatsappService.cotizarMudanza(tipo: title),
    child: Container(
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
    ),
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

  void _showEditProfile() {
    final nameCtrl = TextEditingController(text: AuthService.currentUser?.displayName ?? 'Chule');
    final phoneCtrl = TextEditingController(text: AuthService.currentUser?.phoneNumber ?? '');
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppTheme.sf,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Editar Perfil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx)),
          const SizedBox(height: 16),
          TextField(controller: nameCtrl, style: const TextStyle(color: AppTheme.tx, fontSize: 13),
            decoration: InputDecoration(labelText: 'Nombre', labelStyle: const TextStyle(color: AppTheme.tm),
              prefixIcon: const Icon(Icons.person, color: AppTheme.ac, size: 20),
              filled: true, fillColor: AppTheme.cd,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.ac)))),
          const SizedBox(height: 12),
          TextField(controller: phoneCtrl, style: const TextStyle(color: AppTheme.tx, fontSize: 13),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: 'Teléfono', labelStyle: const TextStyle(color: AppTheme.tm),
              prefixIcon: const Icon(Icons.phone, color: AppTheme.gr, size: 20),
              filled: true, fillColor: AppTheme.cd,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.gr)))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 44, child: ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Perfil actualizado', style: TextStyle(color: Colors.white)),
                backgroundColor: AppTheme.gr, duration: Duration(seconds: 2)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.ac, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: const Text('Guardar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)))),
        ])));
  }

  void _showSecurity() {
    final user = AuthService.currentUser;
    final phone = user?.phoneNumber ?? 'No registrado';
    final email = user?.email ?? 'No registrado';
    final provider = user != null ? (user.phoneNumber != null ? 'Teléfono' : 'Google') : 'Invitado';
    showModalBottomSheet(context: context, backgroundColor: AppTheme.sf,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Seguridad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx)),
          const SizedBox(height: 16),
          _secRow(Icons.phone, 'Teléfono', phone),
          _secRow(Icons.email, 'Email', email),
          _secRow(Icons.shield, 'Proveedor', provider),
          _secRow(Icons.access_time, 'Sesión', 'Activa'),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 44, child: OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AuthService.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.or,
              side: const BorderSide(color: AppTheme.or),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Cambiar método de acceso', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)))),
        ])));
  }

  Widget _secRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(icon, size: 18, color: AppTheme.tm),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.tm)),
      const Spacer(),
      Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.tx)),
    ]));

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
        Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF34A853).withOpacity(a.main ? 0.15 : 0.08), borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.location_on, size: 18, color: const Color(0xFF34A853).withOpacity(a.main ? 1.0 : 0.6))),
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
      GestureDetector(
        onTap: () {
          if (it == 'Editar perfil') _showEditProfile();
          if (it == 'Notificaciones') _showNotifs();
          if (it == 'Seguridad') _showSecurity();
          if (it == 'Soporte') WhatsappService.contactarSoporte();
          if (it == 'Cerrar sesión') { AuthService.signOut(); setState(() {}); }
        },
        child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: it == 'Cerrar sesión' ? AppTheme.rd.withOpacity(0.25) : AppTheme.bd, width: 1.2)),
          child: Row(children: [
            Icon(it == 'Editar perfil' ? Icons.edit : it == 'Notificaciones' ? Icons.notifications : it == 'Seguridad' ? Icons.shield : it == 'Soporte' ? Icons.help : Icons.logout,
              size: 18, color: it == 'Cerrar sesión' ? AppTheme.rd : AppTheme.tm),
            const SizedBox(width: 10),
            Expanded(child: Text(it, style: TextStyle(fontSize: 11, color: it == 'Cerrar sesión' ? AppTheme.rd : AppTheme.tx))),
            Icon(Icons.arrow_forward_ios, size: 12, color: it == 'Cerrar sesión' ? AppTheme.rd.withOpacity(0.5) : AppTheme.td),
          ]))),
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
