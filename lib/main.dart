import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/mercadopago_service.dart';
import 'services/places_photo_service.dart';
import 'services/whatsapp_service.dart';
import 'services/firestore_service.dart';
import 'services/role_service.dart';
import 'services/delivery_time_service.dart';
import 'models/app_models.dart';
import 'package:image_picker/image_picker.dart';
import 'screens/farmacia_madrid_screen.dart';
import 'screens/negocio/negocio_login_screen.dart';
import 'screens/negocio/negocio_panel_screen.dart';
import 'screens/sudo/sudo_login_screen.dart';
import 'screens/sudo/sudo_panel_screen.dart';
import 'screens/cliente/ticket_screen.dart';
import 'screens/cliente/rating_dialog.dart';
import 'screens/cliente/chat_screen.dart';
import 'screens/cliente/historial_screen.dart';
import 'screens/cliente/cupones_screen.dart';
import 'screens/cliente/referidos_screen.dart';
import 'screens/cliente/proponer_negocio_screen.dart';
import 'screens/cliente/onboarding_screen.dart';
import 'screens/cliente/franquicias_screen.dart';

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
  final String? menu, horario, tel, fotoUrl, plan;
  Negocio({required this.id, required this.nom, required this.e, required this.zona, required this.desc, required this.tipo, required this.r, required this.ped, required this.c, this.menu, this.horario, this.tel, this.fotoUrl, this.plan});
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

// ═══ OFERTAS FARMACIAS MADRID ═══
const _ofertasBaseUrl = 'https://firebasestorage.googleapis.com/v0/b/cargo-go-b5f77.firebasestorage.app/o/negocios%2Fofertas%2Foferta_';
final List<String> _ofertasUrls = List.generate(25, (i) => '$_ofertasBaseUrl${(i + 1).toString().padLeft(2, '0')}.jpeg?alt=media');

// ═══ LOGOS CADENAS DE TIENDAS (Firebase Storage) ═══
const _storageBucket = 'https://firebasestorage.googleapis.com/v0/b/cargo-go-b5f77.firebasestorage.app/o/negocios%2Flogos%2F';
const _cadenaLogos = <String, String>{
  'walmart': '${_storageBucket}walmart.png?alt=media',
  'bodega_aurrera': '${_storageBucket}bodega_aurrera.png?alt=media',
  'chedraui': '${_storageBucket}chedraui.png?alt=media',
  'soriana': '${_storageBucket}soriana.png?alt=media',
  'sams': '${_storageBucket}sams.png?alt=media',
  'costco': '${_storageBucket}costco.png?alt=media',
  'homedepot': '${_storageBucket}homedepot.png?alt=media',
  'liverpool': '${_storageBucket}liverpool.png?alt=media',
  'autozone': '${_storageBucket}autozone.png?alt=media',
  'farmguad': '${_storageBucket}farmguad.png?alt=media',
  'lacomer': '${_storageBucket}lacomer.png?alt=media',
  'oreilly': '${_storageBucket}oreilly.png?alt=media',
  // Fast food
  'starbucks': '${_storageBucket}starbucks.png?alt=media',
  'dominos': '${_storageBucket}dominos.png?alt=media',
  'pizzahut': '${_storageBucket}pizzahut.png?alt=media',
  'mcdonalds': '${_storageBucket}mcdonalds.png?alt=media',
  'burgerking': '${_storageBucket}burgerking.png?alt=media',
  'kfc': '${_storageBucket}kfc.png?alt=media',
  'subway': '${_storageBucket}subway.png?alt=media',
  'carlsjr': '${_storageBucket}carlsjr.png?alt=media',
  'littlecaesars': '${_storageBucket}littlecaesars.png?alt=media',
  // Departamentales
  'palaciodehierro': '${_storageBucket}palaciodehierro.png?alt=media',
  'sears': '${_storageBucket}sears.png?alt=media',
  // Especializadas
  'officedepot': '${_storageBucket}officedepot.png?alt=media',
  'elektra': '${_storageBucket}elektra.png?alt=media',
  'coppel': '${_storageBucket}coppel.png?alt=media',
  'mega': '${_storageBucket}mega.png?alt=media',
  // Restaurantes
  'sanborns': '${_storageBucket}sanborns.png?alt=media',
  'vips': '${_storageBucket}vips.png?alt=media',
};
const _cadenaColor = Color(0xFF1565C0);
const _cadenaBorder = Color(0xFF1E88E5);

// ═══ 250 NEGOCIOS REALES (91 Hidalgo + 159 CDMX) ═══
final List<Negocio> negHidalgo = [
  Negocio(id:"h01",nom:"Farmacias Madrid - Panteón",e:"💊",zona:"Calz. Hidalgo 1311, Tulancingo",desc:"Medicamentos genéricos, patente y hospitalarios · Servicio a domicilio",r:4.8,ped:1240,c:AppTheme.gr,menu:"farmacia",tipo:"farmacia",horario:"8:00–22:00",tel:"7753200224",fotoUrl:"https://firebasestorage.googleapis.com/v0/b/cargo-go-b5f77.firebasestorage.app/o/negocios%2Fh01%2Ffoto.jpg?alt=media",plan:"vip"),
  Negocio(id:"h01b",nom:"Farmacias Madrid - Lázaro",e:"💊",zona:"Gral. L. Cárdenas 107, Tulancingo",desc:"Medicamentos genéricos, patente y hospitalarios · Servicio a domicilio",r:4.8,ped:980,c:AppTheme.gr,menu:"farmacia",tipo:"farmacia",horario:"8:00–22:00",tel:"7753200224",fotoUrl:"https://firebasestorage.googleapis.com/v0/b/cargo-go-b5f77.firebasestorage.app/o/negocios%2Fh01b%2Ffoto.jpg?alt=media",plan:"vip"),
  Negocio(id:"h01d",nom:"Farmacias Madrid - Santa María",e:"💊",zona:"C. Jazmín 64, Col. Santa María, Tulancingo",desc:"Medicamentos genéricos, patente y hospitalarios · Servicio a domicilio",r:4.8,ped:860,c:AppTheme.gr,menu:"farmacia",tipo:"farmacia",horario:"8:00–22:00",tel:"7753200224",fotoUrl:"https://firebasestorage.googleapis.com/v0/b/cargo-go-b5f77.firebasestorage.app/o/negocios%2Fh01d%2Ffoto.jpg?alt=media",plan:"vip"),
  Negocio(id:"h01e",nom:"Farmacias Madrid - Caballito",e:"💊",zona:"21 de Marzo, Caballito, Tulancingo",desc:"Medicamentos genéricos, patente y hospitalarios · Servicio a domicilio",r:4.8,ped:650,c:AppTheme.gr,menu:"farmacia",tipo:"farmacia",horario:"8:00–22:00",tel:"7753200224",fotoUrl:"https://firebasestorage.googleapis.com/v0/b/cargo-go-b5f77.firebasestorage.app/o/negocios%2Fh01e%2Ffoto.jpg?alt=media",plan:"vip"),
  // ── 91 Negocios reales Tulancingo ──
  Negocio(id:"h1",nom:"Asados Don Papi",e:"🍽️",zona:"Tulancingo",desc:"Restaurante",r:4.8,ped:3389,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"h2",nom:"El Viejo Matias",e:"🍽️",zona:"Tulancingo",desc:"Restaurante",r:4.3,ped:550,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"h3",nom:"D Victorias Restaurante",e:"🍽️",zona:"Tulancingo",desc:"Restaurante",r:4.6,ped:616,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"h4",nom:"D Victorias La Morena",e:"🍽️",zona:"Tulancingo",desc:"Restaurante",r:4.5,ped:258,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"h5",nom:"RUEDA MADERA",e:"🍽️",zona:"Tulancingo",desc:"Restaurante",r:4.3,ped:1041,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"h6",nom:"Las Pellizcadas de Doña Anita",e:"🍽️",zona:"Tulancingo",desc:"Restaurante",r:4.3,ped:846,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"h7",nom:"Barrio 100",e:"🍸",zona:"Tulancingo",desc:"Bar & cocktails",r:4.1,ped:740,c:const Color(0xFF7C2D12),tipo:"bebidas"),
  Negocio(id:"h8",nom:"Magnolias Tulancingo",e:"🍽️",zona:"Tulancingo",desc:"Restaurante",r:4.2,ped:182,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"h9",nom:"Restaurante Eri",e:"🍽️",zona:"Tulancingo",desc:"Restaurante",r:4.5,ped:175,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"h10",nom:"Cordelia Restaurante",e:"🐟",zona:"Tulancingo",desc:"Mariscos",r:4.6,ped:67,c:const Color(0xFF0891B2),tipo:"mariscos"),
  Negocio(id:"h11",nom:"Taquería El Plebeyo",e:"🌮",zona:"Tulancingo",desc:"Taquería",r:4.5,ped:482,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"h12",nom:"Taquería Juárez",e:"🌮",zona:"Tulancingo",desc:"Taquería",r:4.2,ped:169,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"h13",nom:"Taquería Los Cuates",e:"🌮",zona:"Tulancingo",desc:"Taquería",r:4.7,ped:66,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"h14",nom:"Tacos Memo",e:"🌮",zona:"Tulancingo",desc:"Taquería",r:4.3,ped:1129,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"h15",nom:"Taquería Los Faroles",e:"🌮",zona:"Tulancingo",desc:"Taquería",r:3.9,ped:442,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"h16",nom:"La Caba Pizza-Bar",e:"🍕",zona:"Tulancingo",desc:"Pizzería",r:4.1,ped:970,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"h17",nom:"Pizzas Oh Henry",e:"🍕",zona:"Tulancingo",desc:"Pizzería",r:4.3,ped:223,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"h18",nom:"La Biznaga",e:"🍕",zona:"Tulancingo",desc:"Pizzería",r:4.5,ped:557,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"h19",nom:"Pizzalini Artesanal",e:"🍕",zona:"Tulancingo",desc:"Pizzería",r:4.6,ped:11,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"h20",nom:"Pizzas Davi's",e:"🍕",zona:"Tulancingo",desc:"Pizzería",r:4.5,ped:55,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"h21",nom:"Santo Café",e:"☕",zona:"Tulancingo",desc:"Café",r:4.1,ped:1072,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"h22",nom:"Dos Amigos Café-Bar",e:"☕",zona:"Tulancingo",desc:"Café",r:4.6,ped:335,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"h23",nom:"Campo Café",e:"☕",zona:"Tulancingo",desc:"Café",r:5.0,ped:112,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"h24",nom:"MENINA café",e:"☕",zona:"Tulancingo",desc:"Café",r:4.6,ped:33,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"h25",nom:"Cafetería El Vagón",e:"☕",zona:"Tulancingo",desc:"Café",r:4.2,ped:1156,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"h26",nom:"Panificadora El Buen Gusto",e:"🍞",zona:"Tulancingo",desc:"Panadería",r:4.4,ped:450,c:const Color(0xFFA16207),tipo:"panaderia"),
  Negocio(id:"h27",nom:"Panificadora El Buen Gusto Sur",e:"🍞",zona:"Tulancingo",desc:"Panadería",r:4.3,ped:393,c:const Color(0xFFA16207),tipo:"panaderia"),
  Negocio(id:"h28",nom:"Panadería El Abuelo",e:"🍞",zona:"Tulancingo",desc:"Panadería",r:4.5,ped:107,c:const Color(0xFFA16207),tipo:"panaderia"),
  Negocio(id:"h29",nom:"Panificadora El Ángel",e:"🍞",zona:"Tulancingo",desc:"Panadería",r:4.4,ped:77,c:const Color(0xFFA16207),tipo:"panaderia"),
  Negocio(id:"h30",nom:"Panadería Natividad",e:"🍞",zona:"Tulancingo",desc:"Panadería",r:4.4,ped:28,c:const Color(0xFFA16207),tipo:"panaderia"),
  Negocio(id:"h31",nom:"Carnicería Flores Hermanos",e:"🥩",zona:"Tulancingo",desc:"Carnes",r:5.0,ped:11,c:const Color(0xFF991B1B),tipo:"carniceria"),
  Negocio(id:"h32",nom:"Carnicería Los Compadres",e:"🥩",zona:"Tulancingo",desc:"Carnes",r:5.0,ped:1,c:const Color(0xFF991B1B),tipo:"carniceria"),
  Negocio(id:"h33",nom:"Carnicería Téllez",e:"🥩",zona:"Tulancingo",desc:"Carnes",r:4.2,ped:13,c:const Color(0xFF991B1B),tipo:"carniceria"),
  Negocio(id:"h34",nom:"Abarrotes El Mayoreo",e:"🛒",zona:"Tulancingo",desc:"Abarrotes",r:3.9,ped:31,c:AppTheme.tl,tipo:"abarrotes"),
  Negocio(id:"h35",nom:"Zorro Abarrotero",e:"🛒",zona:"Tulancingo",desc:"Abarrotes",r:3.7,ped:447,c:AppTheme.tl,tipo:"abarrotes"),
  Negocio(id:"h36",nom:"Super Fox",e:"🛒",zona:"Tulancingo",desc:"Abarrotes",r:4.6,ped:43,c:AppTheme.tl,tipo:"abarrotes"),
  Negocio(id:"h37",nom:"JC Estilistas",e:"💇",zona:"Tulancingo",desc:"Estética & beauty",r:5.0,ped:57,c:const Color(0xFFEC4899),tipo:"servicios"),
  Negocio(id:"h38",nom:"Studio Frida Hair",e:"💇",zona:"Tulancingo",desc:"Estética & beauty",r:4.8,ped:45,c:const Color(0xFFEC4899),tipo:"servicios"),
  Negocio(id:"h39",nom:"Longoria Hair Studio",e:"💇",zona:"Tulancingo",desc:"Estética & beauty",r:4.0,ped:55,c:const Color(0xFFEC4899),tipo:"servicios"),
  Negocio(id:"h40",nom:"Gym Xtreme Fitness",e:"💪",zona:"Tulancingo",desc:"Gimnasio & fitness",r:4.5,ped:244,c:const Color(0xFF6366F1),tipo:"servicios"),
  Negocio(id:"h41",nom:"New Body Gym",e:"💪",zona:"Tulancingo",desc:"Gimnasio & fitness",r:4.5,ped:72,c:const Color(0xFF6366F1),tipo:"servicios"),
  Negocio(id:"h42",nom:"Capital Wellness",e:"💪",zona:"Tulancingo",desc:"Gimnasio & fitness",r:4.5,ped:96,c:const Color(0xFF6366F1),tipo:"servicios"),
  Negocio(id:"h43",nom:"GYM 11:11",e:"💪",zona:"Tulancingo",desc:"Gimnasio & fitness",r:4.6,ped:39,c:const Color(0xFF6366F1),tipo:"servicios"),
  Negocio(id:"h44",nom:"Mundo Fit",e:"💪",zona:"Tulancingo",desc:"Gimnasio & fitness",r:4.5,ped:185,c:const Color(0xFF6366F1),tipo:"servicios"),
  Negocio(id:"h45",nom:"Hospital Veterinario Pet-Dog",e:"🐾",zona:"Tulancingo",desc:"Veterinaria",r:4.7,ped:65,c:const Color(0xFF16A34A),tipo:"servicios"),
  Negocio(id:"h46",nom:"Veterinaria Simoda",e:"🐾",zona:"Tulancingo",desc:"Veterinaria",r:4.7,ped:30,c:const Color(0xFF16A34A),tipo:"servicios"),
  Negocio(id:"h47",nom:"Veterinaria NOSHMA",e:"🐾",zona:"Tulancingo",desc:"Veterinaria",r:4.9,ped:98,c:const Color(0xFF16A34A),tipo:"servicios"),
  Negocio(id:"h48",nom:"Florería El Edén",e:"🌸",zona:"Tulancingo",desc:"Florería",r:4.6,ped:74,c:const Color(0xFFE11D48),tipo:"flores"),
  Negocio(id:"h49",nom:"Florería La Orquídea",e:"🌸",zona:"Tulancingo",desc:"Florería",r:5.0,ped:43,c:const Color(0xFFE11D48),tipo:"flores"),
  Negocio(id:"h50",nom:"Florería Alvy",e:"🌸",zona:"Tulancingo",desc:"Florería",r:5.0,ped:24,c:const Color(0xFFE11D48),tipo:"flores"),
  Negocio(id:"h51",nom:"Tintorería Selecto Klin",e:"👔",zona:"Tulancingo",desc:"Lavandería",r:4.8,ped:18,c:const Color(0xFF0284C7),tipo:"servicios"),
  Negocio(id:"h52",nom:"Splash Lavandería",e:"👔",zona:"Tulancingo",desc:"Lavandería",r:4.0,ped:19,c:const Color(0xFF0284C7),tipo:"servicios"),
  Negocio(id:"h53",nom:"Lavandería Tip-Top",e:"👔",zona:"Tulancingo",desc:"Lavandería",r:4.8,ped:9,c:const Color(0xFF0284C7),tipo:"servicios"),
  Negocio(id:"h54",nom:"Ferretería Tulancingo",e:"🔧",zona:"Tulancingo",desc:"Ferretería",r:4.3,ped:52,c:const Color(0xFF525252),tipo:"ferreteria"),
  Negocio(id:"h55",nom:"Fix Ferreterías (Libertad)",e:"🔧",zona:"Tulancingo",desc:"Ferretería",r:4.4,ped:377,c:const Color(0xFF525252),tipo:"ferreteria"),
  Negocio(id:"h56",nom:"Fix Ferreterías (21 Marzo)",e:"🔧",zona:"Tulancingo",desc:"Ferretería",r:4.3,ped:296,c:const Color(0xFF525252),tipo:"ferreteria"),
  Negocio(id:"h57",nom:"Copy Plus",e:"📎",zona:"Tulancingo",desc:"Papelería",r:3.8,ped:164,c:const Color(0xFF2563EB),tipo:"papeleria"),
  Negocio(id:"h58",nom:"Central Paper Mill",e:"📎",zona:"Tulancingo",desc:"Papelería",r:3.7,ped:61,c:const Color(0xFF2563EB),tipo:"papeleria"),
  Negocio(id:"h59",nom:"Papelera AML",e:"📎",zona:"Tulancingo",desc:"Papelería",r:4.3,ped:23,c:const Color(0xFF2563EB),tipo:"papeleria"),
  Negocio(id:"h60",nom:"La Boutique Tulancingo",e:"👗",zona:"Tulancingo",desc:"Boutique & moda",r:4.7,ped:21,c:const Color(0xFFEC4899),tipo:"servicios"),
  Negocio(id:"h61",nom:"Mom's Boutique",e:"👗",zona:"Tulancingo",desc:"Boutique & moda",r:4.8,ped:12,c:const Color(0xFFEC4899),tipo:"servicios"),
  Negocio(id:"h62",nom:"Paris Boutique",e:"👗",zona:"Tulancingo",desc:"Boutique & moda",r:4.7,ped:6,c:const Color(0xFFEC4899),tipo:"servicios"),
  Negocio(id:"h63",nom:"Ópticas NV Tulancingo",e:"👓",zona:"Tulancingo",desc:"Óptica",r:4.9,ped:169,c:const Color(0xFF0284C7),tipo:"servicios"),
  Negocio(id:"h64",nom:"Anteojos Óptica",e:"👓",zona:"Tulancingo",desc:"Óptica",r:4.9,ped:16,c:const Color(0xFF0284C7),tipo:"servicios"),
  Negocio(id:"h65",nom:"Más Visión",e:"👓",zona:"Centro, Tulancingo, Hidalgo",desc:"Óptica",r:5.0,ped:37,c:const Color(0xFF0284C7),tipo:"servicios"),
  Negocio(id:"h66",nom:"Consultorio Dental Tulancingo",e:"🦷",zona:"Tulancingo",desc:"Consultorio dental",r:5.0,ped:1,c:const Color(0xFF16A34A),tipo:"servicios"),
  Negocio(id:"h67",nom:"Dra. Guadalupe Martínez",e:"🦷",zona:"Tulancingo",desc:"Consultorio dental",r:5.0,ped:20,c:const Color(0xFF16A34A),tipo:"servicios"),
  Negocio(id:"h68",nom:"Consultorio Dental Esp.",e:"🦷",zona:"Tulancingo",desc:"Consultorio dental",r:5.0,ped:6,c:const Color(0xFF16A34A),tipo:"servicios"),
  Negocio(id:"h69",nom:"Mueblería Modelo (Centro)",e:"🪑",zona:"Tulancingo",desc:"Mueblería",r:4.0,ped:137,c:const Color(0xFF78350F),tipo:"servicios"),
  Negocio(id:"h70",nom:"Mueblería Modelo (Morena)",e:"🪑",zona:"Tulancingo",desc:"Mueblería",r:4.0,ped:258,c:const Color(0xFF78350F),tipo:"servicios"),
  Negocio(id:"h71",nom:"d'Europe Muebles",e:"🪑",zona:"Tulancingo",desc:"Mueblería",r:4.1,ped:45,c:const Color(0xFF78350F),tipo:"servicios"),
  Negocio(id:"h72",nom:"Mecánico El Gato",e:"🔧",zona:"Tulancingo",desc:"Mecánica automotriz",r:5.0,ped:2,c:const Color(0xFF525252),tipo:"servicios"),
  Negocio(id:"h73",nom:"Automotriz González",e:"🔧",zona:"Tulancingo",desc:"Mecánica automotriz",r:4.4,ped:14,c:const Color(0xFF525252),tipo:"servicios"),
  Negocio(id:"h74",nom:"Barbacoa El Carnerito",e:"🐑",zona:"Tulancingo",desc:"Barbacoa de borrego",r:4.5,ped:1600,c:const Color(0xFF92400E),tipo:"comida"),
  Negocio(id:"h75",nom:"Barbacoa Don Mikey",e:"🐑",zona:"Tulancingo",desc:"Barbacoa de borrego",r:4.6,ped:381,c:const Color(0xFF92400E),tipo:"comida"),
  Negocio(id:"h76",nom:"Barbacoa La Cabaña de Charly",e:"🐑",zona:"Tulancingo",desc:"Barbacoa de borrego",r:4.5,ped:254,c:const Color(0xFF92400E),tipo:"comida"),
  Negocio(id:"h77",nom:"Tacos y Barbacoa La Güera",e:"🐑",zona:"Tulancingo",desc:"Barbacoa de borrego",r:4.6,ped:183,c:const Color(0xFF92400E),tipo:"comida"),
  Negocio(id:"h78",nom:"Barbacoa Mejía",e:"🐑",zona:"Tulancingo",desc:"Barbacoa de borrego",r:4.4,ped:134,c:const Color(0xFF92400E),tipo:"comida"),
  Negocio(id:"h79",nom:"Barbacoa y Carnitas El Hidalguense",e:"🐑",zona:"Tulancingo",desc:"Barbacoa de borrego",r:4.4,ped:94,c:const Color(0xFF92400E),tipo:"comida"),
  Negocio(id:"h80",nom:"Barbacoa Hnos. Mejía",e:"🐑",zona:"Tulancingo",desc:"Barbacoa de borrego",r:4.4,ped:70,c:const Color(0xFF92400E),tipo:"comida"),
  Negocio(id:"h81",nom:"Barbacoa El Criollito",e:"🐑",zona:"Tulancingo",desc:"Barbacoa de borrego",r:4.7,ped:54,c:const Color(0xFF92400E),tipo:"comida"),
  Negocio(id:"h82",nom:"Barbacoa Villalva",e:"🐑",zona:"Tulancingo",desc:"Barbacoa de borrego",r:4.4,ped:36,c:const Color(0xFF92400E),tipo:"comida"),
  Negocio(id:"h83",nom:"Soto Jarillo (Pastes)",e:"🥟",zona:"Tulancingo",desc:"Pastes tradicionales",r:4.1,ped:983,c:const Color(0xFFD97706),tipo:"comida"),
  Negocio(id:"h84",nom:"Pastes Kikos (Zaragoza)",e:"🥟",zona:"Tulancingo",desc:"Pastes tradicionales",r:3.9,ped:600,c:const Color(0xFFD97706),tipo:"comida"),
  Negocio(id:"h85",nom:"Pastes Kikos (21 Marzo)",e:"🥟",zona:"Tulancingo",desc:"Pastes tradicionales",r:3.8,ped:339,c:const Color(0xFFD97706),tipo:"comida"),
  Negocio(id:"h86",nom:"Pastes Real del Platero",e:"🥟",zona:"Tulancingo",desc:"Pastes tradicionales",r:4.0,ped:210,c:const Color(0xFFD97706),tipo:"comida"),
  Negocio(id:"h87",nom:"Real de Plateros (Insurg.)",e:"🥟",zona:"Tulancingo",desc:"Pastes tradicionales",r:4.3,ped:47,c:const Color(0xFFD97706),tipo:"comida"),
  Negocio(id:"h88",nom:"Pastes Artesanales Toñita",e:"🥟",zona:"Tulancingo",desc:"Pastes tradicionales",r:4.2,ped:30,c:const Color(0xFFD97706),tipo:"comida"),
  Negocio(id:"h89",nom:"El Conde del Paste",e:"🥟",zona:"Tulancingo",desc:"Pastes tradicionales",r:5.0,ped:13,c:const Color(0xFFD97706),tipo:"comida"),
  Negocio(id:"h90",nom:"Pastes del Mineral",e:"🥟",zona:"Tulancingo",desc:"Pastes tradicionales",r:4.0,ped:7,c:const Color(0xFFD97706),tipo:"comida"),
  Negocio(id:"h91",nom:"Pastes Real de Plateros (Soto)",e:"🥟",zona:"Tulancingo",desc:"Pastes tradicionales",r:2.5,ped:2,c:const Color(0xFFD97706),tipo:"comida"),
  // ── Cadenas de tiendas Tulancingo / Pachuca ──
  Negocio(id:"ch01",nom:"Walmart Tulancingo",e:"walmart",zona:"Blvd. Felipe Ángeles s/n, Tulancingo",desc:"Supermercado · Abarrotes, electrónica, ropa y más",r:4.3,ped:5200,c:_cadenaColor,tipo:"cadena",horario:"7:00–23:00",tel:"7717170100",plan:"cadena"),
  Negocio(id:"ch02",nom:"Bodega Aurrera Tulancingo",e:"bodega_aurrera",zona:"Calz. Hidalgo 102, Centro, Tulancingo",desc:"Precios bajos siempre · Abarrotes y despensa",r:4.1,ped:4800,c:_cadenaColor,tipo:"cadena",horario:"7:00–23:00",tel:"7717170200",plan:"cadena"),
  Negocio(id:"ch03",nom:"Chedraui Tulancingo",e:"chedraui",zona:"Blvd. Nuevo Hidalgo s/n, Tulancingo",desc:"Supermercado · Frutas, carnes, abarrotes",r:4.2,ped:3900,c:_cadenaColor,tipo:"cadena",horario:"7:00–22:00",tel:"7717170300",plan:"cadena"),
  Negocio(id:"ch04",nom:"Soriana Pachuca",e:"soriana",zona:"Blvd. Luis Donaldo Colosio 612, Pachuca",desc:"Supermercado y tienda departamental",r:4.2,ped:3200,c:_cadenaColor,tipo:"cadena",horario:"8:00–22:00",tel:"7717170400",plan:"cadena"),
  Negocio(id:"ch05",nom:"Sam's Club Pachuca",e:"sams",zona:"Blvd. Colosio 200, Pachuca",desc:"Club de precios · Compras al mayoreo",r:4.4,ped:2800,c:_cadenaColor,tipo:"cadena",horario:"8:00–22:00",tel:"7717170500",plan:"cadena"),
  Negocio(id:"ch06",nom:"Farmacias Guadalajara",e:"farmguad",zona:"Calz. Hidalgo 400, Tulancingo",desc:"Farmacia y tienda de conveniencia",r:4.3,ped:3600,c:_cadenaColor,tipo:"cadena",horario:"7:00–23:00",tel:"7717170600",plan:"cadena"),
];

