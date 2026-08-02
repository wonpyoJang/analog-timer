// Analog Timer — 단순화 메인 화면 목업 (데스크톱 460×860)

const S = {
  bg: '#0E0E0F', surface: '#1A1A1C', surface2: '#161618', border: '#2E2E32',
  text: '#E8E6E0', muted: '#6B6968', faint: '#46443F',
  accent: '#F0C040', orange: '#E07A52', orangeDk: '#C05A28', green: '#2EA84A', danger: '#E05252', blue: '#52B0E0',
};
const F = "'Noto Sans KR',system-ui,sans-serif", FB = "'Bebas Neue',sans-serif";

const SEGMENTS = [
  { name: '휴식', color: S.blue, mins: 20 },
  { name: '집중', color: S.orange, mins: 25 },
  { name: '휴식', color: S.blue, mins: 5 },
  { name: '집중', color: S.orange, mins: 90 },
  { name: '휴식', color: S.blue, mins: 20 },
];

function TitleBar() {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 9, padding: '0 4px 0 10px', height: 34, background: '#111112', borderBottom: `1px solid ${S.border}`, flexShrink: 0 }}>
      <span style={{ width: 14, height: 14, borderRadius: 3, background: '#2A2A2E', display: 'block' }}></span>
      <span style={{ fontSize: 12, color: '#9C9A96', flex: 1 }}>Analog Timer</span>
      <div style={{ display: 'flex' }}>
        {['\u2013', '\u25a1', '\u2715'].map((g, i) => (
          <span key={i} style={{ width: 36, height: 32, display: 'grid', placeItems: 'center', color: '#8C8A86', fontSize: 12 }}>{g}</span>
        ))}
      </div>
    </div>
  );
}

function IconBtn({ glyph, tone, onClick, active, size = 34 }) {
  const fg = tone === 'accent' ? S.accent : tone === 'orange' ? S.orange : tone === 'green' ? S.green : S.muted;
  return (
    <button onClick={onClick} style={{
      width: size, height: size, borderRadius: 8, display: 'grid', placeItems: 'center', cursor: 'pointer',
      background: active ? 'rgba(255,255,255,0.06)' : 'transparent', border: `1px solid ${active ? S.border : 'transparent'}`,
      color: fg, fontSize: 15, fontFamily: F, padding: 0,
    }}>{glyph}</button>
  );
}

function Header({ widgetOn, setWidgetOn, menuOpen, setMenuOpen }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '14px 14px 6px' }}>
      <span style={{ width: 9, height: 9, borderRadius: '50%', background: S.accent, flexShrink: 0 }}></span>
      <span style={{ fontFamily: FB, fontSize: 21, letterSpacing: '2.2px', color: S.accent, flex: 1, lineHeight: 1 }}>ANALOG TIMER</span>
      <button onClick={() => setWidgetOn(!widgetOn)} style={{
        display: 'flex', alignItems: 'center', gap: 7, padding: '6px 11px 6px 9px', borderRadius: 20, cursor: 'pointer', fontFamily: F,
        border: `1px solid ${widgetOn ? 'rgba(240,192,64,0.5)' : S.border}`, background: widgetOn ? 'rgba(240,192,64,0.1)' : 'transparent',
        color: widgetOn ? S.accent : S.muted, fontSize: 12.5, fontWeight: 500,
      }}>
        <span style={{ width: 22, height: 13, borderRadius: 7, background: widgetOn ? 'rgba(240,192,64,0.35)' : '#2A2A2E', position: 'relative', display: 'block' }}>
          <span style={{ position: 'absolute', top: 2, left: widgetOn ? 11 : 2, width: 9, height: 9, borderRadius: '50%', background: widgetOn ? S.accent : '#6B6968' }}></span>
        </span>
        위젯
      </button>
      <IconBtn glyph={"\u22ef"} onClick={() => setMenuOpen(!menuOpen)} active={menuOpen} />
    </div>
  );
}

