## レビュー指摘対応メモ

* Docker-OpenAM
    * CentOS イメージベースの初期設定済みイメージを稼働させると初期設定画面が表示されます
        * docker build と docker run で Tomcat の実行ユーザーが異なっていることが原因です
