// AnalogClock — hybrid analog clock widget face (real time + timer + stopwatch)
// Three layout variants that solve the digital/hands overlap problem differently.
//   A 'below'   — clean dial, digital readouts in pills BELOW the dial
//   B 'subdial' — chronograph-style dark center subdial over full hands
//   C 'dark'    — dark minimal face, short floating hands, big center digital

const CW = {
  seg: '#E07A52', segDark: '#C05A28', green: '#2EA84A', danger: '#E05252',
  accent: '#F0C040', text: '#E8E6E0', muted: '#6B6968',
};

function pol(cx, cy, r, deg) {
  const a = (deg - 90) * Math.PI / 180;
  return [cx + r * Math.cos(a), cy + r * Math.sin(a)];
}
function fmt(ms) {
  if (ms < 0) ms = 0;
  const t = Math.round(ms / 1000), h = Math.floor(t / 3600), m = Math.floor((t % 3600) / 60), s = t % 60;
  const p = (n) => String(n).padStart(2, '0');
  return h > 0 ? `${h}:${p(m)}:${p(s)}` : `${p(m)}:${p(s)}`;
}

function Ring({ r, color, frac, width, track }) {
  return (
    <g>
      {track && <circle cx="100" cy="100" r={r} fill="none" stroke={track} strokeWidth={width} />}
      <circle cx="100" cy="100" r={r} fill="none" stroke={color} strokeWidth={width}
        strokeLinecap="round" pathLength="100" strokeDasharray={`${Math.max(0, Math.min(100, frac * 100))} 100`}
        transform="rotate(-90 100 100)" style={{ transition: 'stroke 0.25s linear' }} />
    </g>
  );
}

function Hand({ deg, inner = 0, outer, width, color, cap = 'round' }) {
  const [x1, y1] = pol(100, 100, inner, deg);
  const [x2, y2] = pol(100, 100, outer, deg);
  return <line x1={x1} y1={y1} x2={x2} y2={y2} stroke={color} strokeWidth={width} strokeLinecap={cap} />;
}

function Ticks({ minor, major }) {
  const els = [];
  for (let i = 0; i < 60; i++) {
    const isMaj = i % 5 === 0;
    const [x1, y1] = pol(100, 100, 94, i * 6);
    const [x2, y2] = pol(100, 100, isMaj ? 85 : 89, i * 6);
    els.push(<line key={i} x1={x1} y1={y1} x2={x2} y2={y2}
      stroke={isMaj ? major : minor} strokeWidth={isMaj ? 2.4 : 1} strokeLinecap="round" />);
  }
  return <g>{els}</g>;
}

function Numbers({ color }) {
  const els = [];
  for (let n = 1; n <= 12; n++) {
    const [x, y] = pol(100, 100, 70, n * 30);
    els.push(
      <text key={n} x={x} y={y} fill={color} fontFamily="'Bebas Neue',sans-serif" fontSize="15"
        textAnchor="middle" dominantBaseline="central" letterSpacing="0.5">{n}</text>
    );
  }
  return <g>{els}</g>;
}

