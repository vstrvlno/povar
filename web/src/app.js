/* ===== Утилиты ===== */
const esc = s => String(s ?? "").replace(/[&<>"']/g, c => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]));
const store = {
  get(k, d) { try { const v = localStorage.getItem("povar." + k); return v ? JSON.parse(v) : d; } catch { return d; } },
  set(k, v) { try { localStorage.setItem("povar." + k, JSON.stringify(v)); } catch {} }
};
const plural = (n, a, b, c) => { const n10 = n % 10, n100 = n % 100; return n10 === 1 && n100 !== 11 ? a : (n10 >= 2 && n10 <= 4 && (n100 < 12 || n100 > 14)) ? b : c; };
const fmtNum = v => String(+v.toFixed(2)).replace(".", ",");
const fmtMin = m => m < 60 ? m + " мин" : (m % 60 ? Math.floor(m / 60) + " ч " + (m % 60) + " мин" : m / 60 + " ч");
const fmtClock = s => { s = Math.max(0, Math.ceil(s)); const h = Math.floor(s / 3600), m = Math.floor(s % 3600 / 60), x = s % 60, p = n => String(n).padStart(2, "0"); return h ? h + ":" + p(m) + ":" + p(x) : p(m) + ":" + p(x); };
const DIFF = {1:"Легко", 2:"Средне", 3:"Сложно"};
const UNITS = {g:"г", ml:"мл", pc:"шт", tbsp:"ст. л.", tsp:"ч. л.", pinch:"щеп."};
const HEAT = {1:["Слабый огонь",2,3], 2:["Средний огонь",4,5], 3:["Выше среднего",6,7], 4:["Сильный огонь",8,9]};
const lower = id => ING[id][0].toLowerCase();

const I = (d, extra = "") => `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" ${extra}>${d}</svg>`;
const ICON = {
  book: I('<path d="M4 5a2 2 0 0 1 2-2h13v16H6a2 2 0 0 0-2 2z"/><path d="M4 19V5"/><path d="M9 7h6"/>'),
  fridge: I('<rect x="5" y="2.5" width="14" height="19" rx="2"/><path d="M5 10h14M9 6v1.5M9 13v3"/>'),
  bulb: I('<path d="M9 18h6M10 21h4"/><path d="M12 3a6 6 0 0 0-3.5 10.9c.6.5 1 1.2 1 2V16h5v-.1c0-.8.4-1.5 1-2A6 6 0 0 0 12 3z"/>'),
  timer: I('<circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2M10 2h4"/>'),
  clock: I('<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>'),
  user: I('<circle cx="12" cy="8" r="3.5"/><path d="M5 20c1-3.5 4-5 7-5s6 1.5 7 5"/>'),
  search: I('<circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/>'),
  camera: I('<path d="M3 8a2 2 0 0 1 2-2h2.5l1.5-2h6l1.5 2H19a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><circle cx="12" cy="13" r="3.5"/>'),
  image: I('<rect x="3" y="4" width="18" height="16" rx="2"/><circle cx="9" cy="10" r="2"/><path d="m21 16-5-5-9 9"/>'),
  play: I('<path d="M7 4.5v15l12-7.5z" fill="currentColor"/>'),
  pause: I('<path d="M8 5v14M16 5v14" stroke-width="3"/>'),
  reset: I('<path d="M4 12a8 8 0 1 0 2.4-5.7"/><path d="M4 4v4h4"/>'),
  x: I('<path d="M6 6l12 12M18 6 6 18"/>'),
  back: I('<path d="m15 5-7 7 7 7"/>'),
  next: I('<path d="m9 5 7 7-7 7"/>'),
  thermo: I('<path d="M14 14.8V5a2 2 0 0 0-4 0v9.8a4 4 0 1 0 4 0z"/><path d="M12 10v6"/>'),
  chef: I('<path d="M7 14v6h10v-6"/><path d="M7 14a4 4 0 0 1-1-7.9A5 5 0 0 1 12 3a5 5 0 0 1 6 3.1A4 4 0 0 1 17 14z"/><path d="M7 17h10"/>'),
  trash: I('<path d="M4 7h16M9 7V4h6v3M6 7l1 13h10l1-13"/>'),
  star: I('<path d="m12 3 2.7 5.6 6.1.9-4.4 4.3 1 6.1L12 17l-5.4 2.9 1-6.1L3.2 9.5l6.1-.9z"/>'),
  starFill: I('<path d="m12 3 2.7 5.6 6.1.9-4.4 4.3 1 6.1L12 17l-5.4 2.9 1-6.1L3.2 9.5l6.1-.9z" fill="currentColor"/>'),
  cart: I('<path d="M3 4h2l2.5 11h11L21 7H6.2"/><circle cx="9" cy="19" r="1.4"/><circle cx="17" cy="19" r="1.4"/>'),
  link: I('<path d="M10 14a4 4 0 0 0 5.7 0l3-3a4 4 0 0 0-5.7-5.7l-1 1"/><path d="M14 10a4 4 0 0 0-5.7 0l-3 3a4 4 0 0 0 5.7 5.7l1-1"/>'),
  check: I('<path d="m5 12 5 5L20 7"/>'),
  leaf: I('<path d="M5 20c0-9 5-14 14-15-1 9-6 14-14 15z"/><path d="M5 20c3-5 6-8 10-10"/>'),
  plus: I('<path d="M12 5v14M5 12h14"/>'),
  info: I('<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/>')
};

/* ===== Данные рецептов ===== */
function parseIng(s) {
  const [left, note] = s.split("|");
  const t = left.trim().split(/\s+/);
  const base = {id: t[0], optional: t.includes("?"), note: note ? note.trim() : ""};
  return t[1] === "tt" ? {...base, tt: true} : {...base, amount: parseFloat(t[1]), unit: t[2]};
}
const MEATY = new Set(Object.keys(ING).filter(id => ING[id][2] === "meat"));
const RECIPES = R.map(r => {
  const ings = r.i.map(parseIng);
  const steps = r.st.map(([h, m, text, temp, par]) => ({h, m: m || 0, text, temp: temp || 0, par: !!par}));
  const ware = r.k.split(" ");
  if (steps.some(s => s.h === 5) && !ware.includes("oven")) ware.unshift("oven");
  const total = r.p + steps.filter(s => !s.par).reduce((a, s) => a + s.m, 0);
  const active = r.p + steps.filter(s => !s.par && s.h !== 0).reduce((a, s) => a + s.m, 0);
  const key = [...new Set(ings.filter(x => !x.optional && !STAPLES.has(x.id)).map(x => x.id))];
  const tags = [];
  if (!ings.some(x => !x.optional && MEATY.has(x.id))) tags.push("veg");
  if (total <= 30) tags.push("quick");
  if (steps.some(s => s.h === 5)) tags.push("oven");
  if (!steps.some(s => s.h > 0)) tags.push("nocook");
  if (key.length <= 5) tags.push("few");
  return {...r, ings, steps, ware, total, active, key, tags, tips: r.t || []};
});
const BY_ID = Object.fromEntries(RECIPES.map(r => [r.id, r]));
const TAGS = {veg:["Без мяса", ICON.leaf], quick:["До 30 минут", ICON.clock], oven:["Духовка", ICON.thermo], nocook:["Без плиты", ""], few:["До 5 продуктов", ""]};
const TAG_WORDS = {veg:"вегетарианское постное без мяса овощное", quick:"быстро быстрый быстрое скорое простое легкое", oven:"духовка в духовке запеченное печеное", nocook:"без плиты без готовки холодное", few:"простое"};
const FREQUENT = ["egg", "onion", "potato", "carrot", "milk", "butter", "chicken", "tomato", "cucumber", "flour", "rice", "pasta", "cheese", "sourCream", "garlic", "mince", "mushrooms", "cabbage", "beet", "apple"];

/* Поисковые индексы */
const words = s => norm(s).split(" ").filter(Boolean);
const RECIPE_INDEX = RECIPES.map(r => ({ref: r, fields: [
  {w: 0, words: words(r.n)},
  {w: 1, words: words(r.a || "")},
  {w: 2, words: [...new Set(r.tags.flatMap(t => words(TAG_WORDS[t])))]},
  {w: 3, words: [...new Set(r.ings.flatMap(x => [...words(ING[x.id][0]), ...words(ALIAS[x.id] || "")]))]},
  {w: 6, words: words(RCATS[r.c])}
]}));
const ING_INDEX = Object.keys(ING).filter(id => !STAPLES.has(id)).map(id => ({ref: {id, name: ING[id][0]}, fields: [
  {w: 0, words: words(ING[id][0])}, {w: 0.5, words: words(ALIAS[id] || "")}, {w: 6, words: words(CATS[ING[id][2]])}
], boost: FREQUENT.includes(id) || ["fish", "beef", "pork", "bread", "sugar"].includes(id) ? 0.6 : 0}));

/* ===== Состояние ===== */
const S = {
  pantry: new Set(store.get("pantry", [])),
  favs: new Set(store.get("favs", [])),
  shop: new Set(store.get("shop", [])),
  recent: store.get("recent", []),
  servings: store.get("servings", {}),
  done: {},
  cat: "all", q: "", tag: "", sort: "cat", pq: "",
  timers: store.get("timers", []),
  scan: null, ai: {text: "", busy: false, err: ""}, cook: null
};
const has = id => S.pantry.has(id) || STAPLES.has(id);
const missing = r => r.key.filter(id => !has(id));
const save = () => { store.set("pantry", [...S.pantry]); store.set("favs", [...S.favs]); store.set("shop", [...S.shop]); store.set("recent", S.recent); store.set("servings", S.servings); };
const saveTimers = () => store.set("timers", S.timers);

let toastTimer = null;
function toast(msg, action) {
  const el = document.getElementById("toast");
  el.innerHTML = `<span>${esc(msg)}</span>${action ? `<a href="${action.href}">${esc(action.label)}</a>` : ""}`;
  el.hidden = false; el.classList.add("show");
  clearTimeout(toastTimer); toastTimer = setTimeout(() => { el.classList.remove("show"); setTimeout(() => el.hidden = true, 300); }, 2800);
}

/* ===== ИИ: Claude через просмотрщик или собственный ключ ===== */
const STANDALONE = !window.claude;
let samplePromise = null;
const getSample = () => {
  if (STANDALONE) return Promise.resolve(null);
  if (!samplePromise) samplePromise = window.claude.use("sample").catch(() => null);
  return samplePromise;
};
const AI = {ready: false, images: false};
getSample().then(async s => {
  AI.ready = !!s || (STANDALONE && !!store.get("apikey", ""));
  if (s) { const lim = await s.limits().catch(() => null); AI.images = !!lim?.images; }
  else AI.images = AI.ready;
  render();
});
const AI_ERR = {
  not_granted: "Доступ к Claude не разрешён. Разрешите его в меню страницы и попробуйте снова.",
  rate_limited: "Слишком много запросов подряд. Подождите минуту.",
  images_unavailable: "В этом просмотре нельзя отправлять фото.",
  no_ai: "Распознавание недоступно: нужен доступ к Claude.",
  cancelled: "Запрос остановлен."
};
const aiErr = e => AI_ERR[e?.code] || e?.message || "Не получилось связаться с Claude. Попробуйте ещё раз.";

async function shrinkToBase64(file) {
  const url = URL.createObjectURL(file);
  try {
    const img = await new Promise((ok, bad) => { const im = new Image(); im.onload = () => ok(im); im.onerror = bad; im.src = url; });
    const k = Math.min(1, 1280 / Math.max(img.naturalWidth, img.naturalHeight));
    const c = document.createElement("canvas");
    c.width = Math.round(img.naturalWidth * k); c.height = Math.round(img.naturalHeight * k);
    c.getContext("2d").drawImage(img, 0, 0, c.width, c.height);
    return c.toDataURL("image/jpeg", 0.8).split(",")[1];
  } finally { URL.revokeObjectURL(url); }
}
async function askClaude(prompt, {image, onText} = {}) {
  const s = await getSample();
  if (s) {
    const opts = {};
    if (image) opts.images = [image];
    if (onText) opts.onText = ({text}) => onText(text);
    const {text} = await s(prompt, opts);
    return text;
  }
  const key = STANDALONE ? store.get("apikey", "") : "";
  if (!key) throw {code: "no_ai"};
  const content = [];
  if (image) content.push({type: "image", source: {type: "base64", media_type: "image/jpeg", data: await shrinkToBase64(image)}});
  content.push({type: "text", text: prompt});
  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {"content-type": "application/json", "x-api-key": key, "anthropic-version": "2023-06-01", "anthropic-dangerous-direct-browser-access": "true"},
    body: JSON.stringify({model: "claude-opus-5-5", max_tokens: 1500, messages: [{role: "user", content}]})
  });
  const json = await res.json().catch(() => ({}));
  if (!res.ok) throw {message: "Ошибка Claude API: " + (json?.error?.message || res.status)};
  const text = (json.content || []).map(b => b.text || "").join("");
  if (onText) onText(text);
  return text;
}