function OverflowMenu() {
  const [hover, setHover] = React.useState(1);
  const Item = ({ glyph, label, hint, tone, chevron, k }) => (
    <div onMouseEnter={() => setHover(k)} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '10px 12px', borderRadius: 8, background: hover === k ? 'rgba(255,255,255,0.055)' : 'transparent', cursor: 'pointer' }}>
      <span style={{ width: 18, textAlign: 'center', fontSize: 14, color: tone === 'accent' ? S.accent : S.muted }}>{glyph}</span>
      <span style={{ flex: 1, fontSize: 13.5, color: tone === 'accent' ? S.accent : S.text }}>{label}</span>
      {hint && <span style={{ fontSize: 11.5, color: S.faint }}>{hint}</span>}
      {chevron && <span style={{ fontSize: 13, color: S.faint, lineHeight: 1 }}>{'\u203a'}</span>}
    </div>
  );
  const Head = ({ children }) => <div style={{ padding: '8px 12px 3px', fontSize: 10.5, letterSpacing: '1.6px', color: S.faint, fontFamily: FB }}>{children}</div>;
  return (
    <div style={{ position: 'absolute', top: 82, right: 14, width: 252, background: '#141416', border: `1px solid ${S.border}`, borderRadius: 12, padding: '4px 6px 6px', boxShadow: '0 4px 10px rgba(0,0,0,0.4), 0 22px 48px rgba(0,0,0,0.6)', zIndex: 5 }}>
      <div style={{ position: 'absolute', top: -5.5, right: 22, width: 10, height: 10, background: '#141416', borderLeft: `1px solid ${S.border}`, borderTop: `1px solid ${S.border}`, transform: 'rotate(45deg)' }}></div>
      <Item k={1} glyph={"\u2699"} label="설정" hint="언어 · 알림 · 배터리" chevron />
      <Item k={2} glyph={"\u25a3"} label="기기 동기화" chevron />
      <div style={{ height: 1, background: S.border, margin: '5px 8px' }}></div>
      <Head>문제 해결</Head>
      <Item k={3} glyph={"\u21bb"} label="위젯 새로고침" />
      <Item k={4} glyph={"\u27f3"} label="앱 재시작" tone="accent" />
      <Item k={5} glyph={"\u2691"} label="오류 리포트" chevron />
      <div style={{ display: 'flex', alignItems: 'center', gap: 7, margin: '5px 6px 4px', padding: '7px 10px', borderRadius: 8, background: 'rgba(46,168,74,0.07)', border: '1px solid rgba(46,168,74,0.18)' }}>
        <span style={{ width: 6, height: 6, borderRadius: '50%', background: S.green, flexShrink: 0 }}></span>
        <span style={{ fontSize: 11, color: '#8FBF9C', lineHeight: 1.5 }}>멈춤 자동 감지·복구 켜짐 — 보통 직접 누를 일이 없습니다.</span>
      </div>
    </div>
  );
}

function ChipRow({ items, activeIndex }) {
  return (
    <div style={{ display: 'flex', gap: 7, flexWrap: 'wrap' }}>
      {items.map((c, i) => (
        <span key={i} style={{
          display: 'flex', alignItems: 'center', gap: 6, padding: '6px 12px', borderRadius: 20, fontSize: 12.5, fontFamily: F,
          border: `1px solid ${i === activeIndex ? 'rgba(224,122,82,0.55)' : S.border}`, background: i === activeIndex ? 'rgba(224,122,82,0.1)' : 'transparent',
          color: i === activeIndex ? S.orange : S.muted,
        }}>{c}</span>
      ))}
    </div>
  );
}

function SegmentRow({ s, current }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '9px 11px', borderRadius: 10, background: S.surface2, border: `1px solid ${current ? 'rgba(224,122,82,0.55)' : S.border}` }}>
      <span style={{ color: S.faint, fontSize: 12, letterSpacing: '-1px' }}>{current ? '\u25b8' : '\u2237'}</span>
      <span style={{ width: 9, height: 9, borderRadius: '50%', background: s.color, flexShrink: 0 }}></span>
      <span style={{ flex: 1, fontSize: 13.5, color: current ? S.text : '#C9C6C0' }}>{s.name}</span>
      <span style={{ width: 46, textAlign: 'center', padding: '4px 0', borderRadius: 7, background: S.bg, border: `1px solid ${S.border}`, fontFamily: FB, fontSize: 13.5, color: S.text }}>{s.mins}</span>
      <span style={{ fontSize: 11.5, color: S.muted }}>분</span>
      <span style={{ color: S.faint, fontSize: 13 }}>{'\u2715'}</span>
    </div>
  );
}

