# mautic-install4Ubuntu
Ubuntu環境に、Mauticをインストールするためのスクリプトです。

## Step1：スクリプトの入手 
install.shをコピー&ペーストするか、ダウンロードします。<br>

## Step2：パーミッション変更とスクリプト実行
スクリプトを実行すると、Ubuntu 16.04.1をターゲットに、ApacheやPHP、MariaDBといった必要なソフトウェアが自動でインストールされます。<br>
途中で、MariaDBのrootパスワードの入力やEnterキーを押すことを求められます。<br>
スクリプトにより、下記ポートが開放されます。ご使用の環境に合わせて、「install.sh」を変更してください。<br>
ポート 22 <br>
ポート 80 <br>
ポート 443 <br>
ポート 3306 <br>
```
# chmod a+x install.sh
# ./install.sh
```
## Step3：ファイアウォール有効化
IBM Bluemix Infrastructure(Bluemix IaaS)を利用の場合は、拡張モニタリングを有効化するために、指定のIPとポート範囲を許可します。<br>
```
# ufw allow from 10.0.0.0/8 to any port 48000:48020 proto tcp
```
ファイアウォール有効化 <br>
```
# ufw enable
```
## Step4：Mautic用データベースの作成
データベース名：mautic_db <br>
データベースユーザー名：mauticdbuser <br>
パスワード：mautic_passwd <br>
```
# mysql -u root -p

MariaDB [(none)]> CREATE DATABASE mautic_db;
MariaDB [(none)]> GRANT ALL PRIVILEGES ON mautic_db.* TO mauticdbuser@'%' IDENTIFIED BY 'mautic_passwd';
MariaDB [(none)]> FLUSH PRIVILEGES;
MariaDB [(none)]> exit
```
## Step5：Webブラウザからセットアップ
Webブラウザからサーバーにアクセスし、Mauticのセットアップを開始します。 <br>
セットアップが完了しますと、ログイン画面が表示されます。英語画面なので、日本語画面に変更するには、下記の動画をご覧ください。<br>
Mauticの日本語化：https://youtu.be/xw-YEvDBkss