/* ===== Распознавание фото ===== */
async function handleScan(file) {
  if (!file) return;
  if (S.scan?.url) URL.revokeObjectURL(S.scan.url);
  S.scan = {url: URL.createObjectURL(file), status: "loading", found: [], sel: new Set(), err: ""};
  render();
  const list = Object.entries(ING).filter(([id]) => !STAPLES.has(id)).map(([id, v]) => `${id} — ${v[0]}`).join("\n");
  const prompt = `На фото — продукты (холодильник, стол, пакет с покупками). Определи, какие продукты из списка ниже видны на фото, включая продукты в упаковках с читаемыми этикетками.
Ответь ТОЛЬКО JSON-массивом идентификаторов из списка, без пояснений. Пример: ["egg","tomato"]. Если ничего не видно — ответь [].

Список (id — название):
${list}`;
  try {
    const text = await askClaude(prompt, {image: file});
    const a = text.indexOf("["), b = text.lastIndexOf("]");
    let ids = [];
    if (a >= 0 && b > a) { try { ids = JSON.parse(text.slice(a, b + 1)); } catch {} }
    ids = [...new Set(ids.filter(id => typeof id === "string" && ING[id] && !STAPLES.has(id)))];
    S.scan.found = ids; S.scan.sel = new Set(ids); S.scan.status = "done";
  } catch (e) {
    S.scan.status = "error"; S.scan.err = aiErr(e);
  }
  render();
}

