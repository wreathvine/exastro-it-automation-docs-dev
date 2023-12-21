
個人設定
------------

個人設定では、自身のアカウント編集、パスワード変更、二要素認証設定、トークン発行が行えます。

#. | 個人設定はログインユーザのアイコンを選択して表示されるメニューから設定できます。

   .. image:: /images/ja/manuals/platform/login/setting_profile.png
      :alt: 個人設定
      :width: 6.67391in

   .. note::
      |  Exastro IT Automation利用中は、アカウント管理メニューは表示されません

アカウント編集
^^^^^^^^^^^^^^^^^^^^^^^

#. | アカウント編集より、Eメール、名、姓を変更することができます。

   .. image:: /images/ja/manuals/platform/login/setting_profile_account.png
      :alt: 個人設定_アカウント編集
      :width: 6.67391in

   .. note::
      |  ※ユーザ名は変更できません。

パスワード変更
^^^^^^^^^^^^^^^^^^^^^^^

#. | パスワード変更より、自身のパスワードを変更することができます。

   .. image:: /images/ja/manuals/platform/login/setting_profile_password.png
      :alt: 個人設定_パスワード変更
      :width: 6.67391in

二要素認証設定
^^^^^^^^^^^^^^^^^^^^^^^

#. | 二要素認証設定より、パスワード＋他の認証方式でのログインが行えるようになります。

   .. image:: /images/ja/manuals/platform/login/setting_profile_auth.png
      :alt: 個人設定_二要素認証設定
      :width: 6.67391in

トークン発行
^^^^^^^^^^^^^^^^^^^^^^^

本システムにおいて、APIを呼び出す際に必要となるアクセストークンがありますが、アクセストークンの発行には、本説明で説明するリフレッシュトークンが必要となります。

.. tip::
   | APIの認証については、「 :doc:`../../reference/index` 」-「 :doc:`../../reference/api/index` 」-「 :doc:`../../reference/api/operator/index` - :doc:`../../reference/api/operator/certification` 」、「 :doc:`../../reference/api/system_manager/index` - :doc:`../../reference/api/system_manager/certification` 」参照

#. | トークン発行より、API実行に必要なトークンの発行ならびに発行したトークンの一覧表示を行うことができます。

   .. image:: /images/ja/manuals/platform/login/setting_profile_token.png
      :alt: 個人設定_トークン一覧
      :width: 6.67391in

#. | 初めてトークンを発行する際は、:guilabel:`発行` ボタンを押下して、必要な情報を入力しトークンを発行することができます。

   | 二要素認証を使用している場合は、二要素認証で使用しているアプリケーションのワンタイムパスワードを入力する必要があります。

   .. image:: /images/ja/manuals/platform/login/setting_profile_token_issue.png
      :alt: 個人設定_トークン発行
      :width: 6.67391in

#. | 発行されたトークンは、再表示できませんので必ず発行結果の画面のトークンを保存する必要があります。

   .. image:: /images/ja/manuals/platform/login/setting_profile_token_issue_ok.png
      :alt: 個人設定_トークン発行OK
      :width: 6.67391in

#. | 発行したトークンの有効期限は、トークン一覧で確認できます。

   .. image:: /images/ja/manuals/platform/login/setting_profile_token_list.png
      :alt: 個人設定_トークン一覧
      :width: 6.67391in

#. | 発行したトークンが不要となった際は、:guilabel:`削除` ボタンを押下して、トークンを削除することができます。

   .. image:: /images/ja/manuals/platform/login/setting_profile_token_list_delete.png
      :alt: 個人設定_トークン一覧(削除)
      :width: 6.67391in

   | 削除確認で本当に削除する場合は、"yes"を入力して、:guilabel:`はい、削除します` ボタンを押下します。 

   .. image:: /images/ja/manuals/platform/login/setting_profile_token_delete.png
      :alt: 個人設定_トークン削除
      :width: 6.67391in

   .. warning::
      |  削除した際、すべてのトークンが無効となります。
