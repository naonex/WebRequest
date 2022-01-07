Write-Output "Rev.2022.01.08"
Write-Output "WebRequest���[�v����X�N���v�g Ver:2.1"
Write-Output ""

# �ݒ�t�@�C���ǂݍ���
Get-Content .\setting.ini | ForEach-Object {
    # null�E�󕶎� or �u;�i�R�����g�A�E�g�j�v�͖���
    if ((-not $_) -or ($_.ToString() -match "^;")) {return}
    # SECTION����
    if ( $_.ToString() -match "^\[.*\]$") {
        $SECTION=$_.ToString()
        Write-Output $SECTION
        return
    }
    if (($SECTION -eq "[API]") -or ($SECTION -eq "[POST]") -or ($SECTION -eq "[SCHEDULE]")) {
        $line = $_.split("=")
        # split���ė�����null�E�󕶎��łȂ���Εϐ���
        if ($line[0] -and $line[1]) {
            set-variable -name $line[0] -value $line[1]
            Write-Output ($line[0].ToString() + "=" + $line[1].ToString())
        }
    }
}
Write-Output ""

# http���N�G�X�gbody�����n�b�V���e�[�u���Ƃ��ĕێ�
$postParams = Get-Content $requestBody | ConvertFrom-Json

# �J�E���g�p�ݒ�
# �L���t�@�C���̑��݊m�F
if (Test-Path $counterFile) {
    [long]$No = Get-Content $counterFile
} else {
    [long]$No = 0
}

# ������r�ݒ�
$STARTTIME = Get-Date $STARTTIME; $ENDTIME = Get-Date $ENDTIME
$CurrentTime = Get-Date; Write-Output $CurrentTime
# �w�莞�Ԃ̊ԃ��[�v
while (($CurrentTime -ge $STARTTIME) -and ($CurrentTime -le $ENDTIME)) {
    # data���̐��������[�v
    foreach($postParam in $postParams."data".GetEnumerator()){
        # �J�E���g�A�b�v�i�J�E���^�[�t�@�C���X�V�j
        $No = $No + 1
        Write-Output $No | Tee-Object -FilePath $counterFile
        # No��ύX
        $postParam."No" = $No
    }
    # json�ɍĕϊ�
    $Body = ConvertTo-Json $postParams
    # ���s�R�[�h�Ɨ]���ȋ󔒂����O
    $Body = $Body -replace "`r`n *",""
    
    # ���N�G�X�g���M
    # Post
    Invoke-WebRequest $API_URL -Method Post -Body $Body -Headers @{"Content-type"="application/json"} 
    #Invoke-RestMethod $API_URL -Method Post -Body $Body -ContentType application/json
    ## Get�T���v��
    ##Invoke-WebRequest $API_URL -Method Get
    ##Invoke-RestMethod $API_URL -Method Get

    # 1�b�ҋ@��A�����ăZ�b�g
    Write-Output ""
    Start-Sleep -s $loopInterval
    $CurrentTime = Get-Date; Write-Output $CurrentTime
}
