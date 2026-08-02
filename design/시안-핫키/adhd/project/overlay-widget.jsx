// TimerOverlayWidget — Android floating overlay pill
// 4 states: idle / timer / stopwatch / both
// Border = timer remaining progress ring (depletes). Stopwatch = green chasing arc (live, no end).
// Spec source: overlay-widget-handoff.md

const OV = {
  surface: 'rgba(26,26,28,0.93)',   // #1A1A1C @93%
  border: '#2E2E32',
  text: '#E8E6E0',
  muted: '#6B6968',
  idleClock: '#9E9A97',
  timerOrange: '#E07A52',
  timerOrangeDark: '#C05A28',
  swGreen: '#2EA84A',
  danger: '#E05252',
};

// 6 segment colors (segColors) — timer dot/label/value/border take active segment color
const SEG_COLORS = ['#E07A52', '#4A90D9', '#E0B23C', '#B57BE0', '#E0729C', '#3FB9C9'];

function fmtClock(d) {
  const h = String(d.getHours()).padStart(2, '0');
  const m = String(d.getMinutes()).padStart(2, '0');
  return `${h}:${m}`;
}
function fmtDur(ms) {
  if (ms < 0) ms = 0;
  const t = Math.round(ms / 1000);
  const h = Math.floor(t / 3600);
  const m = Math.floor((t % 3600) / 60);
  const s = t % 60;
  const p = (n) => String(n).padStart(2, '0');
  return h > 0 ? `${h}:${p(m)}:${p(s)}` : `${p(m)}:${p(s)}`;
}

// rounded-pill perimeter path, starts top-center, clockwise. pathLength normalised to 100.
function pillPath(w, h, inset) {
  const x = inset, y = inset;
  const W = w - inset * 2, H = h - inset * 2;
  const r = Math.min(H / 2, 24);
  const cx = x + W / 2;
  return [
    `M ${cx} ${y}`,
    `H ${x + W - r}`,
    `A ${r} ${r} 0 0 1 ${x + W} ${y + r}`,
    `V ${y + H - r}`,
    `A ${r} ${r} 0 0 1 ${x + W - r} ${y + H}`,
    `H ${x + r}`,
    `A ${r} ${r} 0 0 1 ${x} ${y + H - r}`,
    `V ${y + r}`,
    `A ${r} ${r} 0 0 1 ${x + r} ${y}`,
    'Z',
  ].join(' ');
}

// Animated border. mode: 'idle' | 'progress' | 'chase'
function WidgetBorder({ w, h, mode, frac, color }) {
  if (!w || !h) return null;
  const inset = 1;
  const d = pillPath(w, h, inset);
  const track = (
    <path d={d} fill="none" stroke={OV.border} strokeWidth="1.5"
      vectorEffect="non-scaling-stroke" pathLength="100" />
  );
  let progress = null;
  if (mode === 'progress') {
    const p = Math.max(0, Math.min(100, frac * 100));
    progress = (
      <path d={d} fill="none" stroke={color} strokeWidth="2.5" strokeLinecap="round"
        vectorEffect="non-scaling-stroke" pathLength="100"
        strokeDasharray={`${p} ${100 - p}`} strokeDashoffset="0"
        style={{ transition: 'stroke 0.25s linear' }} />
    );
  } else if (mode === 'chase') {
    progress = (
      <path className="ov-chase" d={d} fill="none" stroke={color} strokeWidth="2.5"
        strokeLinecap="round" vectorEffect="non-scaling-stroke" pathLength="100"
        strokeDasharray="26 74" />
    );
  }
  return (
    <svg width={w} height={h} viewBox={`0 0 ${w} ${h}`}
      style={{ position: 'absolute', inset: 0, overflow: 'visible', pointerEvents: 'none' }}>
      {track}
      {progress}
    </svg>
  );
}

const Dot = ({ color, size = 6 }) => (
  <span style={{
    width: size, height: size, borderRadius: '50%', background: color,
    flexShrink: 0, display: 'inline-block',
  }} />
);

