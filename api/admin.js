// 어드민 대시보드 — /api/admin?token=<ADMIN_TOKEN>
// HTML 페이지를 반환하고, 페이지 내 JS 가 같은 token 으로 /api/telemetry 를 조회한다.
export default function handler(req, res) {
  const token = String(req.query.token || '');
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.status(200).send(`<!DOCTYPE html>
<html lang="ko"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Analog Timer — 텔레메트리</title>
<style>
  :root{--bg:#0E0E0F;--surface:#1A1A1C;--border:#2E2E32;--text:#E8E6E0;--muted:#6B6968;--accent:#F0C040;--orange:#E07A52;--danger:#E05252}
  *{box-sizing:border-box}
  body{margin:0;background:var(--bg);color:var(--text);font-family:'Segoe UI',system-ui,sans-serif;font-size:13px}
  header{padding:16px 20px;border-bottom:1px solid var(--border);display:flex;align-items:center;gap:16px;position:sticky;top:0;background:var(--bg);z-index:2}
  h1{font-size:16px;margin:0;color:var(--accent)}
  .muted{color:var(--muted)}
  button{background:var(--surface);color:var(--text);border:1px solid var(--border);border-radius:6px;padding:6px 12px;cursor:pointer}
  button:hover{border-color:var(--accent)}
  .wrap{padding:16px 20px;max-width:1100px;margin:0 auto}
  .agg{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:16px}
  .chip{background:var(--surface);border:1px solid var(--border);border-radius:20px;padding:6px 12px;font-size:12px}
  .chip b{color:var(--orange)}
  .card{background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:12px 14px;margin-bottom:10px}
  .row1{display:flex;align-items:center;gap:10px;flex-wrap:wrap}
  .badge{font-size:11px;padding:2px 8px;border-radius:10px;border:1px solid var(--border)}
  .badge.crash{color:var(--danger);border-color:#553}
  .badge.native{color:var(--orange);border-color:#653}
  .badge.env{color:#52b0e0;border-color:#356}
  .k{color:var(--muted)} .v{color:var(--text)}
  .meta{display:flex;flex-wrap:wrap;gap:14px;margin-top:6px;font-size:12px}
  pre{background:#0b0b0c;border:1px solid var(--border);border-radius:6px;padding:8px;overflow:auto;font-size:11px;color:#bdbab4;max-height:240px;margin:8px 0 0;white-space:pre-wrap}
  details summary{cursor:pointer;color:var(--muted);margin-top:6px;font-size:12px}
  .empty{color:var(--muted);text-align:center;padding:40px}
  input{background:var(--surface);color:var(--text);border:1px solid var(--border);border-radius:6px;padding:6px 10px;width:240px}
</style></head>
<body>
<header>
  <h1>⏱ Analog Timer — 텔레메트리</h1>
  <span id="count" class="muted">로딩…</span>
  <span style="flex:1"></span>
  <input id="tok" type="password" placeholder="ADMIN_TOKEN" value="${token.replace(/"/g, '&quot;')}">
  <button onclick="load()">새로고침</button>
  <button onclick="clearAll()" style="border-color:#553">전체 지우기</button>
</header>
<div class="wrap">
  <div class="agg" id="agg"></div>
  <div id="list"><div class="empty">불러오는 중…</div></div>
</div>
<script>
const esc=s=>String(s==null?'':s).replace(/[&<>]/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;'}[c]));
const fmt=t=>{const d=new Date(t);return d.toLocaleString('ko-KR');};
function badge(r){
  if(r.type==='env') return '<span class="badge env">ENV</span>';
  if(r.crashKind==='native') return '<span class="badge native">NATIVE 크래시</span>';
  if(r.crashKind==='widget') return '<span class="badge native">위젯 단독 사라짐</span>';
  return '<span class="badge crash">'+esc((r.crashKind||'crash').toUpperCase())+'</span>';
}
function agg(reports){
  const byGpu={},byKind={};
  reports.forEach(r=>{ const g=r.gpu||'(unknown GPU)'; byGpu[g]=(byGpu[g]||0)+1; const k=r.crashKind||r.type||'?'; byKind[k]=(byKind[k]||0)+1; });
  let h='';
  Object.entries(byKind).sort((a,b)=>b[1]-a[1]).forEach(([k,n])=>h+='<span class="chip">'+esc(k)+' <b>'+n+'</b></span>');
  Object.entries(byGpu).sort((a,b)=>b[1]-a[1]).slice(0,8).forEach(([g,n])=>h+='<span class="chip">'+esc(g)+' <b>'+n+'</b></span>');
  document.getElementById('agg').innerHTML=h;
}
function render(reports){
  document.getElementById('count').textContent=reports.length+'건';
  agg(reports);
  if(!reports.length){ document.getElementById('list').innerHTML='<div class="empty">리포트 없음</div>'; return; }
  document.getElementById('list').innerHTML=reports.map(r=>{
    const meta=[
      ['플랫폼',(r.platform||'')+' '+(r.osVersion||'')],
      ['GPU',r.gpu||'-'],
      ['버전',r.appVersion||'-'],
      ['device',(r.deviceId||'').slice(0,12)],
    ].map(([k,v])=>'<span><span class="k">'+k+':</span> <span class="v">'+esc(v)+'</span></span>').join('');
    let det='';
    if(r.message) det+='<details open><summary>message</summary><pre>'+esc(r.message)+'</pre></details>';
    if(r.lastState) det+='<details><summary>마지막 상태</summary><pre>'+esc(JSON.stringify(r.lastState,null,2))+'</pre></details>';
    if(r.breadcrumbs&&r.breadcrumbs.length) det+='<details open><summary>직전 행동 '+r.breadcrumbs.length+'개 (크래시 전 사용 흐름)</summary><pre>'+esc(r.breadcrumbs.map(function(b){return new Date(b.t).toLocaleTimeString("ko-KR")+"  "+b.e+(b.d?" "+JSON.stringify(b.d):"");}).join("\\n"))+'</pre></details>';
    if(r.eventLog) det+='<details><summary>Windows 이벤트로그</summary><pre>'+esc(r.eventLog)+'</pre></details>';
    if(r.stack) det+='<details><summary>스택</summary><pre>'+esc(r.stack)+'</pre></details>';
    return '<div class="card"><div class="row1">'+badge(r)+'<span class="muted">'+fmt(r.receivedAt)+'</span></div><div class="meta">'+meta+'</div>'+det+'</div>';
  }).join('');
}
async function clearAll(){
  if(!confirm('모든 리포트를 삭제할까요? 되돌릴 수 없습니다.')) return;
  const t=document.getElementById('tok').value.trim();
  try{ const r=await fetch('/api/telemetry?token='+encodeURIComponent(t),{method:'DELETE'}); if(r.status===401){alert('인증 실패 — ADMIN_TOKEN 확인');return;} load(); }catch(e){ alert('실패: '+e.message); }
}
async function load(){
  const t=document.getElementById('tok').value.trim();
  try{
    const res=await fetch('/api/telemetry?token='+encodeURIComponent(t)+'&limit=300');
    if(res.status===401){ document.getElementById('list').innerHTML='<div class="empty">인증 실패 — ADMIN_TOKEN 을 확인하세요</div>'; document.getElementById('count').textContent=''; return; }
    const j=await res.json();
    render(j.reports||[]);
  }catch(e){ document.getElementById('list').innerHTML='<div class="empty">오류: '+esc(e.message)+'</div>'; }
}
load();
</script>
</body></html>`);
}