/* ===== Подбор и советы ===== */
function matches() {
  return RECIPES.map(r => { const miss = missing(r); return {r, miss, have: r.key.length - miss.length}; })
    .sort((a, b) => a.miss.length - b.miss.length || b.have / (b.r.key.length || 1) - a.have / (a.r.key.length || 1) || a.r.total - b.r.total);
}
function unlockList(all) {
  const cnt = {};
  all.filter(m => m.miss.length && m.miss.length <= 2).forEach(m => m.miss.forEach(id => cnt[id] = (cnt[id] || 0) + (m.miss.length === 1 ? 2 : 1)));
  return Object.entries(cnt).sort((a, b) => b[1] - a[1]).slice(0, 6).map(([id]) => ({id, n: all.filter(m => m.miss.length <= 2 && m.miss.includes(id)).length}));
}
function adviceLines(all) {
  const lines = [];
  const ready = all.filter(m => !m.miss.length);
  if (ready.length) {
    const fast = ready.reduce((a, b) => a.r.total <= b.r.total ? a : b);
    lines.push(`У вас есть всё для ${ready.length} ${plural(ready.length, "блюда", "блюд", "блюд")}. Быстрее всего — «${fast.r.n}», ${fmtMin(fast.r.total)}.`);
  } else {
    const best = all.find(m => m.miss.length === 1) || all.find(m => m.have > 0);
    if (best) lines.push(`Докупите ${best.miss.map(lower).join(", ")} — и можно готовить «${best.r.n}».`);
    else lines.push("Продуктов пока мало. Чаще всего в рецептах нужны яйца, лук, картофель, морковь и макароны.");
  }
  const fresh = [...S.pantry].filter(id => PERISHABLE.has(id));
  if (fresh.length) {
    const use = all.find(m => m.miss.length <= 1 && m.r.key.some(id => fresh.includes(id)));
    const names = fresh.slice(0, 5).map(lower).join(", ");
    lines.push(use ? `Сначала используйте скоропортящееся (${names}) — например, в «${use.r.n}».` : `Сначала используйте скоропортящееся: ${names}.`);
  }
  return lines;
}
async function askChef() {
  if (S.ai.busy) return;
  S.ai = {text: "", busy: true, err: ""};
  render();
  const items = [...S.pantry].map(lower).join(", ");
  const prompt = `Ты — опытный домашний повар. У меня дома есть: ${items}. Также есть соль, перец, растительное масло, вода и специи.
Предложи 3 блюда, которые можно приготовить прямо сейчас только из этого. Для каждого блюда:
— название;
— одна фраза, почему оно подходит;
— 3–4 коротких шага, где указаны сила огня (слабый/средний/сильный или духовка с °C) и время в минутах;
— на сколько персон получится.
Пиши по-русски, просто, без markdown-разметки (без #, ** и таблиц). Между блюдами — пустая строка.`;
  try {
    await askClaude(prompt, {onText: t => { S.ai.text = t; const el = document.getElementById("aiOut"); if (el) el.textContent = t; }});
  } catch (e) { S.ai.err = aiErr(e); }
  S.ai.busy = false;
  render();
}

/* ===== Таймеры ===== */
const tLeft = t => t.done ? 0 : t.end ? (t.end - Date.now()) / 1000 : t.left;
const findTimer = title => S.timers.find(t => t.title === title);
function startTimer(title, sec) {
  if (!(sec > 0)) return;
  S.timers.unshift({id: Math.random().toString(36).slice(2, 9), title, dur: sec, end: Date.now() + sec * 1000, left: sec, done: false});
  saveTimers(); unlockAudio(); render();
  toast(`Таймер «${title}» запущен`, {href: "#timers", label: "Таймеры"});
}
function timerAct(act, id) {
  const t = S.timers.find(x => x.id === id); if (!t) return;
  if (act === "pause" && t.end) { t.left = tLeft(t); t.end = null; }
  if (act === "resume" && !t.end && !t.done) t.end = Date.now() + t.left * 1000;
  if (act === "plus") {
    if (t.done) { t.done = false; t.dur = 60; t.end = Date.now() + 60000; }
    else if (t.end) { t.end += 60000; t.dur += 60; }
    else { t.left += 60; t.dur += 60; }
  }
  if (act === "restart") { t.done = false; t.end = Date.now() + t.dur * 1000; t.left = t.dur; }
  if (act === "del") S.timers = S.timers.filter(x => x !== t);
  saveTimers(); render();
}
let audio = null;
function unlockAudio() { try { if (!audio) audio = new (window.AudioContext || window.webkitAudioContext)(); if (audio.state === "suspended") audio.resume(); } catch {} }
function alarm() {
  try {
    if (audio) {
      const now = audio.currentTime;
      for (let i = 0; i < 4; i++) {
        const o = audio.createOscillator(), g = audio.createGain();
        o.frequency.value = i % 2 ? 660 : 880; o.type = "sine";
        g.gain.setValueAtTime(0.0001, now + i * 0.35); g.gain.exponentialRampToValueAtTime(0.35, now + i * 0.35 + 0.02);
        g.gain.exponentialRampToValueAtTime(0.0001, now + i * 0.35 + 0.28);
        o.connect(g).connect(audio.destination); o.start(now + i * 0.35); o.stop(now + i * 0.35 + 0.3);
      }
    }
  } catch {}
  try { navigator.vibrate && navigator.vibrate([300, 150, 300, 150, 300]); } catch {}
}
const RING = 150.8;
function tick() {
  let fired = false;
  for (const t of S.timers) if (t.end && !t.done && t.end <= Date.now()) { t.done = true; t.end = null; t.left = 0; fired = true; }
  if (fired) { saveTimers(); alarm(); render(); return; }
  document.querySelectorAll("[data-tclock]").forEach(el => { const t = S.timers.find(x => x.id === el.dataset.tclock); if (t) el.textContent = fmtClock(tLeft(t)); });
  document.querySelectorAll("[data-tring]").forEach(el => { const t = S.timers.find(x => x.id === el.dataset.tring); if (t) el.style.strokeDashoffset = RING * (tLeft(t) / t.dur); });
  const doneN = S.timers.filter(t => t.done).length;
  document.title = doneN ? "⏰ Готово! · Повар" : "Повар";
}
setInterval(tick, 250);

