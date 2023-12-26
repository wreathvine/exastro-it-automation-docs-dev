============
ログイン方法
============

はじめに
========

| 本書は、システム管理の画面操作する際のログイン方法について記載したものです。

.. _system_manager_login:

ログイン
========

#. | ログイン時は、必ずユーザ名とパスワードを準備の上、ログインしてください。

   .. figure:: /images/ja/manuals/platform/login/exastro-login.png
      :alt: ログイン
      :width: 600px
      :align: left
      :class: with-border-thin

   .. list-table:: ログイン時の入力内容
      :widths: 10 10
      :header-rows: 1
      :align: left

      * - ユーザ名
        - パスワード
      * - admin ※
        - password  ※

   .. tip::
             |  ユーザー名、パスワードは、インストール時に指定したシステム管理者のユーザ名、パスワードを使用してください。
             |  docker版でインストールした際のユーザ名、パスワードは、「 :ref:`install_docker_compose_v2.2` 」を参照
             |  helm版でインストールした際のユーザ名は、パスワード、「 :ref:`install_helm_v2.2` 」を参照

#. | ログイン後、下記のようにオーガナイゼーション管理画面が表示されます。

   .. todo:: オーガナイゼーション管理画面（一覧）の画像に差し替え

   .. figure:: /images/ja/diagram/login_workspace.png
      :alt: オーガナイゼーション管理画面（一覧）
      :width: 600px
      :align: left
      :class: with-border-thin

.. include:: ../it_automation_base/setting_profile.rst