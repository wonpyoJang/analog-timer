// AppClock — full-size hybrid analog clock for the main app screen.
// Options: faceTheme 'light'|'dark', timerStyle 'spiral'|'ring', centerLayout 'plate'|'below'|'minimal'
// Self-contained (own helpers, ac- prefix where it matters).

const AC = { seg: '#E07A52', segDark: '#C05A28', green: '#2EA84A', danger: '#E05252', accent: '#F0C040' };

function acPol(cx, cy, r, deg) {
  const a = (deg - 90) * Math.PI / 180;
  return [cx + r * Math.cos(a), cy + r * Math.sin(a)];
}
function acFmt(ms) {
  if (ms < 0) ms = 0;
  const t = Math.round(ms / 1000), h = Math.floor(t / 3600), m = Math.floor((t % 3600) / 60), s = t % 60;
  const p = (n) => String(n).padStart(2, '0');
  return h > 0 ? `${h}:${p(m)}:${p(s)}` : `${p(m)}:${p(s)}`;
}

function acRing({ r, color, frac, width, track }) {
  return (
    <g>
      {track && <circle cx="100" cy="100" r={r} fill="none" stroke={track} strokeWidth={width} />}
      <circle cx="100" cy="100" r={r} fill="none" stroke={color} strokeWidth={width} strokeLinecap="round"
        pathLength="100" strokeDasharray={`${Math.max(0, Math.min(100, frac * 100))} 100`}
        transform="rotate(-90 100 100)" style={{ transition: 'stroke 0.25s linear' }} />
    </g>
  );
}

function acSpiral({ frac, turns, rOuter, rInner, color, width }) {
  const thetaMax = turns * 360;
  const end = thetaMax * Math.max(0, Math.min(1, frac));
  const pts = [];
  for (let a = 0; a <= end; a += 4) {
    const r = rOuter - (rOuter - rInner) * (a / thetaMax);
    pts.push(acPol(100, 100, r, a));
  }
  if (pts.length < 2) return null;
  const d = pts.map((p, i) => `${i ? 'L' : 'M'} ${p[0].toFixed(2)} ${p[1].toFixed(2)}`).join(' ');
  return <path d={d} fill="none" stroke={color} strokeWidth={width} strokeLinecap="round" strokeLinejoin="round" />;
}

function acTicks({ minor, major }) {
  const els = [];
  for (let i = 0; i < 60; i++) {
    const maj = i % 5 === 0;
    const [x1, y1] = acPol(100, 100, 94, i * 6);
    const [x2, y2] = acPol(100, 100, maj ? 85 : 89, i * 6);
    els.push(<line key={i} x1={x1} y1={y1} x2={x2} y2={y2} stroke={maj ? major : minor} strokeWidth={maj ? 2.4 : 1} strokeLinecap="round" />);
  }
  return <g>{els}</g>;
}
function acNumbers({ color }) {
  const els = [];
  for (let n = 1; n <= 12; n++) {
    const [x, y] = acPol(100, 100, 71, n * 30);
    els.push(<text key={n} x={x} y={y} fill={color} fontFamily="'Bebas Neue',sans-serif" fontSize="14" textAnchor="middle" dominantBaseline="central" letterSpacing="0.4">{n}</text>);
  }
  return <g>{els}</g>;
}
function acHand({ deg, inner = 0, outer, width, color }) {
  const [x1, y1] = acPol(100, 100, inner, deg);
  const [x2, y2] = acPol(100, 100, outer, deg);
  return <line x1={x1} y1={y1} x2={x2} y2={y2} stroke={color} strokeWidth={width} strokeLinecap="round" />;
}