/* ===== Фрагменты интерфейса ===== */
function heatHTML(h, temp) {
  if (h === 5) return `<span class="oven">${ICON.thermo}Духовка ${temp || 180} °C</span>`;
  if (!h) return `<span class="time">Без огня</span>`;
  const [name, lo, hi] = HEAT[h];
  let bars = ""; for (let i = 1; i <= 9; i++) bars += `<i class="${i <= hi ? "l" + h : ""}"></i>`;
  return `<span class="heat"><span class="dial" aria-hidden="true">${bars}</span>${name}<span class="hint">${lo}–${hi} из 9</span></span>`;
}
function amount(x, f) {
  if (x.tt) return {a: "по вкусу", g: ""};
  const v = x.amount * f; let a, g = "";
  if (x.unit === "pc" || x.unit === "tbsp" || x.unit === "tsp") {
    a = fmtNum(Math.max(0.5, Math.round(v * 2) / 2)) + " " + UNITS[x.unit];
    const gpp = x.unit === "pc" ? ING[x.id][3] : x.unit === "tbsp" ? 15 : 5;
    if (gpp) g = "≈ " + Math.round(v * gpp) + " г";
  } else if (x.unit === "pinch") a = fmtNum(Math.max(1, Math.round(v))) + " щеп.";
  else {
    const r = v >= 100 ? Math.round(v / 5) * 5 : Math.max(1, Math.round(v));
    a = r >= 1000 ? fmtNum(Math.round(r / 100) / 10) + (x.unit === "g" ? " кг" : " л") : r + " " + UNITS[x.unit];
  }
  return {a, g};
}
const tagsHTML = r => r.tags.filter(t => t !== "few").map(t => `<span class="tag t-${t}">${TAGS[t][1]}${TAGS[t][0]}</span>`).join("");
function cardHTML(r, extra = "") {
  const miss = missing(r), haveN = r.key.length - miss.length;
  const status = S.pantry.size && !extra ? `<div class="have ${miss.length ? "part" : "ok"}">${miss.length ? `Есть ${haveN} из ${r.key.length} продуктов` : "Все продукты есть"}</div>` : "";
  return `<a class="card" href="#r-${r.id}"><div class="dish" aria-hidden="true">${r.e}</div><div class="card-body">
    <div class="card-top"><div class="card-title">${esc(r.n)}</div><button class="fav ${S.favs.has(r.id) ? "on" : ""}" data-act="fav" data-id="${r.id}" aria-label="${S.favs.has(r.id) ? "Убрать из избранного" : "В избранное"}" aria-pressed="${S.favs.has(r.id)}">${S.favs.has(r.id) ? ICON.starFill : ICON.star}</button></div>
    <div class="meta"><span>${ICON.clock}${fmtMin(r.total)}</span><span>${ICON.user}${r.s} ${plural(r.s, "порция", "порции", "порций")}</span><span>${DIFF[r.d]}</span></div>
    <div class="tags">${tagsHTML(r)}</div>
    ${extra || status}</div></a>`;
}
function filtered() {
  const q = S.q.trim();
  let hint = "", layoutFixed = false, list;
  if (q) { const res = runSearch(RECIPE_INDEX, q); list = res.results.map(x => x.item); hint = res.hint; layoutFixed = res.layoutFixed; }
  else list = RECIPES;
  list = list.filter(r => (S.cat === "all" || (S.cat === "fav" ? S.favs.has(r.id) : r.c === S.cat)) && (!S.tag || r.tags.includes(S.tag) || (S.tag === "mine" && !missing(r).length)));
  if (!q || S.sort !== "cat") {
    if (S.sort === "time") list = [...list].sort((a, b) => a.total - b.total);
    if (S.sort === "name") list = [...list].sort((a, b) => a.n.localeCompare(b.n, "ru"));
    if (S.sort === "match") list = [...list].sort((a, b) => missing(a).length - missing(b).length || a.total - b.total);
  }
  return {list, hint, layoutFixed, q};
}
function sectionHTML(title, items, mapper = r => cardHTML(r)) {
  return items.length ? `<section class="block"><div class="section-title"><h2>${title}</h2><span class="num">${items.length}</span></div><div class="grid">${items.map(mapper).join("")}</div></section>` : "";
}
function resultsHTML() {
  const {list, hint, layoutFixed, q} = filtered();
  let head = "";
  if (q && (hint || layoutFixed)) head = `<div class="hintbar">${ICON.info}<span>${layoutFixed ? "Похоже, включена английская раскладка. " : ""}${hint ? `Показываю результаты для «<b>${esc(hint)}</b>»` : ""}</span></div>`;
  if (!list.length) {
    const tips = ["борщ", "курица", "картошка", "быстрый завтрак", "без мяса"].filter(t => norm(t) !== norm(q));
    return head + `<div class="empty"><p>По запросу «${esc(q)}» ничего не нашлось${S.cat !== "all" || S.tag ? " в выбранном разделе" : ""}.</p>
      <p class="muted">Попробуйте: ${tips.map(t => `<button class="linkbtn" data-act="setq" data-v="${t}">${t}</button>`).join(", ")}${S.cat !== "all" || S.tag ? ` — или <button class="linkbtn" data-act="clearf">сбросьте фильтры</button>` : ""}.</p></div>`;
  }
  if (S.cat === "all" && !q && S.sort === "cat") {
    const recent = S.recent.map(id => BY_ID[id]).filter(r => r && list.includes(r)).slice(0, 4);
    const favs = list.filter(r => S.favs.has(r.id)).slice(0, 8);
    return head + sectionHTML("Недавно смотрели", recent) + sectionHTML("Избранное", favs)
      + Object.entries(RCATS).map(([c, name]) => sectionHTML(name, list.filter(r => r.c === c))).join("");
  }
  return head + `<div class="label">Найдено: ${list.length}</div><div class="grid">${list.map(r => cardHTML(r)).join("")}</div>`;
}

/* ===== Экраны ===== */
function menuView() {
  const counts = {all: RECIPES.length, fav: S.favs.size}; RECIPES.forEach(r => counts[r.c] = (counts[r.c] || 0) + 1);
  const chip = (v, n, cnt) => `<button class="chip" data-act="cat" data-v="${v}" aria-pressed="${S.cat === v}">${n}${cnt ? ` <small>${cnt}</small>` : ""}</button>`;
  const tagChip = (v, n) => `<button class="chip ghost" data-act="tag" data-v="${v}" aria-pressed="${S.tag === v}">${n}</button>`;
  return `<div class="page-head"><div><h1>Меню</h1><p class="muted">${RECIPES.length} блюд. Ищите по названию или продукту — опечатки и раскладку поправлю сам.</p></div></div>
  <div class="toolbar">
    <label class="field grow">${ICON.search}<input id="q" type="search" placeholder="Что готовим? «борщ», «курица с рисом», «картошка»…" value="${esc(S.q)}" data-search="menu" autocomplete="off" enterkeyhint="search">${S.q ? `<button class="clear" data-act="setq" data-v="" aria-label="Очистить">${ICON.x}</button>` : `<kbd title="Нажмите / для поиска">/</kbd>`}</label>
    <label class="select">Сортировка<select id="sort" data-sort>
      <option value="cat" ${S.sort === "cat" ? "selected" : ""}>по разделам</option><option value="time" ${S.sort === "time" ? "selected" : ""}>по времени</option>
      <option value="match" ${S.sort === "match" ? "selected" : ""}>по моим продуктам</option><option value="name" ${S.sort === "name" ? "selected" : ""}>по алфавиту</option></select></label>
  </div>
  <div class="chips" role="group" aria-label="Разделы меню">${chip("all", "Все", counts.all)}${S.favs.size ? chip("fav", "★ Избранное", counts.fav) : ""}${Object.entries(RCATS).map(([c, n]) => chip(c, n, counts[c])).join("")}</div>
  <div class="chips" role="group" aria-label="Фильтры">${tagChip("", "Любые")}${tagChip("quick", "⏱ До 30 минут")}${S.pantry.size ? tagChip("mine", "✓ Из моих продуктов") : ""}${tagChip("veg", "🌿 Без мяса")}${tagChip("few", "До 5 продуктов")}${tagChip("oven", "Духовка")}${tagChip("nocook", "Без плиты")}</div>
  <div id="results" class="results">${resultsHTML()}</div>`;
}

