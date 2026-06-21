# Analog Timer 진단 도구 — 위젯이 사라지는 원인을 수집합니다.
$ErrorActionPreference = 'SilentlyContinue'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public class D {
  [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc cb, IntPtr p);
  public delegate bool EnumWindowsProc(IntPtr h, IntPtr p);
  [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
  [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] public static extern int GetWindowTextLength(IntPtr h);
  [DllImport("user32.dll")] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
  [DllImport("user32.dll")] public static extern uint GetGuiResources(IntPtr p, uint f);
  public static int Wins(uint t, out bool widget, out bool main){
    int c=0; bool w=false,m=false;
    EnumWindows((h,p)=>{ uint pid; GetWindowThreadProcessId(h,out pid);
      if(pid==t && IsWindowVisible(h)){ c++; int len=GetWindowTextLength(h); var sb=new StringBuilder(len+2);
        GetWindowText(h,sb,sb.Capacity); if(sb.ToString()=="") w=true; if(sb.ToString()=="Analog Timer") m=true; }
      return true; }, IntPtr.Zero);
    widget=w; main=m; return c; }
}
"@

$out = "$env:USERPROFILE\Desktop\analog-timer-진단결과.txt"
function Log($s){ Write-Host $s; Add-Content -Path $out -Value $s -Encoding UTF8 }

Set-Content $out -Value "" -Encoding UTF8
Log "===== Analog Timer 진단 ====="
Log "수집 시작: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Log ""
Log "--- 시스템 정보 ---"
$os=Get-CimInstance Win32_OperatingSystem
Log "Windows : $($os.Caption) (build $($os.BuildNumber), ver $($os.Version))"
$cpu=Get-CimInstance Win32_Processor | Select-Object -First 1
Log "CPU     : $($cpu.Name)"
$cs=Get-CimInstance Win32_ComputerSystem
Log "RAM     : $([math]::Round($cs.TotalPhysicalMemory/1GB,1)) GB"
Log "GPU     :"
Get-CimInstance Win32_VideoController | ForEach-Object { Log "  - $($_.Name) | 드라이버 $($_.DriverVersion) ($($_.DriverDate))" }
Log ""
Log "--- 사용 방법 ---"
Log "1) Analog Timer 를 실행하세요."
Log "2) 우측 상단 [위젯] 버튼을 눌러 위젯을 켜세요."
Log "3) 타이머를 [START] 로 시작하세요."
Log "4) 그대로 두고 기다리면 이 창이 자동으로 관찰합니다 (최대 40분)."
Log "   위젯이나 앱이 사라지면 그 순간이 기록됩니다."
Log ""

Write-Host ""
Write-Host ">>> 지금 Analog Timer 를 실행하고, 위젯을 켜고, 타이머를 시작하세요. <<<"
Write-Host "    (이 창은 닫지 마세요)"
Write-Host ""
Write-Host "Analog Timer 실행을 기다리는 중..."
$p=$null
for($w=0; $w -lt 120; $w++){ $p=Get-Process analog_timer -ErrorAction SilentlyContinue | Select-Object -First 1; if($p){break}; Start-Sleep -Seconds 5 }
if(-not $p){ Log "[중단] 10분 동안 Analog Timer 가 실행되지 않았습니다."; Read-Host "엔터를 누르면 종료"; exit }

Log "--- 모니터링 시작 (pid=$($p.Id)) ---"
$widgetSeen=$false; $widgetGone=$false; $h0=0; $w0=0
for($i=0; $i -le 240; $i++){     # 10초 * 240 = 40분
  $pa=Get-Process analog_timer -ErrorAction SilentlyContinue | Select-Object -First 1
  $cr=(Get-Process WerFault -ErrorAction SilentlyContinue|Measure-Object).Count
  $t=[math]::Round($i/6,1)
  if($pa){
    $pa.Refresh(); $wd=$false; $mn=$false
    $c=[D]::Wins([uint32]$pa.Id,[ref]$wd,[ref]$mn)
    $hc=$pa.HandleCount; $ws=[math]::Round($pa.WorkingSet64/1MB)
    if($h0 -eq 0){ $h0=$hc; $w0=$ws }
    if($wd){$widgetSeen=$true}
    if($widgetSeen -and (-not $wd) -and (-not $widgetGone)){ $widgetGone=$true; Log "" ; Log "*** t=${t}분: 위젯이 사라짐!  (메인앱 생존=$mn, 핸들=$hc, 메모리=${ws}MB) ***"; Log "" }
    Log ("t={0,5}분  앱=ALIVE 창={1} 위젯={2} 메인={3} 메모리={4}MB(+{5}) 핸들={6}(+{7}) GDI={8} USER={9}" -f $t,$c,$wd,$mn,$ws,($ws-$w0),$hc,($hc-$h0),[D]::GetGuiResources($pa.Handle,0),[D]::GetGuiResources($pa.Handle,1))
  } else {
    Log ""
    Log "*** t=${t}분: 앱(analog_timer)이 완전히 종료/크래시됨! (WerFault=$cr) ***"
    Log ""
    Log "--- 최근 오류 이벤트 로그 (analog_timer/flutter 관련) ---"
    Get-WinEvent -FilterHashtable @{LogName='Application'; Level=2; StartTime=(Get-Date).AddMinutes(-50)} -MaxEvents 40 -ErrorAction SilentlyContinue |
      Where-Object { $_.Message -match 'analog_timer|flutter|0xc0000005|MagicLine' } | Select-Object -First 6 |
      ForEach-Object { Log "  [$($_.TimeCreated.ToString('HH:mm:ss'))] $($_.ProviderName): $($_.Message.Split([char]10)[0])" }
    break
  }
  Start-Sleep -Seconds 10
}
Log ""
Log "===== 진단 종료 ($(Get-Date -Format 'HH:mm:ss')) ====="
Log ""
Log ">>> 이 파일을 그대로 보내주세요: $out"
Write-Host ""
Write-Host "완료! 바탕화면의 'analog-timer-진단결과.txt' 를 보내주세요."
Read-Host "엔터를 누르면 종료"
