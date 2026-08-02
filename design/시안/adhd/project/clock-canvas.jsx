// Clock widget design canvas — 3 live variants of the analog clock widget face.

const SEGS = [
  { name: '할 것 1', dur: 45000, color: '#E07A52' },
  { name: '휴식 1', dur: 30000, color: '#4A90D9' },
  { name: '할 것 2', dur: 40000, color: '#E0B23C' },
];

function useClockState() {
  const [now, setNow] = React.useState(new Date());
  const [segIndex, setSegIndex] = React.useState(0);
  const [remaining, setRemaining] = React.useState(SEGS[0].dur);
  const [swElapsed, setSwElapsed] = React.useState(0);
  const last = React.useRef(performance.now());
  const segRef = React.useRef(0); segRef.current = segIndex;

  React.useEffect(() => {
    let raf;
    const tick = () => {
      const t = performance.now(), dt = t - last.current; last.current = t;
      setNow(new Date());
      setSwElapsed((e) => e + dt);
      setRemaining((r) => {
        const nr = r - dt;
        if (nr <= 0) {
          const ni = (segRef.current + 1) % SEGS.length;
          setSegIndex(ni);
          return SEGS[ni].dur;
        }
        return nr;
      });
      raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, []);

  const seg = SEGS[segIndex];
  return {
    now,
    timer: { label: seg.name, remaining, total: seg.dur, color: seg.color },
    stopwatch: { elapsed: swElapsed },
    ending: remaining <= 10000 && remaining > 0,
  };
}

// Dark expandable widget card (home-screen overlay bubble, expanded)
function WidgetCard({ children, withPills }) {
  return (
    <div style={{
      width: 300, background: 'rgba(32,32,34,0.96)', borderRadius: 18,
      border: '1px solid rgba(255,255,255,0.07)',
      boxShadow: '0 18px 48px rgba(0,0,0,0.45)',
      padding: '14px 16px 16px', position: 'relative',
    }}>
      <div style={{ position: 'absolute', top: 12, right: 14, color: '#8A8A8E', fontSize: 16, lineHeight: 1 }}>⌃</div>
      <div style={{ display: 'flex', justifyContent: 'center', paddingTop: 6 }}>{children}</div>
      <div style={{ textAlign: 'center', marginTop: withPills ? 14 : 16, color: '#7A7A7E',
        fontSize: 12, fontFamily: "'Noto Sans KR',sans-serif" }}>탭하여 닫기</div>
    </div>
  );
}

function Wallpaper({ children }) {
  return (
    <div style={{
      width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center',
      background: 'linear-gradient(160deg, #c9d4e2 0%, #aeb9cc 32%, #5c6478 64%, #2b2f3c 100%)',
      borderRadius: 8,
    }}>{children}</div>
  );
}

function VariantCard({ variant, withPills }) {
  const st = useClockState();
  return (
    <Wallpaper>
      <WidgetCard withPills={withPills}>
        <div>
          <AnalogClock variant={variant} now={st.now} timer={st.timer} stopwatch={st.stopwatch} ending={st.ending} />
          {withPills && <ReadoutPills timer={st.timer} stopwatch={st.stopwatch} tColor={st.ending ? CW.danger : st.timer.color} ending={st.ending} />}
        </div>
      </WidgetCard>
    </Wallpaper>
  );
}

function App() {
  return (
    <DesignCanvas>
      <DCSection id="clock" title="위젯 시계 — 아날로그" subtitle="홈 화면 버블을 펼친 시계 카드 · 타이머(안쪽 링) + 스톱워치(바깥 링) + 실시간 시각 · 라이브">
        <DCArtboard id="a" label="A · 다이얼 + 하단 리드아웃" width={360} height={470}>
          <VariantCard variant="below" withPills />
        </DCArtboard>
        <DCArtboard id="b" label="B · 중앙 서브다이얼" width={360} height={400}>
          <VariantCard variant="subdial" />
        </DCArtboard>
        <DCArtboard id="c" label="C · 다크 미니멀" width={360} height={400}>
          <VariantCard variant="dark" />
        </DCArtboard>
      </DCSection>
    </DesignCanvas>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