function recipeView(r) {
  const sv = S.servings[r.id] || r.s, f = sv / r.s;
  const doneSet = S.done[r.id] || (S.done[r.id] = new Set());
  const ings = r.ings.map(x => {
    const {a, g} = amount(x, f), [name, emo] = ING[x.id];
    const miss = !has(x.id) && !x.optional;
    return `<li><span aria-hidden="true">${emo}</span><span class="nm">${esc(name)}${x.optional ? `<span class="opt">по желанию</span>` : ""}${x.note ? `<small>${esc(x.note)}</small>` : ""}${miss && SUBS[x.id] ? `<small class="subs">💡 ${SUBS[x.id]}</small>` : ""}</span>
      <span class="amt">${a}${g ? `<small>${g}</small>` : ""}</span><button class="dot ${has(x.id) ? "on" : ""}" data-act="ptoggle" data-v="${x.id}" ${STAPLES.has(x.id) ? "disabled" : ""} aria-label="${has(x.id) ? "Есть дома — убрать" : "Нет дома — отметить, что есть"}" title="${has(x.id) ? "Есть дома" : "Отметить, что есть"}"></button></li>`;
  }).join("");
  const steps = r.steps.map((s, i) => {
    const title = `${r.n} · шаг ${i + 1}`, t = findTimer(title), dn = doneSet.has(i);
    const tm = !s.m ? "" : (t && !t.done)
      ? `<span class="running" data-tclock="${t.id}">${fmtClock(tLeft(t))}</span>`
      : `<button class="btn small tbtn" data-act="tstart" data-title="${esc(title)}" data-min="${s.m}">${ICON.timer}Таймер ${s.m} мин</button>`;
    return `<li class="step ${dn ? "done" : ""}"><button class="step-n" data-act="stepdone" data-id="${r.id}" data-v="${i}" aria-pressed="${dn}" aria-label="Шаг ${i + 1} ${dn ? "выполнен" : "— отметить выполненным"}">${dn ? ICON.check : i + 1}</button><p>${esc(s.text)}</p>${s.par ? `<div class="par">параллельно с предыдущим шагом</div>` : ""}
      <div class="step-meta">${heatHTML(s.h, s.temp)}${s.m ? `<span class="time">${ICON.clock}${fmtMin(s.m)}</span>` : ""}${tm}</div></li>`;
  }).join("");
  const miss = missing(r);
  const toBuy = miss.filter(id => !S.shop.has(id));
  return `<a class="back" href="#menu">${ICON.back}Меню</a>
  <div class="hero"><div class="dish" aria-hidden="true">${r.e}</div><div class="hero-text">
    <div class="label">${RCATS[r.c]}</div><h1>${esc(r.n)}</h1>
    <div class="facts"><span class="fact">${ICON.clock}${fmtMin(r.total)}${r.active < r.total - 10 ? ` <span class="muted">· у плиты ${fmtMin(r.active)}</span>` : ""}</span><span class="fact">${DIFF[r.d]}</span><span class="fact">${r.steps.length} ${plural(r.steps.length, "шаг", "шага", "шагов")}</span>${tagsHTML(r)}</div>
    ${S.pantry.size ? `<div class="have ${miss.length ? "part" : "ok"}">${miss.length ? "Не хватает: " + miss.map(lower).join(", ") : "✓ Все продукты есть"}</div>` : ""}
  </div>
  <div class="hero-acts"><button class="btn primary" data-act="cook-open" data-id="${r.id}">${ICON.play}Начать готовку</button>
    <button class="btn ${S.favs.has(r.id) ? "on" : ""}" data-act="fav" data-id="${r.id}" aria-pressed="${S.favs.has(r.id)}">${S.favs.has(r.id) ? ICON.starFill : ICON.star}${S.favs.has(r.id) ? "В избранном" : "В избранное"}</button>
    ${miss.length ? `<button class="btn" data-act="shopadd" data-v="${miss.join(",")}" ${toBuy.length ? "" : "disabled"}>${ICON.cart}${toBuy.length ? `В список покупок (${toBuy.length})` : "Уже в списке покупок"}</button>` : ""}
    <button class="btn ghost" data-act="copylink" data-id="${r.id}">${ICON.link}Ссылка</button></div></div>
  <div class="detail">
    <div class="col sticky">
      <div class="panel"><div class="servings"><div><div class="label">Сколько персон</div><strong>${sv} ${plural(sv, "персона", "персоны", "персон")}</strong></div>
        <div class="stepper"><button data-act="srv" data-id="${r.id}" data-v="-1" aria-label="Меньше">−</button><output>${sv}</output><button data-act="srv" data-id="${r.id}" data-v="1" aria-label="Больше">+</button></div></div>
        ${sv !== r.s ? `<p class="note">Граммовка пересчитана с ${r.s} на ${sv}. Время почти не меняется; для большого объёма возьмите посуду побольше${r.tags.includes("oven") ? " или пеките в два захода" : ""}.</p>` : ""}</div>
      <div class="panel"><h2 style="margin-bottom:6px">Ингредиенты</h2><ul class="ing">${ings}</ul>
        <p class="note">Нажмите на кружок, чтобы отметить продукт как имеющийся. Соль, перец, масло, вода и специи считаются имеющимися.</p></div>
      <div class="panel"><h2 style="margin-bottom:10px">Посуда</h2><ul class="ware">${r.ware.map(w => `<li><span aria-hidden="true">${WARE[w][1]}</span>${WARE[w][0]}</li>`).join("")}</ul></div>
    </div>
    <div class="col"><div class="section-title"><h2>Приготовление</h2>${doneSet.size ? `<button class="linkbtn" data-act="stepreset" data-id="${r.id}">сбросить отметки</button>` : `<span class="muted" style="font-size:13px">нажимайте на номер шага, чтобы отмечать сделанное</span>`}</div><ol class="steps">${steps}</ol>
      ${r.tips.length ? `<div class="panel tips-panel"><h2 style="margin-bottom:8px">Советы</h2><ul class="tips">${r.tips.map(t => `<li>${esc(t)}</li>`).join("")}</ul></div>` : ""}
    </div>
  </div>`;
}

function pantryGridHTML() {
  const q = S.pq.trim();
  const item = id => `<button class="pitem" data-act="ptoggle" data-v="${id}" aria-pressed="${S.pantry.has(id)}"><span aria-hidden="true">${ING[id][1]}</span><span class="t">${esc(ING[id][0])}</span><span class="dot ${S.pantry.has(id) ? "on" : ""}"></span></button>`;
  if (q) {
    const res = runSearch(ING_INDEX, q);
    if (!res.results.length) return `<div class="empty"><p>«${esc(q)}» в справочнике нет.</p><p class="muted">Проверьте написание или отметьте похожий продукт. Для необычных продуктов спросите шефа на вкладке «Что приготовить».</p></div>`;
    const hint = res.hint || res.layoutFixed ? `<div class="hintbar">${ICON.info}<span>${res.layoutFixed ? "Похоже, включена английская раскладка. " : ""}${res.hint ? `Показываю «<b>${esc(res.hint)}</b>»` : ""}</span></div>` : "";
    return hint + `<div class="label">Найдено: ${res.results.length} · Enter отметит первый</div><div class="pgrid">${res.results.slice(0, 40).map(x => item(x.item.id)).join("")}</div>`;
  }
  return `<section class="block"><h2>Часто используемые</h2><div class="pgrid">${FREQUENT.map(item).join("")}</div></section>` +
    Object.entries(CATS).filter(([c]) => c !== "basics").map(([c, name]) => {
      const items = Object.keys(ING).filter(id => ING[id][2] === c);
      return `<section class="block"><h2>${name} <small class="num muted">${items.length}</small></h2><div class="pgrid">${items.map(item).join("")}</div></section>`;
    }).join("");
}
function scanHTML() {
  const sc = S.scan; if (!sc) return "";
  let body = "";
  if (sc.status === "loading") body = `<p><span class="spinner"></span> Claude смотрит на фото и ищет продукты…</p>`;
  if (sc.status === "error") body = `<p class="err">${esc(sc.err)}</p><button class="btn" data-act="scanclose">Закрыть</button>`;
  if (sc.status === "done") body = sc.found.length
    ? `<div class="label">Найдено — снимите отметку с лишнего</div><div class="pgrid">${sc.found.map(id =>
        `<button class="pitem" data-act="scansel" data-v="${id}" aria-pressed="${sc.sel.has(id)}"><span aria-hidden="true">${ING[id][1]}</span><span class="t">${esc(ING[id][0])}</span><span class="dot ${sc.sel.has(id) ? "on" : ""}"></span></button>`).join("")}</div>
       <div class="toolbar"><button class="btn primary" data-act="scanadd" ${sc.sel.size ? "" : "disabled"}>Добавить ${sc.sel.size} ${plural(sc.sel.size, "продукт", "продукта", "продуктов")}</button><button class="btn ghost" data-act="scanclose">Закрыть</button></div>`
    : `<p class="muted">Продуктов на фото не нашлось. Снимите ближе и при хорошем свете или отметьте продукты вручную ниже.</p><button class="btn" data-act="scanclose">Закрыть</button>`;
  return `<div class="panel scanbox"><img src="${sc.url}" alt="Ваше фото продуктов"><div class="block">${body}</div></div>`;
}
function shopHTML() {
  if (!S.shop.size) return "";
  return `<div class="panel shop"><div class="section-title"><h2>${ICON.cart} Список покупок</h2><span class="num">${S.shop.size}</span><button class="linkbtn" data-act="shopclear" style="margin-left:auto">очистить</button></div>
    <p class="muted" style="margin:0 0 8px;font-size:13px">Купили — нажмите на продукт: он переедет в «У меня есть».</p>
    <div class="shoplist">${[...S.shop].map(id => `<button class="pitem" data-act="bought" data-v="${id}"><span aria-hidden="true">${ING[id][1]}</span><span class="t">${esc(ING[id][0])}</span><span class="dot"></span></button>`).join("")}</div></div>`;
}
function pantryView() {
  const canScan = AI.images;
  const keyBox = STANDALONE ? `<details class="panel"><summary>Ключ Claude API — для распознавания фото и советов шефа</summary>
    <p class="muted" style="margin:10px 0">На своём хостинге нужен ключ с console.anthropic.com. Он хранится только в этом браузере.</p>
    <div class="toolbar"><label class="field grow"><input id="apikey" type="password" placeholder="sk-ant-…" value="${esc(store.get("apikey", ""))}" autocomplete="off"></label><button class="btn primary" data-act="savekey">Сохранить</button></div></details>` : "";
  const mine = [...S.pantry];
  return `<div class="page-head"><div><h1>Мои продукты</h1><p class="muted">Отметьте, что есть дома, или сфотографируйте — и посмотрите, что из этого приготовить.</p></div>
    ${mine.length ? `<button class="btn" data-act="pclear">${ICON.trash}Очистить</button>` : ""}</div>
  ${canScan ? `<div class="scan">
    <label class="scan-btn">${ICON.camera}<strong>Сфотографировать</strong><span>Откройте холодильник и снимите полки</span><input type="file" accept="image/*" capture="environment" data-scan aria-label="Сфотографировать продукты"></label>
    <label class="scan-btn alt">${ICON.image}<strong>Выбрать фото</strong><span>Из галереи или с компьютера</span><input type="file" accept="image/*" data-scan aria-label="Выбрать фото продуктов"></label>
  </div>` : `<div class="panel muted">Распознавание по фото включится, когда будет доступ к Claude${STANDALONE ? " — укажите ключ ниже" : ". Разрешите его в меню страницы, если просмотрщик спросит"}. Пока отметьте продукты вручную.</div>`}
  ${scanHTML()}
  <div class="panel mine"><div class="section-title"><h2>У меня есть</h2><span class="num">${mine.length}</span></div>
    ${mine.length ? `<div class="minelist">${mine.sort((a, b) => ING[a][0].localeCompare(ING[b][0], "ru")).map(id => `<button class="minechip" data-act="ptoggle" data-v="${id}" title="Убрать">${ING[id][1]} ${esc(ING[id][0])} <span aria-hidden="true">×</span></button>`).join("")}</div>
    <div class="toolbar" style="margin-top:12px"><a class="btn primary" href="#ideas">${ICON.bulb}Что приготовить</a><span class="muted" style="font-size:13px">Подходит ${matches().filter(m => !m.miss.length).length} ${plural(matches().filter(m => !m.miss.length).length, "блюдо", "блюда", "блюд")} без докупки</span></div>`
    : `<span class="muted">Пока ничего не отмечено. Начните с частых продуктов ниже.</span>`}</div>
  ${shopHTML()}
  ${keyBox}
  <label class="field grow">${ICON.search}<input id="pq" type="search" placeholder="Найти продукт: «картошка», «сыр», «фарш»…" value="${esc(S.pq)}" data-search="pantry" autocomplete="off" enterkeyhint="done">${S.pq ? `<button class="clear" data-act="setpq" aria-label="Очистить">${ICON.x}</button>` : ""}</label>
  <div id="pgrid" class="results">${pantryGridHTML()}</div>
  <section class="block"><h2>Базовое</h2><p class="muted" style="margin:0">Считается, что это есть всегда, и при подборе не учитывается.</p>
    <div class="basics">${[...STAPLES].map(id => `<span>${ING[id][1]} ${ING[id][0]}</span>`).join("")}</div></section>`;
}