function MainWindow({ now, state }) {
  const [widgetOn, setWidgetOn] = React.useState(true);
  const [menuOpen, setMenuOpen] = React.useState(state === 'menu');
  const [editOpen, setEditOpen] = React.useState(state === 'edit');
  const seg = SEGMENTS[3];
  const remaining = 31 * 60000 + 20000;
  const timer = { label: seg.name, remaining, total: seg.mins * 60000, color: seg.color };

  return (
    <div style={{ width: 460, height: 860, background: S.bg, border: `1px solid ${S.border}`, borderRadius: 10, overflow: 'hidden', display: 'flex', flexDirection: 'column', position: 'relative', color: S.text, fontFamily: F, boxShadow: '0 30px 70px rgba(0,0,0,0.5)' }}>
      <TitleBar />
      <div style={{ flex: 1, overflow: 'hidden', position: 'relative' }}>
        <div style={{ marginTop: state === 'edit' ? -252 : 0 }}>
          <Header widgetOn={widgetOn} setWidgetOn={setWidgetOn} menuOpen={menuOpen} setMenuOpen={setMenuOpen} />

          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 12, padding: '2px 0 6px', color: S.muted, fontSize: 12.5 }}>
            <span style={{ color: S.faint }}>{'\u2039'}</span>
            <span>8/2 (일) · 오늘</span>
            <span style={{ color: S.faint }}>{'\u203a'}</span>
          </div>

          <div style={{ display: 'flex', justifyContent: 'center', padding: '4px 0 0' }}>
            <AppClock size={302} faceTheme="light" timerStyle="spiral" centerLayout="plate" now={now} timer={timer} stopwatch={{ elapsed: 663 * 3600000 + 49 * 60000 + 36000 }} ending={false} />
          </div>

          <div style={{ padding: '16px 20px 0' }}>
            <div style={{ height: 4, borderRadius: 2, background: '#232326', overflow: 'hidden' }}>
              <div style={{ width: '65%', height: '100%', background: S.orange, borderRadius: 2 }}></div>
            </div>
          </div>

          {/* primary controls */}
          <div style={{ display: 'flex', gap: 8, padding: '16px 18px 0' }}>
            <button style={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, padding: '14px 0', borderRadius: 10, cursor: 'pointer', background: 'rgba(224,122,82,0.14)', border: `1.5px solid ${S.orange}`, color: S.orange, fontFamily: F, fontSize: 15, fontWeight: 600 }}>
              <span style={{ fontSize: 13 }}>{'\u2016'}</span> 일시정지
            </button>
            <button style={{ width: 52, borderRadius: 10, cursor: 'pointer', background: 'transparent', border: `1px solid ${S.border}`, color: S.text, fontSize: 15 }}>{'\u25b8\u25b8'}</button>
            <button style={{ width: 52, borderRadius: 10, cursor: 'pointer', background: 'transparent', border: `1px solid ${S.border}`, color: S.muted, fontSize: 15 }}>{'\u21ba'}</button>
          </div>

          {/* stopwatch — secondary */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, margin: '10px 18px 0', padding: '9px 10px 9px 13px', borderRadius: 10, background: S.surface2, border: `1px solid ${S.border}` }}>
            <span style={{ width: 8, height: 8, borderRadius: '50%', background: S.green }}></span>
            <span style={{ fontSize: 12.5, color: S.muted, flex: 1 }}>스톱워치 <span style={{ fontFamily: FB, fontSize: 15, color: S.green, letterSpacing: '0.8px', marginLeft: 4 }}>663:49:36</span></span>
            <IconBtn glyph={"\u2016"} tone="green" size={30} />
            <span style={{ fontFamily: FB, fontSize: 13, color: S.muted, letterSpacing: '1px', padding: '0 6px' }}>LAP</span>
            <IconBtn glyph={"\u21ba"} size={30} />
          </div>

          {/* routine */}
          <div style={{ margin: '14px 14px 0', background: S.surface, border: `1px solid ${S.border}`, borderRadius: 12, padding: '13px 13px 14px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 11 }}>
              <span style={{ fontFamily: FB, fontSize: 12, letterSpacing: '1.8px', color: S.faint }}>루틴</span>
              <span style={{ fontSize: 13.5, color: S.text, flex: 1 }}>Deep work 90/20</span>
              <button onClick={() => setEditOpen(!editOpen)} style={{ background: 'transparent', border: `1px solid ${S.border}`, color: S.muted, borderRadius: 8, padding: '5px 11px', cursor: 'pointer', fontSize: 12.5, fontFamily: F }}>
                편집 <span style={{ fontSize: 10 }}>{editOpen ? '\u2303' : '\u2304'}</span>
              </button>
            </div>
            <ChipRow items={['Pomodoro 25/5', '52/17', 'Deep work 90/20']} activeIndex={2} />
            {editOpen && (
              <div style={{ marginTop: 13, paddingTop: 13, borderTop: `1px solid ${S.border}`, display: 'flex', flexDirection: 'column', gap: 7 }}>
                {SEGMENTS.map((s, i) => <SegmentRow key={i} s={s} current={i === 3} />)}
                <div style={{ padding: '9px 0', textAlign: 'center', borderRadius: 9, border: `1px dashed ${S.border}`, color: S.muted, fontSize: 12.5 }}>+ 세그먼트 추가</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginTop: 4 }}>
                  <span style={{ width: 34, height: 19, borderRadius: 10, background: 'rgba(224,122,82,0.3)', position: 'relative', display: 'block' }}>
                    <span style={{ position: 'absolute', top: 3, left: 18, width: 13, height: 13, borderRadius: '50%', background: S.orange }}></span>
                  </span>
                  <span style={{ fontSize: 12.5, color: S.muted, flex: 1 }}>반복</span>
                  <span style={{ fontSize: 12.5, color: S.muted, border: `1px solid ${S.border}`, borderRadius: 8, padding: '5px 11px' }}>현재 루틴 저장</span>
                </div>
              </div>
            )}
          </div>

          {/* records */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, margin: '10px 14px 24px', padding: '12px 14px', borderRadius: 12, background: S.surface, border: `1px solid ${S.border}` }}>
            <span style={{ fontSize: 13, color: S.text, flex: 1 }}>기록</span>
            <span style={{ fontSize: 12, color: S.faint }}>랩 0 · 이벤트 0</span>
            <span style={{ fontSize: 11, color: S.muted }}>{'\u2304'}</span>
          </div>
        </div>
        {menuOpen && <OverflowMenu />}
      </div>
    </div>
  );
}