function AppClock({ size = 300, faceTheme, timerStyle, centerLayout, now, timer, stopwatch, ending }) {
  const h = now.getHours(), m = now.getMinutes(), s = now.getSeconds(), ms = now.getMilliseconds();
  const hourDeg = (h % 12) * 30 + m * 0.5, minDeg = m * 6 + s * 0.1, secDeg = s * 6 + ms * 0.006;
  const tColor = ending ? AC.danger : timer.color;
  const tFrac = timer.remaining / timer.total;
  const swFrac = (stopwatch.elapsed % 60000) / 60000;
  const dark = faceTheme === 'dark';
  const minimal = centerLayout === 'minimal';
  const showCenter = centerLayout !== 'below';

  const C = dark
    ? { face: '#161618', rim: '#2E2E32', tickMin: '#37373B', tickMaj: '#6E6E73', num: '#9E9A97', hand: '#E8E6E0', plate: '#0E0E0F', plateStroke: '#2E2E32' }
    : { face: '#FBFBF8', rim: '#E4E2DD', tickMin: '#CBC9C4', tickMaj: '#1C1C1E', num: '#1C1C1E', hand: '#1C1C1E', plate: '#F1EFE9', plateStroke: '#DEDCD6' };

  const shortHands = minimal;
  const plate = centerLayout === 'plate';

  return (
    <div style={{ position: 'relative', width: size, height: size }}>
      <svg viewBox="0 0 200 200" width={size} height={size}>
        <circle cx="100" cy="100" r="98" fill={C.face} stroke={C.rim} strokeWidth="2" />
        {acTicks({ minor: C.tickMin, major: C.tickMaj })}
        {!dark && acNumbers({ color: C.num })}

        {/* stopwatch — outer ring */}
        {acRing({ r: 79, color: AC.green, frac: swFrac, width: dark ? 4 : 3.5, track: dark ? '#222226' : '#EDEBE6' })}

        {/* timer — inner spiral or ring */}
        <g className={ending ? 'cw-blink' : ''}>
          {timerStyle === 'spiral'
            ? acSpiral({ frac: tFrac, turns: 2.2, rOuter: 66, rInner: 43, color: tColor, width: 4.5 })
            : acRing({ r: 60, color: tColor, frac: tFrac, width: dark ? 5 : 4.5, track: dark ? '#222226' : '#EDEBE6' })}
        </g>

        {/* hands */}
        {shortHands ? (
          <g>
            {acHand({ deg: hourDeg, inner: 42, outer: 54, width: 5, color: C.hand })}
            {acHand({ deg: minDeg, inner: 42, outer: 73, width: 3.5, color: C.hand })}
            {acHand({ deg: secDeg, inner: 42, outer: 77, width: 1.4, color: AC.danger })}
          </g>
        ) : (
          <g>
            {acHand({ deg: hourDeg, outer: 50, width: 5, color: C.hand })}
            {acHand({ deg: minDeg, outer: 70, width: 3.5, color: C.hand })}
            {acHand({ deg: secDeg, inner: -14, outer: 76, width: 1.4, color: AC.danger })}
          </g>
        )}

        {minimal && <circle cx="100" cy="100" r="34" fill={C.face} opacity="0.82" />}
        {plate && <circle cx="100" cy="100" r="37" fill={C.plate} stroke={C.plateStroke} strokeWidth="1.2" />}
        {!plate && !minimal && <circle cx="100" cy="100" r="4.5" fill={C.hand} stroke={dark ? '#161618' : '#fff'} strokeWidth="1.2" />}
        {(plate || minimal) && <circle cx="100" cy="100" r="2.6" fill={AC.danger} />}
      </svg>

      {showCenter && (
        <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', pointerEvents: 'none' }}>
          <div className={ending ? 'cw-blink' : ''} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
            {timer.label && <div style={{ fontFamily: "'Noto Sans KR',sans-serif", fontSize: size * 0.038, fontWeight: 600, color: ending ? AC.danger : AC.segDark, letterSpacing: '0.5px', lineHeight: 1.3 }}>{timer.label}</div>}
            <div style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: size * 0.11, lineHeight: 0.9, color: tColor, letterSpacing: '1px' }}>{acFmt(timer.remaining)}</div>
          </div>
          <div style={{ width: size * 0.14, height: 1, background: dark ? 'rgba(255,255,255,0.14)' : 'rgba(0,0,0,0.12)', margin: `${size * 0.012}px 0` }} />
          <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
            <span style={{ width: 6, height: 6, borderRadius: '50%', background: AC.green }} />
            <span style={{ fontFamily: "'Bebas Neue',sans-serif", fontSize: size * 0.062, color: AC.green, letterSpacing: '1px' }}>{acFmt(stopwatch.elapsed)}</span>
          </div>
        </div>
      )}
    </div>
  );
}

Object.assign(window, { AppClock, AC, acFmt });
