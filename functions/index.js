const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors");
const { MercadoPagoConfig, Preference, Payment } = require("mercadopago");

admin.initializeApp();
const db = admin.firestore();

// ═══ CONFIG (via .env file) ═══
const MP_ACCESS_TOKEN = process.env.MERCADOPAGO_ACCESS_TOKEN || "APP_USR-1944384961399129-020805-fdfa75cab7f7b2d45ab664f6ce070e0a-3008510285";
const client = new MercadoPagoConfig({ accessToken: MP_ACCESS_TOKEN });
const ANTHROPIC_KEY = process.env.ANTHROPIC_API_KEY || "";

// CORS
const corsHandler = cors({
  origin: [
    "https://cargo-go-b5f77.web.app",
    "https://cargo-go-b5f77.firebaseapp.com",
    "https://farmacias-madrid.web.app",
    "https://farmacias-madrid.firebaseapp.com",
    "http://localhost:3000",
    "http://localhost:5000",
    "http://localhost:8080",
  ],
});

// ═══ Tulancingo zones ═══
const ZONAS = [
  { id: 1, nombre: "Centro", cp_inicio: "43600", cp_fin: "43609", precio_base: 35, ciudad: "tulancingo" },
  { id: 2, nombre: "La Floresta", cp_inicio: "43610", cp_fin: "43619", precio_base: 40, ciudad: "tulancingo" },
  { id: 3, nombre: "San Nicolás", cp_inicio: "43620", cp_fin: "43629", precio_base: 40, ciudad: "tulancingo" },
  { id: 4, nombre: "Jaltepec", cp_inicio: "43630", cp_fin: "43639", precio_base: 50, ciudad: "tulancingo" },
  { id: 5, nombre: "Santiago", cp_inicio: "43640", cp_fin: "43649", precio_base: 45, ciudad: "tulancingo" },
  { id: 6, nombre: "Huapalcalco", cp_inicio: "43650", cp_fin: "43659", precio_base: 55, ciudad: "tulancingo" },
  { id: 7, nombre: "CDMX Centro", cp_inicio: "06000", cp_fin: "06999", precio_base: 89, ciudad: "cdmx" },
  { id: 8, nombre: "CDMX Norte", cp_inicio: "07000", cp_fin: "07999", precio_base: 99, ciudad: "cdmx" },
  { id: 9, nombre: "CDMX Sur", cp_inicio: "14000", cp_fin: "14999", precio_base: 99, ciudad: "cdmx" },
  { id: 10, nombre: "Pachuca", cp_inicio: "42000", cp_fin: "42199", precio_base: 75, ciudad: "pachuca" },
];

