# OpenAM-jp/OpenAM Dockerfile

最新の [OpenAM-jp/OpenAM](https://github.com/openam-jp/openam) を Docker コンテナとして柔軟に利用できます。


## 利用方法

### セットアップ済みの OpenAM を起動する手順

1. ホスト名 `openam.example.com` が適切に名前解決されるよう、 DNS または hosts ファイルの設定を行います

1. Docker がセットアップされた環境で `OpenAM-jp/OpenAM` のコンテナ起動コマンドを実行し、しばらく待ちます

        docker run -d -p 18080:8080 --name openam ogismiyamura/openam:trial

1. WEB ブラウザで次の URL にアクセスし、 OpenAM の管理者としてログインします

        http://openam.example.com:18080/sso/XUI/#login/
        # ID / Password: amadmin / adM1npassword


### CentOS 7 ベースのセットアップ済み OpenAM コンテナを起動する手順

1. systemd を使用せず Tomcat を直接起動する場合

    - `OpenAM-jp/OpenAM` のコンテナ起動コマンドを次の内容に変更します

            docker run -d \
                --name openam \
                --rm \
                -p 18080:8080 \
                ogismiyamura/openam:cent7-tomcat80-trial

1. systemd を使用して Tomcat をサービスとして起動する場合

    - `OpenAM-jp/OpenAM` のコンテナ起動コマンドを次の内容に変更します

            docker run -d \
                --name openam \
                --privileged \
                --rm \
                -p 18080:8080 \
                -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
                ogismiyamura/openam:cent7-tomcat80-trial \
                /sbin/init


### 未セットアップの OpenAM コンテナを起動し、手動で設定を行う手順

1. コンテナイメージのタグ ID を次の値に変更します
    - `:trial` -> `:tomcat80`
    - `:cent7-tomcat80-trial` -> `cent7-tomcat80`


### Dockerfile をビルドする手順

1. ソースコードを取得します

        git clone https://github.com/ogis-miyamura/openam-docker.git
        cd openam-docker/Dockerfile

1. Dockerfile 内のパラメータやスクリプトなどを調整し、次のコマンドを実行します

    - Tomcat8 のオフィシャルイメージをベースとする場合

            IMAGE_FROM='tomcat:8.0-jre8'
            SUDO_TOMCAT_CMD=''
            OPENAM_PRECONFIGURE='y'
            CENTOS7_TOMCAT_MAJOR=
            CENTOS7_TOMCAT_VERSION=
            CENTOS7_JDK_VERSION=
            IMAGE_NAME='openam'

            docker build \
                --build-arg IMAGE_FROM=${IMAGE_FROM} \
                --build-arg SUDO_TOMCAT_CMD=${SUDO_TOMCAT_CMD} \
                --build-arg OPENAM_PRECONFIGURE=${OPENAM_PRECONFIGURE:-"n"} \
                --build-arg CENTOS7_TOMCAT_MAJOR=${CENTOS7_TOMCAT_MAJOR:-""} \
                --build-arg CENTOS7_TOMCAT_VERSION=${CENTOS7_TOMCAT_VERSION:-""} \
                --build-arg CENTOS7_JDK_VERSION=${CENTOS7_JDK_VERSION:-""} \
                -t ${IMAGE_NAME} \
                .

    - CentOS 7 のオフィシャルイメージをベースとしたい場合

            IMAGE_FROM='centos:centos7'
            SUDO_TOMCAT_CMD='sudo -u tomcat '
            OPENAM_PRECONFIGURE='y'
            CENTOS7_TOMCAT_MAJOR='8'
            CENTOS7_TOMCAT_VERSION='8.0.53'
            CENTOS7_JDK_VERSION='1.8.0'
            IMAGE_NAME='openam'

            docker build \
                --build-arg IMAGE_FROM=${IMAGE_FROM} \
                --build-arg SUDO_TOMCAT_CMD=${SUDO_TOMCAT_CMD} \
                --build-arg OPENAM_PRECONFIGURE=${OPENAM_PRECONFIGURE:-"n"} \
                --build-arg CENTOS7_TOMCAT_MAJOR=${CENTOS7_TOMCAT_MAJOR:-""} \
                --build-arg CENTOS7_TOMCAT_VERSION=${CENTOS7_TOMCAT_VERSION:-""} \
                --build-arg CENTOS7_JDK_VERSION=${CENTOS7_JDK_VERSION:-""} \
                -t ${IMAGE_NAME} \
                .
