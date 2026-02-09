"""
upload_negocios.py - Sube 101 negocios a Firestore (coleccion 'negocios')
Usa firebase-admin SDK.

Requisitos:
  pip install firebase-admin requests

Uso:
  1. Descarga tu service account key de Firebase Console
     -> Project Settings -> Service accounts -> Generate new private key
  2. Guarda el JSON como scripts/serviceAccountKey.json
  3. python scripts/upload_negocios.py
"""
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
import requests
import os
import sys

# ─── Config ───
GOOGLE_MAPS_API_KEY = 'AIzaSyD37YdGfyW3DFpQl6v48mLfGrjBds78iOI'
SERVICE_ACCOUNT_PATH = os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json')

# ─── Emoji por categoria ───
EMOJI_MAP = {
    'farmacia': '💊', 'comida': '🍲', 'postres': '🧁', 'cafe': '☕',
    'mariscos': '🦐', 'bebidas': '🍺', 'super': '🛒', 'mercado': '🏪',
    'panaderia': '🍞', 'carniceria': '🥩', 'abarrotes': '🏪',
    'flores': '💐', 'ferreteria': '🔧', 'servicios': '🔧',
    'papeleria': '📚', 'libreria': '📖', 'naturista': '🌿',
}

# ─── Color hex por categoria ───
COLOR_MAP = {
    'farmacia': '#00D68F', 'comida': '#FFA502', 'postres': '#FF6B9D',
    'cafe': '#78350F', 'mariscos': '#0891B2', 'bebidas': '#CA8A04',
    'super': '#059669', 'mercado': '#009688', 'panaderia': '#A16207',
    'carniceria': '#991B1B', 'abarrotes': '#009688', 'flores': '#E11D48',
    'ferreteria': '#525252', 'servicios': '#6366F1', 'papeleria': '#2563EB',
    'libreria': '#EAB308', 'naturista': '#16A34A',
}