// ════════════════════════════════════════════════════════════
// CARGO API – unified REST endpoint backed by Firestore
// URL: https://us-central1-cargo-go-b5f77.cloudfunctions.net/cargoApi
// ════════════════════════════════════════════════════════════
exports.cargoApi = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    const path = req.path;
    const method = req.method;

    try {
      // ── STATS ──
      if (path === "/api/stats" && method === "GET") {
        const [negSnap, pedSnap, entSnap, farmSnap] = await Promise.all([
          db.collection("negocios").count().get(),
          db.collection("pedidos").count().get(),
          db.collection("entregas").count().get(),
          db.collection("farmacia_productos").count().get(),
        ]);
        return res.json({
          entregas_hoy: entSnap.data().count || 0,
          negocios: negSnap.data().count || 0,
          pedidos_hoy: pedSnap.data().count || 0,
          productos_farmacia: farmSnap.data().count || 0,
          ingresos_hoy: 0,
          paquetes_hoy: 0,
          mudanzas_hoy: 0,
        });
      }

      // ── LOGIN ──
      if (path === "/api/login" && method === "POST") {
        const { usuario, password } = req.body;
        if (usuario === "admin" && password === "cargo2024") {
          return res.json({ ok: true, token: "cg-" + Date.now().toString(36), rol: "admin" });
        }
        return res.status(401).json({ error: "Credenciales inválidas" });
      }

      // ── NEGOCIOS ──
      if (path === "/api/negocios" && method === "GET") {
        const snap = await db.collection("negocios").orderBy("nombre").limit(200).get();
        const data = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
        return res.json(data);
      }

      if (path.match(/^\/api\/negocios\/([^/]+)$/) && method === "GET") {
        const id = path.split("/")[3];
        const doc = await db.collection("negocios").doc(id).get();
        if (!doc.exists) return res.status(404).json({ error: "No encontrado" });
        return res.json({ id: doc.id, ...doc.data() });
      }

      if (path.match(/^\/api\/negocios\/([^/]+)\/productos$/) && method === "GET") {
        const negId = path.split("/")[3];
        const doc = await db.collection("negocios").doc(negId).get();
        if (!doc.exists) return res.status(404).json({ error: "No encontrado" });
        return res.json(doc.data().productos || []);
      }

      if (path === "/api/negocios/registro" && method === "POST") {
        const data = req.body;
        data.creado = new Date().toISOString();
        data.activo = true;
        const ref = await db.collection("negocios").add(data);
        return res.json({ ok: true, id: ref.id });
      }

      // ── COTIZAR ──
      if (path === "/api/cotizar" && method === "POST") {
        const { cp, peso } = req.body;
        const zona = ZONAS.find((z) => cp >= z.cp_inicio && cp <= z.cp_fin);
        const base = zona ? zona.precio_base : 89;
        const pesoExtra = Math.max(0, (peso || 1) - 1) * 15;
        return res.json({
          zona: zona ? zona.nombre : "Zona extendida",
          precio_base: base,
          peso_extra: pesoExtra,
          total: base + pesoExtra,
          tiempo_estimado: zona && zona.ciudad === "tulancingo" ? "30-60 min" : "1-3 hrs",
        });
      }

      // ── ENVIOS ──
      if (path === "/api/envios" && method === "POST") {
        const data = req.body;
        data.fecha = new Date().toISOString();
        data.estado = "confirmado";
        data.folio = "CG-" + Date.now().toString(36).toUpperCase();
        const ref = await db.collection("envios").add(data);
        return res.json({ ok: true, id: ref.id, folio: data.folio });
      }

      // ── RASTREAR ──
      if (path.match(/^\/api\/rastrear\/(.+)$/) && method === "GET") {
        const folio = path.split("/")[3];
        const snap = await db.collection("envios").where("folio", "==", folio).limit(1).get();
        if (snap.empty) {
          const pedSnap = await db.collection("pedidos").where("numero_pedido", "==", folio).limit(1).get();
          if (pedSnap.empty) return res.status(404).json({ error: "Folio no encontrado" });
          const p = pedSnap.docs[0];
          return res.json({ id: p.id, ...p.data() });
        }
        const d = snap.docs[0];
        return res.json({ id: d.id, ...d.data() });
      }

      // ── HISTORIAL ──
      if (path === "/api/historial" && method === "GET") {
        const snap = await db.collection("pedidos").orderBy("created_at", "desc").limit(50).get();
        const data = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
        return res.json(data);
      }

      // ── ZONAS ──
      if (path === "/api/zonas" && method === "GET") {
        return res.json(ZONAS);
      }

      if (path.match(/^\/api\/detectar-zona\/(.+)$/) && method === "GET") {
        const cp = path.split("/")[3];
        const zona = ZONAS.find((z) => cp >= z.cp_inicio && cp <= z.cp_fin);
        if (zona) return res.json(zona);
        return res.json({ nombre: "Zona no registrada", precio_base: 89, ciudad: "otro" });
      }

      // ── ENTREGAS ──
      if (path === "/api/entregas" && method === "GET") {
        let q = db.collection("entregas");
        const estado = req.query.estado;
        const repId = req.query.repartidor_id;
        if (estado) q = q.where("estado", "==", estado);
        if (repId) q = q.where("repartidor_id", "==", repId);
        const snap = await q.orderBy("fecha", "desc").limit(100).get();
        const data = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
        return res.json(data);
      }

      if (path.match(/^\/api\/entregas\/([^/]+)$/) && method === "GET") {
        const id = path.split("/")[3];
        const doc = await db.collection("entregas").doc(id).get();
        if (!doc.exists) return res.status(404).json({ error: "No encontrada" });
        return res.json({ id: doc.id, ...doc.data() });
      }

      if (path.match(/^\/api\/entregas\/([^/]+)\/iniciar$/) && method === "POST") {
        const id = path.split("/")[3];
        await db.collection("entregas").doc(id).update({ estado: "en_camino", inicio: new Date().toISOString() });
        return res.json({ ok: true, estado: "en_camino" });
      }

      if (path.match(/^\/api\/entregas\/([^/]+)\/completar$/) && method === "POST") {
        const id = path.split("/")[3];
        await db.collection("entregas").doc(id).update({ estado: "completada", completada: new Date().toISOString() });
        return res.json({ ok: true, estado: "completada" });
      }

      // ── REPARTIDORES ──
      if (path === "/api/repartidores" && method === "GET") {
        const snap = await db.collection("repartidores").limit(50).get();
        const data = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
        return res.json(data);
      }

      if (path.match(/^\/api\/repartidor\/([^/]+)$/) && method === "GET") {
        const id = path.split("/")[3];
        const doc = await db.collection("repartidores").doc(id).get();
        if (!doc.exists) return res.status(404).json({ error: "No encontrado" });
        return res.json({ id: doc.id, ...doc.data() });
      }

      if (path.match(/^\/api\/stats\/([^/]+)$/) && method === "GET") {
        const repId = path.split("/")[3];
        const snap = await db.collection("entregas").where("repartidor_id", "==", repId).get();
        const total = snap.size;
        const completadas = snap.docs.filter((d) => d.data().estado === "completada").length;
        return res.json({ total, completadas, pendientes: total - completadas, repartidor_id: repId });
      }

      // ── FARMACIA ──
      if (path === "/api/farmacia/productos" && method === "GET") {
        const limite = parseInt(req.query.limite) || 50;
        const offset = parseInt(req.query.offset) || 0;
        const categoria = req.query.categoria;
        const q2 = req.query.q;
        let q = db.collection("farmacia_productos");
        if (categoria) q = q.where("categoria", "==", categoria);
        const snap = await q.limit(limite + offset).get();
        let data = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
        if (q2) {
          const lower = q2.toLowerCase();
          data = data.filter((p) => (p.nombre || "").toLowerCase().includes(lower) || (p.categoria || "").toLowerCase().includes(lower));
        }
        return res.json(data.slice(offset, offset + limite));
      }

      if (path === "/api/farmacia/buscar" && method === "GET") {
        const q2 = (req.query.q || "").toLowerCase();
        if (q2.length < 2) return res.json([]);
        const snap = await db.collection("farmacia_productos").limit(200).get();
        const data = snap.docs.map((d) => ({ id: d.id, ...d.data() })).filter((p) =>
          (p.nombre || "").toLowerCase().includes(q2) || (p.laboratorio || "").toLowerCase().includes(q2)
        );
        return res.json(data.slice(0, 20));
      }

      if (path === "/api/farmacia/categorias" && method === "GET") {
        const snap = await db.collection("farmacia_productos").limit(500).get();
        const cats = new Set();
        snap.docs.forEach((d) => { if (d.data().categoria) cats.add(d.data().categoria); });
        return res.json([...cats].sort().map((c, i) => ({ id: i + 1, nombre: c })));
      }

      if (path === "/api/farmacia/ofertas" && method === "GET") {
        const snap = await db.collection("farmacia_productos").where("en_oferta", "==", true).limit(30).get();
        const data = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
        return res.json(data);
      }

      if (path === "/api/farmacia/pedido" && method === "POST") {
        const data = req.body;
        data.fecha = new Date().toISOString();
        data.estado = "confirmado";
        const ref = await db.collection("pedidos").add(data);
        return res.json({ ok: true, id: ref.id });
      }

      if (path === "/api/farmacia/pedidos/stats" && method === "GET") {
        const snap = await db.collection("pedidos").get();
        const docs = snap.docs.map((d) => d.data());
        const confirmados = docs.filter((d) => d.status === "confirmado" || d.estado === "confirmado").length;
        const pagados = docs.filter((d) => d.status === "pagado" || d.estado === "pagado").length;
        const total = docs.reduce((s, d) => s + (d.total || 0), 0);
        return res.json({ total_pedidos: snap.size, confirmados, pagados, ingresos_total: total });
      }

      if (path === "/api/farmacia/pedidos" && method === "GET") {
        const estado = req.query.estado;
        let q = db.collection("pedidos").orderBy("created_at", "desc").limit(50);
        if (estado) q = db.collection("pedidos").where("status", "==", estado).limit(50);
        const snap = await q.get();
        const data = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
        return res.json(data);
      }

      if (path.match(/^\/api\/farmacia\/pedidos\/([^/]+)\/estado$/) && method === "PUT") {
        const id = path.split("/")[4];
        const { estado } = req.body;
        await db.collection("pedidos").doc(id).update({ status: estado, updated_at: admin.firestore.FieldValue.serverTimestamp() });
        return res.json({ ok: true, estado });
      }

      if (path.match(/^\/api\/farmacia\/pedidos\/([^/]+)$/) && method === "GET") {
        const id = path.split("/")[4];
        const doc = await db.collection("pedidos").doc(id).get();
        if (!doc.exists) return res.status(404).json({ error: "No encontrado" });
        return res.json({ id: doc.id, ...doc.data() });
      }

      // ── 404 ──
      return res.status(404).json({ error: "Endpoint not found", path });

    } catch (error) {
      console.error("cargoApi error:", error);
      return res.status(500).json({ error: error.message });
    }
  });
});

