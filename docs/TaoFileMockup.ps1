# =====================================================================
#  TaoFileMockup.ps1
#  Gói toàn bộ ảnh PNG xuất từ Figma thành MỘT file HTML tự chứa.
#  Không cần cài gì thêm — Windows PowerShell chạy sẵn.
#
#  CÁCH DÙNG
#  ---------
#  Bước 1. Xuất ảnh từ Figma
#     - Mở page (ví dụ "A — Hộ dân")
#     - Ctrl+A chọn hết frame
#     - Panel Export bên phải -> dấu + -> chọn 2x và PNG
#     - Bấm "Export ... layers", lưu vào một thư mục, ví dụ F:\mockup-png
#     - Làm tương tự cho 3 page, đổ chung vào MỘT thư mục
#
#  Bước 2. Chạy script
#     - Chuột phải file này -> Run with PowerShell
#     - Hoặc mở PowerShell rồi gõ:
#         cd "F:\DisasterRescue\docs"
#         .\TaoFileMockup.ps1 -PngFolder "F:\mockup-png"
#
#  Kết quả: DisasterRescue_Mockup.html nằm cùng thư mục với script.
#
#  Nếu PowerShell chặn không cho chạy, gõ lệnh này trước:
#     Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# =====================================================================

param(
    [string]$PngFolder = "",
    [string]$OutFile   = "DisasterRescue_Mockup.html"
)

$ErrorActionPreference = "Stop"

# --- Hỏi đường dẫn nếu chưa truyền vào ---
if ([string]::IsNullOrWhiteSpace($PngFolder)) {
    Write-Host ""
    Write-Host "  TAO FILE MOCKUP HTML — DisasterRescue" -ForegroundColor Cyan
    Write-Host "  ------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    $PngFolder = Read-Host "  Dan duong dan thu muc chua anh PNG xuat tu Figma"
    $PngFolder = $PngFolder.Trim('"').Trim()
}

if (-not (Test-Path $PngFolder)) {
    Write-Host "  [LOI] Khong tim thay thu muc: $PngFolder" -ForegroundColor Red
    Read-Host "  Nhan Enter de thoat"
    exit 1
}

$files = Get-ChildItem -Path $PngFolder -Filter *.png -File
if ($files.Count -eq 0) {
    Write-Host "  [LOI] Thu muc khong co file PNG nao." -ForegroundColor Red
    Read-Host "  Nhan Enter de thoat"
    exit 1
}

Write-Host ""
Write-Host "  Tim thay $($files.Count) anh. Dang xu ly..." -ForegroundColor Green

# --- Sắp xếp tự nhiên theo số đầu tên file: 01, 02, ... 06, 06b, 07 ... ---
function Get-SortKey([string]$name) {
    if ($name -match '^\s*(\d+)\s*([a-zA-Z]?)') {
        $num = [int]$Matches[1]
        $suf = $Matches[2]
        return "{0:D4}{1}" -f $num, $suf
    }
    return "9999$name"
}

$items = $files | ForEach-Object {
    [PSCustomObject]@{
        File = $_
        Key  = Get-SortKey $_.BaseName
    }
} | Sort-Object Key

# --- Phân nhóm theo số màn ---
function Get-Group([string]$name) {
    if ($name -match '^\s*(\d+)') {
        $n = [int]$Matches[1]
        if ($n -le 9  -or $n -eq 24) { return 'a' }
        if (($n -ge 10 -and $n -le 18) -or ($n -ge 25 -and $n -le 33) -or $n -eq 37 -or $n -eq 38 -or $n -eq 41) { return 'b' }
        return 'c'
    }
    return 'c'
}

