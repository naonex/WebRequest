Write-Output "Rev.2022.01.08"
Write-Output "WebRequestループするスクリプト Ver:2.1"
Write-Output ""

# 設定ファイル読み込み
Get-Content .\setting.ini | ForEach-Object {
    # null・空文字 or 「;（コメントアウト）」は無視
    if ((-not $_) -or ($_.ToString() -match "^;")) {return}
    # SECTION判定
    if ( $_.ToString() -match "^\[.*\]$") {
        $SECTION=$_.ToString()
        Write-Output $SECTION
        return
    }
    if (($SECTION -eq "[API]") -or ($SECTION -eq "[POST]") -or ($SECTION -eq "[SCHEDULE]")) {
        $line = $_.split("=")
        # splitして両方がnull・空文字でなければ変数化
        if ($line[0] -and $line[1]) {
            set-variable -name $line[0] -value $line[1]
            Write-Output ($line[0].ToString() + "=" + $line[1].ToString())
        }
    }
}
Write-Output ""

# httpリクエストbody部をハッシュテーブルとして保持
$postParams = Get-Content $requestBody | ConvertFrom-Json

# カウント用設定
# 記憶ファイルの存在確認
if (Test-Path $counterFile) {
    [long]$No = Get-Content $counterFile
} else {
    [long]$No = 0
}

# 時刻比較設定
$STARTTIME = Get-Date $STARTTIME; $ENDTIME = Get-Date $ENDTIME
$CurrentTime = Get-Date; Write-Output $CurrentTime
# 指定時間の間ループ
while (($CurrentTime -ge $STARTTIME) -and ($CurrentTime -le $ENDTIME)) {
    # data部の数だけループ
    foreach($postParam in $postParams."data".GetEnumerator()){
        # カウントアップ（カウンターファイル更新）
        $No = $No + 1
        Write-Output $No | Tee-Object -FilePath $counterFile
        # Noを変更
        $postParam."No" = $No
    }
    # jsonに再変換
    $Body = ConvertTo-Json $postParams
    # 改行コードと余分な空白を除外
    $Body = $Body -replace "`r`n *",""
    
    # リクエスト送信
    # Post
    Invoke-WebRequest $API_URL -Method Post -Body $Body -Headers @{"Content-type"="application/json"} 
    #Invoke-RestMethod $API_URL -Method Post -Body $Body -ContentType application/json
    ## Getサンプル
    ##Invoke-WebRequest $API_URL -Method Get
    ##Invoke-RestMethod $API_URL -Method Get

    # 1秒待機後、時刻再セット
    Write-Output ""
    Start-Sleep -s $loopInterval
    $CurrentTime = Get-Date; Write-Output $CurrentTime
}