// ════════════════════════════════════════════
// Normalize Firestore data (one-time call)
// GET /normalizeData
// ════════════════════════════════════════════
exports.normalizeData = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    try {
      const snap = await db.collection("negocios").get();
      const batch = db.batch();
      let updated = 0;

      snap.docs.forEach((doc) => {
        const d = doc.data();
        const updates = {};

        // Normalize lat/lng to numbers
        if (d.lat !== undefined && typeof d.lat !== "number") {
          updates.lat = parseFloat(d.lat) || 20.0833;
        }
        if (d.lng !== undefined && typeof d.lng !== "number") {
          updates.lng = parseFloat(d.lng) || -98.3619;
        }
        // Default lat/lng for Tulancingo
        if (d.lat === undefined && d.lng === undefined) {
          updates.lat = 20.0833 + (Math.random() - 0.5) * 0.02;
          updates.lng = -98.3619 + (Math.random() - 0.5) * 0.02;
        }

        // Fill empty horario
        if (!d.horario || d.horario === "") {
          const horarios = [
            "Lun-Sáb 8:00-20:00",
            "Lun-Dom 9:00-21:00",
            "Lun-Vie 7:00-19:00",
            "Lun-Sáb 10:00-20:00",
            "Lun-Dom 8:00-22:00",
          ];
          updates.horario = horarios[Math.floor(Math.random() * horarios.length)];
        }

        // Fill empty telefono with placeholder (admin-only)
        if (!d.telefono || d.telefono === "") {
          updates.telefono = "";
        }

        // Ensure rating is number
        if (d.calificacion !== undefined && typeof d.calificacion !== "number") {
          updates.calificacion = parseFloat(d.calificacion) || 4.5;
        }
        if (d.rating !== undefined && typeof d.rating !== "number") {
          updates.rating = parseFloat(d.rating) || 4.5;
        }

        // Ensure ciudad
        if (!d.ciudad) {
          updates.ciudad = "tulancingo";
        }

        if (Object.keys(updates).length > 0) {
          batch.update(doc.ref, updates);
          updated++;
        }
      });

      await batch.commit();
      return res.json({ ok: true, total: snap.size, updated });
    } catch (error) {
      console.error("normalizeData error:", error);
      return res.status(500).json({ error: error.message });
    }
  });
});

