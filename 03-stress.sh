# epelを追加
sudo amazon-linux-extras install -y epel

# stress-ngとhtopを追加
sudo yum -y stress-ng htop

# 10分間、CPUに負荷をかける
stress-ng --cpu 1 --timeout 600

# htopで負荷状況を確認(「Q」で終了)
htop