# --- Sinh thẻ ảnh, nhúng base64 ---
$cards = New-Object System.Text.StringBuilder
$count = 0
foreach ($it in $items) {
    $count++
    $f = $it.File
    Write-Progress -Activity "Dang nhung anh" -Status $f.Name -PercentComplete (($count / $items.Count) * 100)

    $bytes  = [System.IO.File]::ReadAllBytes($f.FullName)
    $b64    = [System.Convert]::ToBase64String($bytes)
    $title  = $f.BaseName -replace '"', "'"
    $group  = Get-Group $f.BaseName

    [void]$cards.AppendLine("<figure class=`"s g-$group`" data-g=`"$group`">")
    [void]$cards.AppendLine("<img loading=`"lazy`" src=`"data:image/png;base64,$b64`" alt=`"$title`">")
    [void]$cards.AppendLine("<figcaption>$title</figcaption>")
    [void]$cards.AppendLine("</figure>")
}
Write-Progress -Activity "Dang nhung anh" -Completed

$today = Get-Date -Format "dd/MM/yyyy"

# --- Khung HTML ---
$html = @"
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>DisasterRescue — Mockup giao dien</title>
<style>
:root{--red:#D32F2F;--blue:#1976D2;--green:#388E3C;--bg:#F5F5F5;--card:#fff;--tx:#212121;--tx2:#757575;--bd:#E0E0E0}
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:Inter,'Segoe UI',Roboto,sans-serif;background:var(--bg);color:var(--tx)}
header{background:var(--red);color:#fff;padding:26px 24px;text-align:center}
header h1{font-size:24px;font-weight:800}
header p{opacity:.9;font-size:14px;margin-top:5px}
header .m{margin-top:14px;display:flex;gap:8px;justify-content:center;flex-wrap:wrap}
header .m span{background:rgba(255,255,255,.18);padding:4px 11px;border-radius:50px;font-size:12px;font-weight:600}
nav{background:#fff;border-bottom:1px solid var(--bd);position:sticky;top:0;z-index:9;text-align:center;padding:0 12px}
nav button{padding:13px 16px;border:none;background:none;font:inherit;font-size:14px;font-weight:600;color:var(--tx2);cursor:pointer;border-bottom:3px solid transparent}
nav button.on{color:var(--red);border-bottom-color:var(--red)}
main{max-width:1400px;margin:0 auto;padding:22px}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:20px}
.s{background:var(--card);border:1px solid var(--bd);border-radius:12px;overflow:hidden;cursor:zoom-in;transition:.15s}
.s:hover{transform:translateY(-3px);box-shadow:0 6px 18px rgba(0,0,0,.12)}
.s img{width:100%;display:block;background:#fafafa}
.s figcaption{padding:10px 12px;font-size:12.5px;font-weight:600;border-top:1px solid #f0f0f0}
.hide{display:none}
#lb{position:fixed;inset:0;background:rgba(0,0,0,.92);display:none;align-items:center;justify-content:center;z-index:99;flex-direction:column;gap:14px;padding:20px}
#lb.on{display:flex}
#lb img{max-width:96vw;max-height:82vh;object-fit:contain;border-radius:6px}
#lb .cap{color:#fff;font-size:14px;font-weight:600}
#lb .x{position:absolute;top:16px;right:22px;color:#fff;font-size:30px;cursor:pointer;line-height:1}
#lb .nav{position:absolute;top:50%;transform:translateY(-50%);color:#fff;font-size:44px;cursor:pointer;padding:14px;user-select:none;opacity:.65}
#lb .nav:hover{opacity:1}
#lb .prev{left:8px}#lb .next{right:8px}
footer{text-align:center;padding:22px;color:var(--tx2);font-size:12px;border-top:1px solid var(--bd);margin-top:24px}
@media print{nav,#lb{display:none}.grid{grid-template-columns:repeat(2,1fr)}.s{break-inside:avoid}}
</style>
</head>
<body>

<header>
  <h1>DisasterRescue</h1>
  <p>He thong Dieu phoi Cuu ho Khan cap Thien tai cap xa — xa Binh Lieu, Quang Ninh</p>
  <div class="m">
    <span>$($items.Count) man hinh</span>
    <span>SRS v1.1</span>
    <span>Flutter · Riverpod · Hive · Firebase</span>
    <span>CSE441 — TLU</span>
  </div>
</header>

<nav>
  <button class="on" data-f="all">Tat ca</button>
  <button data-f="a">A · Ho dan</button>
  <button data-f="b">B · Admin xa</button>
  <button data-f="c">C · Doi cuu ho</button>
</nav>

<main><div class="grid" id="grid">
$($cards.ToString())
</div></main>

<div id="lb">
  <span class="x">&times;</span>
  <span class="nav prev">&#8249;</span>
  <span class="nav next">&#8250;</span>
  <img id="lbimg" src="" alt="" />
  <div class="cap" id="lbcap"></div>
</div>

<footer>
  DisasterRescue — Bai tap lon CSE441, Truong Dai hoc Thuy Loi · Xuat ngay $today
</footer>

<script>
var figs = Array.prototype.slice.call(document.querySelectorAll('.s'));
var lb = document.getElementById('lb'), lbimg = document.getElementById('lbimg'), lbcap = document.getElementById('lbcap');
var cur = 0, shown = figs;

document.querySelectorAll('nav button').forEach(function(b){
  b.onclick = function(){
    document.querySelectorAll('nav button').forEach(function(x){x.classList.remove('on')});
    b.classList.add('on');
    var f = b.dataset.f;
    figs.forEach(function(fg){
      fg.classList.toggle('hide', f !== 'all' && fg.dataset.g !== f);
    });
    shown = figs.filter(function(fg){return !fg.classList.contains('hide')});
  };
});

function open(i){
  cur = (i + shown.length) % shown.length;
  var fg = shown[cur];
  lbimg.src = fg.querySelector('img').src;
  lbcap.textContent = fg.querySelector('figcaption').textContent;
  lb.classList.add('on');
}
figs.forEach(function(fg){
  fg.onclick = function(){ open(shown.indexOf(fg)); };
});
document.querySelector('#lb .x').onclick = function(){ lb.classList.remove('on'); };
document.querySelector('#lb .prev').onclick = function(e){ e.stopPropagation(); open(cur-1); };
document.querySelector('#lb .next').onclick = function(e){ e.stopPropagation(); open(cur+1); };
lb.onclick = function(e){ if(e.target === lb) lb.classList.remove('on'); };
document.onkeydown = function(e){
  if(!lb.classList.contains('on')) return;
  if(e.key === 'Escape') lb.classList.remove('on');
  if(e.key === 'ArrowLeft') open(cur-1);
  if(e.key === 'ArrowRight') open(cur+1);
};
</script>
</body>
</html>
"@

$outPath = Join-Path (Get-Location) $OutFile
[System.IO.File]::WriteAllText($outPath, $html, [System.Text.Encoding]::UTF8)

$sizeMB = [math]::Round((Get-Item $outPath).Length / 1MB, 1)

Write-Host ""
Write-Host "  XONG." -ForegroundColor Green
Write-Host "  File: $outPath"
Write-Host "  Kich thuoc: $sizeMB MB — da nhung san $($items.Count) anh, khong can thu muc di kem."
Write-Host ""
Read-Host "  Nhan Enter de dong"