// ════════════════════════════════════════════
// POST /createMPPreference
// ════════════════════════════════════════════
exports.createMPPreference = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== "POST") {
      return res.status(405).json({ error: "Method not allowed" });
    }

    try {
      const { items, payer, back_urls } = req.body;

      if (!items || !items.length) {
        return res.status(400).json({ error: "No items provided" });
      }

      const orderNumber = `FM-${Date.now().toString(36).toUpperCase()}`;

      const orderRef = await db.collection("pedidos").add({
        numero_pedido: orderNumber,
        items: items.map((i) => ({ title: i.title, quantity: i.quantity, unit_price: i.unit_price })),
        total: items.reduce((s, i) => s + i.unit_price * i.quantity, 0),
        envio: 0,
        payer: { name: payer?.name || "", email: payer?.email || "", phone: payer?.phone?.number || "" },
        status: "pendiente_pago",
        mercadopago_preference_id: null,
        mercadopago_payment_id: null,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      const preference = new Preference(client);
      const mpItems = items.map((i) => ({ title: i.title, quantity: i.quantity, unit_price: Number(i.unit_price), currency_id: "MXN" }));

      const result = await preference.create({
        body: {
          items: mpItems,
          payer: {
            name: payer?.name || "",
            email: payer?.email || "comprador@farmacias-madrid.com",
            phone: { area_code: "52", number: payer?.phone?.number || "" },
          },
          back_urls: {
            success: back_urls?.success || "https://farmacias-madrid.web.app/?payment=success",
            failure: back_urls?.failure || "https://farmacias-madrid.web.app/?payment=failure",
            pending: back_urls?.pending || "https://farmacias-madrid.web.app/?payment=pending",
          },
          auto_return: "approved",
          external_reference: orderRef.id,
          notification_url: "https://us-central1-cargo-go-b5f77.cloudfunctions.net/webhookMercadoPago",
          statement_descriptor: "FARMACIAS MADRID",
        },
      });

      await orderRef.update({ mercadopago_preference_id: result.id });

      return res.status(200).json({
        init_point: result.init_point,
        sandbox_init_point: result.sandbox_init_point,
        preference_id: result.id,
        order_id: orderRef.id,
        order_number: orderNumber,
      });
    } catch (error) {
      console.error("Error creating preference:", error);
      return res.status(500).json({ error: "Error creating payment preference", detail: error.message });
    }
  });
});

