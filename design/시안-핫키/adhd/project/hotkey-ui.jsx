// Analog Timer — 전역 단축키 설정·녹화 UI 시안
const S = {
  bg: '#0E0E0F', surface: '#1A1A1C', surface2: '#161618', border: '#2E2E32',
  text: '#E8E6E0', muted: '#6B6968', faint: '#46443F',
  accent: '#F0C040', orange: '#E07A52', green: '#2EA84A', danger: '#E05252',
};
const F = "'Noto Sans KR',system-ui,sans-serif", FB = "'Bebas Neue',sans-serif";

function KeyCaps({ combo, dim, size = 11.5 }) {
  const keys = combo.split('+');
  return (
    <span style={{ display: 'inline-flex', gap: 4, opacity: dim ? 0.45 : 1, flexWrap: 'wrap', justifyContent: 'flex-end' }}>
      {keys.map((k, i) => (
        <span key={i} style={{ padding: '3px 7px 4px', borderRadius: 5, background: S.bg, border: `1px solid ${S.border}`, borderBottomWidth: 2, fontSize: size, fontWeight: 600, color: '#C9C6C0', lineHeight: 1.2, fontFamily: F }}>{k === '…' ? '\u2026' : k}</span>
      ))}
    </span>
  );
}

function TitleBar() {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 9, padding: '0 4px 0 10px', height: 34, background: '#111112', borderBottom: `1px solid ${S.border}`, flexShrink: 0 }}>
      <span style={{ width: 14, height: 14, borderRadius: 3, background: '#2A2A2E', display: 'block' }}></span>
      <span style={{ fontSize: 12, color: '#9C9A96', flex: 1 }}>Analog Timer</span>
      <div style={{ display: 'flex' }}>
        {['\u2013', '\u25a1', '\u2715'].map((g, i) => <span key={i} style={{ width: 36, height: 32, display: 'grid', placeItems: 'center', color: '#8C8A86', fontSize: 12 }}>{g}</span>)}
      </div>
    </div>
  );
}

function Toggle({ on }) {
  return (
    <span style={{ width: 34, height: 19, borderRadius: 10, background: on ? 'rgba(240,192,64,0.3)' : '#2A2A2E', position: 'relative', display: 'block', flexShrink: 0 }}>
      <span style={{ position: 'absolute', top: 3, left: on ? 18 : 3, width: 13, height: 13, borderRadius: '50%', background: on ? S.accent : S.muted }}></span>
    </span>
  );
}

function SettingRow({ glyph, title, hint, right, border = true }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '13px 16px', borderBottom: border ? `1px solid #202023` : 'none' }}>
      <span style={{ width: 30, height: 30, borderRadius: 8, background: S.surface2, border: `1px solid #232326`, display: 'grid', placeItems: 'center', fontSize: 14, color: S.muted, flexShrink: 0 }}>{glyph}</span>
      <span style={{ flex: 1, minWidth: 0 }}>
        <span style={{ display: 'block', fontSize: 13.5, color: S.text, fontWeight: 500 }}>{title}</span>
        {hint && <span style={{ display: 'block', fontSize: 11.5, color: S.muted, lineHeight: 1.5, marginTop: 2 }}>{hint}</span>}
      </span>
      {right}
    </div>
  );
}

function HotkeyRow({ label, combo, taken, hover }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '9px 12px', borderRadius: 9, background: hover ? 'rgba(255,255,255,0.045)' : 'transparent', cursor: 'pointer' }}>
      <span style={{ flex: 1, minWidth: 0 }}>
        <span style={{ display: 'block', fontSize: 13, color: S.text }}>{label}</span>
        {taken && (
          <span style={{ display: 'flex', alignItems: 'center', gap: 5, marginTop: 3 }}>
            <span style={{ fontSize: 10.5, color: S.danger, lineHeight: 1 }}>{'\u26a0'}</span>
            <span style={{ fontSize: 11, color: '#C98080', lineHeight: 1.4 }}>Taken by another app — tap to change</span>
          </span>
        )}
      </span>
      <KeyCaps combo={combo} dim={taken} />
    </div>
  );
}