function Widget({ now }) {
  const seg = SEGMENTS[3];
  return (
    <div style={{ width: 206, background: 'rgba(14,14,15,0.96)', border: `1px solid ${S.border}`, borderRadius: 14, padding: 8, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6, boxShadow: '0 20px 44px rgba(0,0,0,0.55)' }}>
      <AppClock size={172} faceTheme="light" timerStyle="spiral" centerLayout="plate" now={now} timer={{ label: seg.name, remaining: 31 * 60000 + 20000, total: seg.mins * 60000, color: seg.color }} stopwatch={{ elapsed: 663 * 3600000 + 49 * 60000 + 36000 }} ending={false} />
      <div style={{ display: 'flex', alignItems: 'center', gap: 6, width: '100%', padding: '0 2px 2px' }}>
        <button style={{ flex: 1, padding: '8px 0', borderRadius: 9, background: 'rgba(224,122,82,0.14)', border: `1px solid ${S.orange}`, color: S.orange, fontSize: 13, fontFamily: F, cursor: 'pointer' }}>{'\u2016'} 일시정지</button>
        <IconBtn glyph={"\u25b8\u25b8"} size={32} />
        <IconBtn glyph={"\u22ef"} size={32} />
      </div>
    </div>
  );
}

function Note({ title, children, w = 340 }) {
  return (
    <div style={{ width: w, background: S.surface, border: `1px solid ${S.border}`, borderRadius: 12, padding: '16px 18px', color: S.text, fontFamily: F }}>
      <div style={{ fontFamily: FB, fontSize: 15, letterSpacing: '1.6px', color: S.accent, marginBottom: 10 }}>{title}</div>
      <div style={{ fontSize: 13, lineHeight: 1.72, color: '#B8B5AF' }}>{children}</div>
    </div>
  );
}

