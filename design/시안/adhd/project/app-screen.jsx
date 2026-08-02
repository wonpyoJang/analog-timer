// Main app screen — Analog Timer. Live timer/stopwatch/segments + Tweaks.

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "faceTheme": "light",
  "timerStyle": "ring",
  "centerLayout": "plate"
}/*EDITMODE-END*/;

const S = {
  bg: '#0E0E0F', surface: '#1A1A1C', surface2: '#161618', border: '#2E2E32',
  text: '#E8E6E0', muted: '#6B6968', faint: '#46443F',
  accent: '#F0C040', orange: '#E07A52', orangeDk: '#C05A28', green: '#2EA84A', danger: '#E05252', blue: '#4A90D9',
};

const DEFAULT_SEGMENTS = [
  { name: '할 것 1', color: '#E07A52', mins: 2 },
  { name: '휴식 1', color: '#4A90D9', mins: 5 },
  { name: '할 것 2', color: '#E07A52', mins: 5 },
  { name: '휴식 2', color: '#4A90D9', mins: 5 },
  { name: '할 것 3', color: '#E07A52', mins: 10 },
];

function Btn({ children, onClick, tone = 'default', active, disabled, size = 'md' }) {
  const tones = {
    default: { bg: 'transparent', bd: S.border, fg: S.text },
    orange: { bg: active ? 'rgba(224,122,82,0.16)' : 'transparent', bd: S.orange, fg: S.orange },
    green: { bg: active ? 'rgba(46,168,74,0.16)' : 'transparent', bd: S.green, fg: S.green },
    danger: { bg: 'transparent', bd: S.danger, fg: S.danger },
    accent: { bg: active ? 'rgba(240,192,64,0.14)' : 'transparent', bd: S.accent, fg: S.accent },
  };
  const t = tones[tone];
  return (
    <button onClick={onClick} disabled={disabled} style={{
      padding: size === 'sm' ? '8px 10px' : '11px 12px', borderRadius: 9,
      background: t.bg, border: `1.5px solid ${t.bd}`, color: t.fg, cursor: disabled ? 'not-allowed' : 'pointer',
      fontFamily: "'Bebas Neue','Noto Sans KR',sans-serif", fontSize: size === 'sm' ? 14 : 15.5, letterSpacing: '0.6px',
      opacity: disabled ? 0.3 : 1, transition: 'background .15s', whiteSpace: 'nowrap', flexShrink: 0,
    }}>{children}</button>
  );
}