function SettingsWindow({ dialog }) {
  return (
    <div style={{ width: 460, background: S.bg, border: `1px solid ${S.border}`, borderRadius: 10, overflow: 'hidden', display: 'flex', flexDirection: 'column', position: 'relative', color: S.text, fontFamily: F, boxShadow: '0 30px 70px rgba(0,0,0,0.5)' }}>
      <TitleBar />
      <div style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '16px 18px 10px' }}>
        <span style={{ fontSize: 16, color: S.muted }}>{'\u2039'}</span>
        <span style={{ fontSize: 16, fontWeight: 600, color: S.text }}>Settings</span>
      </div>
      <SettingRow glyph={'\u2637'} title="Language" right={<span style={{ fontSize: 12.5, color: S.muted }}>English</span>} />
      <SettingRow glyph={'\u2708'} title="Send feedback to the developer" hint="Report a bug or request a feature" />
      <div style={{ borderBottom: `1px solid #202023` }}>
        <SettingRow glyph={'\u2328'} title="Global shortcuts" hint={<span>Work from any app. Tap an item below to change its keys.<br />In-app: Space, N, S, L, W</span>} right={<Toggle on />} border={false} />
        <div style={{ padding: '0 16px 12px 59px', display: 'flex', flexDirection: 'column', gap: 1 }}>
          <HotkeyRow label="Start / Pause" combo="Ctrl+Shift+Alt+Space" />
          <HotkeyRow label="Next segment" combo="Ctrl+Shift+Alt+N" taken />
          <HotkeyRow label="Lap" combo="Ctrl+Shift+Alt+L" />
          <div style={{ display: 'flex', justifyContent: 'flex-end', paddingTop: 6 }}>
            <span style={{ fontSize: 11.5, color: S.faint, padding: '4px 8px', cursor: 'pointer' }}>Restore defaults</span>
          </div>
        </div>
      </div>
      <SettingRow glyph={'\u266a'} title="Voice announcements" right={<Toggle on={false} />} border={false} />
      <div style={{ height: 18 }}></div>
      {dialog && (
        <div style={{ position: 'absolute', inset: 0, background: 'rgba(8,8,9,0.62)', display: 'grid', placeItems: 'center', zIndex: 5 }}>
          <RecordDialog state="captured" />
        </div>
      )}
    </div>
  );
}

function RecordDialog({ state }) {
  // state: waiting | modifiers | captured | nomod | dup
  const preview = { waiting: null, modifiers: 'Ctrl+Shift+Alt+…', captured: 'Ctrl+Shift+Alt+L', nomod: 'L', dup: 'Ctrl+Shift+Alt+Space' }[state];
  const err = state === 'nomod' ? 'Add Ctrl, Alt or Win to the combo' : state === 'dup' ? 'Already used by “Start / Pause”' : null;
  const canSave = state === 'captured';
  return (
    <div style={{ width: 316, background: '#1E1E21', border: `1px solid ${S.border}`, borderRadius: 14, padding: '18px 20px 12px', fontFamily: F, boxShadow: '0 8px 18px rgba(0,0,0,0.4), 0 30px 60px rgba(0,0,0,0.55)' }}>
      <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
        <span style={{ fontSize: 15, fontWeight: 600, color: S.text, flex: 1 }}>Lap</span>
        <span style={{ fontSize: 11, color: S.faint }}>now: Ctrl+Shift+Alt+L</span>
      </div>
      <div style={{ fontSize: 12.5, color: S.muted, marginTop: 3 }}>Press the new key combination</div>
      <div style={{ minHeight: 54, margin: '14px 0 0', borderRadius: 10, background: S.bg, border: `1px ${preview ? 'solid' : 'dashed'} ${err ? 'rgba(224,82,82,0.55)' : S.border}`, display: 'grid', placeItems: 'center', padding: '10px 12px' }}>
        {preview
          ? <KeyCaps combo={preview} size={13} />
          : <span className="cw-blink" style={{ width: 2, height: 18, background: S.muted, display: 'block' }}></span>}
      </div>
      <div style={{ minHeight: 30, display: 'grid', placeItems: 'center', padding: '7px 4px 0' }}>
        {err
          ? <span style={{ fontSize: 11.5, color: S.danger, textAlign: 'center', lineHeight: 1.5 }}>{err}</span>
          : state === 'captured'
            ? <span style={{ fontSize: 11.5, color: S.faint, textAlign: 'center', lineHeight: 1.5 }}>Other apps lose this combo while shortcuts are on</span>
            : null}
      </div>
      <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 6, marginTop: 4 }}>
        <span style={{ fontSize: 13, color: S.muted, padding: '8px 14px', borderRadius: 8, cursor: 'pointer' }}>Cancel</span>
        <span style={{ fontSize: 13, fontWeight: 600, color: canSave ? S.accent : S.faint, padding: '8px 14px', borderRadius: 8, cursor: canSave ? 'pointer' : 'default' }}>Save</span>
      </div>
    </div>
  );
}