function Label({ n, title, sub }) {
  return (
    <div style={{ display: 'flex', alignItems: 'baseline', gap: 9, marginBottom: 12, fontFamily: F }}>
      <span style={{ fontFamily: FB, fontSize: 15, color: S.faint, letterSpacing: '1px' }}>{n}</span>
      <span style={{ fontSize: 14, color: S.text, fontWeight: 600 }}>{title}</span>
      <span style={{ fontSize: 12.5, color: S.muted }}>{sub}</span>
    </div>
  );
}

function Page() {
  const [now, setNow] = React.useState(new Date());
  React.useEffect(() => { const id = setInterval(() => setNow(new Date()), 1000); return () => clearInterval(id); }, []);
  return (
    <div style={{ display: 'flex', gap: 40, alignItems: 'flex-start', padding: 48, background: S.bg }}>
      <div><Label n="01" title="기본 상태" sub="헤더 버튼 7 → 2" /><MainWindow now={now} state="default" /></div>
      <div><Label n="02" title="⋯ 오버플로" sub="복구·관리 기능은 여기로" /><MainWindow now={now} state="menu" /></div>
      <div><Label n="03" title="편집 펼침" sub="루틴 카드 내부에서만" /><MainWindow now={now} state="edit" /></div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>
        <div><Label n="04" title="위젯" sub="4버튼 → 1+2" /><Widget now={now} /></div>
        <Note title="원칙">
          <b style={{ color: S.text }}>1. 첫 화면 = 시계 + 시작/정지 + 위젯.</b><br />
          나머지는 전부 한 뎁스 아래로. 기능은 하나도 삭제하지 않았습니다.<br /><br />
          <b style={{ color: S.text }}>2. 시각적 무게로 우선순위를 표현.</b><br />
          타이머 = 채워진 주황 버튼, 스톱워치 = 조용한 한 줄, 관리 기능 = 아이콘 없는 메뉴 항목.<br /><br />
          <b style={{ color: S.text }}>3. 복구 기능은 숨기되 사라지지 않게.</b><br />
          ⋯ → “문제 해결” 그룹 + 트레이 메뉴. 자동 감지·복구가 이미 동작한다는 안내 문구를 함께.
        </Note>
        <Note title="무엇을 어디로">
          <div style={{ display: 'flex', flexDirection: 'column', gap: 7 }}>
            {[['위젯 새로고침 · 기기 동기화 · 설정', '⋯ 메뉴'], ['앱 재시작 · 오류 리포트', '⋯ › 문제 해결'], ['DateNav', '헤더 아래 한 줄 (무채색)'], ['범례', '삭제 — 시계 색이 곧 범례'], ['스톱워치 3버튼', '한 줄 보조 바'], ['세그먼트 편집기', '루틴 카드 안 “편집”'], ['랩 · 로그 2패널', '“기록” 한 줄 아코디언']].map(([a, b], i) => (
              <div key={i} style={{ display: 'flex', gap: 10, fontSize: 12.5 }}>
                <span style={{ flex: 1, color: '#B8B5AF' }}>{a}</span>
                <span style={{ width: 132, color: S.muted, textAlign: 'right' }}>{b}</span>
              </div>
            ))}
          </div>
        </Note>
      </div>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<Page />);