# ─── 101 Negocios (extraidos de main.dart) ───
NEGOCIOS = [
    # ── Hidalgo (30) ──
    {'id':'h01','nombre':'Farmacias Madrid - Panteón','emoji':'💊','zona':'Calz. Hidalgo 1311, Tulancingo','desc':'Medicamentos genéricos, patente y hospitalarios · Servicio a domicilio','rating':4.8,'pedidos':1240,'tipo':'farmacia','horario':'8:00–22:00','tel':'7753496000','ciudad':'tulancingo'},
    {'id':'h01b','nombre':'Farmacias Madrid - Lázaro','emoji':'💊','zona':'Gral. L. Cárdenas 107, Tulancingo','desc':'Medicamentos genéricos, patente y hospitalarios · Servicio a domicilio','rating':4.8,'pedidos':980,'tipo':'farmacia','horario':'8:00–22:00','tel':'7753496000','ciudad':'tulancingo'},
    {'id':'h01c','nombre':'Farmacias Madrid - 21 de Marzo','emoji':'💊','zona':'21 de Marzo Nte. 406, Tulancingo','desc':'Medicamentos genéricos, patente y hospitalarios · Servicio a domicilio','rating':4.8,'pedidos':720,'tipo':'farmacia','horario':'8:00–22:00','tel':'7753496000','ciudad':'tulancingo'},
    {'id':'h01d','nombre':'Farmacias Madrid - Santa María','emoji':'💊','zona':'C. Jazmín 64, Col. Santa María, Tulancingo','desc':'Medicamentos genéricos, patente y hospitalarios · Servicio a domicilio','rating':4.8,'pedidos':860,'tipo':'farmacia','horario':'8:00–22:00','tel':'7753496000','ciudad':'tulancingo'},
    {'id':'h01e','nombre':'Farmacias Madrid - Caballito','emoji':'💊','zona':'21 de Marzo, Caballito, Tulancingo','desc':'Medicamentos genéricos, patente y hospitalarios · Servicio a domicilio','rating':4.8,'pedidos':650,'tipo':'farmacia','horario':'8:00–22:00','tel':'7753496000','ciudad':'tulancingo'},
    {'id':'h02','nombre':'Mamá Chela','emoji':'🍲','zona':'Centro, Tulancingo','desc':'Comida casera hidalguense','rating':4.9,'pedidos':890,'tipo':'comida','horario':'9:00–18:00','tel':'7759876543','ciudad':'tulancingo'},
    {'id':'h03','nombre':'Dulce María','emoji':'🧁','zona':'La Floresta, Tulancingo','desc':'Postres artesanales mexicanos','rating':4.7,'pedidos':650,'tipo':'postres','horario':'10:00–20:00','tel':'7751112233','ciudad':'tulancingo'},
    {'id':'h04','nombre':'Tacos El Güero','emoji':'🌮','zona':'Centro, Tulancingo','desc':'Tacos al pastor y suadero','rating':4.6,'pedidos':1100,'tipo':'comida','horario':'18:00–02:00','tel':'7754445566','ciudad':'tulancingo'},
    {'id':'h05','nombre':'Carnitas Don Pepe','emoji':'🥩','zona':'San Antonio, Tulancingo','desc':'Carnitas estilo Michoacán','rating':4.5,'pedidos':780,'tipo':'comida','horario':'8:00–16:00','tel':'7753334455','ciudad':'tulancingo'},
    {'id':'h06','nombre':'Pollos El Rey','emoji':'🍗','zona':'Las Torres, Tulancingo','desc':'Pollo al carbón y rostizado','rating':4.4,'pedidos':920,'tipo':'comida','horario':'10:00–21:00','tel':'7756667788','ciudad':'tulancingo'},
    {'id':'h07','nombre':'Café Tulancingo','emoji':'☕','zona':'Centro, Tulancingo','desc':'Café de altura hidalguense','rating':4.6,'pedidos':520,'tipo':'cafe','horario':'7:00–21:00','tel':'7752223344','ciudad':'tulancingo'},
    {'id':'h08','nombre':'Tortas La Abuela','emoji':'🥖','zona':'Jaltepec, Tulancingo','desc':'Tortas gigantes y cemitas','rating':4.7,'pedidos':670,'tipo':'comida','horario':'9:00–20:00','tel':'7758889900','ciudad':'tulancingo'},
    {'id':'h09','nombre':'Barbacoa Los Reyes','emoji':'🐑','zona':'Centro, Tulancingo','desc':'Barbacoa borrego jue y dom','rating':4.8,'pedidos':950,'tipo':'comida','horario':'Jue-Dom 7:00–15:00','tel':'7755556677','ciudad':'tulancingo'},
    {'id':'h10','nombre':'Pastes El Portal','emoji':'🥟','zona':'Centro, Tulancingo','desc':'Pastes tradicionales 1960','rating':4.7,'pedidos':1050,'tipo':'comida','horario':'8:00–20:00','tel':'7751239876','ciudad':'tulancingo'},
    {'id':'h11','nombre':'Panadería San José','emoji':'🍞','zona':'La Floresta','desc':'Pan artesanal y de fiesta','rating':4.5,'pedidos':420,'tipo':'panaderia','horario':'6:00–21:00','tel':'7754561234','ciudad':'tulancingo'},
    {'id':'h12','nombre':'Pulquería La Noria','emoji':'🍺','zona':'Santiago, Tulancingo','desc':'Pulque natural y curados','rating':4.3,'pedidos':380,'tipo':'bebidas','horario':'12:00–22:00','tel':'7757891234','ciudad':'tulancingo'},
    {'id':'h13','nombre':'Abarrotes Doña Lupe','emoji':'🏪','zona':'Cuautepec','desc':'Abarrotes y productos básicos','rating':4.2,'pedidos':620,'tipo':'abarrotes','horario':'7:00–22:00','tel':'7753216549','ciudad':'tulancingo'},
    {'id':'h14','nombre':'Pizzas Tulancingo','emoji':'🍕','zona':'Las Torres','desc':'Pizza al horno de leña','rating':4.4,'pedidos':540,'tipo':'comida','horario':'14:00–23:00','tel':'7756543210','ciudad':'tulancingo'},
    {'id':'h15','nombre':'Jugos y Licuados Mary','emoji':'🥤','zona':'Mercado','desc':'Jugos naturales y licuados','rating':4.5,'pedidos':730,'tipo':'bebidas','horario':'7:00–18:00','tel':'7759871234','ciudad':'tulancingo'},
    {'id':'h16','nombre':'Taller Bicis Rápido','emoji':'🚲','zona':'Centro','desc':'Reparación y refacciones','rating':4.1,'pedidos':180,'tipo':'servicios','horario':'9:00–19:00','tel':'7751472583','ciudad':'tulancingo'},
    {'id':'h17','nombre':'Flores El Jardín','emoji':'💐','zona':'La Floresta','desc':'Arreglos florales y ramos','rating':4.6,'pedidos':290,'tipo':'flores','horario':'8:00–20:00','tel':'7752583691','ciudad':'tulancingo'},
    {'id':'h18','nombre':'Carnicería Hidalgo','emoji':'🥩','zona':'Mercado','desc':'Carnes selectas y marinados','rating':4.4,'pedidos':810,'tipo':'carniceria','horario':'7:00–17:00','tel':'7753691472','ciudad':'tulancingo'},
    {'id':'h19','nombre':'Ferretería Central','emoji':'🔧','zona':'Centro','desc':'Material eléctrico y plomería','rating':4.3,'pedidos':350,'tipo':'ferreteria','horario':'8:00–19:00','tel':'7754567890','ciudad':'tulancingo'},
    {'id':'h20','nombre':'Papelería Escolar','emoji':'📚','zona':'Centro','desc':'Útiles, copias, impresiones','rating':4.2,'pedidos':460,'tipo':'papeleria','horario':'8:00–20:00','tel':'7757890123','ciudad':'tulancingo'},
    {'id':'h21','nombre':'Tortillería La Esperanza','emoji':'🫓','zona':'Centro, Tulancingo','desc':'Tortillas de maíz y harina recién hechas','rating':4.6,'pedidos':1800,'tipo':'comida','horario':'6:00–14:00','tel':'7751234890','ciudad':'tulancingo'},
    {'id':'h22','nombre':'Pollería Hermanos García','emoji':'🐔','zona':'Las Torres, Tulancingo','desc':'Pollo fresco, huevo y embutidos','rating':4.3,'pedidos':950,'tipo':'comida','horario':'7:00–18:00','tel':'7754321098','ciudad':'tulancingo'},
    {'id':'h23','nombre':'Abarrotes El Ahorro','emoji':'🛒','zona':'Jaltepec, Tulancingo','desc':'Todo para tu despensa a buen precio','rating':4.1,'pedidos':720,'tipo':'super','horario':'7:00–23:00','tel':'7756789012','ciudad':'tulancingo'},
    {'id':'h24','nombre':'Taquería Los Compadres','emoji':'🌮','zona':'La Floresta, Tulancingo','desc':'Tacos de suadero, tripa y cabeza','rating':4.7,'pedidos':1350,'tipo':'comida','horario':'19:00–03:00','tel':'7758901234','ciudad':'tulancingo'},
    {'id':'h25','nombre':'Tlapalería Don Manuel','emoji':'🔩','zona':'Centro, Tulancingo','desc':'Pinturas, herramientas y material','rating':4.2,'pedidos':280,'tipo':'ferreteria','horario':'8:00–19:00','tel':'7750123456','ciudad':'tulancingo'},
    {'id':'h26','nombre':'Estética Lupita','emoji':'💇','zona':'La Floresta, Tulancingo','desc':'Cortes, tintes, peinados y uñas','rating':4.5,'pedidos':410,'tipo':'servicios','horario':'9:00–20:00','tel':'7752345678','ciudad':'tulancingo'},
    {'id':'h27','nombre':'Veterinaria San Francisco','emoji':'🐾','zona':'Centro, Tulancingo','desc':'Consultas, vacunas y accesorios','rating':4.4,'pedidos':320,'tipo':'servicios','horario':'9:00–19:00','tel':'7753456789','ciudad':'tulancingo'},
    {'id':'h28','nombre':'Recaudería Doña Carmen','emoji':'🥕','zona':'Mercado, Tulancingo','desc':'Frutas, verduras y legumbres frescas','rating':4.3,'pedidos':1100,'tipo':'mercado','horario':'6:00–16:00','tel':'7754567891','ciudad':'tulancingo'},
    {'id':'h29','nombre':'Lavandería Clean Express','emoji':'👔','zona':'Las Torres, Tulancingo','desc':'Lavado, secado y planchado rápido','rating':4.1,'pedidos':190,'tipo':'servicios','horario':'8:00–20:00','tel':'7755678901','ciudad':'tulancingo'},
    {'id':'h30','nombre':'Cremería La Vaquita','emoji':'🧀','zona':'Mercado, Tulancingo','desc':'Quesos, crema y lácteos de rancho','rating':4.6,'pedidos':680,'tipo':'comida','horario':'7:00–17:00','tel':'7756789013','ciudad':'tulancingo'},
    # ── CDMX (81 - IDs c01..c81, pero son 67 aqui porque algunos se contaron diferente) ──
    {'id':'c01','nombre':'El Califa de León','emoji':'🌮','zona':'San Rafael','desc':'⭐Michelin · Tacos 1968','rating':4.9,'pedidos':3200,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c02','nombre':'Café El Jarocho','emoji':'☕','zona':'Coyoacán','desc':'El café más famoso de CDMX','rating':4.8,'pedidos':2800,'tipo':'cafe','ciudad':'cdmx'},
    {'id':'c03','nombre':'Los Cocuyos','emoji':'🥩','zona':'Centro Histórico','desc':'Suadero y longaniza legendarios','rating':4.7,'pedidos':2100,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c04','nombre':'Mercado Coyoacán','emoji':'🏪','zona':'Coyoacán','desc':'Tostadas, antojitos, quesadillas','rating':4.5,'pedidos':2400,'tipo':'mercado','ciudad':'cdmx'},
    {'id':'c05','nombre':'Tacos Orinoco','emoji':'🌮','zona':'Roma Norte','desc':'Tacos chicharrón prensado','rating':4.8,'pedidos':2900,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c06','nombre':'Por Siempre Vegana','emoji':'🥬','zona':'Roma Sur','desc':'Tacos veganos gourmet','rating':4.6,'pedidos':1800,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c07','nombre':'Churrería El Moro','emoji':'🍩','zona':'Centro Histórico','desc':'Churros desde 1935','rating':4.7,'pedidos':3100,'tipo':'postres','ciudad':'cdmx'},
    {'id':'c08','nombre':'Pastelería Ideal','emoji':'🎂','zona':'Centro Histórico','desc':'Pan y pasteles monumentales','rating':4.5,'pedidos':2200,'tipo':'panaderia','ciudad':'cdmx'},
    {'id':'c09','nombre':'La Casa de Toño','emoji':'🥣','zona':'Polanco','desc':'Pozole y sopes 24hrs','rating':4.6,'pedidos':2700,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c10','nombre':'Taquería Los Parados','emoji':'🌮','zona':'Insurgentes','desc':'Tacos bistec al carbón','rating':4.5,'pedidos':2500,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c11','nombre':'Boing! Factory','emoji':'🥤','zona':'Xochimilco','desc':'Jugos embotellados artesanales','rating':4.3,'pedidos':1200,'tipo':'bebidas','ciudad':'cdmx'},
    {'id':'c12','nombre':'Birria El Texano','emoji':'🍖','zona':'Narvarte','desc':'Birria de res en consomé','rating':4.7,'pedidos':1900,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c13','nombre':'Mercado Jamaica','emoji':'💐','zona':'Jamaica','desc':'Flores, frutas y víveres','rating':4.4,'pedidos':1600,'tipo':'mercado','ciudad':'cdmx'},
    {'id':'c14','nombre':'Helados Tepoznieves','emoji':'🍦','zona':'Condesa','desc':'Nieves artesanales exóticas','rating':4.6,'pedidos':2000,'tipo':'postres','ciudad':'cdmx'},
    {'id':'c15','nombre':'Panadería Rosetta','emoji':'🍞','zona':'Roma Norte','desc':'Pan artesanal europeo-mx','rating':4.8,'pedidos':1700,'tipo':'panaderia','ciudad':'cdmx'},
    {'id':'c16','nombre':'Tortas Río','emoji':'🥖','zona':'Tlalpan','desc':'Tortas cubanas gigantes','rating':4.4,'pedidos':1400,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c17','nombre':'Mariscos La Viga','emoji':'🦐','zona':'La Viga','desc':'Cocteles y ceviches frescos','rating':4.5,'pedidos':1300,'tipo':'mariscos','ciudad':'cdmx'},
    {'id':'c18','nombre':'Tamales Doña Emi','emoji':'🫔','zona':'Tacubaya','desc':'Tamales de todos sabores','rating':4.6,'pedidos':2100,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c19','nombre':'Gorditas Doña Tota','emoji':'🫓','zona':'Centro','desc':'Gorditas rellenas al momento','rating':4.5,'pedidos':1800,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c20','nombre':'Café Habana','emoji':'☕','zona':'Juárez','desc':'Café icónico desde 1950','rating':4.7,'pedidos':1500,'tipo':'cafe','ciudad':'cdmx'},
    {'id':'c21','nombre':'Quesadillas Doña Mary','emoji':'🧀','zona':'Del Valle','desc':'Quesadillas con/sin queso','rating':4.4,'pedidos':1600,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c22','nombre':'Tacos Canasta Javi','emoji':'🌮','zona':'Tepito','desc':'Tacos sudados a $5','rating':4.3,'pedidos':3800,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c23','nombre':'Mercado San Juan','emoji':'🏪','zona':'Centro','desc':'Productos gourmet y exóticos','rating':4.6,'pedidos':1400,'tipo':'mercado','ciudad':'cdmx'},
    {'id':'c24','nombre':'Carnitas Don Güicho','emoji':'🐷','zona':'Azcapotzalco','desc':'Carnitas estilo Quiroga','rating':4.5,'pedidos':1700,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c25','nombre':'Farmacia del Ahorro','emoji':'💊','zona':'Centro Histórico','desc':'Farmacia 24hrs','rating':4.2,'pedidos':900,'tipo':'farmacia','ciudad':'cdmx'},
    {'id':'c26','nombre':'La Especial de París','emoji':'🥘','zona':'Insurgentes','desc':'Comida corrida desde 1921','rating':4.4,'pedidos':1300,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c27','nombre':'Café de Tacuba','emoji':'🍽️','zona':'Centro Histórico','desc':'Restaurante histórico 1912','rating':4.6,'pedidos':1100,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c28','nombre':'El Huequito','emoji':'🌮','zona':'Centro','desc':'Tacos al pastor pioneros','rating':4.7,'pedidos':2600,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c29','nombre':'Nevería Roxy','emoji':'🍦','zona':'Coyoacán','desc':'Helados artesanales 1946','rating':4.5,'pedidos':1800,'tipo':'postres','ciudad':'cdmx'},
    {'id':'c30','nombre':'Pan Bimbo Outlet','emoji':'🍞','zona':'Naucalpan','desc':'Pan de caja al costo','rating':4.1,'pedidos':700,'tipo':'panaderia','ciudad':'cdmx'},
    {'id':'c31','nombre':'Mariscos El Caguamo','emoji':'🐟','zona':'Centro','desc':'Mariscos estilo Nayarit','rating':4.6,'pedidos':1500,'tipo':'mariscos','ciudad':'cdmx'},
    {'id':'c32','nombre':'Tlayudas Oaxaqueñas','emoji':'🫓','zona':'Condesa','desc':'Tlayudas y mezcal artesanal','rating':4.5,'pedidos':1200,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c33','nombre':'Pollos Río','emoji':'🍗','zona':'Polanco','desc':'Pollo al horno c/papas','rating':4.3,'pedidos':1900,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c34','nombre':'Esquites Don Beto','emoji':'🌽','zona':'Reforma','desc':'Esquites, elotes, trolelotes','rating':4.4,'pedidos':2200,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c35','nombre':'Mezcalería','emoji':'🥃','zona':'Doctores','desc':'Mezcal artesanal oaxaqueño','rating':4.6,'pedidos':800,'tipo':'bebidas','ciudad':'cdmx'},
    {'id':'c36','nombre':'Sushi Itto Express','emoji':'🍣','zona':'Santa Fe','desc':'Sushi delivery rápido','rating':4.2,'pedidos':1600,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c37','nombre':'Pizzas Domino','emoji':'🍕','zona':'Nápoles','desc':'Pizza y alitas delivery','rating':4.1,'pedidos':2400,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c38','nombre':'Tostadas Coyoacán','emoji':'🥗','zona':'Coyoacán','desc':'Tostadas de pata y ceviche','rating':4.5,'pedidos':1400,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c39','nombre':'Dulcería de Celaya','emoji':'🍬','zona':'Centro','desc':'Dulces mexicanos 1874','rating':4.7,'pedidos':900,'tipo':'postres','ciudad':'cdmx'},
    {'id':'c40','nombre':'Fonda Margarita','emoji':'🍳','zona':'Condesa','desc':'Desayunos legendarios','rating':4.8,'pedidos':1300,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c41','nombre':'La Polar','emoji':'🍺','zona':'San Rafael','desc':'Cervecería con botanas','rating':4.4,'pedidos':1100,'tipo':'bebidas','ciudad':'cdmx'},
    {'id':'c42','nombre':'Taco Inn','emoji':'🌮','zona':'Insurgentes Sur','desc':'Fast food mexicano','rating':4.2,'pedidos':1800,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c43','nombre':'Superama Express','emoji':'🛒','zona':'Polanco','desc':'Súper premium delivery','rating':4.3,'pedidos':950,'tipo':'super','ciudad':'cdmx'},
    {'id':'c44','nombre':'La Merced Orgánica','emoji':'🥕','zona':'La Merced','desc':'Frutas y verduras orgánicas','rating':4.5,'pedidos':680,'tipo':'mercado','ciudad':'cdmx'},
    {'id':'c45','nombre':'Papelería Lumen','emoji':'📚','zona':'Centro','desc':'Papelería profesional','rating':4.4,'pedidos':540,'tipo':'papeleria','ciudad':'cdmx'},
    {'id':'c46','nombre':'Ferretería Truper','emoji':'🔧','zona':'Iztapalapa','desc':'Herramientas y material','rating':4.2,'pedidos':420,'tipo':'ferreteria','ciudad':'cdmx'},
    {'id':'c47','nombre':'Florerías CDMX','emoji':'💐','zona':'Polanco','desc':'Arreglos premium','rating':4.6,'pedidos':560,'tipo':'flores','ciudad':'cdmx'},
    {'id':'c48','nombre':'Alitas y Boneless','emoji':'🍗','zona':'Roma','desc':'Wings y cerveza artesanal','rating':4.4,'pedidos':1700,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c49','nombre':'VIPS Insurgentes','emoji':'🍽️','zona':'Insurgentes','desc':'Enchiladas y café 24hrs','rating':4.1,'pedidos':1400,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c50','nombre':'Tamal Oaxaqueño','emoji':'🫔','zona':'Del Valle','desc':'Tamales oaxaqueños de mole','rating':4.5,'pedidos':1100,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c51','nombre':'Ramen Shinju','emoji':'🍜','zona':'Roma Norte','desc':'Ramen japonés auténtico','rating':4.7,'pedidos':1200,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c52','nombre':'Hamburguesas Corral','emoji':'🍔','zona':'Condesa','desc':'Burgers artesanales','rating':4.5,'pedidos':1500,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c53','nombre':'Café Punta del Cielo','emoji':'☕','zona':'Coyoacán','desc':'Café mexicano especialidad','rating':4.4,'pedidos':1800,'tipo':'cafe','ciudad':'cdmx'},
    {'id':'c54','nombre':'Waffles & Crêpes','emoji':'🧇','zona':'Roma','desc':'Waffles belgas y crêpes','rating':4.5,'pedidos':900,'tipo':'postres','ciudad':'cdmx'},
    {'id':'c55','nombre':'Tortería Niza','emoji':'🥖','zona':'Juárez','desc':'Tortas desde 1957','rating':4.6,'pedidos':1300,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c56','nombre':'Pozolería Tía Calla','emoji':'🥣','zona':'Roma Sur','desc':'Pozole blanco guerrerense','rating':4.6,'pedidos':1100,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c57','nombre':'Lavandería Express','emoji':'👔','zona':'Narvarte','desc':'Lavado y planchado 2hrs','rating':4.3,'pedidos':380,'tipo':'servicios','ciudad':'cdmx'},
    {'id':'c58','nombre':'Tintorería Premium','emoji':'👗','zona':'Polanco','desc':'Tintorería y costura','rating':4.4,'pedidos':290,'tipo':'servicios','ciudad':'cdmx'},
    {'id':'c59','nombre':'Barbería Old School','emoji':'💈','zona':'Roma','desc':'Cortes clásicos y barba','rating':4.5,'pedidos':420,'tipo':'servicios','ciudad':'cdmx'},
    {'id':'c60','nombre':'Veterinaria PetCare','emoji':'🐾','zona':'Del Valle','desc':'Consultas y productos pet','rating':4.4,'pedidos':560,'tipo':'servicios','ciudad':'cdmx'},
    {'id':'c61','nombre':'Cervecería Primus','emoji':'🍺','zona':'Coyoacán','desc':'Cerveza artesanal local','rating':4.6,'pedidos':700,'tipo':'bebidas','ciudad':'cdmx'},
    {'id':'c62','nombre':'Comida China Wing\'s','emoji':'🥡','zona':'Centro','desc':'Comida china económica','rating':4.2,'pedidos':1600,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c63','nombre':'Empanadas Argentinas','emoji':'🥟','zona':'Condesa','desc':'Empanadas al horno','rating':4.5,'pedidos':800,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c64','nombre':'Jugos Natural Express','emoji':'🥤','zona':'Roma','desc':'Jugos verdes y smoothies','rating':4.4,'pedidos':950,'tipo':'bebidas','ciudad':'cdmx'},
    {'id':'c65','nombre':'El Pescadito','emoji':'🐟','zona':'Condesa','desc':'Fish tacos Ensenada','rating':4.7,'pedidos':1400,'tipo':'mariscos','ciudad':'cdmx'},
    {'id':'c66','nombre':'Korean BBQ Mex','emoji':'🥘','zona':'Zona Rosa','desc':'BBQ coreano fusión mx','rating':4.5,'pedidos':900,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c67','nombre':'Abarrotes Don Toño','emoji':'🏪','zona':'Tepito','desc':'Abarrotes al mayoreo','rating':4.1,'pedidos':1200,'tipo':'abarrotes','ciudad':'cdmx'},
    {'id':'c68','nombre':'Tienda Naturista','emoji':'🌿','zona':'Coyoacán','desc':'Productos naturales','rating':4.3,'pedidos':450,'tipo':'naturista','ciudad':'cdmx'},
    {'id':'c69','nombre':'Librería Gandhi','emoji':'📖','zona':'Miguel Ángel','desc':'Libros y envío express','rating':4.5,'pedidos':380,'tipo':'libreria','ciudad':'cdmx'},
    {'id':'c70','nombre':'Copias Print Center','emoji':'🖨️','zona':'Centro','desc':'Impresiones, planos, lonas','rating':4.2,'pedidos':620,'tipo':'servicios','ciudad':'cdmx'},
    {'id':'c71','nombre':'Bike Messenger','emoji':'🚴','zona':'Juárez','desc':'Mensajería en bici express','rating':4.4,'pedidos':780,'tipo':'servicios','ciudad':'cdmx'},
    {'id':'c72','nombre':'Carnicería Premium','emoji':'🥩','zona':'Polanco','desc':'Cortes Angus y Wagyu','rating':4.7,'pedidos':540,'tipo':'carniceria','ciudad':'cdmx'},
    {'id':'c73','nombre':'Tortillería La Güera','emoji':'🫓','zona':'Iztacalco','desc':'Tortillas maíz nixtamal','rating':4.5,'pedidos':2800,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c74','nombre':'Mueblería Express','emoji':'🪑','zona':'Naucalpan','desc':'Muebles y mudanzas','rating':4.1,'pedidos':180,'tipo':'servicios','ciudad':'cdmx'},
    {'id':'c75','nombre':'Pastes Hidalguenses','emoji':'🥟','zona':'Roma','desc':'Pastes originales Hidalgo','rating':4.6,'pedidos':650,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c76','nombre':'Cevichería Pacífico','emoji':'🦐','zona':'Narvarte','desc':'Ceviche y aguachile','rating':4.6,'pedidos':1100,'tipo':'mariscos','ciudad':'cdmx'},
    {'id':'c77','nombre':'Brownies & Co.','emoji':'🍫','zona':'Condesa','desc':'Brownies gourmet y cookies','rating':4.5,'pedidos':780,'tipo':'postres','ciudad':'cdmx'},
    {'id':'c78','nombre':'Dona María Mole','emoji':'🫕','zona':'Centro','desc':'Moles artesanales','rating':4.4,'pedidos':460,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c79','nombre':'Cochinita Express','emoji':'🐷','zona':'Narvarte','desc':'Cochinita, panuchos, salbutes','rating':4.6,'pedidos':1300,'tipo':'comida','ciudad':'cdmx'},
    {'id':'c80','nombre':'Mercado Roma','emoji':'🏪','zona':'Roma','desc':'Food court gourmet','rating':4.5,'pedidos':1600,'tipo':'mercado','ciudad':'cdmx'},
    {'id':'c81','nombre':'Costco','emoji':'🛒','zona':'Satélite · Coyoacán · Interlomas','desc':'Mayoreo · Electrónica · Alimentos','rating':4.7,'pedidos':5200,'tipo':'super','ciudad':'cdmx'},
]

# ─── Coordenadas reales de todos los negocios ───
COORDS = {
    # Hidalgo
    'h01': [20.0756833, -98.3584392], 'h01b': [20.0776454, -98.3714904], 'h01c': [20.0846106, -98.3657675],
    'h01d': [20.0937157, -98.3667885], 'h01e': [20.0884699, -98.3632441], 'h02': [20.0838, -98.3808], 'h03': [20.0780, -98.3730],
    'h04': [20.0850, -98.3825], 'h05': [20.0890, -98.3770], 'h06': [20.0760, -98.3880],
    'h07': [20.0842, -98.3820], 'h08': [20.0920, -98.3760], 'h09': [20.0835, -98.3830],
    'h10': [20.0840, -98.3810], 'h11': [20.0775, -98.3740], 'h12': [20.0810, -98.3900],
    'h13': [20.0670, -98.3650], 'h14': [20.0765, -98.3875], 'h15': [20.0845, -98.3800],
    'h16': [20.0848, -98.3818], 'h17': [20.0785, -98.3735], 'h18': [20.0843, -98.3805],
    'h19': [20.0847, -98.3822], 'h20': [20.0836, -98.3812], 'h21': [20.0852, -98.3622],
    'h22': [20.0910, -98.3705], 'h23': [20.0920, -98.3755], 'h24': [20.0778, -98.3738],
    'h25': [20.0846, -98.3628], 'h26': [20.0782, -98.3565], 'h27': [20.0839, -98.3610],
    'h28': [20.0848, -98.3605], 'h29': [20.0915, -98.3710], 'h30': [20.0845, -98.3615],
    # CDMX
    'c01': [19.4407, -99.1567], 'c02': [19.3500, -99.1625], 'c03': [19.4326, -99.1332],
    'c04': [19.3505, -99.1630], 'c05': [19.4186, -99.1619], 'c06': [19.4100, -99.1610],
    'c07': [19.4330, -99.1340], 'c08': [19.4335, -99.1345], 'c09': [19.4340, -99.1950],
    'c10': [19.4000, -99.1700], 'c11': [19.2636, -99.1044], 'c12': [19.3980, -99.1600],
    'c13': [19.4130, -99.1250], 'c14': [19.4130, -99.1720], 'c15': [19.4190, -99.1625],
    'c16': [19.2900, -99.1700], 'c17': [19.3870, -99.1200], 'c18': [19.4020, -99.1880],
    'c19': [19.4320, -99.1325], 'c20': [19.4290, -99.1560], 'c21': [19.3900, -99.1720],
    'c22': [19.4400, -99.1250], 'c23': [19.4315, -99.1360], 'c24': [19.4870, -99.1860],
    'c25': [19.4328, -99.1335], 'c26': [19.4010, -99.1690], 'c27': [19.4340, -99.1350],
    'c28': [19.4322, -99.1338], 'c29': [19.3510, -99.1620], 'c30': [19.4780, -99.2380],
    'c31': [19.4318, -99.1330], 'c32': [19.4135, -99.1715], 'c33': [19.4345, -99.1955],
    'c34': [19.4260, -99.1640], 'c35': [19.4200, -99.1450], 'c36': [19.3650, -99.2710],
    'c37': [19.3900, -99.1800], 'c38': [19.3508, -99.1628], 'c39': [19.4325, -99.1342],
    'c40': [19.4128, -99.1718], 'c41': [19.4405, -99.1570], 'c42': [19.3950, -99.1710],
    'c43': [19.4350, -99.1960], 'c44': [19.4280, -99.1255], 'c45': [19.4310, -99.1348],
    'c46': [19.3600, -99.0900], 'c47': [19.4355, -99.1965], 'c48': [19.4185, -99.1615],
    'c49': [19.4005, -99.1695], 'c50': [19.3905, -99.1725], 'c51': [19.4192, -99.1622],
    'c52': [19.4132, -99.1722], 'c53': [19.3515, -99.1618], 'c54': [19.4180, -99.1612],
    'c55': [19.4285, -99.1555], 'c56': [19.4105, -99.1608], 'c57': [19.3985, -99.1605],
    'c58': [19.4348, -99.1958], 'c59': [19.4188, -99.1618], 'c60': [19.3908, -99.1728],
    'c61': [19.3520, -99.1615], 'c62': [19.4332, -99.1328], 'c63': [19.4138, -99.1725],
    'c64': [19.4183, -99.1616], 'c65': [19.4140, -99.1728], 'c66': [19.4270, -99.1530],
    'c67': [19.4405, -99.1248], 'c68': [19.3525, -99.1612], 'c69': [19.4312, -99.1582],
    'c70': [19.4335, -99.1355], 'c71': [19.4295, -99.1565], 'c72': [19.4360, -99.1970],
    'c73': [19.3950, -99.0955], 'c74': [19.4785, -99.2385], 'c75': [19.4195, -99.1628],
    'c76': [19.3988, -99.1608], 'c77': [19.4145, -99.1730], 'c78': [19.4338, -99.1358],
    'c79': [19.3992, -99.1612], 'c80': [19.4178, -99.1608], 'c81': [19.5098, -99.2338],
}

# Place IDs conocidos (los 11 del Excel con Place ID real)
PLACE_IDS = {
    'c01': 'ChIJDSZdTdj_0YURo_NdKw_PU5U',  # El Califa de León
    'c02': 'ChIJY53e1MQAzoURQbANx__OIWE',  # Café El Jarocho
    'c03': 'ChIJPeGf7Lz_0YURd9XGR_f-jqw',  # Los Cocuyos
    'c05': 'ChIJi7GiEK__0YURjgL2bBnqTSM',  # Tacos Orinoco
    'c07': 'ChIJHTf0daz_0YUR4CRWPiuW_xk',  # Churrería El Moro
    'c08': 'ChIJ4dCCR8L_0YURMwgJJbKOHQQ',  # Pastelería Ideal
    'c09': 'ChIJTYXgVlcBzoURqDjx95vRwBs',  # La Casa de Toño
    'c15': 'ChIJq6p0gMD_0YURsGJC5S3RK4Q',  # Panadería Rosetta
    'c28': 'ChIJNXjcU6z_0YURyI8nJeFpY00',  # El Huequito
    'c39': 'ChIJFa2BIKz_0YURB3o9ueqKh1E',  # Dulcería de Celaya
    'c40': 'ChIJHZxGKs__0YUR9a_aH97AKAk',  # Fonda Margarita
}


def get_place_photo_url(place_id):
    """Obtiene foto real de Google Places para un negocio con Place ID."""
    try:
        url = f'https://maps.googleapis.com/maps/api/place/details/json?place_id={place_id}&fields=photos&key={GOOGLE_MAPS_API_KEY}'
        r = requests.get(url, timeout=10)
        data = r.json()
        photos = data.get('result', {}).get('photos', [])
        if photos:
            ref = photos[0]['photo_reference']
            return f'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference={ref}&key={GOOGLE_MAPS_API_KEY}'
    except Exception as e:
        print(f'  [!] Error obteniendo foto para {place_id}: {e}')
    return None


def get_satellite_url(lat, lng):
    """Genera URL de foto satelital con Google Static Maps."""
    return (
        f'https://maps.googleapis.com/maps/api/staticmap'
        f'?center={lat},{lng}&zoom=18&size=600x300&scale=2'
        f'&maptype=satellite&markers=color:red%7C{lat},{lng}'
        f'&key={GOOGLE_MAPS_API_KEY}'
    )


def main():
    # Verificar service account key
    if not os.path.exists(SERVICE_ACCOUNT_PATH):
        print(f'ERROR: No se encontro {SERVICE_ACCOUNT_PATH}')
        print('Descarga tu service account key de Firebase Console:')
        print('  Project Settings -> Service accounts -> Generate new private key')
        print(f'  Guarda como: {SERVICE_ACCOUNT_PATH}')
        sys.exit(1)

    # Init Firebase Admin
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    print(f'=== Subiendo {len(NEGOCIOS)} negocios a Firestore ===\n')

    for i, neg in enumerate(NEGOCIOS):
        nid = neg['id']
        coords = COORDS.get(nid)
        place_id = PLACE_IDS.get(nid)

        # Determinar foto URL
        foto_url = None
        if place_id:
            print(f'  [{i+1}/{len(NEGOCIOS)}] {neg["nombre"]} - Place ID: {place_id}')
            foto_url = get_place_photo_url(place_id)
            if foto_url:
                print(f'    -> Foto Places API OK')
            else:
                print(f'    -> Foto Places API FAIL, usando satelital')

        if not foto_url and coords:
            foto_url = get_satellite_url(coords[0], coords[1])

        # Google Maps URL
        google_maps_url = ''
        if coords:
            google_maps_url = f'https://www.google.com/maps/search/?api=1&query={coords[0]},{coords[1]}'

        # Build document
        doc = {
            'nombre': neg['nombre'],
            'categoria': neg.get('tipo', 'comida'),
            'direccion': neg['zona'],
            'zona': neg['zona'],
            'telefono': neg.get('tel', ''),
            'horario': neg.get('horario', ''),
            'rating': neg['rating'],
            'suscripcion_mensual': 500,
            'estado': 'activo',
            'foto_url': foto_url or '',
            'google_maps_url': google_maps_url,
            'place_id': place_id or '',
            'ciudad': neg['ciudad'],
            'emoji': neg['emoji'],
            'color_hex': COLOR_MAP.get(neg.get('tipo', 'comida'), '#FFA502'),
            'lat': coords[0] if coords else 0.0,
            'lng': coords[1] if coords else 0.0,
            'pedidos': neg.get('pedidos', 0),
            'desc': neg.get('desc', ''),
            'created_at': firestore.SERVER_TIMESTAMP,
        }

        # Upload using negocio ID as document ID
        db.collection('negocios').document(nid).set(doc)
        if not place_id:
            print(f'  [{i+1}/{len(NEGOCIOS)}] {neg["nombre"]} -> OK')

    print(f'\n=== Listo! {len(NEGOCIOS)} negocios subidos a Firestore ===')
    print('Verifica en: https://console.firebase.google.com/project/cargo-go-b5f77/firestore')


if __name__ == '__main__':
    main()