function Note({ title, children, w = 356 }) {
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

function BadgeCompare() {
  const Row = ({ label, children }) => (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '8px 0' }}>
      <span style={{ width: 92, fontSize: 12, color: S.muted, flexShrink: 0 }}>{label}</span>
      {children}
    </div>
  );
  return (
    <div style={{ width: 356, background: S.surface, border: `1px solid ${S.border}`, borderRadius: 12, padding: '14px 18px', fontFamily: F }}>
      <Row label="설정 (현재)"><span style={{ padding: '4px 10px', borderRadius: 6, background: S.bg, border: `1px solid ${S.border}`, fontSize: 12, color: '#C9C6C0' }}>Ctrl+Shift+Alt+L</span></Row>
      <Row label="치트시트 (현재)"><KeyCaps combo="Ctrl+Shift+Alt+L" /></Row>
      <div style={{ height: 1, background: '#232326', margin: '6px 0' }}></div>
      <Row label="제안: 통일"><KeyCaps combo="Ctrl+Shift+Alt+L" /><span style={{ fontSize: 11, color: S.green }}>{'\u2713'} 어디서나 키캡 분리형</span></Row>
    </div>
  );
}

function Page() {
  const dialogStates = [
    ['대기', 'waiting', '커서 깜빡임 — 빈 안내문 대신'],
    ['수식키 진행', 'modifiers', '"…" 키캡으로 진행형 표시'],
    ['유효하지 않음', 'nomod', 'Save 비활성 + 박스 테두리 danger'],
    ['중복', 'dup', '어느 액션과 겹치는지 명시'],
  ];
  return (
    <div style={{ display: 'flex', gap: 44, alignItems: 'flex-start', padding: 48, background: S.bg, minHeight: '100vh' }}>
      <div><Label n="01" title="설정 목록" sub="선점(⚠) 상태 = 왼쪽 힌트 줄" /><SettingsWindow /></div>
      <div><Label n="02" title="녹화 다이얼로그" sub="조합 확정 상태, 컨텍스트 포함" /><SettingsWindow dialog /></div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
        <Label n="03" title="다이얼로그 상태" sub="대기 → 진행 → 오류" />
        {dialogStates.map(([t, st, sub]) => (
          <div key={st}>
            <div style={{ fontSize: 11.5, color: S.muted, marginBottom: 6, fontFamily: F }}>{t} <span style={{ color: S.faint }}>— {sub}</span></div>
            <RecordDialog state={st} />
          </div>
        ))}
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 22 }}>
        <div><Label n="04" title="조합 뱃지 표기" sub="질문 1 답" /><BadgeCompare /></div>
        <Note title="질문별 답">
          <b style={{ color: S.text }}>1. 뱃지 표기 — 키캡 분리형으로 통일.</b><br />
          "키를 누른다"는 대상과 표기가 일치하고, 녹화 진행형 표시(Ctrl Shift Alt …)와도 자연스럽게 이어집니다. 단일 뱃지는 폐기.<br /><br />
          <b style={{ color: S.text }}>2. ⚠ 선점 상태 — 경고를 라벨 밑 힌트 줄로.</b><br />
          우측정렬 경고문 대신 액션명 아래 왼쪽 정렬 한 줄("Taken by another app — tap to change"). 뱃지는 45% 디밍만, 빨간 테두리·행 배경 없음 — 위험이 아니라 "미등록"이므로. 문구 길이 가변(15개 언어)에도 안전.<br /><br />
          <b style={{ color: S.text }}>3. faint 주의 한 줄 — 유지하되 조건부.</b><br />
          조합이 확정된 뒤에만 표시. 문구는 경고 대신 사실 서술로: "Other apps lose this combo while shortcuts are on". 오류 문구와 같은 슬롯을 공유해 다이얼로그 높이가 안 흔들립니다.<br /><br />
          <b style={{ color: S.text }}>4. 기본값 복원 — 위치 유지, 무게만 낮춤.</b><br />
          목록 우하단 faint 텍스트버튼. 기본값과 달라진 항목이 있을 때만 노출하면 평소엔 시각 소음 0.
        </Note>
        <Note title="추가 제안">
          다이얼로그 제목 옆에 <b style={{ color: S.text }}>현재 조합("now: …")</b>을 faint로 표기 — 무엇에서 무엇으로 바꾸는지 컨텍스트 제공. 대기 상태는 안내문 반복 대신 <b style={{ color: S.text }}>깜빡이는 커서</b>로 "입력을 듣고 있음"을 표현.
        </Note>
      </div>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<Page />);
