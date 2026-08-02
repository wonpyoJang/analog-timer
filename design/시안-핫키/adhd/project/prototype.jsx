// Prototype scene: Android phone + light background app + draggable floating widget
// + live timer/stopwatch state machine + demo control dock.

const SEGMENTS = [
  { name: '할 것 1', dur: 20000, color: SEG_COLORS[0] },
  { name: '휴식 1', dur: 12000, color: SEG_COLORS[1] },
  { name: '할 것 2', dur: 18000, color: SEG_COLORS[2] },
  { name: '휴식 2', dur: 12000, color: SEG_COLORS[3] },
  { name: '할 것 3', dur: 18000, color: SEG_COLORS[4] },
  { name: '휴식 3', dur: 12000, color: SEG_COLORS[5] },
];

// ── Light background app (generic, original — shows widget translucency) ───────
function BackgroundApp() {
  const rows = [
    { i: '메', c: '#7C8DB5', t: '메모', s: '오후 회의 안건 정리 — 3가지 항목' },
    { i: '장', c: '#C9913C', t: '장보기 목록', s: '우유, 달걀, 커피 원두, 바나나' },
    { i: '운', c: '#4FA86A', t: '운동 루틴', s: '월/수/금 — 상체, 화/목 — 하체' },
    { i: '독', c: '#B5677C', t: '독서 노트', s: '딥 워크 4장 — 몰입의 조건' },
    { i: '프', c: '#6A7FB5', t: '프로젝트 보드', s: '디자인 핸드오프 검토 완료' },
    { i: '여', c: '#C98B5A', t: '여행 계획', s: '6월 일정 — 숙소 예약 확인' },
  ];
  return (
    <div style={{ height: '100%', background: '#F6F7F9', fontFamily: "'Noto Sans KR', system-ui, sans-serif", color: '#1C1D20' }}>
      <div style={{ padding: '54px 20px 14px' }}>
        <div style={{ fontSize: 26, fontWeight: 700, letterSpacing: '-0.5px' }}>받은 메모</div>
        <div style={{ marginTop: 12, height: 42, borderRadius: 21, background: '#EBEDF1',
          display: 'flex', alignItems: 'center', padding: '0 16px', color: '#8A8D93', fontSize: 14 }}>
          메모 검색
        </div>
      </div>
      <div>
        {rows.map((r, i) => (
          <div key={i} style={{ display: 'flex', gap: 14, alignItems: 'center', padding: '13px 20px' }}>
            <div style={{ width: 42, height: 42, borderRadius: '50%', background: r.c, color: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 16, fontWeight: 600, flexShrink: 0 }}>{r.i}</div>
            <div style={{ flex: 1, minWidth: 0, borderBottom: '1px solid #ECEEF1', paddingBottom: 13, marginBottom: -13 }}>
              <div style={{ fontSize: 15.5, fontWeight: 600 }}>{r.t}</div>
              <div style={{ fontSize: 13.5, color: '#7A7D83', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{r.s}</div>
            </div>
          </div>
        ))}
      </div>
      <div style={{ position: 'absolute', right: 20, bottom: 26, width: 60, height: 60, borderRadius: 18,
        background: '#3B6FE0', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center',
        fontSize: 30, fontWeight: 300, boxShadow: '0 6px 18px rgba(59,111,224,0.45)' }}>+</div>
    </div>
  );
}

// ── Draggable wrapper for the pill within the phone ───────────────────────────
function DraggablePill({ children }) {
  const [pos, setPos] = React.useState(() => {
    try { return JSON.parse(localStorage.getItem('ov_pos')) || { x: 0.5, y: 70 }; }
    catch { return { x: 0.5, y: 70 }; }
  });
  const drag = React.useRef(null);

  const onDown = (e) => {
    const parent = e.currentTarget.parentElement.getBoundingClientRect();
    const self = e.currentTarget.getBoundingClientRect();
    drag.current = {
      pw: parent.width, ph: parent.height, w: self.width, h: self.height,
      px: parent.left, py: parent.top,
      dx: e.clientX - self.left, dy: e.clientY - self.top,
    };
    e.currentTarget.setPointerCapture(e.pointerId);
  };
  const onMove = (e) => {
    if (!drag.current) return;
    const d = drag.current;
    let left = e.clientX - d.px - d.dx;
    let top = e.clientY - d.py - d.dy;
    left = Math.max(6, Math.min(d.pw - d.w - 6, left));
    top = Math.max(46, Math.min(d.ph - d.h - 10, top));
    const cx = (left + d.w / 2) / d.pw;
    setPos({ x: cx, y: top });
  };
  const onUp = (e) => {
    drag.current = null;
    try { localStorage.setItem('ov_pos', JSON.stringify(pos)); } catch {}
  };

  return (
    <div onPointerDown={onDown} onPointerMove={onMove} onPointerUp={onUp}
      style={{
        position: 'absolute', top: pos.y, left: `${pos.x * 100}%`,
        transform: 'translateX(-50%)', cursor: 'grab', touchAction: 'none', zIndex: 50,
      }}>
      {children}
    </div>
  );
}

// ── Control dock ──────────────────────────────────────────────────────────────
const DK = {
  bg: '#0E0E0F', surface: '#1A1A1C', border: '#2E2E32', text: '#E8E6E0',
  muted: '#6B6968', accent: '#F0C040', orange: '#E07A52', green: '#2EA84A', danger: '#E05252',
};
function Btn({ children, onClick, tone = 'default', active, disabled }) {
  const tones = {
    default: { bg: 'transparent', bd: DK.border, fg: DK.text },
    orange: { bg: active ? 'rgba(224,122,82,0.18)' : 'transparent', bd: DK.orange, fg: DK.orange },
    green: { bg: active ? 'rgba(46,168,74,0.18)' : 'transparent', bd: DK.green, fg: DK.green },
    danger: { bg: 'transparent', bd: DK.danger, fg: DK.danger },
    accent: { bg: active ? 'rgba(240,192,64,0.16)' : 'transparent', bd: DK.accent, fg: DK.accent },
  };
  const t = tones[tone];
  return (
    <button onClick={onClick} disabled={disabled} style={{
      flex: 1, padding: '11px 10px', borderRadius: 9, cursor: disabled ? 'not-allowed' : 'pointer',
      background: t.bg, border: `1.5px solid ${t.bd}`, color: t.fg,
      fontFamily: "'Bebas Neue','Noto Sans KR',sans-serif", fontSize: 16, letterSpacing: '0.6px',
      opacity: disabled ? 0.32 : 1, transition: 'background 0.15s', whiteSpace: 'nowrap',
    }}>{children}</button>
  );
}

function App() {
  const [now, setNow] = React.useState(new Date());
  const [segIndex, setSegIndex] = React.useState(0);
  const [timerStatus, setTimerStatus] = React.useState('idle'); // idle | running | paused
  const [remaining, setRemaining] = React.useState(SEGMENTS[0].dur);
  const [swRunning, setSwRunning] = React.useState(false);
  const [swElapsed, setSwElapsed] = React.useState(0);
  const [showLabel, setShowLabel] = React.useState(true);

  const last = React.useRef(performance.now());
  const statusRef = React.useRef(timerStatus);
  const swRef = React.useRef(swRunning);
  statusRef.current = timerStatus; swRef.current = swRunning;

  React.useEffect(() => {
    let raf;
    const tick = () => {
      const t = performance.now();
      const dt = t - last.current; last.current = t;
      setNow(new Date());
      if (statusRef.current === 'running') {
        setRemaining((r) => {
          const nr = r - dt;
          if (nr <= 0) {
            setSegIndex((idx) => {
              if (idx + 1 < SEGMENTS.length) { setTimeout(() => setRemaining(SEGMENTS[idx + 1].dur), 0); return idx + 1; }
              setTimeout(() => { setTimerStatus('idle'); setRemaining(SEGMENTS[idx].dur); }, 0);
              return idx;
            });
            return 0;
          }
          return nr;
        });
      }
      if (swRef.current) setSwElapsed((e) => e + dt);
      raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, []);

  const seg = SEGMENTS[segIndex];
  const timerActive = timerStatus !== 'idle';
  const swActive = swRunning || swElapsed > 0;
  const widgetState = !timerActive && !swActive ? 'idle'
    : timerActive && !swActive ? 'timer'
    : !timerActive && swActive ? 'stopwatch' : 'both';
  const ending = timerActive && remaining <= 10000 && remaining > 0;

  // actions
  const timerToggle = () => setTimerStatus((s) => s === 'running' ? 'paused' : 'running');
  const timerNext = () => {
    const ni = (segIndex + 1) % SEGMENTS.length;
    setSegIndex(ni); setRemaining(SEGMENTS[ni].dur);
  };
  const timerReset = () => { setTimerStatus('idle'); setSegIndex(0); setRemaining(SEGMENTS[0].dur); };
  const jumpSeg = (i) => { setSegIndex(i); setRemaining(SEGMENTS[i].dur); };
  const swToggle = () => setSwRunning((r) => !r);
  const swReset = () => { setSwRunning(false); setSwElapsed(0); };

  const stateMeta = {
    idle: { label: 'IDLE', desc: '현재 시각 표시', color: DK.muted },
    timer: { label: 'TIMER', desc: '세그먼트명 + 남은 시간 · 테두리 카운트다운', color: DK.orange },
    stopwatch: { label: 'STOPWATCH', desc: '경과 시간 · 초록 체이싱 아크', color: DK.green },
    both: { label: 'BOTH', desc: '타이머 + 스톱워치 나란히', color: DK.accent },
  }[widgetState];

  const timerObj = { label: showLabel ? seg.name : null, remaining, total: seg.dur, color: seg.color };

  return (
    <div style={{ display: 'flex', gap: 40, alignItems: 'flex-start', flexWrap: 'wrap', justifyContent: 'center' }}>
      {/* Phone */}
      <div style={{ position: 'relative' }}>
        <AndroidDevice>
          <div style={{ position: 'relative', height: '100%' }}>
            <BackgroundApp />
            <DraggablePill>
              <TimerOverlayWidget
                state={widgetState} now={now}
                timer={timerObj} stopwatch={{ elapsed: swElapsed }} ending={ending} />
            </DraggablePill>
          </div>
        </AndroidDevice>
        <div style={{ textAlign: 'center', marginTop: 14, color: DK.muted, fontSize: 12.5,
          fontFamily: "'Noto Sans KR',sans-serif", letterSpacing: '0.2px' }}>
          위젯을 드래그해 위치를 옮겨보세요 · 다른 앱 위에 항상 표시됩니다
        </div>
      </div>

      {/* Control dock */}
      <div style={{ width: 340, display: 'flex', flexDirection: 'column', gap: 18 }}>
        <div>
          <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 30, letterSpacing: '1.5px', color: DK.accent }}>
            OVERLAY WIDGET
          </div>
          <div style={{ color: DK.muted, fontSize: 13, fontFamily: "'Noto Sans KR',sans-serif", marginTop: 2 }}>
            플로팅 오버레이 · 인터랙티브 프로토타입
          </div>
        </div>

        {/* live state */}
        <div style={{ background: DK.surface, border: `1px solid ${DK.border}`, borderRadius: 14, padding: '14px 16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <span style={{ width: 8, height: 8, borderRadius: '50%', background: stateMeta.color }} />
            <span style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 19, letterSpacing: '1px', color: stateMeta.color }}>
              {stateMeta.label}
            </span>
            <span style={{ marginLeft: 'auto', color: DK.muted, fontSize: 11, fontFamily: "'Bebas Neue',sans-serif", letterSpacing: '0.5px' }}>STATE</span>
          </div>
          <div style={{ color: DK.muted, fontSize: 12.5, fontFamily: "'Noto Sans KR',sans-serif", marginTop: 6 }}>
            {stateMeta.desc}
          </div>
        </div>

        {/* timer controls */}
        <Section title="TIMER" icon="⏱">
          <div style={{ display: 'flex', gap: 8 }}>
            <Btn tone="orange" active={timerStatus === 'running'} onClick={timerToggle}>
              {timerStatus === 'running' ? 'PAUSE' : (timerStatus === 'paused' ? 'RESUME' : 'START')}
            </Btn>
            <Btn tone="accent" onClick={timerNext}>▶ 다음</Btn>
            <Btn tone="danger" onClick={timerReset}>RST</Btn>
          </div>
          <SegList segIndex={segIndex} onJump={jumpSeg} remaining={remaining} />
          <label style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 10, cursor: 'pointer',
            color: DK.muted, fontSize: 12.5, fontFamily: "'Noto Sans KR',sans-serif" }}>
            <input type="checkbox" checked={showLabel} onChange={(e) => setShowLabel(e.target.checked)}
              style={{ accentColor: DK.orange, width: 15, height: 15 }} />
            위젯에 세그먼트명 표시
          </label>
        </Section>

        {/* stopwatch controls */}
        <Section title="STOPWATCH" icon="⏲">
          <div style={{ display: 'flex', gap: 8 }}>
            <Btn tone="green" active={swRunning} onClick={swToggle}>
              {swRunning ? 'PAUSE' : (swElapsed > 0 ? 'RESUME' : 'START')}
            </Btn>
            <Btn tone="danger" onClick={swReset} disabled={!swActive}>RST</Btn>
          </div>
        </Section>
      </div>
    </div>
  );
}