function matchCard(m) {
  const extra = m.miss.length
    ? `<div class="bar"><i style="width:${Math.round(100 * m.have / (m.r.key.length || 1))}%"></i></div><div class="miss">Не хватает: ${m.miss.map(lower).join(", ")}</div>
       ${m.miss.filter(id => SUBS[id]).slice(0, 2).map(id => `<div class="sub">💡 ${esc(ING[id][0])}: ${SUBS[id]}</div>`).join("")}`
    : `<div class="bar ok"><i style="width:100%"></i></div><div class="have ok">Все продукты есть</div>`;
  return cardHTML(m.r, extra);
}
function ideasView() {
  if (!S.pantry.size) return `<div class="page-head"><div><h1>Что приготовить</h1></div></div>
    <div class="empty"><p style="margin:0 0 12px">Отметьте продукты, которые есть дома, или сфотографируйте холодильник — и здесь появятся подходящие блюда и советы.</p><a class="btn primary" href="#pantry">${ICON.fridge}Перейти к продуктам</a></div>`;
  const all = matches(), ready = all.filter(m => !m.miss.length), almost = all.filter(m => m.miss.length >= 1 && m.miss.length <= 2), rest = all.filter(m => m.miss.length > 2 && m.have >= 2);
  const unlock = unlockList(all);
  const ai = AI.ready ? `<div class="toolbar"><button class="btn primary" data-act="ai" ${S.ai.busy ? "disabled" : ""}>${S.ai.busy ? `<span class="spinner"></span>Шеф думает…` : `${ICON.chef}Спросить шефа`}</button>
      <span class="muted" style="font-size:13px">Claude предложит блюда из ваших продуктов, даже если их нет в меню.</span></div>
      ${S.ai.text || S.ai.busy ? `<pre class="ai-out" id="aiOut">${esc(S.ai.text)}</pre>` : ""}${S.ai.err ? `<p class="err" style="margin:0">${esc(S.ai.err)}</p>` : ""}` : "";
  return `<div class="page-head"><div><h1>Что приготовить</h1><p class="muted">Подбор по ${S.pantry.size} ${plural(S.pantry.size, "продукту", "продуктам", "продуктам")}: ${[...S.pantry].slice(0, 6).map(lower).join(", ")}${S.pantry.size > 6 ? "…" : ""}</p></div><a class="btn" href="#pantry">${ICON.fridge}Изменить продукты</a></div>
  <div class="advice"><h2>Совет повара</h2>${adviceLines(all).map(l => `<p>${esc(l)}</p>`).join("")}${ai}</div>
  ${unlock.length ? `<div class="panel"><div class="section-title"><h2>Что докупить в первую очередь</h2></div><p class="muted" style="margin:4px 0 10px;font-size:13px">Один продукт — и открывается сразу несколько блюд. Нажмите, чтобы добавить в список покупок.</p>
    <div class="unlock">${unlock.map(u => `<button class="pitem" data-act="shopadd" data-v="${u.id}" ${S.shop.has(u.id) ? "disabled" : ""}><span aria-hidden="true">${ING[u.id][1]}</span><span class="t">${esc(ING[u.id][0])}<small>${S.shop.has(u.id) ? "уже в списке" : `+${u.n} ${plural(u.n, "блюдо", "блюда", "блюд")}`}</small></span>${S.shop.has(u.id) ? ICON.check : ICON.plus}</button>`).join("")}</div></div>` : ""}
  ${sectionHTML("Можно приготовить прямо сейчас", ready, matchCard)}${sectionHTML("Не хватает 1–2 продуктов", almost, matchCard)}${sectionHTML("Нужно докупить больше", rest.slice(0, 24), matchCard)}`;
}

