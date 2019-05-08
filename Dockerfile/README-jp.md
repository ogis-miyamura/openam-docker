# OpenAM-jp/OpenAM Dockerfile

最新の [OpenAM-jp/OpenAM](https://github.com/openam-jp/openam) を Docker コンテナとして柔軟に利用できます。


## クイックスタート

### 簡易セットアップ済みの OpenAM コンテナを起動する手順（Tomcat オフィシャルイメージベース）

1. ホスト名 `openam.example.com` が適切に名前解決されるよう、 DNS または hosts ファイルの設定を行います

1. Docker がセットアップされた環境で `OpenAM-jp/OpenAM` のコンテナ起動コマンドを実行し、しばらく待ちます

        docker run -d --rm -p 18080:8080 --name openam ogismiyamura/openam:trial

1. WEB ブラウザで次の URL にアクセスし、 OpenAM の管理者としてログインします

| 項目 | 内容 |
|---|---|
| アクセスURL | http://openam.example.com:18080/sso/XUI/#login/ |
| 管理者ID | amadmin |
| 管理者Password | adM1npassword |


### 簡易セットアップ済みの OpenAM コンテナを起動する手順（CentOS 7 イメージベース）

- コンテナのタグ名として次のいずれかを指定します

        cent7-tomcat85-trial
        cent7-tomcat90-trial

- コマンド例：

        docker run -d \
                --rm \
                -p 18080:8080 \
                --name openam \
                ogismiyamura/openam:cent7-tomcat85-trial


### OpenAM コンテナを起動した直後に、自動セットアップを行う手順

- コンテナのタグ名として次のいずれかを指定します

        cent7-tomcat85
        cent7-tomcat90
        tomcat85

- コンテナ起動コマンドに以下のオプション および 任意のセットアップオプションを指定します

        -e OPENAM_CONFIGURATION_MODE=POST

- コマンドの例

        docker run -d \
                --rm \
                -p 18080:8080 \
                --name openam \
                -e OPENAM_CONFIGURATION_MODE=POST \
                -e OPENAM_HOSTNAME=sso.XXXXXX.co.jp \
                -e OPENAM_COOKIE_DOMAIN=.XXXXXX.co.jp \
                -e OPENAM_ROOT_SUFFIX='dc=sso,dc=XXXXXX,dc=co,dc=jp' \
                -e OPENAM_ADMIN_PASSWORD=YYYYYY \
                -e OPENAM_LDAPADMIN_PASSWORD=ZZZZZZ \
                ogismiyamura/openam:cent7-tomcat85


### 未セットアップの OpenAM コンテナを起動し、GUIを用いて手動セットアップを行う手順

- コンテナのタグ名として次のいずれかを指定します

        cent7-tomcat85
        cent7-tomcat90
        tomcat85

- コマンド例：

        docker run -d \
                --name openam \
                --privileged \
                --rm \
                -p 18080:8080 \
                ogismiyamura/openam:cent7-tomcat85


### Tomcat をサービスとして起動する場合

- 仮想サーバー的な使い方に適しています
- 特権オプションが必要となり、安全性が比較的低くなります
- コンテナ起動コマンドに以下のオプションを追加します（`/sbin/init` は末尾に記述します）

        --privileged
        -v /sys/fs/cgroup:/sys/fs/cgroup:ro
        /sbin/init

- コマンド例：

        docker run -d \
                --rm \
                -p 18080:8080 \
                --name openam \
                --privileged \
                -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
                ogismiyamura/openam:cent7-tomcat85-trial \
                /sbin/init


### Dockerfile を任意のオプションでビルドする例

- コマンド例（Tomcat オフィシャルイメージベース、事前セットアップ、Tomcat8.5）：

        docker build \
                --build-arg IMAGE_FROM='tomcat:8.5-jre8' \
                --build-arg SUDO_TOMCAT_CMD='' \
                --build-arg OPENAM_CONFIGURATION_MODE='PRE' \
                -t 'openam-tomcat85' \
                .

- コマンド例（CentOS 7 オフィシャルイメージベース、GUI手動セットアップ、Tomcat8.5）：

        docker build \
                --build-arg IMAGE_FROM='centos:centos7' \
                --build-arg SUDO_TOMCAT_CMD='sudo -u tomcat ' \
                --build-arg CENTOS7_TOMCAT_MAJOR='8' \
                --build-arg CENTOS7_TOMCAT_VERSION='8.5.38' \
                --build-arg CENTOS7_JDK_VERSION='1.8.0' \
                -t 'openam-cent7-tomcat85' \
                .