final List<Negocio> negCdmx = [
  // ── 159 Negocios reales CDMX ──
  Negocio(id:"c1",nom:"Tacos Charly Oficial",e:"🌮",zona:"Tlalpan · CDMX",desc:"Taquería",r:4.3,ped:6471,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c2",nom:"El Califa de León",e:"🌮",zona:"San Rafael · CDMX",desc:"Taquería",r:3.9,ped:5109,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c3",nom:"El Vilsito",e:"🌮",zona:"Narvarte · CDMX",desc:"Taquería",r:4.3,ped:15567,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c4",nom:"Los Cocuyos",e:"🌮",zona:"Centro · CDMX",desc:"Taquería",r:4.1,ped:13094,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c5",nom:"Tacos Atarantados",e:"🌮",zona:"Roma · CDMX",desc:"Taquería",r:4.2,ped:2712,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c6",nom:"Tacos El Paisa",e:"🌮",zona:"San Rafael · CDMX",desc:"Taquería",r:4.2,ped:6791,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c7",nom:"La Once Mil",e:"🌮",zona:"Lomas · CDMX",desc:"Taquería",r:4.8,ped:4036,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c8",nom:"El Sirloin de la Roma",e:"🌮",zona:"Roma · CDMX",desc:"Taquería",r:4.6,ped:4951,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c9",nom:"Taquería Los Parados",e:"🌮",zona:"Roma · CDMX",desc:"Taquería",r:4.3,ped:4976,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c10",nom:"Maizajo",e:"🌮",zona:"Condesa · CDMX",desc:"Taquería",r:4.1,ped:1705,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c11",nom:"El Charco de las Ranas",e:"🌮",zona:"Pedregal · CDMX",desc:"Taquería",r:4.3,ped:6363,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c12",nom:"Taquería Orinoco (Roma)",e:"🌮",zona:"Roma · CDMX",desc:"Taquería",r:4.6,ped:21062,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c13",nom:"Taquería Orinoco (Nápoles)",e:"🌮",zona:"Nápoles · CDMX",desc:"Taquería",r:4.8,ped:1490,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c14",nom:"El Tizoncito (Condesa)",e:"🌮",zona:"Condesa · CDMX",desc:"Taquería",r:4.2,ped:6801,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c15",nom:"El Huequito",e:"🌮",zona:"Nápoles · CDMX",desc:"Taquería",r:4.2,ped:4425,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c16",nom:"Tacos Domingo (Pacheco)",e:"🌮",zona:"Centro · CDMX",desc:"Taquería",r:4.5,ped:611,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c17",nom:"Tacos Domingo (Reforma)",e:"🌮",zona:"Juárez · CDMX",desc:"Taquería",r:4.5,ped:128,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c18",nom:"El Remolkito del Sirloin (Del Valle)",e:"🌮",zona:"Del Valle · CDMX",desc:"Taquería",r:4.5,ped:2429,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c19",nom:"El Remolkito del Sirloin (Roma)",e:"🌮",zona:"Roma · CDMX",desc:"Taquería",r:4.8,ped:1875,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c20",nom:"Tacos Don Juan",e:"🌮",zona:"Condesa · CDMX",desc:"Taquería",r:4.6,ped:2690,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c21",nom:"Tacos Hola El Güero",e:"🌮",zona:"Condesa · CDMX",desc:"Taquería",r:4.3,ped:1486,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c22",nom:"Los Especiales (Madero)",e:"🌮",zona:"Centro · CDMX",desc:"Taquería",r:4.3,ped:24612,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c23",nom:"Los Milanesos",e:"🌮",zona:"Álvaro Obregón · CDMX",desc:"Taquería",r:4.4,ped:7579,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c24",nom:"El Turix",e:"🌮",zona:"Polanco · CDMX",desc:"Taquería",r:4.3,ped:5526,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c26",nom:"Taquerría El Califa (Reforma)",e:"🌮",zona:"Juárez · CDMX",desc:"Taquería",r:4.3,ped:10366,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c27",nom:"Ricos Tacos Toluca",e:"🌮",zona:"Centro · CDMX",desc:"Taquería",r:4.4,ped:527,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c28",nom:"Tacos Los Paisas",e:"🌮",zona:"Centro · CDMX",desc:"Taquería",r:4.4,ped:4888,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c29",nom:"El Farolito Polanco",e:"🌮",zona:"Polanco · CDMX",desc:"Taquería",r:4.1,ped:3664,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c30",nom:"Tacos de Guisado Centro",e:"🌮",zona:"Centro · CDMX",desc:"Taquería",r:4.2,ped:79,c:const Color(0xFFDC2626),tipo:"comida"),
  Negocio(id:"c31",nom:"Rincón Tarasco (Escandón)",e:"🥩",zona:"Escandón · CDMX",desc:"Carnes",r:4.5,ped:1624,c:const Color(0xFF991B1B),tipo:"carniceria"),
  Negocio(id:"c32",nom:"Rincón Tarasco (José Martí)",e:"🥩",zona:"Escandón · CDMX",desc:"Carnes",r:4.3,ped:1615,c:const Color(0xFF991B1B),tipo:"carniceria"),
  Negocio(id:"c33",nom:"Porco Rosso",e:"🥩",zona:"Roma · CDMX",desc:"Carnes",r:4.6,ped:7285,c:const Color(0xFF991B1B),tipo:"carniceria"),
  Negocio(id:"c34",nom:"La Casa de Toño (Zona Rosa)",e:"🇲🇽",zona:"Juárez · CDMX",desc:"Comida mexicana",r:4.5,ped:31748,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c35",nom:"La Casa de Toño (Narvarte)",e:"🇲🇽",zona:"Narvarte · CDMX",desc:"Comida mexicana",r:4.5,ped:32901,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c36",nom:"Beatricita",e:"🇲🇽",zona:"Juárez · CDMX",desc:"Comida mexicana",r:4.2,ped:1216,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c37",nom:"Chilpa",e:"🇲🇽",zona:"Condesa · CDMX",desc:"Comida mexicana",r:4.5,ped:3771,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c38",nom:"Chilakillers Loungería",e:"🇲🇽",zona:"Tacubaya · CDMX",desc:"Comida mexicana",r:4.3,ped:2061,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c39",nom:"Tamales Madre",e:"🇲🇽",zona:"Juárez · CDMX",desc:"Comida mexicana",r:4.1,ped:393,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c40",nom:"Salón Corona",e:"🇲🇽",zona:"Centro · CDMX",desc:"Comida mexicana",r:4.0,ped:8296,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c41",nom:"La Polar",e:"🇲🇽",zona:"San Rafael · CDMX",desc:"Comida mexicana",r:4.3,ped:53,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c42",nom:"Expendio de Maíz",e:"🇲🇽",zona:"Roma · CDMX",desc:"Comida mexicana",r:4.2,ped:1728,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c43",nom:"Contramar",e:"🐟",zona:"Roma · CDMX",desc:"Mariscos",r:4.5,ped:6413,c:const Color(0xFF0891B2),tipo:"mariscos"),
  Negocio(id:"c44",nom:"El Pescadito (Centro)",e:"🐟",zona:"Centro · CDMX",desc:"Mariscos",r:4.5,ped:4159,c:const Color(0xFF0891B2),tipo:"mariscos"),
  Negocio(id:"c45",nom:"El Pescadito (Condesa)",e:"🐟",zona:"Condesa · CDMX",desc:"Mariscos",r:4.6,ped:6764,c:const Color(0xFF0891B2),tipo:"mariscos"),
  Negocio(id:"c46",nom:"La Docena",e:"🐟",zona:"Roma · CDMX",desc:"Mariscos",r:4.3,ped:4714,c:const Color(0xFF0891B2),tipo:"mariscos"),
  Negocio(id:"c47",nom:"Pujol",e:"⭐",zona:"Polanco · CDMX",desc:"Alta cocina",r:4.4,ped:5721,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c48",nom:"Quintonil",e:"⭐",zona:"Polanco · CDMX",desc:"Alta cocina",r:4.4,ped:2873,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c49",nom:"Rosetta",e:"⭐",zona:"Roma · CDMX",desc:"Alta cocina",r:4.2,ped:4584,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c50",nom:"Máximo",e:"⭐",zona:"Roma · CDMX",desc:"Alta cocina",r:4.4,ped:2640,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c51",nom:"Sud 777",e:"⭐",zona:"Pedregal · CDMX",desc:"Alta cocina",r:4.3,ped:3377,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c52",nom:"Limosneros",e:"⭐",zona:"Centro · CDMX",desc:"Alta cocina",r:4.5,ped:3333,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c53",nom:"Dulce Patria",e:"⭐",zona:"Polanco · CDMX",desc:"Alta cocina",r:4.5,ped:1420,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c54",nom:"Nicos",e:"⭐",zona:"Clavería · CDMX",desc:"Alta cocina",r:4.3,ped:4973,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c55",nom:"Biko",e:"⭐",zona:"Polanco · CDMX",desc:"Alta cocina",r:4.3,ped:205,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c56",nom:"BARTOLA",e:"🔥",zona:"Roma · CDMX",desc:"Trending",r:4.4,ped:449,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"c57",nom:"BOBO Burgers & Café",e:"🔥",zona:"Roma · CDMX",desc:"Trending",r:4.5,ped:2238,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"c58",nom:"ISMO",e:"🔥",zona:"Roma · CDMX",desc:"Trending",r:4.3,ped:234,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"c59",nom:"Tonchin Ramen",e:"🔥",zona:"Juárez · CDMX",desc:"Trending",r:4.4,ped:510,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"c60",nom:"Ramen Chido",e:"🔥",zona:"Condesa · CDMX",desc:"Trending",r:4.0,ped:38,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"c61",nom:"LOS LOOSERS",e:"🔥",zona:"Roma · CDMX",desc:"Trending",r:4.1,ped:1722,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"c62",nom:"Selva Negra Ajusco",e:"🔥",zona:"Ajusco · CDMX",desc:"Trending",r:4.2,ped:2175,c:const Color(0xFFEA580C),tipo:"comida"),
  Negocio(id:"c63",nom:"El Cardenal",e:"🏛️",zona:"Centro · CDMX",desc:"Restaurante consagrado",r:4.6,ped:19768,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c64",nom:"Azul Histórico",e:"🏛️",zona:"Centro · CDMX",desc:"Restaurante consagrado",r:4.4,ped:10381,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c65",nom:"Los Danzantes (Coyoacán)",e:"🏛️",zona:"Coyoacán · CDMX",desc:"Restaurante consagrado",r:4.4,ped:5503,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c66",nom:"El Mayor",e:"🏛️",zona:"Centro · CDMX",desc:"Restaurante consagrado",r:4.4,ped:7724,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c67",nom:"Blanco Colima",e:"🏛️",zona:"Roma · CDMX",desc:"Restaurante consagrado",r:4.5,ped:2973,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c68",nom:"Lardo",e:"🏛️",zona:"Condesa · CDMX",desc:"Restaurante consagrado",r:4.4,ped:7423,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c69",nom:"Páramo",e:"🏛️",zona:"Roma · CDMX",desc:"Restaurante consagrado",r:4.4,ped:3713,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c70",nom:"La Barraca Valenciana",e:"🏛️",zona:"Coyoacán · CDMX",desc:"Restaurante consagrado",r:4.5,ped:2742,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c71",nom:"Eno",e:"🏛️",zona:"Roma · CDMX",desc:"Restaurante consagrado",r:4.0,ped:2869,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c72",nom:"Molino El Pujol",e:"🏛️",zona:"Condesa · CDMX",desc:"Restaurante consagrado",r:3.9,ped:1521,c:AppTheme.pu,tipo:"comida"),
  Negocio(id:"c73",nom:"Café El Jarocho (Original)",e:"☕",zona:"Coyoacán · CDMX",desc:"Café",r:4.5,ped:17354,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"c74",nom:"El Jarocho (24hrs)",e:"☕",zona:"Coyoacán · CDMX",desc:"Café",r:4.4,ped:11526,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"c75",nom:"Café La Habana",e:"☕",zona:"Juárez · CDMX",desc:"Café",r:4.3,ped:9008,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"c76",nom:"Café Nin",e:"☕",zona:"Juárez · CDMX",desc:"Café",r:4.4,ped:10252,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"c77",nom:"Panadería Rosetta",e:"☕",zona:"Roma · CDMX",desc:"Café",r:4.5,ped:9922,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"c78",nom:"SAN Matcha (Roma)",e:"☕",zona:"Roma · CDMX",desc:"Café",r:4.5,ped:664,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"c79",nom:"SAN Matcha (Condesa)",e:"☕",zona:"Condesa · CDMX",desc:"Café",r:4.7,ped:147,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"c80",nom:"Café Avellaneda",e:"☕",zona:"Coyoacán · CDMX",desc:"Café",r:4.6,ped:3567,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"c81",nom:"Tierra Garat (Coyoacán)",e:"☕",zona:"Coyoacán · CDMX",desc:"Café",r:4.5,ped:4345,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"c82",nom:"Buna - Café Rico",e:"☕",zona:"Roma · CDMX",desc:"Café",r:4.5,ped:1590,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"c83",nom:"Cicatriz",e:"☕",zona:"Juárez · CDMX",desc:"Café",r:4.3,ped:1631,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"c84",nom:"Cafebrería El Péndulo (Condesa)",e:"☕",zona:"Condesa · CDMX",desc:"Café",r:4.5,ped:10191,c:const Color(0xFF78350F),tipo:"cafe"),
  Negocio(id:"c85",nom:"Churrería El Moro (Centro)",e:"🍫",zona:"Centro · CDMX",desc:"Postres & dulces",r:4.5,ped:60133,c:const Color(0xFFD97706),tipo:"postres"),
  Negocio(id:"c86",nom:"Churrería El Moro (Condesa)",e:"🍫",zona:"Condesa · CDMX",desc:"Postres & dulces",r:4.3,ped:12146,c:const Color(0xFFD97706),tipo:"postres"),
  Negocio(id:"c87",nom:"Churrería El Moro (Lerma)",e:"🍫",zona:"Cuauhtémoc · CDMX",desc:"Postres & dulces",r:4.4,ped:7987,c:const Color(0xFFD97706),tipo:"postres"),
  Negocio(id:"c88",nom:"PUNI PUNI Bubble Tea",e:"🍫",zona:"Roma · CDMX",desc:"Postres & dulces",r:4.3,ped:289,c:const Color(0xFFD97706),tipo:"postres"),
  Negocio(id:"c89",nom:"Club Sorbet",e:"🍫",zona:"Condesa · CDMX",desc:"Postres & dulces",r:4.3,ped:310,c:const Color(0xFFD97706),tipo:"postres"),
  Negocio(id:"c90",nom:"Rufus",e:"🍫",zona:"Roma · CDMX",desc:"Postres & dulces",r:4.3,ped:278,c:const Color(0xFFD97706),tipo:"postres"),
  Negocio(id:"c91",nom:"Nevería Roxy (Condesa)",e:"🍫",zona:"Condesa · CDMX",desc:"Postres & dulces",r:4.6,ped:5797,c:const Color(0xFFD97706),tipo:"postres"),
  Negocio(id:"c92",nom:"Mercado de La Viga",e:"🏪",zona:"Iztapalapa · CDMX",desc:"Mercado",r:4.3,ped:51222,c:AppTheme.tl,tipo:"mercado"),
  Negocio(id:"c93",nom:"Mercado San Juan Pugibet",e:"🏪",zona:"Centro · CDMX",desc:"Mercado",r:4.5,ped:23299,c:AppTheme.tl,tipo:"mercado"),
  Negocio(id:"c94",nom:"Mercado de Coyoacán",e:"🏪",zona:"Coyoacán · CDMX",desc:"Mercado",r:4.5,ped:54619,c:AppTheme.tl,tipo:"mercado"),
  Negocio(id:"c95",nom:"Mercado Sonora",e:"🏪",zona:"Merced · CDMX",desc:"Mercado",r:4.3,ped:119352,c:AppTheme.tl,tipo:"mercado"),
  Negocio(id:"c96",nom:"Mercado de La Merced",e:"🏪",zona:"Merced · CDMX",desc:"Mercado",r:4.4,ped:43379,c:AppTheme.tl,tipo:"mercado"),
  Negocio(id:"c97",nom:"Mercado Jamaica (Flores)",e:"🏪",zona:"Jamaica · CDMX",desc:"Mercado",r:4.5,ped:58030,c:AppTheme.tl,tipo:"mercado"),
  Negocio(id:"c98",nom:"Mercado Roma",e:"🏪",zona:"Roma · CDMX",desc:"Mercado",r:4.3,ped:16847,c:AppTheme.tl,tipo:"mercado"),
  Negocio(id:"c99",nom:"Mercado Medellín",e:"🏪",zona:"Roma · CDMX",desc:"Mercado",r:4.4,ped:16643,c:AppTheme.tl,tipo:"mercado"),
  Negocio(id:"c100",nom:"Mercado de Tepito",e:"🏪",zona:"Tepito · CDMX",desc:"Mercado",r:4.6,ped:3150,c:AppTheme.tl,tipo:"mercado"),
  Negocio(id:"c101",nom:"Mercado Artesanías La Ciudadela",e:"🏪",zona:"Centro · CDMX",desc:"Mercado",r:4.5,ped:33264,c:AppTheme.tl,tipo:"mercado"),
  Negocio(id:"c102",nom:"El Bazar Sábado (San Ángel)",e:"🏪",zona:"San Ángel · CDMX",desc:"Mercado",r:4.5,ped:5410,c:AppTheme.tl,tipo:"mercado"),
  Negocio(id:"c103",nom:"Comedor de los Milagros",e:"🏪",zona:"Roma · CDMX",desc:"Mercado",r:4.4,ped:10538,c:AppTheme.tl,tipo:"mercado"),
  Negocio(id:"c104",nom:"Hanky Panky Cocktail Bar",e:"🍸",zona:"Juárez · CDMX",desc:"Bar & cocktails",r:4.2,ped:1796,c:const Color(0xFF7C2D12),tipo:"bebidas"),
  Negocio(id:"c105",nom:"Licorería Limantour",e:"🍸",zona:"Roma · CDMX",desc:"Bar & cocktails",r:4.4,ped:3510,c:const Color(0xFF7C2D12),tipo:"bebidas"),
  Negocio(id:"c106",nom:"Baltra Bar",e:"🍸",zona:"Condesa · CDMX",desc:"Bar & cocktails",r:4.5,ped:1400,c:const Color(0xFF7C2D12),tipo:"bebidas"),
  Negocio(id:"c107",nom:"Fifty Mils (Four Seasons)",e:"🍸",zona:"Juárez · CDMX",desc:"Bar & cocktails",r:4.5,ped:965,c:const Color(0xFF7C2D12),tipo:"bebidas"),
  Negocio(id:"c108",nom:"Departamento",e:"🍸",zona:"Roma · CDMX",desc:"Bar & cocktails",r:4.1,ped:2905,c:const Color(0xFF7C2D12),tipo:"bebidas"),
  Negocio(id:"c109",nom:"Diablo Negro Mezcal Bar",e:"🍸",zona:"Roma · CDMX",desc:"Bar & cocktails",r:4.9,ped:237,c:const Color(0xFF7C2D12),tipo:"bebidas"),
  Negocio(id:"c110",nom:"Carnitas Don Pepe",e:"🍔",zona:"Iztapalapa · CDMX",desc:"Comfort food",r:4.4,ped:351,c:const Color(0xFFB91C1C),tipo:"comida"),
  Negocio(id:"c111",nom:"La Casa de las Enchiladas",e:"🍔",zona:"Anáhuac · CDMX",desc:"Comfort food",r:4.2,ped:1284,c:const Color(0xFFB91C1C),tipo:"comida"),
  Negocio(id:"c112",nom:"Deigo Sushi Roma",e:"🎬",zona:"Roma Norte · CDMX",desc:"Influencer pick",r:4.9,ped:1523,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c113",nom:"Deigo Ramen Zona Rosa",e:"🎬",zona:"Zona Rosa · CDMX",desc:"Influencer pick",r:4.3,ped:5394,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c114",nom:"Deigo Ramen Condesa",e:"🎬",zona:"Condesa · CDMX",desc:"Influencer pick",r:4.4,ped:2717,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c115",nom:"Deigo Ramen Roma",e:"🎬",zona:"Roma Norte · CDMX",desc:"Influencer pick",r:4.3,ped:684,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c116",nom:"Deigo Ramen Insurgentes",e:"🎬",zona:"Del Valle · CDMX",desc:"Influencer pick",r:4.7,ped:1037,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c117",nom:"Deigo Sushi Insurgentes",e:"🎬",zona:"Del Valle · CDMX",desc:"Influencer pick",r:4.8,ped:367,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c118",nom:"Deigo & Kaito (Original)",e:"🎬",zona:"Del Valle · CDMX",desc:"Influencer pick",r:4.5,ped:5843,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c119",nom:"Bolichera 21",e:"🎬",zona:"Zona Rosa · CDMX",desc:"Influencer pick",r:4.4,ped:1441,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c120",nom:"Torikami Café",e:"🎬",zona:"Condesa · CDMX",desc:"Influencer pick",r:3.7,ped:1059,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c121",nom:"Fasfú Burgers",e:"🎬",zona:"Juárez · CDMX",desc:"Influencer pick",r:2.2,ped:567,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c122",nom:"Don Core",e:"🎬",zona:"Tabacalera · CDMX",desc:"Influencer pick",r:4.6,ped:6747,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c123",nom:"Bambii & Lele Malatang",e:"🎬",zona:"Roma Norte · CDMX",desc:"Influencer pick",r:4.4,ped:172,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c124",nom:"Taquería La Milagrosa",e:"🎬",zona:"Juárez · CDMX",desc:"Influencer pick",r:1.3,ped:618,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c125",nom:"Goyo's Burgers Roma",e:"🎬",zona:"Roma Norte · CDMX",desc:"Influencer pick",r:4.7,ped:1492,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c126",nom:"Goyo's Burgers Nápoles",e:"🎬",zona:"Nápoles · CDMX",desc:"Influencer pick",r:4.8,ped:916,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c127",nom:"Restaurante YUN Ramen & Sushi",e:"🎬",zona:"Iztapalapa · CDMX",desc:"Influencer pick",r:4.1,ped:4167,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c128",nom:"Que Chicken",e:"🎬",zona:"Benito Juárez · CDMX",desc:"Influencer pick",r:2.1,ped:18,c:const Color(0xFFEC4899),tipo:"comida"),
  Negocio(id:"c129",nom:"Café de Tacuba",e:"🏪",zona:"Centro · CDMX",desc:"Cadena",r:4.4,ped:26629,c:const Color(0xFF1565C0),tipo:"cadena"),
  Negocio(id:"c130",nom:"Bisquets Obregón (Madero)",e:"🏪",zona:"Centro · CDMX",desc:"Cadena",r:4.3,ped:10276,c:const Color(0xFF1565C0),tipo:"cadena"),
  Negocio(id:"c131",nom:"Bisquets Obregón (Tacuba)",e:"🏪",zona:"Centro · CDMX",desc:"Cadena",r:4.3,ped:2697,c:const Color(0xFF1565C0),tipo:"cadena"),
  Negocio(id:"c132",nom:"Sonora Grill (Molière)",e:"🏪",zona:"Polanco · CDMX",desc:"Cadena",r:4.7,ped:10050,c:const Color(0xFF1565C0),tipo:"cadena"),
  Negocio(id:"c133",nom:"Sonora Grill Prime",e:"🏪",zona:"Polanco · CDMX",desc:"Cadena",r:4.6,ped:6635,c:const Color(0xFF1565C0),tipo:"cadena"),
  Negocio(id:"c134",nom:"El Fogoncito (Anzures)",e:"🏪",zona:"Anzures · CDMX",desc:"Cadena",r:4.4,ped:3824,c:const Color(0xFF1565C0),tipo:"cadena"),
  Negocio(id:"c135",nom:"El Huequito (Nápoles)",e:"🏪",zona:"Nápoles · CDMX",desc:"Cadena",r:4.2,ped:4425,c:const Color(0xFF1565C0),tipo:"cadena"),
  Negocio(id:"c136",nom:"Au Pied de Cochon",e:"🏪",zona:"Polanco · CDMX",desc:"Cadena",r:4.6,ped:3292,c:const Color(0xFF1565C0),tipo:"cadena"),
  Negocio(id:"c137",nom:"El Bajío (Original)",e:"🍲",zona:"Azcapotzalco · CDMX",desc:"Fonda · Comida casera",r:4.3,ped:4523,c:const Color(0xFFCA8A04),tipo:"comida"),
  Negocio(id:"c138",nom:"El Bajío Vía Vallejo",e:"🍲",zona:"Azcapotzalco · CDMX",desc:"Fonda · Comida casera",r:4.2,ped:2904,c:const Color(0xFFCA8A04),tipo:"comida"),
  Negocio(id:"c139",nom:"El Pozole de Moctezuma",e:"🍲",zona:"Guerrero · CDMX",desc:"Fonda · Comida casera",r:4.5,ped:4007,c:const Color(0xFFCA8A04),tipo:"comida"),
  Negocio(id:"c140",nom:"Fonda Margarita",e:"🍲",zona:"Del Valle · CDMX",desc:"Fonda · Comida casera",r:4.3,ped:4333,c:const Color(0xFFCA8A04),tipo:"comida"),
  Negocio(id:"c141",nom:"Fonda Doña Blanca",e:"🍲",zona:"Centro · CDMX",desc:"Fonda · Comida casera",r:4.3,ped:990,c:const Color(0xFFCA8A04),tipo:"comida"),
  Negocio(id:"c142",nom:"La Oveja Negra",e:"🍲",zona:"Sta. María · CDMX",desc:"Fonda · Comida casera",r:4.4,ped:6420,c:const Color(0xFFCA8A04),tipo:"comida"),
  Negocio(id:"c143",nom:"Fonda Mi Lupita",e:"🍲",zona:"Condesa · CDMX",desc:"Fonda · Comida casera",r:4.2,ped:210,c:const Color(0xFFCA8A04),tipo:"comida"),
  Negocio(id:"c144",nom:"La Fonda Oaxaqueña",e:"🍲",zona:"G.A. Madero · CDMX",desc:"Fonda · Comida casera",r:4.2,ped:1880,c:const Color(0xFFCA8A04),tipo:"comida"),
  Negocio(id:"c145",nom:"La Casa de los Tacos Coyoacán",e:"🍲",zona:"Coyoacán · CDMX",desc:"Fonda · Comida casera",r:4.4,ped:3234,c:const Color(0xFFCA8A04),tipo:"comida"),
  Negocio(id:"c146",nom:"La Casa de Toño (Original)",e:"🏠",zona:"Azcapotzalco · CDMX",desc:"Pozole y antojitos",r:4.5,ped:19876,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c147",nom:"La Casa de Toño (Polanco)",e:"🏠",zona:"Polanco · CDMX",desc:"Pozole y antojitos",r:4.5,ped:7685,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c148",nom:"La Casa de Toño (Tlatelolco)",e:"🏠",zona:"Tlatelolco · CDMX",desc:"Pozole y antojitos",r:4.5,ped:7074,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c149",nom:"La Casa de Toño (Coyoacán)",e:"🏠",zona:"Coyoacán · CDMX",desc:"Pozole y antojitos",r:4.5,ped:6021,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c150",nom:"La Casa de Toño (Coapa)",e:"🏠",zona:"Coapa · CDMX",desc:"Pozole y antojitos",r:4.5,ped:17281,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c151",nom:"La Casa de Toño Express",e:"🏠",zona:"Narvarte · CDMX",desc:"Pozole y antojitos",r:3.9,ped:313,c:const Color(0xFF15803D),tipo:"comida"),
  Negocio(id:"c152",nom:"Churrería El Moro (Original)",e:"🏪",zona:"Centro · CDMX",desc:"Restaurante popular",r:4.5,ped:60132,c:const Color(0xFF1565C0),tipo:"comida"),
  Negocio(id:"c153",nom:"Churrería El Moro (Condesa)",e:"🏪",zona:"Condesa · CDMX",desc:"Restaurante popular",r:4.3,ped:12146,c:const Color(0xFF1565C0),tipo:"comida"),
  Negocio(id:"c154",nom:"Los Cocuyos (24/7)",e:"🏪",zona:"Centro · CDMX",desc:"Restaurante popular",r:4.1,ped:13094,c:const Color(0xFF1565C0),tipo:"comida"),
  Negocio(id:"c155",nom:"Café El Jarocho (Original)",e:"🏪",zona:"Coyoacán · CDMX",desc:"Restaurante popular",r:4.5,ped:17354,c:const Color(0xFF1565C0),tipo:"comida"),
  Negocio(id:"c156",nom:"Café El Jarocho (24hrs)",e:"🏪",zona:"Coyoacán · CDMX",desc:"Restaurante popular",r:4.4,ped:11526,c:const Color(0xFF1565C0),tipo:"comida"),
  Negocio(id:"c157",nom:"Café La Habana",e:"🏪",zona:"Juárez · CDMX",desc:"Restaurante popular",r:4.3,ped:9008,c:const Color(0xFF1565C0),tipo:"comida"),
  Negocio(id:"c158",nom:"Tostadas de Coyoacán",e:"🏪",zona:"Coyoacán · CDMX",desc:"Restaurante popular",r:4.3,ped:6181,c:const Color(0xFF1565C0),tipo:"comida"),
  Negocio(id:"c159",nom:"Las Tlayudas Oaxaqueñas",e:"🏪",zona:"Narvarte · CDMX",desc:"Restaurante popular",r:4.2,ped:2586,c:const Color(0xFF1565C0),tipo:"comida"),
  // ── Cadenas de tiendas CDMX ──
  Negocio(id:"cc01",nom:"Costco Satélite",e:"costco",zona:"Blvd. M. Ávila Camacho 1007, Naucalpan",desc:"Club de precios · Mayoreo y electrónica",r:4.6,ped:6800,c:_cadenaColor,tipo:"cadena",horario:"8:00–22:00",tel:"5555551001",plan:"cadena"),
  Negocio(id:"cc02",nom:"Walmart Copilco",e:"walmart",zona:"Av. Copilco 300, Coyoacán, CDMX",desc:"Supermercado · Abarrotes, electrónica, ropa",r:4.3,ped:7200,c:_cadenaColor,tipo:"cadena",horario:"7:00–23:00",tel:"5555551002",plan:"cadena"),
  Negocio(id:"cc03",nom:"Sam's Club Xola",e:"sams",zona:"Av. Xola 40, Col. del Valle, CDMX",desc:"Club de precios · Compras al mayoreo",r:4.4,ped:4500,c:_cadenaColor,tipo:"cadena",horario:"8:00–22:00",tel:"5555551003",plan:"cadena"),
  Negocio(id:"cc04",nom:"Liverpool Centro",e:"liverpool",zona:"Av. 20 de Noviembre 3, Centro, CDMX",desc:"Tienda departamental · Ropa, electrónica, hogar",r:4.5,ped:3800,c:_cadenaColor,tipo:"cadena",horario:"10:00–21:00",tel:"5555551004",plan:"cadena"),
  Negocio(id:"cc05",nom:"Home Depot Perinorte",e:"homedepot",zona:"Perinorte, Tlalnepantla, Estado de Mexico",desc:"Materiales de construcción y hogar",r:4.3,ped:3200,c:_cadenaColor,tipo:"cadena",horario:"7:00–22:00",tel:"5555551005",plan:"cadena"),
  Negocio(id:"cc06",nom:"Chedraui Azcapotzalco",e:"chedraui",zona:"Calz. Vallejo 960, Azcapotzalco, CDMX",desc:"Supermercado · Frutas, carnes, abarrotes",r:4.2,ped:3600,c:_cadenaColor,tipo:"cadena",horario:"7:00–22:00",tel:"5555551006",plan:"cadena"),
  Negocio(id:"cc07",nom:"AutoZone Insurgentes",e:"autozone",zona:"Av. Insurgentes Sur 1200, CDMX",desc:"Refacciones automotrices y accesorios",r:4.3,ped:2100,c:_cadenaColor,tipo:"cadena",horario:"8:00–21:00",tel:"5555551007",plan:"cadena"),

  // ═══ TEPITO - ZONAS DE COMPRA (VIP MANDADO DORADO) ═══
  Negocio(id:"tp01",nom:"Tepito Uniformes",e:"⚽",zona:"Matamoros entre Tenochtitlán y Toltecas, Tepito",desc:"Uniformes deportivos · Personalización · Mayoreo",r:4.5,ped:3200,c:const Color(0xFFDAA520),tipo:"tepito",horario:"9:00–18:00",tel:"5555000001",plan:"vip_mandado"),
  Negocio(id:"tp02",nom:"Tepito Tenis y Calzado",e:"👟",zona:"Eje 1 Norte esq Matamoros, Tepito, CDMX",desc:"Tenis de marca · Calzado deportivo · Mayoreo",r:4.4,ped:4100,c:const Color(0xFFDAA520),tipo:"tepito",horario:"9:00–18:00",tel:"5555000002",plan:"vip_mandado"),
  Negocio(id:"tp03",nom:"Tepito Trajes y Vestir",e:"👔",zona:"Jesús Carranza, Tepito, CDMX",desc:"Trajes · Camisas · Ropa de vestir a buen precio",r:4.3,ped:2800,c:const Color(0xFFDAA520),tipo:"tepito",horario:"9:00–18:00",tel:"5555000003",plan:"vip_mandado"),
  Negocio(id:"tp04",nom:"Tepito Zapatos",e:"👞",zona:"Aztecas y Matamoros, Tepito, CDMX",desc:"Zapatos de piel · Botas · Calzado casual y formal",r:4.3,ped:2500,c:const Color(0xFFDAA520),tipo:"tepito",horario:"9:00–18:00",tel:"5555000004",plan:"vip_mandado"),
  Negocio(id:"tp05",nom:"Tepito Electrónica",e:"📱",zona:"Eje 1 Norte, zona celulares, Tepito, CDMX",desc:"Celulares · Accesorios · Electrónica · Reparación",r:4.2,ped:5600,c:const Color(0xFFDAA520),tipo:"tepito",horario:"9:00–18:00",tel:"5555000005",plan:"vip_mandado"),
  Negocio(id:"tp06",nom:"Tepito Ropa",e:"👕",zona:"Tenochtitlán, Tepito, CDMX",desc:"Ropa casual · Streetwear · Playeras · Jeans · Mayoreo",r:4.4,ped:6200,c:const Color(0xFFDAA520),tipo:"tepito",horario:"9:00–18:00",tel:"5555000006",plan:"vip_mandado"),
  Negocio(id:"tp08",nom:"Tepito Accesorios",e:"💍",zona:"Peralvillo y Matamoros, Tepito, CDMX",desc:"Joyería · Relojes · Lentes · Accesorios de moda",r:4.2,ped:2900,c:const Color(0xFFDAA520),tipo:"tepito",horario:"9:00–18:00",tel:"5555000008",plan:"vip_mandado"),

  // ═══ PLAZAS CHINAS (VIP MANDADO DORADO) ═══
  Negocio(id:"pz01",nom:"Plaza Izazaga 89",e:"🇨🇳",zona:"José María Izazaga 89, Centro, CDMX",desc:"Electrónica, accesorios, mayoreo",r:4.3,ped:4800,c:const Color(0xFFDAA520),tipo:"plaza_china",horario:"10:00–19:00",tel:"5555000011",plan:"vip_mandado"),
  Negocio(id:"pz02",nom:"Plaza Izazaga 38",e:"🇨🇳",zona:"José María Izazaga 38, Centro, CDMX",desc:"3 pisos, 250+ tiendas, mayoreo",r:4.2,ped:3600,c:const Color(0xFFDAA520),tipo:"plaza_china",horario:"10:00–19:00",tel:"5555000012",plan:"vip_mandado"),
  Negocio(id:"pz03",nom:"Plaza Izazaga 29",e:"🇨🇳",zona:"José María Izazaga 29, Centro, CDMX",desc:"Juguetes, motos eléctricas, mayoreo",r:4.2,ped:3200,c:const Color(0xFFDAA520),tipo:"plaza_china",horario:"10:00–19:00",tel:"5555000013",plan:"vip_mandado"),
  Negocio(id:"pz04",nom:"Plaza Mesones 129",e:"📎",zona:"Mesones 129, Centro, CDMX",desc:"Papelería asiática, mayoreo",r:4.1,ped:2800,c:const Color(0xFFDAA520),tipo:"plaza_china",horario:"10:00–19:00",tel:"5555000014",plan:"vip_mandado"),

  // ═══ MERCADOS CDMX (VIP MANDADO DORADO) ═══
  Negocio(id:"mk01",nom:"La Merced",e:"🛒",zona:"Anillo de Circunvalación, La Merced, CDMX",desc:"El mercado más grande de CDMX · Abarrotes al mayoreo",r:4.4,ped:7800,c:const Color(0xFFDAA520),tipo:"mercado",horario:"5:00–18:00",tel:"5555000021",plan:"vip_mandado"),
  Negocio(id:"mk02",nom:"Central de Abastos",e:"🍎",zona:"Eje 6 Sur, Iztapalapa, CDMX",desc:"Frutas · Verduras · Mayoreo · El más grande de Latinoamérica",r:4.5,ped:9200,c:const Color(0xFFDAA520),tipo:"mercado",horario:"4:00–17:00",tel:"5555000022",plan:"vip_mandado"),
  Negocio(id:"mk03",nom:"Mercado de Sonora",e:"🌿",zona:"Fray Servando Teresa de Mier 419, Merced, CDMX",desc:"Hierbas · Artículos esotéricos · Animales · Artesanías",r:4.3,ped:3400,c:const Color(0xFFDAA520),tipo:"mercado",horario:"7:00–19:00",tel:"5555000023",plan:"vip_mandado"),
  Negocio(id:"mk04",nom:"Mercado de Jamaica",e:"🌸",zona:"Av. Morelos, Jamaica, CDMX",desc:"Flores · Arreglos florales · Plantas · El mercado de las flores",r:4.6,ped:4100,c:const Color(0xFFDAA520),tipo:"mercado",horario:"5:00–19:00",tel:"5555000024",plan:"vip_mandado"),
  Negocio(id:"mk05",nom:"La Lagunilla",e:"👗",zona:"Eje 1 Norte, La Lagunilla, CDMX",desc:"Ropa · Antigüedades · Curiosidades · Tianguis dominical",r:4.3,ped:3800,c:const Color(0xFFDAA520),tipo:"mercado",horario:"8:00–18:00",tel:"5555000025",plan:"vip_mandado"),

  // ═══ RESTAURANTES CDMX (CADENA AZUL) ═══
  Negocio(id:"rx01",nom:"La Casa de Toño",e:"🍲",zona:"Insurgentes Sur, CDMX",desc:"Pozole · Sopes · Comida mexicana 24hrs",r:4.6,ped:5200,c:_cadenaColor,tipo:"cadena",horario:"24 horas",tel:"5555000031",plan:"cadena"),
  Negocio(id:"rx02",nom:"El Califa de León",e:"🌮",zona:"C. Altamirano 22, San Rafael, CDMX",desc:"Tacos legendarios desde 1968 · Estrella Michelin",r:4.9,ped:6800,c:_cadenaColor,tipo:"cadena",horario:"13:00–02:00",tel:"5555000032",plan:"cadena"),
  Negocio(id:"rx03",nom:"Café El Jarocho",e:"☕",zona:"Av. México 155, Coyoacán, CDMX",desc:"El café más famoso de Coyoacán",r:4.8,ped:4500,c:_cadenaColor,tipo:"cadena",horario:"6:00–01:00",tel:"5555000033",plan:"cadena"),
  Negocio(id:"rx04",nom:"Los Cocuyos",e:"🌮",zona:"Bolívar 56, Centro Histórico, CDMX",desc:"Suadero y longaniza legendarios",r:4.7,ped:3900,c:_cadenaColor,tipo:"cadena",horario:"18:00–02:00",tel:"5555000034",plan:"cadena"),
  Negocio(id:"rx05",nom:"Taquería Orinoco",e:"🌮",zona:"Calle Frontera 170, Roma Norte, CDMX",desc:"Tacos de chicharrón prensado estilo Monterrey",r:4.8,ped:4200,c:_cadenaColor,tipo:"cadena",horario:"8:00–23:00",tel:"5555000035",plan:"cadena"),
  Negocio(id:"rx06",nom:"El Cardenal",e:"🍽️",zona:"Calle de la Palma 23, Centro, CDMX",desc:"Alta cocina mexicana · Tradición desde 1969",r:4.7,ped:2800,c:_cadenaColor,tipo:"cadena",horario:"8:00–18:30",tel:"5555000036",plan:"cadena"),
  Negocio(id:"rx07",nom:"Sanborns",e:"sanborns",zona:"Varias sucursales, CDMX",desc:"Restaurante · Tienda · Casa de los Azulejos",r:4.3,ped:3600,c:_cadenaColor,tipo:"cadena",horario:"7:00–23:00",tel:"5555000037",plan:"cadena"),
  Negocio(id:"rx08",nom:"VIPS",e:"vips",zona:"Varias sucursales, CDMX",desc:"Restaurante · Enchiladas y café · Familia",r:4.2,ped:3200,c:_cadenaColor,tipo:"cadena",horario:"7:00–23:00",tel:"5555000038",plan:"cadena"),
  Negocio(id:"rx09",nom:"La Casa de los Tacos",e:"🌮",zona:"Varias sucursales, CDMX",desc:"Tacos al pastor · Gringas · Volcanes",r:4.5,ped:4800,c:_cadenaColor,tipo:"cadena",horario:"12:00–04:00",tel:"5555000039",plan:"cadena"),

  // ═══ CADENAS DE COMIDA RÁPIDA (CADENA AZUL) ═══
  Negocio(id:"ff01",nom:"Starbucks",e:"starbucks",zona:"Varias sucursales, CDMX",desc:"Café · Frappuccinos · Pastelería",r:4.3,ped:5800,c:_cadenaColor,tipo:"cadena",horario:"6:00–22:00",tel:"5555000041",plan:"cadena"),
  Negocio(id:"ff02",nom:"Domino's Pizza",e:"dominos",zona:"Varias sucursales, CDMX",desc:"Pizza · Alitas · Pasta · Delivery",r:4.2,ped:7200,c:_cadenaColor,tipo:"cadena",horario:"11:00–23:00",tel:"5555000042",plan:"cadena"),
  Negocio(id:"ff03",nom:"Pizza Hut",e:"pizzahut",zona:"Varias sucursales, CDMX",desc:"Pizza · Ensaladas · Pastas",r:4.1,ped:3800,c:_cadenaColor,tipo:"cadena",horario:"11:00–23:00",tel:"5555000043",plan:"cadena"),
  Negocio(id:"ff04",nom:"McDonald's",e:"mcdonalds",zona:"Varias sucursales, CDMX",desc:"Hamburguesas · McNuggets · Desayunos",r:4.1,ped:8500,c:_cadenaColor,tipo:"cadena",horario:"6:00–00:00",tel:"5555000044",plan:"cadena"),
  Negocio(id:"ff05",nom:"Burger King",e:"burgerking",zona:"Varias sucursales, CDMX",desc:"Hamburguesas a la parrilla · Whopper",r:4.1,ped:6200,c:_cadenaColor,tipo:"cadena",horario:"7:00–23:00",tel:"5555000045",plan:"cadena"),
  Negocio(id:"ff06",nom:"KFC",e:"kfc",zona:"Varias sucursales, CDMX",desc:"Pollo frito · Alitas · Kentucky",r:4.2,ped:5100,c:_cadenaColor,tipo:"cadena",horario:"10:00–23:00",tel:"5555000046",plan:"cadena"),
  Negocio(id:"ff07",nom:"Subway",e:"subway",zona:"Varias sucursales, CDMX",desc:"Sándwiches frescos · Ensaladas",r:4.0,ped:3400,c:_cadenaColor,tipo:"cadena",horario:"8:00–22:00",tel:"5555000047",plan:"cadena"),
  Negocio(id:"ff08",nom:"Carl's Jr",e:"carlsjr",zona:"Varias sucursales, CDMX",desc:"Hamburguesas premium · Famous Star",r:4.2,ped:4200,c:_cadenaColor,tipo:"cadena",horario:"7:00–23:00",tel:"5555000048",plan:"cadena"),
  Negocio(id:"ff09",nom:"Little Caesars",e:"littlecaesars",zona:"Varias sucursales, CDMX",desc:"Pizza · Hot-N-Ready · Crazy Bread",r:4.0,ped:5600,c:_cadenaColor,tipo:"cadena",horario:"11:00–23:00",tel:"5555000049",plan:"cadena"),

  // ═══ CADENAS DE TIENDAS ADICIONALES (CADENA AZUL) ═══
  Negocio(id:"cc08",nom:"Soriana",e:"soriana",zona:"Varias sucursales, CDMX",desc:"Supermercado · Abarrotes · Hogar",r:4.2,ped:4800,c:_cadenaColor,tipo:"cadena",horario:"7:00–23:00",tel:"5555000051",plan:"cadena"),
  Negocio(id:"cc09",nom:"Bodega Aurrera",e:"bodega_aurrera",zona:"Varias sucursales, CDMX",desc:"Precios bajos siempre · Abarrotes · Despensa",r:4.1,ped:5200,c:_cadenaColor,tipo:"cadena",horario:"7:00–23:00",tel:"5555000052",plan:"cadena"),
  Negocio(id:"cc10",nom:"La Comer",e:"lacomer",zona:"Varias sucursales, CDMX",desc:"Supermercado · Calidad y frescura",r:4.3,ped:3400,c:_cadenaColor,tipo:"cadena",horario:"7:00–22:00",tel:"5555000053",plan:"cadena"),
  Negocio(id:"cc11",nom:"Mega",e:"mega",zona:"Varias sucursales, CDMX",desc:"Supermercado · Marca Soriana",r:4.1,ped:3200,c:_cadenaColor,tipo:"cadena",horario:"7:00–23:00",tel:"5555000054",plan:"cadena"),

  // ═══ TIENDAS DEPARTAMENTALES (CADENA AZUL) ═══
  Negocio(id:"td01",nom:"Palacio de Hierro",e:"palaciodehierro",zona:"Av. 20 de Noviembre 3, Centro, CDMX",desc:"Tienda departamental de lujo",r:4.5,ped:2800,c:_cadenaColor,tipo:"cadena",horario:"11:00–21:00",tel:"5555000061",plan:"cadena"),
  Negocio(id:"td02",nom:"Sears",e:"sears",zona:"Varias sucursales, CDMX",desc:"Tienda departamental · Ropa · Electrónica · Hogar",r:4.2,ped:3200,c:_cadenaColor,tipo:"cadena",horario:"11:00–21:00",tel:"5555000062",plan:"cadena"),

  // ═══ TIENDAS ESPECIALIZADAS (CADENA AZUL) ═══
  Negocio(id:"te01",nom:"Office Depot",e:"officedepot",zona:"Varias sucursales, CDMX",desc:"Papelería · Oficina · Impresión · Tecnología",r:4.2,ped:2400,c:_cadenaColor,tipo:"cadena",horario:"8:00–21:00",tel:"5555000071",plan:"cadena"),
  Negocio(id:"te02",nom:"O'Reilly Auto Parts",e:"oreilly",zona:"Varias sucursales, CDMX",desc:"Refacciones automotrices · Aceites · Accesorios",r:4.3,ped:1800,c:_cadenaColor,tipo:"cadena",horario:"8:00–21:00",tel:"5555000072",plan:"cadena"),
  Negocio(id:"te03",nom:"Elektra",e:"elektra",zona:"Varias sucursales, CDMX",desc:"Electrónica · Muebles · Motos · Servicios financieros",r:4.1,ped:4200,c:_cadenaColor,tipo:"cadena",horario:"9:00–21:00",tel:"5555000073",plan:"cadena"),
  Negocio(id:"te04",nom:"Coppel",e:"coppel",zona:"Varias sucursales, CDMX",desc:"Ropa · Electrónica · Muebles · Crédito",r:4.1,ped:5100,c:_cadenaColor,tipo:"cadena",horario:"9:00–21:00",tel:"5555000074",plan:"cadena"),
];

// ═══ COORDENADAS REALES DE TODOS LOS NEGOCIOS ═══
const _negCoords = <String, List<double>>{
  // ── Hidalgo (Tulancingo ~20.08, -98.38) ──
  'h01': [20.0756833, -98.3584392], // Farmacias Madrid Panteón - Calz. Hidalgo 1311
  'h01b': [20.0776454, -98.3714904], // Farmacias Madrid Lázaro - Gral. L. Cárdenas 107
  'h01c': [20.0846106, -98.3657675], // Farmacias Madrid 21 de Marzo - 21 de Marzo Nte. 406
  'h01d': [20.0937157, -98.3667885], // Farmacias Madrid Santa María - C. Jazmín 64
  'h01e': [20.0884699, -98.3632441], // Farmacias Madrid Caballito - 21 de Marzo
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
  // ── Cadenas Hidalgo ──
  'ch01': [20.0720, -98.3950], // Walmart Tulancingo - Blvd. Felipe Ángeles
  'ch02': [20.0840, -98.3800], // Bodega Aurrera Tulancingo - Calz. Hidalgo
  'ch03': [20.0680, -98.3700], // Chedraui Tulancingo - Blvd. Nuevo Hidalgo
  'ch04': [20.1148, -98.7510], // Soriana Pachuca - Blvd. Colosio
  'ch05': [20.1160, -98.7490], // Sam's Club Pachuca - Blvd. Colosio
  'ch06': [20.0842, -98.3815], // Farmacias Guadalajara - Calz. Hidalgo
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
  // ── Cadenas CDMX ──
  'cc01': [19.5098, -99.2338], // Costco Satélite
  'cc02': [19.3402, -99.1850], // Walmart Copilco
  'cc03': [19.3920, -99.1580], // Sam's Club Xola
  'cc04': [19.4328, -99.1365], // Liverpool Centro
  'cc05': [19.5350, -99.2100], // Home Depot Perinorte
  'cc06': [19.4820, -99.1780], // Chedraui Azcapotzalco
  'cc07': [19.3890, -99.1670], // AutoZone Insurgentes
  // ── Tepito ──
  'tp01': [19.4435, -99.1357], // Uniformes - Matamoros entre Tenochtitlán y Toltecas
  'tp02': [19.4440, -99.1350], // Tenis y Calzado - Eje 1 Norte esq Matamoros
  'tp03': [19.4430, -99.1340], // Trajes y Vestir - Jesús Carranza
  'tp04': [19.4438, -99.1345], // Zapatos - Aztecas y Matamoros
  'tp05': [19.4442, -99.1360], // Electrónica - Eje 1 Norte
  'tp06': [19.4433, -99.1355], // Ropa - Tenochtitlán
  'tp08': [19.4445, -99.1348], // Accesorios - Peralvillo y Matamoros
  // ── Plazas Chinas ──
  'pz01': [19.4270, -99.1410], // Izazaga 89
  'pz02': [19.4275, -99.1425], // Izazaga 38
  'pz03': [19.4276, -99.1430], // Izazaga 29
  'pz04': [19.4290, -99.1380], // Mesones 129
  // ── Mercados CDMX ──
  'mk01': [19.4280, -99.1270], // La Merced - Anillo de Circunvalación
  'mk02': [19.3720, -99.0960], // Central de Abastos - Eje 6 Sur
  'mk03': [19.4260, -99.1240], // Mercado de Sonora - Fray Servando 419
  'mk04': [19.4140, -99.1210], // Mercado de Jamaica - Av. Morelos
  'mk05': [19.4420, -99.1390], // La Lagunilla - Eje 1 Norte
  // ── Restaurantes ──
  'rx01': [19.4390, -99.1550], // La Casa de Toño
  'rx02': [19.4407, -99.1567], // El Califa de León
  'rx03': [19.3500, -99.1625], // Café El Jarocho
  'rx04': [19.4326, -99.1332], // Los Cocuyos
  'rx05': [19.4182, -99.1642], // Taquería Orinoco
  'rx06': [19.4340, -99.1370], // El Cardenal
  'rx07': [19.4360, -99.1410], // Sanborns
  'rx08': [19.3920, -99.1580], // VIPS
  'rx09': [19.4400, -99.1500], // La Casa de los Tacos
  // ── Fast food ──
  'ff01': [19.4270, -99.1670], // Starbucks
  'ff02': [19.4320, -99.1480], // Domino's
  'ff03': [19.4310, -99.1450], // Pizza Hut
  'ff04': [19.4350, -99.1400], // McDonald's
  'ff05': [19.4280, -99.1520], // Burger King
  'ff06': [19.4330, -99.1440], // KFC
  'ff07': [19.4290, -99.1560], // Subway
  'ff08': [19.4200, -99.1630], // Carl's Jr
  'ff09': [19.4260, -99.1500], // Little Caesars
  // ── Cadenas adicionales ──
  'cc08': [19.4180, -99.1700], // Soriana
  'cc09': [19.4100, -99.1580], // Bodega Aurrera
  'cc10': [19.4250, -99.1750], // La Comer
  'cc11': [19.4150, -99.1650], // Mega
  // ── Departamentales ──
  'td01': [19.4330, -99.1362], // Palacio de Hierro
  'td02': [19.4280, -99.1680], // Sears
  // ── Especializadas ──
  'te01': [19.4220, -99.1590], // Office Depot
  'te02': [19.4160, -99.1720], // O'Reilly
  'te03': [19.4300, -99.1530], // Elektra
  'te04': [19.4340, -99.1460], // Coppel
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
    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      // Check onboarding
      final showOnboarding = await OnboardingScreen.shouldShow();
      if (!mounted) return;
      if (showOnboarding) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => OnboardingScreen(onComplete: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          })));
        return;
      }
      // Check for saved session
      final session = await RoleService.loadSession();
      if (!mounted) return;
      Widget dest;
      if (session != null && session.isNegocio && session.negocioId != null) {
        dest = NegocioPanelScreen(session: session);
      } else if (session != null && session.isSudo) {
        dest = SudoPanelScreen(session: session);
      } else {
        dest = const LoginScreen();
      }
      Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (_, __, ___) => dest,
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF87CEEB), foregroundColor: Colors.black87,
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
            // ═══ ROLE BUTTONS ═══
            Row(children: [
              Expanded(child: SizedBox(height: 46, child: OutlinedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NegocioLoginScreen())),
                icon: const Icon(Icons.store, size: 16, color: Color(0xFFFFA502)),
                label: const Text('Soy Negocio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFFFA502))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFA502), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              ))),
              const SizedBox(width: 10),
              Expanded(child: SizedBox(height: 46, child: OutlinedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SudoLoginScreen())),
                icon: const Icon(Icons.admin_panel_settings, size: 16, color: Color(0xFF7C5CFC)),
                label: const Text('Admin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF7C5CFC))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF7C5CFC), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              ))),
            ]),
            const SizedBox(height: 16),
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
  int _dashService = 0; // 0=Pedidos, 1=Mandados, 2=Paquetería, 3=MiniMudanzas
  int _dashNeg = 0; // negocio seleccionado en dashboard
  int _dashEntrega = 0; // entrega seleccionada en dashboard
  String? _menuScreen; // mama, dulce, farmacia, compras, mandado_*
  String? _comprasTienda; // selected store id for Compras en Tienda
  final _comprasLista = TextEditingController();
  final _comprasTel = TextEditingController();
  final _comprasDir = TextEditingController();
  // ── Mandado controllers ──
  final _mandadoLista = TextEditingController();
  final _mandadoTel = TextEditingController();
  final _mandadoDir = TextEditingController();
  String _mandadoCuando = 'Lo antes posible';
  bool _mandadoEnviando = false;
  // VIP Mandado specific fields
  final _mandadoZona = TextEditingController();
  final _mandadoProducto = TextEditingController();
  final _mandadoPresupuesto = TextEditingController();
  final _mandadoNotas = TextEditingController();
  String? _mandadoFotoPath;
  String _mandadoEnvio = 'Estándar';
  final _mandadoCiudad = TextEditingController();
  final _mandadoPago = TextEditingController();
  // Ticket / Pedido state
  Map<String, dynamic>? _ticketData;
  bool _ticketPagando = false;
  String? _pagoResultado; // 'ok', 'error', 'pendiente'
  // Mandado Cart
  List<Map<String, dynamic>> _mandadoCart = [];
  bool _cartBounce = false;
  String _mcEnvio = 'Estándar';
  final _mcCiudad = TextEditingController();
  final _mcDireccion = TextEditingController();
  final _mcTelefono = TextEditingController();
  String _mcPago = 'Mercado Pago';
  final _sugNomCtrl = TextEditingController();
  final _sugTipoCtrl = TextEditingController();
  final _sugZonaCtrl = TextEditingController();
  final List<CartItem> _cart = [];
  final Set<String> _favs = {'h01','h02','h03'};
  int _addrIdx = 0, _payIdx = 0;
  // Cart checkout state
  String _cartPayMethod = 'mercadopago'; // mercadopago, efectivo, whatsapp
  bool _cartAcceptTerms = false;
  final _cartPagaCon = TextEditingController();
  String _pedFilter = 'all', _negCity = 'hidalgo', _negTipo = 'all';
  String _negSearch = '';

  // ═══ SUDO PREMIUM STATE ═══
  final _sudoNombre = TextEditingController();
  final _sudoDesc = TextEditingController();
  String _sudoGiro = 'restaurant';
  final _sudoDir = TextEditingController();
  final _sudoTel = TextEditingController();
  final _sudoHorario = TextEditingController();
  Color _sudoColor = const Color(0xFF2D7AFF);
  List<Map<String, dynamic>> _sudoProductos = [];
  bool _sudoGuardando = false;
  String? _sudoLogoPath;
  final _sudoProdNombre = TextEditingController();
  final _sudoProdPrecio = TextEditingController();
  final _sudoProdDesc = TextEditingController();
  // SUDO tienda view
  Map<String, dynamic>? _sudoTiendaData;
  List<Map<String, dynamic>> _sudoTiendaItems = [];
  List<Map<String, dynamic>> _sudoTiendaCart = [];

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

  // ═══ FIRESTORE PEDIDOS (usuario) ═══
  List<Map<String, dynamic>> _firestorePedidos = [];
  bool _loadingFsPedidos = false;
  Map<String, dynamic>? _selectedPedido; // para detalle pedido

  // ═══ COTIZADOR ═══
  final _cotOrigen = TextEditingController();
  final _cotDestino = TextEditingController();
  final _cotPeso = TextEditingController();
  String _cotTipo = 'paquete'; // paquete, sobre, mudanza
  Map<String, dynamic>? _cotResultado;

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
    _loadFirestorePedidos(); // Cargar pedidos del usuario
    _checkPagoResultado(); // Verificar si viene de MercadoPago
    _loadMandadoCart(); // Cargar carrito mandado desde local
  }

  void _checkPagoResultado() {
    try {
      final params = Uri.base.queryParameters;
      final pago = params['pago'];
      if (pago != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          String title, msg;
          Color color;
          if (pago == 'ok') {
            title = '✅ ¡Pago recibido!';
            msg = 'Tu pedido está confirmado. Te contactamos por WhatsApp.';
            color = AppTheme.gr;
          } else if (pago == 'pendiente') {
            title = '⏳ Pago en proceso';
            msg = 'Tu pago está en proceso. Te avisamos por WhatsApp cuando se confirme.';
            color = AppTheme.yl;
          } else {
            title = '❌ Pago no completado';
            msg = 'El pago no se completó. Intenta de nuevo o elige otro método.';
            color = AppTheme.rd;
          }
          showDialog(context: context, builder: (_) => AlertDialog(
            backgroundColor: AppTheme.sf,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title, style: const TextStyle(color: AppTheme.tx, fontSize: 18)),
            content: Text(msg, style: const TextStyle(color: AppTheme.tm, fontSize: 13)),
            actions: [TextButton(onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: color, fontWeight: FontWeight.w700)))],
          ));
        });
      }
    } catch (_) {}
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

  // ═══ FIRESTORE PEDIDOS ═══
  Future<void> _loadFirestorePedidos() async {
    final user = AuthService.currentUser;
    if (user == null) return;
    setState(() => _loadingFsPedidos = true);
    try {
      final tel = user.phoneNumber ?? '';
      List<Map<String, dynamic>> data = [];
      if (tel.isNotEmpty) {
        data = await FirestoreService.getPedidosPorTelefono(tel);
      }
      if (!mounted) return;
      setState(() { _firestorePedidos = data; _loadingFsPedidos = false; });
      debugPrint('[CGO] Firestore: ${data.length} pedidos del usuario');
    } catch (e) {
      debugPrint('[CGO] Firestore pedidos error: $e');
      if (!mounted) return;
      setState(() => _loadingFsPedidos = false);
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
      bottom ?? Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: _showGlobalSearch,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.45,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF42A5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(children: [
              Icon(Icons.search, size: 16, color: Colors.white),
              SizedBox(width: 6),
              Expanded(child: Text('Buscar...', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500))),
            ]),
          ),
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

  void _showPricingScreen() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppTheme.sf,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Planes para tu negocio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.tx)),
          const SizedBox(height: 4),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppTheme.rd.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: const Text('OFERTA POR TIEMPO LIMITADO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.rd, letterSpacing: 1))),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('\$1,500', style: TextStyle(fontSize: 13, color: Colors.grey, decoration: TextDecoration.lineThrough, decorationColor: Colors.grey)),
            const SizedBox(width: 4),
            Text('\$1,000', style: TextStyle(fontSize: 13, color: Colors.grey, decoration: TextDecoration.lineThrough, decorationColor: Colors.grey)),
            const SizedBox(width: 8),
            const Text('\$800/mes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.gr)),
          ]),
          const Text('¡Todos los planes al mismo precio!', style: TextStyle(fontSize: 11, color: AppTheme.gr, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          for (var p in [
            {'nom': 'Básico', 'precio': '\$300', 'color': 0xFF2D7AFF, 'items': ['Listado en Cargo-GO', 'Foto y descripción', 'Botón de contacto']},
            {'nom': 'Premium', 'precio': '\$500', 'color': 0xFFFFA502, 'items': ['Todo de Básico', 'Destacado en búsquedas', 'Menú/catálogo digital', 'Ofertas destacadas']},
            {'nom': 'VIP', 'precio': '\$800', 'color': 0xFFFFD700, 'items': ['Todo de Premium', 'Tarjeta VIP exclusiva', 'CREDITIS crédito clientes', 'Ofertas con foto', 'Prioridad #1 en resultados']},
          ]) Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(p['color'] as int), width: 1.5),
              color: Color(p['color'] as int).withOpacity(0.06)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(p['nom'] as String, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(p['color'] as int))),
                const Spacer(),
                Text(p['precio'] as String, style: TextStyle(fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough, decorationColor: Colors.grey)),
                const SizedBox(width: 6),
                const Text('\$800/mes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.gr)),
              ]),
              const SizedBox(height: 6),
              for (var item in (p['items'] as List<String>))
                Padding(padding: const EdgeInsets.only(bottom: 2),
                  child: Row(children: [
                    Icon(Icons.check_circle, size: 12, color: Color(p['color'] as int)),
                    const SizedBox(width: 6),
                    Text(item, style: const TextStyle(fontSize: 11, color: AppTheme.tx)),
                  ])),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, height: 36, child: ElevatedButton(
                onPressed: () { Navigator.pop(context); launchUrl(Uri.parse('https://wa.me/527753200224?text=Hola%20me%20interesa%20el%20plan%20${p['nom']}%20para%20mi%20negocio'), mode: LaunchMode.externalApplication); },
                style: ElevatedButton.styleFrom(backgroundColor: Color(p['color'] as int), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                child: const Text('Contratar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)))),
            ])),
        ])));
  }

  void _enviarSugerencia() async {
    final nom = _sugNomCtrl.text.trim();
    final tipo = _sugTipoCtrl.text.trim();
    final zona = _sugZonaCtrl.text.trim();
    if (nom.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escribe el nombre del negocio'))); return; }
    try {
      await FirestoreService.addDocument('sugerencias', {'nombre': nom, 'tipo': tipo, 'zona': zona, 'fecha': DateTime.now().toIso8601String()});
      _sugNomCtrl.clear(); _sugTipoCtrl.clear(); _sugZonaCtrl.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Gracias! Tu sugerencia fue enviada'), backgroundColor: AppTheme.gr));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.rd));
    }
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [c.withOpacity(0.20), AppTheme.cd, c.withOpacity(0.10)]),
      ),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 36)),
        const SizedBox(height: 4),
        Text('📍 Toca para ver', style: TextStyle(fontSize: 8, color: c.withOpacity(0.7))),
      ])));
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
          // ── Método de pago ──
          const Text('Método de pago', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          const SizedBox(height: 8),
          ...[
            {'key': 'mercadopago', 'icon': Icons.payment, 'label': 'MercadoPago', 'desc': 'Tarjeta, OXXO, SPEI', 'color': const Color(0xFF00B2E8)},
            {'key': 'efectivo', 'icon': Icons.attach_money, 'label': 'Efectivo', 'desc': 'Pago contra entrega', 'color': AppTheme.gr},
            {'key': 'whatsapp', 'icon': Icons.chat, 'label': 'WhatsApp', 'desc': 'Coordinar por WhatsApp', 'color': const Color(0xFF25D366)},
          ].map((m) => GestureDetector(
            onTap: () => setS(() => setState(() => _cartPayMethod = m['key'] as String)),
            child: Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _cartPayMethod == m['key'] ? (m['color'] as Color).withOpacity(0.6) : AppTheme.bd, width: 1.5),
                color: _cartPayMethod == m['key'] ? (m['color'] as Color).withOpacity(0.08) : Colors.transparent),
              child: Row(children: [
                Icon(m['icon'] as IconData, size: 20, color: _cartPayMethod == m['key'] ? m['color'] as Color : AppTheme.tm),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m['label'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _cartPayMethod == m['key'] ? AppTheme.tx : AppTheme.tm)),
                  Text(m['desc'] as String, style: TextStyle(fontSize: 8, color: AppTheme.td)),
                ])),
                if (_cartPayMethod == m['key']) Icon(Icons.check_circle, size: 18, color: m['color'] as Color),
              ])))),
          // ── Efectivo: ¿Con cuánto paga? ──
          if (_cartPayMethod == 'efectivo') ...[
            const SizedBox(height: 6),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.gr.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.gr.withOpacity(0.3))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('¿Con cuánto va a pagar?', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.tx)),
                const SizedBox(height: 6),
                TextField(controller: _cartPagaCon, keyboardType: TextInputType.number, style: const TextStyle(fontSize: 14, color: AppTheme.tx, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(prefixText: '\$ ', prefixStyle: const TextStyle(color: AppTheme.gr, fontWeight: FontWeight.w700),
                    hintText: '${_cartTotal + envios}', hintStyle: TextStyle(color: AppTheme.td),
                    filled: true, fillColor: AppTheme.cd, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppTheme.bd)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  onChanged: (_) => setS(() {})),
                if (_cartPagaCon.text.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Builder(builder: (_) {
                    final pagaCon = double.tryParse(_cartPagaCon.text) ?? 0;
                    final totalFinal = (_cartTotal + envios).toDouble();
                    final cambio = pagaCon - totalFinal;
                    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(cambio >= 0 ? 'Cambio:' : 'Falta:', style: TextStyle(fontSize: 10, color: cambio >= 0 ? AppTheme.gr : AppTheme.rd)),
                      Text('\$${cambio.abs().toStringAsFixed(2)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cambio >= 0 ? AppTheme.gr : AppTheme.rd)),
                    ]);
                  }),
                ],
              ])),
          ],
          const SizedBox(height: 10),
          // ── Terms checkbox ──
          GestureDetector(
            onTap: () => setS(() => setState(() => _cartAcceptTerms = !_cartAcceptTerms)),
            child: Row(children: [
              Container(width: 20, height: 20, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _cartAcceptTerms ? AppTheme.ac : AppTheme.bd, width: 1.5),
                color: _cartAcceptTerms ? AppTheme.ac : Colors.transparent),
                child: _cartAcceptTerms ? const Icon(Icons.check, size: 14, color: Colors.white) : null),
              const SizedBox(width: 8),
              Expanded(child: Wrap(children: [
                const Text('Acepto ', style: TextStyle(fontSize: 9, color: AppTheme.tm)),
                GestureDetector(onTap: () { Navigator.pop(ctx); setState(() => _menuScreen = 'aviso_privacidad'); },
                  child: const Text('Aviso de Privacidad', style: TextStyle(fontSize: 9, color: AppTheme.ac, decoration: TextDecoration.underline))),
                const Text(' y ', style: TextStyle(fontSize: 9, color: AppTheme.tm)),
                GestureDetector(onTap: () { Navigator.pop(ctx); setState(() => _menuScreen = 'terminos'); },
                  child: const Text('Términos y Condiciones', style: TextStyle(fontSize: 9, color: AppTheme.ac, decoration: TextDecoration.underline))),
              ])),
            ])),
          const SizedBox(height: 12),
          // ── Pay button ──
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: !_cartAcceptTerms ? null : () async {
              final totalFinal = (_cartTotal + envios).toDouble();
              if (_cartPayMethod == 'mercadopago') {
                Navigator.pop(ctx);
                final ok = await MercadoPagoService.pagarCarrito(
                  subtotal: _cartTotal.toDouble(), envio: envios.toDouble(), items: _cart.length);
                if (ok) { setState(() => _cart.clear()); _showCheckout(); }
                else { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Error al conectar con MercadoPago', style: TextStyle(color: Colors.white)),
                  backgroundColor: Color(0xFFFF4757))); }
              } else if (_cartPayMethod == 'efectivo') {
                final pagaCon = double.tryParse(_cartPagaCon.text) ?? 0;
                if (pagaCon > 0 && pagaCon < totalFinal) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('El monto debe ser igual o mayor al total', style: TextStyle(color: Colors.white)),
                    backgroundColor: Color(0xFFFF4757)));
                  return;
                }
                Navigator.pop(ctx);
                setState(() => _cart.clear());
                _showCheckout(metodo: 'efectivo', pagaCon: pagaCon > 0 ? pagaCon : null);
              } else if (_cartPayMethod == 'whatsapp') {
                final addr = addrs[_addrIdx];
                final items = _cart.map((c) => '${c.q}x ${c.n} (\$${c.price * c.q})').join('\n');
                final msg = 'Hola! Quiero hacer un pedido:\n\n$items\n\nSubtotal: \$$_cartTotal\nEnvio: \$$envios\nTotal: \$${_cartTotal + envios}\n\nDirecccion: ${addr.a}\n\nGracias!';
                final url = 'https://wa.me/527753200224?text=${Uri.encodeComponent(msg)}';
                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                Navigator.pop(ctx);
                setState(() => _cart.clear());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: !_cartAcceptTerms ? AppTheme.td : _cartPayMethod == 'mercadopago' ? const Color(0xFF00B2E8) : _cartPayMethod == 'efectivo' ? AppTheme.gr : const Color(0xFF25D366),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(_cartPayMethod == 'mercadopago' ? Icons.payment : _cartPayMethod == 'efectivo' ? Icons.attach_money : Icons.chat, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(_cartPayMethod == 'mercadopago' ? 'Pagar con MercadoPago' : _cartPayMethod == 'efectivo' ? 'Confirmar Pedido' : 'Pedir por WhatsApp',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
            ]),
          )),
          const SizedBox(height: 8),
          Center(child: TextButton(onPressed: () { setS(() { setState(() => _cart.clear()); }); Navigator.pop(ctx); }, child: Text('Vaciar carrito', style: TextStyle(color: AppTheme.rd, fontSize: 10)))),
        ],
      ])));
  }

  Widget _row(String l, String r, {Color c = AppTheme.tm}) => Padding(padding: const EdgeInsets.only(bottom: 2),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: TextStyle(fontSize: 10, color: c)), Text(r, style: TextStyle(fontSize: 10, color: c))]));

  void _showCheckout({String metodo = 'mercadopago', double? pagaCon}) async {
    final groups = <String, List<CartItem>>{};
    for (var it in _cart) { groups.putIfAbsent(it.from, () => []).add(it); }
    final envios = groups.keys.length * 35;
    final addr = addrs[_addrIdx];
    final tiempoEst = DeliveryTimeService.calcular(zona: DeliveryTimeService.detectarZona(addr.a));

    // Generar folio y guardar en Firestore
    String folio = '';
    try {
      folio = await FirestoreService.generarNumeroPedido();
      final itemsList = _cart.map((c) => {
        'nombre': c.n,
        'cantidad': c.q,
        'precio': c.price * c.q,
      }).toList();
      await FirestoreService.guardarPedido({
        'numero_pedido': folio,
        'cliente_nombre': addr.l,
        'cliente_telefono': '',
        'cliente_direccion': addr.a,
        'negocio_id': _cart.isNotEmpty ? _cart.first.from : '',
        'negocio_nombre': _cart.isNotEmpty ? _cart.first.from : '',
        'items': itemsList,
        'subtotal': _cartTotal,
        'envio': envios,
        'total': _cartTotal + envios,
        'metodo_pago': metodo,
        'tiempo_estimado_min': tiempoEst.min,
        'tiempo_estimado_max': tiempoEst.max,
        'estado': 'nuevo',
        'estado_historial': [{'estado': 'nuevo', 'timestamp': DateTime.now().toIso8601String(), 'por': 'cliente'}],
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      debugPrint('[CGO] Error guardando pedido: $e');
    }

    // Also send to API when online
    if (_online) {
      await ApiService.crearPedidoFarmacia(
        clienteNombre: addr.l,
        clienteTelefono: '',
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
    }

    if (!mounted) return;

    // Build ticket data
    final ticketData = {
      'numero_pedido': folio,
      'items': _cart.map((c) => {'nombre': c.n, 'cantidad': c.q, 'precio': c.price * c.q}).toList(),
      'subtotal': _cartTotal,
      'envio': envios,
      'total': _cartTotal + envios,
      'metodo_pago': metodo,
      'tiempo_estimado_min': tiempoEst.min,
      'tiempo_estimado_max': tiempoEst.max,
      'negocio_nombre': _cart.isNotEmpty ? _cart.first.from : '',
      'cliente_nombre': addr.l,
    };

    // Navigate to ticket screen
    Navigator.push(context, MaterialPageRoute(builder: (_) => TicketScreen(pedido: ticketData)));
    setState(() { _cart.clear(); _tab = 0; });
    _loadApiData();
  }

  @override
  Widget build(BuildContext context) {
    // Full screen map view
    if (_showFullMap) return _fullMapScreen();
    return Scaffold(
      body: SafeArea(child: Stack(children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _menuScreen != null ? _buildMenuScreen() : _buildScreen(),
        ),
        // ── FLOATING WHATSAPP HELP BUTTON ──
        if (_menuScreen == null)
          Positioned(bottom: 170, right: 16, child: GestureDetector(
            onTap: () {
              final url = 'https://wa.me/527753200224?text=${Uri.encodeComponent('Hola, necesito ayuda con Cargo-GO')}';
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
            child: Container(width: 48, height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF25D366),
                boxShadow: [BoxShadow(color: const Color(0xFF25D366).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
              child: const Icon(Icons.chat, size: 22, color: Colors.white)))),
        // ── FLOATING MANDADO CART BUTTON ──
        if (_menuScreen == null || (_menuScreen!.startsWith('mandado_') && _menuScreen != 'mandado_cart') || _menuScreen == 'ticket')
          Positioned(bottom: 100, right: 16, child: GestureDetector(
            onTap: () => setState(() => _menuScreen = 'mandado_cart'),
            child: AnimatedScale(scale: _cartBounce ? 1.2 : 1.0, duration: const Duration(milliseconds: 200),
              curve: Curves.elasticOut,
              child: Container(width: 65, height: 65,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFE3F2FD),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 4))]),
                child: Stack(clipBehavior: Clip.none, children: [
                  const Center(child: Icon(Icons.shopping_cart_rounded, size: 30, color: Color(0xFF0D47A1))),
                  // Badge
                  Positioned(top: -2, right: -2, child: Container(
                    width: 22, height: 22,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF4757)),
                    child: Center(child: Text('${_mandadoCart.length}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white))))),
                ]))))),
      ])),
      bottomNavigationBar: _menuScreen != null ? null : _buildNav(),
      floatingActionButton: _cartQty > 0 ? FloatingActionButton.extended(
        onPressed: _openCart, backgroundColor: const Color(0xFFE3F2FD),
        heroTag: 'mainCart',
        icon: const Icon(Icons.shopping_cart, color: Color(0xFF0D47A1), size: 18),
        label: Text('$_cartQty · \$$_cartTotal', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D47A1))),
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
              gradient: const LinearGradient(colors: [Color(0xFFFFD600), Color(0xFFFFA000)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: Border.all(color: AppTheme.cd, width: 4),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFFD600).withOpacity(0.5), blurRadius: 16, spreadRadius: 2, offset: const Offset(0, 4)),
                BoxShadow(color: const Color(0xFFFFA000).withOpacity(0.3), blurRadius: 24, spreadRadius: -2),
              ],
            ),
            child: const Icon(Icons.bolt_rounded, size: 30, color: Color(0xFF1A1A1A)),
          )),
          Transform.translate(offset: const Offset(0, -14), child: Text('Pedidos', style: TextStyle(fontSize: 9, color: _tab == 2 ? AppTheme.yl : AppTheme.td, fontWeight: _tab == 2 ? FontWeight.w700 : FontWeight.w400))),
        ]),
      )),
      _navBtn(3, Icons.local_shipping_rounded, 'Mudanzas'),
      _navBtn(4, Icons.person_outline_rounded, 'Perfil'),
    ]),
  );

  Widget _navBtn(int i, IconData ic, String l) {
    final bool active = _tab == i;
    return Expanded(child: InkWell(
      onTap: () { setState(() => _tab = i); if (i == 3 && _markerData.isEmpty) _updateMapMarkers(); },
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
    else if (_menuScreen == 'farmacia') {
      launchUrl(Uri.parse('https://farmacias-madrid.web.app'), mode: LaunchMode.externalApplication);
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) setState(() => _menuScreen = null); });
      return const SizedBox();
    }
    else if (_menuScreen != null && _menuScreen!.startsWith('vip_')) {
      final vipId = _menuScreen!.substring(4);
      // Farmacias Madrid VIP cards redirect to external app
      if (vipId.startsWith('h01')) {
        launchUrl(Uri.parse('https://farmacias-madrid.web.app'), mode: LaunchMode.externalApplication);
        WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) setState(() => _menuScreen = null); });
        return const SizedBox();
      }
      return _vipScreen(vipId);
    }
    else if (_menuScreen == 'aviso_privacidad') { return _avisoPrivacidadScreen(); }
    else if (_menuScreen == 'terminos') { return _terminosScreen(); }
    else if (_menuScreen == 'repartidor') { return _repartidorScreen(); }
    else if (_menuScreen == 'mandado_cart') { return _mandadoCartScreen(); }
    else if (_menuScreen != null && _menuScreen!.startsWith('mandado_')) { return _mandadoScreen(_menuScreen!.substring(8)); }
    else if (_menuScreen == 'ticket') { return _ticketScreen(); }
    else if (_menuScreen == 'notificaciones') { return _notificacionesScreen(); }
    else if (_menuScreen == 'detalle_pedido') { return _detallePedidoScreen(); }
    else if (_menuScreen == 'cotizador') { return _cotizadorScreen(); }
    else if (_menuScreen == 'mis_pedidos') { return _misPedidosScreen(); }
    else if (_menuScreen == 'sudo') { return _sudoLandingScreen(); }
    else if (_menuScreen == 'sudo_registro') { return _sudoRegistroScreen(); }
    else if (_menuScreen != null && _menuScreen!.startsWith('sudo_tienda_')) { return _sudoTiendaScreen(_menuScreen!.substring(12)); }
    else {
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) setState(() { _menuScreen = null; _tab = 0; }); });
      return const SizedBox();
    }
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
    final fsNegCount = _firestoreNegocios.isNotEmpty ? _firestoreNegocios.length : allNegs.length;
    final fsPedCount = _firestorePedidos.isNotEmpty ? _firestorePedidos.length : (_apiEntregas.isNotEmpty ? _apiEntregas.length : 47);
    final sEntregas = hasApiStats ? '${_apiStats['envios_hoy'] ?? _apiEntregas.length}' : '$fsPedCount';
    final sIngresos = hasApiStats ? '\$${((_apiStats['ingresos_hoy'] ?? 0) / 1000).toStringAsFixed(1)}k' : '\$98.2k';
    final sProductos = hasApiStats ? '${_apiFarmProductos.isNotEmpty ? _apiFarmProductos.length : 77000}+' : '77K+';
    final sNegocios = hasApiStats ? '${_apiNegocios.isNotEmpty ? _apiNegocios.length : fsNegCount}' : '$fsNegCount';
    final sMandados = hasApiStats ? '${_apiPedidosStats['mandados'] ?? _apiPedidos.length}' : '${_firestorePedidos.length}';
    final sPaquetes = hasApiStats ? '${_apiStats['paquetes_hoy'] ?? 156}' : '156';
    final sMudanzas = hasApiStats ? '${_apiStats['mudanzas_hoy'] ?? 8}' : '8';

    // Entregas recientes: API real si hay, sino mock
    final bool useApiEntregas = _apiEntregas.isNotEmpty;

    return RefreshIndicator(onRefresh: _loadApiData, color: AppTheme.ac,
      child: ListView(padding: const EdgeInsets.all(14), children: [
      _topBar(),
      // ── SEARCH BAR ──
      GestureDetector(
        onTap: () => setState(() { _tab = 1; _negSearch = ''; }),
        child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.bd)),
          child: Row(children: [
            Icon(Icons.search, size: 20, color: AppTheme.or),
            const SizedBox(width: 10),
            Text('🔍 ¿Qué se te antoja?', style: TextStyle(fontSize: 13, color: AppTheme.td)),
          ]))),
      // ── PROMO BANNER ──
      Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Color(0xFF00C853), Color(0xFF00E676)])),
        child: Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('🎉 Tu primer envío GRATIS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            SizedBox(height: 2),
            Text('Código: BIENVENIDO', style: TextStyle(fontSize: 10, color: Colors.white70)),
          ])),
          GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CuponesScreen())),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: const Text('Ver promos', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)))),
        ])),
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
        _dashCard('📦', 'Pedidos\nCDMX - Hidalgo', sEntregas, Icons.arrow_outward, null, tabIdx: 2, svcIdx: 0),
        const SizedBox(width: 10),
        _dashCard('🛒', 'Mandados\nLocal', sMandados, Icons.arrow_outward, 'compras', svcIdx: 1),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        _dashCard('📮', 'Paquetería', sPaquetes, Icons.arrow_outward, null, tabIdx: 2, svcIdx: 2),
        const SizedBox(width: 10),
        _dashCard('🚚', 'Mini\nMudanzas', sMudanzas, Icons.arrow_outward, null, tabIdx: 3, svcIdx: 3),
      ]),
      const SizedBox(height: 16),
      // ── Stats entregas ──
      const Text('Resumen de Entregas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.tx)),
      const SizedBox(height: 8),
      Row(children: [
        _statCardGreen('Entregas Hoy', sEntregas, Icons.local_shipping, const Color(0xFF2D7AFF)),
        const SizedBox(width: 8),
        _statCardGreen('Ingresos', sIngresos, Icons.trending_up, const Color(0xFF00D68F)),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        _statCardGreen('Productos', sProductos, Icons.medication, const Color(0xFFFFA502)),
        const SizedBox(width: 8),
        _statCardGreen('Negocios', sNegocios, Icons.store, const Color(0xFFFFD700)),
      ]),
      const SizedBox(height: 16),
      // ── Nuestros Negocios ──
      Row(children: [
        const Icon(Icons.store, size: 20, color: Color(0xFFFFD700)),
        const SizedBox(width: 8),
        const Text('Nuestros Negocios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFFFD700), letterSpacing: 0.5)),
        const Spacer(),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFFFD700).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Text('${5 + _apiNegocios.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFFFD700)))),
      ]),
      const SizedBox(height: 10),
      // Grid 2 por fila
      Row(children: [
        Expanded(child: _appCard('Farmacias\nMadrid', '💊', const Color(0xFF42A5F5), const Color(0xFF0D47A1), 'farmacia', logo: 'assets/images/farmacia_madrid_logo.png')),
        const SizedBox(width: 10),
        Expanded(child: _appCard('CRUDO\nGhost Kitchen', '🍽️', const Color(0xFFD4AF37), const Color(0xFF1A1000), 'crudo')),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _appCard('Autopartes\nPilingas', '🔧', const Color(0xFFE53935), const Color(0xFF1A0000), 'pilingas')),
        const SizedBox(width: 10),
        Expanded(child: _appCard('Perfumes\nSharazan', '✨', const Color(0xFFE040FB), const Color(0xFF0D0020), 'sharazan')),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _appCard('Regalos\nSorpresa', '🎁', const Color(0xFFFF7043), const Color(0xFF1A0800), 'dulce')),
        const SizedBox(width: 10),
        Expanded(child: _appCard('SUDO\nPremium', '🚀', const Color(0xFF00E676), const Color(0xFF002200), 'sudo')),
      ]),
      // ── FRANCHISE PROMO ──
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FranquiciasScreen())),
        child: Container(margin: const EdgeInsets.only(top: 6), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF1A0A3E), Color(0xFF0D0620)]),
            border: Border.all(color: AppTheme.or.withOpacity(0.4), width: 1.5)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('🚀', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              const Expanded(child: Text('LLEVA CARGO-GO A TU CIUDAD', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5))),
            ]),
            const SizedBox(height: 8),
            Text('Sé dueño de tu propia app de envíos.\nSin local, sin inventario.',
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7), height: 1.4)),
            const SizedBox(height: 10),
            Wrap(spacing: 12, runSpacing: 4, children: [
              Text('💰 Desde \$50,000', style: TextStyle(fontSize: 10, color: AppTheme.or)),
              Text('📱 App lista', style: TextStyle(fontSize: 10, color: AppTheme.or)),
              Text('📊 Panel propio', style: TextStyle(fontSize: 10, color: AppTheme.or)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Text('Ya operamos en Tulancingo 🟢', style: TextStyle(fontSize: 9, color: AppTheme.gr)),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA502)])),
                child: const Text('VER MÁS 🔥', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black))),
            ]),
          ]))),
      const SizedBox(height: 10),
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
        Text('Entregas Recientes${useApiEntregas ? ' (API)' : ''}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
        TextButton(onPressed: () => setState(() => _tab = 2), child: const Text('Ver todos', style: TextStyle(fontSize: 10, color: AppTheme.ac))),
      ]),
      if (useApiEntregas)
        ..._apiEntregas.take(5).toList().asMap().entries.map((e) {
          return _dashApiEntregaCard(e.key, e.value);
        })
      else
        ...pedidos.where((p) => p.est != 'ok').take(4).toList().asMap().entries.map((e) {
          return _dashPedCard(e.key, e.value);
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

  Widget _dashCard(String emoji, String label, String value, IconData arrow, String? menuKey, {int? tabIdx, required int svcIdx}) {
    final bool active = _dashService == svcIdx;
    return Expanded(child: GestureDetector(
      onTap: () {
        setState(() => _dashService = svcIdx);
        if (tabIdx != null) { setState(() => _tab = tabIdx); } else if (menuKey != null) setState(() => _menuScreen = menuKey);
      },
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: active ? null : AppTheme.cd,
          border: active ? null : Border.all(color: AppTheme.bd),
          gradient: active ? const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            Container(width: 30, height: 30, decoration: BoxDecoration(
              color: active ? Colors.white.withOpacity(0.2) : AppTheme.sf, borderRadius: BorderRadius.circular(8)),
              child: Icon(arrow, size: 16, color: active ? Colors.white : AppTheme.tm)),
          ]),
          const Spacer(),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? Colors.white70 : AppTheme.tm)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: active ? Colors.white : AppTheme.tx)),
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

  // ═══ APP CARD (mini con logo y color de marca) ═══
  Widget _appCard(String title, String emoji, Color accent, Color bgColor, String menuKey, {String? logo}) {
    return GestureDetector(
      onTap: () {
        if (menuKey == 'crudo') { launchUrl(Uri.parse('crudo.html'), mode: LaunchMode.externalApplication); return; }
        if (menuKey == 'pilingas') { launchUrl(Uri.parse('pilingas.html'), mode: LaunchMode.externalApplication); return; }
        if (menuKey == 'sharazan') { launchUrl(Uri.parse('sharazan.html'), mode: LaunchMode.externalApplication); return; }
        if (menuKey == 'farmacia') { launchUrl(Uri.parse('https://farmacias-madrid.web.app'), mode: LaunchMode.externalApplication); return; }
        if (menuKey == 'sudo') { setState(() => _menuScreen = 'sudo'); return; }
        setState(() => _menuScreen = menuKey);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [bgColor, accent.withOpacity(0.12)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withOpacity(0.4), width: 1.3),
          boxShadow: [BoxShadow(color: accent.withOpacity(0.15), blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: Stack(children: [
          Positioned(right: -15, top: -15, child: Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withOpacity(0.06)))),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              if (logo != null)
                ClipRRect(borderRadius: BorderRadius.circular(12),
                  child: Image.asset(logo, width: 40, height: 40, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 40, height: 40, decoration: BoxDecoration(color: accent.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: accent.withOpacity(0.3))), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))))))
              else
                Container(width: 40, height: 40, decoration: BoxDecoration(color: accent.withOpacity(0.18), borderRadius: BorderRadius.circular(12), border: Border.all(color: accent.withOpacity(0.25), width: 1)),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22)))),
              Container(width: 24, height: 24, decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.arrow_forward_ios, size: 11, color: accent.withOpacity(0.6))),
            ]),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: accent, height: 1.3)),
          ]),
        ]),
      ),
    );
  }

  // ═══ TARJETA VIP CRUDO ═══
  Widget _crudoVipCard() {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse('crudo.html'), mode: LaunchMode.externalApplication),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4), width: 1),
        ),
        child: Stack(children: [
          Positioned(right: -20, top: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFD4AF37).withOpacity(0.06)))),
          Positioned(left: -10, bottom: -10, child: Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFD4AF37).withOpacity(0.04)))),
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 36, height: 26, decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFB8860B)]),
              )),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('GHOST KITCHEN', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFFD4AF37), letterSpacing: 2)),
                Container(height: 1, width: 50, color: const Color(0xFFD4AF37).withOpacity(0.3)),
              ]),
            ]),
            const SizedBox(height: 12),
            Text('....  ....  ....  ....', style: TextStyle(fontSize: 16, color: const Color(0xFFD4AF37).withOpacity(0.3), letterSpacing: 3, fontFamily: 'monospace')),
            const SizedBox(height: 12),
            const Text('CRUDO VIP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFD4AF37), letterSpacing: 2)),
            const Text('Chef IA · Comida Mexicana Premium', style: TextStyle(fontSize: 10, color: Color(0xFF888888))),
            const Spacer(),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Pedidos con IA · Delivery Cargo-GO', style: TextStyle(fontSize: 9, color: const Color(0xFFD4AF37).withOpacity(0.7))),
                Text('Tulancingo, Hidalgo', style: TextStyle(fontSize: 9, color: const Color(0xFFD4AF37).withOpacity(0.7))),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.15), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 0.5)),
                child: const Text('PEDIR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFD4AF37)))),
            ]),
          ])),
        ]),
      ),
    );
  }

  // ═══ TARJETA VIP PILINGAS ═══
  Widget _pilingasVipCard() {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse('pilingas.html'), mode: LaunchMode.externalApplication),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Color(0xFF1A0000), Color(0xFF2D0A0A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: const Color(0xFFE53935).withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
          border: Border.all(color: const Color(0xFFE53935).withOpacity(0.4), width: 1),
        ),
        child: Stack(children: [
          Positioned(right: -20, top: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFE53935).withOpacity(0.06)))),
          Positioned(left: 40, bottom: 50, child: Container(width: 30, height: 0.5, color: const Color(0xFFE53935).withOpacity(0.15))),
          Positioned(right: 50, top: 25, child: Container(width: 25, height: 0.5, color: const Color(0xFFE53935).withOpacity(0.1))),
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 36, height: 26, decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFB71C1C)]),
              )),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('CARGO-GO VIP', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFFE53935), letterSpacing: 2)),
                Container(height: 1, width: 50, color: const Color(0xFFE53935).withOpacity(0.3)),
              ]),
            ]),
            const SizedBox(height: 12),
            Text('....  ....  ....  ....', style: TextStyle(fontSize: 16, color: const Color(0xFFE53935).withOpacity(0.3), letterSpacing: 3, fontFamily: 'monospace')),
            const SizedBox(height: 12),
            const Text('AUTOPARTES PILINGAS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFE53935), letterSpacing: 1)),
            const Text('Refacciones · Central 47 · 24hrs', style: TextStyle(fontSize: 10, color: Color(0xFF888888))),
            const Spacer(),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Envio GRATIS · Todas las marcas', style: TextStyle(fontSize: 9, color: const Color(0xFFE53935).withOpacity(0.7))),
                Text('Tel: 775 195 7788', style: TextStyle(fontSize: 9, color: const Color(0xFFE53935).withOpacity(0.7))),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE53935).withOpacity(0.15), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3), width: 0.5)),
                child: const Text('VER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFE53935)))),
            ]),
          ])),
        ]),
      ),
    );
  }

  // ═══ TARJETA VIP SHARAZAN ═══
  Widget _sharazanVipCard() {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse('sharazan.html'), mode: LaunchMode.externalApplication),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [Color(0xFF0D0020), Color(0xFF1A0040)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: const Color(0xFF9C27B0).withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
          border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.4), width: 1),
        ),
        child: Stack(children: [
          Positioned(right: -20, top: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF9C27B0).withOpacity(0.06)))),
          Positioned(left: -10, bottom: -10, child: Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFE040FB).withOpacity(0.04)))),
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 36, height: 26, decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFE040FB)]),
              )),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('FRAGANCIAS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFFE040FB), letterSpacing: 2)),
                Container(height: 1, width: 50, color: const Color(0xFFE040FB).withOpacity(0.3)),
              ]),
            ]),
            const SizedBox(height: 12),
            Text('....  ....  ....  ....', style: TextStyle(fontSize: 16, color: const Color(0xFFE040FB).withOpacity(0.3), letterSpacing: 3, fontFamily: 'monospace')),
            const SizedBox(height: 12),
            const Text('PERFUMES SHARAZAN', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFFE040FB), letterSpacing: 1)),
            const Text('IA Personal Shopper · Fragancias Premium', style: TextStyle(fontSize: 10, color: Color(0xFF888888))),
            const Spacer(),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Encuentra tu fragancia ideal con IA', style: TextStyle(fontSize: 9, color: const Color(0xFFE040FB).withOpacity(0.7))),
                Text('Hombre y Mujer · Delivery Cargo-GO', style: TextStyle(fontSize: 9, color: const Color(0xFFE040FB).withOpacity(0.7))),
              ])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE040FB).withOpacity(0.15), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE040FB).withOpacity(0.3), width: 0.5)),
                child: const Text('EXPLORAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFE040FB)))),
            ]),
          ])),
        ]),
      ),
    );
  }

  // ═══ DASH NEGOCIO CARD (con selección azul) ═══
  Widget _dashNegCard(int idx, String emoji, String title, String sub, String rating, String menuKey, {String? logo}) {
    final bool active = _dashNeg == idx;
    return GestureDetector(
      onTap: () {
        if (menuKey == 'crudo') {
          launchUrl(Uri.parse('crudo.html'), mode: LaunchMode.externalApplication);
          return;
        }
        if (menuKey == 'pilingas') {
          launchUrl(Uri.parse('pilingas.html'), mode: LaunchMode.externalApplication);
          return;
        }
        if (menuKey == 'sharazan') {
          launchUrl(Uri.parse('sharazan.html'), mode: LaunchMode.externalApplication);
          return;
        }
        if (menuKey == 'farmacia') {
          launchUrl(Uri.parse('https://farmacias-madrid.web.app'), mode: LaunchMode.externalApplication);
          return;
        }
        setState(() => _dashNeg = idx); setState(() => _menuScreen = menuKey);
      },
      child: Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: active ? null : Colors.transparent,
          gradient: active ? const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)]) : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? const Color(0xFF1565C0) : const Color(0xFFFFD700), width: 1.5),
          boxShadow: active ? [BoxShadow(color: const Color(0xFF1565C0).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          if (logo != null)
            ClipRRect(borderRadius: BorderRadius.circular(14),
              child: Image.asset(logo, width: 56, height: 56, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 56, height: 56, decoration: BoxDecoration(color: active ? Colors.white.withOpacity(0.2) : AppTheme.cd, borderRadius: BorderRadius.circular(14)), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))))))
          else
            Container(width: 56, height: 56, decoration: BoxDecoration(color: active ? Colors.white.withOpacity(0.2) : const Color(0xFFFFD700).withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2), width: 1)),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28)))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: active ? Colors.white : AppTheme.tx)),
            const SizedBox(height: 3),
            Text(sub, style: TextStyle(fontSize: 11, color: active ? Colors.white70 : AppTheme.tm)),
          ])),
          Column(children: [
            Text(rating, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? Colors.white70 : AppTheme.or)),
            const SizedBox(height: 4),
            Icon(Icons.arrow_forward_ios, size: 14, color: active ? Colors.white70 : const Color(0xFFFFD700).withOpacity(0.5)),
          ]),
        ]),
      ),
    );
  }

  // ═══ DASH PEDIDO CARD (compacto) ═══
  Widget _dashPedCard(int idx, Pedido p) {
    final bool active = _dashEntrega == idx;
    final ec = {'ruta': AppTheme.ac, 'prep': AppTheme.or, 'ok': AppTheme.gr};
    final el = {'ruta': 'En Ruta', 'prep': 'Preparando', 'ok': 'Entregado'};
    final ei = {'ruta': Icons.local_shipping, 'prep': Icons.access_time, 'ok': Icons.check_circle};
    final c = ec[p.est]!;
    return GestureDetector(
      onTap: () => setState(() => _dashEntrega = idx),
      child: Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? null : Colors.transparent,
          gradient: active ? const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)]) : null,
          borderRadius: BorderRadius.circular(14),
          border: active ? null : Border.all(color: c.withOpacity(0.2), width: 1),
        ),
        child: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: active ? Colors.white.withOpacity(0.2) : c.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
            child: Icon(ei[p.est], size: 16, color: active ? Colors.white : c)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(p.id, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: active ? Colors.white : Colors.white)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: active ? Colors.white.withOpacity(0.2) : c.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(el[p.est]!, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: active ? Colors.white : c))),
            ]),
            const SizedBox(height: 2),
            Text('${p.orig} → ${p.dest}', style: TextStyle(fontSize: 9, color: active ? Colors.white70 : Colors.white70)),
            if (p.prog > 0 && p.prog < 100) ...[
              const SizedBox(height: 3),
              ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: p.prog / 100, backgroundColor: active ? Colors.white.withOpacity(0.15) : c.withOpacity(0.08), color: active ? Colors.white : c, minHeight: 2)),
            ],
            const SizedBox(height: 2),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${p.cl} · ${p.h}', style: TextStyle(fontSize: 8, color: active ? Colors.white54 : Colors.white54)),
              Text('\$${p.m}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: active ? Colors.white : AppTheme.gr, fontFamily: 'monospace')),
            ]),
          ])),
        ])),
    );
  }

  // ═══ DASH API ENTREGA CARD (con selección azul) ═══
  Widget _dashApiEntregaCard(int idx, Map<String, dynamic> e) {
    final bool active = _dashEntrega == idx;
    final estado = (e['estado'] ?? 'pendiente').toString();
    final ec = {'en_transito': AppTheme.ac, 'pendiente': AppTheme.or, 'completada': AppTheme.gr, 'cancelada': AppTheme.rd};
    final el = {'en_transito': 'En Ruta', 'pendiente': 'Pendiente', 'completada': 'Entregado', 'cancelada': 'Cancelado'};
    final ei = {'en_transito': Icons.local_shipping, 'pendiente': Icons.access_time, 'completada': Icons.check_circle, 'cancelada': Icons.cancel};
    final c = ec[estado] ?? AppTheme.tm;
    final ic = ei[estado] ?? Icons.help;
    final lb = el[estado] ?? estado;
    return GestureDetector(
      onTap: () => setState(() => _dashEntrega = idx),
      child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? null : Colors.transparent,
          gradient: active ? const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)]) : null,
          borderRadius: BorderRadius.circular(20),
          border: active ? null : Border.all(color: c.withOpacity(0.25), width: 1.2),
        ),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: active ? Colors.white.withOpacity(0.2) : c.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(ic, size: 20, color: active ? Colors.white : c)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(e['folio'] ?? '#${e['id']}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : AppTheme.tx)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: active ? Colors.white.withOpacity(0.2) : c.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(lb, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: active ? Colors.white : c))),
            ]),
            const SizedBox(height: 4),
            Text('${e['origen'] ?? '?'} → ${e['destino'] ?? '?'}', style: TextStyle(fontSize: 10, color: active ? Colors.white70 : AppTheme.tm)),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${e['cliente'] ?? ''} · ${e['fecha_creacion'] ?? ''}', style: TextStyle(fontSize: 9, color: active ? Colors.white54 : AppTheme.td)),
              Text('\$${e['precio'] ?? 0}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: active ? Colors.white : AppTheme.gr, fontFamily: 'monospace')),
            ]),
          ])),
        ])),
    );
  }

  Widget _statCardGreen(String label, String value, IconData ic, [Color c = const Color(0xFF2D7AFF)]) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: c, width: 1.5),
      color: c.withOpacity(0.06),
    ),
    child: Row(children: [
      Icon(ic, size: 22, color: c),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: c, fontFamily: 'monospace')),
        Text(label, style: TextStyle(fontSize: 9, color: c)),
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
    final fsIds = useFirestore ? _firestoreNegocios.map((n) => n['id'].toString()).toSet() : <String>{};
    final filtered = all.where((n) {
      if (fsIds.contains(n.id)) return false;
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

    return RefreshIndicator(onRefresh: () async { await _loadApiData(); await _loadFirestoreNegocios(); }, color: AppTheme.ac,
      child: ListView(padding: const EdgeInsets.all(14), children: [
      _topBar(bottom: const SizedBox.shrink()),
      // City filter - outlined rounded
      Row(children: [
        _cityBtn('all', '🔥 TODOS'),
        _cityBtn('hidalgo', '📍 HIDALGO'),
        _cityBtn('cdmx', '🏙️ CDMX'),
      ]),
      const SizedBox(height: 10),
      // Search bar full width
      SizedBox(height: 40, child: TextField(onChanged: (v) => setState(() => _negSearch = v), style: const TextStyle(color: Color(0xFF00B4FF), fontSize: 11),
        decoration: InputDecoration(hintText: 'Buscar negocio, comida, servicio...', hintStyle: const TextStyle(color: Color(0xFF00B4FF), fontSize: 11),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFFFD600), size: 16),
          filled: false, enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF00B4FF), width: 1)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF00B4FF), width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(vertical: 8)))),
      const SizedBox(height: 10),
      // Mini VIP card + Promo
      SizedBox(height: 90, child: Row(children: [
        // Mini VIP featured
        Expanded(child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)]),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(children: [
              Container(width: 24, height: 17, decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFB8860B)]))),
              const Spacer(),
              Text('VIP', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: const Color(0xFFD4AF37).withOpacity(0.7), letterSpacing: 2)),
            ]),
            const Spacer(),
            const Text('NEGOCIOS VIP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFD4AF37), letterSpacing: 1)),
            Text('3 negocios premium', style: TextStyle(fontSize: 9, color: const Color(0xFFD4AF37).withOpacity(0.5))),
          ]),
        )),
        const SizedBox(width: 10),
        // Promo emprender
        Expanded(child: GestureDetector(
          onTap: () => _showPricingScreen(),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(colors: [Color(0xFF0D2137), Color(0xFF0A1929)]),
              border: Border.all(color: AppTheme.ac.withOpacity(0.3), width: 1),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🚀', style: TextStyle(fontSize: 18)),
              const Spacer(),
              const Text('¿Quieres emprender?', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 2),
              Text('Crea tu negocio virtual\nSin local fisico necesario', style: TextStyle(fontSize: 8, color: AppTheme.ac.withOpacity(0.7), height: 1.3)),
            ]),
          ),
        )),
      ])),
      const SizedBox(height: 8),
      // Type filter
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
        Text('${fsFiltered.length + filtered.length + apiFiltered.length} resultados', style: const TextStyle(fontSize: 10, color: AppTheme.td)),
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
                  Container(width: 56, height: 56, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF87CEEB), Color(0xFF67D8EF)]), borderRadius: BorderRadius.circular(14)),
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
          final cols = w > 600 ? 3 : 2;
          final cards = fsFiltered.where((n) => n['id'] != 'c81').toList();
          // Sort: VIP first, then vip_mandado, cadena, premium, basico, gratis
          const planOrder = {'vip': 0, 'vip_mandado': 1, 'cadena': 2, 'premium': 3, 'basico': 4, 'gratis': 5};
          cards.sort((a, b) => (planOrder[a['plan'] ?? 'gratis'] ?? 5).compareTo(planOrder[b['plan'] ?? 'gratis'] ?? 5));
          return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.55),
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
              final logoUrl = (n['logo_url'] ?? '').toString();
              final hasLogo = logoUrl.isNotEmpty;
              // Plan-based card styling — vivo y distinguible
              final Color borderColor; final double borderWidth; final String? badge;
              final List<BoxShadow> cardShadows; final Color cardBg;
              switch (plan) {
                case 'vip':
                  borderColor = const Color(0xFFFFD700); borderWidth = 2.5; badge = 'VIP';
                  cardBg = const Color(0xFF1A1400);
                  cardShadows = [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.35), blurRadius: 16, spreadRadius: 2)];
                case 'premium':
                  borderColor = const Color(0xFFE53935); borderWidth = 2.0; badge = 'PREMIUM';
                  cardBg = const Color(0xFF1A0000);
                  cardShadows = [BoxShadow(color: const Color(0xFFE53935).withOpacity(0.3), blurRadius: 12, spreadRadius: 1)];
                case 'basico':
                  borderColor = const Color(0xFF42A5F5); borderWidth = 1.5; badge = 'BASICO';
                  cardBg = const Color(0xFF0A1A2E);
                  cardShadows = [BoxShadow(color: const Color(0xFF42A5F5).withOpacity(0.25), blurRadius: 10)];
                default:
                  borderColor = c.withOpacity(0.5); borderWidth = 1.2; badge = null;
                  cardBg = const Color(0xFF0A1220);
                  cardShadows = [BoxShadow(color: c.withOpacity(0.15), blurRadius: 8)];
              }
              final previewItems = (plan == 'vip' && n['productos_preview'] is List) ? (n['productos_preview'] as List).take(3).toList() : [];
              // ── VIP CARD: tarjeta compacta en grid ──
              if (plan == 'vip') return GestureDetector(
                onTap: () => setState(() => _menuScreen = 'vip_${n['id']}'),
                child: Container(decoration: BoxDecoration(
                  color: const Color(0xFF1A1400), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.3), blurRadius: 12, spreadRadius: 1)]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    // 1. LOGO 40x40 + VIP badge
                    ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(19), topRight: Radius.circular(19)),
                      child: Container(height: 100, decoration: const BoxDecoration(gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFFB8860B), Color(0xFFDAA520), Color(0xFFFFD700)])),
                        child: Stack(children: [
                          Positioned(top: 3, left: 3, child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)]),
                              borderRadius: BorderRadius.circular(5)),
                            child: const Text('👑 VIP', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Color(0xFF1A1400))))),
                          Center(child: Container(padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF87CEEB), Color(0xFF67D8EF)]), borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)]),
                            child: ClipRRect(borderRadius: BorderRadius.circular(10),
                              child: hasLogo
                                ? Image.network(logoUrl, width: 60, height: 60, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Image.asset('assets/images/farmacia_madrid_logo.png', width: 60, height: 60, fit: BoxFit.cover))
                                : Image.asset('assets/images/farmacia_madrid_logo.png', width: 60, height: 60, fit: BoxFit.cover)))),
                        ]))),
                    // 2. CREDITIS una línea
                    Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0D2137), Color(0xFF0A3D6B)])),
                      child: const Text('💳 CREDITIS · Crédito en medicamentos', textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 7, fontWeight: FontWeight.w800, color: Colors.white))),
                    // 3. Nombre
                    Padding(padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                      child: Text(nombre, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.tx), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    // 4. Ubicación
                    Padding(padding: const EdgeInsets.fromLTRB(6, 2, 6, 2), child: Row(children: [
                      const Icon(Icons.location_on, size: 9, color: Color(0xFF34A853)),
                      const SizedBox(width: 2),
                      Expanded(child: Text(zona, style: const TextStyle(fontSize: 7, color: AppTheme.tm), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ])),
                    // 5. Foto real (llena el espacio)
                    Expanded(child: ClipRRect(child: hasFoto
                      ? Image.network(fotoUrl, width: double.infinity, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppTheme.cd, child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28)))))
                      : Container(color: AppTheme.cd, child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28)))))),
                    // 6. Rating + delivery time
                    Padding(padding: const EdgeInsets.fromLTRB(6, 3, 6, 2), child: Row(children: [
                      Text('⭐ $rating', style: const TextStyle(fontSize: 8, color: Color(0xFFFFD700), fontWeight: FontWeight.w800)),
                      const SizedBox(width: 4),
                      const Icon(Icons.access_time, size: 8, color: AppTheme.cy),
                      const SizedBox(width: 2),
                      Text(DeliveryTimeService.formatear(
                        prepMin: (n['prep_time_min'] as int?) ?? 10,
                        prepMax: (n['prep_time_max'] as int?) ?? 20,
                        zona: DeliveryTimeService.detectarZona(zona)),
                        style: const TextStyle(fontSize: 7, color: AppTheme.cy, fontWeight: FontWeight.w600)),
                    ])),
                    // 7. Botón Solicitar Crédito
                    Padding(padding: const EdgeInsets.fromLTRB(4, 2, 4, 2), child:
                      SizedBox(width: double.infinity, height: 24, child: ElevatedButton(
                        onPressed: () => launchUrl(Uri.parse('https://wa.me/527753200224?text=Hola%20quiero%20info%20sobre%20cr%C3%A9dito%20Creditis'), mode: LaunchMode.externalApplication),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D2137), foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: EdgeInsets.zero, elevation: 0),
                        child: const Text('Solicitar Crédito', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700))))),
                    // 8. Botón Ver Tienda
                    Padding(padding: const EdgeInsets.fromLTRB(4, 0, 4, 4), child:
                      SizedBox(width: double.infinity, height: 24, child: ElevatedButton(
                        onPressed: () => setState(() => _menuScreen = 'vip_${n['id']}'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: EdgeInsets.zero, elevation: 0),
                        child: const Text('Ver Tienda', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700))))),
                  ])));
              // ── NON-VIP CARD: Logo arriba + foto ubicación en medio ──
              final fsStreetUrl = PlacesPhotoService.streetViewUrl(nombre, zona);
              return GestureDetector(
                onTap: () => _showQuickOrderFs(n),
                child: Container(decoration: BoxDecoration(
                color: cardBg, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: borderWidth),
                boxShadow: cardShadows),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // 1. LOGO centrado sobre gradiente + badge
                  ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(19), topRight: Radius.circular(19)),
                    child: Container(height: 70, decoration: BoxDecoration(gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [c.withOpacity(0.6), c.withOpacity(0.2)])),
                      child: Stack(children: [
                        if (badge != null) Positioned(top: 4, left: 4, child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: plan == 'premium'
                                ? const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFB71C1C)])
                                : plan == 'basico'
                                ? const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF1565C0)])
                                : LinearGradient(colors: [c, c.withOpacity(0.8)]),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [BoxShadow(color: borderColor.withOpacity(0.5), blurRadius: 6)]),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (plan == 'premium') const Text('⭐ ', style: TextStyle(fontSize: 8)),
                            Text(badge!, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                          ]))),
                        Positioned(top: 4, right: 4, child: GestureDetector(
                          onTap: () => _showPhotoPickerDialog(n['id'].toString(), nombre),
                          child: Container(padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, size: 12, color: Colors.white)))),
                        Center(child: hasLogo
                          ? Container(width: 50, height: 50,
                              decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor, width: 1.5),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6)]),
                              child: ClipRRect(borderRadius: BorderRadius.circular(10),
                                child: Image.network(logoUrl, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(child: Text(emoji, style: const TextStyle(fontSize: 28))))))
                          : Container(width: 50, height: 50,
                              decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor, width: 1.5),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6)]),
                              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))))),
                      ]))),
                  // 2. Nombre
                  Padding(padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: Text(nombre, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.tx), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  // 3. Categoría + rating
                  Padding(padding: const EdgeInsets.fromLTRB(8, 2, 8, 2), child: Row(children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(5)),
                      child: Text('$emoji $cat', style: TextStyle(fontSize: 7, color: c, fontWeight: FontWeight.w600))),
                    const Spacer(),
                    Text('⭐ $rating', style: TextStyle(fontSize: 8, color: AppTheme.or, fontWeight: FontWeight.w700)),
                  ])),
                  // 4. Foto ubicación real (foto_url → Street View → emoji fallback)
                  Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ClipRRect(borderRadius: BorderRadius.circular(10),
                      child: hasFoto
                        ? Image.network(fotoUrl, width: double.infinity, fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) => progress == null ? child : _fsFallback(emoji, c),
                            errorBuilder: (_, __, ___) => Image.network(fsStreetUrl, width: double.infinity, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _fsFallback(emoji, c)))
                        : Image.network(fsStreetUrl, width: double.infinity, fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) => progress == null ? child : _fsFallback(emoji, c),
                            errorBuilder: (_, __, ___) => _fsFallback(emoji, c))))),
                  // 5. Ubicación
                  Padding(padding: const EdgeInsets.fromLTRB(8, 4, 8, 0), child: Row(children: [
                    const Icon(Icons.location_on, size: 10, color: Color(0xFF34A853)),
                    const SizedBox(width: 2),
                    Expanded(child: Text(zona, style: const TextStyle(fontSize: 8, color: AppTheme.td), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ])),
                  // 6. Tiempo estimado
                  Padding(padding: const EdgeInsets.fromLTRB(8, 2, 8, 0), child: Row(children: [
                    const Icon(Icons.access_time, size: 9, color: AppTheme.cy),
                    const SizedBox(width: 2),
                    Text(DeliveryTimeService.formatear(
                      prepMin: (n['prep_time_min'] as int?) ?? 10,
                      prepMax: (n['prep_time_max'] as int?) ?? 20,
                      zona: DeliveryTimeService.detectarZona(zona)),
                      style: const TextStyle(fontSize: 7, color: AppTheme.cy, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('$pedidos+ pedidos', style: const TextStyle(fontSize: 7, color: AppTheme.td)),
                  ])),
                  // 7. Botón
                  Padding(padding: const EdgeInsets.fromLTRB(6, 3, 6, 5), child:
                    SizedBox(width: double.infinity, height: 26, child: ElevatedButton(
                      onPressed: () => _showQuickOrderFs(n),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF34A853), foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.zero, elevation: 0),
                      child: const Text('Pedir Ahora', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700))))),
                ])));
            });
        }),
      ],
      // ── ALL cards in grid (VIP + cadena + non-VIP) sorted by plan with separators ──
      if (filtered.isNotEmpty) ...[
      LayoutBuilder(builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w > 600 ? 3 : 2;
        final cards = filtered.where((n) => n.id != 'c81').toList();
        cards.sort((a, b) {
          const po = {'vip': 0, 'vip_mandado': 1, 'cadena': 2, 'premium': 3, 'basico': 4};
          return (po[a.plan] ?? 5).compareTo(po[b.plan] ?? 5);
        });
        // Split into VIP and non-VIP
        final vipCards = cards.where((n) => n.plan == 'vip' || n.plan == 'vip_mandado').toList();
        final normalCards = cards.where((n) => n.plan != 'vip' && n.plan != 'vip_mandado').toList();

        Widget buildGrid(List<Negocio> items) => GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.55),
          itemCount: items.length, itemBuilder: (_, i) {
            final n = items[i];
            final coords = _negCoords[n.id];
            final hasCoords = coords != null;
            final lat = hasCoords ? coords[0] : 0.0;
            final lng = hasCoords ? coords[1] : 0.0;
            final streetUrl = PlacesPhotoService.streetViewUrl(n.nom, n.zona);
            // ── VIP CARD: tarjeta compacta en grid ──
            if (n.plan == 'vip') return GestureDetector(
              onTap: () => setState(() => _menuScreen = 'vip_${n.id}'),
              child: Container(decoration: BoxDecoration(
                color: const Color(0xFF1A1400), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD700), width: 2),
                boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.3), blurRadius: 12, spreadRadius: 1)]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // 1. LOGO 40x40 + VIP badge
                  ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(19), topRight: Radius.circular(19)),
                    child: Container(height: 100, decoration: const BoxDecoration(gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFFB8860B), Color(0xFFDAA520), Color(0xFFFFD700)])),
                      child: Stack(children: [
                        Positioned(top: 3, left: 3, child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)]),
                            borderRadius: BorderRadius.circular(5)),
                          child: const Text('👑 VIP', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Color(0xFF1A1400))))),
                        Center(child: Container(padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF87CEEB), Color(0xFF67D8EF)]), borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)]),
                          child: ClipRRect(borderRadius: BorderRadius.circular(10),
                            child: Image.asset('assets/images/farmacia_madrid_logo.png', width: 60, height: 60, fit: BoxFit.cover)))),
                      ]))),
                  // 2. CREDITIS una línea
                  Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0D2137), Color(0xFF0A3D6B)])),
                    child: const Text('💳 CREDITIS · Crédito en medicamentos', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 7, fontWeight: FontWeight.w800, color: Colors.white))),
                  // 3. Nombre
                  Padding(padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                    child: Text(n.nom, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.tx), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  // 4. Ubicación
                  Padding(padding: const EdgeInsets.fromLTRB(6, 2, 6, 2), child: Row(children: [
                    const Icon(Icons.location_on, size: 9, color: Color(0xFF34A853)),
                    const SizedBox(width: 2),
                    Expanded(child: Text(n.zona, style: const TextStyle(fontSize: 7, color: AppTheme.tm), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ])),
                  // 5. Foto real (fotoUrl → Street View → emoji fallback)
                  Expanded(child: ClipRRect(child: (n.fotoUrl != null && n.fotoUrl!.isNotEmpty)
                    ? Image.network(n.fotoUrl!, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.network(streetUrl, width: double.infinity, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppTheme.cd, child: Center(child: Text(n.e, style: const TextStyle(fontSize: 28))))))
                    : Image.network(streetUrl, width: double.infinity, fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null ? child : Container(color: AppTheme.cd, child: Center(child: Text(n.e, style: const TextStyle(fontSize: 28)))),
                        errorBuilder: (_, __, ___) => Container(color: AppTheme.cd, child: Center(child: Text(n.e, style: const TextStyle(fontSize: 28))))))),
                  // 6. Rating + horario
                  Padding(padding: const EdgeInsets.fromLTRB(6, 3, 6, 2), child: Row(children: [
                    Text('⭐ ${n.r}', style: const TextStyle(fontSize: 8, color: Color(0xFFFFD700), fontWeight: FontWeight.w800)),
                    if (n.horario != null) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.access_time, size: 8, color: AppTheme.cy),
                      const SizedBox(width: 2),
                      Expanded(child: Text(n.horario!, style: const TextStyle(fontSize: 7, color: AppTheme.tm), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ])),
                  // 7. Botón Solicitar Crédito
                  Padding(padding: const EdgeInsets.fromLTRB(4, 2, 4, 2), child:
                    SizedBox(width: double.infinity, height: 24, child: ElevatedButton(
                      onPressed: () => launchUrl(Uri.parse('https://wa.me/527753200224?text=Hola%20quiero%20info%20sobre%20cr%C3%A9dito%20Creditis'), mode: LaunchMode.externalApplication),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D2137), foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: EdgeInsets.zero, elevation: 0),
                      child: const Text('Solicitar Crédito', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700))))),
                  // 8. Botón Ver Tienda
                  Padding(padding: const EdgeInsets.fromLTRB(4, 0, 4, 4), child:
                    SizedBox(width: double.infinity, height: 24, child: ElevatedButton(
                      onPressed: () => setState(() => _menuScreen = 'vip_${n.id}'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700), foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: EdgeInsets.zero, elevation: 0),
                      child: const Text('Ver Tienda', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700))))),
                ])));
            // ── VIP MANDADO CARD: emoji arriba + foto real en MEDIO ──
            if (n.plan == 'vip_mandado') return GestureDetector(
              onTap: () => _showAddToCartModal(n),
              child: Container(decoration: BoxDecoration(
                color: const Color(0xFF1A1400), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD700), width: 2),
                boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.3), blurRadius: 12, spreadRadius: 1)]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // 1. Emoji + VIP badge arriba (compacto)
                  ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(19), topRight: Radius.circular(19)),
                    child: Container(height: 50, decoration: const BoxDecoration(gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFFB8860B), Color(0xFFDAA520), Color(0xFFFFD700)])),
                      child: Stack(children: [
                        Positioned(top: 3, left: 3, child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)]),
                            borderRadius: BorderRadius.circular(5)),
                          child: const Text('👑 VIP', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Color(0xFF1A1400))))),
                        Center(child: Text(n.e, style: const TextStyle(fontSize: 28))),
                      ]))),
                  // 2. Nombre
                  Padding(padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                    child: Text(n.nom, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.tx), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  // 3. Ubicación
                  Padding(padding: const EdgeInsets.fromLTRB(6, 2, 6, 0), child: Row(children: [
                    const Icon(Icons.location_on, size: 9, color: Color(0xFF34A853)),
                    const SizedBox(width: 2),
                    Expanded(child: Text(n.zona, style: TextStyle(fontSize: 7, color: Colors.white.withOpacity(0.8)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ])),
                  // 4. FOTO REAL EN MEDIO (fotoUrl → Street View → emoji)
                  Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                    child: ClipRRect(borderRadius: BorderRadius.circular(10),
                      child: (n.fotoUrl != null && n.fotoUrl!.isNotEmpty)
                        ? Image.network(n.fotoUrl!, width: double.infinity, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.network(streetUrl, width: double.infinity, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: AppTheme.cd, child: Center(child: Text(n.e, style: const TextStyle(fontSize: 28))))))
                        : Image.network(streetUrl, width: double.infinity, fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) => progress == null ? child : Container(color: AppTheme.cd, child: Center(child: Text(n.e, style: const TextStyle(fontSize: 28)))),
                            errorBuilder: (_, __, ___) => Container(color: AppTheme.cd, child: Center(child: Text(n.e, style: const TextStyle(fontSize: 28)))))))),
                  // 5. Rating + horario
                  Padding(padding: const EdgeInsets.fromLTRB(6, 0, 6, 2), child: Row(children: [
                    Text('⭐ ${n.r}', style: const TextStyle(fontSize: 8, color: Color(0xFFFFD700), fontWeight: FontWeight.w800)),
                    if (n.horario != null) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.access_time, size: 8, color: AppTheme.cy),
                      const SizedBox(width: 2),
                      Expanded(child: Text(n.horario!, style: const TextStyle(fontSize: 7, color: AppTheme.tm), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ])),
                  // 6. Botón Pedir Mandado
                  Padding(padding: const EdgeInsets.fromLTRB(4, 2, 4, 4), child:
                    SizedBox(width: double.infinity, height: 24, child: ElevatedButton(
                      onPressed: () => _showAddToCartModal(n),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D2137), foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: EdgeInsets.zero, elevation: 0),
                      child: const Text('🛒 Pedir Mandado', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700))))),
                ])));
            // ── CADENA CARD: tarjeta con logo arriba + foto real en medio ──
            if (n.plan == 'cadena') return GestureDetector(
              onTap: () => _showAddToCartModal(n),
              child: Container(decoration: BoxDecoration(
                color: _cadenaColor, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _cadenaBorder, width: 1.2),
                boxShadow: [BoxShadow(color: _cadenaColor.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // 1. Logo centrado (fondo celeste)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
                    child: Container(height: 50, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF87CEEB), Color(0xFF67D8EF)])), padding: const EdgeInsets.all(6),
                      child: Image.network(_cadenaLogos[n.e] ?? '', fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Center(child: Text(n.e, style: const TextStyle(fontSize: 24)))))),
                  // 2. Nombre
                  Padding(padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                    child: Text(n.nom, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  // 3. Ubicación
                  Padding(padding: const EdgeInsets.fromLTRB(6, 2, 6, 0), child: Row(children: [
                    const Icon(Icons.location_on, size: 8, color: Color(0xFF81D4FA)),
                    const SizedBox(width: 2),
                    Expanded(child: Text(n.zona, style: const TextStyle(fontSize: 6, color: Color(0xFFBBDEFB)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ])),
                  // 4. Foto real en medio (Street View fachada)
                  Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                    child: ClipRRect(borderRadius: BorderRadius.circular(8),
                      child: Image.network(streetUrl, width: double.infinity, fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null ? child : Container(color: const Color(0xFF0D2137), child: Center(child: Text(n.e, style: const TextStyle(fontSize: 28)))),
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0D2137), child: Center(child: Text(n.e, style: const TextStyle(fontSize: 28)))))))),
                  // 5. Horario + Botón
                  Padding(padding: const EdgeInsets.fromLTRB(6, 0, 6, 2), child: Row(children: [
                    if (n.horario != null) ...[
                      const Icon(Icons.access_time, size: 7, color: Color(0xFF81D4FA)),
                      const SizedBox(width: 2),
                      Expanded(child: Text(n.horario!, style: const TextStyle(fontSize: 6, color: Color(0xFFBBDEFB)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ])),
                  Padding(padding: const EdgeInsets.fromLTRB(4, 2, 4, 4), child:
                    SizedBox(width: double.infinity, height: 22, child: ElevatedButton(
                      onPressed: () => _showAddToCartModal(n),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF87CEEB), foregroundColor: _cadenaColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), padding: EdgeInsets.zero, elevation: 0),
                      child: const Text('🛒 Pedir Mandado', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700))))),
                ])));
            // ── NON-VIP CARD: emoji arriba + foto real en MEDIO ──
            return GestureDetector(
              onTap: () { if (n.menu != null) setState(() => _menuScreen = n.menu); else _showQuickOrder(n); },
              child: Container(decoration: BoxDecoration(
                color: AppTheme.cd, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: n.c.withOpacity(0.4), width: 1.2),
                boxShadow: [BoxShadow(color: n.c.withOpacity(0.15), blurRadius: 8, spreadRadius: 1)]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // 1. Emoji + badge tipo arriba (compacto)
                  ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(19), topRight: Radius.circular(19)),
                    child: Container(height: 50, decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [n.c.withOpacity(0.6), n.c.withOpacity(0.2)])),
                      child: Stack(children: [
                        Positioned(top: 4, left: 4, child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [n.c, n.c.withOpacity(0.8)]),
                            borderRadius: BorderRadius.circular(8)),
                          child: Text(n.tipo, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white)))),
                        Center(child: Text(n.e, style: const TextStyle(fontSize: 28))),
                      ]))),
                  // 2. Nombre + rating
                  Padding(padding: const EdgeInsets.fromLTRB(6, 4, 6, 0), child: Row(children: [
                    Expanded(child: Text(n.nom, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.tx), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text('⭐ ${n.r}', style: const TextStyle(fontSize: 8, color: AppTheme.or, fontWeight: FontWeight.w700)),
                  ])),
                  // 3. Ubicación
                  Padding(padding: const EdgeInsets.fromLTRB(6, 2, 6, 0), child: Row(children: [
                    const Icon(Icons.location_on, size: 9, color: Color(0xFF34A853)),
                    const SizedBox(width: 2),
                    Expanded(child: Text(n.zona, style: const TextStyle(fontSize: 7, color: AppTheme.td), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ])),
                  // 4. FOTO REAL FACHADA (Street View)
                  Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                    child: ClipRRect(borderRadius: BorderRadius.circular(10),
                      child: Image.network(streetUrl, width: double.infinity, fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) => progress == null ? child : _negCardFallback(n),
                        errorBuilder: (_, __, ___) => _negCardFallback(n))))),
                  // 5. Pedidos + Botón
                  Padding(padding: const EdgeInsets.fromLTRB(4, 0, 4, 4), child: Row(children: [
                    const SizedBox(width: 4),
                    Text('${n.ped}+ pedidos', style: const TextStyle(fontSize: 7, color: AppTheme.td)),
                    const SizedBox(width: 6),
                    Expanded(child: SizedBox(height: 24, child: ElevatedButton(
                      onPressed: () { if (n.menu != null) setState(() => _menuScreen = n.menu); else _showQuickOrder(n); },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF34A853), foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.zero, elevation: 0),
                      child: const Text('Pedir Ahora', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700))))),
                  ])),
                ])));
          });

        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // ── Separador VIP ──
          if (vipCards.isNotEmpty) ...[
            Padding(padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                Expanded(child: Container(height: 1, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Color(0xFFFFD700)])))),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('👑 SERVICIOS VIP CARGO-GO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFFFFD700),
                    shadows: [Shadow(color: const Color(0xFFFFD700).withOpacity(0.5), blurRadius: 6)]))),
                Expanded(child: Container(height: 1, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFFD700), Colors.transparent])))),
              ])),
            buildGrid(vipCards),
            const SizedBox(height: 16),
          ],
          // ── Separador Normales ──
          if (normalCards.isNotEmpty) ...[
            Padding(padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, AppTheme.ac.withOpacity(0.5)])))),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('🏪 MÁS NEGOCIOS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.ac,
                    shadows: [Shadow(color: AppTheme.ac.withOpacity(0.5), blurRadius: 6)]))),
                Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.ac.withOpacity(0.5), Colors.transparent])))),
              ])),
            buildGrid(normalCards),
          ],
        ]);
      }),
      ],
      // ── 💡 Buzón de sugerencias ──
      Container(margin: const EdgeInsets.only(top: 16), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.bd)),
        child: Column(children: [
          const Text('💡 ¿No encuentras tu negocio? ¡Sugiérelo!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.tx)),
          const SizedBox(height: 10),
          TextField(controller: _sugNomCtrl, style: const TextStyle(color: AppTheme.tx, fontSize: 12),
            decoration: InputDecoration(hintText: 'Nombre del negocio', hintStyle: const TextStyle(color: AppTheme.td, fontSize: 12),
              filled: true, fillColor: AppTheme.sf, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _sugTipoCtrl, style: const TextStyle(color: AppTheme.tx, fontSize: 12),
              decoration: InputDecoration(hintText: 'Tipo (comida, etc)', hintStyle: const TextStyle(color: AppTheme.td, fontSize: 12),
                filled: true, fillColor: AppTheme.sf, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _sugZonaCtrl, style: const TextStyle(color: AppTheme.tx, fontSize: 12),
              decoration: InputDecoration(hintText: 'Zona', hintStyle: const TextStyle(color: AppTheme.td, fontSize: 12),
                filled: true, fillColor: AppTheme.sf, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)))),
          ]),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, height: 38, child: ElevatedButton.icon(
            onPressed: _enviarSugerencia,
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Enviar sugerencia', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.ac, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0))),
        ])),
      const SizedBox(height: 20),
    ]));
  }

  // Fallback visual para tarjeta de negocio (sin foto real)
  Widget _negCardFallback(Negocio n) => Container(
    decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [n.c.withOpacity(0.3), n.c.withOpacity(0.08)])),
    child: Center(child: Text(n.e, style: const TextStyle(fontSize: 44))));

  Widget _cityBtn(String k, String l) => Expanded(child: GestureDetector(onTap: () => setState(() => _negCity = k),
    child: Container(margin: const EdgeInsets.symmetric(horizontal: 2), padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _negCity == k ? const Color(0xFFFFD700) : AppTheme.bd, width: _negCity == k ? 1.5 : 1.2),
      gradient: _negCity == k ? const LinearGradient(colors: [Color(0xFFB8860B), Color(0xFFDAA520)]) : null,
      color: _negCity == k ? null : Colors.transparent),
      child: Text(l, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _negCity == k ? Colors.white : AppTheme.tm)))));

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
      floatingActionButton: _cartQty > 0 ? FloatingActionButton.extended(onPressed: _openCart, backgroundColor: const Color(0xFFE3F2FD),
        heroTag: 'menuCart',
        icon: const Icon(Icons.shopping_cart, color: Color(0xFF0D47A1), size: 18),
        label: Text('$_cartQty · \$$_cartTotal', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D47A1)))) : null,
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
    Map<String, dynamic> n = _firestoreNegocios.firstWhere((x) => x['id'] == negocioId, orElse: () => <String, dynamic>{});
    if (n.isEmpty) {
      // Fallback: build Map from static Negocio data
      final allNeg = [...negHidalgo, ...negCdmx];
      final sn = allNeg.where((x) => x.id == negocioId).toList();
      if (sn.isNotEmpty) {
        final s = sn.first;
        n = {'id': s.id, 'nombre': s.nom, 'emoji': s.e, 'zona': s.zona, 'desc': s.desc,
          'categoria': s.tipo, 'rating': s.r, 'pedidos': s.ped,
          'color_hex': '#${s.c.value.toRadixString(16).substring(2)}',
          'horario': s.horario ?? '', 'telefono': s.tel ?? '',
          'foto_url': s.fotoUrl ?? '', 'plan': s.plan ?? 'gratis'};
      }
    }
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
              // ── 🔥 OFERTAS ──
              const Text('🔥 Ofertas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.tx)),
              const SizedBox(height: 10),
              GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85),
                itemCount: _ofertasUrls.length, itemBuilder: (_, i) => GestureDetector(
                  onTap: () => launchUrl(Uri.parse('https://wa.me/527753200224?text=Hola%20me%20interesa%20esta%20oferta%20%23${i + 1}'), mode: LaunchMode.externalApplication),
                  child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2ECC71), width: 1.5)),
                    child: ClipRRect(borderRadius: BorderRadius.circular(10),
                      child: Image.network(_ofertasUrls[i], fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0A2E17),
                          child: const Center(child: Text('📋', style: TextStyle(fontSize: 24))))))))),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 44, child: ElevatedButton.icon(
                onPressed: () => launchUrl(Uri.parse('https://wa.me/527753200224?text=Hola%20me%20interesa%20una%20oferta%20de%20Farmacias%20Madrid'), mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.local_offer, size: 18),
                label: const Text('Comprar Oferta', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0))),
              const SizedBox(height: 18),
              // ── 💳 CREDITIS ──
              Container(padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0D2137), Color(0xFF0A3D6B)]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2D7AFF).withOpacity(0.3))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Text('💳 ', style: TextStyle(fontSize: 20)),
                    Text('CREDITIS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
                  ]),
                  const SizedBox(height: 8),
                  const Text('Crédito en medicamentos de especialidad', style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text('• Sin tarjeta de crédito\n• Aprobación inmediata\n• Hasta 12 meses sin intereses\n• Medicamentos de especialidad y alta especialidad',
                    style: TextStyle(fontSize: 11, color: Colors.white60, height: 1.6)),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, height: 40, child: ElevatedButton(
                    onPressed: () => launchUrl(Uri.parse('https://wa.me/527753200224?text=Hola%20quiero%20info%20sobre%20cr%C3%A9dito%20Creditis'), mode: LaunchMode.externalApplication),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF87CEEB), foregroundColor: const Color(0xFF0D2137),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                    child: const Text('Solicitar Crédito', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)))),
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

  // ═══ PEDIDO DE MANDADO ═══
  Widget _mandadoScreen(String storeId) {
    final allNeg = [...negHidalgo, ...negCdmx];
    final match = allNeg.where((n) => n.id == storeId).toList();
    if (match.isEmpty) return Scaffold(backgroundColor: AppTheme.bg,
      appBar: AppBar(backgroundColor: AppTheme.sf, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _menuScreen = null)),
        title: const Text('Tienda no encontrada')),
      body: const Center(child: Text('No se encontró la tienda', style: TextStyle(color: AppTheme.tx))));
    final store = match.first;
    final logoUrl = _cadenaLogos[store.e] ?? '';
    final isVipMandado = store.plan == 'vip_mandado';
    final accentColor = isVipMandado ? const Color(0xFFFFD700) : const Color(0xFF2563EB);
    final coords = _negCoords[store.id];
    final hasCoords = coords != null;
    final lat = hasCoords ? coords[0] : 0.0;
    final lng = hasCoords ? coords[1] : 0.0;

    InputDecoration _fieldDeco(String label, IconData icon, Color iconColor, {String? hint}) => InputDecoration(
      labelText: label, labelStyle: TextStyle(color: isVipMandado ? const Color(0xFFBFA36D) : AppTheme.tm, fontSize: 11),
      hintText: hint, hintStyle: TextStyle(color: isVipMandado ? const Color(0xFF8B7D5B) : AppTheme.td, fontSize: 11),
      prefixIcon: Icon(icon, size: 18, color: iconColor),
      filled: false,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isVipMandado ? const Color(0xFF3D3520) : AppTheme.bd)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: accentColor, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12));

    return Scaffold(backgroundColor: AppTheme.bg,
      appBar: AppBar(backgroundColor: isVipMandado ? const Color(0xFF1A1400) : const Color(0xFF0F172A),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() { _menuScreen = null; _mandadoCuando = 'Lo antes posible'; _mandadoFotoPath = null; })),
        title: Row(children: [
          if (logoUrl.isNotEmpty)
            ClipRRect(borderRadius: BorderRadius.circular(6),
              child: Container(width: 28, height: 28, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF87CEEB), Color(0xFF67D8EF)])), padding: const EdgeInsets.all(2),
                child: Image.network(logoUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Text(store.e, style: const TextStyle(fontSize: 14)))))
          else
            Text(store.e, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(child: Text(store.nom, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isVipMandado ? const Color(0xFFFFD700) : Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ])),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // ── Foto header ──
        Container(
          height: 160, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isVipMandado ? const Color(0xFFFFD700) : _cadenaBorder)),
          child: ClipRRect(borderRadius: BorderRadius.circular(15),
            child: Stack(children: [
              Positioned.fill(child: Image.network(
                PlacesPhotoService.streetViewUrl(store.nom, store.zona), fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1E293B)))),
              Positioned.fill(child: Container(decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)])))),
              Positioned(bottom: 12, left: 12, right: 12, child: Row(children: [
                Text(store.e, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(store.nom, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  Row(children: [
                    const Icon(Icons.location_on, size: 11, color: Color(0xFF34A853)),
                    const SizedBox(width: 3),
                    Expanded(child: Text(store.zona, style: const TextStyle(fontSize: 10, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ])),
              ])),
            ])),
        ),
        const SizedBox(height: 16),
        // ── Instrucciones ──
        Container(padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isVipMandado ? const Color(0xFFFFD700).withOpacity(0.08) : accentColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accentColor.withOpacity(0.2))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.shopping_cart, size: 18, color: accentColor),
            const SizedBox(width: 8),
            Expanded(child: Text(
              isVipMandado
                ? 'Dinos qué producto buscas y en qué zona. Nosotros vamos, lo encontramos y te lo enviamos.'
                : 'Escribe tu lista de compras y nosotros vamos a la tienda, compramos todo y te lo llevamos a tu puerta.',
              style: TextStyle(fontSize: 11, color: accentColor))),
          ])),
        const SizedBox(height: 16),

        // ═══ VIP MANDADO FIELDS (Tepito, Plazas Chinas, Mercados) ═══
        if (isVipMandado) ...[
          // Campo 1: Zona/Piso
          const Text('📍 ¿Qué zona o piso?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          const SizedBox(height: 8),
          TextField(controller: _mandadoZona,
            style: const TextStyle(color: AppTheme.tx, fontSize: 12),
            decoration: _fieldDeco('Zona o piso', Icons.layers, const Color(0xFFFFD700), hint: 'Ej: Piso 2, zona de celulares')),
          const SizedBox(height: 14),
          // Campo 2: Producto
          const Text('📦 ¿Qué producto buscas?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          const SizedBox(height: 8),
          TextField(controller: _mandadoProducto, maxLines: 3,
            style: const TextStyle(color: AppTheme.tx, fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Ej: Tenis Nike Air Max negros talla 27',
              hintStyle: const TextStyle(color: Color(0xFF8B7D5B), fontSize: 11),
              filled: false,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF3D3520))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5)),
              contentPadding: const EdgeInsets.all(12))),
          const SizedBox(height: 14),
          // Campo 3: Presupuesto
          const Text('💵 Presupuesto máximo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          const SizedBox(height: 8),
          TextField(controller: _mandadoPresupuesto,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.tx, fontSize: 12),
            decoration: _fieldDeco('Presupuesto', Icons.attach_money, const Color(0xFF00D68F), hint: '\$500')),
          const SizedBox(height: 14),
          // Campo 4: Foto de referencia
          const Text('📸 ¿Tienes foto de referencia?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
              if (img != null) setState(() => _mandadoFotoPath = img.path);
            },
            child: Container(height: 80,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF3D3520), style: BorderStyle.solid),
                color: const Color(0xFF1A1400)),
              child: _mandadoFotoPath != null
                ? ClipRRect(borderRadius: BorderRadius.circular(13),
                    child: Stack(children: [
                      Positioned.fill(child: Image.network(_mandadoFotoPath!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: AppTheme.td)))),
                      Positioned(top: 4, right: 4, child: GestureDetector(
                        onTap: () => setState(() => _mandadoFotoPath = null),
                        child: Container(padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 14, color: Colors.white)))),
                    ]))
                : const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.add_photo_alternate, size: 28, color: Color(0xFFBFA36D)),
                    SizedBox(height: 4),
                    Text('Adjuntar imagen de galería', style: TextStyle(fontSize: 10, color: Color(0xFFBFA36D))),
                  ])))),
          const SizedBox(height: 14),
          // Campo 5: Notas adicionales
          const Text('📝 Notas adicionales', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          const SizedBox(height: 8),
          TextField(controller: _mandadoNotas, maxLines: 2,
            style: const TextStyle(color: AppTheme.tx, fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Ej: Si no hay negros, que sean azules',
              hintStyle: const TextStyle(color: Color(0xFF8B7D5B), fontSize: 11),
              filled: false,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF3D3520))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5)),
              contentPadding: const EdgeInsets.all(12))),
          const SizedBox(height: 14),
          // Envío
          const Text('🚚 Tipo de envío', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final op in ['Económico', 'Estándar', 'Express'])
              ChoiceChip(
                label: Text(op, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: _mandadoEnvio == op ? Colors.black : AppTheme.tm)),
                selected: _mandadoEnvio == op,
                onSelected: (sel) { if (sel) setState(() => _mandadoEnvio = op); },
                selectedColor: const Color(0xFFFFD700),
                backgroundColor: const Color(0xFF1E293B),
                side: BorderSide(color: _mandadoEnvio == op ? const Color(0xFFFFD700) : const Color(0xFF3D3520)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ]),
          const SizedBox(height: 14),
          // Ciudad, Estado, CP
          TextField(controller: _mandadoCiudad,
            style: const TextStyle(color: AppTheme.tx, fontSize: 12),
            decoration: _fieldDeco('Ciudad, Estado, CP', Icons.location_city, const Color(0xFF34A853), hint: 'Ej: Tulancingo, Hidalgo, 43600')),
          const SizedBox(height: 10),
          // Dirección
          TextField(controller: _mandadoDir,
            style: const TextStyle(color: AppTheme.tx, fontSize: 12),
            decoration: _fieldDeco('Dirección de entrega', Icons.location_on, const Color(0xFF34A853))),
          const SizedBox(height: 10),
          // Pago
          TextField(controller: _mandadoPago,
            style: const TextStyle(color: AppTheme.tx, fontSize: 12),
            decoration: _fieldDeco('Método de pago', Icons.payment, const Color(0xFF2563EB), hint: 'Ej: Efectivo, Transferencia, Tarjeta')),
          const SizedBox(height: 10),
          // Teléfono
          TextField(controller: _mandadoTel,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: AppTheme.tx, fontSize: 12),
            decoration: _fieldDeco('Tu teléfono', Icons.phone, AppTheme.td)),
        ]
        // ═══ CADENA FIELDS (supermercados, restaurantes, etc.) ═══
        else ...[
          const Text('📋 Tu lista de compras', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          const SizedBox(height: 8),
          TextField(controller: _mandadoLista, maxLines: 6,
            style: const TextStyle(color: AppTheme.tx, fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Ej:\n- 2 litros de leche entera\n- 1 kg de manzanas\n- Detergente Ariel 3kg\n- 12 huevos\n- Pan Bimbo blanco',
              hintStyle: const TextStyle(color: AppTheme.td, fontSize: 11),
              filled: false,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.bd)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
              contentPadding: const EdgeInsets.all(12))),
          const SizedBox(height: 14),
          TextField(controller: _mandadoTel, keyboardType: TextInputType.phone,
            style: const TextStyle(color: AppTheme.tx, fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Tu teléfono', labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 11),
              prefixIcon: const Icon(Icons.phone, size: 18, color: AppTheme.td), filled: false,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.bd)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12))),
          const SizedBox(height: 10),
          TextField(controller: _mandadoDir,
            style: const TextStyle(color: AppTheme.tx, fontSize: 12),
            decoration: InputDecoration(
              labelText: 'Dirección de entrega', labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 11),
              prefixIcon: const Icon(Icons.location_on, size: 18, color: Color(0xFF34A853)), filled: false,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.bd)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12))),
          const SizedBox(height: 14),
          const Text('🕐 ¿Cuándo lo necesitas?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final op in ['Lo antes posible', 'Hoy en la tarde', 'Mañana temprano', 'Elegir hora'])
              ChoiceChip(
                label: Text(op, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: _mandadoCuando == op ? Colors.white : AppTheme.tm)),
                selected: _mandadoCuando == op,
                onSelected: (sel) { if (sel) setState(() => _mandadoCuando = op); },
                selectedColor: const Color(0xFF2563EB),
                backgroundColor: const Color(0xFF1E293B),
                side: BorderSide(color: _mandadoCuando == op ? const Color(0xFF2563EB) : _cadenaBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ]),
        ],
        const SizedBox(height: 16),
        // ── Info cobro ──
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.yl.withOpacity(0.08), borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.yl.withOpacity(0.2))),
          child: const Row(children: [
            Icon(Icons.payments, size: 16, color: AppTheme.yl),
            SizedBox(width: 8),
            Expanded(child: Text('Se cobra: costo de productos + comisión de servicio + envío', style: TextStyle(fontSize: 10, color: AppTheme.yl))),
          ])),
        const SizedBox(height: 16),
        // ── Botón enviar ──
        SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
          onPressed: _mandadoEnviando ? null : () => _enviarMandado(store),
          icon: _mandadoEnviando
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send, size: 18),
          label: Text(_mandadoEnviando ? 'Enviando...' : 'Enviar Pedido de Mandado',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: isVipMandado ? const Color(0xFFFFD700) : accentColor,
            foregroundColor: isVipMandado ? Colors.black : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 4,
            shadowColor: accentColor.withOpacity(0.4)))),
        const SizedBox(height: 20),
      ]),
    );
  }

  void _enviarMandado(Negocio store) async {
    final isVipMandado = store.plan == 'vip_mandado';

    if (isVipMandado) {
      if (_mandadoProducto.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Describe qué producto buscas'), backgroundColor: AppTheme.rd));
        return;
      }
      if (_mandadoTel.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega tu teléfono'), backgroundColor: AppTheme.rd));
        return;
      }
      if (_mandadoDir.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega tu dirección de entrega'), backgroundColor: AppTheme.rd));
        return;
      }
    } else {
      if (_mandadoLista.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escribe tu lista de compras'), backgroundColor: AppTheme.rd));
        return;
      }
      if (_mandadoTel.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega tu teléfono'), backgroundColor: AppTheme.rd));
        return;
      }
      if (_mandadoDir.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega tu dirección de entrega'), backgroundColor: AppTheme.rd));
        return;
      }
    }

    setState(() => _mandadoEnviando = true);

    // Generate order number
    String numeroPedido;
    try {
      numeroPedido = await FirestoreService.generarNumeroPedido();
    } catch (_) {
      final now = DateTime.now();
      numeroPedido = 'CG-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${(now.millisecond).toString().padLeft(3, '0')}';
    }

    // Calculate costs
    final now = DateTime.now();
    double subtotal = 0;
    double envioCosto = 0;
    String productoDesc = '';
    String envioTipo = '';

    if (isVipMandado) {
      final presStr = _mandadoPresupuesto.text.trim().replaceAll(RegExp(r'[^0-9.]'), '');
      subtotal = double.tryParse(presStr) ?? 0;
      envioTipo = _mandadoEnvio;
      envioCosto = envioTipo == 'Económico' ? 150 : envioTipo == 'Express' ? 400 : 250;
      productoDesc = _mandadoProducto.text.trim();
    } else {
      envioTipo = _mandadoCuando;
      envioCosto = 200;
      productoDesc = _mandadoLista.text.trim();
    }

    final total = subtotal + envioCosto;
    final fechaStr = '${now.day.toString().padLeft(2, '0')}/${_mesCorto(now.month)}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Build ticket data
    final ticketInfo = <String, dynamic>{
      'numero_pedido': numeroPedido,
      'fecha': fechaStr,
      'timestamp': now.toIso8601String(),
      'cliente_nombre': '', // User can add later
      'cliente_telefono': _mandadoTel.text.trim(),
      'cliente_direccion': _mandadoDir.text.trim(),
      'cliente_ciudad': isVipMandado ? _mandadoCiudad.text.trim() : '',
      'tienda_id': store.id,
      'tienda_nombre': store.nom,
      'tienda_emoji': store.e,
      'is_vip_mandado': isVipMandado,
      'productos': isVipMandado ? [
        {
          'tienda': store.nom,
          'producto': _mandadoProducto.text.trim(),
          'zona_piso': _mandadoZona.text.trim(),
          'presupuesto': subtotal,
          'notas': _mandadoNotas.text.trim(),
          'foto_referencia': _mandadoFotoPath ?? '',
        }
      ] : [
        {
          'tienda': store.nom,
          'producto': _mandadoLista.text.trim(),
          'presupuesto': 0.0,
        }
      ],
      'subtotal': subtotal,
      'envio_tipo': envioTipo,
      'envio_costo': envioCosto,
      'total': total,
      'metodo_pago': isVipMandado ? (_mandadoPago.text.trim().isNotEmpty ? _mandadoPago.text.trim() : '') : '',
      'estado': 'pendiente_pago',
      'whatsapp_enviado': false,
    };

    // Save to Firestore
    try {
      final docId = await FirestoreService.guardarPedido(ticketInfo);
      ticketInfo['doc_id'] = docId;
    } catch (_) {}

    // Navigate to ticket screen
    setState(() {
      _ticketData = ticketInfo;
      _mandadoEnviando = false;
      _menuScreen = 'ticket';
    });
  }

  String _mesCorto(int m) => const ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'][m];

  // ═══ TICKET / RECIBO SCREEN ═══
  Widget _ticketScreen() {
    final d = _ticketData;
    if (d == null) return Scaffold(backgroundColor: AppTheme.bg,
      body: Center(child: TextButton(onPressed: () => setState(() => _menuScreen = null),
        child: const Text('Sin datos de ticket', style: TextStyle(color: AppTheme.tx)))));
    final productos = (d['productos'] as List?) ?? [];
    final numPedido = d['numero_pedido'] ?? '';
    final isVip = d['is_vip_mandado'] == true;
    final total = (d['total'] as num?)?.toDouble() ?? 0;
    final subtotal = (d['subtotal'] as num?)?.toDouble() ?? 0;
    final envioCosto = (d['envio_costo'] as num?)?.toDouble() ?? 0;
    final goldColor = const Color(0xFFFFD700);

    return Scaffold(backgroundColor: AppTheme.bg,
      appBar: AppBar(backgroundColor: const Color(0xFF1A1400),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() { _menuScreen = null; _ticketData = null; })),
        title: Text('Ticket $numPedido', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFFFD700)))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // ═══ TICKET CARD ═══
        Container(
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: goldColor.withOpacity(0.3), blurRadius: 16, spreadRadius: 2)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // Header dorado
            Container(padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFB8860B), Color(0xFFDAA520), Color(0xFFFFD700)]),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
              child: const Column(children: [
                Text('🟡 CARGO-GO 🟡', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A1400))),
                SizedBox(height: 4),
                Text('══════════════════', style: TextStyle(fontSize: 10, color: Color(0xFF5C4A1E))),
                Text('TICKET DE PEDIDO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1A1400))),
                Text('══════════════════', style: TextStyle(fontSize: 10, color: Color(0xFF5C4A1E))),
              ])),
            // Info pedido
            Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _ticketRow('📋', 'Pedido', numPedido),
              _ticketRow('📅', 'Fecha', d['fecha'] ?? ''),
              if ((d['cliente_telefono'] ?? '').isNotEmpty) _ticketRow('📞', 'Tel', d['cliente_telefono']),
              const SizedBox(height: 12),
              // Separador
              Container(height: 1, color: Colors.grey.shade300),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('PRODUCTOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: 2))),
              Container(height: 1, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              // Productos
              ...productos.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final p = entry.value as Map<String, dynamic>;
                final pres = (p['presupuesto'] as num?)?.toDouble() ?? 0;
                return Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$idx. ${p['tienda'] ?? ''}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87)),
                  if ((p['zona_piso'] ?? '').isNotEmpty)
                    Text('   Zona: ${p['zona_piso']}', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                  Text('   ${p['producto'] ?? ''}', style: const TextStyle(fontSize: 10, color: Colors.black87)),
                  if (pres > 0) Align(alignment: Alignment.centerRight,
                    child: Text('Presupuesto: \$${pres.toStringAsFixed(2)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black87))),
                  if ((p['notas'] ?? '').isNotEmpty)
                    Text('   Notas: ${p['notas']}', style: const TextStyle(fontSize: 9, color: Colors.black45, fontStyle: FontStyle.italic)),
                ]));
              }),
              const SizedBox(height: 8),
              // Resumen
              Container(height: 1, color: Colors.grey.shade300),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('RESUMEN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: 2))),
              Container(height: 1, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              if (subtotal > 0) _ticketMoney('Subtotal productos', subtotal),
              _ticketMoney('Envío ${d['envio_tipo'] ?? ''}', envioCosto),
              Container(height: 1.5, margin: const EdgeInsets.symmetric(vertical: 6), color: Colors.black),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('TOTAL ESTIMADO:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black)),
                Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFFB8860B))),
              ]),
              const SizedBox(height: 12),
              // Envío
              Container(height: 1, color: Colors.grey.shade300),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('ENVÍO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: 2))),
              Container(height: 1, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              _ticketRow('📦', 'Tipo', d['envio_tipo'] ?? ''),
              if ((d['cliente_ciudad'] ?? '').isNotEmpty) _ticketRow('📍', 'Ciudad', d['cliente_ciudad']),
              _ticketRow('📍', 'Dirección', d['cliente_direccion'] ?? ''),
              const SizedBox(height: 12),
              // Estado
              Container(height: 1, color: Colors.grey.shade300),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('ESTADO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black54, letterSpacing: 2))),
              Container(height: 1, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(8)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('🟡', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text('Pendiente de pago', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF856404))),
                ])),
              const SizedBox(height: 16),
              // Footer
              const Center(child: Column(children: [
                Text('══════════════════════════', style: TextStyle(fontSize: 9, color: Colors.black26)),
                SizedBox(height: 4),
                Text('"Gracias por tu compra con', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black54)),
                Text('Cargo-GO · Tepito a tu puerta"', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, fontWeight: FontWeight.w700, color: Color(0xFFB8860B))),
                Text('══════════════════════════', style: TextStyle(fontSize: 9, color: Colors.black26)),
              ])),
            ])),
          ]),
        ),
        const SizedBox(height: 20),
        // ═══ BOTONES DE PAGO ═══
        // 1. MercadoPago
        SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(
          onPressed: _ticketPagando ? null : () => _pagarMercadoPago(),
          icon: _ticketPagando
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1400)))
            : const Text('💳', style: TextStyle(fontSize: 20)),
          label: Text(_ticketPagando ? 'Procesando...' : 'PAGAR CON MERCADO PAGO',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          style: ElevatedButton.styleFrom(
            backgroundColor: goldColor, foregroundColor: const Color(0xFF1A1400),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 4, shadowColor: goldColor.withOpacity(0.4)))),
        const SizedBox(height: 10),
        // 2. Transferencia
        SizedBox(width: double.infinity, height: 46, child: ElevatedButton.icon(
          onPressed: () => _mostrarTransferencia(),
          icon: const Text('📱', style: TextStyle(fontSize: 18)),
          label: const Text('PAGAR POR TRANSFERENCIA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
        const SizedBox(height: 10),
        // 3. OXXO
        SizedBox(width: double.infinity, height: 46, child: ElevatedButton.icon(
          onPressed: () => _mostrarOxxo(),
          icon: const Text('🏪', style: TextStyle(fontSize: 18)),
          label: const Text('PAGAR EN OXXO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF57C00), foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
        const SizedBox(height: 10),
        // 4. Descargar PDF
        SizedBox(width: double.infinity, height: 40, child: OutlinedButton.icon(
          onPressed: () => _descargarTicketPdf(),
          icon: const Icon(Icons.picture_as_pdf, size: 16),
          label: const Text('DESCARGAR TICKET PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(foregroundColor: AppTheme.tm,
            side: const BorderSide(color: AppTheme.bd),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
        const SizedBox(height: 10),
        // 5. WhatsApp
        SizedBox(width: double.infinity, height: 46, child: ElevatedButton.icon(
          onPressed: () => _enviarTicketWhatsApp(),
          icon: const Text('📱', style: TextStyle(fontSize: 18)),
          label: const Text('ENVIAR POR WHATSAPP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
        const SizedBox(height: 30),
      ]),
    );
  }

  Widget _ticketRow(String emoji, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      Text('$emoji ', style: const TextStyle(fontSize: 12)),
      Text('$label: ', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black54)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis)),
    ]));

  Widget _ticketMoney(String label, double amount) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
    ]));

  // ═══ MERCADO PAGO ═══
  void _pagarMercadoPago() async {
    final d = _ticketData;
    if (d == null) return;
    setState(() => _ticketPagando = true);
    final numPedido = d['numero_pedido'] ?? '';
    final total = (d['total'] as num?)?.toDouble() ?? 0;
    final productos = (d['productos'] as List?) ?? [];
    final desc = productos.map((p) => (p as Map)['tienda'] ?? '').join(', ');

    final ok = await MercadoPagoService.checkout(
      title: 'Pedido Cargo-GO #$numPedido',
      description: '${productos.length} producto(s) de $desc',
      amount: total > 0 ? total : 1.0,
      externalReference: numPedido,
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al conectar con MercadoPago'), backgroundColor: AppTheme.rd));
    }
    setState(() => _ticketPagando = false);
  }

  // ═══ TRANSFERENCIA ═══
  void _mostrarTransferencia() {
    final d = _ticketData;
    if (d == null) return;
    final numPedido = d['numero_pedido'] ?? '';
    final total = (d['total'] as num?)?.toDouble() ?? 0;
    const clabe = '012180001234567890';

    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Color(0xFF0F172A),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Center(child: Text('💳 DATOS PARA TRANSFERENCIA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white))),
          const SizedBox(height: 16),
          _transRow('Banco', 'BBVA'),
          _transRow('CLABE', clabe),
          _transRow('Cuenta', '1234567890'),
          _transRow('Titular', 'Cargo-GO SA de CV'),
          _transRow('Referencia', numPedido),
          _transRow('Monto', '\$${total.toStringAsFixed(2)}'),
          const SizedBox(height: 14),
          // Copiar CLABE
          SizedBox(width: double.infinity, height: 40, child: OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: clabe));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CLABE copiada'), backgroundColor: AppTheme.gr, duration: Duration(seconds: 1)));
            },
            icon: const Icon(Icons.copy, size: 14),
            label: const Text('Copiar CLABE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF81D4FA),
              side: const BorderSide(color: Color(0xFF1565C0)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.yl.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: const Row(children: [
              Text('⚠️', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Expanded(child: Text('Envía tu comprobante por WhatsApp para confirmar tu pago',
                style: TextStyle(fontSize: 10, color: AppTheme.yl))),
            ])),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, height: 44, child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              final msg = 'Comprobante pedido #$numPedido por \$${total.toStringAsFixed(2)}';
              launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent(msg)}'), mode: LaunchMode.externalApplication);
            },
            icon: const Text('📱', style: TextStyle(fontSize: 16)),
            label: const Text('Enviar comprobante', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          const SizedBox(height: 10),
        ])));
  }

  Widget _transRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.tm))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
    ]));

  // ═══ OXXO ═══
  void _mostrarOxxo() {
    final d = _ticketData;
    if (d == null) return;
    final numPedido = d['numero_pedido'] ?? '';
    final total = (d['total'] as num?)?.toDouble() ?? 0;
    // Generar referencia OXXO basada en el número de pedido
    final refOxxo = numPedido.replaceAll('-', '');

    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Color(0xFF0F172A),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Center(child: Text('🏪 PAGO EN OXXO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white))),
          const SizedBox(height: 16),
          _transRow('Referencia', refOxxo),
          _transRow('Monto exacto', '\$${total.toStringAsFixed(2)}'),
          _transRow('Vigencia', '72 horas'),
          const SizedBox(height: 10),
          // Copiar referencia
          SizedBox(width: double.infinity, height: 40, child: OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: refOxxo));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Referencia copiada'), backgroundColor: AppTheme.gr, duration: Duration(seconds: 1)));
            },
            icon: const Icon(Icons.copy, size: 14),
            label: const Text('Copiar referencia', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFFFB74D),
              side: const BorderSide(color: Color(0xFFF57C00)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
          const SizedBox(height: 14),
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF57C00).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Pasos:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFFFB74D))),
              const SizedBox(height: 6),
              ...[
                '1. Ve a cualquier OXXO',
                '2. Dile al cajero "depósito"',
                '3. Da la referencia: $refOxxo',
                '4. Paga \$${total.toStringAsFixed(2)} exactos',
                '5. Guarda tu ticket',
                '6. Envía foto del ticket por WhatsApp',
              ].map((s) => Padding(padding: const EdgeInsets.only(bottom: 3),
                child: Text(s, style: const TextStyle(fontSize: 10, color: Colors.white70)))),
            ])),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, height: 44, child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              final msg = 'Comprobante OXXO pedido #$numPedido por \$${total.toStringAsFixed(2)}';
              launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent(msg)}'), mode: LaunchMode.externalApplication);
            },
            icon: const Text('📱', style: TextStyle(fontSize: 16)),
            label: const Text('Enviar ticket OXXO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          const SizedBox(height: 10),
        ])));
  }

  // ═══ PDF TICKET ═══
  void _descargarTicketPdf() async {
    final d = _ticketData;
    if (d == null) return;
    final numPedido = d['numero_pedido'] ?? '';
    final total = (d['total'] as num?)?.toDouble() ?? 0;
    final subtotal = (d['subtotal'] as num?)?.toDouble() ?? 0;
    final envioCosto = (d['envio_costo'] as num?)?.toDouble() ?? 0;
    final productos = (d['productos'] as List?) ?? [];

    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Center(child: pw.Text('CARGO-GO', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
        pw.Center(child: pw.Text('TICKET DE PEDIDO', style: const pw.TextStyle(fontSize: 14))),
        pw.SizedBox(height: 4),
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Text('Pedido: $numPedido', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.Text('Fecha: ${d['fecha']}', style: const pw.TextStyle(fontSize: 10)),
        pw.Text('Tel: ${d['cliente_telefono']}', style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 14),
        pw.Divider(),
        pw.Text('PRODUCTOS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.Divider(),
        pw.SizedBox(height: 6),
        ...productos.asMap().entries.map((entry) {
          final idx = entry.key + 1;
          final p = entry.value as Map<String, dynamic>;
          final pres = (p['presupuesto'] as num?)?.toDouble() ?? 0;
          return pw.Padding(padding: const pw.EdgeInsets.only(bottom: 8), child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              pw.Text('$idx. ${p['tienda'] ?? ''}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text('   ${p['producto'] ?? ''}', style: const pw.TextStyle(fontSize: 9)),
              if (pres > 0) pw.Align(alignment: pw.Alignment.centerRight,
                child: pw.Text('Presupuesto: \$${pres.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 9))),
            ]));
        }),
        pw.SizedBox(height: 10),
        pw.Divider(),
        pw.Text('RESUMEN', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.Divider(),
        pw.SizedBox(height: 6),
        if (subtotal > 0) pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Subtotal productos:', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('\$${subtotal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
        ]),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('Envío ${d['envio_tipo'] ?? ''}:', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('\$${envioCosto.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
        ]),
        pw.SizedBox(height: 6),
        pw.Divider(thickness: 2),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('TOTAL ESTIMADO:', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.Text('\$${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        ]),
        pw.SizedBox(height: 14),
        pw.Divider(),
        pw.Text('ENVÍO', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.Divider(),
        pw.Text('Tipo: ${d['envio_tipo'] ?? ''}', style: const pw.TextStyle(fontSize: 10)),
        if ((d['cliente_ciudad'] ?? '').isNotEmpty) pw.Text('Ciudad: ${d['cliente_ciudad']}', style: const pw.TextStyle(fontSize: 10)),
        pw.Text('Dirección: ${d['cliente_direccion'] ?? ''}', style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 14),
        pw.Divider(),
        pw.Text('Estado: Pendiente de pago', style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 20),
        pw.Center(child: pw.Text('Gracias por tu compra con Cargo-GO', style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic))),
        pw.Center(child: pw.Text('Tepito a tu puerta', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic))),
      ])));

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'ticket_$numPedido.pdf');
  }

  // ═══ WHATSAPP TICKET ═══
  void _enviarTicketWhatsApp() {
    final d = _ticketData;
    if (d == null) return;
    final numPedido = d['numero_pedido'] ?? '';
    final total = (d['total'] as num?)?.toDouble() ?? 0;
    final subtotal = (d['subtotal'] as num?)?.toDouble() ?? 0;
    final envioCosto = (d['envio_costo'] as num?)?.toDouble() ?? 0;
    final productos = (d['productos'] as List?) ?? [];
    final isVip = d['is_vip_mandado'] == true;

    final buf = StringBuffer();
    buf.writeln('🛒 *PEDIDO CARGO-GO*\n');
    buf.writeln('📋 Pedido: *$numPedido*');
    buf.writeln('📅 Fecha: ${d['fecha']}');
    buf.writeln('📞 Tel: ${d['cliente_telefono']}\n');
    buf.writeln('─── PRODUCTOS ───');
    for (var i = 0; i < productos.length; i++) {
      final p = productos[i] as Map<String, dynamic>;
      final pres = (p['presupuesto'] as num?)?.toDouble() ?? 0;
      buf.writeln('${i + 1}. *${p['tienda'] ?? ''}*');
      if (isVip && (p['zona_piso'] ?? '').isNotEmpty) buf.writeln('   📍 Zona: ${p['zona_piso']}');
      buf.writeln('   📦 ${p['producto'] ?? ''}');
      if (pres > 0) buf.writeln('   💵 Presupuesto: \$${pres.toStringAsFixed(2)}');
      if ((p['notas'] ?? '').isNotEmpty) buf.writeln('   📝 ${p['notas']}');
    }
    buf.writeln('\n─── RESUMEN ───');
    if (subtotal > 0) buf.writeln('Subtotal: \$${subtotal.toStringAsFixed(2)}');
    buf.writeln('Envío ${d['envio_tipo']}: \$${envioCosto.toStringAsFixed(2)}');
    buf.writeln('*TOTAL: \$${total.toStringAsFixed(2)}*\n');
    buf.writeln('🚚 Envío: ${d['envio_tipo']}');
    if ((d['cliente_ciudad'] ?? '').isNotEmpty) buf.writeln('📍 ${d['cliente_ciudad']}');
    buf.writeln('📍 ${d['cliente_direccion']}\n');
    buf.writeln('🟡 Estado: Pendiente de pago');
    buf.writeln('\n_Enviado desde Cargo-GO_');

    final url = 'https://wa.me/527753200224?text=${Uri.encodeComponent(buf.toString())}';
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

    // Update whatsapp_enviado in Firestore
    final docId = d['doc_id'];
    if (docId != null) {
      FirestoreService.addDocument('pedidos', {'whatsapp_enviado': true}).catchError((_) {});
    }
  }

  // ═══ MANDADO CART PERSISTENCE ═══
  Future<void> _loadMandadoCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('mandado_cart');
      if (cartJson != null) {
        final list = json.decode(cartJson) as List;
        if (!mounted) return;
        setState(() => _mandadoCart = list.map((e) => Map<String, dynamic>.from(e)).toList());
      }
    } catch (e) { debugPrint('[CGO] Load cart error: $e'); }
  }

  Future<void> _saveMandadoCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('mandado_cart', json.encode(_mandadoCart));
    } catch (e) { debugPrint('[CGO] Save cart error: $e'); }
  }

  void _triggerCartBounce() {
    setState(() => _cartBounce = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _cartBounce = false);
    });
  }

  // ═══ ADD TO CART MODAL ═══
  void _showAddToCartModal(Negocio n) {
    final productoCtrl = TextEditingController();
    final zonaCtrl = TextEditingController();
    final presupuestoCtrl = TextEditingController();
    final notasCtrl = TextEditingController();
    String? fotoPath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: Color(0xFF0C1221),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFFFFD700), width: 2)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Handle bar
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 12),
              // Title
              const Text('🛒 Agregar al Carrito', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFFFD700))),
              const SizedBox(height: 16),
              // Tienda (auto-filled)
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
                color: const Color(0xFF1A1400), borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3))),
                child: Row(children: [
                  Text(n.e, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('🏬 Tienda', style: TextStyle(fontSize: 9, color: Color(0xFFFFD700))),
                    Text(n.nom, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
                  ])),
                ])),
              const SizedBox(height: 12),
              // Producto
              TextField(controller: productoCtrl,
                style: const TextStyle(color: AppTheme.tx, fontSize: 13),
                decoration: InputDecoration(
                  labelText: '📦 ¿Qué producto buscas?',
                  labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 12),
                  filled: true, fillColor: AppTheme.cd,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFD700))),
                )),
              const SizedBox(height: 10),
              // Zona/Piso
              TextField(controller: zonaCtrl,
                style: const TextStyle(color: AppTheme.tx, fontSize: 13),
                decoration: InputDecoration(
                  labelText: '📍 Zona o piso (opcional)',
                  labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 12),
                  filled: true, fillColor: AppTheme.cd,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFD700))),
                )),
              const SizedBox(height: 10),
              // Presupuesto
              TextField(controller: presupuestoCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.tx, fontSize: 13),
                decoration: InputDecoration(
                  labelText: '💵 Presupuesto máximo',
                  prefixText: '\$ ', prefixStyle: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w700),
                  labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 12),
                  filled: true, fillColor: AppTheme.cd,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFD700))),
                )),
              const SizedBox(height: 10),
              // Foto referencia
              GestureDetector(
                onTap: () async {
                  try {
                    final picker = ImagePicker();
                    final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
                    if (img != null) setModalState(() => fotoPath = img.path);
                  } catch (_) {}
                },
                child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
                  color: AppTheme.cd, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: fotoPath != null ? const Color(0xFFFFD700) : AppTheme.bd)),
                  child: Row(children: [
                    Icon(fotoPath != null ? Icons.check_circle : Icons.camera_alt,
                      color: fotoPath != null ? const Color(0xFFFFD700) : AppTheme.tm, size: 20),
                    const SizedBox(width: 10),
                    Text(fotoPath != null ? '📸 Foto adjunta' : '📸 Foto de referencia (opcional)',
                      style: TextStyle(fontSize: 12, color: fotoPath != null ? const Color(0xFFFFD700) : AppTheme.tm)),
                  ]))),
              const SizedBox(height: 10),
              // Notas
              TextField(controller: notasCtrl,
                maxLines: 2,
                style: const TextStyle(color: AppTheme.tx, fontSize: 13),
                decoration: InputDecoration(
                  labelText: '📝 Notas adicionales (opcional)',
                  labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 12),
                  filled: true, fillColor: AppTheme.cd,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFD700))),
                )),
              const SizedBox(height: 18),
              // Botón agregar
              SizedBox(height: 50, child: ElevatedButton(
                onPressed: () {
                  if (productoCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Escribe qué producto buscas'), backgroundColor: AppTheme.rd));
                    return;
                  }
                  final presStr = presupuestoCtrl.text.trim().replaceAll(RegExp(r'[^0-9.]'), '');
                  final item = <String, dynamic>{
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'tienda_id': n.id,
                    'tienda_nom': n.nom,
                    'tienda_emoji': n.e,
                    'producto': productoCtrl.text.trim(),
                    'zona_piso': zonaCtrl.text.trim(),
                    'presupuesto': double.tryParse(presStr) ?? 0,
                    'foto_path': fotoPath ?? '',
                    'notas': notasCtrl.text.trim(),
                  };
                  setState(() => _mandadoCart.add(item));
                  _saveMandadoCart();
                  _triggerCartBounce();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${n.nom} agregado al carrito (${_mandadoCart.length})'),
                    backgroundColor: const Color(0xFFB8860B), duration: const Duration(seconds: 2)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700), foregroundColor: const Color(0xFF1A1400),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 4),
                child: const Text('➕ AGREGAR AL CARRITO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              )),
            ]),
          ),
        );
      }),
    );
  }

  // ═══ MANDADO CART SCREEN ═══
  Widget _mandadoCartScreen() {
    final goldColor = const Color(0xFFFFD700);
    final envioOpciones = {
      'Económico': 120.0,
      'Estándar': 250.0,
      'Express': 600.0,
    };
    final envioEmojis = {'Económico': '🐢', 'Estándar': '📦', 'Express': '⚡'};
    final subtotal = _mandadoCart.fold<double>(0, (s, i) => s + ((i['presupuesto'] as num?)?.toDouble() ?? 0));
    final envioCosto = envioOpciones[_mcEnvio] ?? 250.0;
    final total = subtotal + envioCosto;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1400),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _menuScreen = null)),
        title: Text('🛒 Mi Carrito (${_mandadoCart.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFFFFD700))),
        actions: [
          if (_mandadoCart.isNotEmpty) IconButton(
            icon: const Icon(Icons.delete_sweep, color: Color(0xFFFF4757)),
            onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(
              backgroundColor: AppTheme.sf,
              title: const Text('Vaciar carrito?', style: TextStyle(color: AppTheme.tx, fontSize: 16)),
              content: const Text('Se eliminarán todos los productos', style: TextStyle(color: AppTheme.tm, fontSize: 13)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: AppTheme.tm))),
                TextButton(onPressed: () { Navigator.pop(context); setState(() => _mandadoCart.clear()); _saveMandadoCart(); },
                  child: const Text('Vaciar', style: TextStyle(color: Color(0xFFFF4757), fontWeight: FontWeight.w700))),
              ],
            ))),
        ],
      ),
      body: _mandadoCart.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🛒', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 12),
            const Text('Tu carrito está vacío', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.tx)),
            const SizedBox(height: 6),
            const Text('Agrega productos desde las tiendas', style: TextStyle(fontSize: 12, color: AppTheme.tm)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() => _menuScreen = null),
              style: ElevatedButton.styleFrom(backgroundColor: goldColor, foregroundColor: const Color(0xFF1A1400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Ver Tiendas', style: TextStyle(fontWeight: FontWeight.w700))),
          ]))
        : ListView(padding: const EdgeInsets.all(14), children: [
            // ── CART ITEMS ──
            ...List.generate(_mandadoCart.length, (i) {
              final item = _mandadoCart[i];
              final pres = (item['presupuesto'] as num?)?.toDouble() ?? 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1400),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: goldColor.withOpacity(0.3))),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Emoji
                  Text(item['tienda_emoji'] ?? '🏪', style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  // Info
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item['tienda_nom'] ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: goldColor)),
                    const SizedBox(height: 2),
                    Text(item['producto'] ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.tx)),
                    if ((item['zona_piso'] ?? '').isNotEmpty)
                      Text('📍 ${item['zona_piso']}', style: const TextStyle(fontSize: 9, color: AppTheme.tm)),
                    if (pres > 0)
                      Text('💵 \$${pres.toStringAsFixed(2)}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: goldColor)),
                    if ((item['notas'] ?? '').isNotEmpty)
                      Text('📝 ${item['notas']}', style: const TextStyle(fontSize: 9, color: AppTheme.tm, fontStyle: FontStyle.italic)),
                  ])),
                  // Delete button
                  GestureDetector(
                    onTap: () { setState(() => _mandadoCart.removeAt(i)); _saveMandadoCart(); },
                    child: Container(width: 32, height: 32, decoration: BoxDecoration(
                      color: const Color(0xFFFF4757).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.delete, size: 16, color: Color(0xFFFF4757)))),
                ]),
              );
            }),

            const SizedBox(height: 16),
            // ── SHIPPING INFO ──
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(
              color: AppTheme.cd, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.bd)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('📍 Datos de envío', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.tx)),
                const SizedBox(height: 10),
                TextField(controller: _mcTelefono,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppTheme.tx, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: '📞 Teléfono',
                    labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 12),
                    filled: true, fillColor: AppTheme.sf,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.bd)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.bd)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: goldColor)),
                  )),
                const SizedBox(height: 8),
                TextField(controller: _mcCiudad,
                  style: const TextStyle(color: AppTheme.tx, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: '🏙️ Ciudad / Estado / CP',
                    labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 12),
                    filled: true, fillColor: AppTheme.sf,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.bd)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.bd)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: goldColor)),
                  )),
                const SizedBox(height: 8),
                TextField(controller: _mcDireccion,
                  style: const TextStyle(color: AppTheme.tx, fontSize: 13),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: '📍 Dirección completa',
                    labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 12),
                    filled: true, fillColor: AppTheme.sf,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.bd)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppTheme.bd)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: goldColor)),
                  )),
              ])),

            const SizedBox(height: 14),
            // ── ENVÍO SELECTOR ──
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(
              color: AppTheme.cd, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.bd)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('🚚 Tipo de envío', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.tx)),
                const SizedBox(height: 10),
                ...envioOpciones.entries.map((e) {
                  final selected = _mcEnvio == e.key;
                  return GestureDetector(
                    onTap: () => setState(() => _mcEnvio = e.key),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF1A1400) : AppTheme.sf,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: selected ? goldColor : AppTheme.bd, width: selected ? 2 : 1)),
                      child: Row(children: [
                        Text(envioEmojis[e.key] ?? '', style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(e.key, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: selected ? goldColor : AppTheme.tx))),
                        Text('\$${e.value.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                          color: selected ? goldColor : AppTheme.tm)),
                      ])),
                  );
                }),
              ])),

            const SizedBox(height: 14),
            // ── PAYMENT METHOD ──
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(
              color: AppTheme.cd, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.bd)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('💳 Método de pago', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.tx)),
                const SizedBox(height: 10),
                ...['Mercado Pago', 'Transferencia', 'OXXO'].map((m) {
                  final selected = _mcPago == m;
                  final emoji = m == 'Mercado Pago' ? '💙' : m == 'Transferencia' ? '🏦' : '🏪';
                  return GestureDetector(
                    onTap: () => setState(() => _mcPago = m),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF1A1400) : AppTheme.sf,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: selected ? goldColor : AppTheme.bd, width: selected ? 2 : 1)),
                      child: Row(children: [
                        Text(emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Text(m, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                          color: selected ? goldColor : AppTheme.tx)),
                        const Spacer(),
                        if (selected) Icon(Icons.check_circle, color: goldColor, size: 20),
                      ])),
                  );
                }),
              ])),

            const SizedBox(height: 14),
            // ── SUMMARY ──
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(
              color: const Color(0xFF1A1400), borderRadius: BorderRadius.circular(14),
              border: Border.all(color: goldColor.withOpacity(0.5), width: 1.5)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Subtotal productos', style: TextStyle(fontSize: 12, color: AppTheme.tm)),
                  Text('\$${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.tx)),
                ]),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Envío ${envioEmojis[_mcEnvio]} $_mcEnvio', style: const TextStyle(fontSize: 12, color: AppTheme.tm)),
                  Text('\$${envioCosto.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.tx)),
                ]),
                const SizedBox(height: 8),
                Container(height: 1.5, color: goldColor.withOpacity(0.3)),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('TOTAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: goldColor)),
                  Text('\$${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: goldColor)),
                ]),
              ])),

            const SizedBox(height: 18),
            // ── CHECKOUT BUTTON ──
            SizedBox(height: 52, child: ElevatedButton(
              onPressed: () => _generarTicketDesdeCarrito(),
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor, foregroundColor: const Color(0xFF1A1400),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 4),
              child: const Text('🎫 GENERAR TICKET Y PAGAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            )),
            const SizedBox(height: 10),
            // ── WHATSAPP BUTTON ──
            SizedBox(height: 48, child: ElevatedButton(
              onPressed: () => _enviarCarritoWhatsApp(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 4),
              child: const Text('📱 ENVIAR POR WHATSAPP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            )),
            const SizedBox(height: 30),
          ]),
    );
  }

  // ═══ CART CHECKOUT → TICKET ═══
  void _generarTicketDesdeCarrito() async {
    if (_mandadoCart.isEmpty) return;
    if (_mcTelefono.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega tu teléfono'), backgroundColor: AppTheme.rd));
      return;
    }
    if (_mcDireccion.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega tu dirección de entrega'), backgroundColor: AppTheme.rd));
      return;
    }

    // Generate order number
    String numeroPedido;
    try {
      numeroPedido = await FirestoreService.generarNumeroPedido();
    } catch (_) {
      final now = DateTime.now();
      numeroPedido = 'CG-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${(now.millisecond).toString().padLeft(3, '0')}';
    }

    final now = DateTime.now();
    final envioOpciones = {'Económico': 120.0, 'Estándar': 250.0, 'Express': 600.0};
    final subtotal = _mandadoCart.fold<double>(0, (s, i) => s + ((i['presupuesto'] as num?)?.toDouble() ?? 0));
    final envioCosto = envioOpciones[_mcEnvio] ?? 250.0;
    final total = subtotal + envioCosto;
    final fechaStr = '${now.day.toString().padLeft(2, '0')}/${_mesCorto(now.month)}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Build productos list from cart
    final productos = _mandadoCart.map((item) => <String, dynamic>{
      'tienda': item['tienda_nom'] ?? '',
      'producto': item['producto'] ?? '',
      'zona_piso': item['zona_piso'] ?? '',
      'presupuesto': (item['presupuesto'] as num?)?.toDouble() ?? 0,
      'notas': item['notas'] ?? '',
      'foto_referencia': item['foto_path'] ?? '',
    }).toList();

    final ticketInfo = <String, dynamic>{
      'numero_pedido': numeroPedido,
      'fecha': fechaStr,
      'timestamp': now.toIso8601String(),
      'cliente_nombre': '',
      'cliente_telefono': _mcTelefono.text.trim(),
      'cliente_direccion': _mcDireccion.text.trim(),
      'cliente_ciudad': _mcCiudad.text.trim(),
      'tienda_id': 'multi',
      'tienda_nombre': 'Múltiples tiendas',
      'tienda_emoji': '🛒',
      'is_vip_mandado': true,
      'productos': productos,
      'subtotal': subtotal,
      'envio_tipo': _mcEnvio,
      'envio_costo': envioCosto,
      'total': total,
      'metodo_pago': _mcPago,
      'estado': 'pendiente_pago',
      'whatsapp_enviado': false,
    };

    // Save to Firestore
    try {
      final docId = await FirestoreService.guardarPedido(ticketInfo);
      ticketInfo['doc_id'] = docId;
    } catch (_) {}

    // Clear cart after checkout
    setState(() {
      _ticketData = ticketInfo;
      _mandadoCart.clear();
      _menuScreen = 'ticket';
    });
    _saveMandadoCart();
  }

  void _enviarCarritoWhatsApp() {
    if (_mandadoCart.isEmpty) return;
    final envioOpciones = {'Económico': 120.0, 'Estándar': 250.0, 'Express': 600.0};
    final subtotal = _mandadoCart.fold<double>(0, (s, i) => s + ((i['presupuesto'] as num?)?.toDouble() ?? 0));
    final envioCosto = envioOpciones[_mcEnvio] ?? 250.0;
    final total = subtotal + envioCosto;

    final buf = StringBuffer();
    buf.writeln('🛒 *PEDIDO CARGO-GO*\n');
    buf.writeln('📞 Tel: ${_mcTelefono.text.trim()}');
    buf.writeln('📍 ${_mcCiudad.text.trim()}');
    buf.writeln('📍 ${_mcDireccion.text.trim()}\n');
    buf.writeln('─── PRODUCTOS ───');
    for (var i = 0; i < _mandadoCart.length; i++) {
      final item = _mandadoCart[i];
      final pres = (item['presupuesto'] as num?)?.toDouble() ?? 0;
      buf.writeln('${i + 1}. *${item['tienda_nom'] ?? ''}*');
      if ((item['zona_piso'] ?? '').isNotEmpty) buf.writeln('   📍 Zona: ${item['zona_piso']}');
      buf.writeln('   📦 ${item['producto'] ?? ''}');
      if (pres > 0) buf.writeln('   💵 Presupuesto: \$${pres.toStringAsFixed(2)}');
      if ((item['notas'] ?? '').isNotEmpty) buf.writeln('   📝 ${item['notas']}');
    }
    buf.writeln('\n─── RESUMEN ───');
    if (subtotal > 0) buf.writeln('Subtotal: \$${subtotal.toStringAsFixed(2)}');
    buf.writeln('Envío $_mcEnvio: \$${envioCosto.toStringAsFixed(2)}');
    buf.writeln('*TOTAL: \$${total.toStringAsFixed(2)}*\n');
    buf.writeln('💳 Pago: $_mcPago');
    buf.writeln('\n_Enviado desde Cargo-GO_');

    final url = 'https://wa.me/527753200224?text=${Uri.encodeComponent(buf.toString())}';
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
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
      floatingActionButton: _cartQty > 0 ? FloatingActionButton.extended(onPressed: _openCart, backgroundColor: const Color(0xFFE3F2FD),
        heroTag: 'farmCart',
        icon: const Icon(Icons.shopping_cart, color: Color(0xFF0D47A1), size: 18),
        label: Text('$_cartQty · \$$_cartTotal', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D47A1)))) : null,
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
      // ── Firestore Pedidos del usuario ──
      if (_firestorePedidos.isNotEmpty) ...[
        const SizedBox(height: 16),
        Row(children: [
          const Text('🔥 Mis Pedidos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.or)),
          const Spacer(),
          GestureDetector(onTap: () { _loadFirestorePedidos(); setState(() => _menuScreen = 'mis_pedidos'); },
            child: const Text('Ver todos →', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.ac))),
        ]),
        const SizedBox(height: 8),
        ..._firestorePedidos.take(5).map((p) {
          final estado = (p['estado'] ?? p['status'] ?? 'pendiente').toString();
          final folio = (p['numero_pedido'] ?? p['doc_id'] ?? '').toString();
          final total = (p['total'] as num?)?.toDouble() ?? 0;
          final ec = {'pagado': AppTheme.gr, 'entregado': AppTheme.gr, 'en_ruta': AppTheme.ac,
            'pendiente_pago': AppTheme.or, 'pendiente': AppTheme.or, 'cancelado': AppTheme.rd};
          final c = ec[estado] ?? AppTheme.tm;
          return GestureDetector(
            onTap: () => setState(() { _selectedPedido = p; _menuScreen = 'detalle_pedido'; }),
            child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.withOpacity(0.25), width: 1.2)),
              child: Row(children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(estado == 'pagado' || estado == 'entregado' ? Icons.check_circle : Icons.access_time, size: 18, color: c)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(folio.isNotEmpty ? folio : 'Pedido', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.tx)),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                      child: Text(estado.replaceAll('_', ' '), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: c))),
                  ]),
                  const SizedBox(height: 2),
                  Text('\$${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: c, fontFamily: 'monospace')),
                ])),
              ])));
        }),
      ],
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
            onPressed: () async {
              final user = AuthService.currentUser;
              if (user != null && nameCtrl.text.trim().isNotEmpty) {
                try {
                  await user.updateDisplayName(nameCtrl.text.trim());
                  await user.reload();
                } catch (e) {
                  debugPrint('[CGO] Profile update error: $e');
                }
              }
              if (!context.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Perfil actualizado', style: TextStyle(color: Colors.white)),
                backgroundColor: AppTheme.gr, duration: Duration(seconds: 2)));
              setState(() {});
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

  // ═══ AVISO DE PRIVACIDAD ═══
  Widget _avisoPrivacidadScreen() => Scaffold(backgroundColor: AppTheme.bg, body: SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.all(14), child: Row(children: [
      GestureDetector(onTap: () => setState(() => _menuScreen = null), child: Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.bd)),
        child: const Icon(Icons.arrow_back, color: AppTheme.tx, size: 18))),
      const SizedBox(width: 12),
      const Text('Aviso de Privacidad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx)),
    ])),
    Expanded(child: ListView(padding: const EdgeInsets.all(14), children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.bd)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('AVISO DE PRIVACIDAD INTEGRAL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ac)),
          const SizedBox(height: 4),
          Text('Ultima actualizacion: 13 de febrero de 2026', style: TextStyle(fontSize: 9, color: AppTheme.td)),
          const SizedBox(height: 12),
          _privText('RESPONSABLE', 'Cargo-GO y Farmacias Madrid, con domicilio en Tulancingo de Bravo, Hidalgo, Mexico, es responsable del tratamiento de sus datos personales.'),
          _privText('DATOS QUE RECABAMOS', 'Nombre completo, direccion de entrega, numero telefonico, correo electronico, ubicacion GPS (solo durante el servicio), historial de pedidos y datos de facturacion.'),
          _privText('FINALIDADES', '1. Procesar y entregar sus pedidos de medicamentos y productos.\n2. Gestionar pagos y facturacion.\n3. Enviar notificaciones sobre el estado de sus pedidos.\n4. Mejorar nuestros servicios y atencion al cliente.\n5. Cumplir con obligaciones legales y regulatorias ante COFEPRIS.'),
          _privText('PROTECCION DE DATOS DE SALUD', 'Los datos relacionados con recetas medicas y medicamentos controlados son tratados con estricta confidencialidad conforme a la Ley General de Salud y normativas de COFEPRIS.'),
          _privText('DERECHOS ARCO', 'Usted tiene derecho a Acceder, Rectificar, Cancelar u Oponerse al tratamiento de sus datos personales. Para ejercer estos derechos, contactenos por WhatsApp al 527753200224.'),
          _privText('TRANSFERENCIAS', 'Sus datos podran ser compartidos con: repartidores asignados (solo direccion de entrega), procesadores de pago (MercadoPago), y autoridades sanitarias cuando la ley lo requiera.'),
          _privText('SEGURIDAD', 'Implementamos medidas de seguridad administrativas, tecnicas y fisicas para proteger sus datos personales contra dano, perdida, alteracion o acceso no autorizado.'),
          _privText('CONTACTO', 'WhatsApp: 527753200224\nCorreo: contacto@cargo-go.com'),
        ])),
    ])),
  ])));

  Widget _privText(String title, String body) => Padding(padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tx)),
      const SizedBox(height: 4),
      Text(body, style: const TextStyle(fontSize: 10, color: AppTheme.tm, height: 1.4)),
    ]));

  // ═══ TERMINOS Y CONDICIONES ═══
  Widget _terminosScreen() => Scaffold(backgroundColor: AppTheme.bg, body: SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.all(14), child: Row(children: [
      GestureDetector(onTap: () => setState(() => _menuScreen = null), child: Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.bd)),
        child: const Icon(Icons.arrow_back, color: AppTheme.tx, size: 18))),
      const SizedBox(width: 12),
      const Expanded(child: Text('Terminos y Condiciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx))),
    ])),
    Expanded(child: ListView(padding: const EdgeInsets.all(14), children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.bd)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('TERMINOS Y CONDICIONES DE USO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.ac)),
          const SizedBox(height: 4),
          Text('Ultima actualizacion: 13 de febrero de 2026', style: TextStyle(fontSize: 9, color: AppTheme.td)),
          const SizedBox(height: 12),
          _termSection('1. SERVICIO', 'Cargo-GO es una plataforma de entregas a domicilio que incluye servicios de farmacia (Farmacias Madrid), mandados, paqueteria y mini-mudanzas en la region de Hidalgo, Mexico.'),
          _termSection('2. MEDICAMENTOS', 'Los medicamentos se venden conforme a la Ley General de Salud. Los medicamentos controlados requieren receta medica vigente. Nos reservamos el derecho de solicitar la receta al momento de la entrega.'),
          _termSection('3. PRECIOS', 'Los precios mostrados incluyen IVA. Los precios pueden cambiar sin previo aviso. El costo de envio se calcula segun la distancia y se muestra antes de confirmar el pedido.'),
          _termSection('4. PAGOS', 'Aceptamos: MercadoPago (tarjeta, OXXO, SPEI), efectivo contra entrega y coordinacion por WhatsApp. Los pagos con MercadoPago son procesados por MercadoPago S.A. de C.V.'),
          _termSection('5. ENTREGAS', 'El tiempo estimado de entrega es de 25-45 minutos para zona urbana. No garantizamos tiempos exactos. El repartidor se comunicara si hay demoras.'),
          _termSection('6. DEVOLUCIONES', 'Los medicamentos NO son sujetos a devolucion una vez entregados, salvo defectos de fabrica o error en el despacho. Para devoluciones, contactenos dentro de las 24 horas posteriores.'),
          _termSection('7. PROGRAMA DE LEALTAD', 'Los puntos "Saturnos" se acumulan con cada compra (9% del total). Los puntos no tienen valor monetario y no son transferibles.'),
          _termSection('8. CONTACTO', 'Para dudas, quejas o sugerencias:\nWhatsApp: 527753200224\nCorreo: contacto@cargo-go.com'),
        ])),
    ])),
  ])));

  Widget _termSection(String title, String body) => Padding(padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.tx)),
      const SizedBox(height: 4),
      Text(body, style: const TextStyle(fontSize: 10, color: AppTheme.tm, height: 1.4)),
    ]));

  // ═══ REPARTIDOR SCREEN ═══
  Widget _repartidorScreen() => Scaffold(backgroundColor: AppTheme.bg, body: SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.all(14), child: Row(children: [
      GestureDetector(onTap: () => setState(() => _menuScreen = null), child: Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.bd)),
        child: const Icon(Icons.arrow_back, color: AppTheme.tx, size: 18))),
      const SizedBox(width: 12),
      const Text('Modo Repartidor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx)),
      const Spacer(),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: _onlineRep ? AppTheme.gr.withOpacity(0.15) : AppTheme.rd.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: _onlineRep ? AppTheme.gr : AppTheme.rd)),
          const SizedBox(width: 4),
          Text(_onlineRep ? 'EN LINEA' : 'OFFLINE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _onlineRep ? AppTheme.gr : AppTheme.rd)),
        ])),
    ])),
    Expanded(child: Builder(builder: (_) {
      // Use API entregas if available, otherwise Firestore pedidos
      final entregas = _apiEntregas.isNotEmpty ? _apiEntregas
        : _firestorePedidos.where((p) {
            final est = (p['estado'] ?? p['status'] ?? '').toString();
            return est != 'cancelado' && est != 'entregado';
          }).toList();
      if (entregas.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🛵', style: TextStyle(fontSize: 50)),
          const SizedBox(height: 12),
          Text('No hay entregas pendientes', style: TextStyle(fontSize: 14, color: AppTheme.tm)),
          const SizedBox(height: 8),
          Text('Las entregas apareceran aqui', style: TextStyle(fontSize: 10, color: AppTheme.td)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadFirestorePedidos,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.ac, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Actualizar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
        ]));
      return ListView.builder(padding: const EdgeInsets.all(14), itemCount: entregas.length, itemBuilder: (_, i) {
          final e = entregas[i];
          final estado = (e['estado'] ?? e['status'] ?? 'pendiente').toString();
          final metodo = (e['metodo_pago'] ?? 'mercadopago').toString();
          final total = ((e['total'] ?? 0) as num).toDouble();
          final pagaCon = ((e['paga_con'] ?? 0) as num).toDouble();
          final cambio = pagaCon > 0 ? pagaCon - total : 0.0;
          final dir = (e['direccion'] ?? e['cliente_direccion'] ?? 'Sin direccion').toString();
          final payer = e['payer'] is Map ? (e['payer'] as Map) : {};
          final cliente = (e['cliente'] ?? e['cliente_nombre'] ?? payer['name'] ?? 'Cliente').toString();
          final folio = (e['folio'] ?? e['numero_pedido'] ?? e['id'] ?? e['doc_id'] ?? '').toString();
          return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.bd)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: estado == 'entregado' ? AppTheme.gr.withOpacity(0.15) : AppTheme.ac.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(estado.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: estado == 'entregado' ? AppTheme.gr : AppTheme.ac))),
                const Spacer(),
                if (folio.isNotEmpty) Text('#$folio', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.tm, fontFamily: 'monospace')),
              ]),
              const SizedBox(height: 8),
              Text(cliente, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on, size: 12, color: AppTheme.tm),
                const SizedBox(width: 4),
                Expanded(child: Text(dir, style: const TextStyle(fontSize: 9, color: AppTheme.tm))),
              ]),
              const SizedBox(height: 8),
              // Payment badge
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(
                color: metodo == 'efectivo' ? const Color(0xFFFFF3E0) : const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  Icon(metodo == 'efectivo' ? Icons.attach_money : Icons.payment, size: 16,
                    color: metodo == 'efectivo' ? const Color(0xFFE65100) : const Color(0xFF0D47A1)),
                  const SizedBox(width: 6),
                  Expanded(child: metodo == 'efectivo'
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('COBRAR \$${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFE65100))),
                        if (pagaCon > 0) Text('Paga con: \$${pagaCon.toStringAsFixed(0)} | Cambio: \$${cambio.toStringAsFixed(0)}', style: const TextStyle(fontSize: 9, color: Color(0xFFBF360C))),
                      ])
                    : Text('YA PAGADO - MercadoPago', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0D47A1)))),
                ])),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  onPressed: () { final encoded = Uri.encodeComponent(dir); launchUrl(Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$encoded'), mode: LaunchMode.externalApplication); },
                  icon: const Icon(Icons.map, size: 14, color: Colors.white),
                  label: const Text('Navegar', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF34A853), padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton.icon(
                  onPressed: estado == 'entregado' ? null : () async {
                    // Update Firestore if we have doc_id
                    final docId = (e['doc_id'] ?? '').toString();
                    if (docId.isNotEmpty) {
                      try { await FirestoreService.actualizarEstadoPedido(docId, 'entregado'); } catch (_) {}
                    }
                    setState(() { entregas[i] = {...e, 'estado': 'entregado', 'status': 'entregado'}; });
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido marcado como entregado', style: TextStyle(color: Colors.white)), backgroundColor: AppTheme.gr));
                  },
                  icon: Icon(estado == 'entregado' ? Icons.check : Icons.delivery_dining, size: 14, color: Colors.white),
                  label: Text(estado == 'entregado' ? 'Entregado' : 'Entregar', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(backgroundColor: estado == 'entregado' ? AppTheme.td : AppTheme.ac, padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))),
              ]),
            ]));
        });
      })),
  ])));

  // ═══ PERFIL ═══
  Widget _profileServiceBtn({required IconData icon, required String label, required String desc, required Color color, required VoidCallback onTap}) {
    return GestureDetector(onTap: onTap,
      child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3), width: 1.2)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: color)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.tx)),
            Text(desc, style: const TextStyle(fontSize: 8, color: AppTheme.tm)),
          ])),
          Icon(Icons.arrow_forward_ios, size: 12, color: color),
        ])));
  }

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
          if (it == 'Notificaciones') setState(() => _menuScreen = 'notificaciones');
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
    const SizedBox(height: 12),
    const Text('📦 Mis Servicios', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.tx)),
    const SizedBox(height: 8),
    GestureDetector(onTap: () { _loadFirestorePedidos(); setState(() => _menuScreen = 'mis_pedidos'); },
      child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.or.withOpacity(0.3), width: 1.2)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppTheme.or.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.receipt_long, size: 18, color: AppTheme.or)),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Mis Pedidos', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.tx)),
            Text('Historial de pedidos realizados', style: TextStyle(fontSize: 8, color: AppTheme.tm)),
          ])),
          if (_firestorePedidos.isNotEmpty) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppTheme.or.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Text('${_firestorePedidos.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.or))),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.or),
        ]))),
    // ── Historial completo ──
    _profileServiceBtn(icon: Icons.history, label: 'Historial de Pedidos', desc: 'Busca por teléfono y repite pedidos', color: AppTheme.cy,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HistorialScreen(
        onRepetir: (items, negocio) {
          for (final it in items) {
            _cart.add(CartItem(n: it['nombre'] ?? '', from: negocio, p: (it['precio'] as num?)?.toInt() ?? 0));
          }
          setState(() {});
        })))),
    // ── Cupones ──
    _profileServiceBtn(icon: Icons.local_offer, label: 'Cupones y Promos', desc: 'Descuentos y envíos gratis', color: AppTheme.yl,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CuponesScreen()))),
    // ── Referidos ──
    _profileServiceBtn(icon: Icons.card_giftcard, label: 'Invita a un amigo', desc: 'Gana envíos gratis', color: AppTheme.gr,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferidosScreen()))),
    // ── Proponer negocio ──
    _profileServiceBtn(icon: Icons.lightbulb, label: 'Propón un negocio', desc: '¿Falta tu lugar favorito?', color: AppTheme.or,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProponerNegocioScreen()))),
    // ── Franquicias ──
    _profileServiceBtn(icon: Icons.rocket_launch, label: 'Franquicias Cargo-GO', desc: 'Lleva Cargo-GO a tu ciudad', color: AppTheme.pu,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FranquiciasScreen()))),
    // ── Cotizador ──
    GestureDetector(onTap: () => setState(() => _menuScreen = 'cotizador'),
      child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.gr.withOpacity(0.3), width: 1.2)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppTheme.gr.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.calculate, size: 18, color: AppTheme.gr)),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Cotizador de Envío', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.tx)),
            Text('Calcula el costo de tu envío', style: TextStyle(fontSize: 8, color: AppTheme.tm)),
          ])),
          const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.gr),
        ]))),
    const SizedBox(height: 12),
    const Text('📋 Legal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.tx)),
    const SizedBox(height: 8),
    GestureDetector(onTap: () => setState(() => _menuScreen = 'aviso_privacidad'),
      child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.bd, width: 1.2)),
        child: const Row(children: [
          Icon(Icons.privacy_tip, size: 18, color: AppTheme.tm), SizedBox(width: 10),
          Expanded(child: Text('Aviso de Privacidad', style: TextStyle(fontSize: 11, color: AppTheme.tx))),
          Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.td),
        ]))),
    GestureDetector(onTap: () => setState(() => _menuScreen = 'terminos'),
      child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.bd, width: 1.2)),
        child: const Row(children: [
          Icon(Icons.description, size: 18, color: AppTheme.tm), SizedBox(width: 10),
          Expanded(child: Text('Terminos y Condiciones', style: TextStyle(fontSize: 11, color: AppTheme.tx))),
          Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.td),
        ]))),
    const SizedBox(height: 12),
    const Text('🛵 Repartidor', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.tx)),
    const SizedBox(height: 8),
    GestureDetector(onTap: () => setState(() => _menuScreen = 'repartidor'),
      child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.ac.withOpacity(0.3), width: 1.2)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppTheme.ac.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.delivery_dining, size: 18, color: AppTheme.ac)),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Modo Repartidor', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.tx)),
            Text('Ver entregas pendientes', style: TextStyle(fontSize: 8, color: AppTheme.tm)),
          ])),
          const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.ac),
        ]))),
  ]);

  // ═══ NOTIFICACIONES SCREEN ═══
  Widget _notificacionesScreen() => Scaffold(backgroundColor: AppTheme.bg, body: SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.all(14), child: Row(children: [
      GestureDetector(onTap: () => setState(() => _menuScreen = null), child: Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.bd)),
        child: const Icon(Icons.arrow_back, color: AppTheme.tx, size: 18))),
      const SizedBox(width: 12),
      const Expanded(child: Text('Notificaciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx))),
      GestureDetector(
        onTap: () => setState(() { for (var n in _notifs) n.read = true; }),
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: AppTheme.ac.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: const Text('Marcar leídas', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.ac)))),
    ])),
    // Stats bar
    Container(margin: const EdgeInsets.symmetric(horizontal: 14), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.bd)),
      child: Row(children: [
        _notifStatChip('Total', _notifs.length, AppTheme.ac),
        const SizedBox(width: 10),
        _notifStatChip('Sin leer', _unreadNotifs, AppTheme.or),
        const SizedBox(width: 10),
        _notifStatChip('Leídas', _notifs.length - _unreadNotifs, AppTheme.gr),
      ])),
    const SizedBox(height: 10),
    Expanded(child: _notifs.isEmpty
      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Text('🔔', style: TextStyle(fontSize: 50)),
          SizedBox(height: 12),
          Text('Sin notificaciones', style: TextStyle(fontSize: 14, color: AppTheme.tm)),
          SizedBox(height: 6),
          Text('Aquí aparecerán las actualizaciones de tus pedidos', style: TextStyle(fontSize: 11, color: AppTheme.td)),
        ]))
      : ListView.builder(padding: const EdgeInsets.all(14), itemCount: _notifs.length, itemBuilder: (_, i) {
          final n = _notifs[i];
          final icons = {'Pedido': Icons.local_shipping, 'Oferta': Icons.local_offer, 'Nuevo': Icons.store};
          final colors = {'Pedido': AppTheme.ac, 'Oferta': AppTheme.gr, 'Nuevo': AppTheme.pu};
          final key = n.t.split(' ').first;
          final ic = icons[key] ?? Icons.notifications;
          final cl = colors[key] ?? AppTheme.or;
          return GestureDetector(
            onTap: () => setState(() => n.read = true),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: n.read ? Colors.transparent : cl.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: n.read ? AppTheme.bd : cl.withOpacity(0.3), width: 1.2)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: cl.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(ic, size: 20, color: cl)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(n.t, style: TextStyle(fontSize: 12, fontWeight: n.read ? FontWeight.w500 : FontWeight.w700, color: AppTheme.tx))),
                    if (!n.read) Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: cl)),
                  ]),
                  const SizedBox(height: 4),
                  Text(n.d, style: const TextStyle(fontSize: 10, color: AppTheme.tm, height: 1.3)),
                  const SizedBox(height: 4),
                  Text(n.time, style: const TextStyle(fontSize: 9, color: AppTheme.td)),
                ])),
              ])));
        })),
  ])));

  Widget _notifStatChip(String label, int count, Color c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Text('$count', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c)),
      Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.tm)),
    ])));

  // ═══ MIS PEDIDOS SCREEN ═══
  Widget _misPedidosScreen() => Scaffold(backgroundColor: AppTheme.bg, body: SafeArea(child: Column(children: [
    Padding(padding: const EdgeInsets.all(14), child: Row(children: [
      GestureDetector(onTap: () => setState(() => _menuScreen = null), child: Container(padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.bd)),
        child: const Icon(Icons.arrow_back, color: AppTheme.tx, size: 18))),
      const SizedBox(width: 12),
      const Expanded(child: Text('Mis Pedidos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx))),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppTheme.or.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Text('${_firestorePedidos.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.or))),
    ])),
    if (_loadingFsPedidos) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: AppTheme.ac))),
    Expanded(child: _firestorePedidos.isEmpty && !_loadingFsPedidos
      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('📦', style: TextStyle(fontSize: 50)),
          const SizedBox(height: 12),
          const Text('No tienes pedidos aún', style: TextStyle(fontSize: 14, color: AppTheme.tm)),
          const SizedBox(height: 6),
          const Text('Tus pedidos aparecerán aquí', style: TextStyle(fontSize: 11, color: AppTheme.td)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => setState(() { _menuScreen = null; _tab = 2; }),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Hacer un pedido', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.ac, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
        ]))
      : RefreshIndicator(onRefresh: _loadFirestorePedidos, color: AppTheme.ac,
        child: ListView.builder(padding: const EdgeInsets.all(14), itemCount: _firestorePedidos.length, itemBuilder: (_, i) {
          final p = _firestorePedidos[i];
          final estado = (p['estado'] ?? p['status'] ?? 'pendiente').toString();
          final folio = (p['numero_pedido'] ?? p['doc_id'] ?? '').toString();
          final total = (p['total'] as num?)?.toDouble() ?? 0;
          final fecha = p['timestamp'] != null ? _formatTimestamp(p['timestamp']) : (p['fecha'] ?? '');
          final items = p['items'] is List ? (p['items'] as List) : [];
          final estadoColor = {'pagado': AppTheme.gr, 'entregado': AppTheme.gr, 'en_ruta': AppTheme.ac,
            'pendiente_pago': AppTheme.or, 'pendiente': AppTheme.or, 'cancelado': AppTheme.rd};
          final c = estadoColor[estado] ?? AppTheme.tm;
          final estadoIcon = {'pagado': Icons.check_circle, 'entregado': Icons.check_circle, 'en_ruta': Icons.local_shipping,
            'pendiente_pago': Icons.access_time, 'pendiente': Icons.access_time, 'cancelado': Icons.cancel};
          final ic = estadoIcon[estado] ?? Icons.receipt;
          return GestureDetector(
            onTap: () => setState(() { _selectedPedido = p; _menuScreen = 'detalle_pedido'; }),
            child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.withOpacity(0.3), width: 1.2)),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(ic, size: 22, color: c)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(folio.isNotEmpty ? folio : 'Pedido #${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.tx))),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      child: Text(estado.replaceAll('_', ' ').toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: c))),
                  ]),
                  const SizedBox(height: 4),
                  if (items.isNotEmpty) Text('${items.length} producto${items.length > 1 ? "s" : ""}', style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(fecha.toString(), style: const TextStyle(fontSize: 9, color: AppTheme.td)),
                    Text('\$${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: c, fontFamily: 'monospace')),
                  ]),
                ])),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.td),
              ])));
        }))),
  ])));

  String _formatTimestamp(dynamic ts) {
    try {
      if (ts is Map && ts['_seconds'] != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch((ts['_seconds'] as int) * 1000);
        return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
      }
      return ts.toString();
    } catch (_) { return ''; }
  }

  // ═══ DETALLE PEDIDO SCREEN ═══
  Widget _detallePedidoScreen() {
    final p = _selectedPedido;
    if (p == null) return Scaffold(backgroundColor: AppTheme.bg, body: Center(child:
      TextButton(onPressed: () => setState(() => _menuScreen = null),
        child: const Text('Sin datos', style: TextStyle(color: AppTheme.tx)))));
    final estado = (p['estado'] ?? p['status'] ?? 'pendiente').toString();
    final folio = (p['numero_pedido'] ?? p['doc_id'] ?? '').toString();
    final total = (p['total'] as num?)?.toDouble() ?? 0;
    final envio = (p['envio'] as num?)?.toDouble() ?? (p['envio_costo'] as num?)?.toDouble() ?? 0;
    final subtotal = total - envio;
    final fecha = p['timestamp'] != null ? _formatTimestamp(p['timestamp']) : (p['fecha'] ?? (p['created_at'] != null ? _formatTimestamp(p['created_at']) : ''));
    final items = p['items'] is List ? (p['items'] as List) : [];
    final payer = p['payer'] is Map ? (p['payer'] as Map) : {};
    final dir = (p['cliente_direccion'] ?? p['direccion'] ?? '').toString();
    final tel = (p['cliente_telefono'] ?? payer['phone'] ?? '').toString();
    final nombre = (p['cliente_nombre'] ?? payer['name'] ?? '').toString();
    final mpStatus = (p['mercadopago_status'] ?? '').toString();
    final mpMethod = (p['mercadopago_payment_method'] ?? '').toString();
    final estadoColor = {'pagado': AppTheme.gr, 'entregado': AppTheme.gr, 'en_ruta': AppTheme.ac,
      'pendiente_pago': AppTheme.or, 'pendiente': AppTheme.or, 'cancelado': AppTheme.rd};
    final c = estadoColor[estado] ?? AppTheme.tm;

    return Scaffold(backgroundColor: AppTheme.bg, body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.all(14), child: Row(children: [
        GestureDetector(onTap: () => setState(() { _menuScreen = 'mis_pedidos'; _selectedPedido = null; }),
          child: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.bd)),
            child: const Icon(Icons.arrow_back, color: AppTheme.tx, size: 18))),
        const SizedBox(width: 12),
        Expanded(child: Text(folio.isNotEmpty ? folio : 'Detalle Pedido', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx))),
      ])),
      Expanded(child: ListView(padding: const EdgeInsets.all(14), children: [
        // Estado banner
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c, c.withOpacity(0.7)]),
            borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Icon(estado == 'pagado' || estado == 'entregado' ? Icons.check_circle : estado == 'en_ruta' ? Icons.local_shipping : estado == 'cancelado' ? Icons.cancel : Icons.access_time,
              size: 36, color: Colors.white),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(estado.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
              if (fecha.toString().isNotEmpty) Text(fecha.toString(), style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ])),
          ])),
        const SizedBox(height: 14),

        // Items
        if (items.isNotEmpty) ...[
          _detSecTitle('Productos'),
          ...items.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final item = entry.value is Map ? entry.value as Map : {};
            final title = (item['title'] ?? item['producto'] ?? item['nombre'] ?? 'Item').toString();
            final qty = (item['quantity'] ?? item['cantidad'] ?? 1);
            final price = (item['unit_price'] ?? item['precio'] ?? 0);
            return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.bd)),
              child: Row(children: [
                Container(width: 28, height: 28, decoration: BoxDecoration(color: AppTheme.ac.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text('$idx', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.ac)))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.tx)),
                  Text('Cant: $qty', style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
                ])),
                Text('\$${(price is num ? price.toDouble() : 0.0).toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.gr, fontFamily: 'monospace')),
              ]));
          }),
          const SizedBox(height: 8),
        ],

        // Totales
        _detSecTitle('Resumen'),
        Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.bd)),
          child: Column(children: [
            if (subtotal > 0) _detMoneyRow('Subtotal', subtotal),
            if (envio > 0) _detMoneyRow('Envío', envio),
            Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 8), color: AppTheme.bd),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('TOTAL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.tx)),
              Text('\$${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: c, fontFamily: 'monospace')),
            ]),
          ])),
        const SizedBox(height: 14),

        // Info cliente
        if (nombre.isNotEmpty || tel.isNotEmpty || dir.isNotEmpty) ...[
          _detSecTitle('Datos de Envío'),
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.bd)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (nombre.isNotEmpty) _detInfoRow(Icons.person, 'Cliente', nombre),
              if (tel.isNotEmpty) _detInfoRow(Icons.phone, 'Teléfono', tel),
              if (dir.isNotEmpty) _detInfoRow(Icons.location_on, 'Dirección', dir),
            ])),
          const SizedBox(height: 14),
        ],

        // Pago
        if (mpStatus.isNotEmpty || mpMethod.isNotEmpty) ...[
          _detSecTitle('Pago'),
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.bd)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (mpStatus.isNotEmpty) _detInfoRow(Icons.payment, 'Estado MP', mpStatus),
              if (mpMethod.isNotEmpty) _detInfoRow(Icons.credit_card, 'Método', mpMethod),
            ])),
          const SizedBox(height: 14),
        ],

        // Acciones
        Row(children: [
          Expanded(child: ElevatedButton.icon(
            onPressed: () {
              final msg = 'Hola, consulto sobre mi pedido $folio';
              launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent(msg)}'), mode: LaunchMode.externalApplication);
            },
            icon: const Icon(Icons.chat, size: 16, color: Colors.white),
            label: const Text('Soporte', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton.icon(
            onPressed: estado == 'pendiente_pago' ? () async {
              final ok = await MercadoPagoService.pagarPedido(folio: folio, tipo: 'pedido', total: total);
              if (ok && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Redirigiendo a MercadoPago...'), backgroundColor: AppTheme.ac));
            } : null,
            icon: Icon(estado == 'pendiente_pago' ? Icons.payment : Icons.check, size: 16, color: Colors.white),
            label: Text(estado == 'pendiente_pago' ? 'Pagar' : estado.replaceAll('_', ' '),
              style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(backgroundColor: estado == 'pendiente_pago' ? AppTheme.ac : AppTheme.td,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
        ]),
        const SizedBox(height: 20),
      ])),
    ])));
  }

  Widget _detSecTitle(String t) => Padding(padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)));

  Widget _detMoneyRow(String label, double amount) => Padding(padding: const EdgeInsets.only(bottom: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.tm)),
      Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppTheme.tx, fontFamily: 'monospace')),
    ]));

  Widget _detInfoRow(IconData ic, String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(ic, size: 16, color: AppTheme.ac),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.td)),
        Text(value, style: const TextStyle(fontSize: 12, color: AppTheme.tx)),
      ])),
    ]));

  // ═══ COTIZADOR DE ENVÍO SCREEN ═══
  Widget _cotizadorScreen() {
    final tipoInfo = {
      'paquete': {'icon': '📦', 'nom': 'Paquete', 'desc': 'Cajas, sobres, productos', 'base': 89, 'kg': 12},
      'sobre': {'icon': '✉️', 'nom': 'Sobre / Documento', 'desc': 'Documentos, cartas', 'base': 49, 'kg': 5},
      'mudanza': {'icon': '🚛', 'nom': 'Mini Mudanza', 'desc': 'Muebles, cajas grandes', 'base': 350, 'kg': 25},
      'comida': {'icon': '🍲', 'nom': 'Delivery Comida', 'desc': 'Restaurantes y alimentos', 'base': 39, 'kg': 8},
      'farmacia': {'icon': '💊', 'nom': 'Farmacia', 'desc': 'Medicamentos y salud', 'base': 49, 'kg': 5},
    };

    return Scaffold(backgroundColor: AppTheme.bg, body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.all(14), child: Row(children: [
        GestureDetector(onTap: () => setState(() { _menuScreen = null; _cotResultado = null; }),
          child: Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.bd)),
            child: const Icon(Icons.arrow_back, color: AppTheme.tx, size: 18))),
        const SizedBox(width: 12),
        const Expanded(child: Text('Cotizador de Envío', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx))),
      ])),
      Expanded(child: ListView(padding: const EdgeInsets.all(14), children: [
        // Header
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0D47A1), Color(0xFF1565C0)]),
            borderRadius: BorderRadius.circular(16)),
          child: const Column(children: [
            Icon(Icons.calculate, size: 40, color: Colors.white),
            SizedBox(height: 8),
            Text('Calcula tu envío', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
            SizedBox(height: 4),
            Text('CDMX ↔ Hidalgo · Envíos locales', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ])),
        const SizedBox(height: 16),

        // Tipo de envío
        const Text('Tipo de envío', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: tipoInfo.entries.map((e) {
          final sel = _cotTipo == e.key;
          return GestureDetector(
            onTap: () => setState(() => _cotTipo = e.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: sel ? AppTheme.ac.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? AppTheme.ac : AppTheme.bd, width: sel ? 1.5 : 1)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('${e.value['icon']}', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${e.value['nom']}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? AppTheme.ac : AppTheme.tx)),
                  Text('${e.value['desc']}', style: const TextStyle(fontSize: 8, color: AppTheme.tm)),
                ]),
              ])),
          );
        }).toList()),
        const SizedBox(height: 14),

        // Origen
        TextField(controller: _cotOrigen, style: const TextStyle(color: AppTheme.tx, fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Origen (colonia, ciudad)', labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 12),
            prefixIcon: const Icon(Icons.my_location, size: 18, color: AppTheme.gr),
            filled: false,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.bd)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.ac, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12))),
        const SizedBox(height: 10),

        // Destino
        TextField(controller: _cotDestino, style: const TextStyle(color: AppTheme.tx, fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Destino (colonia, ciudad)', labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 12),
            prefixIcon: const Icon(Icons.location_on, size: 18, color: AppTheme.rd),
            filled: false,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.bd)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.ac, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12))),
        const SizedBox(height: 10),

        // Peso
        if (_cotTipo == 'paquete' || _cotTipo == 'mudanza')
          TextField(controller: _cotPeso, keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.tx, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Peso aproximado (kg)', labelStyle: const TextStyle(color: AppTheme.tm, fontSize: 12),
              prefixIcon: const Icon(Icons.scale, size: 18, color: AppTheme.or),
              filled: false,
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.bd)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.ac, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12))),
        const SizedBox(height: 16),

        // Botón cotizar
        GestureDetector(
          onTap: () {
            if (_cotOrigen.text.trim().isEmpty || _cotDestino.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa origen y destino'), backgroundColor: AppTheme.rd));
              return;
            }
            final info = tipoInfo[_cotTipo]!;
            final basePrice = (info['base'] as int).toDouble();
            final pesoKg = double.tryParse(_cotPeso.text) ?? 1.0;
            final pricePerKg = (info['kg'] as int).toDouble();
            // Distancia estimada
            final orLower = _cotOrigen.text.toLowerCase();
            final deLower = _cotDestino.text.toLowerCase();
            final isCiudad = (orLower.contains('cdmx') || orLower.contains('ciudad de') || orLower.contains('mexico')) !=
                              (deLower.contains('cdmx') || deLower.contains('ciudad de') || deLower.contains('mexico'));
            final distMultiplier = isCiudad ? 2.5 : 1.0; // interurbano vs local
            final costoEnvio = basePrice * distMultiplier + (pesoKg > 1 ? (pesoKg - 1) * pricePerKg : 0);
            final tiempoEst = isCiudad ? '2-4 horas' : '25-45 min';
            setState(() => _cotResultado = {
              'tipo': info['nom'],
              'icon': info['icon'],
              'origen': _cotOrigen.text,
              'destino': _cotDestino.text,
              'peso': pesoKg,
              'costo': costoEnvio,
              'tiempo': tiempoEst,
              'distancia': isCiudad ? 'Interurbano' : 'Local',
            });
          },
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2D7AFF), Color(0xFF1565C0)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: AppTheme.ac.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.calculate, size: 20, color: Colors.white),
              SizedBox(width: 8),
              Text('Cotizar Envío', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            ]))),
        const SizedBox(height: 16),

        // Resultado
        if (_cotResultado != null) ...[
          Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cd,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.gr.withOpacity(0.3), width: 1.5)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('${_cotResultado!['icon']} ', style: const TextStyle(fontSize: 24)),
                const Text('Cotización', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.tx)),
                const Spacer(),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.gr.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text('${_cotResultado!['distancia']}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.gr))),
              ]),
              const SizedBox(height: 12),
              _cotRow('📍', 'Origen', '${_cotResultado!['origen']}'),
              _cotRow('📍', 'Destino', '${_cotResultado!['destino']}'),
              _cotRow('📦', 'Tipo', '${_cotResultado!['tipo']}'),
              _cotRow('⏱️', 'Tiempo est.', '${_cotResultado!['tiempo']}'),
              if ((_cotResultado!['peso'] as double) > 1) _cotRow('⚖️', 'Peso', '${(_cotResultado!['peso'] as double).toStringAsFixed(1)} kg'),
              Container(height: 1.5, margin: const EdgeInsets.symmetric(vertical: 10), color: AppTheme.bd),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('COSTO ESTIMADO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.tx)),
                Text('\$${(_cotResultado!['costo'] as double).toStringAsFixed(0)} MXN',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.gr, fontFamily: 'monospace')),
              ]),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  final msg = '📦 *COTIZACIÓN CARGO-GO*\n\n'
                    'Tipo: ${_cotResultado!['tipo']}\n'
                    'Origen: ${_cotResultado!['origen']}\n'
                    'Destino: ${_cotResultado!['destino']}\n'
                    'Costo est: \$${(_cotResultado!['costo'] as double).toStringAsFixed(0)} MXN\n\n'
                    'Quiero confirmar este envío';
                  launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent(msg)}'), mode: LaunchMode.externalApplication);
                },
                child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF25D366), Color(0xFF128C7E)]),
                    borderRadius: BorderRadius.circular(12)),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.chat, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Confirmar por WhatsApp', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]))),
            ])),
        ],

        // Tabla de precios referencia
        const SizedBox(height: 16),
        const Text('Precios de referencia', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.bd)),
          child: Column(children: [
            _cotPrecioRef('✉️ Sobre / Documento', '\$49', 'Local'),
            _cotPrecioRef('📦 Paquete (hasta 5kg)', '\$89', 'Local'),
            _cotPrecioRef('📦 Paquete interurbano', '\$222', 'CDMX↔Hidalgo'),
            _cotPrecioRef('🍲 Delivery comida', '\$39', 'Local'),
            _cotPrecioRef('💊 Farmacia', '\$49', 'Local'),
            _cotPrecioRef('🚛 Mini Mudanza', '\$350', 'Local'),
            _cotPrecioRef('🚛 Mudanza interurbana', '\$875', 'CDMX↔Hidalgo'),
          ])),
        const SizedBox(height: 20),
      ])),
    ])));
  }

  Widget _cotRow(String emoji, String label, String value) => Padding(padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      const SizedBox(width: 8),
      Text('$label: ', style: const TextStyle(fontSize: 11, color: AppTheme.td)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 11, color: AppTheme.tx, fontWeight: FontWeight.w600))),
    ]));

  Widget _cotPrecioRef(String servicio, String precio, String zona) => Padding(padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Expanded(child: Text(servicio, style: const TextStyle(fontSize: 11, color: AppTheme.tx))),
      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: AppTheme.ac.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
        child: Text(zona, style: const TextStyle(fontSize: 8, color: AppTheme.ac))),
      const SizedBox(width: 8),
      Text(precio, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.gr, fontFamily: 'monospace')),
    ]));

  // ═══════════════════════════════════════════════════════
  // ═══ SUDO PREMIUM SCREENS ═══
  // ═══════════════════════════════════════════════════════

  static const _sudoGiros = <String, String>{
    'restaurant': '🍽️ Restaurant / Cocina',
    'farmacia': '💊 Farmacia / Salud',
    'tienda_ropa': '👕 Tienda de Ropa',
    'abarrotes': '🏪 Abarrotes / Miscelánea',
    'taller': '🔧 Taller / Servicio',
    'belleza': '💇 Belleza / Estética',
    'tecnologia': '💻 Tecnología',
    'papeleria': '📚 Papelería / Regalos',
    'panaderia': '🥖 Panadería / Repostería',
    'ferreteria': '🔨 Ferretería',
    'veterinaria': '🐾 Veterinaria',
    'otro': '📦 Otro',
  };

  Widget _sudoBack() => GestureDetector(
    onTap: () => setState(() => _menuScreen = null),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppTheme.sf, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.bd)),
      child: Row(mainAxisSize: MainAxisSize.min, children: const [
        Icon(Icons.arrow_back_ios, size: 12, color: AppTheme.tm),
        SizedBox(width: 4),
        Text('Inicio', style: TextStyle(fontSize: 11, color: AppTheme.tm, fontWeight: FontWeight.w500)),
      ]),
    ),
  );

  // ── SUDO LANDING ──
  Widget _sudoLandingScreen() {
    final examples = [
      {'emoji': '🍽️', 'name': 'Restaurant', 'color': const Color(0xFFFF7043)},
      {'emoji': '💊', 'name': 'Farmacia', 'color': const Color(0xFF42A5F5)},
      {'emoji': '👕', 'name': 'Ropa', 'color': const Color(0xFFAB47BC)},
      {'emoji': '🔧', 'name': 'Taller', 'color': const Color(0xFFEF5350)},
      {'emoji': '💇', 'name': 'Estética', 'color': const Color(0xFFEC407A)},
      {'emoji': '🏪', 'name': 'Abarrotes', 'color': const Color(0xFF66BB6A)},
      {'emoji': '🥖', 'name': 'Panadería', 'color': const Color(0xFFFFCA28)},
      {'emoji': '💻', 'name': 'Tech', 'color': const Color(0xFF29B6F6)},
      {'emoji': '🐾', 'name': 'Veterinaria', 'color': const Color(0xFF8D6E63)},
      {'emoji': '📚', 'name': 'Papelería', 'color': const Color(0xFF7E57C2)},
      {'emoji': '🔨', 'name': 'Ferretería', 'color': const Color(0xFFFF8A65)},
      {'emoji': '📦', 'name': 'Tu Negocio', 'color': const Color(0xFF00E676)},
    ];
    return Container(color: AppTheme.bg, child: ListView(padding: const EdgeInsets.all(16), children: [
      // Top bar
      Row(children: [_sudoBack(), const Spacer(),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFF00E676).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.verified, size: 14, color: Color(0xFF00E676)),
            SizedBox(width: 4),
            Text('SUDO', style: TextStyle(fontSize: 11, color: Color(0xFF00E676), fontWeight: FontWeight.w800, letterSpacing: 2)),
          ])),
      ]),
      const SizedBox(height: 20),
      // Hero banner
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [Color(0xFF00382A), Color(0xFF001A10)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
          boxShadow: [BoxShadow(color: const Color(0xFF00E676).withOpacity(0.1), blurRadius: 30)],
        ),
        child: Column(children: [
          Container(width: 70, height: 70,
            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00E676).withOpacity(0.15),
              border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3), width: 2)),
            child: const Center(child: Text('🚀', style: TextStyle(fontSize: 32)))),
          const SizedBox(height: 16),
          const Text('¿Tienes un negocio?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF00E676))),
          const SizedBox(height: 6),
          const Text('SUDO te arma tu tienda\ndigital completa', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, color: AppTheme.tx, height: 1.5)),
          const SizedBox(height: 12),
          const Text('Dentro de Cargo-GO, miles de clientes\nte encuentran y te piden con delivery incluido.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppTheme.tm, height: 1.6)),
        ]),
      ),
      const SizedBox(height: 20),
      // Examples grid
      const Text('Tu negocio, cualquier giro', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.tx)),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8,
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        children: examples.map((e) => Container(
          decoration: BoxDecoration(
            color: (e['color'] as Color).withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: (e['color'] as Color).withOpacity(0.2)),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(e['emoji'] as String, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(e['name'] as String, style: TextStyle(fontSize: 9, color: e['color'] as Color, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ]),
        )).toList(),
      ),
      const SizedBox(height: 20),
      // What you get
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.bd)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Lo que incluye SUDO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          const SizedBox(height: 12),
          ...[
            ['🏪', 'Tu tienda digital con tu marca'],
            ['📸', 'Catálogo de productos con fotos'],
            ['🛒', 'Pedidos directos con Cargo-GO delivery'],
            ['🔒', 'Datos de clientes 100% anónimos'],
            ['📊', 'Dashboard de ventas y métricas'],
            ['⭐', 'Sistema de ratings y reseñas'],
            ['📱', 'Notificaciones de nuevos pedidos'],
            ['🎨', 'Personalización completa (colores, logo)'],
          ].map((f) => Padding(padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Text(f[0], style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Expanded(child: Text(f[1], style: const TextStyle(fontSize: 12, color: AppTheme.tm))),
            ]))),
        ]),
      ),
      const SizedBox(height: 20),
      // Pricing
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [const Color(0xFF00E676).withOpacity(0.06), AppTheme.cd], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
        ),
        child: Column(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF00E676).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: const Text('OFERTA DE LANZAMIENTO', style: TextStyle(fontSize: 10, color: Color(0xFF00E676), fontWeight: FontWeight.w800, letterSpacing: 1))),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: const [
            Text('\$1,500', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF00E676))),
            Padding(padding: EdgeInsets.only(bottom: 6), child: Text('/mes', style: TextStyle(fontSize: 14, color: AppTheme.tm))),
          ]),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFFFD600).withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: const Text('🎉 3 MESES GRATIS al activar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFFFD600)))),
          const SizedBox(height: 12),
          const Text('Sin permanencia · Cancela cuando quieras', style: TextStyle(fontSize: 10, color: AppTheme.td)),
        ]),
      ),
      const SizedBox(height: 20),
      // Security badge
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.bd)),
        child: Row(children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(color: AppTheme.ac.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Icon(Icons.shield, color: AppTheme.ac, size: 20))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Seguridad empresarial', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.tx)),
            SizedBox(height: 2),
            Text('HTTPS · Tokens 24h · Rate limiting · Anti-XSS', style: TextStyle(fontSize: 9, color: AppTheme.td)),
          ])),
        ]),
      ),
      const SizedBox(height: 24),
      // CTA Button
      GestureDetector(
        onTap: () => setState(() => _menuScreen = 'sudo_registro'),
        child: Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00C853)]),
            boxShadow: [BoxShadow(color: const Color(0xFF00E676).withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: const Center(child: Text('Activar SUDO Premium', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF003300), letterSpacing: 1))),
        ),
      ),
      const SizedBox(height: 30),
    ]));
  }

  // ── SUDO REGISTRO ──
  Widget _sudoRegistroScreen() {
    final giroIcon = _sudoGiros[_sudoGiro]?.split(' ').first ?? '📦';
    return Container(color: AppTheme.bg, child: Column(children: [
      // Top bar
      Container(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(color: AppTheme.sf, border: Border(bottom: BorderSide(color: AppTheme.bd))),
        child: Row(children: [
          GestureDetector(onTap: () => setState(() => _menuScreen = 'sudo'),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.arrow_back_ios, size: 14, color: AppTheme.tm), SizedBox(width: 4),
              Text('SUDO', style: TextStyle(fontSize: 12, color: AppTheme.tm)),
            ])),
          const Spacer(),
          const Text('Registrar Negocio', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          const Spacer(), const SizedBox(width: 50),
        ])),
      // Form
      Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
        // Logo preview
        Center(child: GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 80);
            if (img != null) setState(() => _sudoLogoPath = img.path);
          },
          child: Container(width: 90, height: 90,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _sudoColor.withOpacity(0.12),
              border: Border.all(color: _sudoColor.withOpacity(0.4), width: 2)),
            child: _sudoLogoPath != null
              ? const Center(child: Icon(Icons.check_circle, color: Color(0xFF00E676), size: 30))
              : Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_a_photo, color: _sudoColor, size: 24),
                  const SizedBox(height: 2),
                  Text('Logo', style: TextStyle(fontSize: 9, color: _sudoColor)),
                ])),
          ),
        )),
        const SizedBox(height: 20),
        // Name
        _sudoField('Nombre del negocio', _sudoNombre, Icons.store, 'Ej: Tacos Don Pepe'),
        const SizedBox(height: 14),
        // Description
        _sudoField('Descripción corta', _sudoDesc, Icons.description, 'Ej: Los mejores tacos de Tulancingo'),
        const SizedBox(height: 14),
        // Giro dropdown
        const Text('Giro del negocio', style: TextStyle(fontSize: 11, color: AppTheme.tm, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.bd)),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value: _sudoGiro, isExpanded: true, dropdownColor: AppTheme.cd,
            style: const TextStyle(fontSize: 13, color: AppTheme.tx),
            items: _sudoGiros.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: (v) { if (v != null) setState(() => _sudoGiro = v); },
          )),
        ),
        const SizedBox(height: 14),
        // Address
        _sudoField('Dirección', _sudoDir, Icons.location_on, 'Calle, número, colonia'),
        const SizedBox(height: 14),
        // Phone (admin only)
        _sudoField('Teléfono (solo admin)', _sudoTel, Icons.phone, '775 XXX XXXX', isPhone: true),
        const SizedBox(height: 4),
        const Text('  Este dato NUNCA es visible para clientes', style: TextStyle(fontSize: 9, color: AppTheme.rd, fontStyle: FontStyle.italic)),
        const SizedBox(height: 14),
        // Hours
        _sudoField('Horario', _sudoHorario, Icons.schedule, 'Ej: Lun-Sáb 8:00-20:00'),
        const SizedBox(height: 14),
        // Color picker
        const Text('Color de marca', style: TextStyle(fontSize: 11, color: AppTheme.tm, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          const Color(0xFF2D7AFF), const Color(0xFFFF4757), const Color(0xFF00D68F), const Color(0xFFFFA502),
          const Color(0xFF7C5CFC), const Color(0xFFFF6B9D), const Color(0xFF00BCD4), const Color(0xFFFF7043),
          const Color(0xFFE040FB), const Color(0xFFD4AF37), const Color(0xFF009688), const Color(0xFFE53935),
        ].map((c) => GestureDetector(
          onTap: () => setState(() => _sudoColor = c),
          child: Container(width: 36, height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c,
              border: Border.all(color: _sudoColor == c ? Colors.white : Colors.transparent, width: 2),
              boxShadow: _sudoColor == c ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 10)] : null)),
        )).toList()),
        const SizedBox(height: 20),
        // Products section
        Row(children: [
          const Text('Catálogo de productos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          const Spacer(),
          GestureDetector(
            onTap: _sudoAddProduct,
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF00E676).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add, size: 14, color: Color(0xFF00E676)),
                SizedBox(width: 4),
                Text('Agregar', style: TextStyle(fontSize: 11, color: Color(0xFF00E676), fontWeight: FontWeight.w600)),
              ])),
          ),
        ]),
        const SizedBox(height: 10),
        if (_sudoProductos.isEmpty)
          Container(padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.bd)),
            child: Column(children: const [
              Icon(Icons.inventory_2_outlined, size: 36, color: AppTheme.td),
              SizedBox(height: 8),
              Text('Agrega tus productos', style: TextStyle(fontSize: 12, color: AppTheme.td)),
              Text('Nombre, precio y foto de cada uno', style: TextStyle(fontSize: 10, color: AppTheme.td)),
            ])),
        ..._sudoProductos.asMap().entries.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.bd)),
          child: Row(children: [
            Container(width: 44, height: 44,
              decoration: BoxDecoration(color: _sudoColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(giroIcon, style: const TextStyle(fontSize: 20)))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.value['nombre'] ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.tx)),
              if (e.value['descripcion'] != null && (e.value['descripcion'] as String).isNotEmpty)
                Text(e.value['descripcion'], style: const TextStyle(fontSize: 10, color: AppTheme.td)),
            ])),
            Text('\$${e.value['precio']}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _sudoColor)),
            const SizedBox(width: 8),
            GestureDetector(onTap: () => setState(() => _sudoProductos.removeAt(e.key)),
              child: const Icon(Icons.close, size: 16, color: AppTheme.rd)),
          ]),
        )),
        const SizedBox(height: 24),
        // Submit button
        GestureDetector(
          onTap: _sudoGuardando ? null : _sudoSubmit,
          child: Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: _sudoGuardando ? null : const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00C853)]),
              color: _sudoGuardando ? AppTheme.cd : null,
            ),
            child: Center(child: _sudoGuardando
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00E676)))
              : const Text('Crear Mi Tienda SUDO', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF003300), letterSpacing: 1))),
          ),
        ),
        const SizedBox(height: 30),
      ])),
    ]));
  }

  Widget _sudoField(String label, TextEditingController ctrl, IconData icon, String hint, {bool isPhone = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.tm, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.bd)),
        child: TextField(
          controller: ctrl,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          style: const TextStyle(fontSize: 13, color: AppTheme.tx),
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(color: AppTheme.td, fontSize: 12),
            prefixIcon: Icon(icon, size: 18, color: AppTheme.tm),
            border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ),
    ]);
  }

  void _sudoAddProduct() {
    _sudoProdNombre.clear();
    _sudoProdPrecio.clear();
    _sudoProdDesc.clear();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: AppTheme.sf,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.bd, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Nuevo Producto', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.tx)),
          const SizedBox(height: 16),
          TextField(controller: _sudoProdNombre,
            style: const TextStyle(fontSize: 13, color: AppTheme.tx),
            decoration: InputDecoration(hintText: 'Nombre del producto', hintStyle: const TextStyle(color: AppTheme.td),
              filled: true, fillColor: AppTheme.cd, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)))),
          const SizedBox(height: 10),
          TextField(controller: _sudoProdPrecio, keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 13, color: AppTheme.tx),
            decoration: InputDecoration(hintText: 'Precio (MXN)', hintStyle: const TextStyle(color: AppTheme.td), prefixText: '\$ ',
              prefixStyle: const TextStyle(color: AppTheme.tx, fontWeight: FontWeight.w700),
              filled: true, fillColor: AppTheme.cd, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)))),
          const SizedBox(height: 10),
          TextField(controller: _sudoProdDesc,
            style: const TextStyle(fontSize: 13, color: AppTheme.tx),
            decoration: InputDecoration(hintText: 'Descripción (opcional)', hintStyle: const TextStyle(color: AppTheme.td),
              filled: true, fillColor: AppTheme.cd, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.bd)))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              if (_sudoProdNombre.text.trim().isEmpty || _sudoProdPrecio.text.trim().isEmpty) return;
              // Sanitize inputs - prevent XSS
              final nombre = _sudoProdNombre.text.trim().replaceAll(RegExp(r'[<>{}]'), '');
              final desc = _sudoProdDesc.text.trim().replaceAll(RegExp(r'[<>{}]'), '');
              final precio = int.tryParse(_sudoProdPrecio.text.trim().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              if (precio <= 0) return;
              setState(() => _sudoProductos.add({'nombre': nombre, 'descripcion': desc, 'precio': precio}));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), foregroundColor: const Color(0xFF003300),
              padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Agregar Producto', style: TextStyle(fontWeight: FontWeight.w700)),
          )),
        ]),
      ),
    );
  }

  Future<void> _sudoSubmit() async {
    // Validate inputs
    final nombre = _sudoNombre.text.trim().replaceAll(RegExp(r'[<>{}]'), '');
    if (nombre.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa el nombre del negocio'))); return; }
    if (_sudoDir.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa la dirección'))); return; }
    if (_sudoTel.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa el teléfono'))); return; }
    if (_sudoProductos.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega al menos un producto'))); return; }

    setState(() => _sudoGuardando = true);
    try {
      // Sanitize all inputs
      final data = {
        'nombre': nombre,
        'descripcion': _sudoDesc.text.trim().replaceAll(RegExp(r'[<>{}]'), ''),
        'giro': _sudoGiro,
        'direccion': _sudoDir.text.trim().replaceAll(RegExp(r'[<>{}]'), ''),
        'telefono': _sudoTel.text.trim().replaceAll(RegExp(r'[^0-9+\s()-]'), ''),
        'horario': _sudoHorario.text.trim().replaceAll(RegExp(r'[<>{}]'), ''),
        'color': '#${_sudoColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
        'plan': 'sudo_premium',
        'plan_inicio': DateTime.now().toIso8601String(),
        'plan_gratis_hasta': DateTime.now().add(const Duration(days: 90)).toIso8601String(),
        'precio_mensual': 1500,
        'activo': true,
        'rating': 5.0,
        'pedidos_total': 0,
        'productos': _sudoProductos,
        'ciudad': 'tulancingo',
        'zona': 'Centro',
        'tipo': _sudoGiro == 'restaurant' || _sudoGiro == 'panaderia' ? 'comida' : _sudoGiro == 'farmacia' ? 'farmacia' : 'tienda',
        'creado': DateTime.now().toIso8601String(),
      };
      final docId = await FirestoreService.addDocumentWithId('negocios', data);
      // WhatsApp notification
      final waMsg = 'NUEVO NEGOCIO SUDO\n\n🏪 $nombre\n📍 ${_sudoDir.text.trim()}\n🏷️ ${_sudoGiros[_sudoGiro]}\n📦 ${_sudoProductos.length} productos\n\nID: $docId';
      launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent(waMsg)}'), mode: LaunchMode.externalApplication);
      // Clear form
      _sudoNombre.clear(); _sudoDesc.clear(); _sudoDir.clear(); _sudoTel.clear(); _sudoHorario.clear();
      _sudoProductos.clear(); _sudoLogoPath = null;
      setState(() { _sudoGuardando = false; _menuScreen = 'sudo_tienda_$docId'; });
    } catch (e) {
      debugPrint('[SUDO] Error: $e');
      setState(() => _sudoGuardando = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ── SUDO TIENDA (Store View) ──
  Widget _sudoTiendaScreen(String negocioId) {
    // Load store data from Firestore
    return FutureBuilder<Map<String, dynamic>?>(
      future: FirestoreService.db.collection('negocios').doc(negocioId).get().then((s) => s.exists ? <String, dynamic>{...s.data()!, 'id': s.id} : null),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(color: AppTheme.bg, child: const Center(child: CircularProgressIndicator(color: Color(0xFF00E676))));
        }
        final tienda = snap.data;
        if (tienda == null) {
          return Container(color: AppTheme.bg, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Tienda no encontrada', style: TextStyle(color: AppTheme.tm)),
            const SizedBox(height: 12),
            GestureDetector(onTap: () => setState(() => _menuScreen = null),
              child: const Text('← Volver', style: TextStyle(color: AppTheme.ac))),
          ])));
        }

        final color = _parseColor(tienda['color'] as String? ?? '#2D7AFF');
        final productos = List<Map<String, dynamic>>.from(tienda['productos'] ?? []);
        final giro = tienda['giro'] as String? ?? 'otro';
        final giroEmoji = _sudoGiros[giro]?.split(' ').first ?? '📦';
        final nombre = tienda['nombre'] as String? ?? 'Tienda';
        final desc = tienda['descripcion'] as String? ?? '';
        final rating = (tienda['rating'] as num?)?.toDouble() ?? 5.0;
        final horario = tienda['horario'] as String? ?? 'No especificado';
        final pedidos = tienda['pedidos_total'] as int? ?? 0;

        return Container(color: AppTheme.bg, child: Column(children: [
          // Store header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(0.15), AppTheme.bg], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              border: Border(bottom: BorderSide(color: color.withOpacity(0.2))),
            ),
            child: Column(children: [
              Row(children: [
                GestureDetector(onTap: () => setState(() => _menuScreen = null),
                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppTheme.sf, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.bd)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.arrow_back_ios, size: 12, color: AppTheme.tm), SizedBox(width: 4),
                      Text('Cargo-GO', style: TextStyle(fontSize: 11, color: AppTheme.tm)),
                    ]))),
                const Spacer(),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF00E676).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Text('SUDO', style: TextStyle(fontSize: 8, color: Color(0xFF00E676), fontWeight: FontWeight.w800, letterSpacing: 2))),
              ]),
              const SizedBox(height: 16),
              // Logo + name
              Container(width: 70, height: 70,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.15),
                  border: Border.all(color: color.withOpacity(0.4), width: 2),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 20)]),
                child: Center(child: Text(giroEmoji, style: const TextStyle(fontSize: 32)))),
              const SizedBox(height: 10),
              Text(nombre, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
              if (desc.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4),
                child: Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.tm), textAlign: TextAlign.center)),
              const SizedBox(height: 10),
              // Rating + hours + orders
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFD600).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star, size: 12, color: Color(0xFFFFD600)),
                    const SizedBox(width: 3),
                    Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFFFD600))),
                  ])),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.schedule, size: 12, color: AppTheme.tm),
                    const SizedBox(width: 3),
                    Text(horario, style: const TextStyle(fontSize: 10, color: AppTheme.tm)),
                  ])),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text('$pedidos pedidos', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600))),
              ]),
            ]),
          ),
          // Products
          Expanded(child: productos.isEmpty
            ? const Center(child: Text('Sin productos aún', style: TextStyle(color: AppTheme.td)))
            : ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: productos.length,
                itemBuilder: (_, i) {
                  final p = productos[i];
                  final pNombre = p['nombre'] as String? ?? 'Producto';
                  final pPrecio = p['precio'] as int? ?? 0;
                  final pDesc = p['descripcion'] as String? ?? '';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(color: AppTheme.cd, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withOpacity(0.15))),
                    child: Padding(padding: const EdgeInsets.all(14),
                      child: Row(children: [
                        Container(width: 50, height: 50,
                          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Text(giroEmoji, style: const TextStyle(fontSize: 24)))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(pNombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.tx)),
                          if (pDesc.isNotEmpty) Text(pDesc, style: const TextStyle(fontSize: 10, color: AppTheme.td)),
                          const SizedBox(height: 4),
                          Text('\$$pPrecio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
                        ])),
                        GestureDetector(
                          onTap: () {
                            // Create order via WhatsApp - customer stays anonymous to business
                            final waMsg = 'PEDIDO SUDO · $nombre\n\n📦 $pNombre\n💰 \$$pPrecio\n\n🚚 Delivery Cargo-GO';
                            launchUrl(Uri.parse('https://wa.me/527753200224?text=${Uri.encodeComponent(waMsg)}'), mode: LaunchMode.externalApplication);
                          },
                          child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)]),
                            child: const Text('Pedir', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))),
                        ),
                      ])),
                  );
                },
              )),
          // Security footer
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.sf, border: Border(top: BorderSide(color: AppTheme.bd))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
              Icon(Icons.shield, size: 12, color: AppTheme.td),
              SizedBox(width: 6),
              Text('Tu identidad es anónima · Datos protegidos', style: TextStyle(fontSize: 9, color: AppTheme.td)),
            ])),
        ]));
      },
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppTheme.ac;
    }
  }
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