function timerCard(t) {
  const left = tLeft(t), running = !!t.end && !t.done;
  return `<div class="timer ${t.done ? "done" : ""}">
    <svg class="ring" viewBox="0 0 56 56" aria-hidden="true"><circle class="bg" cx="28" cy="28" r="24"/><circle class="fg" cx="28" cy="28" r="24" stroke-dasharray="${RING}" style="stroke-dashoffset:${t.done ? 0 : RING * (left / t.dur)}" transform="rotate(-90 28 28)" ${t.done ? "" : `data-tring="${t.id}"`}/></svg>
    <div class="tt"><div>${esc(t.title)}</div><div class="big" ${t.done ? "" : `data-tclock="${t.id}"`}>${t.done ? "Готово!" : fmtClock(left)}</div></div>
    <div class="acts">
      ${t.done ? `<button class="icon-btn" data-act="t-restart" data-id="${t.id}" aria-label="Запустить снова">${ICON.reset}</button>`
        : `<button class="icon-btn" data-act="${running ? "t-pause" : "t-resume"}" data-id="${t.id}" aria-label="${running ? "Пауза" : "Продолжить"}">${running ? ICON.pause : ICON.play}</button>`}
      <button class="icon-btn" data-act="t-plus" data-id="${t.id}" aria-label="Добавить минуту">+1</button>
      <button class="icon-btn" data-act="t-del" data-id="${t.id}" aria-label="Удалить">${ICON.x}</button>
    </div></div>`;
}
function timersView() {
  return `<div class="page-head"><div><h1>Таймеры</h1><p class="muted">Несколько таймеров сразу. Запускайте прямо из шага рецепта — звук и вибрация, когда время выйдет.</p></div></div>
  <section class="block"><h2>Запущенные</h2>
    ${S.timers.length ? `<div class="tgrid">${S.timers.map(timerCard).join("")}</div>` : `<div class="empty">Таймеров нет. Выберите время ниже или нажмите «Таймер» в шаге рецепта.</div>`}</section>
  <section class="block"><h2>Быстрый старт</h2>
    <div class="presets">${[1, 2, 3, 5, 7, 10, 15, 20, 25, 30, 45, 60].map(m => `<button data-act="preset" data-min="${m}">${m} мин</button>`).join("")}</div></section>
  <section class="panel block"><h2>Свой таймер</h2>
    <div class="custom"><label class="field grow"><input id="ctitle" placeholder="Название, например «Курица в духовке»" autocomplete="off"></label>
      <span class="mm"><input id="cmin" type="number" min="0" max="600" value="5" aria-label="Минуты"> мин</span>
      <span class="mm"><input id="csec" type="number" min="0" max="59" value="0" aria-label="Секунды"> сек</span>
      <button class="btn primary" data-act="custom">${ICON.play}Запустить</button></div></section>
  <section class="block"><h2>Шпаргалка по варке</h2>
    <ul class="cheat">${CHEAT.map(([n, m]) => `<li><span>${n}</span><span class="num muted">${m} мин</span><button class="icon-btn" data-act="tstart" data-title="${esc(n)}" data-min="${m}" aria-label="Запустить: ${esc(n)}">${ICON.play}</button></li>`).join("")}</ul></section>`;
}

/* ===== Режим готовки ===== */
let wakeLock = null;
function cookHTML() {
  const c = S.cook; if (!c) return "";
  const r = BY_ID[c.id], n = r.steps.length, f = c.sv / r.s;
  let body;
  if (c.page === 0) {
    body = `<div class="cook-prep block"><h2>Подготовьте на ${c.sv} ${plural(c.sv, "персону", "персоны", "персон")}</h2>
      <ul class="ing">${r.ings.map(x => { const {a, g} = amount(x, f); return `<li><span>${ING[x.id][1]}</span><span class="nm">${esc(ING[x.id][0])}${x.optional ? `<span class="opt">по желанию</span>` : ""}${x.note ? `<small>${esc(x.note)}</small>` : ""}</span><span class="amt">${a}${g ? `<small>${g}</small>` : ""}</span><span class="dot ${has(x.id) ? "on" : ""}"></span></li>`; }).join("")}</ul>
      <h3 style="margin-top:6px">Посуда</h3><ul class="ware">${r.ware.map(w => `<li>${WARE[w][1]} ${WARE[w][0]}</li>`).join("")}</ul></div>`;
  } else {
    const s = r.steps[c.page - 1], title = `${r.n} · шаг ${c.page}`, t = findTimer(title), nx = r.steps[c.page];
    let clock = "";
    if (s.m) clock = t ? `<div class="cook-clock" ${t.done ? "" : `data-tclock="${t.id}"`}>${t.done ? "Готово!" : fmtClock(tLeft(t))}</div>
        <div class="toolbar" style="justify-content:center">${t.done ? `<button class="btn" data-act="t-restart" data-id="${t.id}">Ещё раз</button>` : `<button class="btn" data-act="${t.end ? "t-pause" : "t-resume"}" data-id="${t.id}">${t.end ? "Пауза" : "Продолжить"}</button>`}<button class="btn" data-act="t-plus" data-id="${t.id}">+1 мин</button></div>`
      : `<div class="cook-clock">${fmtClock(s.m * 60)}</div><button class="btn primary" data-act="tstart" data-title="${esc(title)}" data-min="${s.m}">${ICON.timer}Запустить таймер</button>`;
    body = `<div class="k">Шаг ${c.page} из ${n}${s.par ? " · параллельно" : ""}</div><div class="txt">${esc(s.text)}</div>${heatHTML(s.h, s.temp)}${clock}
      ${nx ? `<div class="nextstep"><span class="label">Дальше</span>${esc(nx.text)}</div>` : `<div class="nextstep"><span class="label">Дальше</span>Готово — приятного аппетита!</div>`}`;
  }
  return `<div class="cook" role="dialog" aria-modal="true" aria-label="Режим готовки">
    <div class="cook-top"><h2>${r.e} ${esc(r.n)}</h2><button class="btn ghost" data-act="cook-close">${ICON.x}Закрыть</button></div>
    <div class="progress"><i style="width:${100 * c.page / n}%"></i></div>
    <div class="cook-body">${body}</div>
    <div class="cook-nav"><button class="btn" data-act="cook-prev" ${c.page === 0 ? "disabled" : ""}>${ICON.back}Назад</button>
      ${c.page < n ? `<button class="btn primary" data-act="cook-next">${c.page === 0 ? "Начать" : "Далее"}${ICON.next}</button>` : `<button class="btn primary" data-act="cook-close">Готово, приятного аппетита</button>`}</div></div>`;
}
async function openCook(id) {
  S.cook = {id, page: 0, sv: S.servings[id] || BY_ID[id].s};
  unlockAudio();
  try { wakeLock = await navigator.wakeLock?.request("screen"); } catch {}
  render();
}
function closeCook() { S.cook = null; try { wakeLock?.release(); } catch {} wakeLock = null; render(); }
document.addEventListener("visibilitychange", async () => { if (S.cook && document.visibilityState === "visible") { try { wakeLock = await navigator.wakeLock?.request("screen"); } catch {} } });

/* ===== Каркас и маршруты ===== */
const NAV = [["menu", "Меню", ICON.book], ["pantry", "Продукты", ICON.fridge], ["ideas", "Что приготовить", ICON.bulb], ["timers", "Таймеры", ICON.timer]];
document.getElementById("root").innerHTML = `<div class="app"><aside class="side"><div class="brand"><span class="brand-mark" aria-hidden="true">🍳</span>Повар</div>
  <nav class="nav" id="nav" aria-label="Разделы"></nav><div class="side-foot">${RECIPES.length} рецептов · ${Object.keys(ING).length} продуктов.<br>Продукты, избранное и таймеры сохраняются в этом браузере.</div></aside>
  <main id="main"><div class="wrap" id="view"></div></main></div><div class="dock" id="dock"></div><div id="cook"></div><div id="toast" class="toast" hidden></div>`;