function App() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);
  const [now, setNow] = React.useState(new Date());
  const [segments, setSegments] = React.useState(DEFAULT_SEGMENTS);
  const [segIndex, setSegIndex] = React.useState(0);
  const [timerStatus, setTimerStatus] = React.useState('running');
  const [remaining, setRemaining] = React.useState(DEFAULT_SEGMENTS[0].mins * 60000);
  const [swRunning, setSwRunning] = React.useState(true);
  const [swElapsed, setSwElapsed] = React.useState(0);
  const [laps, setLaps] = React.useState([]);
  const [widgetOn, setWidgetOn] = React.useState(true);

  const last = React.useRef(performance.now());
  const refs = React.useRef({});
  refs.current = { timerStatus, swRunning, segIndex, segments };

  React.useEffect(() => {
    let raf;
    const tick = () => {
      const p = performance.now(), dt = p - last.current; last.current = p;
      setNow(new Date());
      const r = refs.current;
      if (r.timerStatus === 'running') {
        setRemaining((rem) => {
          const nr = rem - dt;
          if (nr <= 0) {
            const ni = r.segIndex + 1;
            if (ni < r.segments.length) { setSegIndex(ni); return r.segments[ni].mins * 60000; }
            setTimerStatus('idle'); return 0;
          }
          return nr;
        });
      }
      if (r.swRunning) setSwElapsed((e) => e + dt);
      raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, []);

  const seg = segments[segIndex] || segments[0];
  const timerActive = timerStatus !== 'idle';
  const swActive = swRunning || swElapsed > 0;
  const ending = timerActive && remaining <= 10000 && remaining > 0;
  const timer = { label: seg.name, remaining, total: seg.mins * 60000, color: seg.color };

  // actions
  const timerToggle = () => setTimerStatus((s) => s === 'running' ? 'paused' : 'running');
  const timerNext = () => { const ni = (segIndex + 1) % segments.length; setSegIndex(ni); setRemaining(segments[ni].mins * 60000); };
  const timerReset = () => { setTimerStatus('idle'); setSegIndex(0); setRemaining(segments[0].mins * 60000); };
  const swToggle = () => setSwRunning((r) => !r);
  const swLap = () => setLaps((l) => [swElapsed, ...l]);
  const swReset = () => { setSwRunning(false); setSwElapsed(0); setLaps([]); };

  const setMins = (i, v) => setSegments((arr) => arr.map((s, j) => j === i ? { ...s, mins: v } : s));
  const setName = (i, v) => setSegments((arr) => arr.map((s, j) => j === i ? { ...s, name: v } : s));
  const delSeg = (i) => setSegments((arr) => arr.filter((_, j) => j !== i));
  const addSeg = () => setSegments((arr) => [...arr, { name: `할 것 ${arr.length + 1}`, color: S.orange, mins: 5 }]);

  const timerLabel = timerStatus === 'running' ? 'PAUSE' : (timerStatus === 'paused' ? 'RESUME' : 'START');
  const swLabel = swRunning ? 'PAUSE' : (swElapsed > 0 ? 'RESUME' : 'START');

  return (
    <div style={{ minHeight: '100%', background: S.bg, color: S.text, fontFamily: "'Noto Sans KR',system-ui,sans-serif", paddingBottom: 28 }}>
      {/* header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '16px 18px 8px' }}>
        <span style={{ fontSize: 26 }}>⏱️</span>
        <span style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 30, letterSpacing: '2px', color: S.accent, flex: 1 }}>ANALOG TIMER</span>
        <button onClick={() => setWidgetOn((w) => !w)} style={{
          padding: '7px 12px', borderRadius: 9, cursor: 'pointer',
          border: `1.5px solid ${widgetOn ? S.accent : S.border}`, background: widgetOn ? 'rgba(240,192,64,0.12)' : 'transparent',
          color: widgetOn ? S.accent : S.muted, fontFamily: "'Noto Sans KR',sans-serif", fontSize: 13, fontWeight: 600,
        }}>위젯 {widgetOn ? 'ON' : 'OFF'}</button>
      </div>

      {/* clock */}
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', padding: '6px 0 0' }}>
        <AppClock size={304} faceTheme={t.faceTheme} timerStyle={t.timerStyle} centerLayout={t.centerLayout}
          now={now} timer={timer} stopwatch={{ elapsed: swElapsed }} ending={ending} />

        {/* below-bar readouts */}
        {t.centerLayout === 'below' && (
          <div style={{ display: 'flex', gap: 10, marginTop: 14 }}>
            <Readout color={ending ? S.danger : seg.color} label={seg.name} value={acFmt(remaining)} blink={ending} />
            <Readout color={S.green} value={acFmt(swElapsed)} />
          </div>
        )}

        {/* legend */}
        <div style={{ display: 'flex', gap: 20, marginTop: 16, color: S.muted, fontSize: 12.5 }}>
          <Legend color={S.orange} text={`타이머 — 안쪽 ${t.timerStyle === 'spiral' ? '나선' : '링'}`} />
          <Legend color={S.green} text="스톱워치 — 바깥 링" />
        </div>
      </div>

      {/* controls */}
      <div style={{ display: 'flex', gap: 14, padding: '20px 18px 0' }}>
        <ControlCol title="TIMER" icon="⏱">
          <Btn tone="orange" active={timerStatus === 'running'} onClick={timerToggle} size="sm">{timerLabel}</Btn>
          <Btn tone="accent" onClick={timerNext} size="sm">▶ 다음</Btn>
          <Btn tone="danger" onClick={timerReset} size="sm">RST</Btn>
        </ControlCol>
        <div style={{ width: 1, background: S.border, alignSelf: 'stretch' }} />
        <ControlCol title="STOPWATCH" icon="⏲">
          <Btn tone="green" active={swRunning} onClick={swToggle} size="sm">{swLabel}</Btn>
          <Btn onClick={swLap} disabled={!swRunning} size="sm">LAP</Btn>
          <Btn tone="danger" onClick={swReset} disabled={!swActive} size="sm">RST</Btn>
        </ControlCol>
      </div>

      {laps.length > 0 && (
        <div style={{ margin: '14px 18px 0', display: 'flex', flexDirection: 'column', gap: 4 }}>
          {laps.slice(0, 3).map((lp, i) => (
            <div key={i} style={{ display: 'flex', justifyContent: 'space-between', fontSize: 13, color: S.muted, fontFamily: "'Bebas Neue',sans-serif", letterSpacing: '1px' }}>
              <span>LAP {laps.length - i}</span><span style={{ color: S.green }}>{acFmt(lp)}</span>
            </div>
          ))}
        </div>
      )}

      {/* segments */}
      <div style={{ margin: '22px 14px 0', background: S.surface, border: `1px solid ${S.border}`, borderRadius: 16, padding: '16px 14px' }}>
        <div style={{ display: 'flex', alignItems: 'center', marginBottom: 12 }}>
          <span style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 15, letterSpacing: '2px', color: S.muted, flex: 1 }}>TIMER SEGMENTS</span>
          <button onClick={addSeg} style={{ background: 'transparent', border: `1.5px solid ${S.border}`, color: S.muted, borderRadius: 8, padding: '5px 11px', cursor: 'pointer', fontSize: 13, fontFamily: "'Noto Sans KR',sans-serif" }}>+ 추가</button>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 9 }}>
          {segments.map((s, i) => {
            const cur = i === segIndex && timerActive;
            return (
              <div key={i} onClick={() => { setSegIndex(i); setRemaining(s.mins * 60000); }} style={{
                display: 'flex', alignItems: 'center', gap: 11, padding: '11px 13px', borderRadius: 11, cursor: 'pointer',
                background: S.surface2, border: `1.5px solid ${cur ? s.color : S.border}`,
              }}>
                <span style={{ width: 11, height: 11, borderRadius: '50%', background: s.color, flexShrink: 0 }} />
                <input value={s.name} onClick={(e) => e.stopPropagation()} onChange={(e) => setName(i, e.target.value)}
                  style={{ flex: 1, minWidth: 0, background: 'transparent', border: 'none', color: cur ? S.text : '#C9C6C0', fontSize: 14.5, fontFamily: "'Noto Sans KR',sans-serif", outline: 'none' }} />
                <div onClick={(e) => e.stopPropagation()} style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <input type="number" step="0.5" min="0" value={s.mins} onChange={(e) => setMins(i, parseFloat(e.target.value) || 0)}
                    style={{ width: 52, textAlign: 'center', background: '#0E0E0F', border: `1px solid ${S.border}`, borderRadius: 7, color: S.text, fontSize: 14, fontFamily: "'Bebas Neue',sans-serif", letterSpacing: '0.5px', padding: '6px 4px', outline: 'none' }} />
                  <span style={{ fontSize: 12.5, color: S.muted }}>분</span>
                  <button onClick={() => delSeg(i)} style={{ background: 'transparent', border: 'none', color: S.faint, cursor: 'pointer', fontSize: 16, lineHeight: 1, padding: '2px 4px' }}>✕</button>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Tweaks */}
      <TweaksPanel>
        <TweakSection label="시계 페이스" />
        <TweakRadio label="테마" value={t.faceTheme} options={['light', 'dark']} onChange={(v) => setTweak('faceTheme', v)} />
        <TweakSection label="진행 표시" />
        <TweakRadio label="타이머" value={t.timerStyle} options={['ring', 'spiral']} onChange={(v) => setTweak('timerStyle', v)} />
        <TweakSection label="중앙 리드아웃" />
        <TweakRadio label="배치" value={t.centerLayout} options={['plate', 'minimal', 'below']} onChange={(v) => setTweak('centerLayout', v)} />
      </TweaksPanel>
    </div>
  );
}

function Readout({ color, label, value, blink }) {
  return (
    <div className={blink ? 'cw-blink' : ''} style={{ display: 'flex', alignItems: 'center', gap: 7, padding: '8px 14px', borderRadius: 22, background: 'rgba(255,255,255,0.05)', border: `1px solid ${color}33` }}>
      <span style={{ width: 7, height: 7, borderRadius: '50%', background: color }} />
      {label && <span style={{ fontFamily: "'Noto Sans KR',sans-serif", fontSize: 12.5, fontWeight: 600, color: blink ? S.danger : S.orangeDk }}>{label}</span>}
      <span style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 20, color, letterSpacing: '1px' }}>{value}</span>
    </div>
  );
}
function Legend({ color, text }) {
  return <span style={{ display: 'flex', alignItems: 'center', gap: 6 }}><span style={{ width: 8, height: 8, borderRadius: '50%', background: color }} />{text}</span>;
}
function ControlCol({ title, icon, children }) {
  return (
    <div style={{ flex: 1 }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6, marginBottom: 10 }}>
        <span style={{ fontSize: 12 }}>{icon}</span>
        <span style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 14, letterSpacing: '2px', color: S.muted }}>{title}</span>
      </div>
      <div style={{ display: 'flex', gap: 7 }}>{children.map((c, i) => React.cloneElement(c, { key: i, style: { ...(c.props.style || {}) } }))}</div>
    </div>
  );
}

function Mount() {
  return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'radial-gradient(900px 600px at 50% -5%, #18181b, #0b0b0c 70%)', padding: '32px 20px' }}>
      <AndroidDevice dark>
        <App />
      </AndroidDevice>
    </div>
  );
}
ReactDOM.createRoot(document.getElementById('root')).render(<Mount />);
