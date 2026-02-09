"""
setup_farmacias_vip.py - Configura las 5 sucursales de Farmacias Madrid como VIP

Sube fotos reales de Street View a Firebase Storage y actualiza Firestore
con datos reales: direcciones, coordenadas, telefono, plan VIP.

Uso:
  python scripts/setup_farmacias_vip.py
"""
import os, sys
import firebase_admin
from firebase_admin import credentials, storage
from google.auth.transport.requests import AuthorizedSession
from google.oauth2 import service_account

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FOTOS = os.path.join(BASE, 'datos', 'fotos')
SA = os.path.join(os.path.expanduser('~'), '.config', 'firebase', 'cargo-go-service-account.json')
PID = 'cargo-go-b5f77'
FS = f'https://firestore.googleapis.com/v1/projects/{PID}/databases/(default)/documents'

# ─── Las 5 Sucursales ───
SUCURSALES = [
    {
        'id': 'h01',
        'nombre': 'Farmacias Madrid - Panteón',
        'direccion': 'Calz. Hidalgo 1311, Tulancingo',
        'lat': 20.0756833,
        'lng': -98.3584392,
        'foto_archivo': 'FARMA PANTEON.png',
        'horario': '8:00–22:00',
        'pedidos': 1240,
    },
    {
        'id': 'h01b',
        'nombre': 'Farmacias Madrid - Lázaro',
        'direccion': 'Gral. L. Cárdenas 107, Tulancingo',
        'lat': 20.0776454,
        'lng': -98.3714904,
        'foto_archivo': 'FARMA SUC LAZARO.png',
        'horario': '8:00–22:00',
        'pedidos': 980,
    },
    {
        'id': 'h01c',
        'nombre': 'Farmacias Madrid - 21 de Marzo',
        'direccion': '21 de Marzo Nte. 406, Tulancingo',
        'lat': 20.0846106,
        'lng': -98.3657675,
        'foto_archivo': 'FARMA SUC 21.png',
        'horario': '8:00–22:00',
        'pedidos': 720,
    },
    {
        'id': 'h01d',
        'nombre': 'Farmacias Madrid - Santa María',
        'direccion': 'C. Jazmín 64, Col. Santa María, Tulancingo',
        'lat': 20.0937157,
        'lng': -98.3667885,
        'foto_archivo': 'FARMA SABTA.png',
        'horario': '8:00–22:00',
        'pedidos': 860,
    },
    {
        'id': 'h01e',
        'nombre': 'Farmacias Madrid - Caballito',
        'direccion': '21 de Marzo, Caballito, Tulancingo',
        'lat': 20.0884699,
        'lng': -98.3632441,
        'foto_archivo': 'FARMA SUC CABALLITO.png',
        'horario': '8:00–22:00',
        'pedidos': 650,
    },
]

# Campos comunes VIP
COMUN = {
    'emoji': '💊',
    'categoria': 'farmacia',
    'ciudad': 'tulancingo',
    'telefono': '7753496000',
    'color_hex': '#0066CC',
    'rating': 4.8,
    'estado': 'activo',
    'plan': 'vip',
    'desc': 'Medicamentos genéricos, patente y hospitalarios · Servicio a domicilio',
}

LOGO_ARCHIVO = 'logo_madrid.png'


def _v(v):
    """Convierte valor Python a formato Firestore REST."""
    if isinstance(v, bool): return {'booleanValue': v}
    if isinstance(v, int): return {'integerValue': str(v)}
    if isinstance(v, float): return {'doubleValue': v}
    return {'stringValue': str(v) if v else ''}


def _subir_foto(bkt, ruta, destino):
    """Sube una foto a Firebase Storage. Retorna URL publica o ''."""
    try:
        blob = bkt.blob(destino)
        blob.upload_from_filename(ruta, content_type='image/png')
        blob.make_public()
        return blob.public_url
    except Exception as e:
        print(f'    ⚠ Error subiendo foto: {e}')
        return ''


def main():
    if not os.path.exists(SA):
        print(f'ERROR: No se encontró {SA}')
        print('Necesitas el service account key de Firebase.')
        sys.exit(1)

    # Init Firebase
    cred = credentials.Certificate(SA)
    firebase_admin.initialize_app(cred, {'storageBucket': f'{PID}.firebasestorage.app'})
    bkt = storage.bucket()
    ses = AuthorizedSession(service_account.Credentials.from_service_account_file(
        SA, scopes=['https://www.googleapis.com/auth/datastore',
                    'https://www.googleapis.com/auth/cloud-platform']))

    # Verificar si Storage está habilitado
    storage_ok = False
    try:
        storage_ok = bkt.exists()
    except Exception:
        pass
    if not storage_ok:
        print('⚠ Firebase Storage no está habilitado. Se subirán solo datos a Firestore.')
        print('  Para habilitar: Firebase Console → Storage → Get started\n')

    print('=== Configurando 5 Farmacias Madrid como VIP ===\n')

    # 1. Subir logo (si Storage disponible)
    logo_path = os.path.join(FOTOS, LOGO_ARCHIVO)
    logo_url = ''
    if storage_ok and os.path.isfile(logo_path):
        logo_url = _subir_foto(bkt, logo_path, 'negocios/logo_madrid.png')
        if logo_url:
            print(f'  ✓ Logo subido: {logo_url}\n')

    # 2. Por cada sucursal: subir foto + actualizar Firestore
    ok = 0
    for suc in SUCURSALES:
        nid = suc['id']
        nombre = suc['nombre']
        print(f'  [{nid}] {nombre}')

        # Subir foto si Storage disponible
        foto_url = ''
        foto_path = os.path.join(FOTOS, suc['foto_archivo'])
        if storage_ok and os.path.isfile(foto_path):
            foto_url = _subir_foto(bkt, foto_path, f'negocios/{nid}/foto.jpg')
            if foto_url:
                print(f'    📷 Foto subida: {foto_url}')

        # Construir documento completo
        campos = {
            'nombre': nombre,
            'emoji': COMUN['emoji'],
            'categoria': COMUN['categoria'],
            'ciudad': COMUN['ciudad'],
            'zona': suc['direccion'],
            'direccion': suc['direccion'],
            'desc': COMUN['desc'],
            'horario': suc['horario'],
            'telefono': COMUN['telefono'],
            'rating': COMUN['rating'],
            'pedidos': suc['pedidos'],
            'color_hex': COMUN['color_hex'],
            'estado': COMUN['estado'],
            'plan': COMUN['plan'],
            'foto_url': foto_url,
            'banner_url': foto_url,
            'logo_url': logo_url,
            'lat': suc['lat'],
            'lng': suc['lng'],
        }

        # PATCH a Firestore
        mask = '&'.join(f'updateMask.fieldPaths={k}' for k in campos)
        resp = ses.patch(
            f'{FS}/negocios/{nid}?{mask}',
            json={'fields': {k: _v(v) for k, v in campos.items()}})

        if resp.status_code == 200:
            ok += 1
            print(f'    ✓ Firestore actualizado (plan: VIP)')
        else:
            print(f'    ✗ Error Firestore: {resp.status_code} - {resp.text}')
        print()

    print(f'=== {ok}/5 farmacias configuradas como VIP ===')
    if ok == 5:
        print('¡Todas las sucursales listas! 🎉')
    if not storage_ok:
        print('\nNOTA: Las fotos no se subieron. Habilita Storage y vuelve a correr el script.')


if __name__ == '__main__':
    main()