// ════════════════════════════════════════════
// POST /webhookMercadoPago
// ════════════════════════════════════════════
exports.webhookMercadoPago = functions.https.onRequest(async (req, res) => {
  try {
    const { type, data } = req.body;

    if (type === "payment") {
      const payment = new Payment(client);
      const paymentInfo = await payment.get({ id: data.id });
      const externalRef = paymentInfo.external_reference;
      if (!externalRef) return res.status(200).send("OK");

      const statusMap = {
        approved: "pagado", pending: "pendiente_pago", authorized: "pagado",
        in_process: "pendiente_pago", in_mediation: "pendiente_pago",
        rejected: "cancelado", cancelled: "cancelado", refunded: "cancelado",
      };
      const newStatus = statusMap[paymentInfo.status] || "pendiente_pago";

      await db.collection("pedidos").doc(externalRef).update({
        status: newStatus,
        mercadopago_payment_id: String(data.id),
        mercadopago_status: paymentInfo.status,
        mercadopago_status_detail: paymentInfo.status_detail || "",
        mercadopago_payment_method: paymentInfo.payment_method_id || "",
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log(`Order ${externalRef} updated to ${newStatus}`);
    }

    return res.status(200).send("OK");
  } catch (error) {
    console.error("Webhook error:", error);
    return res.status(200).send("OK");
  }
});

// ════════════════════════════════════════════
// Helper: call Anthropic Claude API
// ════════════════════════════════════════════
async function callClaude(systemPrompt, messages) {
  if (!ANTHROPIC_KEY) throw new Error("ANTHROPIC_API_KEY not configured");
  const apiMessages = messages.map((m) => ({ role: m.role === "user" ? "user" : "assistant", content: m.content }));
  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: { "Content-Type": "application/json", "x-api-key": ANTHROPIC_KEY, "anthropic-version": "2023-06-01" },
    body: JSON.stringify({ model: "claude-sonnet-4-5-20250929", max_tokens: 400, system: systemPrompt, messages: apiMessages }),
  });
  if (!response.ok) throw new Error(`Anthropic ${response.status}`);
  const data = await response.json();
  const text = data.content?.[0]?.text || "";
  const cleaned = text.replace(/```json|```/g, "").trim();
  try { return JSON.parse(cleaned); } catch (e) { return { text: cleaned }; }
}

// POST /chefCrudo
exports.chefCrudo = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== "POST") return res.status(405).json({ error: "Method not allowed" });
    try {
      const { messages, systemPrompt } = req.body;
      if (!messages || !Array.isArray(messages)) return res.status(400).json({ error: "messages required" });
      const result = await callClaude(systemPrompt || "Eres el Chef de CRUDO.", messages);
      return res.json(result);
    } catch (error) {
      console.error("chefCrudo:", error.message);
      return res.status(500).json({ mensaje: "El chef está ocupado.", platillos_recomendados: [], accion: "platicar" });
    }
  });
});

// POST /sharazanAI
exports.sharazanAI = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== "POST") return res.status(405).json({ error: "Method not allowed" });
    try {
      const { messages, systemPrompt } = req.body;
      if (!messages || !Array.isArray(messages)) return res.status(400).json({ error: "messages required" });
      const result = await callClaude(systemPrompt || "Eres Sharazan.", messages);
      return res.json(result);
    } catch (error) {
      console.error("sharazanAI:", error.message);
      return res.status(500).json({ mensaje: "Sharazan está pensando.", perfumes: [] });
    }
  });
});
