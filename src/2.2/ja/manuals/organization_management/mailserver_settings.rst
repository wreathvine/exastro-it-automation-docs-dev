====================
メール送信サーバ設定
====================


はじめに
========

| 本書では、Exastro Suite における メール送信サーバ設定  について説明します。

メール送信サーバの設定
======================

| メールでイベントの通知を受け取るためには、送信用メールサーバの設定を行う必要があります。

メール送信サーバの登録
----------------------

| メール送信サーバは、下記の方法で登録します。

#. | Exastro Platformにオーガナイゼーション管理者でログインします。

#. | Exastro Platformのメニューより :menuselection:`メール送信サーバ設定` をクリックします。

   .. image:: /images/ja/manuals/platform/platform_menu.png
      :width: 200px
      :align: left

#. | :menuselection:`メール送信サーバ設定` 画面が表示されるので、メール送信サーバの情報を入力し、 :guilabel:`登録` をクリックします。

   .. figure:: /images/ja/manuals/platform/mailserver_settings/メール送信サーバ設定.png
      :width: 600px
      :align: left

   .. list-table:: メール送信サーバ設定登録
      :widths: 40 200
      :header-rows: 1
      :align: left
   
      * - 項目名
        - 説明
      * - SMTPサーバーホスト
        - | ワークスペースに割り当てる一意のIDを指定します。
          | ここで指定した ID を使ってシステム間の連携を行います。
      * - 暗号化方式
        - | ワークスペースに割り当てる名前を指定します。
      * - SMTPサーバーポート
        - | 本番環境、検証環境、開発環境といった作成する環境の一覧を入力します。
          | この環境はオペレーションに割り当てることが可能です。
      * - 認証あり
        - | ワークスペースの説明を記載します。
      * - 送信元表示名
        - | ワークスペースに割り当てる一意のIDを指定します。
          | ここで指定した ID を使ってシステム間の連携を行います。
      * - 送信先メールアドレス(Reply-to)
        - | ワークスペースに割り当てる名前を指定します。
      * - 送信先表示名
        - | 本番環境、検証環境、開発環境といった作成する環境の一覧を入力します。
          | この環境はオペレーションに割り当てることが可能です。
      * - 差出人メールアドレス
        - | ワークスペースの説明を記載します。
     
メール送信サーバの削除
----------------------

#. | Exastro Platformにオーガナイゼーション管理者でログインします。

#. | Exastro Platformのメニューより :menuselection:`メール送信サーバ設定` をクリックします。

   .. image:: /images/ja/manuals/platform/platform_menu.png
      :width: 200px
      :align: left

#. | :menuselection:`メール送信サーバ設定` 画面が表示されるので、 :guilabel:`設定削除` をクリックします。

   .. figure:: /images/ja/manuals/platform/mailserver_settings/メール送信サーバ設定_delete.png
      :width: 600px
      :align: left

#. | 確認メッセージが表示されるので、削除を入力し、 :guilabel:`はい、削除します` をクリックします。

   .. figure:: /images/ja/manuals/platform/mailserver_settings/メール送信サーバ設定削除実行確認画面.png
      :width: 600px
      :align: left

   .. note::
      | 一度削除したメール送信サーバ設定を復元することは出来ません。