function route() {
  const h = location.hash.slice(1);
  if (h.startsWith("r-") && BY_ID[h.slice(2)]) return {v: "recipe", id: h.slice(2)};
  return {v: ["pantry", "ideas", "timers"].includes(h) ? h : "menu"};
}
let lastKey = "";
function render() {
  const rt = route(), key = rt.v + (rt.id || "");
  const active = S.timers.filter(t => !t.done).length;
  document.getElementById("nav").innerHTML = NAV.map(([k, n, ic]) => `<a href="#${k}" ${(rt.v === k || (rt.v === "recipe" && k === "menu")) ? 'aria-current="page"' : ""}>${ic}<span>${n}</span>${k === "timers" && active ? `<span class="badge">${active}</span>` : (k === "pantry" && S.shop.size ? `<span class="badge alt">${S.shop.size}</span>` : "")}</a>`).join("");
  const focus = document.activeElement?.id, caret = document.activeElement?.selectionStart;
  const view = document.getElementById("view");
  if (rt.v === "recipe" && key !== lastKey) { S.recent = [rt.id, ...S.recent.filter(x => x !== rt.id)].slice(0, 8); save(); }
  view.innerHTML = rt.v === "recipe" ? recipeView(BY_ID[rt.id]) : rt.v === "pantry" ? pantryView() : rt.v === "ideas" ? ideasView() : rt.v === "timers" ? timersView() : menuView();
  if (focus && key === lastKey) { const el = document.getElementById(focus); if (el) { el.focus({preventScroll: true}); try { el.setSelectionRange(caret, caret); } catch {} } }
  if (key !== lastKey) window.scrollTo(0, 0);
  lastKey = key;
  const dock = document.getElementById("dock");
  dock.hidden = rt.v === "timers" || !S.timers.length || !!S.cook;
  dock.innerHTML = S.timers.slice(0, 3).map(t => `<a href="#timers" class="${t.done ? "done" : ""}">${ICON.timer}<span class="n">${esc(t.title)}</span><b ${t.done ? "" : `data-tclock="${t.id}"`}>${t.done ? "готово" : fmtClock(tLeft(t))}</b></a>`).join("")
    + (S.timers.length > 3 ? `<a href="#timers">Ещё ${S.timers.length - 3}</a>` : "");
  document.getElementById("cook").innerHTML = cookHTML();
}
const refreshResults = () => { const el = document.getElementById("results"); if (el) el.innerHTML = resultsHTML(); };

/* ===== События ===== */
document.addEventListener("click", e => {
  const b = e.target.closest("[data-act]"); if (!b) return;
  const {act, v, id} = b.dataset;
  if (b.closest("a.card")) e.preventDefault();
  if (act === "cat") { S.cat = v; render(); }
  else if (act === "tag") { S.tag = v; render(); }
  else if (act === "setq") { S.q = v || ""; render(); if (v) document.getElementById("q")?.focus(); }
  else if (act === "setpq") { S.pq = ""; render(); document.getElementById("pq")?.focus(); }
  else if (act === "clearf") { S.cat = "all"; S.tag = ""; render(); }
  else if (act === "fav") { S.favs.has(id) ? S.favs.delete(id) : S.favs.add(id); save(); render(); toast(S.favs.has(id) ? `«${BY_ID[id].n}» — в избранном` : `Убрано из избранного`); }
  else if (act === "srv") { const r = BY_ID[id]; S.servings[id] = Math.min(30, Math.max(1, (S.servings[id] || r.s) + +v)); save(); render(); }
  else if (act === "stepdone") { const st = S.done[id]; st.has(+v) ? st.delete(+v) : st.add(+v); render(); }
  else if (act === "stepreset") { S.done[id] = new Set(); render(); }
  else if (act === "copylink") {
    const url = location.href.split("#")[0] + "#r-" + id;
    navigator.clipboard?.writeText(url).then(() => toast("Ссылка на рецепт скопирована"), () => toast(url));
  }
  else if (act === "shopadd") { const ids = v.split(",").filter(x => ING[x] && !has(x)); ids.forEach(x => S.shop.add(x)); save(); render(); if (ids.length) toast(`В список покупок: ${ids.slice(0, 3).map(lower).join(", ")}${ids.length > 3 ? ` и ещё ${ids.length - 3}` : ""}`, {href: "#pantry", label: "Открыть"}); }
  else if (act === "shopclear") { S.shop.clear(); save(); render(); }
  else if (act === "bought") { S.shop.delete(v); S.pantry.add(v); save(); render(); toast(`${ING[v][0]} — теперь в «У меня есть»`); }
  else if (act === "tstart") startTimer(b.dataset.title, +b.dataset.min * 60);
  else if (act === "preset") startTimer(`Таймер ${b.dataset.min} мин`, +b.dataset.min * 60);
  else if (act === "custom") {
    const m = Math.max(0, +document.getElementById("cmin").value || 0), s = Math.min(59, Math.max(0, +document.getElementById("csec").value || 0));
    startTimer(document.getElementById("ctitle").value.trim() || "Таймер", m * 60 + s);
  }
  else if (act.startsWith("t-")) timerAct(act.slice(2), id);
  else if (act === "ptoggle") { if (S.pantry.has(v)) S.pantry.delete(v); else { S.pantry.add(v); S.shop.delete(v); } save(); render(); }
  else if (act === "pclear") { S.pantry.clear(); save(); render(); }
  else if (act === "scansel") { S.scan.sel.has(v) ? S.scan.sel.delete(v) : S.scan.sel.add(v); render(); }
  else if (act === "scanadd") { S.scan.sel.forEach(x => { S.pantry.add(x); S.shop.delete(x); }); save(); URL.revokeObjectURL(S.scan.url); const n = S.scan.sel.size; S.scan = null; render(); toast(`Добавлено ${n} ${plural(n, "продукт", "продукта", "продуктов")}`, {href: "#ideas", label: "Что приготовить"}); }
  else if (act === "scanclose") { URL.revokeObjectURL(S.scan.url); S.scan = null; render(); }
  else if (act === "savekey") { store.set("apikey", document.getElementById("apikey").value.trim()); AI.ready = AI.images = !!store.get("apikey", ""); render(); toast(AI.ready ? "Ключ сохранён" : "Ключ удалён"); }
  else if (act === "ai") askChef();
  else if (act === "cook-open") openCook(id);
  else if (act === "cook-close") closeCook();
  else if (act === "cook-next") { S.cook.page = Math.min(BY_ID[S.cook.id].steps.length, S.cook.page + 1); render(); }
  else if (act === "cook-prev") { S.cook.page = Math.max(0, S.cook.page - 1); render(); }
});
document.addEventListener("input", e => {
  const s = e.target.dataset?.search;
  if (s === "menu") { S.q = e.target.value; refreshResults(); }
  if (s === "pantry") { S.pq = e.target.value; document.getElementById("pgrid").innerHTML = pantryGridHTML(); }
});
document.addEventListener("change", e => {
  if (e.target.matches("[data-sort]")) { S.sort = e.target.value; refreshResults(); }
  if (e.target.matches("[data-scan]")) { handleScan(e.target.files[0]); e.target.value = ""; }
});
document.addEventListener("keydown", e => {
  if (S.cook) {
    if (e.key === "Escape") closeCook();
    if (e.key === "ArrowRight") { S.cook.page = Math.min(BY_ID[S.cook.id].steps.length, S.cook.page + 1); render(); }
    if (e.key === "ArrowLeft") { S.cook.page = Math.max(0, S.cook.page - 1); render(); }
    return;
  }
  const typing = /^(INPUT|TEXTAREA|SELECT)$/.test(document.activeElement?.tagName);
  if (e.key === "/" && !typing) { e.preventDefault(); const el = document.getElementById("q") || document.getElementById("pq"); if (el) el.focus(); else { location.hash = "menu"; setTimeout(() => document.getElementById("q")?.focus(), 50); } }
  if (e.key === "Enter" && e.target.id === "pq" && S.pq.trim()) {
    const first = runSearch(ING_INDEX, S.pq).results[0];
    if (first) { const id = first.item.id; S.pantry.has(id) ? S.pantry.delete(id) : S.pantry.add(id); S.pq = ""; save(); render(); document.getElementById("pq")?.focus(); toast(S.pantry.has(id) ? `${ING[id][0]} — есть дома` : `${ING[id][0]} убран`); }
  }
  if (e.key === "Escape" && typing && e.target.dataset?.search) { e.target.value = ""; e.target.dispatchEvent(new Event("input", {bubbles: true})); }
});
document.addEventListener("pointerdown", unlockAudio, {once: true});
window.addEventListener("hashchange", render);
render();