function Section({ title, icon, children }) {
  return (
    <div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginBottom: 9 }}>
        <span style={{ fontSize: 13 }}>{icon}</span>
        <span style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 15, letterSpacing: '1.5px', color: DK.muted }}>{title}</span>
        <div style={{ flex: 1, height: 1, background: DK.border }} />
      </div>
      {children}
    </div>
  );
}

function SegList({ segIndex, onJump, remaining }) {
  return (
    <div style={{ marginTop: 10, display: 'flex', flexDirection: 'column', gap: 5 }}>
      {SEGMENTS.map((s, i) => {
        const cur = i === segIndex;
        return (
          <div key={i} onClick={() => onJump(i)} style={{
            display: 'flex', alignItems: 'center', gap: 9, padding: '7px 11px', borderRadius: 8, cursor: 'pointer',
            background: cur ? 'rgba(255,255,255,0.04)' : 'transparent',
            border: `1px solid ${cur ? s.color : 'transparent'}`,
          }}>
            <span style={{ width: 9, height: 9, borderRadius: '50%', background: s.color, flexShrink: 0 }} />
            <span style={{ flex: 1, color: cur ? DK.text : DK.muted, fontSize: 13, fontFamily: "'Noto Sans KR',sans-serif" }}>{s.name}</span>
            <span style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 15, letterSpacing: '0.5px',
              color: cur ? s.color : DK.muted }}>
              {cur ? fmtDur(remaining) : fmtDur(s.dur)}
            </span>
          </div>
        );
      })}
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
