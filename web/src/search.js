/* ===== Поиск с опечатками, синонимами и раскладкой ===== */
const norm = s => String(s ?? "").toLowerCase().replace(/ё/g, "е").replace(/[^a-zа-я0-9\s-]/g, " ").replace(/\s+/g, " ").trim();
const LAYOUT = {q:"й",w:"ц",e:"у",r:"к",t:"е",y:"н",u:"г",i:"ш",o:"щ",p:"з","[":"х","]":"ъ",a:"ф",s:"ы",d:"в",f:"а",g:"п",h:"р",j:"о",k:"л",l:"д",";":"ж","'":"э",z:"я",x:"ч",c:"с",v:"м",b:"и",n:"т",m:"ь",",":"б",".":"ю"};
const fixLayout = s => s.replace(/[a-z\[\];',.]/g, c => LAYOUT[c] || c);

/* Расстояние Дамерау — Левенштейна с ранним выходом */
function dist(a, b, max) {
  if (a === b) return 0;
  if (Math.abs(a.length - b.length) > max) return max + 1;
  const m = a.length, n = b.length;
  let prev2 = null, prev = Array.from({length: n + 1}, (_, j) => j), cur;
  for (let i = 1; i <= m; i++) {
    cur = [i]; let rowMin = i;
    for (let j = 1; j <= n; j++) {
      let v = Math.min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1));
      if (i > 1 && j > 1 && a[i - 1] === b[j - 2] && a[i - 2] === b[j - 1]) v = Math.min(v, prev2[j - 2] + 1);
      cur[j] = v; if (v < rowMin) rowMin = v;
    }
    if (rowMin > max) return max + 1;
    prev2 = prev; prev = cur;
  }
  return prev[n];
}
const tolerance = len => len <= 3 ? 0 : len <= 5 ? 1 : len <= 8 ? 2 : 3;

/* Насколько слово word подходит под запрос tok: 0 — точное начало, иначе число правок; null — не подходит */
function wordScore(tok, word) {
  if (word.startsWith(tok)) return 0;
  if (tok.length < 3) return null;
  const max = tolerance(tok.length);
  let best = dist(tok, word, max);
  if (word.length > tok.length) best = Math.min(best, dist(tok, word.slice(0, tok.length), max) + 0.3, dist(tok, word.slice(0, tok.length + 1), max) + 0.3);
  if (tok.length > word.length && word.length >= 4) best = Math.min(best, dist(tok.slice(0, word.length), word, max) + 1);
  return best <= max ? best : null;
}

/* Поисковый индекс элемента: поля с весом. fields = [{w, words:[...]}] */
function matchItem(tokens, fields) {
  let total = 0; const hints = [];
  for (const tok of tokens) {
    let best = null;
    for (const f of fields) for (const word of f.words) {
      const sc = wordScore(tok, word);
      if (sc === null) continue;
      const v = sc * 3 + f.w;
      if (best === null || v < best.v) best = {v, word, sc};
    }
    if (best === null) return null;
    total += best.v; if (best.sc > 0) hints.push([tok, best.word]);
  }
  return {score: total, hints};
}

function runSearch(items, rawQuery) {
  const variants = [norm(rawQuery)];
  const alt = norm(fixLayout(rawQuery.toLowerCase()));
  if (alt && alt !== variants[0]) variants.push(alt);
  let best = {results: [], hint: "", query: variants[0]};
  for (const q of variants) {
    const tokens = q.split(" ").filter(Boolean);
    if (!tokens.length) continue;
    const results = [];
    for (const it of items) { const m = matchItem(tokens, it.fields); if (m) results.push({item: it.ref, score: m.score - (it.boost || 0), hints: m.hints}); }
    results.sort((a, b) => a.score - b.score || (a.item.n || a.item.name).length - (b.item.n || b.item.name).length || (a.item.n || a.item.name).localeCompare(b.item.n || b.item.name, "ru"));
    if (results.length) { const cut = results[0].score + 5; while (results.length > 1 && results[results.length - 1].score > cut) results.pop(); }
    if (results.length > best.results.length || (results.length && results[0].score < (best.results[0]?.score ?? Infinity))) {
      let hint = "";
      if (results.length && results[0].hints.length) {
        const map = Object.fromEntries(results[0].hints);
        hint = tokens.map(t => map[t] || t).join(" ");
      }
      best = {results, hint: hint !== q ? hint : "", query: q, layoutFixed: q === alt && alt !== variants[0]};
    }
  }
  return best;
}
