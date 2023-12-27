========
ユーザー
========

はじめに
========

| 本書では、Exastro システム におけるユーザーについて説明します。


ユーザーの登録
==============
| Exastro システムで使用するユーザーを登録出来ます。
| ユーザーは、付与されているロールでユーザーの役割を区別します。
| ユーザーに割り当てられるロールの詳細につきましては :doc:`../organization_management/role` をご参照ください。

ユーザーの作成
--------------

| ユーザーは、下記の方法で作成します。

#. | Exastro Platformにオーガナイゼーション管理者でログインします。

#. | Exastro Platformのメニューより :menuselection:`ユーザー管理` をクリックします。

   .. image:: /images/ja/manuals/platform/platform_menu.png
      :width: 200px
      :align: left

#. | :menuselection:`ユーザー一覧` 画面が表示されるので、 :guilabel:`作成` をクリックします。

   .. figure:: /images/ja/manuals/platform/user/ユーザー一覧画面.png
      :width: 600px
      :align: left

   .. note:: | ユーザー管理権限を有するロールに紐づくユーザー以外でログインしている時は、メニューに :menuselection:`ユーザー管理` は表示されません。
      | ユーザー管理権限を有するロールは以下の3つです。
      | _orgnization-manager,_orgnization-user-manager,_orgnization-user-role-manager

#. | :menuselection:`新規ユーザー` 画面が表示されるので、ユーザーの情報を入力し、 :guilabel:`登録` をクリックします。

   .. figure:: /images/ja/manuals/platform/user/新規ユーザー作成画面.png
      :width: 600px
      :align: left

   .. list-table:: 新規ユーザー登録
      :widths: 40 200
      :header-rows: 1
      :align: left
   
      * - 項目名
        - 説明
      * - ユーザーID
        - | ユーザーに割り当てる一意のIDを自動で付与します。
          | ここで指定した ID を使ってシステム間の連携を行います。
      * - ユーザー名
        - | ユーザーに割り当てる名前を指定します。
      * - パスワード
        - | アカウントにログインするためのパスワードを設定します。
          | 初回ログイン時パスワード変更要求のチェックボックスを指定すると、該当ユーザーが初回ログイン時、パスワード変更が要求されます。（推奨）
          | 初回ログイン時パスワード変更要求のチェックボックスを指定しない場合、入力したパスワードをそのまま利用することができます。

ユーザーの編集
---------------

#. | Exastro Platformにオーガナイゼーション管理者でログインします。

#. | Exastro Platformのメニューより :menuselection:`ユーザー管理` をクリックします。

   .. image:: /images/ja/manuals/platform/platform_menu.png
      :width: 200px
      :align: left

#. | :menuselection:`ユーザー一覧` 画面が表示されるので、 :guilabel:`編集` をクリックします。

   .. figure:: /images/ja/manuals/platform/user/ユーザー一覧画面_edit.png
      :width: 600px
      :align: left

#. | :menuselection:`ユーザー編集` 画面が表示されるので、ユーザーの情報を編集し、 :guilabel:`登録` をクリックします。

   .. figure:: /images/ja/manuals/platform/user/ユーザー編集画面.png
      :width: 600px
      :align: left

   .. tips::
      | ユーザーID、ユーザー名の変更は出来ません。

ユーザーの削除
--------------

#. | Exastro Platformにオーガナイゼーション管理者でログインします。

#. | Exastro Platformのメニューより :menuselection:`ユーザー管理` をクリックします。

   .. image:: /images/ja/manuals/platform/platform_menu.png
      :width: 200px
      :align: left

#. | :menuselection:`ユーザー一覧` 画面が表示されるので、 :guilabel:`削除` をクリックします。

   .. figure:: /images/ja/manuals/platform/user/ユーザー一覧画面_delete.png
      :width: 600px
      :align: left

#. | 確認メッセージが表示されるので、オーガナイゼーションIDとユーザー名を入力し、 :guilabel:`はい、削除します` をクリックします。

   .. figure:: /images/ja/manuals/platform/user/ユーザー削除実行確認画面.png
      :width: 600px
      :align: left

   .. tips::
      | 一度削除したユーザーを復元することは出来ません。
      | オーガナイゼーション管理者を削除することは出来ません。
