param(
  [Parameter(Mandatory=$true)][string]$Pdf,
  [Parameter(Mandatory=$true)][string]$OutDir,
  [int]$Width = 1700
)

Add-Type -AssemblyName System.Runtime.WindowsRuntime | Out-Null

$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
  $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and
  $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
})[0]

function Await($op, $type) {
  $m = $asTaskGeneric.MakeGenericMethod($type)
  $t = $m.Invoke($null, @($op))
  $t.Wait(-1) | Out-Null
  $t.Result
}

function AwaitAction($act) {
  $m = ([System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object {
    $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and -not $_.IsGenericMethod
  })[0]
  $t = $m.Invoke($null, @($act))
  $t.Wait(-1) | Out-Null
}

[Windows.Storage.StorageFile,      Windows.Storage,   ContentType=WindowsRuntime] | Out-Null
[Windows.Storage.StorageFolder,    Windows.Storage,   ContentType=WindowsRuntime] | Out-Null
[Windows.Data.Pdf.PdfDocument,     Windows.Data.Pdf,  ContentType=WindowsRuntime] | Out-Null
[Windows.Data.Pdf.PdfPageRenderOptions, Windows.Data.Pdf, ContentType=WindowsRuntime] | Out-Null

if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }

$pdfFile = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync((Resolve-Path $Pdf).Path)) ([Windows.Storage.StorageFile])
$doc     = Await ([Windows.Data.Pdf.PdfDocument]::LoadFromFileAsync($pdfFile)) ([Windows.Data.Pdf.PdfDocument])
$folder  = Await ([Windows.Storage.StorageFolder]::GetFolderFromPathAsync((Resolve-Path $OutDir).Path)) ([Windows.Storage.StorageFolder])

"PAGES=$($doc.PageCount)"

for ($i = 0; $i -lt $doc.PageCount; $i++) {
  $page = $doc.GetPage($i)
  $name = "page{0:D2}.png" -f ($i + 1)

  $outFile = Await ($folder.CreateFileAsync($name, [Windows.Storage.CreationCollisionOption]::ReplaceExisting)) ([Windows.Storage.StorageFile])
  $stream  = Await ($outFile.OpenAsync([Windows.Storage.FileAccessMode]::ReadWrite)) ([Windows.Storage.Streams.IRandomAccessStream])

  $opts = New-Object Windows.Data.Pdf.PdfPageRenderOptions
  $opts.DestinationWidth = [uint32]$Width

  AwaitAction ($page.RenderToStreamAsync($stream, $opts))
  $stream.Dispose()
  $page.Close()

  "WROTE=$name"
}