function TimerOverlayWidget({ state, now, timer, stopwatch, ending }) {
  const ref = React.useRef(null);
  const [size, setSize] = React.useState({ w: 0, h: 0 });

  React.useLayoutEffect(() => {
    if (!ref.current) return;
    const el = ref.current;
    const ro = new ResizeObserver(() => {
      setSize({ w: el.offsetWidth, h: el.offsetHeight });
    });
    ro.observe(el);
    setSize({ w: el.offsetWidth, h: el.offsetHeight });
    return () => ro.disconnect();
  }, [state, timer && timer.label]);

  const valueFont = {
    fontFamily: "'Bebas Neue', 'Noto Sans KR', sans-serif",
    fontSize: 19, lineHeight: 1, letterSpacing: '1px', fontWeight: 400,
  };
  const labelFont = {
    fontFamily: "'Noto Sans KR', 'Bebas Neue', sans-serif",
    fontSize: 10, lineHeight: 1, letterSpacing: '0.5px', fontWeight: 500,
  };

  // timer color (segment-driven), red override when ending
  const tColor = ending ? OV.danger : (timer ? timer.color : OV.timerOrange);
  const tLabelColor = ending ? OV.danger : (timer ? shade(timer.color, -0.18) : OV.timerOrangeDark);

  // border behaviour
  let border = { mode: 'idle' };
  if (state === 'timer' || state === 'both') {
    border = { mode: 'progress', frac: timer ? timer.remaining / timer.total : 0, color: tColor };
  } else if (state === 'stopwatch') {
    border = { mode: 'chase', color: OV.swGreen };
  }

  const TimerSection = () => {
    const hasLabel = timer && timer.label;
    return (
      <div className={ending ? 'ov-blink' : ''}
        style={{ display: 'flex', alignItems: hasLabel ? 'flex-start' : 'center', gap: 5 }}>
        <span style={{ marginTop: hasLabel ? 3 : 0 }}><Dot color={tColor} /></span>
        <div style={{ display: 'flex', flexDirection: 'column', gap: hasLabel ? 2 : 0 }}>
          {hasLabel && (
            <span style={{ ...labelFont, color: tLabelColor, whiteSpace: 'nowrap' }}>{timer.label}</span>
          )}
          <span style={{ ...valueFont, color: tColor }}>{fmtDur(timer.remaining)}</span>
        </div>
      </div>
    );
  };

  const SwSection = () => (
    <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
      <Dot color={OV.swGreen} />
      <span style={{ ...valueFont, color: OV.swGreen }}>{fmtDur(stopwatch.elapsed)}</span>
    </div>
  );

  let content;
  if (state === 'idle') {
    content = <span style={{ ...valueFont, color: OV.idleClock }}>{fmtClock(now)}</span>;
  } else if (state === 'timer') {
    content = <TimerSection />;
  } else if (state === 'stopwatch') {
    content = <SwSection />;
  } else {
    content = (
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <TimerSection />
        <SwSection />
      </div>
    );
  }

  return (
    <div ref={ref} style={{
      position: 'relative', display: 'inline-flex', alignItems: 'center',
      padding: '5px 13px', borderRadius: 24,
      background: OV.surface,
      backdropFilter: 'blur(8px)', WebkitBackdropFilter: 'blur(8px)',
      boxShadow: '0 4px 12px rgba(0,0,0,0.6)',
      userSelect: 'none', whiteSpace: 'nowrap',
    }}>
      <WidgetBorder w={size.w} h={size.h} {...border} />
      <div style={{ position: 'relative', zIndex: 1 }}>{content}</div>
    </div>
  );
}

// lighten/darken a hex color by amount (-1..1)
function shade(hex, amt) {
  const c = hex.replace('#', '');
  let r = parseInt(c.slice(0, 2), 16), g = parseInt(c.slice(2, 4), 16), b = parseInt(c.slice(4, 6), 16);
  const f = (v) => Math.max(0, Math.min(255, Math.round(v + 255 * amt)));
  const h = (v) => f(v).toString(16).padStart(2, '0');
  return `#${h(r)}${h(g)}${h(b)}`;
}

Object.assign(window, { TimerOverlayWidget, SEG_COLORS, OV, fmtDur, fmtClock });