function AnalogClock({ variant, now, timer, stopwatch, ending }) {
  const h = now.getHours(), m = now.getMinutes(), s = now.getSeconds(), ms = now.getMilliseconds();
  const hourDeg = (h % 12) * 30 + m * 0.5;
  const minDeg = m * 6 + s * 0.1;
  const secDeg = s * 6 + ms * 0.006;

  const tColor = ending ? CW.danger : timer.color;
  const tFrac = timer.remaining / timer.total;
  const swFrac = (stopwatch.elapsed % 60000) / 60000;

  const dark = variant === 'dark';
  const C = dark
    ? { face: '#161618', rim: '#2E2E32', tickMin: '#37373B', tickMaj: '#6E6E73', num: '#9E9A97', hand: '#E8E6E0', hub: '#E8E6E0' }
    : { face: '#FAFAF7', rim: '#E4E2DD', tickMin: '#C9C7C2', tickMaj: '#1C1C1E', num: '#1C1C1E', hand: '#1C1C1E', hub: '#1C1C1E' };

  // ring radii — timer inner, stopwatch outer (app rule)
  const swR = 80, tR = dark ? 64 : 62;

  const shortHands = dark; // variant C: floating hands, clear center

  return (
    <div style={{ position: 'relative', width: 244, height: 244 }}>
      <svg viewBox="0 0 200 200" width="244" height="244">
        <circle cx="100" cy="100" r="98" fill={C.face} stroke={C.rim} strokeWidth="2" />
        <Ticks minor={C.tickMin} major={C.tickMaj} />
        {!dark && <Numbers color={C.num} />}

        {/* progress rings */}
        <Ring r={swR} color={CW.green} frac={swFrac} width={dark ? 4 : 3} track={dark ? '#222226' : '#EDEBE6'} />
        <g className={ending ? 'cw-blink' : ''}>
          <Ring r={tR} color={tColor} frac={tFrac} width={dark ? 5 : 4} track={dark ? '#222226' : '#EDEBE6'} />
        </g>

        {/* hands */}
        {shortHands ? (
          <g>
            <Hand deg={hourDeg} inner={40} outer={52} width={5} color={C.hand} />
            <Hand deg={minDeg} inner={40} outer={72} width={3.5} color={C.hand} />
            <Hand deg={secDeg} inner={40} outer={76} width={1.4} color={CW.danger} />
          </g>
        ) : (
          <g>
            <Hand deg={hourDeg} outer={46} width={5} color={C.hand} />
            <Hand deg={minDeg} outer={66} width={3.5} color={C.hand} />
            <Hand deg={secDeg} inner={-14} outer={74} width={1.4} color={CW.danger} />
          </g>
        )}

        {/* center hub (variants A/B) */}
        {variant !== 'subdial' && !dark && (
          <circle cx="100" cy="100" r="4.5" fill={C.hub} stroke="#fff" strokeWidth="1.2" />
        )}
        {variant === 'subdial' && (
          <circle cx="100" cy="100" r="42" fill="#1A1A1C" stroke="#000" strokeOpacity="0.25" strokeWidth="1" />
        )}
      </svg>

      {/* ── center digital overlays ───────────────────────────── */}
      {variant === 'subdial' && (
        <CenterStack timer={timer} stopwatch={stopwatch} tColor={tColor} ending={ending} size="sm" />
      )}
      {variant === 'dark' && (
        <CenterStack timer={timer} stopwatch={stopwatch} tColor={tColor} ending={ending} size="lg" />
      )}
    </div>
  );
}

function CenterStack({ timer, stopwatch, tColor, ending, size }) {
  const lg = size === 'lg';
  return (
    <div style={{
      position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
      alignItems: 'center', justifyContent: 'center', pointerEvents: 'none', gap: lg ? 2 : 1,
    }}>
      <div className={ending ? 'cw-blink' : ''} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: lg ? 1 : 0 }}>
        {timer.label && (
          <div style={{ fontFamily: "'Noto Sans KR',sans-serif", fontSize: lg ? 11 : 8.5, fontWeight: 600,
            color: CW.segDark, letterSpacing: '0.5px', filter: ending ? 'none' : 'none', color: ending ? CW.danger : CW.segDark }}>
            {timer.label}
          </div>
        )}
        <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: lg ? 38 : 21, lineHeight: 0.95,
          color: tColor, letterSpacing: '1px' }}>{fmt(timer.remaining)}</div>
      </div>
      <div style={{ width: lg ? 46 : 30, height: 1, background: 'rgba(255,255,255,0.12)', margin: lg ? '3px 0' : '2px 0' }} />
      <div style={{ display: 'flex', alignItems: 'center', gap: lg ? 6 : 4 }}>
        <span style={{ width: lg ? 6 : 5, height: lg ? 6 : 5, borderRadius: '50%', background: CW.green }} />
        <span style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: lg ? 19 : 13, color: CW.green, letterSpacing: '1px' }}>
          {fmt(stopwatch.elapsed)}
        </span>
      </div>
    </div>
  );
}

// Digital readout pills (variant A — placed below the dial)
function ReadoutPills({ timer, stopwatch, tColor, ending }) {
  const pill = (border, children, blink) => (
    <div className={blink ? 'cw-blink' : ''} style={{
      display: 'flex', alignItems: 'center', gap: 7, padding: '7px 14px', borderRadius: 22,
      background: 'rgba(255,255,255,0.05)', border: `1px solid ${border}33`,
    }}>{children}</div>
  );
  return (
    <div style={{ display: 'flex', gap: 10, justifyContent: 'center', marginTop: 16 }}>
      {pill(tColor, (
        <React.Fragment>
          <span style={{ width: 7, height: 7, borderRadius: '50%', background: tColor }} />
          {timer.label && <span style={{ fontFamily: "'Noto Sans KR',sans-serif", fontSize: 12, fontWeight: 600, color: ending ? CW.danger : CW.segDark }}>{timer.label}</span>}
          <span style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 20, color: tColor, letterSpacing: '1px' }}>{fmt(timer.remaining)}</span>
        </React.Fragment>
      ), ending)}
      {pill(CW.green, (
        <React.Fragment>
          <span style={{ width: 7, height: 7, borderRadius: '50%', background: CW.green }} />
          <span style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: 20, color: CW.green, letterSpacing: '1px' }}>{fmt(stopwatch.elapsed)}</span>
        </React.Fragment>
      ), false)}
    </div>
  );
}

Object.assign(window, { AnalogClock, ReadoutPills, CW, fmt });
